# IoG SPC700 Sound Engine — US vs JP Comparison

Comparison of the Quintet N-SPC sound-engine program embedded in the US and JP builds of *Illusion of Gaia*.

| | US | JP |
|---|---|---|
| Source label | `spc_sound_engine` — `extracted/system/engine/spc_transfer.asm:328` | `spc_0292D1` — `extracted-jp/system/chunk_028000.asm:3101` |
| ROM offset (headerless) | 168464 (blob 3026 bytes) | 168657 (blob 2975 bytes) |
| ARAM payload | `$0400–$0FC9` (3018 bytes) | `$0400–$0F96` (2967 bytes) |
| Entry point | `$0400` | `$0400` |
| Decoded instructions | 1373 | 1324 |
| Command opcodes | `$E0–$FA` + `$FF` (32-entry table) | `$E0–$FA` (27-entry table) |
| Full disassembly | [spc-disassembly.md](spc-disassembly.md) | [spc-disassembly-jp.md](spc-disassembly-jp.md) |

Companion: [spc-engine-us-vs-jp-alignment.md](spc-engine-us-vs-jp-alignment.md) — every instruction of both engines in aligned order (generated).

> **Status of claims.** Everything in the tables below that quotes an address, byte, or instruction is read directly from the two disassemblies. Statements labelled *(inferred)* are interpretations of what the code does; statements labelled *measured* were observed by running the US ROM in Mesen2 (SPC-side trace); the JP ROM was never run. §10 lists what remains unverified.

---

## 1. Summary

The two engines are the **same program**. Roughly 90 % of the US instructions have an exact counterpart in the JP engine (identical, or identical after relocating addresses); the command set, the voice/sequence machinery, the DSP register tables and the frequency/pan/echo tables are shared. The differences are concentrated in four areas:

1. **Master volume and fade-out were re-architected in the US build.** JP applies a fixed master volume and scales *each voice* by the fade level. US computes `MVOL`/`EVOL` from the fade level and a new port-controlled volume scale, and no longer scales voices.
2. **Boot/stop/start state differs.** US boots muted with master/echo volume 0 and relies on the first `$E5` command to open the master volume; JP boots at `MVOL=$60`, unmuted.
3. **The JP engine has a stereo-sweep SFX mode** (two SFX voices panned in opposition from a 64-entry table) that the US engine removed. The US engine instead gained a new command `$FF` (set ADSR), a second timer, a forced SFX channel volume, an SFX key-off, and a snap-to-target at the end of pitch slides.
4. **Level changes.** With identical song data the US engine plays about 2.3 dB quieter than JP (static estimate), from two independent changes (`$E5` subtracts `$1E`; MVOL is scaled by `$3E = $E0`). See §6.

Song data is largely shared between regions: 24 of 30 `.bgm` files are byte-identical (§9), so the engines must remain data-compatible for the common case.

---

## 2. Methodology

Reproduce with:

```bash
node scripts/disasm-spc700.mjs --variant us      # → docs/audio/spc-disassembly.md
node scripts/disasm-spc700.mjs --variant jp      # → docs/audio/spc-disassembly-jp.md
node scripts/compare-spc-engines.mjs --diffs     # summary + hunk table on stdout
node scripts/compare-spc-engines.mjs --appendix docs/audio/spc-engine-us-vs-jp-alignment.md
```

1. **Extract.** Both blobs are read from the extracted `.asm` files and unpacked as IPL upload streams (`[u16 size][u16 target][payload]…`, terminated by `[0000][entry]`). Both unpack to a single block at `$0400` with entry `$0400`.
2. **Trace.** Recursive-descent from the entry point and from every command handler in the handler table. Instructions are decoded with a full SPC700 opcode table (`scripts/lib/spc700.mjs`). Everything not reached by tracing is a data table.
3. **Command table.** Handler addresses are 16-bit words indexed by opcode; the dispatcher pushes the handler address (high, then low) and executes `RET`. The SPC700 `RET` does **not** add 1 to the popped address, so the table values are the true entry points.
4. **Align.** The two instruction streams are aligned globally (Needleman–Wunsch, `scripts/lib/spc-align.mjs`). Each aligned pair is classified:
   - *same* — identical bytes-level operands
   - *relocated* — only code/table addresses differ, and they map consistently through the alignment
   - *operand* — a constant, direct-page variable, or branch target differs
   - *mnemonic* — different instruction at the aligned position
   - *US-only* / *JP-only* — no counterpart
5. **Tables.** Data regions are compared byte-for-byte by name.

### Alignment result

| Class | Count |
|-------|------:|
| Identical | 954 |
| Identical modulo relocation | 279 |
| Operand changed | 18 |
| Mnemonic changed | 7 |
| US only | 115 (231 code bytes) |
| JP only | 66 (132 code bytes) |

1233 of 1258 matched pairs (98 %) are identical or merely relocated. The 51-byte payload difference is accounted for by +99 US-only code bytes, +15 US-only table bytes (larger handler/parameter tables), and −64 JP-only table bytes (pan sweep table), within a byte or so of operand-size changes.

---

## 3. Memory layout and data tables

| Region | US | JP | Comparison |
|--------|----|----|-----------|
| Code | `$0400–$0B48`, `$0BA9–$0E0F`, `$0E87–$0FC9` | `$0400–$0A93`, `$0AE5–$0D38`, `$0DF0–$0F96` | shifted; see §5 |
| `OpHandlerTable` | `$0B49–$0B88` (32 × u16) | `$0A94–$0AC9` (27 × u16) | US has 5 more entries |
| `OpParamCountTable` | `$0B89–$0BA8` (32 B) | `$0ACA–$0AE4` (27 B) | US has 5 more entries |
| `PanCurveTable` | `$0E10–$0E24` | `$0D39–$0D4D` | **identical** |
| `SfxPanSweepTable` | — | `$0D4E–$0D8D` (64 B) | **JP only** |
| `EchoFirTable` | `$0E25–$0E44` | `$0D8E–$0DAD` | **identical** |
| `DspRegAddrTable` | `$0E45–$0E4E` | `$0DAE–$0DB7` | **identical** |
| `DspRegSourceTable` | `$0E4F–$0E58` | `$0DB8–$0DC1` | **2 bytes differ** (§5.4) |
| `FreqTable` | `$0E59–$0E72` | `$0DC2–$0DDB` | **identical** |
| `VoiceRegBaseTable` | `$0E73–$0E86` | `$0DDC–$0DEF` | **identical** |

`SfxPanSweepTable` contents (JP): a 64-entry triangle-ish wave from `$0A` up to `$14`, down to `$00` and back to `$09`, i.e. a pan position (`0..$14`) sweeping across the stereo field. The previous working name `LfoSineTable` was wrong: its only reader is the JP SFX stereo sweep (§5.9), not a vibrato LFO.

Both engines use the same fixed ARAM structures: DSP sample directory at `$1000` (`DIR = $10`), SFX script pointer table at `$1400`, instrument table at `$1200` (6 bytes per entry), song base pointer at `$0FFC`, extended-song marker at `$0FFD == $14`.

---

## 4. Command set

All 27 JP commands exist in the US engine with the same parameter count and the same role. The US engine adds `$FF`.

| Op | Role *(inferred)* | Params | US handler | JP handler | Handler difference |
|----|------|:-:|:-:|:-:|---|
| `$E0` | SetInstrument | 1 | `$089D` | `$081D` | none (relocated) |
| `$E1` | SetPan | 1 | `$0909` | `$0889` | none |
| `$E2` | PanSlide | 2 | `$0917` | `$0897` | none |
| `$E3` | VibratoOn | 3 | `$0930` | `$08B0` | none |
| `$E4` | VibratoOff | 0 | `$093C` | `$08BC` | none |
| `$E5` | SetSongVolume | 1 | `$0957` | `$08D7` | **US subtracts `$1E`, opens fade level** (§5.5) |
| `$E6` | SongVolumeSlide | 2 | `$0968` | `$08E1` | none |
| `$E7` | SetTempo | 1 | `$097A` | `$08F3` | none |
| `$E8` | TempoSlide | 2 | `$0983` | `$08FC` | none |
| `$E9` | GlobalTranspose | 1 | `$0995` | `$090E` | none |
| `$EA` | ChannelTranspose | 1 | `$0998` | `$0911` | none |
| `$EB` | TremoloOn | 3 | `$099C` | `$0915` | none |
| `$EC` | TremoloOff | 0 | `$09A8` | `$0921` | none |
| `$ED` | SetChannelVolume | 1 | `$09C9` | `$0942` | **US forces `$B4` in SFX mode** (§5.5) |
| `$EE` | ChannelVolumeSlide | 2 | `$09D8` | `$094B` | none |
| `$EF` | CallSubroutine | 3 | `$09F5` | `$0968` | none |
| `$F0` | VibratoFade | 1 | `$0947` | `$08C7` | none |
| `$F1` | PitchEnvelopeTo | 3 | `$09AB` | `$0924` | none |
| `$F2` | PitchEnvelopeFrom | 3 | `$09AF` | `$0928` | none |
| `$F3` | PitchEnvelopeOff | 0 | `$09C5` | `$093E` | none |
| `$F4` | FineTune | 1 | `$09F1` | `$0964` | none |
| `$F5` | EchoOn | 3 | `$0A19` | `$098C` | none |
| `$F6` | EchoOff | 0 | `$0A4D` | `$09C0` | none |
| `$F7` | SetEchoParams | 3 | `$0A54` | `$09C7` | none |
| `$F8` | EchoVolumeSlide | 3 | `$0A2C` | `$099F` | none |
| `$F9` | PitchSlide | 3 | `$0AFA` | `$0A45` | none at entry; per-tick effect differs (§5.8) |
| `$FA` | SetPercussionBase | 1 | `$0AE0` | `$0A2B` | none |
| `$FB–$FE` | — | — | `$0000` | — | US table entries are **zero** (jump to `$0000`) |
| `$FF` | **SetAdsr** | 1 (table) / 3 (actual) | `$0AB8` | — | **US only** (§5.6) |

Role names are from the handler bodies and the N-SPC lineage; they are also used as labels in the disassemblies.

Notes:

- `OpParamCountTable` and `OpHandlerTable` are otherwise identical in content; JP simply ends at `$FA`.
- A JP song stream containing `$FB–$FF` would index past the 27-entry table. This cannot occur with shipped data (§9).
- Parameter counts are consistent for every shared opcode.

---

## 5. Change catalog

Addresses are `US / JP`. "Hunk" ranges match the table printed by `compare-spc-engines.mjs`.

### 5.1 Boot sequence — `$0400…$0443` / `$0400…$0433`

| | US | JP |
|-|----|----|
| FLG mirror `$48` | `SET1 $48.6` at `$040C` — **mute bit set at boot** | not set |
| `MVOL` L/R (DSP `$0C/$1C`) | `A = $00` | `A = $60` |
| `EVOL` L/R (DSP `$2C/$3C`) | explicitly written `$00` (extra `CALL WriteDsp` ×2 at `$041D–$0427`) | not written |
| `DIR` (DSP `$5D`) | `$10` | `$10` |
| Timer 0 target (`$FA`) | `$10` | `$10` |
| Timer 1 target (`$FB`) | **`$10`** (`$0439–$043B`) | not configured |
| `CONTROL` (`$F1`) | `$03` (T0 + T1) | `$01` (T0 only) |
| Tempo default `$53` | `$10` | `$10` |

The final `CONTROL` write in the loader tail follows the same pattern: `MOV X,#$33` (US, T0+T1 + port clear) vs `MOV X,#$31` (JP, T0 + port clear) at `$0FC5 / $0F92`.

### 5.2 Main loop pacing and master volume — `$046D…$04E3` / `$045D…$049C`

| | US | JP |
|-|----|----|
| Tick source | waits on **T0OUT** (`$FD`) for the 125 Hz auxiliary clock (`$43`: SFX tick + echo-delay stepping), then spins on **T1OUT** (`$FE`) as the tempo multiplier (`MOV Y,$FE; BEQ` at `$0495`) | waits on **T0OUT** once; the count is `PUSH`ed and reused as the tempo multiplier (`PUSH Y` `$0461`, `POP Y` `$0482`) |
| Tick condition | carry from `$51 += tempo×count` **or** non-zero high byte of the product (`BCS`/`CMP Y,#0` at `$049F–$04A3`) | carry only (`BCC` at `$0489`) |
| SFX tick gate | skipped when `$0FFD == $14` **or `$31 == 0`** (`$0480–$0484`) | skipped when `$0FFD == $14` only |
| Master volume per tick | **new block `$04A8–$04D2`** (below) | none |
| Fade-out countdown | `DEC $31` per tick, ends at 0 → CmdStop | `DEC $31` per tick, ends at 0 → CmdStop |

Both timers run at the same nominal rate (target `$10` → 500 Hz), so the effective cadence is the same; the US build simply tracks them with independent hardware counters.

The US master-volume block runs once per music tick (`$31 != 0`):

```
$6B  = (($61 * $31) >> 8 * $3E) >> 8      ; echo volume L source
$6C  = (($63 * $31) >> 8 * $3E) >> 8      ; echo volume R source
MVOL = (($60 * $31) >> 8 * $3E) >> 8      ; written to DSP $0C and $1C, and to port 3 ($F7)
```

Here `$61/$63` are the current echo-volume high bytes (set by `$F5`/`$F8`), `$60` is an **immediate constant** (the same `$60` JP writes to MVOL at boot), `$31` is the fade level, and `$3E` is the port-controlled volume scale (§5.3). The DSP master volume is therefore `$60 × fade × $3E`; echo L/R go through `$6B/$6C` (§5.4).

The block also writes the computed volume to **SPC port 3** (`MOV $F7,A` at `$04C9`). Searching both ROMs' extracted 65816 code found no reader of `$2143`/`APUIO3` other than the IPL transfer routine's own protocol, so this appears to be an unused output *(inferred)*.

### 5.3 Port command handling — `$068B…$06C1` / `$0610…$0640`

Command byte dispatch is shared: `$F0` stop, `$F1` fade-out, `$F2` mute (see below), `$FF` (`$0683/$0608` routine), `$90/$91` stereo/mono (`$32`), `$02` start song.

Differences:

| | US | JP |
|-|----|----|
| Command source in the volume branch | `MOV A,$04` (latched command) | `MOV A,$F4` (re-read hardware port) |
| Volume command range | `$40–$7F`; `A = ((cmd−$40) << 2) ^ $FF`; `$3E = (A × $E0) >> 8` → `$DF` (cmd `$40`) down to `$02` (cmd `$7F`) | `$10–$7F`; `$3E = (cmd−$10) << 1` → `0` (cmd `$10`) up to `$DE` (cmd `$7F`); also `$5E = $FF` |
| Meaning of `$3E` | **multiplicative** master scale (large = loud; song-start default `$E0`) | **subtractive** voice attenuation (`SBC A,$3E` at `$0D1D`); `0` = none (song-start default) |
| `$F1` fade-out (`CmdFadeOut`) | `$30 = $FF`, `$31 = $FF` | `$30 = $FF`, **`$31 = $7F`** |
| `$F2` (`CmdF2` / `CmdMute`) | `MOV $0E,#$FF` — the KOFF source: keys off all voices (measured, see below) | `SET1 $48.6` — sets FLG mute |

Consequences:

- **Fade length.** US fades from level `$FF` (255 ticks); JP counts down from `$7F` (127 ticks). In tick counts, the US fade-out runs twice as long. Wall time is tick-rate dependent (`ticks/s ≈ tempo × 500 / 256`).
- **Fade effect.** In JP the countdown value is *also* the fade scale for every voice (`$31 << 1`, `$0D2A–$0D31`). In US the same variable is multiplied into `MVOL`/`EVOL` instead (§5.2).
- **`$F2` keys off every voice in the US engine; it does not mute.** It writes `$FF` to `$0E`, and `$0E` is the KOFF source of the main-loop DSP refresh (`DspRegSourceTable` entry 7, `$0E`, paired with `DspRegAddrTable` entry 7, DSP `$5C`; an earlier scan of the code for direct reads missed the table). In JP, `$F2` mutes the DSP via FLG bit 6. Measured on the US ROM (Mesen2, SPC-side trace of a scene change): `$F2` is dispatched to `CmdF2` (`$067F`), the main loop writes KOFF = `$FF` within a tick, and the summed voice envelope falls from about 460 to 0 within 4 frames; master volume, echo volume and FLG stay unchanged (`$53`, `$19`, `$00`) until the `$F0` that follows. The engine dispatches `$F2` again on every tick while the port still holds it (a command byte of `$F0` or above jumps to the dispatch without the edge compare against `$08`). `SpcMusicLoadCmd` sends `$F2` before a music change when `$0D72` is set and holds it for 32 frames, so the old track is silent about 30 frames before `$F0` arrives.

### 5.4 DSP echo-volume source

`DspRegSourceTable` bytes 1–2 are the direct-page sources copied to DSP `EVOL` L/R by the main-loop DSP refresh (`$0443…$0467` / `$0433…$0457`):

| Index | DSP reg | US source | JP source |
|:-:|:-:|:-:|:-:|
| 1 | `$2C` EVOLL | `$6B` | `$61` |
| 2 | `$3C` EVOLR | `$6C` | `$63` |

The US engine reads the **scaled** values from §5.2; JP reads the raw echo-volume variables set by `$F5/$F8`. All other entries are identical. Dependent change: the one-word zero constant used by the slide-negate helper (`MOVW YA,$xx`; neither engine writes it, so it is a `0` constant) lives at `$1C` in the US build and `$0E` in JP (`$0B44 / $0A8F`).

### 5.5 `$E5` and `$ED`

```
; US $E5 (SetSongVolume)            ; JP $E5
MOV A,Y                             MOV A,Y
SETC                                SETC
SBC A,#$1E          ; ← −30         SBC A,#$00
MOV Y,A                             MOV Y,A
MOV A,#$00                          MOV A,#$00
MOVW $58,YA         ; $59 = vol     MOVW $58,YA
MOV A,$31
BNE .done
MOV $31,#$FF        ; ← open master volume
.done RET                           RET
```

- US `$E5` stores `parameter − $1E` (30) in `$59`. A song written for the JP engine with `$E5 $F0` plays at `$D2` in the US engine.
- US `$E5` also sets the fade level `$31` to `$FF` **if it is 0**. Because the US boot and CmdStop leave `$31 = 0` (§5.1, §5.7), `MVOL` stays at 0 and the SFX tick stays gated until the first `$E5` executes.

US `$ED` (`SetChannelVolume`) additionally does:

```
MOV Y,$34
BEQ .store
MOV A,#$B4          ; in SFX mode, force channel volume to 180 regardless of the operand
.store MOV $0305+X,A
```

JP stores the operand unchanged.

### 5.6 `$FF` — SetAdsr (US only, `$0AB8–$0ADF`, 40 bytes)

```
b1 = operand from the dispatcher
Y  = DSP ADSR1 register of the channel's voice
     (X = slot×2; X ≥ $10 first has 4 subtracted, so SFX slots $10/$12 map to DSP voices 6/7;
      Y = (nibble-swap(X) >> 1) + 5 = voice×$10 + 5)
WriteDspVoiceMasked(Y, b1 | $80)                     ; ADSR1, ADSR mode enabled
Y++                                                  ; ADSR2
b2 = ReadSeqByte();  $3F = b2
b3 = ReadSeqByte()
WriteDspVoiceMasked(Y, (nibble-swap(b3) << 1) | b2)  ; ADSR2
```

It reads **three** sequence bytes (operand 1 from the dispatcher, then two via `ReadSeqByte`) but the US `OpParamCountTable` lists `1` for `$FF`. For every shared opcode the table entry equals the number of bytes consumed, so this entry is inconsistent. The mismatch only matters for code that uses the table to skip commands (e.g. when a voice is muted). No shipped song uses `$FF` (§9).

### 5.7 Stop / start song

`CmdStop` (`$F0`; US `$0636`, JP `$05EF`):

| Step | US | JP |
|------|----|----|
| Guard | `MOV A,$D5; BEQ → RET` — nothing to stop if music channel 0 is inactive | no guard |
| Master | `$6B = $6C = 0`; `MVOL` and `EVOL` L/R written `0` directly (`$0649–$065C`); `$5C = $FF` | `$46 = $FF` (KOF all voices) |
| `$0E` | `= $FF` (the KOFF source: all voices keyed off by the next refresh) | — |
| FLG | `SET1 $48.5` (echo write disable) | `SET1 $48.5` **and `SET1 $48.6` (mute)** |
| Channel state | all eight music channel pointers `$D5…$E3` zeroed; `$31 = 0` | only `$E5`, `$E7` zeroed |
| Common | `$04 = 0`, echo-delay reset via `SetEchoDelay(1)` | same |

Start song (cmd `$02`; US `$06C2…`, JP `$0641…`):

| | US | JP |
|-|----|----|
| `$31` | `= 0` (`$06E1`) | not touched |
| `$35` (SFX sweep state) | — | `= 0` |
| `$3E` | `= $E0` (`$06F2`) | `= 0` |
| `$0E` | `= 0` (the KOFF source cleared) | — |
| FLG mute | `CLR1 $48.6` | `CLR1 $48.6` |
| Per-voice init volume `$0305+X` | `$00` (`$0707`) | `$FF` (`$0681`) |
| Song master volume `$59` | `$00` (`$0731`) | `$C0` (`$06AB`) |

The tick routine's head differs the same way: JP clears FLG mute on every tick while music runs (`CLR1 $48.6`, `$06CA`), the US build clears the KOFF source `$0E = 0` (`$0750`). JP's tick also forces all-voice volume recomputation while a fade is active (`$07AD–$07B1`: `$30 != 0 → $5E = $FF`), which the US engine does not need because voices are no longer scaled by the fade.

Net effect: in the JP engine volume state is *initialised to audible defaults* (`$59 = $C0`, channel volume `$FF`, `MVOL = $60`); in the US engine everything starts at zero and each song must set `$E5` and `$ED` itself. Shipped songs do (§9).

### 5.8 Pitch slide (`$F9`) — `$0CEA…$0D0C` / `$0C21…$0C2A`

Both engines add a per-tick delta (`$0390+X/$0391+X`) to the current pitch (`$037C+X/$037D+X`) while the slide counter `$98+X` runs.

- **US** performs the add inline and, when `DEC $98+X` reaches 0, **snaps the pitch to the exact target** (`$03A5` → `$037C`, `$03A4` → `$037D`), removing accumulated rounding error.
- **JP** performs the add through the shared 16-bit helper (`CALL $0B88`, with `YA = $037C`) and never snaps; the final pitch is target ± rounding.

The US helper (`$0C49`) also gained a guard (`CMP A,#$7C; BEQ RET` at `$0C58–$0C5A`) that JP lacks. Its purpose is unclear (open item 5).

### 5.9 SFX engine — `$0E87…$0F89` / `$0DF0…$0F56`

The SFX tick reads `PORT2`/`PORT3` for two SFX voices (`X = $10` and `X = $12`). Shared behaviour: port value → script index into the `$1400` pointer table → voice starts running that script in SFX mode (`$34 = $FF`), with `$1A`/`$37`/`$36` masks keeping the music channel from overwriting that voice.

JP-only additions:

| JP address | Change |
|------------|--------|
| `$0E05–$0E3D` | If the port-2 byte has **bit 7 set**, start the *same* script (low 7 bits) on **both** SFX voices (`X = $10` and `$12`), set the stereo-sweep flag `$35 = $FF`, phase `$3F = 0`, and give the second voice `$70+X = 3` (instead of 2; one tick later *(inferred)*) |
| `$0E07–$0E09` | A normal (bit 7 clear) port-2 command is ignored while a sweep is active (`$35 != 0`) |
| `$0E46–$0E4C` | Port-3 SFX is ignored while the sweep is active |
| `$0EC9–$0EFA` | Per-tick for each SFX voice while `$35 != 0`: mark volume dirty (`$5E`), advance `$3F`, look up `SfxPanSweepTable[($3F>>1) & $3F]`, and call `SetPan`. Voice `$12` uses `table | $C0`; voice `$10` uses the *negated* phase (`−$3F`), so the two voices pan in opposition |
| `$0EC6` | `$35` cleared when the SFX voice ends |
| `$0F4B–$0F52` | While fading (`$30 != 0`), force volume recompute for the voice |

So a port-2 SFX id with the high bit set is a **stereo "ping-pong" SFX** in the JP engine. Which game SFX use it was not determined; in the US engine bit 7 is not treated specially.

US-only / changed:

| US address | Change |
|------------|--------|
| `$0F15` | At SFX voice end, `OR $46,$47` — **key-off** the SFX voice (JP does not) |
| `$0ED9` | SFX script start sets default channel volume `$0305+X = $96`; JP sets `$DC` |
| `$0E87` gate | SFX tick skipped while `$31 == 0` (§5.2) |
| `$09C9` | `$ED` forces channel volume `$B4` in SFX mode (§5.5) |

The per-voice volume computation (US `$0D63` family → `$0E0F`, JP `$0C81` family → `$0D38`) also differs: JP subtracts `$3E` from the intermediate (`SETC; SBC A,$3E` at `$0D1C`, music voices only) and multiplies by `$31 << 1` while a fade is active (`$0D29–$0D31`, all voices including SFX); the US version has neither step because those factors moved into the master volume (§5.2).

### 5.10 Unchanged areas

Instrument load (`$E0`), pan/vibrato/tremolo/tempo/echo commands, note-to-pitch (frequency table, octave shift, instrument pitch multiply), the voice update loop, sequence reader (`ReadSeqByte`, `ReadWord`, phrase-list/loop-marker handling), echo FIR sets and delay logic, the DSP write helpers, the port sync routine (`SyncPort`), the extended-song marker (`$0FFD == $14`), and the IPL-return loader tail are all the same in both builds apart from relocation.

---

## 6. Resulting loudness difference *(estimate from static analysis)*

For the same song data (`$E5 $F0`, `$3E` at its song-start default):

| Factor | JP | US |
|--------|----|----|
| Song master volume `$59` | `$F0` | `$F0 − $1E = $D2` → ×0.875 |
| `MVOL` | `$60` fixed (96) | `$60 × ($FF/256) × ($E0/256)` ≈ `$54` (84) → ×0.875 |
| Combined voice+master gain | 1.00 | ≈ 0.766 |

That is about **−2.3 dB** in the US build for music (all songs but one use `$E5 $F0`; one uses `$E5 $EB`). SFX voices bypass `$59` but still see MVOL, the `$ED` override (`$B4`) and the `$96` default (JP `$DC`). Among the shared songs, only `bgm_waterfall` differs by a volume byte (`$ED $F0` in JP, `$ED $DC` in US, a 0.92× channel scale), so the song data does not otherwise compensate for the engine change.

---

## 7. Routine map

Shared routines, names as used in the disassemblies (address US → JP):

| Routine | US → JP |
|---------|---------|
| `SyncPort` | `$0504 → $04BD` |
| `WriteDspVoiceMasked` | `$05FE → $05B7` |
| `WriteDsp` | `$0606 → $05BF` |
| `ReadWord` | `$060B → $05C4` |
| `CmdFadeOut` | `$0619 → $05D2` |
| `ClearAramTail` | `$0622 → $05DB` |
| `CmdStop` | `$0636 → $05EF` |
| `CmdF2` / `CmdMute` | `$067F → $0605` |
| `ProcessPortCommand` | `$06C2 → $0641` |
| `MusicTick` | `$0738 → $06B2` |
| `ReadSeqByte` | `$0893 → $0813` (27 callers in each) |
| `SetEchoDelay` | `$0A76 → $09E9` |
| `ComputeSlideStep` | `$0B2D → $0A78` |
| `UpdateVoice` | `$0D63 → $0C81` |
| `SfxTick` | `$0E87 → $0DF0` |
| `SfxStartScript` | `$0ECA → $0E64` |
| `SfxVoiceStep` | `$0F30 → $0EC9` |

The full 200+ routine mapping is in the `compare-spc-engines.mjs` output ("Routine map").

---

## 8. Direct-page variables whose role differs

| DP | US | JP |
|----|----|----|
| `$0E` | KOFF source (`DspRegSourceTable` entry 7 → DSP `$5C`); set to `$FF` by `$F2` and CmdStop, cleared at song start and at the tick head | scratch zero word for the slide-negate helper (with `$0F`) |
| `$1C` | scratch zero word for the slide-negate helper (with `$1D`) | unused |
| `$31` | fade **level** `$FF…0`, also gates MVOL and SFX tick | fade **countdown** `$7F…0`, scales each voice |
| `$35` | unused | SFX stereo-sweep active |
| `$3E` | **multiplicative** master scale, default `$E0` | **subtractive** voice attenuation, default `0` |
| `$3F` | scratch for `$FF` | SFX stereo-sweep phase counter |
| `$59` | song master volume, default `0` (set by `$E5 − $1E`) | song master volume, default `$C0` |
| `$6B/$6C` | scaled echo volume L/R (feed `EVOL`) | unused |
| `$04` vs `$F4` | latched command used by the volume branch | volume branch re-reads the port |

Everything else compared (`$30`, `$32`, `$34`, `$36/$37/$1A`, `$45/$46/$47/$48`, `$4C/$4D`, `$53`, `$5E`, `$60–$63`, …) has the same role in both builds.

---

## 9. Implications and cross-checks against song data

The 65816 side uploads a `.bgm` stream, whose song sequences contain only commands from the shared set. A quick scan (`temp/bgm-ops.mjs`, a throw-away parser that walks phrase lists → patterns → channel streams, following `$EF` calls) over all `extracted/music/*.bgm` and `extracted-jp/music/*.bgm` found:

| Check | Result |
|-------|--------|
| Identical files across regions | **24 of 30** byte-identical (23 by file name, plus `bgm_1D4F6B` in the US tree = `bgm_1E125C` in the JP tree, 454 B) |
| Differing files | `bgm_awakening_the_wind` (US 2325 B / JP 1201 B), `bgm_illusion_of_gaia` (4625 / 4587), `bgm_lively_city` (3001 / 4013), `bgm_lively_city_by_the_sea` (3161 / 4253), `bgm_rebirth` (8593 / 8680), `bgm_waterfall` (142 / 142, one byte) |
| `$FF` (SetAdsr) used by any song | **No** (US or JP) |
| Songs that execute `$E5` | every song in which the parser found sequence streams (all but `bgm_restart`), both regions |
| Songs that execute `$ED` | the same set, both regions |
| Command histogram | both regions use only `E0–E5, E7, E8, EA, ED, EE, F1–F5, F7, FA` |

Conclusions:

- **Region-shared song data works on both engines**: shared songs only use commands present in both, and `$E5`/`$ED` are always set explicitly, so the changed power-on defaults (§5.7) and the `$31`-gated master volume (§5.5) do not break them.
- The `$FF` command is not exercised by any shipped BGM. The JP stereo sweep and the US SFX `$ED` override concern SFX scripts (ARAM `$1400` table), which were not scanned; whether they use these paths is open (§10).
- For `awakening_the_wind`, `lively_city` and `lively_city_by_the_sea` the shorter file is a byte-for-byte prefix of the longer one; `illusion_of_gaia` and `rebirth` differ throughout the common length (3305 and 7122 bytes). In all cases the opcode usage stays within the shared command set.
- The parser is a throw-away heuristic (`temp/bgm-ops.mjs`, not kept as a supported tool); treat the histogram as supporting evidence, not a full proof.

---

## 10. Unverified / open items

1. **Runtime behaviour.** Only the US ROM was run (SPC-side trace, see [mesen2-d-series-summary.md](../mesen2-d-series-summary.md)): the fade-out is audible (master volume `$53` to 0 in about 335 frames, one step about every 4 frames), `$F2` keys off the voices, CmdStop clears master and echo volume, and the resident loader writes no DSP register. The volume estimate (§6) and the SFX-gating on `$31 == 0` are still static-analysis conclusions; the JP ROM was not run.
2. **PORT3 output.** The US engine's master-volume value written to `$F7` appears unused; only the extracted 65816 code was searched (`$2143` / `APUIO3`).
3. **Command source `$04` vs `$F4`.** JP re-reads the port in the volume branch; whether any observable timing difference follows was not analysed.
4. **`$5C = $FF` in US CmdStop.** Purpose unclear; JP has no equivalent.
5. **US `$0C58` guard** (`CMP A,#$7C; BEQ`) in the 16-bit add helper — purpose unclear.
6. **Which SFX use the JP stereo sweep** (port-2 bit 7).
7. **Name quality.** Opcode/routine names are descriptive labels derived from the code, not recovered symbols.
8. **CPU side.** Which port commands the 65816 sends (`$40–$7F` vs `$10–$7F` volume ranges) was not examined in either ROM.

---

## 11. Side findings

- **`docs/audio/spc-engine.md`** lists every handler address one higher than the table value (e.g. `$E0` → `$089E`; the table holds `$089D`). The SPC700 `RET` does not add 1, so the table values are correct.
- **`db-jp/blocks.json`**: part `spc_0292D1` spans 168657–176276 (7620 bytes), but the engine is only 2975 bytes (ends at 171632). The extractor emits 65816 code (`code_029E70` …) in the remainder of that span. For parity with the US part (168464–171490), the JP end could be tightened to 171632.
- **US `OpHandlerTable`** contains four zero entries (`$FB–$FE`).
- The US disassembly in [spc-disassembly.md](spc-disassembly.md) was **regenerated** with the rewritten `scripts/disasm-spc700.mjs` (corrected SPC700 operand order/format, symbolic labels, I/O register comments). Its content differs from the previous version throughout; review the diff before committing.

## 12. Tooling

| File | Purpose |
|------|---------|
| `scripts/disasm-spc700.mjs` | Disassembler CLI (`--variant us|jp`, `-o`, `--aram`) |
| `scripts/compare-spc-engines.mjs` | Alignment + comparison report |
| `scripts/lib/spc700.mjs` | SPC700 opcode table, decoder, upload parser, tracer |
| `scripts/lib/spc-variants.mjs` | Per-build layout (code range, tables, data regions) |
| `scripts/lib/spc-align.mjs` | Instruction-stream alignment |
| `scripts/lib/spc-names.mjs` | Opcode and routine labels |
