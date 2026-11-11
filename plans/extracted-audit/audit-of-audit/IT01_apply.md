# IT-01 apply: `scene_script.asm` notes (PLAN F01)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT01_spec.json` (one spec, one file: `system/engine/scene_script.asm`; block note by `edit` ops, six part notes as full text, four comments with `expect` guards). Because the block note uses `edit` ops, re-running the spec reports an error instead of `=unchanged`.

## Items

| finding id | file:line (live, after merge) | status | note |
|---|---|---|---|
| N-1 / A07-10 (rows) | `scene_script.asm:17, 18, 19` | APPLIED | Rows `$04` (palette colours into `cgramPalette`, `< start, end, dest >`), `$05` (metatile sets for layer 0 and/or 1, then the metatile flag table), `$06` (layer maps: width, height, compressed map; with no layer bit set a tileset to low VRAM). Re-derived from `SceneCmd_LoadPalette` (648), `SceneCmd_LoadMetatileSets` (689), `SceneCmd_LoadLayerMaps` (776) and `DmaRomToWram` (dest = `$42` + `$0668`, source = `$3E` + `$0664`). |
| N-1 (row `$14`) | `:24` | APPLIED | Label: no-op that skips its id byte; the position is what jump (`$15`) and branch (`$13`) continue at. Rows `$13`/`$15` untouched (IT-17). |
| N-1 / A07-10 (jump-table part note) | `:227` | APPLIED | Five retired names replaced; all 12 entries now use the live labels and agree with the table at `:229-254`. |
| N-1 / A07-12 (`SceneCmd_Label` part note) | `:277` | APPLIED | No-op that skips the label id (`INY`, then the `RTS` of `SceneCmd_Default` that follows); the label position is what `$15` and `$13` (flag set) continue at. |
| N-1 / A07-10 (`SceneCmd_LoadPalette` part note) | `:646` | APPLIED | Palette colours into the buffer at `$7F:0A00`; destination `$0020` (colour `$10`) also copies the first loaded colour to `cgramPalette` (colour 0). |
| N-1 / A07-10 (`SceneCmd_LoadMetatileSets` part note) | `:687` | APPLIED | Metatile definition set to `$7E:2000` / `$7E:2800` + destination; operands scaled x`$40` (XBA, LSR x2); decompress buffer written as `$7E:7000`. |
| N-1 (fourth part note the table pairs wrongly: `SceneCmd_LoadLayerMaps`) | `:774` | APPLIED | The row `$06` and this header both carried the retired "FullGraphics" description. Only the opening sentence changed ("Scene command `$06`: load the layer map or maps"); the rest was checked against the code and kept. |
| N-2 / A01 F1 / A07-01 (inline comment) | `:1303` (tag 166783) | APPLIED | Code is `LDA $musicRoomGroup / CMP $06F4 / BEQ loc_028B88 / RTS`: equal continues to the load path, a mismatch returns. |
| N-2 / A01 F1 (block-note sentence) | `:75` | APPLIED | Now: the transfer runs only when the script's group byte (`$06F4`, stored at the top of the routine) equals `musicRoomGroup`; the redundancy check is `CheckSourceCacheHit` on `$0687`. No mnemonic invented for `$06F4`. |
| N-2 / A01 F1 (`SpcMusicLoadCmd` part note) | `:1294` | APPLIED | Part note already had the right direction; `$06F4` now named as the group byte stored at the top of the routine (A01 F1 asked for it). |
| A07-11 | `:1378` (tag 166924) | APPLIED | "decompress to WRAM `$7E:4000` (sprite tile staging)". `QuintetLzDecompress` sets the data bank to `$7E` and writes at `$7A` (`QuintetLzDecompress.asm:23, 27, 54`). |
| N-3 / A07-17 (block note row `$02`) | `:15` | APPLIED | `display_preset_table`. |
| N-3 / A07-17 (block note) | `:71` | APPLIED | `display_preset_table`. |
| N-3 / A07-17 (comments) | `:1159`, `:1161` (tags 166518, 166520) | APPLIED | `display_preset_table`. These are `notes/comments/bank02.json` keys 166518 and 166520. |
| Block-note sentence (step 7) | `:9` | APPLIED | One sentence: the rebuilt tree finds scenes through `scene_meta_list` via `baserom/scene-load/SceneMetaLoad.patch.asm` (replaces `FindCurrentScene` and `SkipScriptCommands` with indexed lookups; the extracted versions are the scanning originals). Checked against the patch file (`FindCurrentScene!` uses `[$3A],Y` indexed by the scene id; `SkipScriptCommands!` uses `meta_label_list`). |
| A07-17 (patch source) | `baserom/equipped-icon/EquippedIcon.patch.asm:474` | BLOCKED | Stale `?INCLUDE 'table_018000'`. Patch sources are not edited here; needs the user (decision U4). |
| A07-17 (docs) | `docs/structs-reference.md`, `docs/bank01-data-tables.md`, `docs/code/bank0D-scene-meta.md`, `docs/code/bank02/scene-script.md` | BLOCKED | Docs are IT-14. |

DISPUTED: none. SKIPPED: none.

## Dry-run summary

```
system/engine/scene_script.asm: block +0 ~1 -0 =0, parts +0 ~6 -0 =0, comments +0 ~4 -0 =0
[DRY RUN] 3 notes file(s) would change: notes/blockNotes/bank02.json, notes/partNotes/bank02.json, notes/comments/bank02.json
OK
```

The real run reported the same counts and wrote the same three files. Only `notes/` changed (`git status` on `notes`, `baserom`, `db-us`, `us`, `src`).

## Gate

`npm run extract:lt` then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline. Last file changed: `notes/comments/bank02.json` (via `merge`).

## Found outside scope (not changed)

Same retired-name drift remains in this file; none of it is in the IT-01 list:

- Block note, "GRAPHICS CACHE SYSTEM" / source-cache paragraph (`:51`): "dual-tilemap layers 0/1" (slots `$0678/$067B`, now `SceneCmd_LoadMetatileSets`) and "FullGraphics layers 0/1" (slots `$067E/$0681`, now `SceneCmd_LoadLayerMaps`).
- Inline comments at `:408` (tag 165172) and `:817` (tag 165906): "FullGraphics layer-0 slot `$067E`".
- Block note intro (`:3`): "transfer tilemaps" for the command set.
- `SceneCmd_LoadSpriteTiles` header (`:1356`): "decompresses to `$4000`" without saying WRAM `$7E` (the same header names `$7E:4000` for the uncompressed path). Row `$10` belongs to IT-17.
- `SceneCmd_LoadMetatileSets` (`:739-749`): `BEQ loc_02878A` follows `INC $3E`, so it tests the pointer wrap, not the source's first word; the note does not claim a raw-data path, and none was added.
- Block-note table rows `$13`, `$15` and the `SkipScriptCommands` texts: IT-17.
