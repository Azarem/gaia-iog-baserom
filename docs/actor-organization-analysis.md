# Actor & Code Organization Analysis

Manual review of all **855** `.asm` files under `extracted/` (34 in `actors/`, 622 containing at least one `actor_def`, **721** total `actor_def` instances). Cross-referenced against `us/blocks.json` block/part definitions and `us/overrides.json` naming and movability overrides.

---

## Reference Conventions

| Symbol | Meaning | Organization implication |
|--------|---------|------------------------|
| `$&label` | Short/local reference — target must stay within the same code bank or a very nearby region | Code referenced this way **must move with** the owning actor/chunk |
| `$@label` | Long/bank-crossing reference — assembler resolves via full address | Target **may live elsewhere**; does not constrain bank placement |
| `#$&label` / `#$@label` | Same distinction for immediate values (e.g. actor pointer setup) | Pointer pairs (`#$*` + `#$&`) must stay co-located; `@` pairs can point remotely |
| `?INCLUDE 'name'` | Compile-time dependency | Defines the **logical unit**; over-inclusion bloats unrelated scenes |
| `?BANK xx` | Declares intended ROM bank (**84 files**) | Bank boundaries are hard constraints for `&` references |

**Movable actor file (working definition):** Contains the `actor_def` (or `e_actor_*` entry point) **and** all code/data reached exclusively via `$&` / `#$&` references, with `@` references only to truly global utilities (system funcs, shared tables, other bank-stable libraries).

---

## Corpus Overview

| Category | Count | Notes |
|----------|------:|-------|
| Total `.asm` files | 855 | Scene folders dominate (freejia 51, edward_castle 50, angel_village 50…) |
| Files with `actor_def` | 622 | Remainder are functions, tables, strings, thinkers, patches |
| Multi-`actor_def` files | ~49 | See [Split Candidates](#split-candidates) |
| `?BANK`-annotated files | 84 | Mostly player, inventory, diary, world map, boss arenas |
| `functions/` globals | 34 | Shared routines already partially extracted |
| `tables/` | 39 | Data blocks referenced across scenes |
| `thinkers/` | 22+ | Scene processors; similar rules apply |

### `blocks.json` structure

- **Top-level keys** mirror extraction folders: `system`, `actors`, `thinkers`, scene names (`edward_castle`, `pyramid`, …).
- **`parts` blocks** (~100 entries): intentionally group an actor with its helper code (e.g. `actor_00D877`, `sE6_gaia`, `player_character` cluster).
- **`movable` flag**: ~100 explicit assignments; `false` marks bank-locked or tightly coupled units.
- **`overrides.json`**: Supplies human-readable names for sub-actors (`ec0A_throne_guard1`, `eu91_merchant2`, `it1A_moon_tribe3`, …) and **`M` overrides** (0 = force non-movable, 1 = force movable) consumed via `fixups.json`.

### Alignment gaps (blocks ↔ extracted ↔ overrides)

Several monolithic `blocks.json` entries span multiple distinct actors that extraction (and overrides) already treat separately:

| `blocks.json` entry | Extracted reality | Recommendation |
|---------------------|-------------------|----------------|
| `gw82_archer` (757490–758819) | **7** `actor_def`s: `gw83_stone_archer1–4`, `gw87_statue_archer`, `gw82_archer1–2` in one 709-line file | Convert to `parts` block; split file per archer variant **or** rename block to `gw82_archer_family` |
| `ec0A_throne_guards` | `ec0A_throne_guard1`, `ec0A_throne_guard2` (+ shared `code_04C66A`) | Already split in asm; update `blocks.json` to `parts` matching overrides |
| `eu91_merchant` | `eu91_merchant`, `eu91_merchant2–4`, shared `code_07C2DF` | `parts` with shared code sibling |
| `ir1F_stone_lord` | 4 variants + shared combat code | `parts` block; keep shared `code_0A9619+` as sibling |
| `sg4C_platforms` | 4 platform actors + 4 tiny `@`-referenced handlers | `parts`; handlers could move to global if reused |
| `ec0F_king_bat` | King bat + 4 sub-bats sharing `code_0A8733`/`0A8743` | `parts`; shared JSR targets stay in same file |
| `chunk_00E683` | Collision engine **plus** 4 unrelated `actor_def`s buried inside | **Split urgently** — see below |

---

## Split Candidates

Files that pack multiple independent actors and should become separate logical units (separate `parts` entries and preferably separate `.asm` files).

### High priority

#### 1. `system/chunk_00E683.asm` (~1,297 lines, 4 `actor_def`s)

Currently mixes:
- Global collision/distance utilities (`func_00E683`, `func_00E6A6`, large `table_00EF72`)
- Four actors (`actor_00E94D`, `actor_00EA96`, `actor_00EAA7`, `actor_00EAC3`) that are **scene props**, not collision core

**Action:** Split into `functions/chunk_00E683_collision.asm` (movable global library) and four small actor files under `actors/` or appropriate scenes. `blocks.json` already lists these as separate `parts` — extraction should follow.

#### 2. `great_wall/gw82_archer.asm` (7 actors, 709 lines)

Shared behavior: stone/statue archers call `@actor_00E256` (global aimable-target handler) but use extensive local `$&` chains (`code_0B8F15` → `code_0B917A` → …).

**Action:** Split into:
- `gw83_stone_archer.asm` (variants 1–4 + shared local code)
- `gw87_statue_archer.asm`
- `gw82_archer.asm` (wall archers only)

Mark shared local routines as a `parts` sibling or a `gw82_archer_common` chunk if variants need the same bank.

#### 3. Multi-variant enemy packs (5 actors each)

| File | Actors | Shared code |
|------|--------|-------------|
| `edward_castle/ec0F_king_bat.asm` | King + 4 sub-bats | `code_0A8733`, `code_0A8743` |
| `incan_ruins/ir1F_stone_guard.asm` | 5 guards | `@actor_00E256` + local `$&` |
| `mountain_temple/mtA0_acid_spider.asm` | 5 spiders | Local web/AI routines |
| `itory/moon_tribe_camp/it1A_moon_tribe.asm` | 5 tribe NPCs | Dialogue `$&` chains; one `@code_00B800` thinker ref |

**Action:** Use `parts` per variant (names already in `overrides.json`). Keep **one** shared-code section included by all variants.

#### 4. `system/dark_space/sE6_gaia.asm` (~1,679 lines)

Single `actor_def` but contains an entire sub-system: Gaia actor, cutscene funcs, widescreen strings, secondary `actor_08F67F`, and **`e_actor_09A090`** (physically in bank 09 per `@` refs).

**Action:** Split into:
- `sE6_gaia.asm` — actor + directly `$&`-linked cutscene driver
- `sE6_gaia_dialogue.asm` — strings/tables (already partially typed as `&DialogString` in blocks)
- `actor_08F67F.asm` — separate actor file
- `e_actor_09A090.asm` — relocate to `unused/` or `system/` (hint NPC related code lives nearby in ROM)

The composite is marked `movable: true` in blocks but is **not** practically movable as one unit.

### Medium priority (4 actors per file)

| File | Notes |
|------|-------|
| `sky_garden/sg4D_knight_armor.asm` | 4 armor variants; 613 lines; `@actor_00E256`; good `parts` candidate |
| `sky_garden/garden_main/sg4C_platforms.asm` | 4 platforms; handlers are `@` (relocated spawns) — could split with minimal coupling |
| `mu/mu_vampire_lair/mu67_vampires.asm` | 4 vampire variants |
| `mountain_temple/mtA0_skulker.asm` | 4 skulker variants |
| `incan_ruins/ir1F_stone_lord.asm` | 4 lords; thin entry stubs + shared body |
| `euro/euro/eu91_merchant.asm` | 4 merchants + shared shop UI |
| `edward_castle/aqueduct_lockway/ec0E_barrier.asm` | 4 barrier variants (overrides: `ec0E_barrier2–4`) |
| `angkor_wat/awB1_wall_walker.asm` | 4 walkers; heavy `$&` sharing — split stubs, keep shared core |
| `actors/ramps.asm` | 4 ramp directions + shared `$&` physics (`code_00D4BB`); blocks marks **`movable: false`** — correct |

### Lower priority (2–3 actors)

Examples: `hint_npc.asm`, `dark_rewards.asm`, `sg4C_spirits.asm`, `pyCC_mystic_ball.asm`, `dm43_elevator.asm`, `av6C_portrait.asm`, `sp58_monologue.asm`, title screen actors (`sFC_actor_0BC9AE.asm` has 2), etc. These are manageable but would benefit from `parts` documentation in `blocks.json`.

---

## Combine Candidates

Cases where separate blocks/files should merge into one logical `parts` group.

### 1. Player character cluster (`actors/player_character.asm` + dependencies)

`player_character` includes and references via `@`:
- `e_actor_02B7B3`, `actor_02B29E`, `e_actor_02B42B`, `e_actor_02B20E` (separate files today)
- `code_02C3C8` is the hub returned to from `entry_points_00C418`, `actor_00D877`, inventory flows

**blocks.json** already marks `actor_02B7B3` and `actor_02B42B` as `movable: false` with large `parts`. **`player_character` is `movable: false`.**

**Action:** Formalize a **`player`** mega-block in `blocks.json`:
```
player_character (actor_def)
├── actor_02B20E parts (sidekick / companion COP handler)
├── actor_02B29E (movement state machine — Code)
├── actor_02B42B parts (inventory overlay logic)
├── actor_02B7B3 parts (field interaction — 30+ funcs)
└── actor_02BDF6 parts (tiny e_actor pair)
```
Keep separate `.asm` files for readability but **one `parts` parent** and shared `?BANK 02`. Do not attempt to move individual pieces.

### 2. `actor_00D877` + `actor_00DA78` + `func_00DB8A`

`actor_00D877.asm` is already a model `parts` block (e_actor + 6 funcs, all `$&`). It `@`-points to `code_02C3C8` (player) and `#$&func_00DB8A` (player setup).

**Action:** Document that `func_00DB8A` (`functions/func_00DB8A.asm`, referenced from **14** scene files) is a **global actor utility**, not part of `00D877`. Consider merging `actor_00DA78` into a `field_interaction` library alongside `00D877` if they share bank 00.

### 3. Edward Castle `ec0A_*` NPCs (already one file per NPC)

**Good pattern.** Opposite of `gw82_archer` — each guard/maid/kara is isolated (~50–400 lines), mostly self-contained. **Do not combine**; optionally group under a scene-level `parts` container in blocks for discoverability only.

### 4. Variant actors with copy-pasted entry (`eu91_merchant2–4`)

Merchants 2–4 differ only in entry address; body jumps to shared `code_07C2DF`.

**Action:** Combine into one **`parts`** block with:
- One shared `eu91_merchant_common.asm`
- Four tiny `actor_def` stubs (could remain one file — current layout is acceptable if blocks documents `parts`)

Same pattern for `it1A_moon_tribe2–5`, `ec0F_sub_bat1–4`, `sg4C_platform1–4`.

### 5. `reward_actors.asm` + `actor_00C2BB.asm`

HP/STR/DEF reward handlers share `func_00E110` and `$&` wide strings. `actor_00C2BB` (red jewel reward) calls `$&code_00C33E` locally and `$@func_00B05E` globally.

**Action:** Keep `reward_actors` as one **`parts`** group (`movable: true` already). Ensure `reward_table_01AADE` stays in same bank or is referenced via `@`.

---

## Movable vs Non-Movable Assessment

### Already correct (`movable: false`)

| Unit | Reason |
|------|--------|
| `player_character` + `02B42B`/`02B7B3` cluster | `@` web across bank 02; COP registration |
| `ramps` / `large_ramps` | Tight `$&` loops + `@code_00D2D5` self-COP |
| `inventory_menu` | Heavy `@inventory_spritemap`, `@code_02E8xx` internal layout |
| `sFA_diary_menu` | Full menu engine, PPU registers, `@` strings |
| `sFE_actor_03A2F1` (world map) | `@func_00B519`, `@func_00B4CC`, includes overworld tables |
| `actor_00E4DB` | Used as **`@` library** by angkor/pyramid actors — must stay put |
| Boss arenas (`pyDD_mummy_queen`, `sE8_actor_0CEEAA`, `na49_kara/lily`) | Multi-bank `@` includes (`sE6_gaia`, `func_08F5F9`, …) |

### Should remain movable (`movable: true`) — verified self-contained

Files with **zero `$@` refs** and substantial `$&` usage (relocate-friendly):

| File | `$&` refs | Lines | Notes |
|------|----------:|------:|-------|
| `actors/overworld_exit.asm` | 42 | 379 | Exemplary isolated actor |
| `actors/actor_00E4DB.asm` | 25 | 214 | **Note:** marked non-movable because others `@`-link *into* it |
| `actors/jeweler_gem.asm` | 15 | 317 | |
| `actors/actor_00D877.asm` | 15 | 317 | Model `parts` actor |
| `actors/actor_00C2BB.asm` | mixed | 142 | Only `@` to system funcs |
| `edward_castle/ec0C_ribber.asm` | 13 | 242 | |
| `incan_ruins/ir1D_scuttlebug.asm` | 14 | 200 | |
| Most `ec0A_*.asm` NPCs | low `@` | varies | Scene-local |

### Reassess movability (blocks.json updates suggested)

| Unit | Current | Recommended | Evidence |
|------|---------|-------------|----------|
| `sky_garden/sg4D_cyber.asm` | not explicit | **`movable: true`** per variant | 34 `$&`, 1461 lines but modular blue/red sub-actors; split first |
| `sE6_gaia` | `movable: true` | **`movable: false`** until split | `@e_actor_09A090`, `@table_0EE000`, spans banks 08–09 |
| `actor_00CD59` (statue inventory) | `movable: true` | **`movable: false`** | 11 `@` vs 2 `$&`; `@inventory_spritemap`, `@func_00B4B7` |
| `entry_points_00C418` | `movable: true` | **`movable: false`** | `@code_02C3C8`, `@table_0EE000`; hub for scene transitions |
| `thinkers_05FB16` | `movable: true` | keep **true** | 18 `$&`, isolated thinker bundle |
| `dc2F_adrift` | `movable: false` | keep **false** | Large self-contained scene script |
| `fr32_showman` | `movable: false` | verify — may be overly conservative | Check `@` density if relocation needed |

### `overrides.json` `M` flag usage

Addresses with `"M": 0` (e.g. 36650, 36702, 186244–188255) are **manual non-movable overrides** — likely cases where automatic analysis got it wrong (probably gaia-ship or similar tight bank coupling). Addresses with `"M": 1` (164770–172332) force movability for actors that might otherwise look coupled. **Preserve these** when reorganizing; they encode author intent.

---

## Global / Shared Code — Keep Separate from Actors

Code referenced via `@` from many scenes should **not** be folded into scene actors.

### Tier 1 — Core libraries (stay in `functions/` or `system/`)

| Symbol | Referenced from | Role |
|--------|-----------------|------|
| `func_00DB8A` | 14+ files | Standard actor slot initialization |
| `func_00B05E` / `func_00B069` / `func_00B496` | reward/jewel actors | Flag/stat check helpers |
| `func_00F3C9` | inventory, statue, diary | Scene fade/transition |
| `func_06B9F2` | euro merchants | Shop inventory logic |
| `entry_points_00C418` | great_wall archers, many scenes | Scene entry COP handlers |
| `chunk_00E683` funcs + `table_00EF72` | collision-heavy actors | **Must split from embedded actors** |

### Tier 2 — Shared actor behavior modules (stay in `actors/`)

| Symbol | `@` ref count | Role |
|--------|-------------:|------|
| `actor_00E256` | 9 files | Aimable-target / COP `[A2]` handler for statues, archers, knights |
| `actor_00E4DB` | 5+ files | Alternate combat collision pattern (angkor wall walkers, pyramid) |
| `actor_00DA78` | included widely | Field object behavior template |
| `code_02C3C8` | player hub | Return point for control handoff — never merge into scene actors |

### Tier 3 — Data tables (stay in `tables/`)

| Symbol | `@` ref count | Role |
|--------|-------------:|------|
| `table_0EE000` | **85** files | Universal sprite/map table — quintessential global |
| `table_01B086` | common | Direction/speed lookup (`actor_00D877`, world map) |
| `stats_01ABF0` | great_wall | Enemy stat block |
| `reward_table_01AADE` | `actor_00C2BB` | `$&` — keep with reward group or mark `&`-typed in blocks |

### Tier 4 — Candidates to **promote** to global

| Current location | Why promote |
|------------------|-------------|
| `code_0A8733` / `code_0A8743` in `ec0F_king_bat.asm` | Identical JSR targets for 5 bats — extract `ec0F_bat_common.asm` if reused elsewhere |
| `code_07C2DF` shop dispatcher in `eu91_merchant.asm` | Pattern likely reusable for other shopkeepers |
| `code_04C66A` in throne guards | Tiny shared dialogue wrapper — OK as `$&` sibling |
| `ending/.../misc_actors_09E64B.asm` | 23 `@` refs, 0 `$&` — **already global** ending script; rename to `functions/` or `system/ending/` |

---

## Thinkers & Processors

Thinkers follow the same `&`/`@` rules. Notable units:

| File | Assessment |
|------|------------|
| `thinkers/parallax_thinker.asm` | Large, scene-agnostic — global |
| `thinkers/sFE_proc_03A940.asm` | 12 `$&`, world-map related — keep near `sFE_actor_03A2F1` |
| `thinkers/thinkers_05FB16.asm` | 18 `$&`, 611 lines — movable bundle (`crF7_thinker_05FB16` in overrides) |
| Scene-local thinkers (`thinker_00B520` etc.) | Already small, movable |

**Action:** Mirror actor `parts` grouping for thinkers that share code (e.g. boot logo thinkers `00B83F`–`00B867` could be one `parts` block).

---

## Scene-Folder Organization Notes

### Well-organized (keep pattern)

- **Edward Castle:** Subfolder per room + one asm per NPC/enemy.
- **Actors folder:** True globals (`floor_button`, `town_door`, `overworld_exit`).
- **Tables / functions:** Already separated.

### Needs cleanup

| Area | Issue |
|------|-------|
| `system/` | Mixes boot, title, inventory, diary, dark_space, collision chunk — OK as tree but `chunk_00E683` and `sE6_gaia` need internal splits |
| `sky_garden/sg4D_cyber.asm` | Multiple cyber variants + red/blue in one 1461-line file — split by enemy type |
| `unused/` | Contains production-adjacent code (`hint_npc`, `dark_rewards`, `actor_09AA6E`) — rename to `debug/` or document which are shippable |
| `ending/ending_credits/` | Many small actor fragments — combine related `sF7_actor_*` into `parts` groups per blocks |

---

## Recommended Priority Order

1. **Split `chunk_00E683.asm`** — separates global collision from four actors (high impact, low risk).
2. **Update `blocks.json` `parts`** for gw82_archer, throne_guards, stone_lord, platforms, king_bat, merchants — align with overrides names.
3. **Split `sE6_gaia.asm`** — unlock dark_space bank management.
4. **Split `sg4D_cyber.asm`** and **`gw82_archer.asm`** — largest scene files after gaia.
5. **Formalize `player` mega-block** in blocks — document immovable cluster.
6. **Audit `movable` flags** for `actor_00CD59`, `sE6_gaia`, `entry_points_00C418` (set false).
7. **Promote ending `misc_actors_09E64B`** to system/functions namespace.
8. Sweep remaining ~40 multi-actor files into `parts` documentation (low urgency if asm layout already matches overrides).

---

## Appendix: Multi-`actor_def` File Inventory

Files with more than one `actor_def` (sorted by count):

```
7  great_wall/gw82_archer.asm
5  mountain_temple/mtA0_acid_spider.asm
5  itory/moon_tribe_camp/it1A_moon_tribe.asm
5  incan_ruins/ir1F_stone_guard.asm
5  edward_castle/ec0F_king_bat.asm
4  system/chunk_00E683.asm
4  sky_garden/sg4D_knight_armor.asm
4  sky_garden/garden_main/sg4C_platforms.asm
4  mu/mu_vampire_lair/mu67_vampires.asm
4  mountain_temple/mtA0_skulker.asm
4  incan_ruins/ir1F_stone_lord.asm
4  euro/euro/eu91_merchant.asm
4  edward_castle/aqueduct_lockway/ec0E_barrier.asm
4  angkor_wat/awB1_wall_walker.asm
4  actors/ramps.asm
3  (14 files — spirits, mystic_ball, elevator, flayzer, eye_stalker, portrait, ishtar, dm41, …)
2  (20+ files — hint_npc, dark_rewards, title actors, vipers, haunts, teleporter, …)
```

---

## Appendix: `@actor_00E256` Consumers

These actors depend on the global aimable-target module and must either keep `@actor_00E256` or include `actor_00E256.asm`:

- `great_wall/gw82_archer.asm`
- `incan_ruins/ir1F_stone_lord.asm`
- `incan_ruins/ir1F_stone_guard.asm`
- `incan_ruins/inca_secret_hallway/ir20_statue.asm`
- `incan_ruins/inca_treasure_room/ir26_statue.asm`
- `edward_castle/aqueduct_lockway/ec0E_statue.asm`
- `sky_garden/sg4D_knight_armor.asm`
- `sky_garden/garden_southwest/sg51_statue.asm`
- `south_cape/coastal_cave/sc02_seth.asm`

Do **not** merge `actor_00E256` into any of these — it is correctly centralized in `actors/actor_00E256.asm` (`movable: true`, 192 lines, all `$&`).

---

*Generated from manual analysis of the extracted US ROM disassembly. Revisit after block moves to verify `&`-reference integrity in rebuilt ROM.*
