# Illusion of Gaia — Documentation

Complete technical documentation for the **Illusion of Gaia** US ROM (SNES), covering the full disassembly of 14 ROM banks, the COP bytecode scripting system, WRAM memory layout, actor organization, data structures, and engine architecture.

---

## Documentation Sections

### [Code Bank Documentation](code/)

The core of the documentation — comprehensive analysis of every ROM bank (`$00`–`$0D`). Includes detailed function-level documentation with address maps, calling conventions, memory layouts, and cross-reference tables.

- **Engine Banks** (`$00`–`$03`) — System core, data tables, gameplay engine, runtime engine. Each has a multi-document suite with 9–21 topic documents.
- **Actor Banks** (`$04`–`$0B`) — NPC and enemy actor scripts organized by game progression, from South Cape through the final Babel Tower and ending sequences.
- **Data Banks** (`$0C`–`$0D`) — Scene spawn tables and the master scene metadata manifest.

> 14 banks · 58 documents · ~380,000 bytes of analyzed code & data

### [COP Bytecode System](cop/)

Complete reference for the **209 COP opcodes** that drive all actor and thinker scripting. The COP system is the game's bytecode interpreter — every NPC, enemy, cutscene, and background effect is scripted through COP instructions dispatched by `CopDispatch` at `$00846D`.

- **[COP Overview](cop/README.md)** — Dispatch architecture, entrancy state, parameter types, full opcode roster
- **[Family Documents](cop/families/)** — 39 focused deep-dives grouped by function (audio, collision, movement, sprites, dialog, etc.)
- **Source:** `extracted/system/engine/cop_handlers_*.asm` (30 handler files)

---

## Reference Documents

These cross-cutting references span the entire ROM:

| Document | Description |
|----------|-------------|
| [**Actor Organization Analysis**](actor-organization-analysis.md) | Classification of all 855 ASM files and 721 actor definitions — how actors are structured, named, and distributed across banks |
| [**WRAM Memory Map**](wram-memory-map.md) | Complete WRAM address map (`$7E:0000`–`$7F:FFFF`) with all known variables, cross-validated against DataCrystal |
| [**Structs Reference**](structs-reference.md) | Documentation of all struct types in `us/structs.json` — `actor-def`, `thinker-def`, `scene-meta`, spawn tables, and more |
| [**Bank $01 Data Tables**](bank01-data-tables.md) | All 22 engine lookup tables: warps, enemy stats, strings, trig LUTs, movement deltas |
| [**COP Commands Reference**](cop-commands-reference.md) | ⚠ *Archived* — monolithic COP reference preserved for history. Use [`cop/`](cop/) instead. |

### External References

| Resource | Description |
|----------|-------------|
| [**RAM Map** (raw)](ram_map.txt) | Legacy plain-text RAM map |
| [**Data Crystal Notes**](Illusion%20of%20Gaia_Notes%20-%20Data%20Crystal.html) | Saved copy of the Data Crystal wiki notes page |

---

## Database Triad

The ROM structure is defined by three complementary JSON files in `us/`:

| File | Purpose |
|------|---------|
| [`us/blocks.json`](../us/blocks.json) | Block/part structure — known code/data regions with start/end/type |
| [`us/overrides.json`](../us/overrides.json) | Per-address register state and type corrections |
| [`us/names.json`](../us/names.json) | Human-readable address labels (address → name mapping) |

The engine auto-discovers additional pieces within and between blocks through code analysis. See the [Code Bank Documentation](code/) for per-bank details on how these files define the ROM structure.

---

## Workflow

```
extract → edit .asm / patches → rebuild → test in Mesen2
```

- **Extract:** `npm run extract` (or `npm run extract:lt` for line-tracked output with ROM addresses)
- **Rebuild:** `npm run rebuild`
- **Assembler syntax:** See [`gaia-knowledge/curated/gaialabs/assembler-syntax.md`](../../gaia-knowledge/curated/gaialabs/assembler-syntax.md) for `$&` / `$@` label conventions
