# Illusion of Gaia — MIDI + SoundFont Conversion Pipeline

_Documentation for the BGM → MIDI + SF2 export system in `@gaialabs/core`._

---

## Table of Contents

1. [Pipeline Overview](#pipeline-overview)
2. [BGM Parsing](#bgm-parsing)
3. [N-SPC Disassembly](#n-spc-disassembly)
4. [SoundFont (SF2) Generation](#soundfont-sf2-generation)
5. [MIDI Generation](#midi-generation)
6. [FluidSynth Compensation](#fluidsynth-compensation)
7. [File Inventory](#file-inventory)

---

## Pipeline Overview

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────┐
│ .bgm file    │────→│ parseBgm()   │────→│ decodeBgm()     │
│ (raw binary) │     │ bgm-parser.ts│     │ part-decoder.ts  │
└──────────────┘     └──────────────┘     └────────┬────────┘
                                                    │
                                           DecodedBgm (typed)
                                                    │
                     ┌──────────────────────────────┼──────────────────────┐
                     │                              │                      │
              ┌──────▼──────┐              ┌────────▼────────┐    ┌───────▼───────┐
              │ disassemble │              │ buildMidiTracks │    │ SF2 writer    │
              │ Song()      │              │ mapper.ts       │    │ writer.ts     │
              │ nspc-disasm │              └────────┬────────┘    └───────┬───────┘
              └─────────────┘                       │                     │
                                            MidiTrackData[]       iog-instruments.sf2
                                                    │
                                            ┌───────▼───────┐
                                            │ writeMidi()   │
                                            │ writer.ts     │
                                            └───────┬───────┘
                                                    │
                                              .mid files
```

### Playback chain

```
.mid file + iog-instruments.sf2 → FluidSynth (in VLC or standalone) → audio output
```

---

## BGM Parsing

**Source:** `src/audio/parse/bgm-parser.ts`

### `parseBgm(data: Uint8Array): BgmFile`

Parses the raw `.bgm` binary into structured blocks:

1. Reads blocks sequentially: each has a 4-byte header (`u16 size`, `u16 target`) followed by `size` bytes of payload
2. Stops at the terminator block (`size = 0`)
3. Reads the instrument trailer (count + IDs) after the terminator

### `decodeBgm(bgm: BgmFile, name: string): DecodedBgm`

**Source:** `src/audio/parse/part-decoder.ts`

Interprets the parsed blocks by their ARAM target addresses:

1. Identifies block types by target address (`$1254` → instruments, `$1300` → velocity table, etc.)
2. Parses instrument definitions (6 bytes each)
3. Determines song type: `minimal`, `standard`, or `extended` based on the song basename
4. Calls `disassembleSong()` to decode the sequence data into structured events
5. Returns the complete `DecodedBgm` with all metadata

---

## N-SPC Disassembly

**Source:** `src/audio/parse/nspc-disassembler.ts`

### `disassembleSong(sequenceData, baseAddr, velocityTable, headerType): NspcSong`

1. Reads the phrase list header pointer (first `u16` in sequence data)
2. Walks the phrase list to find pattern addresses and the loop marker (`$00FF`)
3. Identifies intro pattern (first) and loop pattern (at loop-jump target)
4. For each of 8 channels:
   - Reads channel pointer from intro pattern
   - Disassembles intro track → gets `introEvents` + `finalState`
   - **Passes `finalState` as `initialState` to loop disassembly** (critical for transpose persistence)
   - Disassembles loop track → gets `loopEvents`

### `disassembleTrack(data, baseAddr, trackAddr, velocityTable, initialState?): { events, finalState }`

Processes a byte stream into an array of `NspcEvent` objects:

#### State machine variables

| Variable | Initial | Description |
|----------|---------|-------------|
| `currentDuration` | 48 (or from initialState) | Ticks for next note/rest/tie |
| `currentGateFraction` | `$FC` (or from initialState) | Gate fraction (0–255) |
| `currentVelocity` | `null` (or from initialState) | MIDI velocity (sticky) |
| `channelVolume` | 240 (or from initialState) | Per-channel volume |
| `channelTranspose` | 0 (or from initialState) | Semitone offset for notes |

#### Event types produced

| Event kind | Fields | Triggered by |
|-----------|--------|-------------|
| `note` | `pitch`, `midiNote`, `duration`, `gateTime`, `velocity` | `$80`–`$C7` |
| `rest` | `duration` | `$C9` |
| `percussion` | `note`, `duration`, `gateTime`, `velocity` | `$CA`–`$DF` |
| `setInstrument` | `slot` | `$E0` |
| `tempo` | `value` | `$E7` |
| `mainVolume` | `value` | `$E5` |
| `volume` | `value` | `$ED` |
| `pan` | `value` | `$E1` |
| `tuning` | `value` | `$F4` |
| `vibrato` | `delay`, `rate`, `depth` | `$E3` |
| `vibratoOff` | — | `$E4` |
| `echo` | `enabled`, `volume`, `feedback` | `$F5` |
| `end` | — | `$00` |

---

## SoundFont (SF2) Generation

**Source:** `src/audio/sf2/writer.ts`

### Sample processing

For each of 60 instruments in `SAMPLE_TABLE`:

1. **Load BRR data** from `.sfx` file (pure BRR blocks, no header)
2. **Decode BRR → PCM** at native 32 kHz (Int16Array)
3. **Compute root key** from instrument pitch:
   ```
   dspPitchAtC4 = ((SPC_FREQ_TABLE_C >> 2) × instrumentPitch) >> 8
   rootKey = round(60 − 12 × log₂(dspPitchAtC4 / 4096))
   ```
4. **Compute fine-tune** correction in cents for the rounding error
5. **Extract ADSR** parameters from definition bytes

### SF2 structure

```
SF2 File
├── INFO chunk (name, version)
├── sdta chunk
│   └── smpl sub-chunk (all PCM samples concatenated, 46 zero-sample padding between each)
└── pdta chunk
    ├── phdr (preset headers — one per instrument)
    ├── pbag (preset bags)
    ├── pmod (preset modulators — empty)
    ├── pgen (preset generators — bank/preset/instrument links)
    ├── inst (instrument headers)
    ├── ibag (instrument bags)
    ├── imod (instrument modulators — empty)
    ├── igen (instrument generators — rootKey, loop, ADSR, fineTune)
    ├── shdr (sample headers — name, rates, loop points)
    └── (terminal records for each sub-chunk)
```

### Generator assignments per instrument

| Generator | ID | Value | Purpose |
|-----------|-----|-------|---------|
| `sampleModes` | 54 | 0 or 1 | 0=no loop, 1=loop continuously |
| `overridingRootKey` | 58 | rootKey | MIDI note for native playback rate |
| `fineTune` | 52 | cents | Fine-pitch correction (−99 to +99) |
| `attackVolEnv` | 34 | timecents | ADSR attack time |
| `decayVolEnv` | 36 | timecents | ADSR decay time |
| `sustainVolEnv` | 37 | centibels | ADSR sustain attenuation |
| `releaseVolEnv` | 38 | timecents | Fixed ~10 ms (SNES-accurate) |

### ADSR conversion

```
attackRate (0–15) → internal rate = field × 2 + 1
  → attackMs via linear model: 64 steps × STEP_INTERVAL[rate] / 32000
  → timecents = 1200 × log₂(ms / 1000)

decayRate (0–7) → internal rate = field × 2 + 16
  → decayMs from RATE_TO_MS table
  → timecents = 1200 × log₂(ms / 1000)

sustainLevel (0–7) → fraction = (level + 1) / 8
  → centibels = -200 × log₁₀(fraction)

sustainRate (0–31) → additional fade during sustain
  If sustainRate > 0: merge decay+sustain fade into single SF2 decay
  If sustainRate = 0: hold at sustain level indefinitely

releaseVolEnv → always -6644 timecents (≈10 ms, matching SNES ~8 ms key-off)
```

---

## MIDI Generation

**Source:** `src/audio/midi/mapper.ts`, `src/audio/midi/tempo.ts`, `src/audio/midi/writer.ts`

### `buildMidiTracks(decoded: DecodedBgm): MidiTrackData[]`

Converts disassembled N-SPC events to MIDI track data.

#### Processing flow per channel

1. Determine default instrument from `sampleIds[]`
2. Process intro events (if any), collecting notes/controls/programs/tempos/pitchBends
3. Process loop events (2 repetitions for a complete musical experience)
4. Apply **LEAD_IN_TICKS** (960 MIDI ticks ≈ 1.5 s silence) offset to all events
5. Collect tempo events globally from ALL channels (tempo is global in N-SPC)
6. Deduplicate global tempos (last-at-same-tick wins)

#### Event mapping

| N-SPC Event | MIDI Output |
|-------------|------------|
| `note` | Note-on at tick, note-off at tick + `gateTime` (converted to MIDI ticks) |
| `rest` | Advances tick counter only |
| `setInstrument` | Program Change (program = sampleId) |
| `tempo` | MIDI tempo meta-event (µs/quarter from tempo byte formula) |
| `volume` | CC7 (Channel Volume) with [logarithmic compensation](#fluidsynth-compensation) |
| `mainVolume` | CC7 (same handling as volume) |
| `pan` | CC10 (Pan, scaled from 0–20 to 0–127) |
| `tuning` | Pitch Bend (centered at 8192, ±2 semitone range) |
| `echo` | CC91 (Reverb Send Level) |

#### MIDI file structure

```
Format 1 (multi-track)
├── Track 0: Conductor (tempo events, time signature)
├── Track 1: Channel 1 (notes, controls, programs, pitch bends)
├── Track 2: Channel 2
│   ...
└── Track N: Channel N (up to 8 channels)
```

#### Pitch bend configuration

RPN 0,0 messages are emitted at the start of each track that uses pitch bends:
```
CC 101 = 0    (RPN MSB)
CC 100 = 0    (RPN LSB)
CC 6 = 2      (Data Entry MSB: ±2 semitones)
CC 38 = 0     (Data Entry LSB: 0 cents)
```

This sets the pitch bend sensitivity to ±2 semitones, matching the IoG N-SPC tuning range.

---

## FluidSynth Compensation

The SNES DSP uses **linear** amplitude scaling, while FluidSynth (and most MIDI synthesizers) use **non-linear** curves. Two compensations are applied:

### 1. Velocity: Square-root mapping

**Problem:** FluidSynth applies a square law to velocity: `amplitude ∝ (vel/127)²`

**SNES behavior:** `amplitude ∝ raw/255` (linear)

**Fix:** Apply square root before mapping:
```
midiVelocity = round(127 × √(rawVelocity / 255))
```

This ensures `amplitude = (√(raw/255))² = raw/255` — matching the SNES.

| Raw SPC velocity | Linear mapping | Square-root mapping | FluidSynth amplitude |
|-----------------|----------------|--------------------|--------------------|
| 50 | 25 | 56 | 19.4% (correct: 19.6%) |
| 125 | 62 | 89 | 49.1% (correct: 49.0%) |
| 200 | 100 | 112 | 77.8% (correct: 78.4%) |

### 2. Channel Volume (CC7): Logarithmic inversion

**Problem:** FluidSynth's CC7 uses a logarithmic curve: `attenuation_cB = 960 × (1 − CC7/127)`

**SNES behavior:** Volume is applied linearly: `amplitude = vol/240`

**Fix:** Invert FluidSynth's logarithmic curve:
```
linearAmp = vol / 240
CC7 = round(127 × (1 + (200/960) × log₁₀(linearAmp)))
```

| SNES volume | Linear CC7 | Compensated CC7 | FluidSynth amplitude |
|------------|-----------|-----------------|---------------------|
| 25 | 13 | 101 | 10.4% (correct: 10.4%) |
| 120 | 64 | 118 | 50.0% (correct: 50.0%) |
| 240 | 127 | 127 | 100% (correct: 100%) |

Without this compensation, quiet instruments (like harp arpeggios at SNES vol=25) were nearly inaudible in FluidSynth — CC7=13 produces only 0.01% amplitude with the logarithmic curve.

---

## File Inventory

### Source files (`gaia-core/src/audio/`)

| File | Purpose |
|------|---------|
| `constants.ts` | Sample table, frequency table, ARAM addresses, conversion functions |
| `types.ts` | TypeScript type definitions for all audio structures |
| `parse/bgm-parser.ts` | BGM binary → `BgmFile` blocks |
| `parse/part-decoder.ts` | `BgmFile` → `DecodedBgm` (interprets blocks) |
| `parse/nspc-disassembler.ts` | Sequence data → `NspcEvent[]` (byte stream decoder) |
| `parse/sfx-parser.ts` | SFX file loading and instrument slot mapping |
| `brr/decode.ts` | BRR → PCM decoder, WAV writer |
| `sf2/writer.ts` | SF2 SoundFont builder (samples + instruments + ADSR) |
| `midi/mapper.ts` | `DecodedBgm` → `MidiTrackData[]` (event conversion) |
| `midi/tempo.ts` | Tempo byte ↔ microseconds conversion |
| `midi/writer.ts` | `MidiTrackData[]` → `.mid` file (Standard MIDI File writer) |

### Generated output (`gaia-iog-baserom/temp/audio/`)

| Path | Contents |
|------|----------|
| `temp/audio/iog-instruments.sf2` | SoundFont with all 60 IoG instruments |
| `temp/audio/samples/*.wav` | Raw 32 kHz BRR-decoded WAV files (1:1 round-trip capable) |
| `temp/audio/midi/*.mid` | MIDI files for all 30 BGM tracks |

### Export script

`gaia-iog-baserom/export-audio.mjs` — Automated pipeline that:
1. Builds the SF2 from `extracted/sfx/*.sfx`
2. Exports WAV samples
3. Converts all `extracted/music/*.bgm` to MIDI
