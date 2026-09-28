# IoG Audio Pipeline — Gap Analysis & Sanity Check

_Comprehensive audit of what is known, documented, implemented, partially implemented, and still unknown in the IoG audio conversion pipeline._

**Last updated:** September 2026

---

## Coverage Summary

| Category | Status | Notes |
|----------|--------|-------|
| BGM file parsing | ✅ Complete | All 30 BGM files parse correctly |
| Song structure (phrase lists) | ✅ Complete | Multi-pattern phrase lists now handled |
| N-SPC note/rest/tie/percussion | ✅ Complete | All note bytes, ties, rests, percussion |
| Duration/velocity table | ✅ Complete | Both sub-tables (gate fraction + velocity) |
| Gate time / articulation | ✅ Complete | XCN-derived duration class → gate fraction |
| Instrument switching ($E0) | ✅ Complete | Slot → sampleId mapping verified |
| Pitch calculation | ✅ Complete | Freq table, octave shift, instPitch multiply |
| ADSR envelopes (SF2) | ✅ Complete | Attack (linear), decay, sustain, release |
| SF2 sample rootKey/fineTune | ✅ Complete | dspPitchAtC4 formula verified against SPC disasm |
| Tempo ($E7) | ✅ Complete | Timer1 ÷16, accumulator model, all channels |
| Channel volume ($ED) | ✅ Complete | FluidSynth log-curve compensation |
| Main volume ($E5) | ✅ Complete | Same log-curve compensation |
| Pan ($E1) | ✅ Complete | 0–20 → MIDI CC10 0–127 |
| Tuning ($F4) | ✅ Complete | Freq interpolation → MIDI pitch bend ±2 semi |
| Per-voice transpose ($EA) | ✅ Complete | State persistence across intro→loop |
| Global transpose ($E9) | ✅ Complete | Same as $EA in implementation |
| Velocity mapping | ✅ Complete | √ compensation for FluidSynth square law |
| Echo on ($F5) | ⚠️ Partial | Emits CC91 only; no delay/feedback modeling |
| Vibrato ($E3) | ⚠️ Partial | Emits CC1 depth only; no rate/delay modeling |
| Vibrato off ($E4) | ✅ Complete | CC1 = 0 |
| Pattern-boundary sync | ✅ Complete | Pad shorter channels with rests |
| MIDI lead-in silence | ✅ Complete | 960 ticks for synth init |
| Tempo from all channels | ✅ Complete | Global collection + dedup |
| SPC700 disassembly | ✅ Available | Full disassembly at docs/audio/spc-disassembly.md |
| Volume fade ($E6) | ❌ Not impl. | 31 occurrences; gradual CC7 ramp |
| Tempo fade ($E8) | ❌ Not impl. | 23 occurrences; gradual tempo ramp |
| Pan fade ($E2) | ❌ Not impl. | 29 occurrences; gradual CC10 ramp |
| Pitch envelope ($F2/$F3) | ❌ Not impl. | 16+13 occ.; portamento/glide |
| Amplitude modulation ($F0) | ❌ Not impl. | 94 occurrences; tremolo |
| ADSR attack override ($EC) | ❌ Not impl. | 2 occurrences; rare |
| ADSR full override ($F1) | ❌ Not impl. | 28 occurrences; dynamic envelopes |
| Echo FIR filter ($F7) | ❌ Not impl. | 30 occurrences; echo timbre shaping |
| Echo off/param ($F6) | ❌ Not impl. | Consumed, not emitted |
| Channel vol fade ($EE) | ❌ Not impl. | Per-channel volume fade (handler $09D9), 2 params |
| Tremolo ($EB) | ❌ Not impl. | Amplitude LFO (handler $099D), 3 params — delay/rate/depth |
| Subroutine $F8/$F9 | ❌ Not impl. | Subroutine call/return (handlers $0A2D/$0AFB) |
| Conditional $FA | ❌ Not impl. | Conditional flag (handler $0AE1) |
| DSP write $FF | ❌ Not impl. | Per-channel DSP register write (handler $0AB9) |
| $FB–$FE | ✅ N/A | UNUSED in IoG engine (invalid handler addresses) |
| Percussion mapping | ⚠️ Minimal | Only 1 percussion event in all IoG BGM |
| WAV round-trip | ✅ Complete | 32 kHz BRR decode, no resampling |
| SFX conversion | ✅ Complete | Pure BRR, no header |

---

## Critical Bug Fix: Opcode Parameter Counts

**Discovered during this sanity check.** By cross-referencing the SPC700 binary's parameter count table (ARAM `$0B89`, 32 bytes), we found that **8 opcodes had incorrect byte counts** in the N-SPC disassembler. This caused cascading misalignment of the sequence data parser, generating spurious notes from incorrectly-interpreted parameter bytes.

### Corrected Param Counts

| Opcode | Old (wrong) | New (correct) | Impact |
|--------|-------------|---------------|--------|
| `$EB` Tremolo | `offset += 2` | `offset += 4` | Was missing 2 params, causing next 2 bytes to be parsed as music data |
| `$EC` ADSR Attack | `offset += 2` | `offset += 1` | Was consuming an extra byte (a following note/opcode) |
| `$EF` Subcommand | `offset += 2` | `offset += 4` | Was missing 2 params |
| `$F1` ADSR Override | `offset += 3` | `offset += 4` | Was missing 1 param |
| `$F2` Pitch Envelope | `offset += 3` | `offset += 4` | Was missing 1 param |
| `$F6` Echo Off | `offset += 2` | `offset += 1` | Was consuming an extra byte |
| `$F8` Subroutine Call | `offset += 3` | `offset += 4` | Was missing 1 param |
| `$F9` Loop/Return | `offset += 3` | `offset += 4` | Was missing 1 param |
| `$FB`–`$FE` Unused | Various | `offset += 1` | Corrected to match UNUSED status (0 params) |

**Result:** Songs that contained these opcodes now parse correctly. Some songs that previously generated spurious notes (e.g., `beautiful_world`: 2076→628 notes) now have accurate note counts. Total note count across all 30 BGM tracks: **31,922** (essentially unchanged, confirming no data was lost — only spurious notes removed).

---

## Detailed Analysis

### 1. Fully Implemented & Verified ✅

These features have been reverse-engineered from the SPC700 binary, implemented in `@gaialabs/core`, and verified through listening tests:

#### Pitch System
- **Frequency table** (13 entries at ARAM $0E59): Verified against SPC binary
- **Pitch algorithm** (ARAM $0592–$05F0): `freq_shifted = (freqTable[semitone] × 2) >> (6 − octave)`, then `DSP_pitch = (freq_shifted × instPitch) >> 8`
- **Tuning interpolation**: `$F4` value interpolates between adjacent freq table entries; correctly maps to MIDI pitch bend at ±2 semitone sensitivity
- **Per-voice transpose** ($EA/$E9): Signed byte offset applied to all subsequent notes; persists from intro to loop patterns via `TrackDisasmState`

#### Timing System
- **Timer 1**: Divisor $10 → 500 Hz fire rate
- **Tick accumulator**: `acc += tempoByte; tick on overflow`
- **24 ticks per quarter**: Verified from note duration distributions
- **Tempo formula**: `µs/quarter = 12,288,000 / tempoByte`

#### Duration/Velocity System
- **24-byte combined table**: Bytes 0–7 = gate fractions, bytes 8–23 = velocity values
- **DV byte parsing**: `XCN A` instruction swaps nibbles; upper 3 bits = duration class, lower 4 bits = velocity index
- **Gate time**: `max(1, (duration × gateFraction) >> 8)`
- **Velocity persistence**: Sticky until explicitly changed; NOT reset by rests

#### Volume System
- **Channel volume ($ED)**: Linear 0–255, compensated to FluidSynth's logarithmic CC7 curve
- **Main volume ($E5)**: Same compensation applied

#### Song Structure
- **Multi-pattern phrase lists**: All patterns in the phrase list are now processed sequentially
- **Pattern-boundary sync**: Shorter channels padded with rests to match longest
- **Intro/loop split**: Patterns before loop marker → intro; patterns from loop target → loop
- **State persistence**: All channel state carries across pattern boundaries and intro→loop

#### SF2/MIDI Generation
- **Root key derivation**: `rootKey = round(60 − 12 × log₂(dspPitchAtC4 / 4096))`
- **Fine-tune correction**: Via SF2 `fineTune` generator (not SHDR pitchCorrection)
- **ADSR conversion**: Attack (linear timing model), decay (exponential), sustain level, fixed ~10ms release
- **Velocity mapping**: `√(raw/255)` to compensate FluidSynth square law
- **Volume mapping**: Inverse logarithmic for FluidSynth CC7

---

### 2. Partially Implemented ⚠️

#### Echo / Reverb ($F5, $F6, $F7)

**What's implemented:**
- Echo enable byte → MIDI CC91 (Reverb Send Level)
- Volume parameter scaled to 0–127

**What's missing:**
- **Echo delay** is not modeled — the SNES echo uses an ARAM delay buffer whose size determines the delay time. No MIDI equivalent.
- **Echo feedback** ($F5 param 3) is consumed but not used — FluidSynth's built-in reverb has its own feedback; the SNES feedback value doesn't map directly.
- **Echo FIR filter** ($F7, 30 occurrences) — 8-tap FIR filter coefficients that shape the echo's timbre. No MIDI equivalent.
- **Echo off/param** ($F6, consumed but no event) — should at minimum set CC91 to 0.

**Impact:** Echo adds perceived loudness and ambiance. The CC91 approximation is reasonable but the specific delay time and feedback character are lost. Most songs have echo enabled on channel 0 with moderate volume (30–110) and feedback (30–110).

#### Vibrato ($E3, $E4)

**What's implemented:**
- Vibrato depth → MIDI CC1 (Modulation Wheel), scaled from 0–255 to 0–127
- Vibrato off → CC1 = 0

**What's missing:**
- **Vibrato delay** (first parameter): The SNES vibrato doesn't start immediately — it waits `delay` ticks after a note-on before oscillating. MIDI CC1 is set immediately at the vibrato command time.
- **Vibrato rate** (second parameter): The oscillation speed is ignored. MIDI CC1 depth triggers the synth's default modulation rate.
- **Vibrato waveform**: The SPC engine likely uses a triangle wave LFO. FluidSynth's CC1 modulation may use a different shape.

**Impact:** Moderate. Used on 42 channels across all songs. Depths range from 12–120, rates from 12–30. The depth approximation captures the general feel but the timing and rate differences may be audible on sustained notes.

---

### 3. Not Implemented ❌

#### Fade Commands ($E2, $E6, $E8) — 83 total occurrences

These commands perform gradual transitions over a specified number of ticks:

| Command | Params | Occurrences | Description |
|---------|--------|-------------|-------------|
| $E6 | speed, target | 31 | Volume fade (main vol → target) |
| $E2 | speed, target | 29 | Pan fade (pan → target) |
| $E8 | speed, target | 23 | Tempo fade (tempo → target) |

**Current behavior:** The command is consumed (correct byte count) but the target value is never applied. The volume/pan/tempo remains at its previous value.

**Impact:** Medium. Fadeouts and cross-fades won't sound correct. Songs that rely on crescendo/diminuendo effects will sound static where they should be gradually changing.

**Implementation path:** Emit the target value as an immediate event (simple) or generate a series of intermediate MIDI events over the duration (accurate but complex).

#### Pitch Envelope / Portamento ($F2, $F3) — 29 total occurrences

| Command | Params | Occurrences | Description |
|---------|--------|-------------|-------------|
| $F2 | delay, speed | 16 | Enable pitch slide between notes |
| $F3 | — | 13 | Disable pitch envelope |

**Impact:** Low-medium. Affects glissando/portamento effects. Songs with sliding notes (e.g., string bends) will have discrete pitch jumps instead of smooth slides.

**Implementation path:** Could be mapped to MIDI CC65 (Portamento On/Off) and CC5 (Portamento Time).

#### Amplitude Modulation / Tremolo ($F0) — 94 occurrences

| Command | Params | Occurrences | Description |
|---------|--------|-------------|-------------|
| $F0 | param | 94 | Enable tremolo / amplitude modulation |

**Impact:** Medium. Tremolo is used frequently (94 occurrences). This creates a pulsing volume effect that adds expressiveness, particularly on sustained instruments. Without it, sustained notes sound flatter.

**Implementation path:** No direct MIDI CC equivalent. Could be emulated with a series of CC7/CC11 events, or ignored since FluidSynth's CC1 modulation includes some amplitude component.

#### ADSR Dynamic Override ($EC, $F1) — 30 total occurrences

| Command | Params | Occurrences | Description |
|---------|--------|-------------|-------------|
| $EC | rate | 2 | Override attack rate |
| $F1 | adsr1, adsr2 | 28 | Override full ADSR |

**Impact:** Low. The SF2 has static ADSR envelopes per instrument. Dynamic overrides mid-song would require real-time synthesis parameters that MIDI/SF2 don't support well.

#### Subroutine/Loop Flow Control ($F8, $F9, $FA, $FB) — 100 total occurrences

| Command | Params | Occurrences | Description |
|---------|--------|-------------|-------------|
| $F8 | addr_lo, addr_hi | 1 | Call subroutine at ARAM address |
| $F9 | count, addr | 43 | Loop/return from subroutine |
| $FA | param | 54 | Conditional flag |
| $FB | count, addr_lo, addr_hi, end | 2 | Repeat block |

**⚠️ IMPORTANT:** These are currently silently consumed. If any song uses $F9 loops to repeat musical phrases, those phrases will only play once instead of the intended repeat count. This could cause songs to sound shorter or have missing repeated sections.

**Impact:** Potentially high for songs that use subroutine loops. The 43 occurrences of $F9 suggest this may be actively used. Further investigation needed to determine if any of these fall within channel data (vs. being data bytes misidentified by the raw scan).

**Implementation path:** Would require the disassembler to actually follow subroutine calls and expand loops inline. Complex but important for completeness.

#### Now-Identified Commands ($EB, $EE, $FF)

**These were previously unknown but have been identified through SPC700 binary analysis:**

| Command | Handler | Params | Description |
|---------|---------|--------|-------------|
| $EB | `$099D` | 3 | **Tremolo** — Amplitude modulation LFO (delay, rate, depth). Analogous to $E3 vibrato but for volume. |
| $EE | `$09D9` | 2 | **Channel Volume Fade** — Per-channel volume ramp (speed, target). Like $E6 but per-channel instead of global. Handler computes a 16-bit per-tick increment. |
| $FF | `$0AB9` | 1 | **DSP Register Write** — Writes a value to a calculated DSP register based on the current channel. Likely noise clock or special DSP features. |

#### Confirmed Unused ($FB–$FE)

| Command | Handler | Params | Status |
|---------|---------|--------|--------|
| $FB | `$0001` | 0 | **UNUSED** — Invalid handler address. Not present in any IoG track. |
| $FC | `$0001` | 0 | **UNUSED** — Same. |
| $FD | `$0001` | 0 | **UNUSED** — Same. |
| $FE | `$0001` | 0 | **UNUSED** — Same. |

The raw byte scan counts (238 for $EE, 69 for $FF, etc.) were misleading because they included non-opcode data bytes (pattern pointers, channel pointers, BRR data offsets) that happened to have those values.

---

### 4. Known Limitations

#### FluidSynth-Specific Compromises
- **Velocity curve**: Square-root mapping compensates for FluidSynth's square law, but may sound wrong on other SF2 players
- **CC7 log curve**: Same — the logarithmic inversion is FluidSynth-specific
- **Reverb quality**: CC91 triggers FluidSynth's built-in reverb, which sounds nothing like the SNES echo hardware
- **Pitch bend**: ±2 semitone range via RPN 0,0; some players may default to ±12

#### Structural Limitations
- **Monophonic channels**: SNES channels are monophonic, but MIDI is polyphonic. Our note-off priority ordering (off before on at same tick) approximates this, but polyphonic synths may still overlap notes slightly.
- **No sample-level effects**: BRR Gaussian interpolation, noise generation, and pitch modulation are DSP-level effects with no MIDI equivalent.
- **No ARAM echo buffer**: The SNES echo effect uses an ARAM delay buffer. The delay time, FIR filter shape, and feedback are all hardware features that CC91 doesn't replicate.

#### Data Gaps
- **SFX samples 0–13**: Used for sound effects, not music. Definitions exist but they're not used by any BGM track's instrument table.
- **Percussion**: Only 1 percussion event across all 30 BGM tracks. The percussion mapping table (`PERCUSSION_TO_GM_DRUM`) is largely untested.
- **Driver init script** (ARAM $1200): Some songs upload a driver init script. Its effect is not modeled.

---

## Priority Recommendations

### High Priority (affects song accuracy)
1. **Implement channel volume fade ($EE)** — This is the per-channel version of $E6. Without it, channel volumes stay static where they should be ramping up/down. Likely affects many songs since $EE appeared frequently in raw scans.
2. **Implement fade commands** ($E2, $E6, $E8) — at minimum, emit the target value immediately. More accurately, generate intermediate CC events over the fade duration.
3. **Verify $F8/$F9 subroutine usage** — determine if any active channel data uses subroutine loops. If so, the disassembler needs to follow subroutine calls and expand loops inline.

### Medium Priority (improves quality)
1. **Implement tremolo ($EB)** — 3-param amplitude LFO. IoG uses this for tremolo effects. Can approximate with CC11 (Expression) modulation or ignore since SF2 has no built-in tremolo.
2. **Implement amplitude modulation ($F0)** — 94 occurrences. Single-param tremolo depth.
3. **Improve vibrato** — add delay parameter support (rate is less critical)
4. **Implement pitch envelope** ($F2/$F3) — adds expressiveness to sliding notes

### Low Priority (minor or rare)
1. Dynamic ADSR overrides ($EC, $F1) — can't be fully represented in MIDI/SF2
2. Echo FIR filter ($F7) — no MIDI equivalent
3. DSP register write ($FF) — unclear purpose, likely rare
4. $FB–$FE — confirmed unused in IoG engine, can be ignored

---

## Document Inventory

| Document | Path | Status |
|----------|------|--------|
| SPC Engine Reference | `docs/audio/spc-engine.md` | ✅ Complete |
| MIDI+SF2 Pipeline | `docs/audio/midi-sf2-pipeline.md` | ✅ Complete |
| Sample Catalog | `docs/audio/sample-catalog.md` | ✅ Complete |
| BGM Track Listing | `docs/audio/bgm-track-listing.md` | ✅ Complete |
| SPC700 Full Disassembly | `docs/audio/spc-disassembly.md` | ✅ Available |
| Gap Analysis (this file) | `docs/audio/gap-analysis.md` | ✅ Current |
| SPC Transfer Protocol | `docs/code/bank02/spc-transfer.md` | ✅ Complete |
| COP Audio Family | `docs/cop/families/audio.md` | ✅ Complete |

## Source File Inventory

| File | Path | Description |
|------|------|-------------|
| constants.ts | `gaia-core/src/audio/constants.ts` | Freq table, sample table, ARAM addrs |
| types.ts | `gaia-core/src/audio/types.ts` | All type definitions |
| nspc-disassembler.ts | `gaia-core/src/audio/parse/nspc-disassembler.ts` | N-SPC sequence decoder |
| bgm-parser.ts | `gaia-core/src/audio/parse/bgm-parser.ts` | BGM file parser |
| part-decoder.ts | `gaia-core/src/audio/parse/part-decoder.ts` | Block interpreter |
| sfx-parser.ts | `gaia-core/src/audio/parse/sfx-parser.ts` | SFX/instrument mapping |
| decode.ts | `gaia-core/src/audio/brr/decode.ts` | BRR → PCM decoder |
| writer.ts (sf2) | `gaia-core/src/audio/sf2/writer.ts` | SF2 SoundFont builder |
| mapper.ts | `gaia-core/src/audio/midi/mapper.ts` | Event → MIDI mapper |
| tempo.ts | `gaia-core/src/audio/midi/tempo.ts` | Tempo conversion |
| writer.ts (midi) | `gaia-core/src/audio/midi/writer.ts` | MIDI file writer |
| disasm-spc700.mjs | `gaia-iog-baserom/scripts/disasm-spc700.mjs` | SPC700 disassembler script |
| export-audio.mjs | `gaia-iog-baserom/export-audio.mjs` | Full export pipeline script |
