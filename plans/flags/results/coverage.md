# FL41 coverage matrix of the flag array `$0A00-$0AB3`

Generated read-only by `node plans/flags/tools/fl41_report.mjs coverage` (2026-11-04). Inputs: `plans/flags/inventory.json` (FL01 build, 909 asm files, 818 tagged, 1,693 literal COP sites, 18 scene-meta gates, 57 helper calls, 17 traces, 674 direct accesses), the registry fragments FL10-FL40 merged in order (`fl32_lib.mjs loadRegistry`), the queue files FL10-FL40 (337 items), `extracted/tables/*.asm` (event block table, scene actors) and `db-us/groups.json`. `db-us/flags.json` is still the empty skeleton, so "named record" means a record in the merged fragment chain, not a shipped one. Bits are global flag indices `$0000-$059F` (1,440 bits); byte = `$0A00 + (index >> 3)`, bit = `index & 7`. The tables name the bits by their hex index. The one-line status rule per bit is in section 1; the per-bit rows are in the appendix (section 9).

## 1. How to read this file

Every bit has one **primary status** (the FL41 vocabulary, precedence top to bottom) and two detail axes.

| Primary status | Rule |
|---|---|
| overlaps inventory/ability/other state | the byte is not flag storage (`$0AA4-$0AB3` state words), or it is an ability-bitmask bit (`$0510-$051F`) that has no named record |
| named record | at least one non-row meaning with a name in the merged registry |
| scene row only | only `level: "row"` meanings (no bit has this status; the scene-level version is in section 5) |
| literal COP both ways, no record | set and tested by literal COP, no record (added to the vocabulary: the bit `$0138`) |
| helper-only (no literal COP) | reached by a helper trace only, no record |
| table-only | reached through a data table or the event-block scan row, no literal COP, no record |
| set-only / test-only | literal COP sets (or only tests) the bit, or an engine scan / dynamic helper only reads it; no record; no other half found |
| referenced by a direct read | only a direct-address access reaches it (`LDA $0A9F` tomb mask) |
| unreferenced | none of the searches S1-S9 finds a use; section 4.9 names them per range |

**Detail axes.** *doc*: record / proposal / table-row / none. *ref*: `both`, `set-only` and `test-only` (literal COP), `gate-only`, `helper-only`, `helper+direct`, `table-only`, `direct-only`, `debug-only`, `unreferenced`, `not-a-flag`. A `test-only` ref with no literal COP means a dynamic reader (the event-block scan or `TestFlag_0300(sceneCurrent)`); the tag in the appendix says which.

**Searches (the proof behind "unreferenced").**

| id | Search | Result |
|---|---|---|
| S1 | literal COP operands: `inventory.json` `sites` kind `cop` (1,693 sites, 284 distinct indices); cross-checked by `fl41_romscan.mjs`, a ROM byte scan of `02 <CC-D3> <operands>` (2,018 byte matches, 1,693 equal to inventory sites, 325 not: 22 mid-instruction operand bytes and 303 inside data regions, none a code site) | indices in section 4 |
| S2 | scene-meta gates: `branch < flag, label >` in `tables/scene_meta.asm` (18 lines, 9 distinct indices, all literal; `SceneCmd_Branch` reads the operand with `ReadScriptByte`, so it reaches `$00-$FF` only) | 18 of 18 decoded |
| S3 | helper call sites: 57 in `inventory.json` `helper_calls`, matching an independent label-name scan (`rg` of every `flag_helpers` entry), and no call by numeric address (`rg` of `JSL/JSR/JML/JMP/PEA $B0xx-$B4xx` and `$80Bxxx` in `extracted/`: 0 matches); 17 traces with candidate index sets | `unresolved_dynamic_helper_inputs` = [] |
| S4 | direct accesses to bytes `$0A00-$0AB3`: 674 rows in `direct_accesses` (flag region rows: `$0A00` 13, `$0A01` 3, `$0A1F` 4, `$0A20` 1, `$0A80` 6, `$0A9F` 1, `$0AA2` 31, then the state words) | bytes with no row: every byte not listed here |
| S5 | event-block table (158 rows) and the `ApplyAllEventBlocks` scan of `$0A20-$0A3F` (all 256 bits; `event_blocks.asm:81 {172529}`) | D3 |
| S6 | kill-flag spawn rows: enemy-spawn rows of `tables/scene_actors.asm` (operand 6 = enemy number); `CheckEnemyDefeatedFlag`; `ClearAllWramFlags` | D6 |
| S7 | data tables that feed helpers: `scene_chest_table` (46 rows, 7-bit flag), `enemy_clear_reward_table` (256 bytes, 87 nonzero), boss `boss-reward-range` rows (6 matched), `statue-reward` rows, hidden red jewel actor parameters | D4, D5, D7 |
| S8 | numeric-address helper calls | none (see S3) |
| S9 | the registry: 912 meanings in FL10-FL40 and their `_no_use`, `_block_only` and `_no_use_range` notes | per-range notes below |

## 2. Summary

### 2.1 Primary status per domain

| Domain | index range | bytes | named record | scene row only | helper-only | table-only | set-only | test-only | direct read | both, no record | unreferenced | overlaps | total |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| D1 scene scratch | `$0000-$000F` | `$0A00-0A01` | 16 | . | . | . | . | . | . | . | . | . | 16 |
| D2 story | `$0010-$00FF` | `$0A02-0A1F` | 211 | . | . | . | . | 1 | . | . | 28 | . | 240 |
| D3 event triggers | `$0100-$01FF` | `$0A20-0A3F` | 102 | . | . | 54 | 1 | 98 | . | 1 | . | . | 256 |
| D4 chests/jewels | `$0200-$02FF` | `$0A40-0A5F` | 62 | . | . | . | . | . | . | . | 194 | . | 256 |
| D5 scene reward | `$0300-$03FF` | `$0A60-0A7F` | 87 | . | . | . | . | 142 | . | . | 27 | . | 256 |
| D6 kill flags | `$0400-$04FF` | `$0A80-0A9F` | 192 | . | . | 61 | . | . | 1 | . | 2 | . | 256 |
| D7 boss reward | `$0500-$0507` | `$0AA0` | 5 | . | . | 1 | . | . | . | . | 2 | . | 8 |
| unassigned byte | `$0508-$050F` | `$0AA1` | . | . | . | . | . | . | . | . | 8 | . | 8 |
| D7 ability | `$0510-$051F` | `$0AA2-0AA3` | 8 | . | . | . | . | . | . | . | . | 8 | 16 |
| state words | `$0520-$059F` | `$0AA4-0AB3` | . | . | . | . | . | . | . | . | . | 128 | 128 |
| **total** | | | **683** | **0** | **0** | **116** | **1** | **241** | **1** | **1** | **261** | **136** | **1440** |

### 2.2 Reference axis and documentation axis

| ref | bits | | doc | bits |
|---|---:|---|---|---:|
| table-only | 478 | | record | 683 |
| unreferenced | 266 | | none | 637 |
| test-only | 250 | | table-row | 116 |
| both | 246 | | proposal | 4 |
| not-a-flag | 128 | |  |  |
| helper-only | 35 | |  |  |
| set-only | 28 | |  |  |
| helper+direct | 6 | |  |  |
| debug-only | 2 | |  |  |
| direct-only | 1 | |  |  |

Reading the table: 683 bits own a named record (D1 16, D2 211, D3 102, D4 62, D5 87, D6 192, D7 13). The 261 unreferenced bits are listed in section 4.9; every one of them is also covered by the runtime write census FL41-01 (section 8.4). `D5 test-only 142` are the scene-reward bits of scenes that have tier 0 in the table but are read anyway by `TestFlag_0300(sceneCurrent)` (section 7).

## 3. Per-byte summary (180 bytes)

Columns: R = named record, T = table-only, S/Tst = set-only / test-only, X = direct read, U = unreferenced, O = overlaps state; "both" = literal COP both ways without a record (`$0138`). Bytes with all eight bits in one status show one number.

| byte | indices | domain | R | T | S | Tst | X | both | U | O | records on the byte |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `$0A00` | `$0000-$0007` | D1 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A01` | `$0008-$000F` | D1 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A02` | `$0010-$0017` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A03` | `$0018-$001F` | D2 | 5 | . | . | . | . | . | 3 | . | bits 1,2,3,4,5 |
| `$0A04` | `$0020-$0027` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A05` | `$0028-$002F` | D2 | 6 | . | . | . | . | . | 2 | . | bits 1,2,3,5,6,7 |
| `$0A06` | `$0030-$0037` | D2 | 5 | . | . | . | . | . | 3 | . | bits 0,1,2,5,7 |
| `$0A07` | `$0038-$003F` | D2 | 6 | . | . | . | . | . | 2 | . | bits 2,3,4,5,6,7 |
| `$0A08` | `$0040-$0047` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,6,7 |
| `$0A09` | `$0048-$004F` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A0A` | `$0050-$0057` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,6,7 |
| `$0A0B` | `$0058-$005F` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,5,6 |
| `$0A0C` | `$0060-$0067` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A0D` | `$0068-$006F` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A0E` | `$0070-$0077` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A0F` | `$0078-$007F` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A10` | `$0080-$0087` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A11` | `$0088-$008F` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A12` | `$0090-$0097` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A13` | `$0098-$009F` | D2 | 5 | . | . | . | . | . | 3 | . | bits 0,1,5,6,7 |
| `$0A14` | `$00A0-$00A7` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A15` | `$00A8-$00AF` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A16` | `$00B0-$00B7` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A17` | `$00B8-$00BF` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,5,6,7 |
| `$0A18` | `$00C0-$00C7` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A19` | `$00C8-$00CF` | D2 | 2 | . | . | . | . | . | 6 | . | bits 0,7 |
| `$0A1A` | `$00D0-$00D7` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,6,7 |
| `$0A1B` | `$00D8-$00DF` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,3,4,5,6,7 |
| `$0A1C` | `$00E0-$00E7` | D2 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A1D` | `$00E8-$00EF` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,5,6 |
| `$0A1E` | `$00F0-$00F7` | D2 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,5,7 |
| `$0A1F` | `$00F8-$00FF` | D2 | 6 | . | . | 1 | . | . | 1 | . | bits 1,2,3,4,5,7 |
| `$0A20` | `$0100-$0107` | D3 | 6 | 2 | . | . | . | . | . | . | bits 1,2,3,4,5,6 |
| `$0A21` | `$0108-$010F` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,2,3,4,5,6,7 |
| `$0A22` | `$0110-$0117` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,2,3,4,5,6,7 |
| `$0A23` | `$0118-$011F` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,1,2,3,4,5,7 |
| `$0A24` | `$0120-$0127` | D3 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A25` | `$0128-$012F` | D3 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A26` | `$0130-$0137` | D3 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A27` | `$0138-$013F` | D3 | 6 | 1 | . | . | . | 1 | . | . | bits 1,2,3,5,6,7 |
| `$0A28` | `$0140-$0147` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,1,2,3,4,6,7 |
| `$0A29` | `$0148-$014F` | D3 | 7 | 1 | . | . | . | . | . | . | bits 1,2,3,4,5,6,7 |
| `$0A2A` | `$0150-$0157` | D3 | 4 | 4 | . | . | . | . | . | . | bits 0,1,2,3 |
| `$0A2B` | `$0158-$015F` | D3 | 2 | 6 | . | . | . | . | . | . | bits 1,7 |
| `$0A2C` | `$0160-$0167` | D3 | 1 | 7 | . | . | . | . | . | . | bits 7 |
| `$0A2D` | `$0168-$016F` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,2,3,4,5,6,7 |
| `$0A2E` | `$0170-$0177` | D3 | 7 | 1 | . | . | . | . | . | . | bits 0,1,3,4,5,6,7 |
| `$0A2F` | `$0178-$017F` | D3 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A30` | `$0180-$0187` | D3 | . | 7 | 1 | . | . | . | . | . | - |
| `$0A31` | `$0188-$018F` | D3 | . | 8 | . | . | . | . | . | . | - |
| `$0A32` | `$0190-$0197` | D3 | . | 8 | . | . | . | . | . | . | - |
| `$0A33` | `$0198-$019F` | D3 | 2 | 4 | . | 2 | . | . | . | . | bits 2,3 |
| `$0A34` | `$01A0-$01A7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A35` | `$01A8-$01AF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A36` | `$01B0-$01B7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A37` | `$01B8-$01BF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A38` | `$01C0-$01C7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A39` | `$01C8-$01CF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3A` | `$01D0-$01D7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3B` | `$01D8-$01DF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3C` | `$01E0-$01E7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3D` | `$01E8-$01EF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3E` | `$01F0-$01F7` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A3F` | `$01F8-$01FF` | D3 | . | . | . | 8 | . | . | . | . | - |
| `$0A40` | `$0200-$0207` | D4 | 7 | . | . | . | . | . | 1 | . | bits 1,2,3,4,5,6,7 |
| `$0A41` | `$0208-$020F` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A42` | `$0210-$0217` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A43` | `$0218-$021F` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A44` | `$0220-$0227` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A45` | `$0228-$022F` | D4 | 7 | . | . | . | . | . | 1 | . | bits 0,1,2,3,4,5,6 |
| `$0A46` | `$0230-$0237` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A47` | `$0238-$023F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A48` | `$0240-$0247` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A49` | `$0248-$024F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4A` | `$0250-$0257` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4B` | `$0258-$025F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4C` | `$0260-$0267` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4D` | `$0268-$026F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4E` | `$0270-$0277` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A4F` | `$0278-$027F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A50` | `$0280-$0287` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A51` | `$0288-$028F` | D4 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A52` | `$0290-$0297` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A53` | `$0298-$029F` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A54` | `$02A0-$02A7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A55` | `$02A8-$02AF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A56` | `$02B0-$02B7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A57` | `$02B8-$02BF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A58` | `$02C0-$02C7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A59` | `$02C8-$02CF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5A` | `$02D0-$02D7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5B` | `$02D8-$02DF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5C` | `$02E0-$02E7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5D` | `$02E8-$02EF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5E` | `$02F0-$02F7` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A5F` | `$02F8-$02FF` | D4 | . | . | . | . | . | . | 8 | . | - |
| `$0A60` | `$0300-$0307` | D5 | . | . | . | 7 | . | . | 1 | . | - |
| `$0A61` | `$0308-$030F` | D5 | 4 | . | . | 3 | . | . | 1 | . | bits 4,5,6,7 |
| `$0A62` | `$0310-$0317` | D5 | 1 | . | . | 6 | . | . | 1 | . | bits 2 |
| `$0A63` | `$0318-$031F` | D5 | 1 | . | . | 7 | . | . | . | . | bits 5 |
| `$0A64` | `$0320-$0327` | D5 | 7 | . | . | 1 | . | . | . | . | bits 0,1,2,3,5,6,7 |
| `$0A65` | `$0328-$032F` | D5 | 1 | . | . | 7 | . | . | . | . | bits 0 |
| `$0A66` | `$0330-$0337` | D5 | . | . | . | 8 | . | . | . | . | - |
| `$0A67` | `$0338-$033F` | D5 | 3 | . | . | 5 | . | . | . | . | bits 5,6,7 |
| `$0A68` | `$0340-$0347` | D5 | 4 | . | . | 4 | . | . | . | . | bits 0,1,5,6 |
| `$0A69` | `$0348-$034F` | D5 | 3 | . | . | 3 | . | . | 2 | . | bits 5,6,7 |
| `$0A6A` | `$0350-$0357` | D5 | 5 | . | . | 2 | . | . | 1 | . | bits 0,1,2,3,4 |
| `$0A6B` | `$0358-$035F` | D5 | 1 | . | . | 7 | . | . | . | . | bits 7 |
| `$0A6C` | `$0360-$0367` | D5 | 5 | . | . | 3 | . | . | . | . | bits 0,1,2,4,5 |
| `$0A6D` | `$0368-$036F` | D5 | 3 | . | . | 5 | . | . | . | . | bits 5,6,7 |
| `$0A6E` | `$0370-$0377` | D5 | 3 | . | . | 3 | . | . | 2 | . | bits 0,1,2 |
| `$0A6F` | `$0378-$037F` | D5 | . | . | . | 8 | . | . | . | . | - |
| `$0A70` | `$0380-$0387` | D5 | 6 | . | . | . | . | . | 2 | . | bits 2,3,4,5,6,7 |
| `$0A71` | `$0388-$038F` | D5 | 1 | . | . | 7 | . | . | . | . | bits 0 |
| `$0A72` | `$0390-$0397` | D5 | . | . | . | 8 | . | . | . | . | - |
| `$0A73` | `$0398-$039F` | D5 | . | . | . | 6 | . | . | 2 | . | - |
| `$0A74` | `$03A0-$03A7` | D5 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A75` | `$03A8-$03AF` | D5 | 1 | . | . | 4 | . | . | 3 | . | bits 0 |
| `$0A76` | `$03B0-$03B7` | D5 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A77` | `$03B8-$03BF` | D5 | 7 | . | . | 1 | . | . | . | . | bits 0,1,2,3,4,5,6 |
| `$0A78` | `$03C0-$03C7` | D5 | . | . | . | 6 | . | . | 2 | . | - |
| `$0A79` | `$03C8-$03CF` | D5 | 4 | . | . | 2 | . | . | 2 | . | bits 4,5,6,7 |
| `$0A7A` | `$03D0-$03D7` | D5 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A7B` | `$03D8-$03DF` | D5 | 3 | . | . | 5 | . | . | . | . | bits 0,1,3 |
| `$0A7C` | `$03E0-$03E7` | D5 | . | . | . | 8 | . | . | . | . | - |
| `$0A7D` | `$03E8-$03EF` | D5 | . | . | . | 3 | . | . | 5 | . | - |
| `$0A7E` | `$03F0-$03F7` | D5 | . | . | . | 7 | . | . | 1 | . | - |
| `$0A7F` | `$03F8-$03FF` | D5 | . | . | . | 6 | . | . | 2 | . | - |
| `$0A80` | `$0400-$0407` | D6 | 7 | . | . | . | . | . | 1 | . | bits 1,2,3,4,5,6,7 |
| `$0A81` | `$0408-$040F` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A82` | `$0410-$0417` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A83` | `$0418-$041F` | D6 | 7 | 1 | . | . | . | . | . | . | bits 0,1,2,3,4,5,6 |
| `$0A84` | `$0420-$0427` | D6 | 7 | 1 | . | . | . | . | . | . | bits 0,1,2,3,4,5,6 |
| `$0A85` | `$0428-$042F` | D6 | . | 8 | . | . | . | . | . | . | - |
| `$0A86` | `$0430-$0437` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A87` | `$0438-$043F` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A88` | `$0440-$0447` | D6 | 6 | 2 | . | . | . | . | . | . | bits 1,2,3,4,5,6 |
| `$0A89` | `$0448-$044F` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A8A` | `$0450-$0457` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A8B` | `$0458-$045F` | D6 | 2 | 6 | . | . | . | . | . | . | bits 0,1 |
| `$0A8C` | `$0460-$0467` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A8D` | `$0468-$046F` | D6 | 6 | 2 | . | . | . | . | . | . | bits 0,1,2,3,4,5 |
| `$0A8E` | `$0470-$0477` | D6 | . | 8 | . | . | . | . | . | . | - |
| `$0A8F` | `$0478-$047F` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A90` | `$0480-$0487` | D6 | 2 | 6 | . | . | . | . | . | . | bits 0,1 |
| `$0A91` | `$0488-$048F` | D6 | 1 | 7 | . | . | . | . | . | . | bits 7 |
| `$0A92` | `$0490-$0497` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A93` | `$0498-$049F` | D6 | 6 | 2 | . | . | . | . | . | . | bits 0,1,2,3,4,5 |
| `$0A94` | `$04A0-$04A7` | D6 | 5 | 3 | . | . | . | . | . | . | bits 3,4,5,6,7 |
| `$0A95` | `$04A8-$04AF` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A96` | `$04B0-$04B7` | D6 | 5 | 3 | . | . | . | . | . | . | bits 0,2,3,4,5 |
| `$0A97` | `$04B8-$04BF` | D6 | 4 | 4 | . | . | . | . | . | . | bits 2,3,6,7 |
| `$0A98` | `$04C0-$04C7` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A99` | `$04C8-$04CF` | D6 | 6 | 2 | . | . | . | . | . | . | bits 0,1,2,3,4,5 |
| `$0A9A` | `$04D0-$04D7` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A9B` | `$04D8-$04DF` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A9C` | `$04E0-$04E7` | D6 | 8 | . | . | . | . | . | . | . | bits 0,1,2,3,4,5,6,7 |
| `$0A9D` | `$04E8-$04EF` | D6 | 4 | 4 | . | . | . | . | . | . | bits 0,1,2,3 |
| `$0A9E` | `$04F0-$04F7` | D6 | 5 | 2 | . | . | . | . | 1 | . | bits 0,1,2,3,4 |
| `$0A9F` | `$04F8-$04FF` | D6 | 7 | . | . | . | 1 | . | . | . | bits 0,1,2,3,4,5,6 |
| `$0AA0` | `$0500-$0507` | D7b | 5 | 1 | . | . | . | . | 2 | . | bits 0,1,2,3,4 |
| `$0AA1` | `$0508-$050F` | U | . | . | . | . | . | . | 8 | . | - |
| `$0AA2` | `$0510-$0517` | D7a | 5 | . | . | . | . | . | . | 3 | bits 0,1,4,5,6 |
| `$0AA3` | `$0518-$051F` | D7a | 3 | . | . | . | . | . | . | 5 | bits 0,1,2 |
| `$0AA4` | `$0520-$0527` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AA5` | `$0528-$052F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AA6` | `$0530-$0537` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AA7` | `$0538-$053F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AA8` | `$0540-$0547` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AA9` | `$0548-$054F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAA` | `$0550-$0557` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAB` | `$0558-$055F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAC` | `$0560-$0567` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAD` | `$0568-$056F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAE` | `$0570-$0577` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AAF` | `$0578-$057F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AB0` | `$0580-$0587` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AB1` | `$0588-$058F` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AB2` | `$0590-$0597` | S | . | . | . | . | . | . | . | 8 | - |
| `$0AB3` | `$0598-$059F` | S | . | . | . | . | . | . | . | 8 | - |

## 4. Lists per status

### 4.1 Named record

683 bits: $0000-$0017 $0019-$001D $0020-$0027 $0029-$002B $002D-$0032 $0035 $0037 $003A-$0044 $0046-$0054 $0056-$005E $0060-$0099 $009D-$00BB $00BD-$00C8 $00CF-$00D4 $00D6-$00D9 $00DB-$00EE $00F0-$00F5 $00F7 $00F9-$00FD $00FF $0101-$0106 $0108 $010A-$0110 $0112-$011D $011F-$0137 $0139-$013B $013D-$0144 $0146 $0147 $0149-$0153 $0159 $015F $0167 $0168 $016A-$0171 $0173-$017F $019A $019B $0201-$022E $0280-$028F $030C-$030F $0312 $031D $0320-$0323 $0325-$0328 $033D-$0341 $0345 $0346 $034D-$0354 $035F-$0362 $0364 $0365 $036D-$0372 $0382-$0388 $03A0-$03A8 $03B0-$03BE $03CC-$03D9 $03DB $0401-$041E $0420-$0426 $0430-$043F $0441-$0446 $0448-$0459 $0460-$046D $0478-$0481 $048F-$049D $04A3-$04B0 $04B2-$04B5 $04BA $04BB $04BE-$04CD $04D0-$04EB $04F0-$04F4 $04F8-$04FE $0500-$0504 $0510 $0511 $0514-$0516 $0518-$051A

### 4.2 Scene row only

No bit. Scene-level coverage of D1 (the only domain where rows exist) is in section 5.

### 4.3 Helper-only (no literal COP): reference axis

Bits reached by a helper trace and by no literal COP, whether or not they have a record (the record decides the primary status).

| index | name | helper trace | note |
|---|---|---|---|
| `$0098` | gw_entrance_necklace_stone_taken | necklace_stone_flags |  |
| `$0099` | gw_dive_necklace_stone_taken | necklace_stone_flags |  |
| `$00A0` | dm_laborer_main_a_freed | diamond_mine_laborer_flags |  |
| `$00A1` | dm_laborer_main_b_freed | diamond_mine_laborer_flags |  |
| `$00A2` | dm_laborer_nest_freed | diamond_mine_laborer_flags |  |
| `$00A3` | dm_laborer_elevator_passage_freed | diamond_mine_laborer_flags |  |
| `$00F2` | py_trickle_orbs_a_fallen | falling_orb_flags |  |
| `$00F3` | py_trickle_orbs_b_fallen | falling_orb_flags |  |
| `$00FA` | mu_mystic_statue_collected | statue_reward_flags |  |
| `$00FB` | gw_mystic_statue_collected | statue_reward_flags |  |
| `$0173` | py_main_dark_space_open | dark_space_portal_death_flags |  |
| `$0280` | sc_lances_house_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0281` | sc_south_cape_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0282` | ec_aqueduct_exit_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0283` | it_itory_village_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0284` | fr_oakton_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0285` | fr_freejia_hotel_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0286` | av_angel_rooms_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0287` | av_angel_tunnel_rooms_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0288` | wa_watermia_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0289` | wa_gambling_house_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028A` | eu_euro_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028B` | eu_dark_chapel_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028C` | nv_gorgon_hut_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028D` | da_dao_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028E` | py_pyramid_main_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$028F` | bt_babel_lower_floors_hidden_jewel_taken | hidden_red_jewel_flags |  |
| `$0500` | ir_castoth_reward_claimed | wram_offset_constant_callers |  |
| `$0501` | sg_viper_reward_claimed | wram_offset_constant_callers |  |
| `$0502` | mu_vampires_reward_claimed | wram_offset_constant_callers |  |
| `$0503` | gw_sand_fanger_reward_claimed | wram_offset_constant_callers |  |
| `$0504` | py_mummy_queen_reward_claimed | wram_offset_constant_callers |  |
| `$0510` | sys_will_psycho_dash_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/attack_ability_system.asm:155 {178162} |
| `$0511` | sys_will_psycho_slider_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/player_character.asm:1293 {183198} |
| `$0512` | (proposal) sys_will_spin_dash_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/attack_ability_system.asm:155 {178162}, :177 {178217}; great_wall/wall_rampway/gw85_spin_dash_gate.asm:27 {518420} |
| `$0514` | sys_freedan_dark_friar_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/attack_ability_system.asm:213 {178285} |
| `$0515` | sys_freedan_aura_barrier_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/attack_ability_system.asm:236 {178346} |
| `$0516` | sys_freedan_earthquaker_unlocked | inventory_ability_flags | also a direct read of `abilityBitmask`: actors/player/attack_ability_system.asm:213 {178285}; actors/player/player_character.asm:593 {181957} |
| `$0518` | sys_shadow_ability_slot0_unlocked | inventory_ability_flags |  |
| `$0519` | sys_shadow_ability_slot1_unlocked | inventory_ability_flags |  |
| `$051A` | sys_shadow_ability_slot2_unlocked | inventory_ability_flags |  |

### 4.4 Table-only: reference axis

478 bits. By source: event-block rows without a literal COP 91 ($0100-$0103 $0105 $0107 $0109-$0111 $0117 $0118 $011E $0122-$0124 $012B $012C $0130 $0131 $0134-$0137 $013C-$0142 $0145 $0148 $0153-$0158 $015A-$015E $0160-$0166 $0168 $0169 $016C $016D $016F $0172 $0180-$0184 $0186-$019D); scene reward tier rows 87; chest rows 46; kill flags 253; boss row 1. Bits without a record: 116 ($0100 $0107 $0109 $0111 $011E $013C $0145 $0148 $0154-$0158 $015A-$015E $0160-$0166 $0169 $0172 $0180-$0184 $0186-$0199 $019C $019D $041F $0427-$042F $0440 $0447 $045A-$045F $046E-$0477 $0482-$048E $049E-$04A2 $04B1 $04B6-$04B9 $04BC $04BD $04CE $04CF $04EC-$04EF $04F5 $04F6 $0505).

### 4.5 Set-only (literal COP): the 28

$002E $006D $0106 $0108 $0115 $0119 $011B $011D $0120 $0125 $0128-$012A $012D $0146 $0147 $0149-$0151 $017A $017B $0185 (table in section 6).

### 4.6 Test-only (literal COP): the 10

$0020 $0043 $00F8 $00F9 $00FC $00FD $0116 $0132 $016A $016B (table in section 6).

Test-only by a dynamic reader and no literal COP, no record: 98 D3 bits ($019E-$01FF: scanned by `ApplyAllEventBlocks`, beyond the 158-row table) and 142 D5 bits (tier-0 scenes read by `TestFlag_0300(sceneCurrent)`).

### 4.7 Referenced by a direct read

| index | what | cite |
|---|---|---|
| `$0000` | Rama compare low byte == $FE | mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0001` | plate gate mask $001E; Rama compare low byte == $FE | incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:19 {640148}; mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0002` | plate gate mask $001E; Rama compare low byte == $FE | incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:19 {640148}; mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0003` | plate gate mask $001E; Rama compare low byte == $FE | incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:19 {640148}; mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0004` | plate gate mask $001E; Rama compare low byte == $FE | incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:19 {640148}; mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0005` | Rama compare low byte == $FE | mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0006` | Rama compare low byte == $FE | mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0007` | Rama compare low byte == $FE | mu/mu_altar_room/mu66_rama_spirits.asm:89 {433951} |
| `$0008` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$0009` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000A` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000B` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000C` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000D` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000E` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$000F` | laborer hit counter (byte $0A01) | diamond_mine/mine_main/dm3F_switch.asm:31 {380989}, :45 {381015}; dm3F_mine_collapse_trigger.asm:19 {381042} |
| `$00FF` | engine clear/set of flag $FF | system/engine/scene_lifecycle.asm:842 {253418}, :844 {253423}; system/inventory/inventory_overlay.asm:131 {191814}, :133 {191819} |
| `$04F8` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04F9` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FA` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FB` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FC` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FD` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FE` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$04FF` | tomb mask byte $0A9F == $3F | great_wall/wall_tomb/gw88_tomb_dark_space.asm:18 {507380} |
| `$0510` | abilityBitmask BIT #$0005 | actors/player/attack_ability_system.asm:155 {178162} |
| `$0511` | abilityBitmask BIT #$0002 | actors/player/player_character.asm:1293 {183198} |
| `$0512` | abilityBitmask BIT #$0005/$0004 | actors/player/attack_ability_system.asm:155 {178162}, :177 {178217}; great_wall/wall_rampway/gw85_spin_dash_gate.asm:27 {518420} |
| `$0514` | abilityBitmask BIT #$0050 | actors/player/attack_ability_system.asm:213 {178285} |
| `$0515` | abilityBitmask BIT #$0020 | actors/player/attack_ability_system.asm:236 {178346} |
| `$0516` | abilityBitmask BIT #$0050/$0040 | actors/player/attack_ability_system.asm:213 {178285}; actors/player/player_character.asm:593 {181957} |

### 4.8 Literal COP both ways, no record

$0138 (`$0138`, the Seaside Palace key door; proposal only, section 8.3).

### 4.9 Unreferenced (each range names the searches that found nothing)

| range | bits | searches that found no use | other evidence |
|---|---:|---|---|
| D2 $0018 $001E $001F $0028 $002C $0033 $0034 $0036 $0038 $0039 $0045 $0055 $005F $009A-$009C $00BC $00C9-$00CE $00D5 $00DA $00EF $00F6 $00FE | 28 | S1 (no literal COP of the index), S2 (not a gate operand), S3 (not in any trace candidate set), S4 (no direct access to the byte except `$0A1F` bit 7), S8 | each index appears in no FL20-FL29 registry record or site table; the 62 indices of FL10 section 5 'no static site' agree for the bytes it lists |
| D4 $0200 $022F-$027F $0290-$02FF | 194 | S1, S2, S3 (only the 46 chest rows via `barrier_chest_flags` and the 16 jewel numbers reach `$0200`-based indices), S4 (no direct access to `$0A40-$0A5F`), S7 (no chest row has another flag value) | FL12 section 3: 62 mapped, 194 with no path; census item FL12-06 queued; `$0200` is chest flag 0 (no row uses it) |
| D5 $0300 $0309 $0314 $0348 $034A $0357 $0376 $0377 $0380 $0381 $039E $039F $03AA $03AB $03AF $03C1 $03C2 $03CA $03CB $03EB-$03EF $03F1 $03F8 $03F9 | 27 | S1, S2, S3 (candidates are tier rows; helper callers read `$0300 + sceneCurrent` only for ids that are scenes), S4 (no direct access to `$0A60-$0A7F`), `groups.json` lookup: the scene id is not a scene | the id is not a scene id of `db-us/groups.json`, so `sceneCurrent` never has this value (the 142 tier-0 ids that are scenes are `test-only`, section 7) |
| D6 $0400 $04F7 | 2 | S1, S3, S6 (no enemy-spawn row with enemy number `$00` or `$F7`), S4 (`$0A9E`: no direct access) | FL14: `$0400` is 'no flag'; `$04F7` has no spawn row; `$04FF` is not unreferenced (tomb mask) |
| D7 $0506 $0507 | 2 | S1, S3 (the `Offset100` helpers mask to 3 bits; boss rows 0-5 match, rows 6-7 are placeholder rows that the first-match scan never reaches), S4 (`$0AA0` has no direct access) | FL15 section 4 (boss rows 5-7 placeholders) |
| unassigned byte $0508-$050F | 8 | S1, S3 (3-bit mask never reaches byte `$0AA1`), S4 (no row for `$0AA1`) | FL10-18 queue item (unassigned bytes), FL10 section 5 |

### 4.10 Overlaps inventory/ability/other state

136 bits: `$0520-$059F` = bytes `$0AA4-$0AB3` (128 bits: `$0AA4-$0AA5` unassigned, `$0AA6` state word with 81 direct sites, `$0AA8-$0AAB` unassigned, `$0AAC` state word, `$0AAE-$0AAF` unassigned, `$0AB0` word, `$0AB2` word, `$0AB4` starts `inventorySlots`) and the ability bits that have no record: $0512 $0513 $0517 $051B-$051F. Of those, `$0512` is the Spin Dash bit (helper `TestFlag_0510` and the BIT masks at `attack_ability_system.asm:155 {178162}`, `:177 {178217}`, `gw85_spin_dash_gate.asm:27 {518420}`; proposal only), `$0513` and `$0517` are touched only by the 16-bit debug stores of `$00FF` into `abilityBitmask` (`debug_man` {781889}, `unused_debug_mode` {637608}; no BIT mask in any reader includes bit 3 or 7), and `$051B-$051F` appear in no reader mask, no helper candidate set and no setter. The bytes `$0AA4-$0AB3` are not flag storage: a flag index there would only be reached by a word-form COP with an operand above `$051F`, and the inventory has no such operand (largest literal index `$0185`).

## 5. D1 scratch flags: (scene, bit) coverage

D1 is scoped by scene. Pairs = distinct scene ids on the literal sites of an index; covered = a non-row meaning scopes the scene; row = only a `level: "row"` meaning scopes it. Sites whose scene list is the whole game are shared engine readers (`player_character.asm` runs in 223 scenes for index 0).

| index | meanings | scenes on sites | covered by a record | row only | not scoped | of which shared-engine sites only |
|---|---:|---:|---:|---:|---:|---:|
| `$0000` | 12 | 224 | 35 | 1 | 188 | 188 shared + 0 scene-specific |
| `$0001` | 58 | 66 | 56 | 2 | 8 | 0 shared + 8 scene-specific |
| `$0002` | 42 | 42 | 39 | 1 | 2 | 0 shared + 2 scene-specific |
| `$0003` | 31 | 30 | 28 | 1 | 1 | 0 shared + 1 scene-specific |
| `$0004` | 26 | 24 | 24 | 0 | 0 | 0 shared + 0 scene-specific |
| `$0005` | 17 | 17 | 17 | 0 | 0 | 0 shared + 0 scene-specific |
| `$0006` | 10 | 10 | 10 | 0 | 0 | 0 shared + 0 scene-specific |
| `$0007` | 5 | 5 | 5 | 0 | 0 | 0 shared + 0 scene-specific |
| `$0008` | 6 | 5 | 5 | 0 | 0 | 0 shared + 0 scene-specific |
| `$0009` | 3 | 3 | 3 | 0 | 0 | 0 shared + 0 scene-specific |
| `$000A` | 5 | 5 | 5 | 0 | 0 | 0 shared + 0 scene-specific |
| `$000B` | 4 | 4 | 4 | 0 | 0 | 0 shared + 0 scene-specific |
| `$000C` | 2 | 2 | 2 | 0 | 0 | 0 shared + 0 scene-specific |
| `$000D` | 2 | 3 | 2 | 0 | 1 | 0 shared + 1 scene-specific |
| `$000E` | 5 | 6 | 5 | 0 | 1 | 0 shared + 1 scene-specific |
| `$000F` | 16 | 22 | 16 | 0 | 6 | 0 shared + 6 scene-specific |
| **total** | | 468 | 256 | 5 | 207 | |

The 19 scene-specific pairs without a scope entry are all sites of directory-wide actors or the inventory pseudo-scene `$FF`; each site is cited in the evidence of a record whose scope names the scene that matters (`overworld_exit.asm:210 {52010}` in `$0001` scene `$15`, `item_use_system.asm:701 {232398}` is cited by no record: quality item Q-E6 below, `mu67_vampires.asm:193 {717483}` in `$0002` scene `$67`, `item_use_system.asm:811 {232828}`, `:710/:711 {232420, 232426}` in `$000D/$000E` scene `$CD`, `:931 {233336}` in `$000F` scene `$39`, `gw82_archer.asm:135 {757688}` in `$000F` scene `$87`). The 188 shared-engine scenes of index `$0000` read a bit that nothing sets in those scenes: the record `sys_player_alt_idle_active` (34 scenes) covers the scenes where it is set.

## 6. The 28 set-only and 10 test-only literal flags: where the other half lives

Method: for each flag the inventory gives literal COP sites; the other half is looked for in S3 (helper trace candidates), S5 (event-block row and scan), S4 (direct byte accesses), S1 again with the opposite role, and the dynamic inputs (none unresolved). "Closed" = a concrete other half is cited; "dead write" = every search found no reader, the claim is static; "queued" = a runtime item exists. Row scene = scene byte of the event block row `n` of `extracted/system/event_block_table.asm`.

| index | name | grade | literal | other half | status |
|---|---|---|---|---|---|
| `$0020` | sc_cave_friends_idle | UNKNOWN | B: south_cape/coastal_cave/sc02_lance.asm:22 {307314}; B: south_cape/coastal_cave/sc02_seth.asm:26 {308339} (+1) | no setter anywhere: literal COP, helper traces, direct byte `$0A04` (none), dynamic helper inputs (0 unresolved), ROM byte scan all found nothing; the record says UNKNOWN | queued FL20-10 |
| `$002E` | it_couple_house_incan_melody_played | VERIFIED-STATIC | S: system/inventory/item_use_system.asm:488 {231465} | none found: write-only (UseItem_IncanMelody has no reader). Closed as a dead write; queued for the runtime check. | closed (dead write); queued FL22-01, FL30-06 |
| `$0043` | ec_prison_door_c_open | UNKNOWN | B: edward_castle/castle_prison/ec0B_guard.asm:20 {318502} | no setter anywhere (same searches as `$20`; none of the 17 trace candidate sets holds index 67); the record says UNKNOWN | queued FL21-08 |
| `$006D` | na_cottage_party_left_for_nazca | VERIFIED-STATIC | S: nazca/neils_cottage/na49_lance.asm:47 {385447} | none found: write-only. Closed as a dead write (static, searches S1-S5, S8); runtime read census queued as FL41-04. | closed (dead write); queued FL41-04 |
| `$00F8` | (proposal) gs_mystic_statue_ceremony_done | proposal | B: gold_ship/ship_gold/gs2C_crew5.asm:17 {361423}; B: gold_ship/ship_gold_interior/gs2E_sleep.asm:32 {362056} (+1) | statue-reward row +0 is the raw flag index: `SetFlagRaw` at `system/statue_inventory/statue_inventory_reward.asm:114 {52689}` (trace `statue_reward_flags`, candidates `$F8-$FD`) | closed (table); queued FL23-07, FL32-42 |
| `$00F9` | sg_viper_mystic_statue_collected | VERIFIED-STATIC | B: sky_garden/viper_lair/sg55_mystic_statue.asm:37 {708159} | statue-reward row +0 is the raw flag index: `SetFlagRaw` at `system/statue_inventory/statue_inventory_reward.asm:114 {52689}` (trace `statue_reward_flags`, candidates `$F8-$FD`) | closed (table); queued FL24-16 |
| `$00FC` | py_mummy_queen_mystic_statue_collected | VERIFIED-STATIC | W: pyramid/puzzle_room/pyCD_kara.asm:106 {572963}; B: pyramid/pyramid_main/pyCC_portal.asm:20 {576879} | statue-reward row +0 is the raw flag index: `SetFlagRaw` at `system/statue_inventory/statue_inventory_reward.asm:114 {52689}` (trace `statue_reward_flags`, candidates `$F8-$FD`) | closed (table) |
| `$00FD` | bt_olman_mystic_statue_collected | VERIFIED-STATIC | B: babel_tower/babel_entrance/btDE_olman.asm:31 {624664} | statue-reward row +0 is the raw flag index: `SetFlagRaw` at `system/statue_inventory/statue_inventory_reward.asm:114 {52689}` (trace `statue_reward_flags`, candidates `$F8-$FD`) | closed (table) |
| `$0106` | ec_prison_cell_door_tiles_removed | VERIFIED-STATIC | S: system/inventory/item_use_system.asm:302 {230891} | event block row $06 (scene $0B) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $FF differs from the row scene: the block is applied when the player loads scene $0B later | closed (table); queued FL11-01 |
| `$0108` | ir_plate_gate_open | VERIFIED-STATIC | S: incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm:29 {640169} | event block row $08 (scene $1F) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0115` | ec_aqueduct_back_prop_hit_b | VERIFIED-STATIC | S: edward_castle/aqueduct_back/ec12_aqueduct_enemy.asm:52 {638820} | event block row $15 (scene $12) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0116` | ec_aqueduct_back_dark_space_open | VERIFIED-STATIC | B: edward_castle/aqueduct_back/ec12_aqueduct_dark_space.asm:14 {638830}; W: edward_castle/aqueduct_back/ec12_aqueduct_dark_space.asm:15 {638837} | `SetFlag_0100` at `functions/StandardEnemyDefeatHandler.asm:122 {56371}` (also `EnemyDefeatDispatch.asm:91 {697544}`, `awB1_wall_walker.asm:538 {770410}`, `pyCC_mystic_ball.asm:251 {771966}`), index = death-action operand of an enemy-spawn row (trace `enemy_death_action_flags`) | closed (table) |
| `$0119` | sc_wills_house_ransacked | INFERRED | C: south_cape/wills_house/sc06_kara_return.asm:85 {304776}; S: edward_castle/edward_castle/ec0A_kara.asm:186 {315306} | event block row $19 (scene $06) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table); queued FL11-03, FL20-09, FL21-07 |
| `$011B` | it_cave_statue_a_taken | VERIFIED-STATIC | S: itory/itory_cave/it19_inca_statue_a.asm:20 {324461} | event block row $1B (scene $19) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$011D` | it_moon_tribe_statue_b_taken | VERIFIED-STATIC | S: itory/moon_tribe_cave/it1B_inca_statue_b.asm:20 {326361} | event block row $1D (scene $1B) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0120` | gs_adrift_effect_layer_set | INFERRED | S: gold_ship/adrift/dc2F_adrift.asm:376 {367371}; C: gold_ship/adrift/dc2F_adrift.asm:425 {367491} | event block row $20 (scene $2F) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table); queued FL11-04 |
| `$0125` | sg_garden_sw_blocker_a_top_set | VERIFIED-STATIC | C: sky_garden/garden_southwest_underside/sg52_blocker_enemy_a.asm:38 {390677}; S: sky_garden/garden_southwest_underside/sg52_blocker_enemy_a.asm:54 {390716} | event block row $25 (scene $51) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $52 differs from the row scene: the block is applied when the player loads scene $51 later | closed (table); queued FL24-10 |
| `$0128` | sg_garden_sw_blocker_b_underside_state1 | VERIFIED-STATIC | S: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:34 {390784}; C: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:59 {390839} | event block row $28 (scene $52) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0129` | sg_garden_sw_blocker_b_top_state2 | VERIFIED-STATIC | C: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:35 {390788}; S: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:56 {390827} | event block row $29 (scene $51) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $52 differs from the row scene: the block is applied when the player loads scene $51 later | closed (table) |
| `$012A` | sg_garden_sw_blocker_b_underside_state2 | VERIFIED-STATIC | C: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:36 {390792}; S: sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm:57 {390831} | event block row $2A (scene $52) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$012D` | sg_garden_sw_switch_top_pressed | VERIFIED-STATIC | S: sky_garden/garden_southwest_underside/sg52_switch.asm:27 {390896} | event block row $2D (scene $51) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $52 differs from the row scene: the block is applied when the player loads scene $51 later | closed (table); queued FL24-09 |
| `$0132` | dm_hidden_dark_space_open | VERIFIED-STATIC | B: diamond_mine/mine_collapsed_tunnel/dm40_hidden_dark_space.asm:18 {382497}; W: diamond_mine/mine_collapsed_tunnel/dm40_hidden_dark_space.asm:19 {382504} | `SetFlag_0100` at `functions/StandardEnemyDefeatHandler.asm:122 {56371}` (also `EnemyDefeatDispatch.asm:91 {697544}`, `awB1_wall_walker.asm:538 {770410}`, `pyCC_mystic_ball.asm:251 {771966}`), index = death-action operand of an enemy-spawn row (trace `enemy_death_action_flags`) | closed (table) |
| `$0146` | mu_bomb_wire_cut_a | VERIFIED-STATIC | S: mu/mu_vampire_lair/mu67_bomb.asm:64 {435312} | event block row $46 (scene $67) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table); queued FL25-06 |
| `$0147` | mu_bomb_wire_cut_b | VERIFIED-STATIC | S: mu/mu_vampire_lair/mu67_bomb.asm:65 {435316} | event block row $47 (scene $67) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0149` | av_ishtar_door_1_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:70 {448489}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:26 {448714} | event block row $49 (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014A` | av_ishtar_door_2_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:77 {448499}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:27 {448718} | event block row $4A (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014B` | av_ishtar_door_3_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:84 {448509}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:28 {448722} | event block row $4B (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014C` | av_ishtar_door_4_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:91 {448519}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:29 {448726} | event block row $4C (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014D` | av_ishtar_door_5_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:98 {448529}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:30 {448730} | event block row $4D (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014E` | av_ishtar_door_6_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:105 {448539}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:31 {448734} | event block row $4E (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$014F` | av_ishtar_door_7_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:112 {448549}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:32 {448738} | event block row $4F (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0150` | av_ishtar_door_8_open | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_doors.asm:119 {448559}; C: angel_village/angel_tunnel_test/av75_voice_rooms.asm:33 {448742} | event block row $50 (scene $75) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0151` | av_ishtar_test_passed | VERIFIED-STATIC | S: angel_village/angel_tunnel_test/av75_voice_rooms.asm:164 {449021} | event block row $51 (scene $74) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $75 differs from the row scene: the block is applied when the player loads scene $74 later | closed (table) |
| `$016A` | gw_sand_fanger_defeated | VERIFIED-STATIC | W: great_wall/sand_fanger_lair/gw8A_sand_fanger.asm:111 {753779} | `SetFlag_0100` at `functions/StandardEnemyDefeatHandler.asm:122 {56371}` (also `EnemyDefeatDispatch.asm:91 {697544}`, `awB1_wall_walker.asm:538 {770410}`, `pyCC_mystic_ball.asm:251 {771966}`), index = death-action operand of an enemy-spawn row (trace `enemy_death_action_flags`) | closed (table) |
| `$016B` | aw_outer_east_wall_walker_defeated | VERIFIED-STATIC | W: angkor_wat/angkor_outer_east/awB2_slider_glide_trigger.asm:14 {563403} | `SetFlag_0100` at `functions/StandardEnemyDefeatHandler.asm:122 {56371}` (also `EnemyDefeatDispatch.asm:91 {697544}`, `awB1_wall_walker.asm:538 {770410}`, `pyCC_mystic_ball.asm:251 {771966}`), index = death-action operand of an enemy-spawn row (trace `enemy_death_action_flags`) | closed (table) |
| `$017A` | dm_cell_door_open | VERIFIED-STATIC | S: diamond_mine/mine_foyer/dm44_cell_door.asm:25 {382277} | event block row $7A (scene $44) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$017B` | dm_elevator_door_open | VERIFIED-STATIC | S: diamond_mine/mine_main/dm3F_elevator_door.asm:23 {382555} | event block row $7B (scene $3F) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); same scene as the setter | closed (table) |
| `$0185` | (proposal) gs_ship_departure_started | proposal | S: gold_ship/ship_gold/gs2C_descent.asm:29 {360840} | event block row $85 (scene $1E) is applied by the `ApplyAllEventBlocks` scan (`event_blocks.asm:81 {172529}`, reads all of `$0A20-$0A3F`); setter scene $2C differs from the row scene: the block is applied when the player loads scene $1E later | closed (table); queued FL11-14, FL23-09, FL32-44 |

Result: 34 flags closed by a table or helper other half (26 event-block rows, 4 statue-reward rows, 4 death-action rows), 2 dead writes (`$2E`, `$6D`), 2 test-only flags with no setter anywhere (`$20`, `$43`, both UNKNOWN and queued FL20-10, FL21-08). Cross-scene rows: `$0125`, `$0129`, `$012D` are set in scene `$52` and applied in scene `$51`; `$0151` is set in `$75` and applied in `$74`; `$0185` is set in `$2C` and applied in `$1E`. No dynamic-trace or dead-code explanation is needed beyond these.

## 7. Dynamic inputs and helper callers

`inventory.json` reports `unresolved_dynamic_helper_inputs = []` and `unresolved_cop_sites = []`. `SceneCmd_Branch` (`scene_script.asm:264 {164941}`) is decoded: all 18 `branch < flag, label >` lines of `tables/scene_meta.asm` (an independent `rg` count agrees) have a literal one-byte operand, 9 distinct indices (`$21 $4C $70 $7B $7E $88 $96 $B3 $F4` in decimal 33, 76, 112, 123, 126, 136, 150, 179, 244); no other file carries a `branch <` command.

Bound of every helper caller (57 call sites, grouped by trace):

| Trace / group | call sites | input | bound | result |
|---|---:|---|---|---|
| cop-operand | 8 | COP operand of the script command | all 1,693 COP sites have literal operands (`unresolved_cop_sites` empty) | bounded |
| dungeon_kill_wram_flags | 1 | actor field enemy number from the spawn row | 253 candidates = nonzero enemy numbers of `scene_actors` (FL14 table, 1 to 255) | bounded (rows) |
| boss_reward_wram_flags | 2 | boss row number & 7 | 6 rows matched (rows 6-7 are shadowed placeholders); `$0500-$0505` | bounded (rows) |
| enemy_clear_reward_flags | 7 | `$0300 + sceneCurrent` (tests) or the placed scene (boss handler, reward actors) | the 87-scene candidate set bounds only the SET sites (`boss_clear_reward_handler.asm:159 {50035}`, `reward_actors.asm:115 {57679}`, reached after a tier read). The TEST sites `StandardEnemyDefeatHandler.asm:89 {56311}`, `:204 {56727}` (test before the tier-0 check), `radar_map_screen.asm:175 {229828}`, `field_reveal_object.asm:45 {55948}` and `boss_clear_reward_handler.asm:154 {50026}` read `$0300 + sceneCurrent` for any scene value | **not bounded by the candidate set**: reads cover every scene id; the 142 tier-0 scene ids are read and never set (D5 `test-only`); harmless (read only), but the candidate list understates the read set |
| hidden_red_jewel_flags | 2 | actor parameter `$0E + $80` on base `$0200` | 16 actors placed in scene rows (`$0280-$028F`) | bounded (placement) |
| hit_switch_flags | 1 | actor parameter `$24 := $0E` | 5 values (`$01-$04`, `$0F`) over 3 scenes (placement) | bounded (placement) |
| statue_reward_flags | 3 | statue-reward row +0 | 6 rows (`$F8-$FD`) | bounded (rows) |
| enemy_death_action_flags | 8 | `deathActionIdx` stored from operand 7 of an enemy-spawn row; the callers skip index 0 | 42 candidates from the rows; `StandardEnemyDefeatHandler.asm:119 {56361}` tests only when the index is nonzero | bounded (rows) |
| scene_meta_gates | 1 | `SceneCmd_Branch` operand | 18 literal gates, 9 indices | bounded (decoded) |
| barrier_chest_flags | 4 | chest-table byte 3 & `$7F` | 46 rows, so at most 46 indices (`$0201-$027E`) | bounded (rows) |
| inventory_ability_flags | 1 | `4 * characterForm + slot` | forms 0-2 times slots 0-2 = 9 candidates; a `characterForm` above 2 would index `$051C+` | bounded by the form domain (assumption: `characterForm` stays 0-2) |
| block | 3 | none (`ClearAllWramFlags` has no input) | 3 callers | no input |
| necklace_stone_flags | 2 | byte table indexed by actor parameter | 2 candidates (`$98 $99`) | bounded (placement) |
| dark_space_portal_death_flags | 2 | actor parameter `$0E` (spawn byte >> 1) on base `$0100` | 1 candidate (`$0173`), 1 scene | bounded (placement) |
| falling_orb_flags | 2 | actor parameter `$0E + $80` | 2 candidates (`$F2 $F3`) | bounded (placement) |
| gold_tile_flags | 2 | actor parameter `$0E` | 4 candidates (`$01-$04`) | bounded (placement) |
| wram_offset_constant_callers | 6 | immediate `LDA` before `TestWramFlag_Offset100` | 6 constants (`$00-$04`, `$03`) | bounded (constants) |
| diamond_mine_laborer_flags | 2 | byte table indexed by actor parameter | 4 candidates (`$A0-$A3`) | bounded (placement) |

Findings: (1) no helper input is unresolved and no helper is called by numeric address. (2) The only unbounded input is `sceneCurrent` in the `TestFlag_0300` callers; its read set is all 256 values, so the matrix classifies the 142 tier-0 scene ids as test-only and the 27 non-scene ids as unreferenced (a scene id that does not exist cannot be `sceneCurrent`). (3) The scan in `ApplyAllEventBlocks` reads all 256 D3 bits while the table has 158 rows: `LookupEventBlock` has no bound check (FL11), so a set bit in `$019E-$01FF` makes the scan read 8 bytes beyond the table and apply a block when the junk scene byte equals `sceneCurrent`. No code sets those bits; a preset or census harness must not write them (queue item FL41-02). (4) `inventory_ability_flags` is bounded only by the domain of `characterForm`.

## 8. Quality audit

### 8.1 Counts

Merged chain: 683 index records, 912 meanings; grades VERIFIED-STATIC 742, INFERRED 162, (none) 6, UNKNOWN 2 (the 6 meanings without a grade are the D1 row meanings, Q-C3). Proposals without a record: `$00F8`, `$0138`, `$0185`, `$0512`. Names: 905 distinct, 0 reused across indices. Queue items: 341 in 20 files.

### 8.2 Checks run and results

| check | method | result |
|---|---|---|
| duplicate or non-unique names | every `name` of every meaning, merged chain | 0 names used at two indices; 0 proposals reuse a record name at another index |
| D1 records with `scope: null` | indices `$0000-$000F` | 0 |
| D1 overlapping scopes | scene present in two meanings of one D1 index | 13 scene overlaps (Q-C2) |
| name prefix versus area | prefix of the name against `db-us/groups.json` prefix (system = `sys`) | 6 meanings (Q-D) |
| grades without evidence | VERIFIED-STATIC with no `{offset}` evidence entry: 0; any meaning without evidence: 1 | `$0043` ec_prison_door_c_open (UNKNOWN) (Q-F) |
| INFERRED/UNKNOWN without `queue` field | meaning field `queue` empty | 9 of 164, each covered by a queue item of the same flag (Q-B1) |
| `queue` ids that do not exist | field against the 337 ids | 0 |
| citations `file:line {offset}` | `fl32_citecheck.mjs` over the 22 registry fragments and 20 queue files | 1 real mismatch (Q-E1); the tool also prints 29 lines for shorthand citations that re-use the previous file name, and 130 lines for data-table rows (`tables/*.asm`, `boss-reward-range` rows) that carry no `; {n}` tag; all checked by hand |
| `npm run flags -- --check` | real db: `Flags check: OK (0 indices ...; 1 warning)`; chain merged into a scratch registry by FL32: 86 errors | listed in FL32 section "New questions" (44 unknown kinds, 32 `requires/excludes` and 7 `pairsWith` as text, 2 scoped single D2 meanings, area `unused`, 5 overlapping D1 scopes); the apply pass fixes them |

### 8.3 Findings with the fix

**Q-A Spine flags still proposals.** `$00F8`, `$0138`, `$0185`, `$0512` have no record (FL31 left them for FL32; FL32 did not write them). Proposals disagree for `$0138`: FL11 and FL32 `sp_palace_entrance_open`, FL25 and FL30 `sp_mu_passage_door_open` (high). The code settles it: `UseItem_SeasidePalaceKey` (`item_use_system.asm:1052 {233821}`, `:1057 {233840}`) tests the player inside tiles (08,07)-(0A,08) of scene `$5A`, removes item `#10`, stages BG change `#38` and sets the flag; the door it opens is the passage to Mu (warp `#05` to scene `$5E`). Fix: FL41 proposal `$0138 sp_mu_passage_door_open`; FL32 rows that name `sp_palace_entrance_open` (`FL32_registry.json`, 1) follow. `$F8`: `gs_mystic_statue_ceremony_done`; `$0185`: `gs_ship_departure_started`; `$0512`: `sys_will_spin_dash_unlocked`; unchanged from the proposals, FL41 repeats them in `FL41_registry.json` so the apply pass can write the four records.

**Q-B Records without a queue id.** `$0000` sc_town_player_south_strip_active -> FL20-11; `$0000` bt_light_elevator_player_pose_cue -> FL29-01; `$0006` sc_cave_statue_moved_ack -> FL20-12; `$000F` pr_text_fade_out_done -> FL20-13; `$000F` py_vader_barrier_busy -> FL29-03; `$0020` sc_cave_friends_idle -> FL20-10; `$00DB` end_epilogue_first_half_done -> FL29-07; `$00F2` py_trickle_orbs_a_fallen -> FL29-04; `$00F3` py_trickle_orbs_b_fallen -> FL29-05. Each id is the item of that meaning (same flag and scope). Fix: patch rows in `FL41_registry.json` add the `queue` field (`expectOld` = the current name).

**Q-C D1.** (1) 0 records with `scope: null`. (2) Overlapping scopes: `$0000` scene `$01` (sc_town_player_south_strip_active + sys_player_alt_idle_active); `$0000` scene `$1E` (ir_cliff_back_player_north_strip_active + sys_player_alt_idle_active); `$0000` scene `$3D` (dm_promise_passage_player_near_wall + sys_player_alt_idle_active); `$0000` scene `$40` (dm_collapsed_tunnel_player_near_slave + sys_player_alt_idle_active); `$0000` scene `$73` (av_waterfall_alt_idle_zone + sys_player_alt_idle_active); `$0000` scene `$75` (av_test_wind_room_alt_idle + sys_player_alt_idle_active); `$0000` scene `$78` (wa_watermia_alt_idle_zone + sys_player_alt_idle_active); `$0000` scene `$9D` (eu_dark_chapel_altar_alt_idle_zone + sys_player_alt_idle_active); `$0000` scene `$E1` (bt_light_elevator_player_pose_cue + sys_player_alt_idle_active); `$0001` scene `$06` (sc_house_pig_stops_will_req + sc_house_kara_talk_req); `$0002` scene `$06` (sc_house_kara_first_line_ack + sc_house_kara_depart_line_req); `$0003` scene `$06` (sc_house_bill_talk_req + sc_house_kara_second_line_req); `$0004` scene `$06` (sc_house_lola_line_ack + sc_house_depart_confirm_req). The nine `$0000` overlaps are the layering of one generic engine record (`sys_player_alt_idle_active`) over nine scene-specific setters and are intended; the four scene-`$06` overlaps (`$0001-$0004`) are two phases of the same scene that `scope.scenes` cannot separate: the fix is an `actors` scope on each of the eight meanings (`sc_house_*` at the House intro versus the departure chain). (3) Six D1 row meanings have no name, area, kinds or grade (`$0000 scenes 11`, `$0001 scenes 47`, `$0001 scenes 139`, `$0002 scenes 47`, `$0003 scenes 47`, `$0008 scenes 63`): rows are scene-level notes; the fix is to give them `grade: INFERRED` when the apply pass writes them.

**Q-D Names.**

Prefix versus area: 6 meanings. `end_` in area ending (expected ed); `unused_` in area unused (expected (area not in groups.json)). Examples: `$0002` end_epilogue_mother_voice_cue, `$0003` end_epilogue_spirits_depart_cue, `$0004` end_epilogue_kara_farewell_cue, `$0005` end_epilogue_player_stand_cue, `$00DB` end_epilogue_first_half_done, `$00F5` unused_mode7_boss_defeated. Fix: area `ending` uses the prefix `end_` (rename the area to `end` or the names to `ed_`, one decision for the apply pass), and `$00F5 unused_mode7_boss_defeated` takes area `system` with a `sys_` name.

Names that do not state what is true when set (name -> fix):

| index | current name | proposed | why |
|---|---|---|---|
| `$0000` | av_waterfall_alt_idle_zone | av_waterfall_alt_idle_active | ends in `zone`, a place, not a state |
| `$0000` | wa_watermia_alt_idle_zone | wa_watermia_alt_idle_active | same |
| `$0000` | eu_dark_chapel_altar_alt_idle_zone | eu_dark_chapel_altar_alt_idle_active | same |
| `$0000` | av_test_wind_room_alt_idle | av_test_wind_room_alt_idle_active | ends in `idle`, no state word |
| `$0002` | wa_glass_game_start | wa_glass_game_started | imperative noun, not a state |
| `$0001` | it_lily_house_moon_tribe_yes | it_lily_house_moon_tribe_yes_answered | ends in the answer, not the state |
| `$0001` | wa_lukes_house_party_cue_and_stay_talk | wa_lukes_house_party_cue_given | two states in one name |
| `$0146` | mu_bomb_wire_cut_a | mu_lair_gate_a_open | FL25 (medium): the flag is set right after both vampires die (`mu67_bomb.asm:64 {435312}`), before the wire answer; decision pending (FL25 question 1, queue FL25-06) |
| `$0147` | mu_bomb_wire_cut_b | mu_lair_gate_b_open | same (`mu67_bomb.asm:65 {435316}`) |
| `$0020` | sc_cave_friends_idle | (keep, UNKNOWN) | states the effect only; the record says so |

`$0146/$0147` are used by name in `specs/FL32_presets.json` (18 occurrences) and `FL32_registry.json` (2): the apply pass must rename them together if the user accepts the FL25 proposal; FL41 does not patch the name (a rename is a decision, not a gap) and does not edit those files.

**Q-E Citations.**

- Q-E1: `FL27_registry.json:5` and `FL27_20261104.md:225` cite `watermia/watermia/wa78_glass_game.asm:538 {498241}`; the tag `{498241}` is on line 539 (`STA $0AA6`), line 538 is `ORA #$0004` {498238}. Fix: `:539 {498241}`. This is the only real mismatch of the 42 files.
- Q-E6: the claim "the use gate refuses the melody when `$02` is already set" (`FL21_registry.json`, record `$0002`, scene `$11`, note) cites `item_use_system.asm:700 {232391}`, which is the `$0113` test; the `$02` test is `item_use_system.asm:701 {232398}`. Fix: patch row in `FL41_registry.json` (index `$0002`, `expectOld` `ec_doorway_melody_played_req`) adds `:701 {232398}` to the evidence and corrects the note.

**Q-F Grades.** `$0043 ec_prison_door_c_open` (UNKNOWN) has an empty `evidence`; its note holds the searches. Fix: patch row in `FL41_registry.json` sets evidence `extracted/edward_castle/castle_prison/ec0B_guard.asm:20 {318502}`. All VERIFIED-STATIC meanings carry at least one `{offset}` citation. 162 INFERRED + 2 UNKNOWN meanings; none was promoted by FL41.

**Q-G Records whose fragments disagree.** Index with different names across fragments (records and proposals), final name of the merged chain:

| index | names by fragment | final | verdict |
|---|---|---|---|
| `$0010` | FL20: sc_school_lesson_done (prop); FL30: sys_boot_logo_first_shown (prop); FL31: sc_school_lesson_done; FL31: sys_boot_logo_first_shown | sc_school_lesson_done / sys_boot_logo_first_shown | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0040` | FL22: it_village_barrier_lifted (prop); FL30: it_village_barrier_lifted (prop); FL31: it_meadow_lola_melody_played | it_meadow_lola_melody_played | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0070` | FL10: sp_palace_fountain_done (prop); FL25: sp_fountain_purified_done | sp_fountain_purified_done | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0088` | FL10: mu_vampire_lair_done (prop); FL25: mu_lair_reunion_started | mu_lair_reunion_started | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0096` | FL10: wa_festival_night_active (prop); FL24: gw_lance_lilly_reunion_done (prop); FL27: wa_festival_night_active (prop); FL31: wa_festival_night_active | wa_festival_night_active | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$00F4` | FL10: pr_prophecy_second_page_active (prop); FL20: pr_prophecy_first_pass_active (prop); FL30: pr_prophecy_first_pass_active (prop); FL31: pr_prophecy_first_pass_active | pr_prophecy_first_pass_active | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0106` | FL11: ec_prison_door_unlocked (prop); FL30: ec_prison_cell_door_tiles_removed | ec_prison_cell_door_tiles_removed | later fragment renames deliberately (FL31/FL25/FL30 decision); nothing to fix |
| `$0138` | FL11: sp_palace_entrance_open (prop); FL25: sp_mu_passage_door_open (prop); FL30: sp_mu_passage_door_open (prop); FL32: sp_palace_entrance_open (prop) | (proposal) sp_palace_entrance_open | open: FL41 proposal `sp_mu_passage_door_open` |
| `$0146` | FL11: mu_bomb_wire_cut_a; FL25: mu_lair_gate_a_open (prop) | mu_bomb_wire_cut_a | final is wrong: rename (Q-D) |
| `$0147` | FL11: mu_bomb_wire_cut_b; FL25: mu_lair_gate_b_open (prop) | mu_bomb_wire_cut_b | final is wrong: rename (Q-D) |

Index reuses: `$0010` has two scoped meanings (`sc_school_lesson_done` scene `$08`, `sys_boot_logo_first_shown` scene `$FB`); D1 indices are reused by design in every scene; no other persistent index has two meanings. The 62 spine indices have one record each.

### 8.4 New queue items

See `queue/FL41_queue.json`: FL41-01 (write census over the 261 unreferenced bits and the D3 tail), FL41-02 (hazard: D3 bits `$019E-$01FF`), FL41-03 (tier-0 reads of `TestFlag_0300`), FL41-04 (read census for the dead write `$6D`).

## 9. Appendix: status row per bit

Columns: index, byte.bit, domain, primary status, doc, ref, name or proposal, tags.

| index | byte.bit | dom | primary | doc | ref | name | tags |
|---|---|---|---|---|---|---|---|
| `$0000` | `0A00.0` | D1 | named record | record | both | sc_town_player_south_strip_active / ir_cliff_back_player_north_strip_active / dm_promise_passage_player_near_wall / dm_collapsed_tunnel_player_near_slave / av_waterfall_alt_idle_zone / av_test_wind_room_alt_idle / wa_watermia_alt_idle_zone / eu_dark_chapel_altar_alt_idle_zone / bt_light_elevator_player_pose_cue / sys_player_alt_idle_active / sys_inventory_exit_req | direct: Rama compare low byte == $FE |
| `$0001` | `0A00.1` | D1 | named record | record | both | pr_prophecy_camera_pan_done / sc_school_erik_line_ack / sc_cave_lance_talk_req / sc_house_pig_stops_will_req / sc_house_kara_talk_req / ec_castle_kara_talk_req / ec_prison_bread_tasted_ack / ec_lockway_switch_pressed / ec_doorway_press_window_open / it_village_intro_pan_active / it_lily_house_moon_tribe_yes / ir_entrance_kara_arrived / ir_gold_tile_1_occupied / ir_ceiling_trap_zone_1_fired / gs_wreck_fish_intro_ack / gs_wreck_interior_mummy_talk_req / fr_oakton_dog_talk_req / fr_oakton_interior_rescuer_dialog_req / fr_freejia_alley_guard_push_req / fr_hotel_lily_greeting_req / fr_slave_market_guard_pass_req / gw_dive_switch_struck_req / gw_rampway_gate_switch_struck_req / sg_descent_neil_line_done / sg_crash_approach_done / mt_crossroads_mushroom_drop_req / mt_circuit_stem_a_drop_req / sp_key_coffin_talk_req / mu_rama_first_talk_done / mu_lair_bomb_wire_chosen / na_cottage_arrival_talk_done / na_plain_neil_intro_done / av_undersea_neil_narration_done / av_entrance_lance_sign_talk_done / av_village_door_open_req / av_tunnel_crack_inspected_req / av_tunnel_rooms_magic_dust_used / eu_altar_passage_open_request / wa_glass_gate_spectator_released / wa_lukes_house_party_cue_and_stay_talk / wa_father_house_father_talked / wa_exchange_lily_first_line_done / eu_guest_room_neil_asks_kara_pending / nv_village_cutscene_start_cue / da_snake_game_start_requested / py_melody_played_cue / bt_flight_farewell_done / py_queen_teleport_active / bt_olman_talk_cue / bt_crystal_ring_dropped / bt_light_elevator_ride_cue / bt_exterior_spirit_talk_cue / bt_rooftop_seth_spoken / bt_comet_phase2_started / sys_palette_wave_req / ir_plate_room_wind_melody_played | helper: hit_switch_flags,gold_tile_flags; direct: plate gate mask $001E; Rama compare low byte == $FE |
| `$0002` | `0A00.2` | D1 | named record | record | both | sc_town_hide_seek_walk_req / sc_cave_seth_talk_req / sc_house_kara_first_line_ack / sc_house_kara_depart_line_req / ec_castle_kara_guest_ack / ec_prison_door_check_ack / ec_doorway_melody_played_req / it_village_intro_dialog_done / it_lily_house_kara_walk_req / ir_entrance_lily_dialog_req / ir_gold_tile_2_occupied / ir_ceiling_trap_zone_2_fired / gs_wreck_erik_dialog_req / gs_wreck_interior_mummy_dialog_ack / fr_oakton_interior_kara_dialog_ack / fr_freejia_arrival_kara_talk_req / fr_hotel_lance_talk_req / sg_descent_neil_handoff_req / gw_rampway_short_spear_switch_struck_req / gw_inner_necklace_stones_handed_over / mt_circuit_stem_b_drop_req / sp_stone_coffin_talk_req / mu_prayer_spirits_release_req / mu_rama_spirit_a_talked / mu_lair_fight_started / na_cottage_welcome_talk_done / na_plain_spirit_seen / av_undersea_mushrooms_examined / av_entrance_lily_urge_done / wa_glass_game_start / wa_birthday_lily_surprised / wa_father_house_lance_talked / wa_exchange_bouquet_given / eu_hamlet_arrived / nv_hamlet_sad_look_cue / da_snake_game_first_pot_hit / py_jackal_arrival_cue / bt_comet_spirit_talk_cue / bt_rooftop_neil_father_spoken / end_epilogue_mother_voice_cue / bt_comet_gaia_wave_running | helper: hit_switch_flags,gold_tile_flags; direct: plate gate mask $001E; Rama compare low byte == $FE |
| `$0003` | `0A00.3` | D1 | named record | record | both | sc_town_hide_seek_wall_ack / sc_cave_news_react_req / sc_house_bill_talk_req / sc_house_kara_second_line_req / ec_castle_kara_speech_req / ec_prison_moss_ack / ec_doorway_early_press_req / it_village_kara_line_done / it_lily_house_kara_walk_done / ir_entrance_kara_scold_done / ir_gold_tile_3_occupied / ir_ceiling_trap_zone_3_fired / fr_freejia_arrival_walk_req / gw_rampway_long_spear_switch_struck_req / gw_inner_lance_first_lines_done / mu_rama_spirit_b_talked / mu_lair_bomb_defused_ack / na_cottage_socks_talk_done / na_plain_neil_statue_talk_done / av_undersea_neil_strip_reached / av_entrance_kara_talk_done / wa_glass_player_turn1_done / wa_birthday_cake_done / wa_exchange_roses_thanked / nv_hamlet_fire_jump_cue / da_snake_game_time_up / py_flame_statue_fired / bt_rooftop_neil_mother_spoken / end_epilogue_spirits_depart_cue / bt_comet_phase1_defeated | helper: hit_switch_flags,gold_tile_flags; direct: plate gate mask $001E; Rama compare low byte == $FE |
| `$0004` | `0A00.4` | D1 | named record | record | both | sc_cave_exit_lock_active / sc_house_lola_line_ack / sc_house_depart_confirm_req / ec_prison_ball_ack / it_village_lola_reunion_done / ir_gold_tile_4_occupied / ir_ceiling_trap_zone_4_fired / fr_freejia_hotel_door_talk_req / gw_rampway_multi_spear_switch_struck_req / gw_inner_lilly_answer_done / mu_rama_spirit_c_talked / mu_lair_neil_arrived_req / na_cottage_lance_socks_reply_done / av_undersea_kara_mushroom_remark_done / av_entrance_lily_grouch_done / wa_glass_player_turn2_done / wa_birthday_lance_talk_started / wa_exchange_confession_done / nv_fire_effect_actor_started / da_snake_game_result_ready / py_jackal_panic_started / bt_comet_spirit_ride_done / bt_exterior_spirit_ride_done / bt_rooftop_hamlet_spoken / end_epilogue_kara_farewell_cue / bt_comet_gaia_defeated | helper: hit_switch_flags,gold_tile_flags; direct: plate gate mask $001E; Rama compare low byte == $FE |
| `$0005` | `0A00.5` | D1 | named record | record | both | sc_cave_demo_request_ack / sc_house_scream_dialog_ack / ec_throne_audience_done_ack / it_village_lily_house_line_done / ir_ceiling_trap_zone_5_fired / fr_freejia_hotel_door_open_req / gw_inner_lance_reply_done / mu_rama_spirit_d_talked / mu_lair_lilly_greeting_done / na_cottage_intro_released / na_plain_kara_first_talk_done / wa_glass_player_turn3_done / wa_exchange_lily_gone / nv_mother_voice_done / py_jackal_walk_cue / bt_rooftop_fifth_spirit_spoken / end_epilogue_player_stand_cue | direct: Rama compare low byte == $FE |
| `$0006` | `0A00.6` | D1 | named record | record | both | sc_cave_statue_moved_ack / sc_house_bill_girl_line_ack / ir_ceiling_trap_zone_6_fired / mu_rama_spirit_e_talked / mu_lair_neil_remark_done / na_cottage_inventions_toured / na_plain_kara_stomach_remark_done / wa_glass_player_turn4_done / nv_beckon_kid_follow_accepted / py_jackal_departed_cue | direct: Rama compare low byte == $FE |
| `$0007` | `0A00.7` | D1 | named record | record | both | sc_cave_card_trick_req / sc_house_soldier_line_ack / mu_rama_spirit_f_talked / na_cottage_kara_cygnus_done / na_plain_lily_rocks_remark_done | direct: Rama compare low byte == $FE |
| `$0008` | `0A01.0` | D1 | named record | record | both | sc_cave_card_picked_ack / sc_house_kara_reply_ack / na_cottage_expedition_agreed / na_plain_lily_cygnus_hint_done / wa_glass_game_over_cue | direct: laborer hit counter (byte $0A01) |
| `$0009` | `0A01.1` | D1 | named record | record | both | sc_cave_erik_reaction_ack / sc_house_hamlet_release_req / na_plain_condor_quiz_solved | direct: laborer hit counter (byte $0A01) |
| `$000A` | `0A01.2` | D1 | named record | record | both | sc_cave_seth_explain_ack / sc_house_lola_viaduct_talk_req / ec_throne_guards_go_req / na_plain_lily_red_star_hint_done / bt_rooftop_fusion_burst_cue | direct: laborer hit counter (byte $0A01) |
| `$000B` | `0A01.3` | D1 | named record | record | both | sc_cave_lance_close_ack / sc_house_bill_prison_talk_ack / ec_throne_queen_prompt_req / na_plain_neil_at_left_foot | direct: laborer hit counter (byte $0A01) |
| `$000C` | `0A01.4` | D1 | named record | record | both | ec_throne_queen_done_ack / na_plain_erik_alarm_done | direct: laborer hit counter (byte $0A01) |
| `$000D` | `0A01.5` | D1 | named record | record | both | na_plain_object_landed / py_jackal_melody_heard | direct: laborer hit counter (byte $0A01) |
| `$000E` | `0A01.6` | D1 | named record | record | both | it_elder_go_declined / gs_dream_shira_talk_req / sp_fountain_stone_used_req / py_melody_playable / bt_rooftop_fusion_line_seen | direct: laborer hit counter (byte $0A01) |
| `$000F` | `0A01.7` | D1 | named record | record | both | it_elder_not_summoned_answer / ir_gold_tile_hint_shown / ir_wind_tunnel_switch_pressed / mu_connector_spikes_switch_hit / fr_freejia_showman_talk_req / fr_hotel_memory_melody_played_req / gw_switchback_switch_struck_req / sp_fountain_fade_active / mu_rama_finale_req / na_plain_buried_tile_inspected / wa_glass_player_may_drink / py_jackal_scene_active / py_vader_barrier_busy / bt_comet_spirit_gfx_loaded / bt_rooftop_spirits_gathered | helper: hit_switch_flags; direct: laborer hit counter (byte $0A01) |
| `$0010` | `0A02.0` | D2 | named record | record | both | sc_school_lesson_done / sys_boot_logo_first_shown |  |
| `$0011` | `0A02.1` | D2 | named record | record | both | sc_seth_door_jar_seen |  |
| `$0012` | `0A02.2` | D2 | named record | record | both | sc_wills_house_narration_seen |  |
| `$0013` | `0A02.3` | D2 | named record | record | both | sc_lance_house_narration_seen |  |
| `$0014` | `0A02.4` | D2 | named record | record | both | sc_erik_house_narration_seen |  |
| `$0015` | `0A02.5` | D2 | named record | record | both | sc_cave_intro_seen |  |
| `$0016` | `0A02.6` | D2 | named record | record | both | sc_cave_kara_news_done |  |
| `$0017` | `0A02.7` | D2 | named record | record | both | sc_cave_exit_dark_narration_seen |  |
| `$0018` | `0A03.0` | D2 | unreferenced | none | unreferenced |  |  |
| `$0019` | `0A03.1` | D2 | named record | record | both | ec_castle_kara_meeting_done |  |
| `$001A` | `0A03.2` | D2 | named record | record | both | ec_castle_kara_door_answered |  |
| `$001B` | `0A03.3` | D2 | named record | record | both | sc_kara_soldier_scene_done |  |
| `$001C` | `0A03.4` | D2 | named record | record | both | sc_dinner_night_passed |  |
| `$001D` | `0A03.5` | D2 | named record | record | both | sc_morning_narration_seen |  |
| `$001E` | `0A03.6` | D2 | unreferenced | none | unreferenced |  |  |
| `$001F` | `0A03.7` | D2 | unreferenced | none | unreferenced |  |  |
| `$0020` | `0A04.0` | D2 | named record | record | test-only | sc_cave_friends_idle |  |
| `$0021` | `0A04.1` | D2 | named record | record | both | ec_throne_room_done | scene-meta gate |
| `$0022` | `0A04.2` | D2 | named record | record | both | ec_castle_kara_escaped |  |
| `$0023` | `0A04.3` | D2 | named record | record | both | ec_prison_key_taken |  |
| `$0024` | `0A04.4` | D2 | named record | record | both | ec_prison_cell_door_unlocked |  |
| `$0025` | `0A04.5` | D2 | named record | record | both | sc_lily_met_in_house |  |
| `$0026` | `0A04.6` | D2 | named record | record | both | sc_itory_trip_started |  |
| `$0027` | `0A04.7` | D2 | named record | record | both | sc_guard_gate_open |  |
| `$0028` | `0A05.0` | D2 | unreferenced | none | unreferenced |  |  |
| `$0029` | `0A05.1` | D2 | named record | record | both | ma_mansion_intro_seen |  |
| `$002A` | `0A05.2` | D2 | named record | record | both | it_moon_tribe_revealed |  |
| `$002B` | `0A05.3` | D2 | named record | record | both | it_village_lily_intro_done |  |
| `$002C` | `0A05.4` | D2 | unreferenced | none | unreferenced |  |  |
| `$002D` | `0A05.5` | D2 | named record | record | both | it_cave_statue_a_item_given |  |
| `$002E` | `0A05.6` | D2 | named record | record | set-only | it_couple_house_incan_melody_played |  |
| `$002F` | `0A05.7` | D2 | named record | record | both | ir_entryway_block_placed |  |
| `$0030` | `0A06.0` | D2 | named record | record | both | ir_cliff_back_statue_a_placed |  |
| `$0031` | `0A06.1` | D2 | named record | record | both | ir_cliff_back_statue_b_placed |  |
| `$0032` | `0A06.2` | D2 | named record | record | both | ir_wind_melody_given |  |
| `$0033` | `0A06.3` | D2 | unreferenced | none | unreferenced |  |  |
| `$0034` | `0A06.4` | D2 | unreferenced | none | unreferenced |  |  |
| `$0035` | `0A06.5` | D2 | named record | record | both | sc_lola_melody_learned |  |
| `$0036` | `0A06.6` | D2 | unreferenced | none | unreferenced |  |  |
| `$0037` | `0A06.7` | D2 | named record | record | both | it_lily_house_departure_done |  |
| `$0038` | `0A07.0` | D2 | unreferenced | none | unreferenced |  |  |
| `$0039` | `0A07.1` | D2 | unreferenced | none | unreferenced |  |  |
| `$003A` | `0A07.2` | D2 | named record | record | both | ec_aqueduct_exit_lilly_met |  |
| `$003B` | `0A07.3` | D2 | named record | record | both | it_lola_bill_reunion_done |  |
| `$003C` | `0A07.4` | D2 | named record | record | both | ir_plate_puzzle_solved |  |
| `$003D` | `0A07.5` | D2 | named record | record | both | sc_kara_intro_done |  |
| `$003E` | `0A07.6` | D2 | named record | record | both | sc_dinner_invited |  |
| `$003F` | `0A07.7` | D2 | named record | record | both | ec_entrance_letter_shown |  |
| `$0040` | `0A08.0` | D2 | named record | record | both | it_meadow_lola_melody_played |  |
| `$0041` | `0A08.1` | D2 | named record | record | both | it_elder_voice_heard |  |
| `$0042` | `0A08.2` | D2 | named record | record | both | ec_prison_door_b_unlocked |  |
| `$0043` | `0A08.3` | D2 | named record | record | test-only | ec_prison_door_c_open |  |
| `$0044` | `0A08.4` | D2 | named record | record | both | it_elder_legend_heard |  |
| `$0045` | `0A08.5` | D2 | unreferenced | none | unreferenced |  |  |
| `$0046` | `0A08.6` | D2 | named record | record | both | ec_castle_barrel_roast_taken |  |
| `$0047` | `0A08.7` | D2 | named record | record | both | it_elder_statue_entrusted |  |
| `$0048` | `0A09.0` | D2 | named record | record | both | it_moon_cave_statue_b_item_given |  |
| `$0049` | `0A09.1` | D2 | named record | record | both | it_moon_camp_gate_opened |  |
| `$004A` | `0A09.2` | D2 | named record | record | both | it_moon_camp_ruins_trip_started |  |
| `$004B` | `0A09.3` | D2 | named record | record | both | ir_entrance_kara_catchup_done |  |
| `$004C` | `0A09.4` | D2 | named record | record | both | gs_ship_descent_done | scene-meta gate |
| `$004D` | `0A09.5` | D2 | named record | record | both | gs_wreck_palette_alt_set |  |
| `$004E` | `0A09.6` | D2 | named record | record | both | gs_queen_welcome_done |  |
| `$004F` | `0A09.7` | D2 | named record | record | both | gs_crows_nest_guard_talked |  |
| `$0050` | `0A0A.0` | D2 | named record | record | both | gs_wreck_interior_wakeup_done |  |
| `$0051` | `0A0A.1` | D2 | named record | record | both | gs_wreck_seth_cry_heard |  |
| `$0052` | `0A0A.2` | D2 | named record | record | both | gs_adrift_final_palette_set |  |
| `$0053` | `0A0A.3` | D2 | named record | record | both | fr_freejia_herb_taken |  |
| `$0054` | `0A0A.4` | D2 | named record | record | both | fr_freejia_hp_jewel_taken |  |
| `$0055` | `0A0A.5` | D2 | unreferenced | none | unreferenced |  |  |
| `$0056` | `0A0A.6` | D2 | named record | record | both | fr_oakton_departure_agreed |  |
| `$0057` | `0A0A.7` | D2 | named record | record | both | fr_freejia_hotel_guide_done |  |
| `$0058` | `0A0B.0` | D2 | named record | record | both | fr_hotel_reunion_done |  |
| `$0059` | `0A0B.1` | D2 | named record | record | both | fr_harborer_woman_talked |  |
| `$005A` | `0A0B.2` | D2 | named record | record | both | fr_slaver_told_hideout |  |
| `$005B` | `0A0B.3` | D2 | named record | record | both | dm_foyer_door_key_a_used |  |
| `$005C` | `0A0B.4` | D2 | named record | record | both | dm_foyer_door_key_b_used |  |
| `$005D` | `0A0B.5` | D2 | named record | record | both | dm_morgue_mine_key_taken |  |
| `$005E` | `0A0B.6` | D2 | named record | record | both | dm_sam_memory_melody_given |  |
| `$005F` | `0A0B.7` | D2 | unreferenced | none | unreferenced |  |  |
| `$0060` | `0A0C.0` | D2 | named record | record | both | sg_garden_pedestal_east_upper_crystal_set |  |
| `$0061` | `0A0C.1` | D2 | named record | record | both | sg_garden_pedestal_east_lower_crystal_set |  |
| `$0062` | `0A0C.2` | D2 | named record | record | both | sg_garden_pedestal_west_upper_crystal_set |  |
| `$0063` | `0A0C.3` | D2 | named record | record | both | sg_garden_pedestal_west_lower_crystal_set |  |
| `$0064` | `0A0C.4` | D2 | named record | record | both | fr_freejia_arrival_intro_done |  |
| `$0065` | `0A0C.5` | D2 | named record | record | both | fr_erik_rescued_done |  |
| `$0066` | `0A0C.6` | D2 | named record | record | both | fr_sam_erik_location_heard |  |
| `$0067` | `0A0C.7` | D2 | named record | record | both | fr_kidnapper_door_confronted |  |
| `$0068` | `0A0D.0` | D2 | named record | record | both | fr_hotel_lance_memory_restored |  |
| `$0069` | `0A0D.1` | D2 | named record | record | both | dm_elevator_key_used |  |
| `$006A` | `0A0D.2` | D2 | named record | record | both | dm_mine_entrance_intro_done |  |
| `$006B` | `0A0D.3` | D2 | named record | record | both | sg_garden_arrival_narration_seen |  |
| `$006C` | `0A0D.4` | D2 | named record | record | both | ir_larai_monologue_seen |  |
| `$006D` | `0A0D.5` | D2 | named record | record | set-only | na_cottage_party_left_for_nazca |  |
| `$006E` | `0A0D.6` | D2 | named record | record | both | sp_arrival_monologue_seen |  |
| `$006F` | `0A0D.7` | D2 | named record | record | both | sp_lilly_pocket_scene_done |  |
| `$0070` | `0A0E.0` | D2 | named record | record | both | sp_fountain_purified_done | scene-meta gate |
| `$0071` | `0A0E.1` | D2 | named record | record | both | sp_voice_palace_of_vampires_seen |  |
| `$0072` | `0A0E.2` | D2 | named record | record | both | sp_voice_basement_fountain_seen |  |
| `$0073` | `0A0E.3` | D2 | named record | record | both | sp_voice_purification_stone_seen |  |
| `$0074` | `0A0E.4` | D2 | named record | record | both | av_annex_lance_confided |  |
| `$0075` | `0A0E.5` | D2 | named record | record | both | av_entrance_arrival_scene_done |  |
| `$0076` | `0A0E.6` | D2 | named record | record | both | fr_oakton_rescuer_briefing_done |  |
| `$0077` | `0A0E.7` | D2 | named record | record | both | mu_arrival_monologue_seen |  |
| `$0078` | `0A0F.0` | D2 | named record | record | both | mu_west_room_visited |  |
| `$0079` | `0A0F.1` | D2 | named record | record | both | mu_west_hope_statue_taken |  |
| `$007A` | `0A0F.2` | D2 | named record | record | both | mu_south_statue_sightline_hint_seen |  |
| `$007B` | `0A0F.3` | D2 | named record | record | both | mu_hope_statue_west_placed | scene-meta gate |
| `$007C` | `0A0F.4` | D2 | named record | record | both | mu_water_lowered_remark_seen |  |
| `$007D` | `0A0F.5` | D2 | named record | record | both | sp_passage_lilly_remark_seen |  |
| `$007E` | `0A0F.6` | D2 | named record | record | both | mu_hope_statue_east_placed | scene-meta gate |
| `$007F` | `0A0F.7` | D2 | named record | record | both | mu_maze_hope_statue_taken |  |
| `$0080` | `0A10.0` | D2 | named record | record | both | mu_rama_statue_first_placed |  |
| `$0081` | `0A10.1` | D2 | named record | record | both | mu_rama_statue_second_placed |  |
| `$0082` | `0A10.2` | D2 | named record | record | both | mu_altar_burial_ground_seen |  |
| `$0083` | `0A10.3` | D2 | named record | record | both | sp_hint_right_room_life_seen |  |
| `$0084` | `0A10.4` | D2 | named record | record | both | sp_hint_left_room_life_seen |  |
| `$0085` | `0A10.5` | D2 | named record | record | both | sp_villager_palace_key_given |  |
| `$0086` | `0A10.6` | D2 | named record | record | both | mu_lair_erik_cry_seen |  |
| `$0087` | `0A10.7` | D2 | named record | record | both | mu_lair_vampire_intro_seen |  |
| `$0088` | `0A11.0` | D2 | named record | record | both | mu_lair_reunion_started | scene-meta gate |
| `$0089` | `0A11.1` | D2 | named record | record | both | av_ishtar_riddles_solved |  |
| `$008A` | `0A11.2` | D2 | named record | record | both | av_kara_portrait_kissed |  |
| `$008B` | `0A11.3` | D2 | named record | record | both | av_ishtar_portrait_speech_seen |  |
| `$008C` | `0A11.4` | D2 | named record | record | both | av_kara_rescued_from_portrait |  |
| `$008D` | `0A11.5` | D2 | named record | record | both | wa_arrival_cutscene_started |  |
| `$008E` | `0A11.6` | D2 | named record | record | both | sys_lance_letter_read |  |
| `$008F` | `0A11.7` | D2 | named record | record | both | wa_fireplace_journal_taken |  |
| `$0090` | `0A12.0` | D2 | named record | record | both | wa_lance_father_visit_done |  |
| `$0091` | `0A12.1` | D2 | named record | record | both | wa_lance_lily_exchange_done |  |
| `$0092` | `0A12.2` | D2 | named record | record | both | wa_kara_lance_letter_given |  |
| `$0093` | `0A12.3` | D2 | named record | record | both | gw_dive_lilly_cutscene_started |  |
| `$0094` | `0A12.4` | D2 | named record | record | both | wa_party_left_for_euro |  |
| `$0095` | `0A12.5` | D2 | named record | record | both | wa_glass_will_delivered |  |
| `$0096` | `0A12.6` | D2 | named record | record | both | wa_festival_night_active | scene-meta gate |
| `$0097` | `0A12.7` | D2 | named record | record | both | wa_glass_game_won |  |
| `$0098` | `0A13.0` | D2 | named record | record | helper-only | gw_entrance_necklace_stone_taken | helper: necklace_stone_flags |
| `$0099` | `0A13.1` | D2 | named record | record | helper-only | gw_dive_necklace_stone_taken | helper: necklace_stone_flags |
| `$009A` | `0A13.2` | D2 | unreferenced | none | unreferenced |  |  |
| `$009B` | `0A13.3` | D2 | unreferenced | none | unreferenced |  |  |
| `$009C` | `0A13.4` | D2 | unreferenced | none | unreferenced |  |  |
| `$009D` | `0A13.5` | D2 | named record | record | both | gw_trail_intro_seen |  |
| `$009E` | `0A13.6` | D2 | named record | record | both | eu_geezers_argument_seen |  |
| `$009F` | `0A13.7` | D2 | named record | record | both | eu_mt_kress_marked_on_map |  |
| `$00A0` | `0A14.0` | D2 | named record | record | helper-only | dm_laborer_main_a_freed | helper: diamond_mine_laborer_flags |
| `$00A1` | `0A14.1` | D2 | named record | record | helper-only | dm_laborer_main_b_freed | helper: diamond_mine_laborer_flags |
| `$00A2` | `0A14.2` | D2 | named record | record | helper-only | dm_laborer_nest_freed | helper: diamond_mine_laborer_flags |
| `$00A3` | `0A14.3` | D2 | named record | record | helper-only | dm_laborer_elevator_passage_freed | helper: diamond_mine_laborer_flags |
| `$00A4` | `0A14.4` | D2 | named record | record | both | eu_guest_room_neil_greeting_seen |  |
| `$00A5` | `0A14.5` | D2 | named record | record | both | eu_arrival_cutscene_played |  |
| `$00A6` | `0A14.6` | D2 | named record | record | both | eu_power_house_strength_taken |  |
| `$00A7` | `0A14.7` | D2 | named record | record | both | mt_kress_intro_seen |  |
| `$00A8` | `0A15.0` | D2 | named record | record | both | eu_teapot_used_in_mansion |  |
| `$00A9` | `0A15.1` | D2 | named record | record | both | av_annex_reunion_done |  |
| `$00AA` | `0A15.2` | D2 | named record | record | both | eu_neil_mansion_talk_done |  |
| `$00AB` | `0A15.3` | D2 | named record | record | both | eu_hamlet_morning_scene_done |  |
| `$00AC` | `0A15.4` | D2 | named record | record | both | nv_party_arrived_native_village |  |
| `$00AD` | `0A15.5` | D2 | named record | record | both | nv_party_house_search_started |  |
| `$00AE` | `0A15.6` | D2 | named record | record | both | nv_vacant_hut_checked |  |
| `$00AF` | `0A15.7` | D2 | named record | record | both | nv_sleep_cutscene_done |  |
| `$00B0` | `0A16.0` | D2 | named record | record | both | nv_party_rest_decided |  |
| `$00B1` | `0A16.1` | D2 | named record | record | both | nv_temple_drawn_on_map |  |
| `$00B2` | `0A16.2` | D2 | named record | record | both | nv_hamlet_cutscene_done |  |
| `$00B3` | `0A16.3` | D2 | named record | record | both | aw_entrance_intro_seen | scene-meta gate |
| `$00B4` | `0A16.4` | D2 | named record | record | both | da_neil_reunion_seen |  |
| `$00B5` | `0A16.5` | D2 | named record | record | both | aw_snake_pit_fall_effect_played |  |
| `$00B6` | `0A16.6` | D2 | named record | record | both | da_arrived_dao |  |
| `$00B7` | `0A16.7` | D2 | named record | record | both | aw_crystal_shrine_intro_seen |  |
| `$00B8` | `0A17.0` | D2 | named record | record | both | da_hotel_letter_and_journal_given |  |
| `$00B9` | `0A17.1` | D2 | named record | record | both | ir_secret_hallway_statue_destroyed |  |
| `$00BA` | `0A17.2` | D2 | named record | record | both | aw_black_crystal_glasses_taken |  |
| `$00BB` | `0A17.3` | D2 | named record | record | both | py_jackal_scene_done |  |
| `$00BC` | `0A17.4` | D2 | unreferenced | none | unreferenced |  |  |
| `$00BD` | `0A17.5` | D2 | named record | record | both | aw_pinnacle_vision_seen |  |
| `$00BE` | `0A17.6` | D2 | named record | record | both | aw_gorgon_flower_given |  |
| `$00BF` | `0A17.7` | D2 | named record | record | both | nv_statue1_petal_placed |  |
| `$00C0` | `0A18.0` | D2 | named record | record | both | nv_statue2_petal_placed |  |
| `$00C1` | `0A18.1` | D2 | named record | record | both | nv_statue3_petal_placed |  |
| `$00C2` | `0A18.2` | D2 | named record | record | both | py_hieroglyph_stone_1_taken |  |
| `$00C3` | `0A18.3` | D2 | named record | record | both | py_hieroglyph_stone_2_taken |  |
| `$00C4` | `0A18.4` | D2 | named record | record | both | py_hieroglyph_stone_3_taken |  |
| `$00C5` | `0A18.5` | D2 | named record | record | both | py_hieroglyph_stone_4_taken |  |
| `$00C6` | `0A18.6` | D2 | named record | record | both | py_hieroglyph_stone_5_taken |  |
| `$00C7` | `0A18.7` | D2 | named record | record | both | py_hieroglyph_stone_6_taken |  |
| `$00C8` | `0A19.0` | D2 | named record | record | both | gw_inner_reunion_scene_done |  |
| `$00C9` | `0A19.1` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CA` | `0A19.2` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CB` | `0A19.3` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CC` | `0A19.4` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CD` | `0A19.5` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CE` | `0A19.6` | D2 | unreferenced | none | unreferenced |  |  |
| `$00CF` | `0A19.7` | D2 | named record | record | both | nv_gorgon_hut_statues_restored |  |
| `$00D0` | `0A1A.0` | D2 | named record | record | both | py_kara_scene_done |  |
| `$00D1` | `0A1A.1` | D2 | named record | record | both | py_hieroglyph_puzzle_solved |  |
| `$00D2` | `0A1A.2` | D2 | named record | record | both | bt_entrance_monologue_seen |  |
| `$00D3` | `0A1A.3` | D2 | named record | record | both | bt_flute_discovery_monologue_seen |  |
| `$00D4` | `0A1A.4` | D2 | named record | record | both | bt_kara_following_will |  |
| `$00D5` | `0A1A.5` | D2 | unreferenced | none | unreferenced |  |  |
| `$00D6` | `0A1A.6` | D2 | named record | record | both | eu_ann_apple_errand_started |  |
| `$00D7` | `0A1A.7` | D2 | named record | record | both | sc_fisherman_pot_jewel_claimed |  |
| `$00D8` | `0A1B.0` | D2 | named record | record | both | ec_castle_right_guard_jewel_given |  |
| `$00D9` | `0A1B.1` | D2 | named record | record | both | dm_collapsed_tunnel_slave_freed |  |
| `$00DA` | `0A1B.2` | D2 | unreferenced | none | unreferenced |  |  |
| `$00DB` | `0A1B.3` | D2 | named record | record | both | end_epilogue_first_half_done |  |
| `$00DC` | `0A1B.4` | D2 | named record | record | both | sys_gaia_intro_heard |  |
| `$00DD` | `0A1B.5` | D2 | named record | record | both | sys_shadow_statue_first_used |  |
| `$00DE` | `0A1B.6` | D2 | named record | record | both | ec_aqueduct_lockway_lilly_seen |  |
| `$00DF` | `0A1B.7` | D2 | named record | record | both | ec_aqueduct_doorway_orb_played |  |
| `$00E0` | `0A1C.0` | D2 | named record | record | both | gs_seth_red_jewel_given |  |
| `$00E1` | `0A1C.1` | D2 | named record | record | both | fr_creep_red_jewel_given |  |
| `$00E2` | `0A1C.2` | D2 | named record | record | both | wa_lance_red_jewel_given |  |
| `$00E3` | `0A1C.3` | D2 | named record | record | both | eu_ann_first_apple_given |  |
| `$00E4` | `0A1C.4` | D2 | named record | record | both | eu_ann_second_apple_given |  |
| `$00E5` | `0A1C.5` | D2 | named record | record | both | eu_ann_red_jewel_given |  |
| `$00E6` | `0A1C.6` | D2 | named record | record | both | nv_gorgon_hut_red_jewel_given |  |
| `$00E7` | `0A1C.7` | D2 | named record | record | both | da_snake_panic_prize_given |  |
| `$00E8` | `0A1D.0` | D2 | named record | record | both | ma_solid_arm_intro_heard |  |
| `$00E9` | `0A1D.1` | D2 | named record | record | both | sys_jeweler_herb_given |  |
| `$00EA` | `0A1D.2` | D2 | named record | record | both | sys_jeweler_defense_given |  |
| `$00EB` | `0A1D.3` | D2 | named record | record | both | sys_jeweler_max_hp_given |  |
| `$00EC` | `0A1D.4` | D2 | named record | record | both | sys_jeweler_strength_given |  |
| `$00ED` | `0A1D.5` | D2 | named record | record | both | sys_jeweler_psycho_dash_given |  |
| `$00EE` | `0A1D.6` | D2 | named record | record | both | sys_jeweler_dark_friar_given |  |
| `$00EF` | `0A1D.7` | D2 | unreferenced | none | unreferenced |  |  |
| `$00F0` | `0A1E.0` | D2 | named record | record | both | eu_life_medicine_taken |  |
| `$00F1` | `0A1E.1` | D2 | named record | record | both | eu_dark_medicine_taken |  |
| `$00F2` | `0A1E.2` | D2 | named record | record | helper-only | py_trickle_orbs_a_fallen | helper: falling_orb_flags |
| `$00F3` | `0A1E.3` | D2 | named record | record | helper-only | py_trickle_orbs_b_fallen | helper: falling_orb_flags |
| `$00F4` | `0A1E.4` | D2 | named record | record | both | pr_prophecy_first_pass_active | scene-meta gate |
| `$00F5` | `0A1E.5` | D2 | named record | record | both | unused_mode7_boss_defeated |  |
| `$00F6` | `0A1E.6` | D2 | unreferenced | none | unreferenced |  |  |
| `$00F7` | `0A1E.7` | D2 | named record | record | both | sys_freedan_statue_first_used |  |
| `$00F8` | `0A1F.0` | D2 | test-only | proposal | test-only | (proposal) gs_mystic_statue_ceremony_done | helper: statue_reward_flags |
| `$00F9` | `0A1F.1` | D2 | named record | record | test-only | sg_viper_mystic_statue_collected | helper: statue_reward_flags |
| `$00FA` | `0A1F.2` | D2 | named record | record | helper-only | mu_mystic_statue_collected | helper: statue_reward_flags |
| `$00FB` | `0A1F.3` | D2 | named record | record | helper-only | gw_mystic_statue_collected | helper: statue_reward_flags |
| `$00FC` | `0A1F.4` | D2 | named record | record | test-only | py_mummy_queen_mystic_statue_collected | helper: statue_reward_flags |
| `$00FD` | `0A1F.5` | D2 | named record | record | test-only | bt_olman_mystic_statue_collected | helper: statue_reward_flags |
| `$00FE` | `0A1F.6` | D2 | unreferenced | none | unreferenced |  |  |
| `$00FF` | `0A1F.7` | D2 | named record | record | both | sys_scene_setup_done | direct: engine clear/set of flag $FF |
| `$0100` | `0A20.0` | D3 | table-only | table-row | table-only |  | event block row $00 |
| `$0101` | `0A20.1` | D3 | named record | record | table-only | ec_aqueduct_main_canal_worm_03_defeated | table: enemy_death_action_flags; event block row $01 |
| `$0102` | `0A20.2` | D3 | named record | record | table-only | ec_aqueduct_main_canal_worm_05_defeated | table: enemy_death_action_flags; event block row $02 |
| `$0103` | `0A20.3` | D3 | named record | record | table-only | ec_aqueduct_lockway_canal_worm_06_defeated | table: enemy_death_action_flags; event block row $03 |
| `$0104` | `0A20.4` | D3 | named record | record | both | ec_rusty_switch_pushed | word form; event block row $04 |
| `$0105` | `0A20.5` | D3 | named record | record | table-only | ec_aqueduct_hall_king_bat_0b_defeated | table: enemy_death_action_flags; event block row $05 |
| `$0106` | `0A20.6` | D3 | named record | record | set-only | ec_prison_cell_door_tiles_removed | word form; event block row $06 |
| `$0107` | `0A20.7` | D3 | table-only | table-row | table-only |  | event block row $07 |
| `$0108` | `0A21.0` | D3 | named record | record | set-only | ir_plate_gate_open | word form; event block row $08 |
| `$0109` | `0A21.1` | D3 | table-only | table-row | table-only |  | event block row $09 |
| `$010A` | `0A21.2` | D3 | named record | record | table-only | ir_inca_side_passage_four_way_0e_defeated | table: enemy_death_action_flags; event block row $0A |
| `$010B` | `0A21.3` | D3 | named record | record | table-only | ir_inca_guarded_gap_frozen_whirligig_13_defeated | table: enemy_death_action_flags; event block row $0B |
| `$010C` | `0A21.4` | D3 | named record | record | table-only | ir_inca_river_crossing_frozen_whirligig_19_defeated | table: enemy_death_action_flags; event block row $0C |
| `$010D` | `0A21.5` | D3 | named record | record | table-only | ir_larai_cliff_four_way_0c_defeated | table: enemy_death_action_flags; event block row $0D |
| `$010E` | `0A21.6` | D3 | named record | record | table-only | ir_larai_cliff_four_way_0d_defeated | table: enemy_death_action_flags; event block row $0E |
| `$010F` | `0A21.7` | D3 | named record | record | table-only | ir_larai_cliff_four_way_10_defeated | table: enemy_death_action_flags; event block row $0F |
| `$0110` | `0A22.0` | D3 | named record | record | table-only | ir_ceiling_trap_room_four_way_08_defeated | table: enemy_death_action_flags; event block row $10 |
| `$0111` | `0A22.1` | D3 | table-only | table-row | table-only |  | event block row $11 |
| `$0112` | `0A22.2` | D3 | named record | record | both | ir_glowing_tile_done | word form; event block row $12 |
| `$0113` | `0A22.3` | D3 | named record | record | both | ec_aqueduct_door_open | word form; event block row $13 |
| `$0114` | `0A22.4` | D3 | named record | record | both | ec_aqueduct_back_prop_hit_a | word form; event block row $14 |
| `$0115` | `0A22.5` | D3 | named record | record | set-only | ec_aqueduct_back_prop_hit_b | word form; event block row $15 |
| `$0116` | `0A22.6` | D3 | named record | record | test-only | ec_aqueduct_back_dark_space_open | word form; table: enemy_death_action_flags; event block row $16 |
| `$0117` | `0A22.7` | D3 | named record | record | table-only | ec_aqueduct_back_skull_chaser_17_defeated | table: enemy_death_action_flags; event block row $17 |
| `$0118` | `0A23.0` | D3 | named record | record | table-only | ec_aqueduct_back_skull_chaser_18_defeated | table: enemy_death_action_flags; event block row $18 |
| `$0119` | `0A23.1` | D3 | named record | record | set-only | sc_wills_house_ransacked | word form; event block row $19 |
| `$011A` | `0A23.2` | D3 | named record | record | both | it_cave_wall_broken | word form; event block row $1A |
| `$011B` | `0A23.3` | D3 | named record | record | set-only | it_cave_statue_a_taken | word form; event block row $1B |
| `$011C` | `0A23.4` | D3 | named record | record | both | it_moon_tribe_trial_done | word form; event block row $1C |
| `$011D` | `0A23.5` | D3 | named record | record | set-only | it_moon_tribe_statue_b_taken | word form; event block row $1D |
| `$011E` | `0A23.6` | D3 | table-only | table-row | table-only |  | event block row $1E |
| `$011F` | `0A23.7` | D3 | named record | record | both | ir_castoth_defeated | word form; event block row $1F |
| `$0120` | `0A24.0` | D3 | named record | record | set-only | gs_adrift_effect_layer_set | word form; event block row $20 |
| `$0121` | `0A24.1` | D3 | named record | record | both | dm_mine_collapse_done | word form; event block row $21 |
| `$0122` | `0A24.2` | D3 | named record | record | table-only | dm_mine_main_grundit_02_defeated | table: enemy_death_action_flags; event block row $22 |
| `$0123` | `0A24.3` | D3 | named record | record | table-only | dm_mine_zigzag_bat_spawner_07_defeated | table: enemy_death_action_flags; event block row $23 |
| `$0124` | `0A24.4` | D3 | named record | record | table-only | sg_garden_southwest_blue_cyber_04_defeated | table: enemy_death_action_flags; event block row $24 |
| `$0125` | `0A24.5` | D3 | named record | record | set-only | sg_garden_sw_blocker_a_top_set | word form; event block row $25 |
| `$0126` | `0A24.6` | D3 | named record | record | both | sg_garden_sw_blocker_a_underside_set | word form; event block row $26 |
| `$0127` | `0A24.7` | D3 | named record | record | both | sg_garden_sw_blocker_b_top_state1 | word form; event block row $27 |
| `$0128` | `0A25.0` | D3 | named record | record | set-only | sg_garden_sw_blocker_b_underside_state1 | word form; event block row $28 |
| `$0129` | `0A25.1` | D3 | named record | record | set-only | sg_garden_sw_blocker_b_top_state2 | word form; event block row $29 |
| `$012A` | `0A25.2` | D3 | named record | record | set-only | sg_garden_sw_blocker_b_underside_state2 | word form; event block row $2A |
| `$012B` | `0A25.3` | D3 | named record | record | table-only | sg_garden_southwest_blue_cyber_07_defeated | table: enemy_death_action_flags; event block row $2B |
| `$012C` | `0A25.4` | D3 | named record | record | table-only | sg_garden_southwest_dynapede2_10_defeated | table: enemy_death_action_flags; event block row $2C |
| `$012D` | `0A25.5` | D3 | named record | record | set-only | sg_garden_sw_switch_top_pressed | word form; event block row $2D |
| `$012E` | `0A25.6` | D3 | named record | record | both | sg_garden_sw_switch_underside_pressed | word form; event block row $2E |
| `$012F` | `0A25.7` | D3 | named record | record | both | sg_garden_west_underside_pressure_switch_done | word form; event block row $2F |
| `$0130` | `0A26.0` | D3 | named record | record | table-only | sg_garden_southeast_underside_red_cyber_09_defeated | table: enemy_death_action_flags; event block row $30 |
| `$0131` | `0A26.1` | D3 | named record | record | table-only | sg_garden_southwest_underside_red_cyber_08_defeated | table: enemy_death_action_flags; event block row $31 |
| `$0132` | `0A26.2` | D3 | named record | record | test-only | dm_hidden_dark_space_open | word form; table: enemy_death_action_flags; event block row $32 |
| `$0133` | `0A26.3` | D3 | named record | record | both | dm_promise_passage_wall_broken | word form; event block row $33 |
| `$0134` | `0A26.4` | D3 | named record | record | table-only | dm_mine_promise_passage_flayzer3_03_defeated | table: enemy_death_action_flags; event block row $34 |
| `$0135` | `0A26.5` | D3 | named record | record | table-only | dm_mine_promise_passage_eye_stalker1_07_defeated | table: enemy_death_action_flags; event block row $35 |
| `$0136` | `0A26.6` | D3 | named record | record | table-only | dm_mine_promise_passage_eye_stalker3_06_defeated | table: enemy_death_action_flags; event block row $36 |
| `$0137` | `0A26.7` | D3 | named record | record | table-only | sg_garden_southeast_blue_cyber_0b_defeated | table: enemy_death_action_flags; event block row $37 |
| `$0138` | `0A27.0` | D3 | both, no record | proposal | both | (proposal) sp_palace_entrance_open | word form; event block row $38 |
| `$0139` | `0A27.1` | D3 | named record | record | both | mu_rama_council_done | word form; event block row $39 |
| `$013A` | `0A27.2` | D3 | named record | record | both | sp_key_coffin_opened | word form; event block row $3A |
| `$013B` | `0A27.3` | D3 | named record | record | both | sp_stone_coffin_opened | word form; event block row $3B |
| `$013C` | `0A27.4` | D3 | table-only | table-row | table-only |  | event block row $3C |
| `$013D` | `0A27.5` | D3 | named record | record | table-only | mu_mu_entrance_cyclops2_05_defeated | table: enemy_death_action_flags; event block row $3D |
| `$013E` | `0A27.6` | D3 | named record | record | table-only | mu_mu_east_skuddle_06_defeated | table: enemy_death_action_flags; event block row $3E |
| `$013F` | `0A27.7` | D3 | named record | record | table-only | mu_mu_east_skuddle_08_defeated | table: enemy_death_action_flags; event block row $3F |
| `$0140` | `0A28.0` | D3 | named record | record | table-only | mu_mu_maze_skuddle_13_defeated | table: enemy_death_action_flags; event block row $40 |
| `$0141` | `0A28.1` | D3 | named record | record | table-only | mu_mu_maze_cyclops2_05_defeated | table: enemy_death_action_flags; event block row $41 |
| `$0142` | `0A28.2` | D3 | named record | record | table-only | mu_mu_west_slipper_09_defeated | table: enemy_death_action_flags; event block row $42 |
| `$0143` | `0A28.3` | D3 | named record | record | both | av_tunnel_river_passage_found | word form; event block row $43 |
| `$0144` | `0A28.4` | D3 | named record | record | both | av_tunnel_passage_73_found | word form; event block row $44 |
| `$0145` | `0A28.5` | D3 | table-only | table-row | table-only |  | event block row $45 |
| `$0146` | `0A28.6` | D3 | named record | record | set-only | mu_bomb_wire_cut_a | word form; event block row $46 |
| `$0147` | `0A28.7` | D3 | named record | record | set-only | mu_bomb_wire_cut_b | word form; event block row $47 |
| `$0148` | `0A29.0` | D3 | table-only | table-row | table-only |  | event block row $48 |
| `$0149` | `0A29.1` | D3 | named record | record | set-only | av_ishtar_door_1_open | word form; event block row $49 |
| `$014A` | `0A29.2` | D3 | named record | record | set-only | av_ishtar_door_2_open | word form; event block row $4A |
| `$014B` | `0A29.3` | D3 | named record | record | set-only | av_ishtar_door_3_open | word form; event block row $4B |
| `$014C` | `0A29.4` | D3 | named record | record | set-only | av_ishtar_door_4_open | word form; event block row $4C |
| `$014D` | `0A29.5` | D3 | named record | record | set-only | av_ishtar_door_5_open | word form; event block row $4D |
| `$014E` | `0A29.6` | D3 | named record | record | set-only | av_ishtar_door_6_open | word form; event block row $4E |
| `$014F` | `0A29.7` | D3 | named record | record | set-only | av_ishtar_door_7_open | word form; event block row $4F |
| `$0150` | `0A2A.0` | D3 | named record | record | set-only | av_ishtar_door_8_open | word form; event block row $50 |
| `$0151` | `0A2A.1` | D3 | named record | record | set-only | av_ishtar_test_passed | word form; event block row $51 |
| `$0152` | `0A2A.2` | D3 | named record | record | both | gw_dive_switch_hit | word form; event block row $52 |
| `$0153` | `0A2A.3` | D3 | named record | record | table-only | gw_wall_switchback_archer1_03_defeated | table: enemy_death_action_flags; event block row $53 |
| `$0154` | `0A2A.4` | D3 | table-only | table-row | table-only |  | event block row $54 |
| `$0155` | `0A2A.5` | D3 | table-only | table-row | table-only |  | event block row $55 |
| `$0156` | `0A2A.6` | D3 | table-only | table-row | table-only |  | event block row $56 |
| `$0157` | `0A2A.7` | D3 | table-only | table-row | table-only |  | event block row $57 |
| `$0158` | `0A2B.0` | D3 | table-only | table-row | table-only |  | event block row $58 |
| `$0159` | `0A2B.1` | D3 | named record | record | both | mt_crossroads_mushroom_gate_open | word form; event block row $59 |
| `$015A` | `0A2B.2` | D3 | table-only | table-row | table-only |  | event block row $5A |
| `$015B` | `0A2B.3` | D3 | table-only | table-row | table-only |  | event block row $5B |
| `$015C` | `0A2B.4` | D3 | table-only | table-row | table-only |  | event block row $5C |
| `$015D` | `0A2B.5` | D3 | table-only | table-row | table-only |  | event block row $5D |
| `$015E` | `0A2B.6` | D3 | table-only | table-row | table-only |  | event block row $5E |
| `$015F` | `0A2B.7` | D3 | named record | record | both | mt_circuit_mushroom_gate_a_open | word form; event block row $5F |
| `$0160` | `0A2C.0` | D3 | table-only | table-row | table-only |  | event block row $60 |
| `$0161` | `0A2C.1` | D3 | table-only | table-row | table-only |  | event block row $61 |
| `$0162` | `0A2C.2` | D3 | table-only | table-row | table-only |  | event block row $62 |
| `$0163` | `0A2C.3` | D3 | table-only | table-row | table-only |  | event block row $63 |
| `$0164` | `0A2C.4` | D3 | table-only | table-row | table-only |  | event block row $64 |
| `$0165` | `0A2C.5` | D3 | table-only | table-row | table-only |  | event block row $65 |
| `$0166` | `0A2C.6` | D3 | table-only | table-row | table-only |  | event block row $66 |
| `$0167` | `0A2C.7` | D3 | named record | record | both | mt_circuit_mushroom_gate_b_open | word form; event block row $67 |
| `$0168` | `0A2D.0` | D3 | named record | record | table-only | mt_kress_loop_yorrick_3_11_defeated | table: enemy_death_action_flags; event block row $68 |
| `$0169` | `0A2D.1` | D3 | table-only | table-row | table-only |  | event block row $69 |
| `$016A` | `0A2D.2` | D3 | named record | record | test-only | gw_sand_fanger_defeated | word form; table: enemy_death_action_flags; event block row $6A |
| `$016B` | `0A2D.3` | D3 | named record | record | test-only | aw_outer_east_wall_walker_defeated | word form; table: enemy_death_action_flags; event block row $6B |
| `$016C` | `0A2D.4` | D3 | named record | record | table-only | aw_angkor_outer_gate_wall_walker1_0f_defeated | table: enemy_death_action_flags; event block row $6C |
| `$016D` | `0A2D.5` | D3 | named record | record | table-only | aw_snake_pit_wall_walker1_04_defeated | table: enemy_death_action_flags; event block row $6D |
| `$016E` | `0A2D.6` | D3 | named record | record | both | aw_outer_north_ledge_opened | word form; event block row $6E |
| `$016F` | `0A2D.7` | D3 | named record | record | table-only | aw_angkor_inner_east_wall_walker4_08_defeated | table: enemy_death_action_flags; event block row $6F |
| `$0170` | `0A2E.0` | D3 | named record | record | both | py_meltdown_a_ledge_opened | word form; event block row $70 |
| `$0171` | `0A2E.1` | D3 | named record | record | both | py_meltdown_b_ledge_opened | word form; event block row $71 |
| `$0172` | `0A2E.2` | D3 | table-only | table-row | table-only |  | event block row $72 |
| `$0173` | `0A2E.3` | D3 | named record | record | helper-only | py_main_dark_space_open | helper: dark_space_portal_death_flags; table: enemy_death_action_flags; event block row $73 |
| `$0174` | `0A2E.4` | D3 | named record | record | both | gw_tomb_dark_space_open | word form; event block row $74 |
| `$0175` | `0A2E.5` | D3 | named record | record | both | bt_crystal_gate_a_open | word form; event block row $75 |
| `$0176` | `0A2E.6` | D3 | named record | record | both | bt_crystal_gate_b_open | word form; event block row $76 |
| `$0177` | `0A2E.7` | D3 | named record | record | both | bt_crystal_gate_c_open | word form; event block row $77 |
| `$0178` | `0A2F.0` | D3 | named record | record | both | bt_crystal_gate_d_open | word form; event block row $78 |
| `$0179` | `0A2F.1` | D3 | named record | record | both | bt_crystal_gate_e_open | word form; event block row $79 |
| `$017A` | `0A2F.2` | D3 | named record | record | set-only | dm_cell_door_open | word form; event block row $7A |
| `$017B` | `0A2F.3` | D3 | named record | record | set-only | dm_elevator_door_open | word form; event block row $7B |
| `$017C` | `0A2F.4` | D3 | named record | record | both | pr_legends_page_1_shown | word form; event block row $7C |
| `$017D` | `0A2F.5` | D3 | named record | record | both | pr_legends_page_2_shown | word form; event block row $7D |
| `$017E` | `0A2F.6` | D3 | named record | record | both | pr_legends_page_3_shown | word form; event block row $7E |
| `$017F` | `0A2F.7` | D3 | named record | record | both | pr_legends_page_4_shown | word form; event block row $7F |
| `$0180` | `0A30.0` | D3 | table-only | table-row | table-only |  | event block row $80 |
| `$0181` | `0A30.1` | D3 | table-only | table-row | table-only |  | event block row $81 |
| `$0182` | `0A30.2` | D3 | table-only | table-row | table-only |  | event block row $82 |
| `$0183` | `0A30.3` | D3 | table-only | table-row | table-only |  | event block row $83 |
| `$0184` | `0A30.4` | D3 | table-only | table-row | table-only |  | event block row $84 |
| `$0185` | `0A30.5` | D3 | set-only | proposal | set-only | (proposal) gs_ship_departure_started | word form; event block row $85 |
| `$0186` | `0A30.6` | D3 | table-only | table-row | table-only |  | event block row $86 |
| `$0187` | `0A30.7` | D3 | table-only | table-row | table-only |  | event block row $87 |
| `$0188` | `0A31.0` | D3 | table-only | table-row | table-only |  | event block row $88 |
| `$0189` | `0A31.1` | D3 | table-only | table-row | table-only |  | event block row $89 |
| `$018A` | `0A31.2` | D3 | table-only | table-row | table-only |  | event block row $8A |
| `$018B` | `0A31.3` | D3 | table-only | table-row | table-only |  | event block row $8B |
| `$018C` | `0A31.4` | D3 | table-only | table-row | table-only |  | event block row $8C |
| `$018D` | `0A31.5` | D3 | table-only | table-row | table-only |  | event block row $8D |
| `$018E` | `0A31.6` | D3 | table-only | table-row | table-only |  | event block row $8E |
| `$018F` | `0A31.7` | D3 | table-only | table-row | table-only |  | event block row $8F |
| `$0190` | `0A32.0` | D3 | table-only | table-row | table-only |  | event block row $90 |
| `$0191` | `0A32.1` | D3 | table-only | table-row | table-only |  | event block row $91 |
| `$0192` | `0A32.2` | D3 | table-only | table-row | table-only |  | event block row $92 |
| `$0193` | `0A32.3` | D3 | table-only | table-row | table-only |  | event block row $93 |
| `$0194` | `0A32.4` | D3 | table-only | table-row | table-only |  | event block row $94 |
| `$0195` | `0A32.5` | D3 | table-only | table-row | table-only |  | event block row $95 |
| `$0196` | `0A32.6` | D3 | table-only | table-row | table-only |  | event block row $96 |
| `$0197` | `0A32.7` | D3 | table-only | table-row | table-only |  | event block row $97 |
| `$0198` | `0A33.0` | D3 | table-only | table-row | table-only |  | event block row $98 |
| `$0199` | `0A33.1` | D3 | table-only | table-row | table-only |  | event block row $99 |
| `$019A` | `0A33.2` | D3 | named record | record | table-only | ma_mansion_flayzer3_07_defeated | table: enemy_death_action_flags; event block row $9A |
| `$019B` | `0A33.3` | D3 | named record | record | table-only | ma_mansion_eye_stalker3_12_defeated | table: enemy_death_action_flags; event block row $9B |
| `$019C` | `0A33.4` | D3 | table-only | table-row | table-only |  | event block row $9C |
| `$019D` | `0A33.5` | D3 | table-only | table-row | table-only |  | event block row $9D |
| `$019E` | `0A33.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$019F` | `0A33.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A0` | `0A34.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A1` | `0A34.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A2` | `0A34.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A3` | `0A34.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A4` | `0A34.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A5` | `0A34.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A6` | `0A34.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A7` | `0A34.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A8` | `0A35.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01A9` | `0A35.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AA` | `0A35.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AB` | `0A35.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AC` | `0A35.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AD` | `0A35.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AE` | `0A35.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01AF` | `0A35.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B0` | `0A36.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B1` | `0A36.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B2` | `0A36.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B3` | `0A36.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B4` | `0A36.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B5` | `0A36.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B6` | `0A36.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B7` | `0A36.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B8` | `0A37.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01B9` | `0A37.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BA` | `0A37.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BB` | `0A37.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BC` | `0A37.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BD` | `0A37.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BE` | `0A37.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01BF` | `0A37.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C0` | `0A38.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C1` | `0A38.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C2` | `0A38.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C3` | `0A38.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C4` | `0A38.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C5` | `0A38.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C6` | `0A38.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C7` | `0A38.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C8` | `0A39.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01C9` | `0A39.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CA` | `0A39.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CB` | `0A39.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CC` | `0A39.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CD` | `0A39.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CE` | `0A39.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01CF` | `0A39.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D0` | `0A3A.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D1` | `0A3A.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D2` | `0A3A.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D3` | `0A3A.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D4` | `0A3A.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D5` | `0A3A.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D6` | `0A3A.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D7` | `0A3A.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D8` | `0A3B.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01D9` | `0A3B.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DA` | `0A3B.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DB` | `0A3B.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DC` | `0A3B.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DD` | `0A3B.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DE` | `0A3B.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01DF` | `0A3B.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E0` | `0A3C.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E1` | `0A3C.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E2` | `0A3C.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E3` | `0A3C.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E4` | `0A3C.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E5` | `0A3C.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E6` | `0A3C.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E7` | `0A3C.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E8` | `0A3D.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01E9` | `0A3D.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01EA` | `0A3D.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01EB` | `0A3D.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01EC` | `0A3D.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01ED` | `0A3D.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01EE` | `0A3D.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01EF` | `0A3D.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F0` | `0A3E.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F1` | `0A3E.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F2` | `0A3E.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F3` | `0A3E.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F4` | `0A3E.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F5` | `0A3E.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F6` | `0A3E.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F7` | `0A3E.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F8` | `0A3F.0` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01F9` | `0A3F.1` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FA` | `0A3F.2` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FB` | `0A3F.3` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FC` | `0A3F.4` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FD` | `0A3F.5` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FE` | `0A3F.6` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$01FF` | `0A3F.7` | D3 | test-only | none | test-only |  | beyond the 158-row table: LookupEventBlock has no bound check |
| `$0200` | `0A40.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0201` | `0A40.1` | D4 | named record | record | table-only | ec_aqueduct_lockway_herb_chest_opened | table: barrier_chest_flags |
| `$0202` | `0A40.2` | D4 | named record | record | table-only | ec_aqueduct_treasure_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0203` | `0A40.3` | D4 | named record | record | table-only | ec_aqueduct_back_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0204` | `0A40.4` | D4 | named record | record | table-only | ir_larai_cliff_blue_block_chest_opened | table: barrier_chest_flags |
| `$0205` | `0A40.5` | D4 | named record | record | table-only | ir_inca_river_crossing_herb_chest_opened | table: barrier_chest_flags |
| `$0206` | `0A40.6` | D4 | named record | record | table-only | ir_inca_treasure_room_herb_chest_opened | table: barrier_chest_flags |
| `$0207` | `0A40.7` | D4 | named record | record | table-only | ir_inca_treasure_room_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0208` | `0A41.0` | D4 | named record | record | table-only | gs_ship_gold_interior_mystic_statue_chest_opened | table: barrier_chest_flags |
| `$0209` | `0A41.1` | D4 | named record | record | table-only | dm_mine_main_herb_chest_opened | table: barrier_chest_flags |
| `$020A` | `0A41.2` | D4 | named record | record | table-only | sg_garden_east_crystal_ball_chest_opened | table: barrier_chest_flags |
| `$020B` | `0A41.3` | D4 | named record | record | table-only | sg_garden_east_herb_chest_opened | table: barrier_chest_flags |
| `$020C` | `0A41.4` | D4 | named record | record | table-only | sg_garden_east_red_jewel_chest_opened | table: barrier_chest_flags |
| `$020D` | `0A41.5` | D4 | named record | record | table-only | sg_garden_southeast_underside_crystal_ball_chest_opened | table: barrier_chest_flags |
| `$020E` | `0A41.6` | D4 | named record | record | table-only | sg_garden_southwest_crystal_ball_chest_opened | table: barrier_chest_flags |
| `$020F` | `0A41.7` | D4 | named record | record | table-only | sg_garden_southwest_underside_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0210` | `0A42.0` | D4 | named record | record | table-only | sg_garden_west_herb_chest_opened | table: barrier_chest_flags |
| `$0211` | `0A42.1` | D4 | named record | record | table-only | sg_garden_west_crystal_ball_chest_opened | table: barrier_chest_flags |
| `$0212` | `0A42.2` | D4 | named record | record | table-only | sp_palace_main_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0213` | `0A42.3` | D4 | named record | record | table-only | sp_palace_rooms_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0214` | `0A42.4` | D4 | named record | record | table-only | sp_palace_coffins_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0215` | `0A42.5` | D4 | named record | record | table-only | mu_mu_entrance_rama_statue_chest_opened | table: barrier_chest_flags |
| `$0216` | `0A42.6` | D4 | named record | record | table-only | mu_mu_entrance_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0217` | `0A42.7` | D4 | named record | record | table-only | mu_mu_east_rama_statue_chest_opened | table: barrier_chest_flags |
| `$0218` | `0A43.0` | D4 | named record | record | table-only | mu_mu_south_empty_chest_opened | table: barrier_chest_flags |
| `$0219` | `0A43.1` | D4 | named record | record | table-only | av_angel_tunnel_river_red_jewel_chest_opened | table: barrier_chest_flags |
| `$021A` | `0A43.2` | D4 | named record | record | table-only | av_angel_tunnel_rooms_magic_dust_chest_opened | table: barrier_chest_flags |
| `$021B` | `0A43.3` | D4 | named record | record | table-only | av_angel_tunnel_test_herb_chest_opened | table: barrier_chest_flags |
| `$021C` | `0A43.4` | D4 | named record | record | table-only | av_angel_tunnel_test_red_jewel_chest_opened | table: barrier_chest_flags |
| `$021D` | `0A43.5` | D4 | named record | record | table-only | gw_wall_dive_red_jewel_chest_opened | table: barrier_chest_flags |
| `$021E` | `0A43.6` | D4 | named record | record | table-only | gw_wall_rampway_herb_chest_opened | table: barrier_chest_flags |
| `$021F` | `0A43.7` | D4 | named record | record | table-only | mt_kress_crossroads_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0220` | `0A44.0` | D4 | named record | record | table-only | mt_kress_loop_mushroom_drop_chest_opened | table: barrier_chest_flags |
| `$0221` | `0A44.1` | D4 | named record | record | table-only | mt_kress_mushrooms_mushroom_drop_chest_opened | table: barrier_chest_flags |
| `$0222` | `0A44.2` | D4 | named record | record | table-only | mt_kress_maze_mushroom_drop_chest_opened | table: barrier_chest_flags |
| `$0223` | `0A44.3` | D4 | named record | record | table-only | mt_kress_summit_teapot_chest_opened | table: barrier_chest_flags |
| `$0224` | `0A44.4` | D4 | named record | record | table-only | aw_angkor_outer_gate_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0225` | `0A44.5` | D4 | named record | record | table-only | aw_angkor_outer_west_herb_chest_opened | table: barrier_chest_flags |
| `$0226` | `0A44.6` | D4 | named record | record | table-only | aw_angkor_inner_west_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0227` | `0A44.7` | D4 | named record | record | table-only | aw_angkor_shrine_main_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0228` | `0A45.0` | D4 | named record | record | table-only | aw_angkor_shrine_upper_red_jewel_chest_opened | table: barrier_chest_flags |
| `$0229` | `0A45.1` | D4 | named record | record | table-only | py_pyramid_meltdown_b_red_jewel_chest_opened | table: barrier_chest_flags |
| `$022A` | `0A45.2` | D4 | named record | record | table-only | py_pyramid_trickle_a_red_jewel_chest_opened | table: barrier_chest_flags |
| `$022B` | `0A45.3` | D4 | named record | record | table-only | py_pyramid_vader_a_red_jewel_chest_opened | table: barrier_chest_flags |
| `$022C` | `0A45.4` | D4 | named record | record | table-only | py_pyramid_dangerslide_b_red_jewel_chest_opened | table: barrier_chest_flags |
| `$022D` | `0A45.5` | D4 | named record | record | table-only | ma_mansion_herb_chest_opened | table: barrier_chest_flags |
| `$022E` | `0A45.6` | D4 | named record | record | table-only | mu_mu_east_empty_chest_opened | table: barrier_chest_flags |
| `$022F` | `0A45.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0230` | `0A46.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0231` | `0A46.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0232` | `0A46.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0233` | `0A46.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0234` | `0A46.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0235` | `0A46.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0236` | `0A46.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0237` | `0A46.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0238` | `0A47.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0239` | `0A47.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$023A` | `0A47.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$023B` | `0A47.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$023C` | `0A47.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$023D` | `0A47.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$023E` | `0A47.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$023F` | `0A47.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0240` | `0A48.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0241` | `0A48.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0242` | `0A48.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0243` | `0A48.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0244` | `0A48.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0245` | `0A48.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0246` | `0A48.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0247` | `0A48.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0248` | `0A49.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0249` | `0A49.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$024A` | `0A49.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$024B` | `0A49.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$024C` | `0A49.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$024D` | `0A49.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$024E` | `0A49.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$024F` | `0A49.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0250` | `0A4A.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0251` | `0A4A.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0252` | `0A4A.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0253` | `0A4A.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0254` | `0A4A.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0255` | `0A4A.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0256` | `0A4A.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0257` | `0A4A.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0258` | `0A4B.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0259` | `0A4B.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$025A` | `0A4B.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$025B` | `0A4B.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$025C` | `0A4B.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$025D` | `0A4B.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$025E` | `0A4B.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$025F` | `0A4B.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0260` | `0A4C.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0261` | `0A4C.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0262` | `0A4C.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0263` | `0A4C.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0264` | `0A4C.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0265` | `0A4C.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0266` | `0A4C.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0267` | `0A4C.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0268` | `0A4D.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0269` | `0A4D.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$026A` | `0A4D.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$026B` | `0A4D.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$026C` | `0A4D.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$026D` | `0A4D.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$026E` | `0A4D.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$026F` | `0A4D.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0270` | `0A4E.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0271` | `0A4E.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0272` | `0A4E.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0273` | `0A4E.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0274` | `0A4E.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0275` | `0A4E.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0276` | `0A4E.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0277` | `0A4E.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0278` | `0A4F.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0279` | `0A4F.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$027A` | `0A4F.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$027B` | `0A4F.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$027C` | `0A4F.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$027D` | `0A4F.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$027E` | `0A4F.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$027F` | `0A4F.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0280` | `0A50.0` | D4 | named record | record | helper-only | sc_lances_house_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0281` | `0A50.1` | D4 | named record | record | helper-only | sc_south_cape_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0282` | `0A50.2` | D4 | named record | record | helper-only | ec_aqueduct_exit_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0283` | `0A50.3` | D4 | named record | record | helper-only | it_itory_village_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0284` | `0A50.4` | D4 | named record | record | helper-only | fr_oakton_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0285` | `0A50.5` | D4 | named record | record | helper-only | fr_freejia_hotel_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0286` | `0A50.6` | D4 | named record | record | helper-only | av_angel_rooms_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0287` | `0A50.7` | D4 | named record | record | helper-only | av_angel_tunnel_rooms_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0288` | `0A51.0` | D4 | named record | record | helper-only | wa_watermia_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0289` | `0A51.1` | D4 | named record | record | helper-only | wa_gambling_house_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028A` | `0A51.2` | D4 | named record | record | helper-only | eu_euro_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028B` | `0A51.3` | D4 | named record | record | helper-only | eu_dark_chapel_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028C` | `0A51.4` | D4 | named record | record | helper-only | nv_gorgon_hut_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028D` | `0A51.5` | D4 | named record | record | helper-only | da_dao_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028E` | `0A51.6` | D4 | named record | record | helper-only | py_pyramid_main_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$028F` | `0A51.7` | D4 | named record | record | helper-only | bt_babel_lower_floors_hidden_jewel_taken | helper: hidden_red_jewel_flags |
| `$0290` | `0A52.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0291` | `0A52.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$0292` | `0A52.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$0293` | `0A52.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$0294` | `0A52.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$0295` | `0A52.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$0296` | `0A52.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$0297` | `0A52.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0298` | `0A53.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$0299` | `0A53.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$029A` | `0A53.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$029B` | `0A53.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$029C` | `0A53.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$029D` | `0A53.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$029E` | `0A53.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$029F` | `0A53.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A0` | `0A54.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A1` | `0A54.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A2` | `0A54.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A3` | `0A54.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A4` | `0A54.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A5` | `0A54.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A6` | `0A54.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A7` | `0A54.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A8` | `0A55.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02A9` | `0A55.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AA` | `0A55.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AB` | `0A55.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AC` | `0A55.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AD` | `0A55.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AE` | `0A55.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02AF` | `0A55.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B0` | `0A56.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B1` | `0A56.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B2` | `0A56.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B3` | `0A56.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B4` | `0A56.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B5` | `0A56.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B6` | `0A56.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B7` | `0A56.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B8` | `0A57.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02B9` | `0A57.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BA` | `0A57.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BB` | `0A57.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BC` | `0A57.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BD` | `0A57.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BE` | `0A57.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02BF` | `0A57.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C0` | `0A58.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C1` | `0A58.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C2` | `0A58.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C3` | `0A58.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C4` | `0A58.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C5` | `0A58.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C6` | `0A58.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C7` | `0A58.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C8` | `0A59.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02C9` | `0A59.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CA` | `0A59.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CB` | `0A59.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CC` | `0A59.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CD` | `0A59.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CE` | `0A59.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02CF` | `0A59.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D0` | `0A5A.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D1` | `0A5A.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D2` | `0A5A.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D3` | `0A5A.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D4` | `0A5A.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D5` | `0A5A.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D6` | `0A5A.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D7` | `0A5A.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D8` | `0A5B.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02D9` | `0A5B.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DA` | `0A5B.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DB` | `0A5B.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DC` | `0A5B.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DD` | `0A5B.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DE` | `0A5B.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02DF` | `0A5B.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E0` | `0A5C.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E1` | `0A5C.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E2` | `0A5C.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E3` | `0A5C.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E4` | `0A5C.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E5` | `0A5C.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E6` | `0A5C.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E7` | `0A5C.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E8` | `0A5D.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02E9` | `0A5D.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02EA` | `0A5D.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02EB` | `0A5D.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02EC` | `0A5D.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02ED` | `0A5D.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02EE` | `0A5D.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02EF` | `0A5D.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F0` | `0A5E.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F1` | `0A5E.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F2` | `0A5E.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F3` | `0A5E.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F4` | `0A5E.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F5` | `0A5E.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F6` | `0A5E.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F7` | `0A5E.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F8` | `0A5F.0` | D4 | unreferenced | none | unreferenced |  |  |
| `$02F9` | `0A5F.1` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FA` | `0A5F.2` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FB` | `0A5F.3` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FC` | `0A5F.4` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FD` | `0A5F.5` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FE` | `0A5F.6` | D4 | unreferenced | none | unreferenced |  |  |
| `$02FF` | `0A5F.7` | D4 | unreferenced | none | unreferenced |  |  |
| `$0300` | `0A60.0` | D5 | unreferenced | none | unreferenced |  |  |
| `$0301` | `0A60.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0302` | `0A60.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0303` | `0A60.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0304` | `0A60.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0305` | `0A60.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0306` | `0A60.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0307` | `0A60.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0308` | `0A61.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0309` | `0A61.1` | D5 | unreferenced | none | unreferenced |  |  |
| `$030A` | `0A61.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$030B` | `0A61.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$030C` | `0A61.4` | D5 | named record | record | table-only | ec_aqueduct_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$030D` | `0A61.5` | D5 | named record | record | table-only | ec_aqueduct_main_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$030E` | `0A61.6` | D5 | named record | record | table-only | ec_aqueduct_lockway_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$030F` | `0A61.7` | D5 | named record | record | table-only | ec_aqueduct_hall_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0310` | `0A62.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0311` | `0A62.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0312` | `0A62.2` | D5 | named record | record | table-only | ec_aqueduct_back_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0313` | `0A62.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0314` | `0A62.4` | D5 | unreferenced | none | unreferenced |  |  |
| `$0315` | `0A62.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0316` | `0A62.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0317` | `0A62.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0318` | `0A63.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0319` | `0A63.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$031A` | `0A63.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$031B` | `0A63.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$031C` | `0A63.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$031D` | `0A63.5` | D5 | named record | record | table-only | ir_larai_cliff_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$031E` | `0A63.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$031F` | `0A63.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$0320` | `0A64.0` | D5 | named record | record | table-only | ir_inca_secret_hallway_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0321` | `0A64.1` | D5 | named record | record | table-only | ir_inca_river_crossing_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0322` | `0A64.2` | D5 | named record | record | table-only | ir_inca_river_detour_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0323` | `0A64.3` | D5 | named record | record | table-only | ir_inca_guarded_gap_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0324` | `0A64.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0325` | `0A64.5` | D5 | named record | record | table-only | ir_inca_entryway_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0326` | `0A64.6` | D5 | named record | record | table-only | ir_inca_treasure_room_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0327` | `0A64.7` | D5 | named record | record | table-only | ir_inca_side_passage_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0328` | `0A65.0` | D5 | named record | record | table-only | ir_ceiling_trap_room_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0329` | `0A65.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$032A` | `0A65.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$032B` | `0A65.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$032C` | `0A65.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$032D` | `0A65.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$032E` | `0A65.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$032F` | `0A65.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0330` | `0A66.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0331` | `0A66.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0332` | `0A66.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0333` | `0A66.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0334` | `0A66.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0335` | `0A66.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0336` | `0A66.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0337` | `0A66.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0338` | `0A67.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0339` | `0A67.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$033A` | `0A67.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$033B` | `0A67.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$033C` | `0A67.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$033D` | `0A67.5` | D5 | named record | record | table-only | dm_mine_promise_passage_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$033E` | `0A67.6` | D5 | named record | record | table-only | dm_mine_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$033F` | `0A67.7` | D5 | named record | record | table-only | dm_mine_main_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0340` | `0A68.0` | D5 | named record | record | table-only | dm_mine_collapsed_tunnel_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0341` | `0A68.1` | D5 | named record | record | table-only | dm_mine_zigzag_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0342` | `0A68.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0343` | `0A68.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0344` | `0A68.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0345` | `0A68.5` | D5 | named record | record | table-only | dm_mine_morgue_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0346` | `0A68.6` | D5 | named record | record | table-only | dm_mine_nest_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0347` | `0A68.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0348` | `0A69.0` | D5 | unreferenced | none | unreferenced |  |  |
| `$0349` | `0A69.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$034A` | `0A69.2` | D5 | unreferenced | none | unreferenced |  |  |
| `$034B` | `0A69.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$034C` | `0A69.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$034D` | `0A69.5` | D5 | named record | record | table-only | sg_garden_east_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$034E` | `0A69.6` | D5 | named record | record | table-only | sg_garden_east_underside_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$034F` | `0A69.7` | D5 | named record | record | table-only | sg_garden_southeast_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0350` | `0A6A.0` | D5 | named record | record | table-only | sg_garden_southeast_underside_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0351` | `0A6A.1` | D5 | named record | record | table-only | sg_garden_southwest_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0352` | `0A6A.2` | D5 | named record | record | table-only | sg_garden_southwest_underside_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0353` | `0A6A.3` | D5 | named record | record | table-only | sg_garden_west_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0354` | `0A6A.4` | D5 | named record | record | table-only | sg_garden_west_underside_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0355` | `0A6A.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$0356` | `0A6A.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0357` | `0A6A.7` | D5 | unreferenced | none | unreferenced |  |  |
| `$0358` | `0A6B.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0359` | `0A6B.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$035A` | `0A6B.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$035B` | `0A6B.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$035C` | `0A6B.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$035D` | `0A6B.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$035E` | `0A6B.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$035F` | `0A6B.7` | D5 | named record | record | table-only | mu_mu_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0360` | `0A6C.0` | D5 | named record | record | table-only | mu_mu_east_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0361` | `0A6C.1` | D5 | named record | record | table-only | mu_mu_south_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0362` | `0A6C.2` | D5 | named record | record | table-only | mu_mu_west_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0363` | `0A6C.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0364` | `0A6C.4` | D5 | named record | record | table-only | mu_mu_connector_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0365` | `0A6C.5` | D5 | named record | record | table-only | mu_mu_maze_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0366` | `0A6C.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0367` | `0A6C.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$0368` | `0A6D.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0369` | `0A6D.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$036A` | `0A6D.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$036B` | `0A6D.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$036C` | `0A6D.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$036D` | `0A6D.5` | D5 | named record | record | table-only | av_angel_tunnel_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$036E` | `0A6D.6` | D5 | named record | record | table-only | av_angel_tunnel_draco_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$036F` | `0A6D.7` | D5 | named record | record | table-only | av_angel_tunnel_dark_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0370` | `0A6E.0` | D5 | named record | record | table-only | av_angel_tunnel_river_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0371` | `0A6E.1` | D5 | named record | record | table-only | av_angel_tunnel_wind_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0372` | `0A6E.2` | D5 | named record | record | table-only | av_angel_tunnel_statue_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0373` | `0A6E.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0374` | `0A6E.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0375` | `0A6E.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0376` | `0A6E.6` | D5 | unreferenced | none | unreferenced |  |  |
| `$0377` | `0A6E.7` | D5 | unreferenced | none | unreferenced |  |  |
| `$0378` | `0A6F.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0379` | `0A6F.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037A` | `0A6F.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037B` | `0A6F.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037C` | `0A6F.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037D` | `0A6F.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037E` | `0A6F.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$037F` | `0A6F.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0380` | `0A70.0` | D5 | unreferenced | none | unreferenced |  |  |
| `$0381` | `0A70.1` | D5 | unreferenced | none | unreferenced |  |  |
| `$0382` | `0A70.2` | D5 | named record | record | table-only | gw_wall_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0383` | `0A70.3` | D5 | named record | record | table-only | gw_wall_dive_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0384` | `0A70.4` | D5 | named record | record | table-only | gw_scene_84_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0385` | `0A70.5` | D5 | named record | record | table-only | gw_wall_rampway_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0386` | `0A70.6` | D5 | named record | record | table-only | gw_wall_blind_pit_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0387` | `0A70.7` | D5 | named record | record | table-only | gw_wall_switchback_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0388` | `0A71.0` | D5 | named record | record | table-only | gw_wall_tomb_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$0389` | `0A71.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$038A` | `0A71.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$038B` | `0A71.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$038C` | `0A71.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$038D` | `0A71.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$038E` | `0A71.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$038F` | `0A71.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0390` | `0A72.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0391` | `0A72.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0392` | `0A72.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0393` | `0A72.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0394` | `0A72.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0395` | `0A72.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0396` | `0A72.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0397` | `0A72.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0398` | `0A73.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0399` | `0A73.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$039A` | `0A73.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$039B` | `0A73.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$039C` | `0A73.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$039D` | `0A73.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$039E` | `0A73.6` | D5 | unreferenced | none | unreferenced |  |  |
| `$039F` | `0A73.7` | D5 | unreferenced | none | unreferenced |  |  |
| `$03A0` | `0A74.0` | D5 | named record | record | table-only | mt_kress_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A1` | `0A74.1` | D5 | named record | record | table-only | mt_kress_twisted_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A2` | `0A74.2` | D5 | named record | record | table-only | mt_kress_crossroads_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A3` | `0A74.3` | D5 | named record | record | table-only | mt_kress_gauntlet_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A4` | `0A74.4` | D5 | named record | record | table-only | mt_kress_loop_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A5` | `0A74.5` | D5 | named record | record | table-only | mt_kress_circuit_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A6` | `0A74.6` | D5 | named record | record | table-only | mt_kress_mushrooms_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A7` | `0A74.7` | D5 | named record | record | table-only | mt_kress_maze_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A8` | `0A75.0` | D5 | named record | record | table-only | mt_kress_detour_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03A9` | `0A75.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03AA` | `0A75.2` | D5 | unreferenced | none | unreferenced |  |  |
| `$03AB` | `0A75.3` | D5 | unreferenced | none | unreferenced |  |  |
| `$03AC` | `0A75.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03AD` | `0A75.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03AE` | `0A75.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03AF` | `0A75.7` | D5 | unreferenced | none | unreferenced |  |  |
| `$03B0` | `0A76.0` | D5 | named record | record | table-only | aw_angkor_entrance_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B1` | `0A76.1` | D5 | named record | record | table-only | aw_angkor_outer_gate_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B2` | `0A76.2` | D5 | named record | record | table-only | aw_angkor_outer_east_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B3` | `0A76.3` | D5 | named record | record | table-only | aw_angkor_outer_north_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B4` | `0A76.4` | D5 | named record | record | table-only | aw_snake_pit_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B5` | `0A76.5` | D5 | named record | record | table-only | aw_angkor_outer_west_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B6` | `0A76.6` | D5 | named record | record | table-only | aw_angkor_outer_courtyard_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B7` | `0A76.7` | D5 | named record | record | table-only | aw_angkor_inner_gate_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B8` | `0A77.0` | D5 | named record | record | table-only | aw_angkor_inner_east_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03B9` | `0A77.1` | D5 | named record | record | table-only | aw_angkor_inner_west_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BA` | `0A77.2` | D5 | named record | record | table-only | aw_angkor_inner_courtyard_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BB` | `0A77.3` | D5 | named record | record | table-only | aw_angkor_shrine_main_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BC` | `0A77.4` | D5 | named record | record | table-only | aw_angkor_shrine_crystal_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BD` | `0A77.5` | D5 | named record | record | table-only | aw_angkor_shrine_dejavu_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BE` | `0A77.6` | D5 | named record | record | table-only | aw_angkor_shrine_upper_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03BF` | `0A77.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C0` | `0A78.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C1` | `0A78.1` | D5 | unreferenced | none | unreferenced |  |  |
| `$03C2` | `0A78.2` | D5 | unreferenced | none | unreferenced |  |  |
| `$03C3` | `0A78.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C4` | `0A78.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C5` | `0A78.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C6` | `0A78.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C7` | `0A78.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C8` | `0A79.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03C9` | `0A79.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03CA` | `0A79.2` | D5 | unreferenced | none | unreferenced |  |  |
| `$03CB` | `0A79.3` | D5 | unreferenced | none | unreferenced |  |  |
| `$03CC` | `0A79.4` | D5 | named record | record | table-only | py_pyramid_main_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03CD` | `0A79.5` | D5 | named record | record | table-only | py_puzzle_room_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03CE` | `0A79.6` | D5 | named record | record | table-only | py_pyramid_ramptastic_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03CF` | `0A79.7` | D5 | named record | record | table-only | py_pyramid_ramptastic_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D0` | `0A7A.0` | D5 | named record | record | table-only | py_pyramid_meltdown_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D1` | `0A7A.1` | D5 | named record | record | table-only | py_pyramid_meltdown_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D2` | `0A7A.2` | D5 | named record | record | table-only | py_pyramid_focus_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D3` | `0A7A.3` | D5 | named record | record | table-only | py_pyramid_focus_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D4` | `0A7A.4` | D5 | named record | record | table-only | py_pyramid_trickle_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D5` | `0A7A.5` | D5 | named record | record | table-only | py_pyramid_trickle_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D6` | `0A7A.6` | D5 | named record | record | table-only | py_pyramid_vader_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D7` | `0A7A.7` | D5 | named record | record | table-only | py_pyramid_vader_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D8` | `0A7B.0` | D5 | named record | record | table-only | py_pyramid_dangerslide_a_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03D9` | `0A7B.1` | D5 | named record | record | table-only | py_pyramid_dangerslide_b_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03DA` | `0A7B.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03DB` | `0A7B.3` | D5 | named record | record | table-only | py_pyramid_dangerslide_c_clear_reward_claimed | table: enemy_clear_reward_flags |
| `$03DC` | `0A7B.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03DD` | `0A7B.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03DE` | `0A7B.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03DF` | `0A7B.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E0` | `0A7C.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E1` | `0A7C.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E2` | `0A7C.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E3` | `0A7C.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E4` | `0A7C.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E5` | `0A7C.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E6` | `0A7C.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E7` | `0A7C.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03E8` | `0A7D.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03E9` | `0A7D.1` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03EA` | `0A7D.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03EB` | `0A7D.3` | D5 | unreferenced | none | unreferenced |  |  |
| `$03EC` | `0A7D.4` | D5 | unreferenced | none | unreferenced |  |  |
| `$03ED` | `0A7D.5` | D5 | unreferenced | none | unreferenced |  |  |
| `$03EE` | `0A7D.6` | D5 | unreferenced | none | unreferenced |  |  |
| `$03EF` | `0A7D.7` | D5 | unreferenced | none | unreferenced |  |  |
| `$03F0` | `0A7E.0` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03F1` | `0A7E.1` | D5 | unreferenced | none | unreferenced |  |  |
| `$03F2` | `0A7E.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03F3` | `0A7E.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03F4` | `0A7E.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03F5` | `0A7E.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03F6` | `0A7E.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): StandardEnemyDefeatHandler {56311}, radar_map_screen {229828}; scene has enemy-spawn rows |
| `$03F7` | `0A7E.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03F8` | `0A7F.0` | D5 | unreferenced | none | unreferenced |  |  |
| `$03F9` | `0A7F.1` | D5 | unreferenced | none | unreferenced |  |  |
| `$03FA` | `0A7F.2` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03FB` | `0A7F.3` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03FC` | `0A7F.4` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03FD` | `0A7F.5` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03FE` | `0A7F.6` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$03FF` | `0A7F.7` | D5 | test-only | none | test-only |  | dynamic test TestFlag_0300(sceneCurrent): radar_map_screen {229828}; scene has no enemy-spawn row |
| `$0400` | `0A80.0` | D6 | unreferenced | none | unreferenced |  |  |
| `$0401` | `0A80.1` | D6 | named record | record | table-only | sys_dungeon_enemy_01_killed | table: dungeon_kill_wram_flags |
| `$0402` | `0A80.2` | D6 | named record | record | table-only | sys_dungeon_enemy_02_killed | table: dungeon_kill_wram_flags |
| `$0403` | `0A80.3` | D6 | named record | record | table-only | sys_dungeon_enemy_03_killed | table: dungeon_kill_wram_flags |
| `$0404` | `0A80.4` | D6 | named record | record | table-only | sys_dungeon_enemy_04_killed | table: dungeon_kill_wram_flags |
| `$0405` | `0A80.5` | D6 | named record | record | table-only | sys_dungeon_enemy_05_killed | table: dungeon_kill_wram_flags |
| `$0406` | `0A80.6` | D6 | named record | record | table-only | sys_dungeon_enemy_06_killed | table: dungeon_kill_wram_flags |
| `$0407` | `0A80.7` | D6 | named record | record | table-only | sys_dungeon_enemy_07_killed | table: dungeon_kill_wram_flags |
| `$0408` | `0A81.0` | D6 | named record | record | table-only | sys_dungeon_enemy_08_killed | table: dungeon_kill_wram_flags |
| `$0409` | `0A81.1` | D6 | named record | record | table-only | sys_dungeon_enemy_09_killed | table: dungeon_kill_wram_flags |
| `$040A` | `0A81.2` | D6 | named record | record | table-only | sys_dungeon_enemy_0a_killed | table: dungeon_kill_wram_flags |
| `$040B` | `0A81.3` | D6 | named record | record | table-only | sys_dungeon_enemy_0b_killed | table: dungeon_kill_wram_flags |
| `$040C` | `0A81.4` | D6 | named record | record | table-only | sys_dungeon_enemy_0c_killed | table: dungeon_kill_wram_flags |
| `$040D` | `0A81.5` | D6 | named record | record | table-only | sys_dungeon_enemy_0d_killed | table: dungeon_kill_wram_flags |
| `$040E` | `0A81.6` | D6 | named record | record | table-only | sys_dungeon_enemy_0e_killed | table: dungeon_kill_wram_flags |
| `$040F` | `0A81.7` | D6 | named record | record | table-only | sys_dungeon_enemy_0f_killed | table: dungeon_kill_wram_flags |
| `$0410` | `0A82.0` | D6 | named record | record | table-only | sys_dungeon_enemy_10_killed | table: dungeon_kill_wram_flags |
| `$0411` | `0A82.1` | D6 | named record | record | table-only | sys_dungeon_enemy_11_killed | table: dungeon_kill_wram_flags |
| `$0412` | `0A82.2` | D6 | named record | record | table-only | sys_dungeon_enemy_12_killed | table: dungeon_kill_wram_flags |
| `$0413` | `0A82.3` | D6 | named record | record | table-only | sys_dungeon_enemy_13_killed | table: dungeon_kill_wram_flags |
| `$0414` | `0A82.4` | D6 | named record | record | table-only | sys_dungeon_enemy_14_killed | table: dungeon_kill_wram_flags |
| `$0415` | `0A82.5` | D6 | named record | record | table-only | sys_dungeon_enemy_15_killed | table: dungeon_kill_wram_flags |
| `$0416` | `0A82.6` | D6 | named record | record | table-only | sys_dungeon_enemy_16_killed | table: dungeon_kill_wram_flags |
| `$0417` | `0A82.7` | D6 | named record | record | table-only | sys_dungeon_enemy_17_killed | table: dungeon_kill_wram_flags |
| `$0418` | `0A83.0` | D6 | named record | record | table-only | sys_dungeon_enemy_18_killed | table: dungeon_kill_wram_flags |
| `$0419` | `0A83.1` | D6 | named record | record | table-only | sys_dungeon_enemy_19_killed | table: dungeon_kill_wram_flags |
| `$041A` | `0A83.2` | D6 | named record | record | table-only | sys_dungeon_enemy_1a_killed | table: dungeon_kill_wram_flags |
| `$041B` | `0A83.3` | D6 | named record | record | table-only | sys_dungeon_enemy_1b_killed | table: dungeon_kill_wram_flags |
| `$041C` | `0A83.4` | D6 | named record | record | table-only | sys_dungeon_enemy_1c_killed | table: dungeon_kill_wram_flags |
| `$041D` | `0A83.5` | D6 | named record | record | table-only | sys_dungeon_enemy_1d_killed | table: dungeon_kill_wram_flags |
| `$041E` | `0A83.6` | D6 | named record | record | table-only | sys_dungeon_enemy_1e_killed | table: dungeon_kill_wram_flags |
| `$041F` | `0A83.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0420` | `0A84.0` | D6 | named record | record | table-only | sys_dungeon_enemy_20_killed | table: dungeon_kill_wram_flags |
| `$0421` | `0A84.1` | D6 | named record | record | table-only | sys_dungeon_enemy_21_killed | table: dungeon_kill_wram_flags |
| `$0422` | `0A84.2` | D6 | named record | record | table-only | sys_dungeon_enemy_22_killed | table: dungeon_kill_wram_flags |
| `$0423` | `0A84.3` | D6 | named record | record | table-only | sys_dungeon_enemy_23_killed | table: dungeon_kill_wram_flags |
| `$0424` | `0A84.4` | D6 | named record | record | table-only | sys_dungeon_enemy_24_killed | table: dungeon_kill_wram_flags |
| `$0425` | `0A84.5` | D6 | named record | record | table-only | sys_dungeon_enemy_25_killed | table: dungeon_kill_wram_flags |
| `$0426` | `0A84.6` | D6 | named record | record | table-only | sys_dungeon_enemy_26_killed | table: dungeon_kill_wram_flags |
| `$0427` | `0A84.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0428` | `0A85.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0429` | `0A85.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042A` | `0A85.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042B` | `0A85.3` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042C` | `0A85.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042D` | `0A85.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042E` | `0A85.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$042F` | `0A85.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0430` | `0A86.0` | D6 | named record | record | table-only | sys_dungeon_enemy_30_killed | table: dungeon_kill_wram_flags |
| `$0431` | `0A86.1` | D6 | named record | record | table-only | sys_dungeon_enemy_31_killed | table: dungeon_kill_wram_flags |
| `$0432` | `0A86.2` | D6 | named record | record | table-only | sys_dungeon_enemy_32_killed | table: dungeon_kill_wram_flags |
| `$0433` | `0A86.3` | D6 | named record | record | table-only | sys_dungeon_enemy_33_killed | table: dungeon_kill_wram_flags |
| `$0434` | `0A86.4` | D6 | named record | record | table-only | sys_dungeon_enemy_34_killed | table: dungeon_kill_wram_flags |
| `$0435` | `0A86.5` | D6 | named record | record | table-only | sys_dungeon_enemy_35_killed | table: dungeon_kill_wram_flags |
| `$0436` | `0A86.6` | D6 | named record | record | table-only | sys_dungeon_enemy_36_killed | table: dungeon_kill_wram_flags |
| `$0437` | `0A86.7` | D6 | named record | record | table-only | sys_dungeon_enemy_37_killed | table: dungeon_kill_wram_flags |
| `$0438` | `0A87.0` | D6 | named record | record | table-only | sys_dungeon_enemy_38_killed | table: dungeon_kill_wram_flags |
| `$0439` | `0A87.1` | D6 | named record | record | table-only | sys_dungeon_enemy_39_killed | table: dungeon_kill_wram_flags |
| `$043A` | `0A87.2` | D6 | named record | record | table-only | sys_dungeon_enemy_3a_killed | table: dungeon_kill_wram_flags |
| `$043B` | `0A87.3` | D6 | named record | record | table-only | sys_dungeon_enemy_3b_killed | table: dungeon_kill_wram_flags |
| `$043C` | `0A87.4` | D6 | named record | record | table-only | sys_dungeon_enemy_3c_killed | table: dungeon_kill_wram_flags |
| `$043D` | `0A87.5` | D6 | named record | record | table-only | sys_dungeon_enemy_3d_killed | table: dungeon_kill_wram_flags |
| `$043E` | `0A87.6` | D6 | named record | record | table-only | sys_dungeon_enemy_3e_killed | table: dungeon_kill_wram_flags |
| `$043F` | `0A87.7` | D6 | named record | record | table-only | sys_dungeon_enemy_3f_killed | table: dungeon_kill_wram_flags |
| `$0440` | `0A88.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0441` | `0A88.1` | D6 | named record | record | table-only | sys_dungeon_enemy_41_killed | table: dungeon_kill_wram_flags |
| `$0442` | `0A88.2` | D6 | named record | record | table-only | sys_dungeon_enemy_42_killed | table: dungeon_kill_wram_flags |
| `$0443` | `0A88.3` | D6 | named record | record | table-only | sys_dungeon_enemy_43_killed | table: dungeon_kill_wram_flags |
| `$0444` | `0A88.4` | D6 | named record | record | table-only | sys_dungeon_enemy_44_killed | table: dungeon_kill_wram_flags |
| `$0445` | `0A88.5` | D6 | named record | record | table-only | sys_dungeon_enemy_45_killed | table: dungeon_kill_wram_flags |
| `$0446` | `0A88.6` | D6 | named record | record | table-only | sys_dungeon_enemy_46_killed | table: dungeon_kill_wram_flags |
| `$0447` | `0A88.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0448` | `0A89.0` | D6 | named record | record | table-only | sys_dungeon_enemy_48_killed | table: dungeon_kill_wram_flags |
| `$0449` | `0A89.1` | D6 | named record | record | table-only | sys_dungeon_enemy_49_killed | table: dungeon_kill_wram_flags |
| `$044A` | `0A89.2` | D6 | named record | record | table-only | sys_dungeon_enemy_4a_killed | table: dungeon_kill_wram_flags |
| `$044B` | `0A89.3` | D6 | named record | record | table-only | sys_dungeon_enemy_4b_killed | table: dungeon_kill_wram_flags |
| `$044C` | `0A89.4` | D6 | named record | record | table-only | sys_dungeon_enemy_4c_killed | table: dungeon_kill_wram_flags |
| `$044D` | `0A89.5` | D6 | named record | record | table-only | sys_dungeon_enemy_4d_killed | table: dungeon_kill_wram_flags |
| `$044E` | `0A89.6` | D6 | named record | record | table-only | sys_dungeon_enemy_4e_killed | table: dungeon_kill_wram_flags |
| `$044F` | `0A89.7` | D6 | named record | record | table-only | sys_dungeon_enemy_4f_killed | table: dungeon_kill_wram_flags |
| `$0450` | `0A8A.0` | D6 | named record | record | table-only | sys_dungeon_enemy_50_killed | table: dungeon_kill_wram_flags |
| `$0451` | `0A8A.1` | D6 | named record | record | table-only | sys_dungeon_enemy_51_killed | table: dungeon_kill_wram_flags |
| `$0452` | `0A8A.2` | D6 | named record | record | table-only | sys_dungeon_enemy_52_killed | table: dungeon_kill_wram_flags |
| `$0453` | `0A8A.3` | D6 | named record | record | table-only | sys_dungeon_enemy_53_killed | table: dungeon_kill_wram_flags |
| `$0454` | `0A8A.4` | D6 | named record | record | table-only | sys_dungeon_enemy_54_killed | table: dungeon_kill_wram_flags |
| `$0455` | `0A8A.5` | D6 | named record | record | table-only | sys_dungeon_enemy_55_killed | table: dungeon_kill_wram_flags |
| `$0456` | `0A8A.6` | D6 | named record | record | table-only | sys_dungeon_enemy_56_killed | table: dungeon_kill_wram_flags |
| `$0457` | `0A8A.7` | D6 | named record | record | table-only | sys_dungeon_enemy_57_killed | table: dungeon_kill_wram_flags |
| `$0458` | `0A8B.0` | D6 | named record | record | table-only | sys_dungeon_enemy_58_killed | table: dungeon_kill_wram_flags |
| `$0459` | `0A8B.1` | D6 | named record | record | table-only | sys_dungeon_enemy_59_killed | table: dungeon_kill_wram_flags |
| `$045A` | `0A8B.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$045B` | `0A8B.3` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$045C` | `0A8B.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$045D` | `0A8B.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$045E` | `0A8B.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$045F` | `0A8B.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0460` | `0A8C.0` | D6 | named record | record | table-only | sys_dungeon_enemy_60_killed | table: dungeon_kill_wram_flags |
| `$0461` | `0A8C.1` | D6 | named record | record | table-only | sys_dungeon_enemy_61_killed | table: dungeon_kill_wram_flags |
| `$0462` | `0A8C.2` | D6 | named record | record | table-only | sys_dungeon_enemy_62_killed | table: dungeon_kill_wram_flags |
| `$0463` | `0A8C.3` | D6 | named record | record | table-only | sys_dungeon_enemy_63_killed | table: dungeon_kill_wram_flags |
| `$0464` | `0A8C.4` | D6 | named record | record | table-only | sys_dungeon_enemy_64_killed | table: dungeon_kill_wram_flags |
| `$0465` | `0A8C.5` | D6 | named record | record | table-only | sys_dungeon_enemy_65_killed | table: dungeon_kill_wram_flags |
| `$0466` | `0A8C.6` | D6 | named record | record | table-only | sys_dungeon_enemy_66_killed | table: dungeon_kill_wram_flags |
| `$0467` | `0A8C.7` | D6 | named record | record | table-only | sys_dungeon_enemy_67_killed | table: dungeon_kill_wram_flags |
| `$0468` | `0A8D.0` | D6 | named record | record | table-only | sys_dungeon_enemy_68_killed | table: dungeon_kill_wram_flags |
| `$0469` | `0A8D.1` | D6 | named record | record | table-only | sys_dungeon_enemy_69_killed | table: dungeon_kill_wram_flags |
| `$046A` | `0A8D.2` | D6 | named record | record | table-only | sys_dungeon_enemy_6a_killed | table: dungeon_kill_wram_flags |
| `$046B` | `0A8D.3` | D6 | named record | record | table-only | sys_dungeon_enemy_6b_killed | table: dungeon_kill_wram_flags |
| `$046C` | `0A8D.4` | D6 | named record | record | table-only | sys_dungeon_enemy_6c_killed | table: dungeon_kill_wram_flags |
| `$046D` | `0A8D.5` | D6 | named record | record | table-only | sys_dungeon_enemy_6d_killed | table: dungeon_kill_wram_flags |
| `$046E` | `0A8D.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$046F` | `0A8D.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0470` | `0A8E.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0471` | `0A8E.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0472` | `0A8E.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0473` | `0A8E.3` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0474` | `0A8E.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0475` | `0A8E.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0476` | `0A8E.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0477` | `0A8E.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0478` | `0A8F.0` | D6 | named record | record | table-only | sys_dungeon_enemy_78_killed | table: dungeon_kill_wram_flags |
| `$0479` | `0A8F.1` | D6 | named record | record | table-only | sys_dungeon_enemy_79_killed | table: dungeon_kill_wram_flags |
| `$047A` | `0A8F.2` | D6 | named record | record | table-only | sys_dungeon_enemy_7a_killed | table: dungeon_kill_wram_flags |
| `$047B` | `0A8F.3` | D6 | named record | record | table-only | sys_dungeon_enemy_7b_killed | table: dungeon_kill_wram_flags |
| `$047C` | `0A8F.4` | D6 | named record | record | table-only | sys_dungeon_enemy_7c_killed | table: dungeon_kill_wram_flags |
| `$047D` | `0A8F.5` | D6 | named record | record | table-only | sys_dungeon_enemy_7d_killed | table: dungeon_kill_wram_flags |
| `$047E` | `0A8F.6` | D6 | named record | record | table-only | sys_dungeon_enemy_7e_killed | table: dungeon_kill_wram_flags |
| `$047F` | `0A8F.7` | D6 | named record | record | table-only | sys_dungeon_enemy_7f_killed | table: dungeon_kill_wram_flags |
| `$0480` | `0A90.0` | D6 | named record | record | table-only | sys_dungeon_enemy_80_killed | table: dungeon_kill_wram_flags |
| `$0481` | `0A90.1` | D6 | named record | record | table-only | sys_dungeon_enemy_81_killed | table: dungeon_kill_wram_flags |
| `$0482` | `0A90.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0483` | `0A90.3` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0484` | `0A90.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0485` | `0A90.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0486` | `0A90.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0487` | `0A90.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0488` | `0A91.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$0489` | `0A91.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048A` | `0A91.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048B` | `0A91.3` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048C` | `0A91.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048D` | `0A91.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048E` | `0A91.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$048F` | `0A91.7` | D6 | named record | record | table-only | sys_dungeon_enemy_8f_killed | table: dungeon_kill_wram_flags |
| `$0490` | `0A92.0` | D6 | named record | record | table-only | sys_dungeon_enemy_90_killed | table: dungeon_kill_wram_flags |
| `$0491` | `0A92.1` | D6 | named record | record | table-only | sys_dungeon_enemy_91_killed | table: dungeon_kill_wram_flags |
| `$0492` | `0A92.2` | D6 | named record | record | table-only | sys_dungeon_enemy_92_killed | table: dungeon_kill_wram_flags |
| `$0493` | `0A92.3` | D6 | named record | record | table-only | sys_dungeon_enemy_93_killed | table: dungeon_kill_wram_flags |
| `$0494` | `0A92.4` | D6 | named record | record | table-only | sys_dungeon_enemy_94_killed | table: dungeon_kill_wram_flags |
| `$0495` | `0A92.5` | D6 | named record | record | table-only | sys_dungeon_enemy_95_killed | table: dungeon_kill_wram_flags |
| `$0496` | `0A92.6` | D6 | named record | record | table-only | sys_dungeon_enemy_96_killed | table: dungeon_kill_wram_flags |
| `$0497` | `0A92.7` | D6 | named record | record | table-only | sys_dungeon_enemy_97_killed | table: dungeon_kill_wram_flags |
| `$0498` | `0A93.0` | D6 | named record | record | table-only | sys_dungeon_enemy_98_killed | table: dungeon_kill_wram_flags |
| `$0499` | `0A93.1` | D6 | named record | record | table-only | sys_dungeon_enemy_99_killed | table: dungeon_kill_wram_flags |
| `$049A` | `0A93.2` | D6 | named record | record | table-only | sys_dungeon_enemy_9a_killed | table: dungeon_kill_wram_flags |
| `$049B` | `0A93.3` | D6 | named record | record | table-only | sys_dungeon_enemy_9b_killed | table: dungeon_kill_wram_flags |
| `$049C` | `0A93.4` | D6 | named record | record | table-only | sys_dungeon_enemy_9c_killed | table: dungeon_kill_wram_flags |
| `$049D` | `0A93.5` | D6 | named record | record | table-only | sys_dungeon_enemy_9d_killed | table: dungeon_kill_wram_flags |
| `$049E` | `0A93.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$049F` | `0A93.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04A0` | `0A94.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04A1` | `0A94.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04A2` | `0A94.2` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04A3` | `0A94.3` | D6 | named record | record | table-only | sys_dungeon_enemy_a3_killed | table: dungeon_kill_wram_flags |
| `$04A4` | `0A94.4` | D6 | named record | record | table-only | sys_dungeon_enemy_a4_killed | table: dungeon_kill_wram_flags |
| `$04A5` | `0A94.5` | D6 | named record | record | table-only | sys_dungeon_enemy_a5_killed | table: dungeon_kill_wram_flags |
| `$04A6` | `0A94.6` | D6 | named record | record | table-only | sys_dungeon_enemy_a6_killed | table: dungeon_kill_wram_flags |
| `$04A7` | `0A94.7` | D6 | named record | record | table-only | sys_dungeon_enemy_a7_killed | table: dungeon_kill_wram_flags |
| `$04A8` | `0A95.0` | D6 | named record | record | table-only | sys_dungeon_enemy_a8_killed | table: dungeon_kill_wram_flags |
| `$04A9` | `0A95.1` | D6 | named record | record | table-only | sys_dungeon_enemy_a9_killed | table: dungeon_kill_wram_flags |
| `$04AA` | `0A95.2` | D6 | named record | record | table-only | sys_dungeon_enemy_aa_killed | table: dungeon_kill_wram_flags |
| `$04AB` | `0A95.3` | D6 | named record | record | table-only | sys_dungeon_enemy_ab_killed | table: dungeon_kill_wram_flags |
| `$04AC` | `0A95.4` | D6 | named record | record | table-only | sys_dungeon_enemy_ac_killed | table: dungeon_kill_wram_flags |
| `$04AD` | `0A95.5` | D6 | named record | record | table-only | sys_dungeon_enemy_ad_killed | table: dungeon_kill_wram_flags |
| `$04AE` | `0A95.6` | D6 | named record | record | table-only | sys_dungeon_enemy_ae_killed | table: dungeon_kill_wram_flags |
| `$04AF` | `0A95.7` | D6 | named record | record | table-only | sys_dungeon_enemy_af_killed | table: dungeon_kill_wram_flags |
| `$04B0` | `0A96.0` | D6 | named record | record | table-only | sys_dungeon_enemy_b0_killed | table: dungeon_kill_wram_flags |
| `$04B1` | `0A96.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04B2` | `0A96.2` | D6 | named record | record | table-only | sys_dungeon_enemy_b2_killed | table: dungeon_kill_wram_flags |
| `$04B3` | `0A96.3` | D6 | named record | record | table-only | sys_dungeon_enemy_b3_killed | table: dungeon_kill_wram_flags |
| `$04B4` | `0A96.4` | D6 | named record | record | table-only | sys_dungeon_enemy_b4_killed | table: dungeon_kill_wram_flags |
| `$04B5` | `0A96.5` | D6 | named record | record | table-only | sys_dungeon_enemy_b5_killed | table: dungeon_kill_wram_flags |
| `$04B6` | `0A96.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04B7` | `0A96.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04B8` | `0A97.0` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04B9` | `0A97.1` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04BA` | `0A97.2` | D6 | named record | record | table-only | sys_dungeon_enemy_ba_killed | table: dungeon_kill_wram_flags |
| `$04BB` | `0A97.3` | D6 | named record | record | table-only | sys_dungeon_enemy_bb_killed | table: dungeon_kill_wram_flags |
| `$04BC` | `0A97.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04BD` | `0A97.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04BE` | `0A97.6` | D6 | named record | record | table-only | sys_dungeon_enemy_be_killed | table: dungeon_kill_wram_flags |
| `$04BF` | `0A97.7` | D6 | named record | record | table-only | sys_dungeon_enemy_bf_killed | table: dungeon_kill_wram_flags |
| `$04C0` | `0A98.0` | D6 | named record | record | table-only | sys_dungeon_enemy_c0_killed | table: dungeon_kill_wram_flags |
| `$04C1` | `0A98.1` | D6 | named record | record | table-only | sys_dungeon_enemy_c1_killed | table: dungeon_kill_wram_flags |
| `$04C2` | `0A98.2` | D6 | named record | record | table-only | sys_dungeon_enemy_c2_killed | table: dungeon_kill_wram_flags |
| `$04C3` | `0A98.3` | D6 | named record | record | table-only | sys_dungeon_enemy_c3_killed | table: dungeon_kill_wram_flags |
| `$04C4` | `0A98.4` | D6 | named record | record | table-only | sys_dungeon_enemy_c4_killed | table: dungeon_kill_wram_flags |
| `$04C5` | `0A98.5` | D6 | named record | record | table-only | sys_dungeon_enemy_c5_killed | table: dungeon_kill_wram_flags |
| `$04C6` | `0A98.6` | D6 | named record | record | table-only | sys_dungeon_enemy_c6_killed | table: dungeon_kill_wram_flags |
| `$04C7` | `0A98.7` | D6 | named record | record | table-only | sys_dungeon_enemy_c7_killed | table: dungeon_kill_wram_flags |
| `$04C8` | `0A99.0` | D6 | named record | record | table-only | sys_dungeon_enemy_c8_killed | table: dungeon_kill_wram_flags |
| `$04C9` | `0A99.1` | D6 | named record | record | table-only | sys_dungeon_enemy_c9_killed | table: dungeon_kill_wram_flags |
| `$04CA` | `0A99.2` | D6 | named record | record | table-only | sys_dungeon_enemy_ca_killed | table: dungeon_kill_wram_flags |
| `$04CB` | `0A99.3` | D6 | named record | record | table-only | sys_dungeon_enemy_cb_killed | table: dungeon_kill_wram_flags |
| `$04CC` | `0A99.4` | D6 | named record | record | table-only | sys_dungeon_enemy_cc_killed | table: dungeon_kill_wram_flags |
| `$04CD` | `0A99.5` | D6 | named record | record | table-only | sys_dungeon_enemy_cd_killed | table: dungeon_kill_wram_flags |
| `$04CE` | `0A99.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04CF` | `0A99.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04D0` | `0A9A.0` | D6 | named record | record | table-only | sys_dungeon_enemy_d0_killed | table: dungeon_kill_wram_flags |
| `$04D1` | `0A9A.1` | D6 | named record | record | table-only | sys_dungeon_enemy_d1_killed | table: dungeon_kill_wram_flags |
| `$04D2` | `0A9A.2` | D6 | named record | record | table-only | sys_dungeon_enemy_d2_killed | table: dungeon_kill_wram_flags |
| `$04D3` | `0A9A.3` | D6 | named record | record | table-only | sys_dungeon_enemy_d3_killed | table: dungeon_kill_wram_flags |
| `$04D4` | `0A9A.4` | D6 | named record | record | table-only | sys_dungeon_enemy_d4_killed | table: dungeon_kill_wram_flags |
| `$04D5` | `0A9A.5` | D6 | named record | record | table-only | sys_dungeon_enemy_d5_killed | table: dungeon_kill_wram_flags |
| `$04D6` | `0A9A.6` | D6 | named record | record | table-only | sys_dungeon_enemy_d6_killed | table: dungeon_kill_wram_flags |
| `$04D7` | `0A9A.7` | D6 | named record | record | table-only | sys_dungeon_enemy_d7_killed | table: dungeon_kill_wram_flags |
| `$04D8` | `0A9B.0` | D6 | named record | record | table-only | sys_dungeon_enemy_d8_killed | table: dungeon_kill_wram_flags |
| `$04D9` | `0A9B.1` | D6 | named record | record | table-only | sys_dungeon_enemy_d9_killed | table: dungeon_kill_wram_flags |
| `$04DA` | `0A9B.2` | D6 | named record | record | table-only | sys_dungeon_enemy_da_killed | table: dungeon_kill_wram_flags |
| `$04DB` | `0A9B.3` | D6 | named record | record | table-only | sys_dungeon_enemy_db_killed | table: dungeon_kill_wram_flags |
| `$04DC` | `0A9B.4` | D6 | named record | record | table-only | sys_dungeon_enemy_dc_killed | table: dungeon_kill_wram_flags |
| `$04DD` | `0A9B.5` | D6 | named record | record | table-only | sys_dungeon_enemy_dd_killed | table: dungeon_kill_wram_flags |
| `$04DE` | `0A9B.6` | D6 | named record | record | table-only | sys_dungeon_enemy_de_killed | table: dungeon_kill_wram_flags |
| `$04DF` | `0A9B.7` | D6 | named record | record | table-only | sys_dungeon_enemy_df_killed | table: dungeon_kill_wram_flags |
| `$04E0` | `0A9C.0` | D6 | named record | record | table-only | sys_dungeon_enemy_e0_killed | table: dungeon_kill_wram_flags |
| `$04E1` | `0A9C.1` | D6 | named record | record | table-only | sys_dungeon_enemy_e1_killed | table: dungeon_kill_wram_flags |
| `$04E2` | `0A9C.2` | D6 | named record | record | table-only | sys_dungeon_enemy_e2_killed | table: dungeon_kill_wram_flags |
| `$04E3` | `0A9C.3` | D6 | named record | record | table-only | sys_dungeon_enemy_e3_killed | table: dungeon_kill_wram_flags |
| `$04E4` | `0A9C.4` | D6 | named record | record | table-only | sys_dungeon_enemy_e4_killed | table: dungeon_kill_wram_flags |
| `$04E5` | `0A9C.5` | D6 | named record | record | table-only | sys_dungeon_enemy_e5_killed | table: dungeon_kill_wram_flags |
| `$04E6` | `0A9C.6` | D6 | named record | record | table-only | sys_dungeon_enemy_e6_killed | table: dungeon_kill_wram_flags |
| `$04E7` | `0A9C.7` | D6 | named record | record | table-only | sys_dungeon_enemy_e7_killed | table: dungeon_kill_wram_flags |
| `$04E8` | `0A9D.0` | D6 | named record | record | table-only | sys_dungeon_enemy_e8_killed | table: dungeon_kill_wram_flags |
| `$04E9` | `0A9D.1` | D6 | named record | record | table-only | sys_dungeon_enemy_e9_killed | table: dungeon_kill_wram_flags |
| `$04EA` | `0A9D.2` | D6 | named record | record | table-only | sys_dungeon_enemy_ea_killed | table: dungeon_kill_wram_flags |
| `$04EB` | `0A9D.3` | D6 | named record | record | table-only | sys_dungeon_enemy_eb_killed | table: dungeon_kill_wram_flags |
| `$04EC` | `0A9D.4` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04ED` | `0A9D.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04EE` | `0A9D.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04EF` | `0A9D.7` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04F0` | `0A9E.0` | D6 | named record | record | table-only | sys_dungeon_enemy_f0_killed | table: dungeon_kill_wram_flags |
| `$04F1` | `0A9E.1` | D6 | named record | record | table-only | sys_dungeon_enemy_f1_killed | table: dungeon_kill_wram_flags |
| `$04F2` | `0A9E.2` | D6 | named record | record | table-only | sys_dungeon_enemy_f2_killed | table: dungeon_kill_wram_flags |
| `$04F3` | `0A9E.3` | D6 | named record | record | table-only | sys_dungeon_enemy_f3_killed | table: dungeon_kill_wram_flags |
| `$04F4` | `0A9E.4` | D6 | named record | record | table-only | sys_dungeon_enemy_f4_killed | table: dungeon_kill_wram_flags |
| `$04F5` | `0A9E.5` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04F6` | `0A9E.6` | D6 | table-only | table-row | table-only |  | table: dungeon_kill_wram_flags |
| `$04F7` | `0A9E.7` | D6 | unreferenced | none | unreferenced |  |  |
| `$04F8` | `0A9F.0` | D6 | named record | record | table-only | sys_dungeon_enemy_f8_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04F9` | `0A9F.1` | D6 | named record | record | table-only | sys_dungeon_enemy_f9_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FA` | `0A9F.2` | D6 | named record | record | table-only | sys_dungeon_enemy_fa_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FB` | `0A9F.3` | D6 | named record | record | table-only | sys_dungeon_enemy_fb_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FC` | `0A9F.4` | D6 | named record | record | table-only | sys_dungeon_enemy_fc_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FD` | `0A9F.5` | D6 | named record | record | table-only | sys_dungeon_enemy_fd_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FE` | `0A9F.6` | D6 | named record | record | table-only | sys_dungeon_enemy_fe_killed | table: dungeon_kill_wram_flags; direct: tomb mask byte $0A9F == $3F |
| `$04FF` | `0A9F.7` | D6 | direct read | none | direct-only |  | direct: tomb mask byte $0A9F == $3F |
| `$0500` | `0AA0.0` | D7b | named record | record | helper-only | ir_castoth_reward_claimed | helper: wram_offset_constant_callers; table: boss_reward_wram_flags |
| `$0501` | `0AA0.1` | D7b | named record | record | helper-only | sg_viper_reward_claimed | helper: wram_offset_constant_callers; table: boss_reward_wram_flags |
| `$0502` | `0AA0.2` | D7b | named record | record | helper-only | mu_vampires_reward_claimed | helper: wram_offset_constant_callers; table: boss_reward_wram_flags |
| `$0503` | `0AA0.3` | D7b | named record | record | helper-only | gw_sand_fanger_reward_claimed | helper: wram_offset_constant_callers; table: boss_reward_wram_flags |
| `$0504` | `0AA0.4` | D7b | named record | record | helper-only | py_mummy_queen_reward_claimed | helper: wram_offset_constant_callers; table: boss_reward_wram_flags |
| `$0505` | `0AA0.5` | D7b | table-only | table-row | table-only |  | table: boss_reward_wram_flags |
| `$0506` | `0AA0.6` | D7b | unreferenced | none | unreferenced |  |  |
| `$0507` | `0AA0.7` | D7b | unreferenced | none | unreferenced |  |  |
| `$0508` | `0AA1.0` | U | unreferenced | none | unreferenced |  |  |
| `$0509` | `0AA1.1` | U | unreferenced | none | unreferenced |  |  |
| `$050A` | `0AA1.2` | U | unreferenced | none | unreferenced |  |  |
| `$050B` | `0AA1.3` | U | unreferenced | none | unreferenced |  |  |
| `$050C` | `0AA1.4` | U | unreferenced | none | unreferenced |  |  |
| `$050D` | `0AA1.5` | U | unreferenced | none | unreferenced |  |  |
| `$050E` | `0AA1.6` | U | unreferenced | none | unreferenced |  |  |
| `$050F` | `0AA1.7` | U | unreferenced | none | unreferenced |  |  |
| `$0510` | `0AA2.0` | D7a | named record | record | helper+direct | sys_will_psycho_dash_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0005 |
| `$0511` | `0AA2.1` | D7a | named record | record | helper+direct | sys_will_psycho_slider_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0002 |
| `$0512` | `0AA2.2` | D7a | overlaps | proposal | helper+direct | (proposal) sys_will_spin_dash_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0005/$0004 |
| `$0513` | `0AA2.3` | D7a | overlaps | none | debug-only |  |  |
| `$0514` | `0AA2.4` | D7a | named record | record | helper+direct | sys_freedan_dark_friar_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0050 |
| `$0515` | `0AA2.5` | D7a | named record | record | helper+direct | sys_freedan_aura_barrier_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0020 |
| `$0516` | `0AA2.6` | D7a | named record | record | helper+direct | sys_freedan_earthquaker_unlocked | helper: inventory_ability_flags; direct: abilityBitmask BIT #$0050/$0040 |
| `$0517` | `0AA2.7` | D7a | overlaps | none | debug-only |  |  |
| `$0518` | `0AA3.0` | D7a | named record | record | helper-only | sys_shadow_ability_slot0_unlocked | helper: inventory_ability_flags |
| `$0519` | `0AA3.1` | D7a | named record | record | helper-only | sys_shadow_ability_slot1_unlocked | helper: inventory_ability_flags |
| `$051A` | `0AA3.2` | D7a | named record | record | helper-only | sys_shadow_ability_slot2_unlocked | helper: inventory_ability_flags |
| `$051B` | `0AA3.3` | D7a | overlaps | none | unreferenced |  |  |
| `$051C` | `0AA3.4` | D7a | overlaps | none | unreferenced |  |  |
| `$051D` | `0AA3.5` | D7a | overlaps | none | unreferenced |  |  |
| `$051E` | `0AA3.6` | D7a | overlaps | none | unreferenced |  |  |
| `$051F` | `0AA3.7` | D7a | overlaps | none | unreferenced |  |  |
| `$0520` | `0AA4.0` | S | overlaps | none | not-a-flag |  |  |
| `$0521` | `0AA4.1` | S | overlaps | none | not-a-flag |  |  |
| `$0522` | `0AA4.2` | S | overlaps | none | not-a-flag |  |  |
| `$0523` | `0AA4.3` | S | overlaps | none | not-a-flag |  |  |
| `$0524` | `0AA4.4` | S | overlaps | none | not-a-flag |  |  |
| `$0525` | `0AA4.5` | S | overlaps | none | not-a-flag |  |  |
| `$0526` | `0AA4.6` | S | overlaps | none | not-a-flag |  |  |
| `$0527` | `0AA4.7` | S | overlaps | none | not-a-flag |  |  |
| `$0528` | `0AA5.0` | S | overlaps | none | not-a-flag |  |  |
| `$0529` | `0AA5.1` | S | overlaps | none | not-a-flag |  |  |
| `$052A` | `0AA5.2` | S | overlaps | none | not-a-flag |  |  |
| `$052B` | `0AA5.3` | S | overlaps | none | not-a-flag |  |  |
| `$052C` | `0AA5.4` | S | overlaps | none | not-a-flag |  |  |
| `$052D` | `0AA5.5` | S | overlaps | none | not-a-flag |  |  |
| `$052E` | `0AA5.6` | S | overlaps | none | not-a-flag |  |  |
| `$052F` | `0AA5.7` | S | overlaps | none | not-a-flag |  |  |
| `$0530` | `0AA6.0` | S | overlaps | none | not-a-flag |  |  |
| `$0531` | `0AA6.1` | S | overlaps | none | not-a-flag |  |  |
| `$0532` | `0AA6.2` | S | overlaps | none | not-a-flag |  |  |
| `$0533` | `0AA6.3` | S | overlaps | none | not-a-flag |  |  |
| `$0534` | `0AA6.4` | S | overlaps | none | not-a-flag |  |  |
| `$0535` | `0AA6.5` | S | overlaps | none | not-a-flag |  |  |
| `$0536` | `0AA6.6` | S | overlaps | none | not-a-flag |  |  |
| `$0537` | `0AA6.7` | S | overlaps | none | not-a-flag |  |  |
| `$0538` | `0AA7.0` | S | overlaps | none | not-a-flag |  |  |
| `$0539` | `0AA7.1` | S | overlaps | none | not-a-flag |  |  |
| `$053A` | `0AA7.2` | S | overlaps | none | not-a-flag |  |  |
| `$053B` | `0AA7.3` | S | overlaps | none | not-a-flag |  |  |
| `$053C` | `0AA7.4` | S | overlaps | none | not-a-flag |  |  |
| `$053D` | `0AA7.5` | S | overlaps | none | not-a-flag |  |  |
| `$053E` | `0AA7.6` | S | overlaps | none | not-a-flag |  |  |
| `$053F` | `0AA7.7` | S | overlaps | none | not-a-flag |  |  |
| `$0540` | `0AA8.0` | S | overlaps | none | not-a-flag |  |  |
| `$0541` | `0AA8.1` | S | overlaps | none | not-a-flag |  |  |
| `$0542` | `0AA8.2` | S | overlaps | none | not-a-flag |  |  |
| `$0543` | `0AA8.3` | S | overlaps | none | not-a-flag |  |  |
| `$0544` | `0AA8.4` | S | overlaps | none | not-a-flag |  |  |
| `$0545` | `0AA8.5` | S | overlaps | none | not-a-flag |  |  |
| `$0546` | `0AA8.6` | S | overlaps | none | not-a-flag |  |  |
| `$0547` | `0AA8.7` | S | overlaps | none | not-a-flag |  |  |
| `$0548` | `0AA9.0` | S | overlaps | none | not-a-flag |  |  |
| `$0549` | `0AA9.1` | S | overlaps | none | not-a-flag |  |  |
| `$054A` | `0AA9.2` | S | overlaps | none | not-a-flag |  |  |
| `$054B` | `0AA9.3` | S | overlaps | none | not-a-flag |  |  |
| `$054C` | `0AA9.4` | S | overlaps | none | not-a-flag |  |  |
| `$054D` | `0AA9.5` | S | overlaps | none | not-a-flag |  |  |
| `$054E` | `0AA9.6` | S | overlaps | none | not-a-flag |  |  |
| `$054F` | `0AA9.7` | S | overlaps | none | not-a-flag |  |  |
| `$0550` | `0AAA.0` | S | overlaps | none | not-a-flag |  |  |
| `$0551` | `0AAA.1` | S | overlaps | none | not-a-flag |  |  |
| `$0552` | `0AAA.2` | S | overlaps | none | not-a-flag |  |  |
| `$0553` | `0AAA.3` | S | overlaps | none | not-a-flag |  |  |
| `$0554` | `0AAA.4` | S | overlaps | none | not-a-flag |  |  |
| `$0555` | `0AAA.5` | S | overlaps | none | not-a-flag |  |  |
| `$0556` | `0AAA.6` | S | overlaps | none | not-a-flag |  |  |
| `$0557` | `0AAA.7` | S | overlaps | none | not-a-flag |  |  |
| `$0558` | `0AAB.0` | S | overlaps | none | not-a-flag |  |  |
| `$0559` | `0AAB.1` | S | overlaps | none | not-a-flag |  |  |
| `$055A` | `0AAB.2` | S | overlaps | none | not-a-flag |  |  |
| `$055B` | `0AAB.3` | S | overlaps | none | not-a-flag |  |  |
| `$055C` | `0AAB.4` | S | overlaps | none | not-a-flag |  |  |
| `$055D` | `0AAB.5` | S | overlaps | none | not-a-flag |  |  |
| `$055E` | `0AAB.6` | S | overlaps | none | not-a-flag |  |  |
| `$055F` | `0AAB.7` | S | overlaps | none | not-a-flag |  |  |
| `$0560` | `0AAC.0` | S | overlaps | none | not-a-flag |  |  |
| `$0561` | `0AAC.1` | S | overlaps | none | not-a-flag |  |  |
| `$0562` | `0AAC.2` | S | overlaps | none | not-a-flag |  |  |
| `$0563` | `0AAC.3` | S | overlaps | none | not-a-flag |  |  |
| `$0564` | `0AAC.4` | S | overlaps | none | not-a-flag |  |  |
| `$0565` | `0AAC.5` | S | overlaps | none | not-a-flag |  |  |
| `$0566` | `0AAC.6` | S | overlaps | none | not-a-flag |  |  |
| `$0567` | `0AAC.7` | S | overlaps | none | not-a-flag |  |  |
| `$0568` | `0AAD.0` | S | overlaps | none | not-a-flag |  |  |
| `$0569` | `0AAD.1` | S | overlaps | none | not-a-flag |  |  |
| `$056A` | `0AAD.2` | S | overlaps | none | not-a-flag |  |  |
| `$056B` | `0AAD.3` | S | overlaps | none | not-a-flag |  |  |
| `$056C` | `0AAD.4` | S | overlaps | none | not-a-flag |  |  |
| `$056D` | `0AAD.5` | S | overlaps | none | not-a-flag |  |  |
| `$056E` | `0AAD.6` | S | overlaps | none | not-a-flag |  |  |
| `$056F` | `0AAD.7` | S | overlaps | none | not-a-flag |  |  |
| `$0570` | `0AAE.0` | S | overlaps | none | not-a-flag |  |  |
| `$0571` | `0AAE.1` | S | overlaps | none | not-a-flag |  |  |
| `$0572` | `0AAE.2` | S | overlaps | none | not-a-flag |  |  |
| `$0573` | `0AAE.3` | S | overlaps | none | not-a-flag |  |  |
| `$0574` | `0AAE.4` | S | overlaps | none | not-a-flag |  |  |
| `$0575` | `0AAE.5` | S | overlaps | none | not-a-flag |  |  |
| `$0576` | `0AAE.6` | S | overlaps | none | not-a-flag |  |  |
| `$0577` | `0AAE.7` | S | overlaps | none | not-a-flag |  |  |
| `$0578` | `0AAF.0` | S | overlaps | none | not-a-flag |  |  |
| `$0579` | `0AAF.1` | S | overlaps | none | not-a-flag |  |  |
| `$057A` | `0AAF.2` | S | overlaps | none | not-a-flag |  |  |
| `$057B` | `0AAF.3` | S | overlaps | none | not-a-flag |  |  |
| `$057C` | `0AAF.4` | S | overlaps | none | not-a-flag |  |  |
| `$057D` | `0AAF.5` | S | overlaps | none | not-a-flag |  |  |
| `$057E` | `0AAF.6` | S | overlaps | none | not-a-flag |  |  |
| `$057F` | `0AAF.7` | S | overlaps | none | not-a-flag |  |  |
| `$0580` | `0AB0.0` | S | overlaps | none | not-a-flag |  |  |
| `$0581` | `0AB0.1` | S | overlaps | none | not-a-flag |  |  |
| `$0582` | `0AB0.2` | S | overlaps | none | not-a-flag |  |  |
| `$0583` | `0AB0.3` | S | overlaps | none | not-a-flag |  |  |
| `$0584` | `0AB0.4` | S | overlaps | none | not-a-flag |  |  |
| `$0585` | `0AB0.5` | S | overlaps | none | not-a-flag |  |  |
| `$0586` | `0AB0.6` | S | overlaps | none | not-a-flag |  |  |
| `$0587` | `0AB0.7` | S | overlaps | none | not-a-flag |  |  |
| `$0588` | `0AB1.0` | S | overlaps | none | not-a-flag |  |  |
| `$0589` | `0AB1.1` | S | overlaps | none | not-a-flag |  |  |
| `$058A` | `0AB1.2` | S | overlaps | none | not-a-flag |  |  |
| `$058B` | `0AB1.3` | S | overlaps | none | not-a-flag |  |  |
| `$058C` | `0AB1.4` | S | overlaps | none | not-a-flag |  |  |
| `$058D` | `0AB1.5` | S | overlaps | none | not-a-flag |  |  |
| `$058E` | `0AB1.6` | S | overlaps | none | not-a-flag |  |  |
| `$058F` | `0AB1.7` | S | overlaps | none | not-a-flag |  |  |
| `$0590` | `0AB2.0` | S | overlaps | none | not-a-flag |  |  |
| `$0591` | `0AB2.1` | S | overlaps | none | not-a-flag |  |  |
| `$0592` | `0AB2.2` | S | overlaps | none | not-a-flag |  |  |
| `$0593` | `0AB2.3` | S | overlaps | none | not-a-flag |  |  |
| `$0594` | `0AB2.4` | S | overlaps | none | not-a-flag |  |  |
| `$0595` | `0AB2.5` | S | overlaps | none | not-a-flag |  |  |
| `$0596` | `0AB2.6` | S | overlaps | none | not-a-flag |  |  |
| `$0597` | `0AB2.7` | S | overlaps | none | not-a-flag |  |  |
| `$0598` | `0AB3.0` | S | overlaps | none | not-a-flag |  |  |
| `$0599` | `0AB3.1` | S | overlaps | none | not-a-flag |  |  |
| `$059A` | `0AB3.2` | S | overlaps | none | not-a-flag |  |  |
| `$059B` | `0AB3.3` | S | overlaps | none | not-a-flag |  |  |
| `$059C` | `0AB3.4` | S | overlaps | none | not-a-flag |  |  |
| `$059D` | `0AB3.5` | S | overlaps | none | not-a-flag |  |  |
| `$059E` | `0AB3.6` | S | overlaps | none | not-a-flag |  |  |
| `$059F` | `0AB3.7` | S | overlaps | none | not-a-flag |  |  |
