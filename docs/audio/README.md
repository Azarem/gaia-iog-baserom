# Illusion of Gaia — Audio Documentation

Comprehensive documentation of the IoG audio system, from hardware to MIDI export.

## Documents

### [SPC Engine Reference](spc-engine.md)

Complete reverse-engineering of the IoG N-SPC sound engine:

- ARAM memory map
- BGM file format (block structure, instrument trailer)
- Song structure (phrase lists, patterns, channel pointers)
- Instrument definitions (SRCN, ADSR, pitch)
- Full N-SPC instruction set ($E0–$FF)
- Pitch calculation algorithm (frequency table, octave shift, instrument pitch multiplication)
- ADSR envelope system (attack/decay/sustain/release timing)
- Tempo and timing (Timer 1, tick generation, BPM conversion)
- Echo / reverb system
- Sample directory and BRR format
- Known quirks discovered during reverse-engineering

### [MIDI + SF2 Pipeline](midi-sf2-pipeline.md)

Technical documentation for the BGM → MIDI + SoundFont conversion:

- Pipeline architecture (parsing → disassembly → SF2/MIDI generation)
- BGM parsing and block interpretation
- N-SPC disassembler implementation details
- SoundFont generation (root key derivation, ADSR conversion, generator mapping)
- MIDI generation (event mapping, tempo handling, pitch bend configuration)
- FluidSynth compensation (velocity square-root, CC7 logarithmic inversion)
- Source file inventory

### [Sample Catalog](sample-catalog.md)

Complete inventory of all 60 IoG audio samples with instrument pitch, root key, and ADSR parameters.

### [BGM Track Listing](bgm-track-listing.md)

All 30 background music tracks with instrumentation, channel count, tempo, and layout type.

## Related Documentation

- [SPC Transfer Protocol](../code/bank02/spc-transfer.md) — 65C816 ↔ SPC700 upload protocol
- [COP Audio Family](../cop/families/audio.md) — COP handlers for music/SFX script commands
- [gaia-knowledge audio corpus](../../) — Knowledge base entries for SNES audio hardware

## Quick Reference

### Playing exported MIDI

```bash
# FluidSynth CLI
fluidsynth -a dsound temp/audio/iog-instruments.sf2 temp/audio/midi/bgm_secret_of_nazca.mid

# VLC: Tools → Preferences → Show All → Input/Codecs → Audio codecs → FluidSynth
# Set "SoundFont file" to the full path of iog-instruments.sf2
```

### Re-exporting

```bash
cd gaia-iog-baserom
node export-audio.mjs
```

### Key constants

| Constant | Value | Description |
|----------|-------|-------------|
| `NSPC_TICKS_PER_QUARTER` | 24 | Ticks per quarter note |
| `BRR_SAMPLE_RATE` | 32,000 Hz | Native SNES DSP mixer rate |
| `SPC_SLOT_BASE` | `$0E` | First instrument slot index |
| `ARAM_SONG_BASE_STANDARD` | `$5532` | Standard song data base address |
| `ARAM_INSTRUMENT_DEF` | `$1254` | Instrument definition upload target |
| `ARAM_VELOCITY_TABLE` | `$1300` | Duration/velocity table upload target |
| `DEFAULT_TEMPO_BYTE` | `$10` (16) | ~78 BPM |
