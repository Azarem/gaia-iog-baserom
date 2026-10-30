# Exports for Mesen2 (labels, scene list, named rebuilds)

These commands feed the Mesen2 MCP server (`C:/Work/mesen2-mcp`) and its Lua kit. They live in `src/` (`src/export.ts`, `src/index.ts`); do not replace them with ad-hoc scripts.

## `npm run rebuild`: named output, SHA-1, build mode (B-01)

```
npm run rebuild -- [<extracted>] [<out.smc>] [<baserom>] [--out=<out.smc>] [--artifacts] [--artifacts-dir=<dir>] [--mode=tagged|plain]
```

| Option | Effect |
|--------|--------|
| `<out.smc>` or `--out=<path>` | Write the ROM there instead of `rebuilt/Illusion of Gaia - Rebuilt.smc`. The folder is created. Example: `rebuilt/variants/tagged.smc`, `rebuilt/variants/plain.smc`. |
| `--artifacts` | Also write `file-layout.json`, `master-lookup.json` and `crc.json` (as before). |
| `--artifacts-dir=<dir>` | Write those three files to `<dir>` instead of `artifacts/`, so a variant build does not overwrite the gate artifacts. |
| `--mode=tagged\|plain` | Build mode recorded in `crc.json`. When omitted it is detected: `tagged` if the extracted asm carries `; {n}` line-tracking numbers (`npm run extract:lt`), otherwise `plain`. |

Every rebuild prints the output path, the **SHA-1** of the ROM, its size, the mode and the header checksum. `crc.json` now also has `mode` and `sha1` next to `checksum`, `crc` and `totalSize`.

**Old artifacts (B-05).** A ROM and an `artifacts/crc.json` built before B-01 have no `mode` and no `sha1`. A session that needs the mode (for example the MCP server checking a ROM against `crc.json`) must run `npm run rebuild` again. Do the same when `extracted/` was edited after the last rebuild: the ROM, `master-lookup.json` and the label files are then out of date. After a rebuild run `npm run export -- labels` again.

Both variants need their own extraction (`extract:lt` for tagged, `extract` for plain), so run the sequence once per variant:

```
npm run extract:lt && npm run rebuild -- extracted rebuilt/variants/tagged.smc --artifacts-dir=temp/tagged
npm run extract    && npm run rebuild -- extracted rebuilt/variants/plain.smc  --artifacts-dir=temp/plain
```

## `npm run export -- labels`: Mesen2 `.mlb` files (B-02)

```
npm run export -- labels [--out-dir=<dir>]                          (default: artifacts/labels)
npm run export -- labels --master-lookup=<file> --out=<file.mlb>    (one file for a variant build, B-04)
```

Reads every `db-us/names/bankNN.json` (decimal ROM offset to name) and `artifacts/master-lookup.json` (upper-cased name to hex offset in the **rebuilt** ROM; run `npm run rebuild -- --artifacts` first) and writes:

| File | Offsets | Use with |
|------|---------|----------|
| `iog-original.mlb` | the key of the names file (the original ROM) | the original ROM (`Illusion of Gaia.smc`) |
| `iog-rebuilt.mlb` | the offset of the name in `master-lookup.json` | the rebuilt ROM that produced that lookup |

**Variant builds (B-04).** A build made with `npm run rebuild -- --artifacts-dir=temp/plain ...` has its own `master-lookup.json`. Pass it with `--master-lookup=<file>` and name the output with `--out=<file.mlb>`: only the rebuilt-ROM labels are written (to that file; the original file and `artifacts/labels` are not touched), for example

```
npm run export -- labels --master-lookup=temp/plain/master-lookup.json --out=temp/plain/iog-plain.mlb
```

Both paths are relative to the current folder. A variant ROM built without `--artifacts-dir` (or `--artifacts`) has no lookup, so no label file can be made for it: rebuild it again with `--artifacts-dir`.

Lines are `SnesPrgRom:<hex offset>:<label>`. Characters Mesen2 does not accept in a label are replaced by `_` (the command reports how many). Names without a `master-lookup.json` entry are left out of the rebuilt file and listed. Regenerate both files after every names iteration and every rebuild; in the MCP server load them with `load_labels {path, replace:true}` (use one per ROM slot).

## `npm run export -- scenes`: scene ids and required event flags (B-03)

```
npm run export -- scenes [--out=<file>]          (default: artifacts/scenes.json)
```

Writes one JSON file: `ids` (sorted scene ids), `idsWithoutScene` (ids 0-255 with no entry), and `scenes[]` with `id`, `idHex`, `key`, `group`, `prefix`, `description`, `requiredFlags` (event flag numbers) and, when flags are known, `requiredFlagBytes` (`address`, `mask`) with `flagNote` and `flagSource`. Event flag `#n` is WRAM byte `0x0A00 + (n >> 3)`, bit `n & 7`; the scene id goes to `sceneNext` at `0x0642`.

Scene ids come from `db-us/groups.json`. The flags a scene needs come from `db-us/scene-flags.json`, a hand-maintained input:

```json
{ "10": { "flags": [63], "note": "...", "source": "where this was observed" } }
```

The export fails if that file names an id that is not in `groups.json`, and if `groups.json` has duplicate ids. Add an entry when an experiment finds a flag a scene needs; the file starts with the one case known today (scene `$0A` Edward's Castle, flag `$3F`).
