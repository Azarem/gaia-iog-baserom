# Bank $02 — SPC700 Music Transfer Protocol

*Part of the [Bank $02 Documentation Suite](README.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**ASM sources:** [`spc_transfer.asm`](../../../extracted/system/engine/spc_transfer.asm) (block: `spc_transfer`), command `$11` handler [`SpcMusicLoadCmd`](../../../extracted/system/engine/scene_script.asm) in `scene_script.asm` (same bank, preceding ROM block)

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

This document covers the SPC700 upload routines in `spc_transfer.asm` and how scene script command `$11` invokes them. For the scene script interpreter and graphics commands, see [scene-script.md](scene-script.md).

---

## spc_transfer.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$028B6D` | SpcMusicLoadCmd | Scene opcode `$11` — in `scene_script.asm`, not `spc_transfer.asm` source file |
| `$02908E` | SpcLoadBuiltinEngine | Boot upload of `spc_sound_engine` via `SpcIplHandshake` |
| `$02909B` | SpcBlockTransfer | Music/sample stream: IPL session + `$FF` re-entry + sample-chunk session |
| `$02919B` | SpcIplHandshake | Shared IPL record protocol (`RTS` return) |
| `$029210` | spc_sound_engine | Embedded SPC700 binary (IPL records; 3,018-byte payload per asm header) |

ROM blocks (`db-us/blocks.json`): `scene_script` 164795–168078; `spc_transfer` 168078–171490. `SpcMusicLoadCmd` lies in the `scene_script` block; `SpcLoadBuiltinEngine` starts the `spc_transfer` block at `$02908E`.

### SPC Transfer Protocol

*Evidence: [ASM] + [XREF]*

Communication uses APU I/O ports `$2140`–`$2143` (`APUIO0`–`APUIO2` in these files).

**IPL record stream (`SpcIplHandshake`):**

1. Poll until `APUIO0`/`APUIO1` echo `$BBAA`.
2. For each record: read size word → `X`, destination word → `APUIO2`/`APUIO3`; `DisableNmiKeepJoypad`; `APUIO1` = 0 or 1 via `ROL` of “size > 0” carry; kick on `APUIO0` (first record uses `$CC`); wait for echo; if `worldReadyFlag` (`$0654`) = `$0F`, `EnableNmiAndJoypad`.
3. If overflow flag set (`ADC #$7F` after `ROL`), send data bytes: 16-bit writes to `APUIO0`/`APUIO1` (counter low, data high), waiting for counter echo between bytes.
4. Size word `$0000` ends the session; clears `APUIO2`; returns `RTS`.

**Music upload (`SpcBlockTransfer`):**

1. `SpcIplHandshake` on stream at `[$46]` (session 1 — song tables in ARAM).
2. Back up `Y` by 2; write `$FF` to `APUIO0`; seed counter `$30` with `$CC`; wait for `$BBAA`.
3. Session 2: read destination word into `$2E`, chunk count into `$28`, index bytes from stream; for each index (bit 7 = empty slot), locate sample in library `$C5:0000`, send via shared header/data handshake (`SpcSendHeader` / `SpcSendChunkData`); final size-0 record ends session 2; `RTL`.

**NMI gating:** `DisableNmiKeepJoypad` before each header/kick; `EnableNmiAndJoypad` only after kick echo when `worldReadyFlag` = `$0F` (at boot, NMI stays off through data bytes per file header).

**Scene music command (`SpcMusicLoadCmd`, scene_script.asm):** compares script group byte (`$06F4`) to `musicRoomGroup` (`$06F6`); on match, `CheckSourceCacheHit` at `$0687`; on miss, `WaitFrames(26)`, optional `$F2` + `WaitFrames(32)` when `$0D72` nonzero, `$F0` on `APUIO0` with poll until `$00`, `$FF`, `WaitFrames(2)` twice, `SpcBlockTransfer`, `$0D72=1`, `WaitFrames(3)`, then `APUIO0` = `$01` if `musicParentActor` (`$06F2`) nonzero else `$00`.

### SpcLoadBuiltinEngine

Sets `$46`/`$48` to `spc_sound_engine`, `JSR SpcIplHandshake`, `RTL`.

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `system_core.asm` `SystemInit` | `JSL SpcLoadBuiltinEngine` at cold start |
| `SpcIplHandshake` | Uploads IPL records in the blob |

### SpcMusicLoadCmd

*Evidence: [ASM] — routine body in `scene_script.asm`*

See scene-script command table and `SpcMusicLoadCmd` listing in [scene-script.md](scene-script.md). Operand bytes: `musicParentActor`, group byte → `$06F4`, then 3-byte pointer via `LoadScriptPointer`.

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06F2` | Out | `musicParentActor` from script (nonzero → `$01` play on `APUIO0` after load) |
| `$06F4` | Out | Script group byte compared to `musicRoomGroup` |
| `$06F6` | In | `musicRoomGroup` |
| `$0687` | RW | Source-pointer cache slot |
| `$0D72` | Out | Set to `$01` after successful transfer |
| `$46`/`$48` | Out | Pointer copied from `$3E`/`$40` for `SpcBlockTransfer` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script_jump_table` | Opcode `$11` |
| `SceneScriptNoMusic` | Skips 5 operand bytes when handler address matches |
| `LoadMusicFromTransitionState` | Other `SpcBlockTransfer` caller (file header) |

### SpcBlockTransfer

`PHP`/`PHY`; `JSR SpcIplHandshake`; session 2 loop as in protocol section. Uses `$28` (chunk count), `$2E`/`$2C` (destination/size), `$4A`/`$4C` (library pointer), `$30` (handshake counter). Returns `RTL`.

### SpcIplHandshake

Poll `$BBAA`, then `SpcSendRecord` loop until size-0 record. Returns `RTS` (used via `JSR` from `SpcLoadBuiltinEngine` and `SpcBlockTransfer`).

### spc_sound_engine

Embedded SPC700 data (`#CA0B…` line in asm). Not 65816 code. Asm header: one IPL record of `$0BCA` (3,018) bytes to ARAM `$0400`, plus terminator record (size 0, entry `$0400`). ROM part spans 168464–171490 (3,026 bytes including encoded record headers in the extraction).

## See Also

*Evidence: [XREF]*

### Callers

| Function | Caller | Context |
|----------|--------|---------|
| `SpcLoadBuiltinEngine` | `system_core.asm` | Cold-start APU init |
| `SpcBlockTransfer` | `SpcMusicLoadCmd`, `LoadMusicFromTransitionState` | Track/sample upload |
| `SpcMusicLoadCmd` | `scene_script_jump_table` `$11` | Scene script music |

### Dependencies

| Dependency | Role |
|------------|------|
| [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm) | `DisableNmiKeepJoypad`, `EnableNmiAndJoypad`, `WaitFrames` |
| [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) | `SpcMusicLoadCmd`, `LoadScriptPointer`, `CheckSourceCacheHit`, `ReadScriptByte` |

### Related Documentation

- [scene-script.md](scene-script.md) — interpreter and `$11` dispatch
- [hardware-and-init.md](hardware-and-init.md) — VBlank/joypad helpers
- [README.md](README.md) — Bank `$02` overview
- [bank00/system-core.md](../bank00/system-core.md) — `SystemInit` → `SpcLoadBuiltinEngine`
