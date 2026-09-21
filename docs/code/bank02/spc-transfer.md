# Bank $02 — SPC700 Music Transfer Protocol

*Part of the [Bank $02 Documentation Suite](README.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)
**ASM source:** [`spc_transfer.asm`](../../../extracted/system/engine/spc_transfer.asm) (block: `spc_transfer`)

This document was split from the former `scene-engine.md` monolith (now [scene-script.md](scene-script.md) + this file). It covers the SPC700 upload path that streams compressed music data to the embedded sound engine. For the scene script interpreter and graphics loading commands, see [scene-script.md](scene-script.md).

---

## spc_transfer.asm

| Address | Name | Description |
|---------|------|-------------|
| `$028B6D` | SpcMusicLoadCmd | Command `$11` handler — the music load orchestrator. |
| `$02908E` | SpcLoadBuiltinEngine | Loads the embedded SPC700 sound engine binary (`spc_sound_engine`) to APU RAM at cold start. |
| `$02909B` | SpcBlockTransfer | Full SPC700 multi-block upload routine. |
| `$02919B` | SpcIplHandshake | Initial IPL (Initial Program Load) upload — the first-stage SPC700 bootstrap transfer. |
| `$029210` | spc_sound_engine | Embedded SPC700 sound engine binary uploaded to APU RAM at startup via `SpcLoadBuiltinEngine`. |

### SPC Transfer Protocol

Communication uses APU I/O ports `$2140`–`$2143`:

1. **IPL handshake** (`SpcIplHandshake`) — CPU waits for `$BBAA` on `$2140`, sends `$CC`, then streams IPL bootstrap bytes with alternating acknowledge bytes.
2. **Multi-block upload** (`SpcBlockTransfer`) — After IPL, sends `$FF`/`$CC` start sequence, waits for `$BBAA`, then for each block: read 4-byte header (size + destination), stream data through `$2140` with `$C5`-based acknowledge protocol, send block-end marker.
3. **Timing** — `EnableNmiOnly` during upload prevents auto-joypad reads from interfering. Re-enables auto-joypad when `$0654 = $0F`.
4. **Music fade** — `SpcMusicLoadCmd` sends `$F2` (fade) then `$F0` (stop) if music is playing, waits `$1A` frames, then uploads new track data.

### SpcLoadBuiltinEngine

Loads the embedded SPC700 sound engine binary (`spc_sound_engine`) to APU RAM at cold start. Sets the transfer source pointer at `$46`/`$48` to the embedded binary address and invokes `SpcIplHandshake` to bootstrap the APU. Called once from `system_core.asm` during initialization before any scene music loads.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$46` ← address of `spc_sound_engine` |
| 2 | `$48` ← bank of `spc_sound_engine` |
| 3 | `JSR SpcIplHandshake` |
| 4 | Return |

**Source:**

```75:82:../../../extracted/system/engine/spc_transfer.asm
SpcLoadBuiltinEngine {
    LDX #$&spc_sound_engine
    STX $46
    LDA #$^spc_sound_engine
    STA $48
    JSR $&SpcIplHandshake
    RTL 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | Out | IPL transfer source pointer |
| `spc_sound_engine` | In | Embedded 3,026-byte APU driver |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `system_core.asm` | Cold-start caller |
| `SpcIplHandshake` | Bootstrap upload |
| `spc_sound_engine` | Binary payload |

### SpcMusicLoadCmd

Command `$11` handler — the music load orchestrator. Reads track ID to `$06F2`, cache key to `$06F4`, and a 3-byte source pointer via `LoadScriptPointer`. Fast-path: if cache key matches `$06F6`, returns immediately without touching the APU. On cache miss (`CheckSourceCacheHit` at slot `$0687`): waits `$1A` frames, fades/stops current music via `$2140` (`$F2` fade, `$F0` stop), waits for APU acknowledge, resets APU with `$FF` on `$2140`, uploads new data via `SpcBlockTransfer`, sets `$0D72` (music active flag), waits 3 frames, then sends play command (`$01`) or stop (`$00`) based on track ID.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read track ID, cache key, source pointer |
| 2 | If cache key = `$06F6`: return (fast skip) |
| 3 | Cache-check `$0687`; return if unchanged |
| 4 | Fade/stop current music; wait for APU idle |
| 5 | Reset APU; `SpcBlockTransfer` from `$46`/`$48` |
| 6 | Send play/stop command on `$2140` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06F2` | Out | Track ID (`$00` = stop) |
| `$06F4` | Out | Cache key |
| `$06F6` | In | Previous cache key for fast skip |
| `$0687` | Out | Music source cache slot |
| `$0D72` | Out | Music active flag |
| `$46`/`$48` | Out | Transfer source pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script_jump_table` | Entry `$11` |
| `SpcBlockTransfer` | Data upload |
| `SceneScriptNoMusic` | Bypasses this handler |
| `MusicTransitions.patch.asm` | External caller of `SpcBlockTransfer` |

### SpcBlockTransfer

Full SPC700 multi-block upload routine. Performs IPL handshake first, then enters the main transfer loop. Sends `$FF`/`$CC` start sequence on `$2140`, waits for `$BBAA` acknowledge, then for each data block reads a 4-byte header (2-byte size + 2-byte destination address) and streams bytes through `$2140`. Handles bank-crossing in the source data via `$4A`/`$4C` pointer arithmetic. Each byte is sent with an acknowledge wait loop. Block end is signaled via `$2140`/`$2141`/`$2142` with address and transfer-mode flag. `EnableNmiOnly` is called during each block transfer for timing isolation.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `SpcIplHandshake` |
| 2 | Send `$FF`/`$CC`; wait for `$BBAA` |
| 3 | Read 4-byte block header (size + dest addr) |
| 4 | Stream data bytes via `$2140` with ack protocol |
| 5 | Send block-end marker; repeat from step 3 |
| 6 | Exit when size = 0 |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | In | Source data pointer |
| `$2E`/`$28` | Out | Block size / dest address |
| `$2140`–`$2142` | Out | APU I/O ports |
| `$0654` | In | Boot state (`$0F` = re-enable joypad) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcMusicLoadCmd` | Music data upload |
| `SpcIplHandshake` | Initial handshake |
| `EnableNmiOnly` | Timing isolation |
| `MusicTransitions.patch.asm` | External caller |

### SpcIplHandshake

Initial IPL (Initial Program Load) upload — the first-stage SPC700 bootstrap transfer. Waits for the `$BBAA` signature on `$2140` (indicating the SPC is ready), sends `$CC` to begin, then streams bootstrap bytes from `[$46],Y` one at a time with alternating acknowledge values on `$2140`. After the bootstrap stream, reads the first block header (size + destination) and sends it via `$2141`/`$2142`. Calls `EnableNmiOnly` during the transfer. Returns when the bootstrap phase completes (signaled by the overflow flag from the `$7F`/`$80` address check in the source stream).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Wait for `$BBAA` on `$2140` |
| 2 | Send `$CC` to start bootstrap |
| 3 | Stream bytes from source with ack on `$2140` |
| 4 | Read block header; send addr to `$2141`/`$2142` |
| 5 | `EnableNmiOnly`; wait for completion |
| 6 | Return (or loop if more bootstrap data) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | In | Bootstrap source pointer |
| `$2140` | In/Out | Handshake port |
| `$2141`/`$2142` | Out | Block address ports |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcBlockTransfer` | Called at start of full transfer |
| `SpcLoadBuiltinEngine` | Boot-time caller |
| `EnableNmiOnly` | Timing control |

### spc_sound_engine

Embedded SPC700 sound engine binary uploaded to APU RAM at startup via `SpcLoadBuiltinEngine`. This is the resident music driver that runs on the SPC700 co-processor — it receives commands and data through the `$2140`–`$2143` I/O ports and manages BGM playback, sound effects, and fade transitions. The binary is stored as a single hex-encoded line in the ASM source. It occupies 3,026 bytes of ROM and is the largest single part in the combined scene/SPC block.

**Algorithm:**

N/A — embedded binary data, not executable 65816 code.

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| APU RAM | Out | Upload destination (via IPL) |
| `$2140`–`$2143` | In | Runtime command interface |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcLoadBuiltinEngine` | Uploads this binary at boot |
| `SpcMusicLoadCmd` | Sends music data to running engine |
| `SpcIplHandshake` | Bootstrap transfer mechanism |

## See Also

### Callers

| Function | Caller | Context |
|----------|--------|---------|
| `SpcLoadBuiltinEngine` | `system_core.asm` | Cold-start APU initialization |
| `SpcBlockTransfer` | `SpcMusicLoadCmd`, `MusicTransitions.patch.asm` | Music upload |
| `SpcMusicLoadCmd` | `scene_script_jump_table` entry `$11` | Scene script music load command |

### Dependencies

| Dependency | Role |
|------------|------|
| [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm) | `EnableNmiOnly`, `EnableNmiAndJoypad` — timing isolation during upload |
| [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) | `ReadScriptByte`, `LoadScriptPointer`, `CheckSourceCacheHit` — script operand parsing for command `$11` |

### Related Documentation

- [scene-script.md](scene-script.md) — Scene script interpreter; command `$11` dispatches to `SpcMusicLoadCmd`
- [hardware-and-init.md](hardware-and-init.md) — VBlank/joypad layer used during SPC transfers
- [README.md](README.md) — Full bank `$02` overview
- [bank00/system-core.md](../bank00/system-core.md) — Cold-start sequence calling `SpcLoadBuiltinEngine`

---
