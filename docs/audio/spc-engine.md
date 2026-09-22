# Illusion of Gaia — SPC700 Sound Engine Reference

_Comprehensive reverse-engineering documentation of the IoG N-SPC audio engine._

**Engine binary:** 3,026 bytes uploaded to ARAM at boot from `spc_sound_engine` in [`spc_transfer.asm`](../../extracted/system/engine/spc_transfer.asm).

**Variant:** N-SPC (Nintendo SPC, Quintet-customized). Used by Quintet across the Soul Blazer trilogy (Soul Blazer, Illusion of Gaia, Terranigma).

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [ARAM Memory Map](#aram-memory-map)
3. [BGM File Format](#bgm-file-format)
4. [Song Structure: Phrase Lists and Patterns](#song-structure-phrase-lists-and-patterns)
5. [Instrument Definitions](#instrument-definitions)
6. [Duration / Velocity Table](#duration--velocity-table)
7. [Sequence Data Byte Encoding](#sequence-data-byte-encoding)
8. [N-SPC Instruction Set](#n-spc-instruction-set)
9. [Pitch Calculation Algorithm](#pitch-calculation-algorithm)
10. [ADSR Envelope System](#adsr-envelope-system)
11. [Tempo and Timing](#tempo-and-timing)
12. [Echo / Reverb](#echo--reverb)
13. [Sample Directory and BRR Playback](#sample-directory-and-brr-playback)
14. [Per-Song Instrument Slot Mapping](#per-song-instrument-slot-mapping)
15. [Known Quirks and Discoveries](#known-quirks-and-discoveries)

---

## Architecture Overview

The SNES audio subsystem is a separate coprocessor (Sony SPC700) with 64 KB of dedicated ARAM (Audio RAM). Communication between the 65C816 main CPU and the SPC700 occurs through four 8-bit I/O ports (`$2140`–`$2143` / APU `$F4`–`$F7`).

At cold boot, the 65C816 uploads the 3,026-byte sound engine binary to ARAM via the IPL bootstrap protocol. For each new BGM track, the 65C816 uploads the track's data blocks (sequence data, instrument definitions, velocity table, sample directory, and BRR sample data) to specific ARAM addresses, then sends a play command.

The SPC700 engine runs an internal tick-based sequencer:
- **Timer 1** fires at 500 Hz (divisor `$10` = 16 from the 8 kHz base)
- Each timer fire: `accumulator += tempoByte`
- A **sequence tick** occurs whenever the accumulator overflows (≥ 256)
- **24 ticks = 1 quarter note** (N-SPC standard)

The engine processes 8 simultaneous voices, each reading from its own sequence data stream.

---

## ARAM Memory Map

| Address | Size | Contents |
|---------|------|----------|
| `$0000`–`$00FF` | 256 | Zero page (engine state, per-channel registers) |
| `$0100`–`$01FF` | 256 | Stack |
| `$0200`–`$0591` | ~1000 | Engine code (main loop, handlers) |
| `$0592`–`$05F0` | ~96 | **Pitch calculation routine** |
| `$0E59`–`$0E71` | 26 | **Frequency table** (13 × 16-bit entries, C through C+) |
| `$0FE0`–`$0FE5` | 6 | **SPC slot assignment table** (per-song SRCN indices) |
| `$0FFC`–`$0FFD` | 2 | **Song base pointer** (ARAM addr of sequence data) |
| `$0FFE`–`$0FFF` | 2 | **Sample end pointer** (first byte after sample data) |
| `$1000`–`$1037` | 56 | Extended sample directory (14 entries × 4 bytes) |
| `$1038`–`$104F` | 24 | **Standard sample directory** (6 entries × 4 bytes) |
| `$1200`–`$1253` | 84 | Driver init script (optional per-song configuration) |
| `$1254`–`$1277` | 36 | **Instrument definitions** (6 instruments × 6 bytes) |
| `$1300`–`$1317` | 24 | **Duration / Velocity table** |
| `$1400`+ | variable | Extended song sequence data (for large songs) |
| `$5532`+ | variable | Standard song sequence data |
| varies | variable | BRR sample data (fills remaining ARAM) |

---

## BGM File Format

Each `.bgm` file is a self-contained music bundle containing everything the SPC needs to play a track. Structure:

```
┌─────────────────────────────────────────────┐
│  Block 0: [u16 size] [u16 target] [payload] │  ← e.g. instrument defs → ARAM $1254
│  Block 1: [u16 size] [u16 target] [payload] │  ← e.g. velocity table → ARAM $1300
│  Block 2: [u16 size] [u16 target] [payload] │  ← e.g. sequence data → ARAM $5532
│  ...                                        │
│  Terminator: [u16 size=0] [u16 target]      │  ← target = sample end address
├─────────────────────────────────────────────┤
│  [u8 instrumentCount]                       │
│  [u8 instrumentId] × instrumentCount        │  ← global sample IDs for this song
└─────────────────────────────────────────────┘
```

### Block types (by ARAM target address)

| Target | Purpose | Typical Size |
|--------|---------|-------------|
| `$1254` | Instrument definitions | `instrumentCount × 6` bytes |
| `$1300` | Duration/velocity table | 24 bytes |
| `$5532` or `$1400` | Sequence data (patterns + channel data) | 500–3000 bytes |
| `$1038` | Sample directory (standard) | 24 bytes |
| `$1000` | Sample directory (extended) | 56 bytes |
| `$0FFC` | Song base pointer | 2 bytes |
| `$0FFE` | Sample end pointer | 2 bytes |
| `$0FE0` | SPC slot assignment | 6 bytes |
| `$1200` | Driver init script | 24 bytes (optional) |

### Instrument ID trailer

After the terminator block, the file contains:
- `u8 instrumentCount` — number of distinct instruments used by this song
- `u8[instrumentCount]` — global sample IDs (indices into `SAMPLE_TABLE`)

These IDs map per-song slot numbers (from `$E0` setInstrument commands) to the global instrument pool.

---

## Song Structure: Phrase Lists and Patterns

### Sequence data layout

The sequence data block contains three levels of hierarchy:

```
Sequence Data Block (at song base address)
├── Phrase List Header: [u16 phraseListPtr]
├── Phrase List: [u16 patternAddr]... [u16 0x00FF] [u16 loopTarget] [u16 0x0000]
├── Pattern A (intro):  [u16 ch0Ptr] [u16 ch1Ptr] ... [u16 ch7Ptr]
├── Pattern B (loop):   [u16 ch0Ptr] [u16 ch1Ptr] ... [u16 ch7Ptr]
├── Channel 0 intro data: [byte stream...]
├── Channel 0 loop data:  [byte stream...]
├── Channel 1 intro data: [byte stream...]
│   ...
└── Channel 7 loop data:  [byte stream...]
```

### Phrase list format

The phrase list is a flat array of `u16` entries:

| Entry Value | Meaning |
|-------------|---------|
| `addr` (valid ARAM) | Pointer to a pattern (16-byte block of 8 channel pointers) |
| `$00FF` | **Loop marker** — next `u16` is the ARAM address to jump back to in the phrase list |
| `$0000` | **End marker** — stop playback |

**Standard songs:** One or two patterns (intro + loop), with `$00FF` marking the loop jump target.

**Minimal songs** (e.g., `lolas_melody`): Single pattern with no `$00FF` marker. The engine implicitly loops the pattern.

**Extended songs** (e.g., `illusion_of_gaia`): Same format but sequence data is at ARAM `$1400` instead of `$5532`, allowing more BRR sample space.

### Pattern format

Each pattern is 16 bytes: 8 × `u16` ARAM pointers, one per voice channel:

```
[u16 ch0Ptr] [u16 ch1Ptr] [u16 ch2Ptr] [u16 ch3Ptr]
[u16 ch4Ptr] [u16 ch5Ptr] [u16 ch6Ptr] [u16 ch7Ptr]
```

A pointer of `$0000` means the channel is silent in this pattern.

### State persistence: intro → loop

**Critical:** The SPC engine does NOT reset channel state when transitioning from the intro pattern to the loop pattern. All state set during the intro (per-voice transpose, current duration, velocity, gate fraction, channel volume) persists into the loop. This is commonly used for setup — the intro pattern initializes instruments, volumes, panning, and transposes with no notes, while the loop pattern contains the actual music.

---

## Instrument Definitions

Each song uploads 6 bytes per instrument to ARAM `$1254`:

| Byte | Name | Description |
|------|------|-------------|
| 0 | `SRCN` | Source number — index into the BRR sample directory |
| 1 | `ADSR1` | DSP ADSR1 register value |
| 2 | `ADSR2` | DSP ADSR2 register value |
| 3 | `GAIN` | DSP GAIN register value (used when ADSR bit 7 = 0) |
| 4 | `PitchHi` | Instrument pitch multiplier high byte |
| 5 | `PitchLo` | Instrument pitch multiplier low byte |

### Instrument pitch

The 16-bit **instrument pitch** (`PitchHi << 8 | PitchLo`) is a multiplication factor applied to the frequency table lookup during [pitch calculation](#pitch-calculation-algorithm). It determines the base tuning of each instrument. Typical values range from `$0100` (very low pitch) to `$3FFF` (maximum).

The instrument pitch is NOT a semitone offset — it is a linear multiplication factor. Doubling the value raises the pitch by one octave.

### Example (Horn 1, sample $1F)

```
SRCN=0x12  ADSR1=0xFF  ADSR2=0xA8  GAIN=0xB8  PitchHi=0x04  PitchLo=0x70
→ instrumentPitch = $0470 = 1136
```

### ADSR1 / ADSR2 bit fields

See [ADSR Envelope System](#adsr-envelope-system) for full decoding.

---

## Duration / Velocity Table

A 24-byte table uploaded to ARAM `$1300`, divided into two sub-tables:

### Bytes 0–7: Duration (gate fraction) table

| Index | Hex | Approx % | Musical feel |
|-------|-----|----------|--------------|
| 0 | `$32` | 19.6% | Staccatissimo |
| 1 | `$65` | 39.5% | Staccato |
| 2 | `$7F` | 49.6% | Semi-staccato |
| 3 | `$98` | 59.4% | Normal |
| 4 | `$B2` | 69.5% | Slightly detached |
| 5 | `$CB` | 79.3% | Legato-ish |
| 6 | `$E5` | 89.5% | Nearly legato |
| 7 | `$FC` | 98.4% | Fully legato |

**Gate time formula:**
```
gateTime = max(1, (duration × gateFraction) >> 8)
```

Where `duration` is the total event time in ticks and `gateFraction` is the table value.

### Bytes 8–23: Velocity table

16 velocity values indexed by the velocity index from the DV byte:

| Index | Typical A | Typical B | Description |
|-------|-----------|-----------|-------------|
| 0 | `$0A` | `$19` | ppp (pianississimo) |
| 1 | `$19` | `$32` | pp |
| 2 | `$28` | `$4C` | p |
| 3 | `$3C` | `$65` | mp |
| 4 | `$50` | `$72` | mf (mezzo-forte) |
| 5 | `$64` | `$7F` | f |
| 6 | `$7D` | `$8C` | |
| 7 | `$96` | `$98` | |
| 8 | `$AA` | `$A5` | |
| 9 | `$B9` | `$B2` | |
| 10 | `$C8` | `$BF` | |
| 11 | `$D4` | `$CB` | |
| 12 | `$E1` | `$D8` | ff |
| 13 | `$EB` | `$E5` | |
| 14 | `$F5` | `$F2` | fff |
| 15 | `$FF` | `$FC` | ffff (maximum) |

Each song provides its own 24-byte table (Table A or B variant). Values are raw 0–255 amplitude levels. The SPC engine applies these linearly to the DSP voice volume.

---

## Sequence Data Byte Encoding

Each channel's sequence data is a byte stream processed sequentially:

| Byte Range | Type | Description |
|------------|------|-------------|
| `$00` | End | End of channel data (stop this voice) |
| `$01`–`$7F` | Duration | Set current duration in ticks (optional velocity param follows) |
| `$80`–`$C7` | Note | Play note (72 notes = 6 octaves × 12 semitones) |
| `$C8` | Tie | Extend previous note by current duration |
| `$C9` | Rest | Silent rest for current duration |
| `$CA`–`$DF` | Percussion | Percussion hit (22 drum sounds) |
| `$E0`–`$FF` | Opcode | Engine commands (see instruction set below) |

### Duration / Velocity (DV) byte (`$01`–`$7F`)

When a byte in the range `$01`–`$7F` is encountered, it directly sets the **current duration** in sequence ticks. Optionally, the NEXT byte can be a secondary DV parameter (only consumed if the next byte is also in `$01`–`$7F` and is not a recognized note/command):

```
Secondary DV byte layout:
  Bits 6-4: Duration class (0–7) → indexes gate fraction table
  Bits 3-0: Velocity index (0–15) → indexes velocity table (at offset +8)
```

The engine extracts these via the `XCN A` instruction (exchange nibbles):

```spc700
XCN A          ; swap nibbles: $63 → $36
AND A, #$07    ; extract duration class from bits 2-0 of swapped value
               ; (= bits 6-4 of original)
```

### Velocity persistence

Once set by a DV parameter byte, the velocity remains **sticky** — it is NOT reset by rests, notes, or percussion hits. It persists until a new DV parameter byte explicitly changes it.

### Note bytes (`$80`–`$C7`)

Each note byte encodes a pitch in a 6-octave range:

```
noteIndex = byte − $80     (range 0–71)
octave    = noteIndex / 12  (range 0–5)
semitone  = noteIndex % 12  (0=C, 1=C#, 2=D, ... 11=B)
```

| Byte | Note | Octave |
|------|------|--------|
| `$80` | C0 | 0 |
| `$8C` | C1 | 1 |
| `$98` | C2 | 2 |
| `$A4` | C3 | 3 |
| `$B0` | C4 | 4 |
| `$BC` | C5 | 5 |
| `$C7` | B5 | 5 (max) |

**MIDI mapping:** `midiNote = (byte − $80) + 24 + channelTranspose`

The offset of +24 maps SPC octave 0 to MIDI octave 2 (C2 = MIDI 24).

### Tie (`$C8`)

Extends the most recent note's duration by the current duration value. Both the total duration and gate time are extended. The voice continues playing without restarting. Multiple ties can chain together for very long notes.

### Rest (`$C9`)

Silence for the current duration. Keys off the voice. Does NOT reset velocity.

---

## N-SPC Instruction Set

All opcodes in the range `$E0`–`$FF`. Parameter bytes follow the opcode byte.

### Channel Control

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$E0` | 2 | **Set Instrument** | `slot` | Switch voice to instrument at slot number. Slot is a per-song index starting at `$0E` (added to `SPC_SLOT_BASE`). |
| `$E1` | 2 | **Pan** | `value` | Set stereo panning. Value 0–20: 0=left, 10=center, 20=right. Lower 5 bits used. |
| `$E2` | 3 | **Pan Fade** | `speed`, `target` | Gradually slide panning to `target` over `speed` ticks. |
| `$E3` | 4 | **Vibrato** | `delay`, `rate`, `depth` | Enable pitch vibrato after `delay` ticks, with given `rate` and `depth`. |
| `$E4` | 1 | **Vibrato Off** | — | Disable vibrato on this channel. |
| `$ED` | 2 | **Channel Volume** | `volume` | Set channel volume (0–255). Applied linearly to DSP voice volume. |
| `$F4` | 2 | **Tuning** | `value` | Fine-pitch adjustment. Interpolates between adjacent frequency table entries: 0=exact semitone, 255=almost next semitone up. |

### Global Control

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$E5` | 2 | **Main Volume** | `volume` | Set DSP master volume (MVOL). Affects all channels. |
| `$E6` | 3 | **Volume Fade** | `speed`, `target` | Fade main volume to `target` over `speed` ticks. |
| `$E7` | 2 | **Tempo** | `value` | Set tempo byte. Higher = faster. See [Tempo and Timing](#tempo-and-timing). |
| `$E8` | 3 | **Tempo Fade** | `speed`, `target` | Gradually change tempo to `target` over `speed` ticks. |

### Transpose

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$E9` | 2 | **Global Transpose** | `semitones` | Signed byte (−128 to +127). Shifts all subsequent notes on this channel by N semitones. Applied before frequency table lookup. |
| `$EA` | 2 | **Per-Voice Transpose** | `semitones` | Signed byte. Same effect as `$E9` but semantically per-voice (the engine treats them identically — both update the channel's transpose state). |

> **Important:** Transpose state persists from intro to loop. A `$EA +12` in the intro will affect all notes in the loop unless reset by another `$EA` command.

### ADSR / Envelope

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$EC` | 2 | **ADSR Attack Override** | `rate` | Override the attack rate for this channel's current instrument. |
| `$F1` | 3 | **ADSR Override** | `adsr1`, `adsr2` | Override both ADSR registers for this channel. |

### Echo / Reverb

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$F5` | 4 | **Echo On** | `enabled`, `volume`, `feedback` | Enable echo effect. `volume` controls echo level, `feedback` controls decay. |
| `$F6` | 2 | **Echo Off/Param** | `value` | Disable echo or adjust echo parameter. |
| `$F7` | 4 | **Echo FIR Filter** | `c0`, `c1`, `c2` | Set echo FIR filter coefficients (affects echo timbre). |

### Pitch Effects

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$F2` | 3 | **Pitch Envelope** | `delay`, `speed` | Pitch slide/bend effect (portamento-like). |
| `$F3` | 1 | **Pitch Envelope Off** | — | Disable pitch envelope effect. |
| `$F0` | 2 | **Amplitude Modulation** | `param` | Enable tremolo / amplitude modulation. |

### Flow Control and Misc

| Opcode | Size | Name | Parameters | Description |
|--------|------|------|------------|-------------|
| `$EE` | 3 | **Unknown (3 bytes)** | `p1`, `p2` | Purpose unidentified. Consumed and ignored. |
| `$EF` | 2 | **Subcommand** | `param` | Miscellaneous sub-command dispatch. |
| `$EB` | 2 | **Reserved** | `param` | Unused/reserved. Consumed and ignored. |
| `$F8` | 3 | **Subroutine Call** | `addr_lo`, `addr_hi` | Call a subroutine pattern at the given ARAM address. |
| `$F9` | 3 | **Subroutine Return / Loop** | `count`, `addr` | Loop or return from subroutine. |
| `$FA` | 2 | **Conditional** | `param` | Conditional execution flag. |
| `$FB` | 5 | **Repeat Block** | `count`, `addr_lo`, `addr_hi`, `end` | Repeat a section of sequence data. |
| `$FC` | 2 | **Unknown** | `param` | Purpose unidentified. |
| `$FD` | 3 | **Unknown** | `p1`, `p2` | Purpose unidentified. |
| `$FE` | 2 | **Unknown** | `param` | Purpose unidentified. |
| `$FF` | 2 | **Unknown** | `param` | Purpose unidentified. |

---

## Pitch Calculation Algorithm

The DSP pitch register determines the playback speed of a BRR sample. The SPC engine computes it from the note byte and instrument pitch through a multi-step process.

### Source: ARAM `$0592`–`$05F0`

```
Input:
  noteIndex = (pitchByte − $80) + channelTranspose   (0–71 typically)
  instrumentPitch = (defByte[4] << 8) | defByte[5]   (14-bit, $0100–$3FFF)
  tuning = current tuning value from $F4 command      (0–255)

Step 1 — Octave/Semitone split:
  octave   = noteIndex / 12    (integer division, 0–5)
  semitone = noteIndex % 12    (0–11)

Step 2 — Frequency table lookup with tuning interpolation:
  baseFreq = freqTable[semitone]        ; 14-bit value from table at ARAM $0E59
  nextFreq = freqTable[semitone + 1]    ; next semitone (table has 13 entries for wrap)
  freq = baseFreq + ((nextFreq − baseFreq) × tuning) >> 8

Step 3 — Octave shift with doubling:
  freq_shifted = (freq × 2) >> (6 − octave)
  ; Implementation: ASL+ROL (doubles), then LSR+ROR loop for (6−octave) iterations

Step 4 — Instrument pitch multiplication:
  DSP_pitch = (freq_shifted × instrumentPitch) >> 8    ; middle 16 bits of 32-bit result

Output:
  DSP pitch register value (14-bit, written to DSP voice registers $X2/$X3)
  Playback rate = BRR_SAMPLE_RATE × DSP_pitch / 4096
```

### Frequency Table (ARAM `$0E59`)

13 entries covering one octave (C through C of next octave):

| Index | Note | Value (hex) | Value (dec) |
|-------|------|-------------|-------------|
| 0 | C | `$085F` | 2143 |
| 1 | C# | `$08DE` | 2270 |
| 2 | D | `$0965` | 2405 |
| 3 | D# | `$09F4` | 2548 |
| 4 | E | `$0A8C` | 2700 |
| 5 | F | `$0B2C` | 2860 |
| 6 | F# | `$0BD6` | 3030 |
| 7 | G | `$0C8B` | 3211 |
| 8 | G# | `$0D4A` | 3402 |
| 9 | A | `$0E14` | 3604 |
| 10 | A# | `$0EEA` | 3818 |
| 11 | B | `$0FCD` | 4045 |
| 12 | C+ | `$10BE` | 4286 |

Entry 12 (C+) = 2 × entry 0 (C), confirming equal temperament.

### Worked example: Horn 1 playing D4 (pitch byte `$A6`)

```
noteIndex = $A6 − $80 + 12 (transpose) = 38 + 12 = 50
octave = 50 / 12 = 4
semitone = 50 % 12 = 2 (D)

freqTable[2] = 2405 (D)
freq_shifted = (2405 × 2) >> (6 − 4) = 4810 >> 2 = 1202
DSP_pitch = (1202 × 1136) >> 8 = 1365472 >> 8 = 5333
Playback = 32000 × 5333 / 4096 = 41,664 Hz
```

### SF2 Root Key Derivation

For the SoundFont, each instrument needs a `rootKey` — the MIDI note at which the sample plays at its native rate (32 kHz). Computed from DSP pitch at C4:

```
DSP_pitch_at_C4 = ((freqTable[0] >> 2) × instrumentPitch) >> 8
rootKey = round(60 − 12 × log₂(DSP_pitch_at_C4 / 4096))
```

Example: Horn 1 (`instPitch = 1136`):
```
DSP_pitch_at_C4 = ((2143 >> 2) × 1136) >> 8 = (535 × 1136) >> 8 = 2374
rootKey = round(60 − 12 × log₂(2374 / 4096)) = round(60 + 9.4) = 69 (A4)
```

---

## ADSR Envelope System

The SNES DSP provides hardware ADSR envelopes. Each instrument definition includes ADSR1 and ADSR2 bytes.

### ADSR1 (definition byte 1)

```
Bit 7:    ADSR enable (1 = use ADSR, 0 = use GAIN)
Bits 6-4: Decay rate  (0–7)  → internal rate = field × 2 + 16
Bits 3-0: Attack rate (0–15) → internal rate = field × 2 + 1
```

### ADSR2 (definition byte 2)

```
Bits 7-5: Sustain level (0–7) → sustain = (level + 1) / 8 of peak
Bits 4-0: Sustain rate  (0–31) → internal rate directly
```

### Envelope phases

1. **Attack** (linear): Envelope rises from 0 to peak (2047). Attack is LINEAR — each step adds a fixed increment.
   - Rate 15: instant (~0.5 ms)
   - Rate 0: ~4.1 seconds

2. **Decay** (exponential): Envelope falls from peak toward sustain level.
   - Rate field 0–7 → internal rates 16–30
   - Exponential decay: each step multiplies by (1 − 1/256)

3. **Sustain** (exponential fade): After decay reaches the sustain level, the envelope continues to decrease at the sustain rate.
   - Rate 0: infinite sustain (no fade)
   - Rate 31: rapid fade to silence

4. **Release** (key off): Fixed ~8 ms release time. The SNES DSP always releases at internal rate 31, which produces a very short fade to silence.

### Sustain level mapping

| Field (bits 7-5) | Level | Fraction of peak |
|-------------------|-------|-----------------|
| 0 | 1/8 | 12.5% |
| 1 | 2/8 | 25.0% |
| 2 | 3/8 | 37.5% |
| 3 | 4/8 | 50.0% |
| 4 | 5/8 | 62.5% |
| 5 | 6/8 | 75.0% |
| 6 | 7/8 | 87.5% |
| 7 | 8/8 | 100.0% |

### Internal rate → timing table

| Rate | Approx ms (exponential) | Attack ms (linear) |
|------|------------------------|-------------------|
| 0 | ∞ | — |
| 1 | 38,000 | 4,100 |
| 3 | 24,000 | 2,600 |
| 5 | 14,000 | 1,500 |
| 7 | 9,400 | 1,000 |
| 9 | 5,900 | 384 |
| 11 | 3,500 | 256 |
| 15 | 1,500 | 64 |
| 19 | 590 | 8 |
| 23 | 220 | 4 |
| 27 | 92 | 2 |
| 31 | 18 | 0.5 |

---

## Tempo and Timing

### Timer configuration

- **Timer 1 divisor:** `$10` (16)
- **Timer 1 frequency:** 8000 / 16 = **500 Hz** (2 ms per tick)
- **Sequence tick generation:** `accumulator += tempoByte; if overflow → tick`

### Tempo byte → BPM conversion

```
ticks_per_second = 500 × tempoByte / 256
BPM = (ticks_per_second / NSPC_TICKS_PER_QUARTER) × 60
    = 500 × tempoByte × 60 / (256 × 24)
    = tempoByte × 4.883
```

| Tempo byte | BPM | Description |
|-----------|-----|-------------|
| `$10` (16) | ~78 | Default (engine init value) |
| `$13` (19) | ~93 | Typical slow ballad |
| `$1B` (27) | ~132 | Moderate |
| `$24` (36) | ~176 | Fast |
| `$30` (48) | ~234 | Very fast |

### Microseconds per quarter note

```
µs/quarter = 24 × 256 × 1,000,000 / (500 × tempoByte) = 12,288,000 / tempoByte
```

### Standard note durations

| N-SPC ticks | Musical value | At 120 BPM |
|-------------|---------------|------------|
| 96 | Whole note | 2.0 s |
| 48 | Half note | 1.0 s |
| 24 | Quarter note | 0.5 s |
| 12 | Eighth note | 0.25 s |
| 6 | Sixteenth note | 0.125 s |
| 3 | Thirty-second note | 0.0625 s |

---

## Echo / Reverb

The SNES DSP has a built-in echo effect using a delay buffer in ARAM.

### Echo command (`$F5`, 4 bytes)

```
$F5 [enabled] [volume] [feedback]
```

- `enabled`: Non-zero to enable echo on this channel
- `volume`: Echo volume (0–255). Written to DSP echo volume registers (EVOL).
- `feedback`: Echo feedback amount (0–255). Higher values = longer reverb tail. Written to DSP EFB register.

### Echo FIR filter (`$F7`, 4 bytes)

```
$F7 [c0] [c1] [c2]
```

Sets the first 3 FIR filter coefficients for the echo's 8-tap FIR filter. The filter shapes the timbre of the echo — different coefficients produce different reverb characters (warm, bright, metallic, etc.).

### Echo off (`$F6`, 2 bytes)

```
$F6 [param]
```

Disables echo or adjusts echo parameters.

---

## Sample Directory and BRR Playback

### BRR format

BRR (Bit Rate Reduction) is the SNES DSP's native audio compression:
- **Block size:** 9 bytes (1 header + 8 data bytes)
- **Samples per block:** 16 PCM samples
- **Compression ratio:** ~3.6:1 vs 16-bit PCM

Header byte flags:
```
Bit 7-4: Shift amount (0–12)
Bit 3-2: Filter mode (0–3)
Bit 1:   Loop flag (1 = this is the loop point)
Bit 0:   End flag (1 = last block)
```

### Sample directory

The DSP locates samples through the sample directory (pointed to by DIR register). Each entry is 4 bytes:

```
[u16 startAddress] [u16 loopAddress]
```

IoG uses ARAM `$1038` (standard, 6 entries) or `$1000` (extended, 14 entries) for the directory.

### IoG SFX files

`.sfx` files are pure BRR block data with **no header** (`SFX_FILE_HEADER_BYTES = 0`). Every file is an exact multiple of 9 bytes. The first block is typically a warmup block.

---

## Per-Song Instrument Slot Mapping

### Slot system

Each song defines up to 6 instruments (standard) or 14 (extended). The `$E0` (Set Instrument) command uses a slot number starting at `$0E` (`SPC_SLOT_BASE`).

```
$E0 $00 → slot $0E (first instrument)
$E0 $01 → slot $0F (second instrument)
$E0 $02 → slot $10 (third instrument)
...
$E0 $05 → slot $13 (sixth instrument)
```

### Slot → Sample ID mapping

The BGM file's instrument ID trailer maps slots to global sample IDs:

```
instrumentIds = [$20, $1B, $1C, $1D, $1F, $21]
                  ↓     ↓     ↓     ↓     ↓     ↓
               Slot 0  Slot 1  Slot 2  ...
               Strings3 Pizz   Strings2 Tom-tom Horn1  Trumpet1
```

### ARAM slot table (`$0FE0`)

The 6-byte block at ARAM `$0FE0` contains the SRCN (source number) for each slot, used by the DSP to locate the BRR data in the sample directory. Values are typically `$0E`, `$0F`, `$10`, `$11`, `$12`, `$13`.

---

## Known Quirks and Discoveries

### 1. Per-voice transpose in intro patterns

Several songs set `$EA` (per-voice transpose) in the intro pattern, which has zero notes. The transpose must persist into the loop pattern. Discovered songs:

| Song | Channel | Transpose | Purpose |
|------|---------|-----------|---------|
| `secret_of_nazca` | Ch4 | +12 | Horn 1 plays one octave higher |
| `beautiful_world` | Ch0 | −12 | Bass plays one octave lower |
| `golden_road` | Ch5 | −12 | Koto plays one octave lower |
| `unexplored_temple` | Ch5 | −3 | Channel shifted down 3 semitones |

### 2. Velocity table is at offset +8 in the 24-byte table

The SPC engine's velocity lookup uses `$1308+Y` (not `$1300+Y`). The first 8 bytes are the duration/gate fraction table. Misindexing by using `$1300` produces completely wrong velocities.

### 3. Gate time via XCN instruction

The DV (duration/velocity) byte's upper bits encode the gate time class, not just velocity. The SPC engine uses the `XCN A` (exchange nibbles) instruction to extract both fields from a single byte. This was a key discovery — without gate time, all notes sounded fully legato.

### 4. SNES DSP release time is fixed ~8 ms

The SNES DSP always releases voices at internal rate 31 (~18 ms to silence from the current level). This is much faster than typical MIDI/SF2 release times. Using longer release times in the SF2 causes notes to overlap and blur together.

### 5. Frequency table doubling step

The SPC engine's pitch calculation includes an `ASL+ROL` (arithmetic shift left + rotate left through carry) doubling step BEFORE the right-shift loop. This means the formula is `(freq × 2) >> (6 − octave)`, NOT `freq >> (6 − octave)`. Missing this doubling produces DSP pitch values that are half the correct value, resulting in all instruments sounding one octave too low.

### 6. Linear vs exponential in ADSR

Attack is LINEAR (constant step size of +32 per interval), while decay and sustain are EXPONENTIAL (multiplicative reduction). Using the exponential timing table for attack calculations produces attack times that are 10–75× too slow.

### 7. Two velocity table variants

IoG songs use one of two velocity table variants (A or B). Each song uploads its own 24-byte table. The tables have identical duration fractions (bytes 0–7) but different velocity curves — Table B has a more compressed dynamic range.

---

## See Also

- [SPC Transfer Protocol](../code/bank02/spc-transfer.md) — How the 65C816 uploads data to the SPC700
- [COP Audio Family](../../docs/cop/families/audio.md) — COP handlers for music/SFX commands
- [SNES DSP Reference](https://wiki.superfamicom.org/spc700-reference) — Hardware register documentation
- [N-SPC Format (SNESmusic.org)](https://snesmusic.org/files/spc700.html) — General N-SPC format reference
