# COP family: Audio (music + SFX)

_Deep-audited ops: `[04]`, `[05]`, `[06]`, `[07]`, `[08]`, `[09]`, `[0A]`, `[19]`_ · _Source: [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)_

[← COP index](../README.md)

## Overview

Background music and sound effects reach the SPC700 through two layers: **thinker-backed music loaders** (`$04`, `$05`, `$19`) that run `SpcTransferMusicData` / `SpcFadeOutHandshake` asynchronously, and **SFX latch bytes** (`$06`–`$08`) written synchronously and sent to the SPC during NMI as one 16-bit word on `$2142`/`$2143` (`APUIO2` = channel 1, `APUIO3` = channel 2). Low-level **`WriteApuIo0` / `WriteApuIo1`** (`$0A` / `$09`) poke `$2140`/`$2141` directly for special cases (tempo tweaks, cutscene SPC commands).

## Shared state

- `$06F8` / `$06F9` — SFX queue bytes (channel 1 / channel 2); `NmiHandler` moves the 16-bit word to `$2142`/`$2143` and clears both bytes on **even** `$36` frames (odd frames write 0 to both ports; `musicTransitionState` = `$FFFF` skips the write); music-transfer completion paths also clear them
- `$06FA` — Music track ID (written during SPC handshake by thinker code in `hdma_dma_spc.asm`)
- `$06F2` — BGM id stored by the scene's `music` record (`SpcMusicLoadCmd`), also by `pyCD_jackal` (`$0F`) and the Memory Melody item (`$0E`). `StartMusic` / `FadeThenStartMusic` never write it (71 call sites), so after a scripted music change it still holds the scene's id
- `$2140`–`$2143` — SNES APU I/O ports (`APUIO0`–`APUIO3`)
- `$7F000A` (`chatPtr`) — Music bundle ID stored on the thinker spawned by `$04`/`$05`
- `AllocateActorAfter` — inserts a thinker after the calling actor ([`actor_pool.asm`](../../../extracted/system/engine/actor_pool.asm))
- `ActorPoolAllocator` / `MusicJingleActor` — pooled path for `$19`
- `SpcTransferMusicData` / `SpcFadeOutHandshake` — thinker entry points in `hdma_dma_spc.asm`

## Family notes

- Music ops **return immediately** (`RTI`); the spawned thinker owns the multi-frame `$F0` / `$F1` APU handshake and block upload.
- `$05` differs from `$04` only in the thinker entry: **`SpcFadeOutHandshake`** first sends **`$F1`** on `APUIO0` (the SPC engine's own fade-out command; the fade runs inside the SPC, not in 65816 code), waits for the echo, sends **`$01`**, and enters the same transfer path as `$04` once `APUIO0` reads zero. The fade is audible: the SPC's master volume falls from `$53` to 0 over about 335 frames, then its fade-end code runs `CmdStop`, which writes 0 to `APUIO0`; only then does the thinker send `$F0`. The fade-out leg lasts about 340 frames (341 measured); the thinker reads the zero when it next runs, so a dialogue wait that blocks the main loop delays the `$F0` further (541 frames after the `$F1` in the scene `$58` run). The `$01` has no effect, because the SPC's last-command byte already holds `$01`.
- SFX ops are **single-store** handlers; they do not wait for the SPC to acknowledge.
- `$08` writes a **16-bit word** to `$06F8`, filling both latch bytes in one instruction (typical pattern `#$0505` = ch1 `#$05`, ch2 `#$05`).
- `$19` combines music start with dialogue; prefer the pool + `MusicJingleActor` path, with an **inline `DialogStringRenderer` fallback** when the pool is full.
- **Music ids.** `StartMusic` / `FadeThenStartMusic` store the operand in `chatPtr` → `$06FA`; `LoadMusicFromTransitionState` reads `music_pointer_array` entry **id − 1** (`music_pointer_array-3 + 3*id`). Id 0 never indexes the table: it appears only in the scene `$FA` `music` record (`bgm_restart` loaded from the script pointer, port 0 = `$00`), and no COP call uses `#00` (71 `StartMusic` / `FadeThenStartMusic` call sites, all immediate). Ids `$0D` and `$17` (both `bgm_lively_city` in the table) have no `StartMusic` call site. `MusicAndText` and `ChestOpeningActor` pass `$26 + 1`, so `#17` plays id `$18`, the chest fanfare `bgm_important_item` (measured: the second upload in a chest scene is that file).
- **Hit sound.** `ApplyPlayerHitstun` plays `COP [PlaySoundCh2] ( #07 )` on both exits, with no read of `characterForm` (static; run only with Will, no hit landed as Freedan or Shadow).
- **Camera shake.** `CameraShakeActor` plays `PlaySoundCh2 #15` on **every** tick of its 61-tick life (`$26` = `$3C`, no `SetEntryHere`), not once; measured 61 plays.
- `$09`/`$0A` bypass queues — use sparingly; many engine sites use `$7F` / `$01` on `$2140` as SPC command bytes during cutscenes.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `04` | `StartMusic` | 57 | `Byte` | `StartMusic` | Continue |
| `05` | `FadeThenStartMusic` | 14 | `Byte` | `FadeThenStartMusic` | Continue |
| `06` | `PlaySoundCh2` | 92 | `Byte` | `PlaySoundCh2` | Continue |
| `07` | `PlaySoundCh1` | 244 | `Byte` | `PlaySoundCh1` | Continue |
| `08` | `PlaySoundBoth` | 72 | `Word` | `PlaySoundBoth` | Continue |
| `09` | `WriteApuIo1` | 4 | `Byte` | `WriteApuIo1` | Continue |
| `0A` | `WriteApuIo0` | 7 | `Byte` | `WriteApuIo0` | Continue |
| `19` | `MusicAndText` | 22 | `Byte`, `@DialogString` | `MusicAndText` | Continue (thinker) / block (fallback) |

**Family call-site total:** 512

## Opcodes

#### COP [04] — `StartMusic` (queue background music)

- **Preferred name:** `StartMusic`
- **Aliases:** (legacy copdef name matches)
- **Handler:** `StartMusic` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 57

##### What it does

Allocates a **thinker actor** immediately after the caller via `AllocateActorAfter`, configures it for asynchronous SPC music load, stores the **music bundle ID** in the thinker’s `$7F000A`, and returns without waiting for audio.

```asm
StartMusic {
    TYX 
    PHX
    JSR $&actor_pool.AllocateActorAfter
    TYX 
    LDA #$&hdma_dma_spc.SpcTransferMusicData
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcTransferMusicData
    STA $0002, X
    LDA $0012, X
    ORA #$1000            ; Thinker active
    STA $0012, X
    LDA $0010, X
    AND #$EFFF            ; Clear render flag $0800
    STA $0010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X       ; Music ID → $7F000A
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}
```

The thinker runs `SpcTransferMusicData`, which performs the `$F0` stop handshake, DMAs bundle data to the SPC, and clears SFX queue state when finished (see `hdma_dma_spc.asm`). If allocation fails silently (no slot), the handler still advances the script PC — **fail-soft**.

##### How it is used

Boss and set-piece BGM, area themes, and cutscene stingers. Often paired with `WaitByte` / `WaitWord` for timing, not with a spin on music state.

```asm
COP [StartMusic] ( #10 )          ; babel_tower/comet_lair/sE8_dark_gaia.asm:89
COP [StartMusic] ( #0F )          ; incan_ruins/ir29_castoth.asm:195 — battle theme
COP [StartMusic] ( #14 )          ; ending/ending_credits/sF7_credits.asm:92
COP [StartMusic] ( #1B )          ; incan_ruins/incan_ruins_entrance/ir1C_kara.asm:29
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte MusicId` — index into the game’s music bundle table (1-based in script literals) |
| WRAM | Music ID on thinker `$7F000A`; transfer state in `musicTransitionState` (engine) |
| Async | Yes — script continues; SPC load runs on thinker + NMI |
| Pairs with | `$05` is the variant whose thinker sends the SPC fade-out request (`$F1`) first; `$19` when dialogue must accompany the same track |

---

#### COP [05] — `FadeThenStartMusic` (fade, then queue music)

- **Preferred name:** `FadeThenStartMusic`
- **Handler:** `FadeThenStartMusic` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 14

##### What it does

Same allocation and flag setup as `[04]`, but the thinker entry is **`SpcFadeOutHandshake`** instead of `SpcTransferMusicData`. That path sends **`$F1`** on `APUIO0` (the SPC engine's `CmdFadeOut`), waits for the echo, sends **`$01`**, and falls into `SpcTransferMusicData` (the standard `$F0` transfer used by `[04]`) when `APUIO0` then reads zero; otherwise it yields and retries.

Measured on the US ROM (scene change with `FadeThenStartMusic #02`, SPC-side trace): `$F1` is dispatched, the master volume steps `$53` → 0 about every 4 frames (about 335 frames), the SPC's fade-end code calls `CmdStop` (master and echo volume 0, `FLG` `$20`, `EON` 0), which writes 0 to `APUIO0` 341 frames after the `$F1`; the thinker then sends `$F0` and the rest of the standard transfer when it reads that zero (frame 1018 in this run, because the main loop sat in a dialogue wait from frame 776 to 1017 and the thinker did not run; 959 versus the zero at 767 in the shipped build). `$F0` is the SPC's stop command, not a ready signal. In the one `GaiaThenRest` run (track `#0E`) the `$F1` echo never arrived (`APUIO0` kept reading `$01`), so the handshake looped for 1,744 frames and track `$0E` was never uploaded; the cause is open.

```asm
FadeThenStartMusic {
    ; … AllocateActorAfter + flags identical to StartMusic …
    LDA #$&hdma_dma_spc.SpcFadeOutHandshake
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcFadeOutHandshake
    STA $0002, X
    ; … read MusicId → $chatPtr, RTI …
}
```

##### How it is used

Called from the ending and epilogue scripts and from the Castoth transformation scene (call sites below). The fade itself is the SPC engine's and is audible (about 335 frames) before the next music loads.

```asm
COP [FadeThenStartMusic] ( #14 )  ; ending/ending_new_babel/s89_new_babel.asm:39
COP [FadeThenStartMusic] ( #13 )  ; ending/ending_comet/sE5_epilogue.asm:64
COP [FadeThenStartMusic] ( #1B )  ; incan_ruins/castoth_lair/ir29_transform.asm:35
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte MusicId` — same encoding as `[04]` |
| Diff vs `[04]` | Thinker entry `SpcFadeOutHandshake` → `$F1` before shared loader |
| Outcome | Continue (async) |

---

#### COP [06] — `PlaySoundCh2` (queue SFX on channel 2)

- **Preferred name:** `PlaySoundCh2`
- **Handler:** `PlaySoundCh2` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 92

##### What it does

Reads one byte and stores it in **`$06F9`** (`sfxQueueCh2`). The 8-bit store targets the **high byte** of the 16-bit latch at `$06F8` (65816 `STA $06F9` in 8-bit mode updates `$06F9` only).

```asm
PlaySoundCh2 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh2      ; $06F9
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}
```

`NmiHandler` sends the queued byte on **`$2143`** (`APUIO3`, the high byte of the 16-bit word written to `$2142`) on even frames, and clears it; odd frames write 0 to the port. The drain is skipped while `musicTransitionState` = `$FFFF`.

##### How it is used

UI feedback (diary menu cursor moves), combat impact sounds on channel 2, and paired cues with `[07]`.

```asm
COP [PlaySoundCh2] ( #10 )        ; system/diary_menu/sFA_diary_menu.asm:194 — cursor
COP [PlaySoundCh2] ( #11 )        ; system/diary_menu/sFA_diary_menu.asm:231 — confirm
COP [PlaySoundCh2] ( #2C )        ; babel_tower/comet_lair/sE8_dark_gaia.asm:881
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte SoundId` — SPC effect id sent on `$2143` (`APUIO3`) |
| WRAM | `$06F9` |
| Latency | Up to 2 frames until the next even-frame NMI drain (skipped while `musicTransitionState` = `$FFFF`) |
| Outcome | Continue |

---

#### COP [07] — `PlaySoundCh1` (queue SFX on channel 1)

- **Preferred name:** `PlaySoundCh1`
- **Handler:** `PlaySoundCh1` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 244

##### What it does

Same shape as `[06]`, but stores to **`$06F8`** (`sfxQueueCh1`), the low byte of the word that `NmiHandler` writes to **`$2142`** (`APUIO2`).

```asm
PlaySoundCh1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh1      ; $06F8
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}
```

Most common “play a sound” COP in the corpus — dialog blips, footsteps, attack cues, and map interactions.

##### How it is used

```asm
COP [PlaySoundCh1] ( #20 )        ; babel_tower/comet_lair/sE8_dark_gaia.asm:301
COP [PlaySoundCh1] ( #06 )        ; babel_tower/comet_lair/sE8_dark_gaia.asm:412 — repeated tick SFX
COP [PlaySoundCh1] ( #13 )        ; typical dialog confirm (many NPC scripts after PrintDialogString)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte SoundId` |
| WRAM | `$06F8` |
| Note | `DialogStringRenderer` may also `STA $06F8` per-character when `$D2 SetSfx` is used in strings |
| Outcome | Continue |

---

#### COP [08] — `PlaySoundBoth` (queue both SFX channels)

- **Preferred name:** `PlaySoundBoth`
- **Handler:** `PlaySoundBoth` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 72

##### What it does

Consumes a **word** operand and stores it 16-bit to **`$06F8`**, which fills **`$06F8` (low)** and **`$06F9` (high)** in one write.

```asm
PlaySoundBoth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $sfxQueueCh1      ; Word → $06F8/$06F9
    LDA $0A
    STA $02, S
    RTI 
}
```

Authoring convention: **`#$LLHH`** where low byte = channel 1 id, high byte = channel 2 id (e.g. `#$0606` plays `#$06` on both).

##### How it is used

Symmetric stereo-ish cues, trap rumble, and attack wind-up sounds that need both ports populated before the next NMI drain.

```asm
COP [PlaySoundBoth] ( #$0606 )    ; pyramid/pyD2_haunt.asm:223
COP [PlaySoundBoth] ( #$2323 )    ; mu/mu_vampire_lair/mu67_vampires.asm:485
COP [PlaySoundBoth] ( #$0E0E )    ; edward_castle/aqueduct_hall/ec0F_rusty_switch.asm:44
COP [PlaySoundBoth] ( #$2C2C )    ; incan_ruins/ceiling_trap_room/ir28_ceiling_trap_trigger.asm:34
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Word` — low byte → `$06F8`, high byte → `$06F9` |
| Alternative | Two `[07]`/`[06]` ops in sequence if ids differ |
| Outcome | Continue |

---

#### COP [09] — `WriteApuIo1` (direct `$2141` write)

- **Preferred name:** `WriteApuIo1`
- **Handler:** `WriteApuIo1` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 4

##### What it does

Immediate **`STA $2141`** with no handshake or queue — raw access to APU port 1.

```asm
WriteApuIo1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}
```

During SPC block upload, engine firmware also uses `$2141` as a **transfer phase flag** (`spc_transfer.asm`); this COP exposes the same port to scripts.

##### How it is used

Rare — minigame tempo / mode tweaks and a handful of cutscene actors.

```asm
COP [WriteApuIo1] ( #08 )         ; watermia/watermia/wa78_glass_game.asm:64
COP [WriteApuIo1] ( #0A )         ; sky_garden/garden_descent/sp58_descent_cutscene.asm:65
COP [WriteApuIo1] ( #0A )         ; gold_ship/ship_wreck_interior/gs2D_lily.asm:95
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte` — value written to `$2141` |
| Risk | Can desync SPC state if not matched to firmware expectations |
| Outcome | Continue |

---

#### COP [0A] — `WriteApuIo0` (direct `$2140` write)

- **Preferred name:** `WriteApuIo0`
- **Handler:** `WriteApuIo0` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 7

##### What it does

Immediate **`STA $2140`** — primary SNES→SPC command port.

```asm
WriteApuIo0 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO0
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}
```

Common script values **`#$7F`** and **`#$01`** mirror engine handshake bytes used around dialogue mutes and resume.

##### How it is used

```asm
COP [WriteApuIo0] ( #7F )
COP [WriteApuIo0] ( #01 )         ; dao/dao/daC3_jackal_girl.asm:24-26 — SPC command bracketing text
COP [WriteApuIo0] ( #00 )         ; unused/unused_kara_dialog.asm:30 — music test prototype
COP [WriteApuIo0] ( #01 )         ; native_village/native_village/nvAC_hamlet.asm:56
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte` — value written to `$2140` |
| Outcome | Continue |

---

#### COP [19] — `MusicAndText` (start music + show dialogue)

- **Preferred name:** `MusicAndText`
- **Handler:** `MusicAndText` @ [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)
- **Usage count:** 22

##### What it does

**Primary path:** `ActorPoolAllocator` obtains a free actor, links it into the thinker list, **`CopyActorState`** from the parent, sets entry **`MusicJingleActor`**, and stores three operands in the new actor:

- `$0026` — track ID (byte)
- `$0020` — text pointer (word)
- `$0022` — text bank (byte)

Then **`RTI`** — music and text run on the pooled actor.

**Fallback path** (`BCS` after allocator): inline **`DialogStringRenderer`** with temporary DBR, **`joypadMaskStd` cleared**, one **`UpdateFrameRender`**, then restore joypad and clear **`displayModeFlags` bit `$80`**.

```asm
MusicAndText {
    TYX 
    PHD 
    LDA #$0000
    TCD 
    JSL $@actor_pool.ActorPoolAllocator
    BCS loc_008836        ; pool full → inline dialog
    ; … link actor, CopyActorState, MusicJingleActor, store track/text/bank …
    RTI 

  loc_008836:
    ; … read operands, mask joypad, UpdateFrameRender, DialogStringRenderer …
    RTI 
}
```

##### How it is used

NPC reward lines that also trigger a **fanfare / jingle track** (`#17` is common) without a separate `[04]` + `[BF]` sequence.

```asm
COP [MusicAndText] ( #17, @dialogstring_0AA7EF )  ; diamond_mine/mine_main/dm3F_laborer.asm:122
COP [MusicAndText] ( #17, @dialogstring_0AA85C )  ; diamond_mine/mine_main/dm3F_laborer.asm:138
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | `Byte MusicId`, `@DialogString` (far text: word + bank per copdef) |
| Thinker fields | Track `$0026`, pointer `$0020`, bank `$0022` on `MusicJingleActor` |
| Fallback | Synchronous wide-string render; blocks caller until string completes |
| Outcome | Continue when pooled; blocking render on pool exhaustion |

##### Family summary

| Op | Layer | Async | Target |
|----|-------|-------|--------|
| `[04]`/`[05]` | Music queue | Yes | Thinker → SPC bundles |
| `[06]`–`[08]` | SFX latch | No (store only) | `$06F8`/`$06F9` → NMI (even frames) → `$2142`/`$2143` |
| `[09]`/`[0A]` | Raw ports | No | `$2141` / `$2140` |
| `[19]` | Music + text | Yes (preferred) | `MusicJingleActor` + `@DialogString` |
