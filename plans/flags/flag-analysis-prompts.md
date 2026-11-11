# IOG script-flag analysis - agent prompts

Companion to [flag-analysis-plan.md](flag-analysis-plan.md) (read its sections 2-5 first; every prompt below refers to them). One prompt = one iteration = one agent session.

## How to use

1. Open a **new chat** per iteration, workspace `c:\Work\gaia-iog-baserom` (the multi-root `gaia-snes` workspace also works).
2. Paste the **Static common block** (A), then the **iteration prompt** (B-F). For group iterations FL20-FL29 paste the **group template** (D.1) with the parameter block of your group (D.2).
3. For runtime iterations paste the **Mesen2 common block** (section 12.1 of `plans/extracted-audit/mesen2-investigation-plan.md`), then the **Runtime addendum** (G), then the FR prompt.
4. When the agent finishes, read its final message and the report, then run the apply pass (plan section 7) or hand the apply prompt (H) to an agent.
5. Keep the plan's progress log (section 12) current.

Models: any strong coding model works for FL00/FL01; analysis iterations benefit from a long-context model because each reads 30-45 script files.

---

## A. Static common block (paste above every FL prompt except FL00/FL01)

```text
You are running one analysis iteration of the Illusion of Gaia (US) script-flag project. Workspace: c:\Work\gaia-iog-baserom. Before anything else read, in this order: plans/flags/flag-analysis-plan.md sections 1-4 and the row of your iteration in section 5; docs/cop/families/scene_flags.md; docs/code/bank00/event-flags.md; the header comment of extracted/system/engine/flag_helpers.asm; gaia-knowledge/curated/gaialabs/assembler-syntax.md only if you must quote assembler syntax. Your evidence is the extracted asm under extracted/ plus the inventory (plans/flags/inventory.json when FL01 is done, otherwise plans/flags/iog_flag_usage_inventory.json with the stale-file list of plan Appendix A). Never use the walkthrough, docs/ram_map.txt or wiki pages as evidence: they are hints for naming and ordering only.

HARD RULES
1. Write only under plans/flags/results/ (report, registry fragment, specs, runtime queue; create the subfolders registry/, specs/, queue/ if missing) and plans/flags/tools/ (a reusable read-only helper, with a header that says it writes nowhere else). Do not edit extracted/, notes/, db-us/, baserom/, docs/, src/, artifacts/, us/, plans/extracted-audit/ or the plan and prompt files. Do not delete files you did not create.
2. No git write command (commit, push, tag, merge, rebase, reset, revert). git status/diff/log only. Never run npm run extract, extract:lt, rebuild, or merge/names/flags without --dry-run. The only npm commands allowed: npm run merge -- <spec> --dry-run, npm run names -- <spec> --dry-run and, once FL00 exists, npm run flags -- <file> --dry-run and npm run flags -- --check. Never write a throwaway script that edits notes, comments, names, blocks.json/files.json or docs (.cursor/rules/no-adhoc-scripts.mdc). A read-only query helper is fine.
3. Flag facts to apply (plan 2.1 and 4.3): global index n = byte 0x0A00 + (n >> 3), bit n & 7; operands are hex; BranchOnFlag* with sense 00 jumps when the flag is CLEAR, nonzero sense when SET; WaitOnFlag* yields until the flag matches the sense; flags 0000-000F are cleared at every scene load (scratch: scope them to scenes); WRAM-relative helper indices convert to global by +0400 (kill flags) and Offset100 helpers land at 0500-0507; unobserved is never free.
4. Addresses, not names. Names change under the audit. Cite every site as file:line plus the decimal ROM offset (the "; {n}" tag, or the offset field of the FL01 inventory). If the tree is untagged and the inventory has no offset for a site, write "offset: not available" and tell me; do not run extract:lt.
5. Grades: VERIFIED-STATIC (every reader and writer read, effect unambiguous in code), INFERRED (consistent with context, at least two independent pieces of evidence, say what is missing), UNKNOWN (sites listed, meaning not established). Never promote a guess. VERIFIED-RUNTIME is reserved for FR steps. A claim of absence ("never set", "no reader") states the searches you ran and their scope.
6. Names (plan 3.1): lower snake_case, <area>_<subject>_<state>, true when the flag is set, unique across persistent flags. A name guessed from dialog text says so in notes.
7. Spine flags (used in another group too) get roles and a proposal in your report and fragment ("proposals"), never a final record: FL31 writes it.
8. Text you draft for later note changes (specs): present tense, what the code does now, no history, no iteration/question ids, hedge only a specific untraced claim, waits as operand and ticks, accumulator-implied mnemonics bare (LSR, not LSR A), "slot"/"group"/"frame" with their meaning. Comment specs follow gaia-core/docs/notes-and-comments.md "Merge spec format"; check each with npm run merge -- <spec> --dry-run.
9. Stop rules: if the same search or reading fails twice, change the hypothesis; if a scene's script is too large to read in full, say which part you read and grade accordingly. If your scope is larger than the plan's sizing (about 200 COP sites, 45 files, 60 indices), do the first scenes in story order, write the report for them, and tell me where you stopped. Never fabricate a result to fill a gap.

DELIVERABLES (for every FL iteration)
- plans/flags/results/<ITER>_<yyyymmdd>.md (template: plan 4.5)
- plans/flags/results/registry/<ITER>_registry.json (flag records; "proposals" for spine flags)
- plans/flags/results/queue/<ITER>_queue.json (runtime queue; one item per INFERRED, UNKNOWN and spine flag)
- plans/flags/results/specs/<ITER>_notes.json and <ITER>_names.json only when a shipped note or name is wrong (dry-run output pasted in the report)
FINAL MESSAGE to me: counts per grade, number of sites covered of total, every shipped note now shown wrong (file:line), index reuses found, new questions (text only), the iteration you recommend next. Do not claim the iteration is done if a pass criterion of plan section 5 was not met: say which one failed.
```

---

## B. Phase 0 - tooling prompts

### FL00 - Registry schema and `npm run flags`

```text
ITERATION FL00 (registry schema and tool). You are a TypeScript coding agent. Workspace c:\Work\gaia-iog-baserom. Read: plans/flags/flag-analysis-plan.md (all of sections 2, 3, 5.1, 6, 7, 11), src/export.ts, src/index.ts, src/names.ts, package.json, docs/mesen2-exports.md, gaia-core/docs/notes-and-comments.md sections "Notes Merge", "Names Merge" (the tool you add follows the same conventions: spec file in, --dry-run, validation, clear errors), db-us/scene-flags.json, .cursor/rules/no-adhoc-scripts.mdc.

Step 1 - decisions. Ask me (AskQuestion) for any of D1, D3, D4, D5 of plan section 11 that I have not answered in this chat; use the defaults if I say so. Finalize the schema of plan 3.1-3.3 with me before you code: field list, controlled vocabularies (kinds, grades, domains), the scope object, the fragment and spec file formats (including a way to edit an existing record: expectOld plus replacement, like merge), how spine "proposals" are stored and promoted.
Step 2 - implement, in src/ only (new src/flags.ts plus the wiring in src/index.ts and a package.json script "flags"):
  flags -- <fragment.json> [--dry-run]       merge flag records into db-us/flags.json; reject: index outside its domain range, duplicate name among persistent flags or within (index, scope), unknown kind or grade, scope on a persistent flag whose meaning is global, D1 record without scope; print counts (added, changed, rejected) and never write on --dry-run
  flags -- --check                            validate db-us/flags.json, db-us/scene-flags.json, db-us/flag-presets.json against each other (names exist, indices exist, scene ids exist in db-us/groups.json)
  flags -- export [--out-dir=<dir>]          artifacts/flags.json and artifacts/flag-presets.json (flat, sorted, with byte address, mask, domain, grade; sites joined from plans/flags/inventory.json when it exists)
  flags -- docs                               docs/flags/README.md (domains, lifecycle table, how to read; hand-written intro text lives in a template string or a docs/flags/_intro.md you create) and one page per area group
  flags -- scene-flags <spec.json> [--dry-run]  merge entries into db-us/scene-flags.json (flags, note, source, names, entry, grade)
  flags -- presets <spec.json> [--dry-run]    merge into db-us/flag-presets.json
Extend exportScenes in src/export.ts to accept the optional scene-flags fields (names, entry, grade), validate names against the registry when it exists, and publish them in artifacts/scenes.json. Keep the existing file format working.
Step 3 - docs: add a "flags" section to docs/mesen2-exports.md and write docs/flags/README.md (tool usage, file formats, an example fragment). Update gaia-knowledge only by telling me what to add (do not edit that repo).
Step 4 - verify: npm run type-check; write a sample fragment (plans/flags/results/registry/_sample_FL00.json) with the scene-$0A flag 63 record and one D1 record with two scopes; run flags --dry-run on it, then (only with my OK) a real run into a copy of db-us (never leave a test record in db-us/flags.json; db-us/flags.json ships as an empty skeleton {schema:1, domains:{...}, flags:{}}); show each rejection rule firing once.
Rules: no git write commands; no ad-hoc scripts for notes/names; do not touch extracted/, notes/, baserom/, us/. Pass: type-check clean; round trip of the sample; --check rejects a duplicate name and an out-of-domain index; docs written. Final message: the final schema (paste it), files changed, anything I must decide, the next iteration (FL01).
```

### FL01 - Inventory rebuild keyed by ROM offset

```text
ITERATION FL01 (inventory rebuild). You are a TypeScript coding agent. Workspace c:\Work\gaia-iog-baserom. Needs FL00 (schema; src/flags.ts exists). Read: plans/flags/flag-analysis-plan.md sections 1.2, 2, 5.1 (FL01), Appendix A; plans/flags/20261027-02.md; plans/flags/flag_usage_reference.md (header and the dynamic-trace section); the old inventory plans/flags/iog_flag_usage_inventory.json (structure: indices, helper_sites, direct_symbol_sites, dynamic_helper_traces, unresolved_dynamic_helper_inputs); src/index.ts; docs/mesen2-exports.md (line-tracking tags).
The old scanner (tests/iog/iog_flag_reference.py, another repo) is not available: implement flags -- inventory in src/ (decision D2; confirm with me if I have not answered). The extracted tree must carry "; {n}" line-tracking tags (npm run extract:lt) so each site gets its decimal ROM offset: if extracted/ is untagged (rg -c "; \{[0-9]+\}" extracted/south_cape/south_cape/sc01_jar_door.asm prints 0 or fails), STOP and tell me to run `npm run extract:lt` (then `npm run extract` again after you finish). Do not run them yourself.
Output plans/flags/inventory.json (+ a short generated plans/flags/inventory.md) with, per site: rom offset (decimal), file, line, opcode or helper, operands, resolved global index (and WRAM-relative index when relevant), width (byte/word), scene ids (from scene_actors placement or the scene prefix of the file; list unknowns), role guess limited to set / clear / branch / wait / helper call / table reference / direct read (no semantics). Scan: the 8 COP opcodes (CC-D3); calls to flag_helpers.* with the traces of the old inventory re-derived (the 16 dynamic traces; keep the method text, fix the helper and file names that changed, e.g. SceneCmd_ConditionalLoad is now SceneCmd_Branch); word forms #$00XX; the $13 branch commands in the scene_meta command streams (decode scene id -> flag index); item COPs D4-D7 with item ids; SwitchCase operands other than $0000; direct accesses to $0A00-$0BFB outside flag_helpers and the save code; $eventFlags/$wramFlags symbol references.
Reconcile with the old inventory: sites gained, lost and renamed (match by text and neighbors, not by path); the 11 missing files of Appendix A must map to current files or be reported. Expected: 1,693 COP sites and 57 helper calls, or every difference explained in plans/flags/results/FL01_<date>.md.
Rules: do not edit extracted/, notes/, db-us/ or baserom/; no git write commands; no ad-hoc scripts for notes/names. Pass: counts reconcile; no site without an offset; npm run type-check clean; re-running the command reproduces the file byte for byte. Final message: counts per category, differences from the old inventory, remaining unresolved dynamic inputs, next iteration (FL10).
```

---

## C. Phase 1 - engine and table domains (paste block A first)

### FL10 - Storage, lifecycle, scene-meta gates

```text
ITERATION FL10 (storage, lifecycle, scene-meta gates). Scope: extracted/system/engine/flag_helpers.asm, cop_handlers_scene_flags.asm, cop_handlers_dungeon_switch.asm, scene_lifecycle.asm (ClearSceneState and everything that touches $eventFlags), save_system.asm, system/inventory/inventory_overlay.asm, functions/game_over_sequence.asm, system/world_map/WorldMapController.asm, angel_village/undersea_tunnel/st68_kara.asm, sky_garden/garden_descent/sp58_red_eye.asm, system_init.asm, event_blocks.asm, scene_script.asm (SceneCmd_Branch), tables/scene_meta.asm, plus every site of the 18 direct $eventFlags/$wramFlags references of the inventory.
Questions to answer with code evidence:
1. When is each byte range of 0A00-0AB3 zeroed, saved, restored (boot, ClearSceneState, inventory overlay, world-map entry, game over, save/load)? Confirm that STX $eventFlags zeroes exactly flags 0000-000F: find the register width at that point (REP/SEP before it, overrides.json M/X for that address) and state it. Compare with docs/wram-memory-map.md section 2.7 ("persistent ... survives scene transitions" for the whole 0A00-0AFF page): quote the wrong sentence and draft the fix as a merge spec.
2. Build the per-byte map of 0A00-0AB3 (flag index 0000-059F): byte, index range, domain (plan 2.2), helper base, who owns it. Mark bytes with no known owner "unassigned". Note where the flag array stops and inventorySlots ($0AB4) begins.
3. Decode every $13 command in tables/scene_meta.asm (SceneCmd_Branch): scene id, flag index, what the skipped block loads. These are domain D9 reads.
4. List every other reader or writer of the array that is not a COP or a helper (the direct symbol sites; the Rama low-byte compare; the plate gate bit mask) with the exact bits.
5. Write the exact semantics of SetEventFlag, ClearEventFlag, TestEventFlag, SetWramFlag, TestWramFlag and the wrappers in one table (index in, base added, mask, carry out), with the index conversions of plan 2.1.
Deliverables: the report with the domain table (D1-D9), lifecycle table, byte map, scene-meta gate table; the registry fragment holds the "domains" object (plan 3.1) and a record per flag index that the scene-meta gates reference; queue items for the reset behavior (FR00) and for any lifecycle claim you could not close statically. Pass: every byte of the range has a domain or "unassigned"; the D1 reset claim has width evidence; the scene-meta table is complete.
```

### FL11 - Event triggers $0100-$01FF

```text
ITERATION FL11 (event triggers and death actions). Domain D3, global indices 0100-01FF (bytes 0A20-0A3F). Scope: the event_blocks table and ApplyAllEventBlocks (flag 0100+n triggers event block n: what does block n change, in which scene?); enemy death-action indices (the field in tables/scene_actors.asm actor-spawn rows, stored by actor_execution, tested by SetFlag_0100/TestFlag_0100 in EnemyDefeatDispatch, StandardEnemyDefeatHandler, awB1_wall_walker, pyCC_mystic_ball, pyCC_dark_space_portal); the 66 literal word-form flags (0170-017F legends and crystal gates, 0185 gold ship, 0100-019B others) with their scenes. Use the inventory traces "enemy_death_action_flags" (42 candidates) and "dark_space_portal_death_flags" but verify the rows you cite.
For each index in 0100-01FF that has any use, write a record: which event block or death action it is, the scene, the actors (spawner and consumer), set/clear/test sites, the effect (tiles changed, reveal, door, boss defeat), and the relation to the matching COP literal sites in the scene groups (which group iteration also sees it: list them as spine proposals when it does). Indices with no use get one row "no use found" with the searches.
Pass: every used index has a record or a "no use found" row; the event-block table is mapped to scenes; death-action indices are mapped to enemy actor rows.
```

### FL12 - Chests, jewels, barriers $0200-$02FF

```text
ITERATION FL12 (chests, hidden Red Jewels, barriers). Domain D4, global 0200-02FF (bytes 0A40-0A5F). Scope: tables/scene_chest_table.asm (the stale name scene_barrier_chest_table in the old inventory is this table: confirm), actors/hidden_red_jewel.asm (parameter-derived 0280-028F), system/engine/warps_interaction.asm (PlaceOpenedChestTiles, HandleChestInteraction), system/engine/radar_map_screen.asm, and any COP or helper that sets a 0200-range flag.
Deliver: a table scene id | chest tile (x,y) | contents (item name from system_strings item_name_table) | global flag | fanfare | jewel flag number, for all chest records (the block note says 46 records in 39 scenes: verify), the same for hidden Red Jewel actor placements (scene_actors rows of hidden_red_jewel, parameter -> flag), the barrier records the old trace mentions (46 candidate flags 0201-022E: confirm which are chest flags and which are barrier flags, or whether they are the same list), and gaps (flags in 0200-02FF referenced nowhere). One domain record plus one record per flag.
Check the block note of scene_chest_table.asm against your table and draft a merge spec for every wrong line. Pass: every flag the tables or actors reference is mapped to a scene and contents.
```

### FL13 - Scene clear reward $0300-$03FF

```text
ITERATION FL13 (per-scene clear reward). Domain D5, global 0300-03FF (bytes 0A60-0A7F), flag = 0300 + scene id. Scope: tables/enemy_clear_reward_table.asm, functions/StandardEnemyDefeatHandler.asm, actors/field_reveal_object.asm, actors/reward_actors.asm, actors/boss_clear_reward_handler.asm, system/engine/radar_map_screen.asm; the inventory trace "enemy_clear_reward_flags" (87 candidate scenes).
Deliver: table scene id | flag | reward kind (HP, strength, defense, gem, item, reveal) and amount | which table row and handler | when the flag is set | what the radar shows | notes; the scenes in the table with no reward actor and the reverse. Explain how the clear is detected (enemy count, boss) and what is tested before the reward actor runs. One domain record, one row per scene (a full record only for flags that other scripts also read). Pass: all 87 candidate scenes mapped or explained.
```

### FL14 - Dungeon kill flags $0400-$04FF

```text
ITERATION FL14 (dungeon kill flags). Domain D6, global 0400-04FF (bytes 0A80-0A9F), global = 0400 + enemyNum (the WRAM-relative index of the helpers and of the inventory trace "dungeon_kill_wram_flags", 253 candidates, is enemyNum). Scope: tables/scene_actors.asm (enemy-number field), system/engine/actor_execution.asm (decode, store, CheckEnemyDefeatedFlag), cop_handlers_dungeon_switch.asm (SetDungeonKillFlag, COP D8), the 4 manual COP D8 sites, ClearAllWramFlags callers, game_over_sequence.
Deliver: table enemy number | scene id(s) | actor and spawn row | notes (same number used in several scenes = shared kill bit; numbers never used; numbers used by actors that are unplaced); lifetime (cleared on world-map entry, st68_kara, sp58_red_eye, game over: confirm each site and when it runs); what happens at scene load for a set bit (actor not spawned? where in the code?). One domain record; a full record only for numbers with a manual COP D8 site or a shared use. Pass: every nonzero enemy number in scene_actors appears once in the table.
```

### FL15 - Boss reward and ability flags $0500-$059F

```text
ITERATION FL15 (boss reward and ability flags). Domain D7: boss reward flags global 0500-0507 (byte 0AA0, helpers TestWramFlag_Offset100/SetWramFlag_Offset100) and ability flags 0510+ (TestFlag_0510, index = characterForm*4 + slot; byte 0AA2 is also abilityBitmask). Scope: actors/boss_clear_reward_handler.asm, the boss lairs (incan_ruins/ir29_castoth.asm, great_wall/sand_fanger_lair/gw8A_sand_fanger.asm, mu/mu_vampire_lair/mu67_vampires.asm, pyramid/mummy_queen_lair/pyDD_mummy_queen.asm, sky_garden/viper_lair/sg55_viper.asm, and any other boss script that tests or sets these), system/inventory/inventory_menu.asm (TestAbilityFlag), system/inventory/item_use_system.asm, and every writer of abilityBitmask ($0AA2) found with rg.
Deliver: boss index -> global flag -> boss -> reward (the inventory trace says the row number is masked to 0-7: show the table); the ability map: global flag -> form (Will/Freedan/Shadow) and slot -> ability name (verify the community bit order Psycho Dash 01, Psycho Slide 02, Spin Dash 04, Dark Friar 10, Aura Barrier 20, Earth Quaker 40 against the code); who grants each ability (script, actor, item) and in which scene, or "no setter in extracted code" with the search. One domain record and one record per flag in use. Pass: every flag in 0500-0507 and every ability flag in use is mapped; every ability bit has a setter or an explicit "not found" row.
```

---

## D. Phase 2 - scene groups (paste block A, then D.1 with one parameter block from D.2)

### D.1 Group template

```text
ITERATION <ITER> (<TITLE>). Scope: the directories <DIRS> under extracted/ (scene ids and keys: db-us/groups.json, groups of the same names; <SCENECOUNT> scenes). Baseline from the inventory: <SITES> literal COP sites in <FILES> files; indices used: <IDX>; spine flags in scope: <SPINE>. Dynamic traces that belong here: <DYNAMIC>. Leads (verify, do not trust): <LEADS>.
You own every literal flag site in these directories (scratch and persistent), the helper calls in them, and the direct reads. Follow plan 4.2 steps 1-10 exactly. Specific instructions:
1. Pull the sites of your directories from the inventory and list the flags: owned (used only in your directories) and spine (also used elsewhere; the inventory lists the other directories). Save that list in the report as the coverage table before you read any script.
2. Work scene by scene in story order. For each scene id: placement in tables/scene_actors.asm (actor, parameter, death-action index, enemy number), scene_thinkers.asm, scene_warps.asm (what leads in and out), scene_meta $13 gates. Read every actor script that uses a flag in full, plus the dialog text in the same file (dialogstring_XXXXXX blocks). Write 2-3 sentences of state machine per actor: what it does with the flag clear, with the flag set, what sets or clears it.
3. Scratch flags (0000-000F): never describe one without its scene. Key them by scene id in the fragment (scope {scenes:[...]}); identify handshakes (a SetFlagByte followed by WaitOnFlagByte on the same index, one actor producing, another consuming) and give both actors; the same index in two scenes is two meanings.
4. Persistent flags (0010 and up): describe the story event, the guard idiom (what is skipped when the flag is set or clear: read the branch target), the one-shot narration latches, the door/wall/bridge gates, rewards. Record who else reads or writes the flag in other groups (spine) with their roles.
5. Dynamic indices of this group (actor-parameter or table driven): verify the inventory trace row by row for your actors (scene_actors parameter -> index) and write a record per resolved index.
6. Map the entry effect: for each scene say whether any actor locks the player (joypadMaskStd, script lock) without a flag; those flags go into the report's "scene entry" table (scene, flags needed, source site). This feeds FL32/FR40; do not edit db-us/scene-flags.json.
7. Shipped text check: rg the notes and comments of your files for claims about these flags (for example "not traced", "unknown flag", wrong scene names) and draft the merge spec.
8. Queue: one runtime item per INFERRED/UNKNOWN flag and per spine flag, with a start scene, the flags to set (use the registry names you propose) and the observation. Keep each trial small (one scene, one toggle, one observable).
Pass: every site of the scope is in the coverage table; every owned flag has a record (T1: scene rows; T2: full) or a one-line row; every spine flag has roles and a proposal; every scene has a scene note; contradictions quoted; queue written.
```

### D.2 Parameter blocks

```text
ITER=FL20 TITLE="Prologue and South Cape" DIRS="prologue, south_cape" SCENECOUNT=12 SITES=202 FILES=29 IDX="13 scratch, 22 persistent, 5 at or above 0100" SPINE=9
DYNAMIC="none known; scene_flag_init (placed in 26 scenes) belongs to FL30"
LEADS="legend stage flags 017C-017F (word COPs; pr8D_prologue2 sets and tests, pr8C_prologue1 clears); house intro narration latches 11-17 in sc01_house_intro/sc01_jar_door/sc02_entry/sc02_erik; Will's house 1B-1D (sc06_*); coastal cave 15 16 20; sc01_guard 27; flag 4C is shared with gold_ship. This is the pilot iteration: report anything in the plan or prompt that was unclear."
```

```text
ITER=FL21 TITLE="Edward's Castle and the mansion" DIRS="edward_castle, mansion" SCENECOUNT=12 SITES=119 FILES=32 IDX="9 scratch, 17 persistent, 6 at or above 0100" SPINE=7
DYNAMIC="none known"
LEADS="flag 3F (scene 0A guard; ground truth in db-us/scene-flags.json and the Mesen2 H3 result); prison cell/door ec0B (23, 24); Kara/Lily/Edwina scripts ec0A (19-22); aqueduct scenes ec0E-ec13; mansion intro 29 (sE9)"
```

```text
ITER=FL22 TITLE="Itory, Moon Tribe, Incan Ruins" DIRS="itory, incan_ruins" SCENECOUNT=21 SITES=134 FILES=34 IDX="9 scratch, 22 persistent, 8 at or above 0100" SPINE=10
DYNAMIC="gold_tile_flags (ir1F_gold_tile: flags 01-04 through SetFlagRaw/ClearFlagRaw, actor-parameter driven; the actor's file name may differ from the inventory)"
LEADS="inca statues it19/it1B; it1A Moon Tribe; the plate gate ir1F_plate_gate_opener reads eventFlags bits 1-4 directly (list all four bits and what sets each); ir29_castoth boss flag (FL15 owns the table, you own the script); 2F-31 are shared with system; the Incan Melody item use sets 2E (item_use_system.asm)"
```

```text
ITER=FL23 TITLE="Gold Ship and Freejia" DIRS="gold_ship, freejia" SCENECOUNT=19 SITES=169 FILES=40 IDX="7 scratch, 25 persistent, 2 at or above 0100" SPINE=7
DYNAMIC="none known"
LEADS="gs2C_descent sets 0185 (descent started); Freejia herb and HP jewel actors (fr32_*); flags 4C 4D 52 are shared with thinkers or south_cape (global_ambient_dispatcher?)"
```

```text
ITER=FL24 TITLE="Diamond Mine, Great Wall, Sky Garden, Mountain Temple" DIRS="diamond_mine, great_wall, sky_garden, mountain_temple" SCENECOUNT=42 SITES=128 FILES=37 IDX="7 scratch, 18 persistent, 22 at or above 0100" SPINE=13
DYNAMIC="diamond_mine_laborer_flags (dm3F_laborer, A0-A3), necklace_stone_flags (gw82_necklace_stone, 98 99); the Kress crystal-ball gate scripts named in the inventory (mtA2/mtA5) no longer exist under those names: find where their sites live now"
LEADS="dm44 cell door, dm47 Sam, dm45 key, dm3D breakable wall; sand fanger 016A (word wait); gw85_spin_dash_gate; sg52/sg54 switches; sky garden 60-63 are shared with system; Sky Garden has 22 sites at or above 0100"
```

```text
ITER=FL25 TITLE="Seaside Palace and Mu" DIRS="seaside_palace, mu" SCENECOUNT=14 SITES=129 FILES=33 IDX="9 scratch, 25 persistent, 6 at or above 0100" SPINE=6
DYNAMIC="none known"
LEADS="7E drains Mu (the harness already uses it: state orig_S14h); mu66_rama_spirits compares the low byte of eventFlags with FE; mu67 vampires (boss flag, FL15 table); sp5A voices and monologue; sp5C stone and key coffins; 7B is shared with system and mu"
```

```text
ITER=FL26 TITLE="Angel Village and Nazca" DIRS="angel_village, nazca" SCENECOUNT=16 SITES=168 FILES=36 IDX="15 scratch, 9 persistent, 11 at or above 0100" SPINE=1
DYNAMIC="none known"
LEADS="av69-av75 party NPCs and tunnel doors; undersea_tunnel st68_* (st68_kara calls ClearAllWramFlags: FL14 owns the lifetime, you own the script); na4B is a single scene with 71 scratch sites (a follower script with a buried tile): treat the scene as one state machine and document the handshakes; 8D is shared with actors and watermia"
```

```text
ITER=FL27 TITLE="Watermia and Euro" DIRS="watermia, euro" SCENECOUNT=21 SITES=160 FILES=37 IDX="9 scratch, 27 persistent, 0 at or above 0100" SPINE=9
DYNAMIC="none known"
LEADS="watermia intro and NPC chains (shared 8D 94 96 9D with other groups); Euro flea market eu97 medicines, altar eu9D; A5 A7 A8 are cross-area"
```

```text
ITER=FL28 TITLE="Native Village, Dao, Angkor Wat" DIRS="native_village, dao, angkor_wat" SCENECOUNT=27 SITES=153 FILES=33 IDX="6 scratch, 26 persistent, 2 at or above 0100" SPINE=12
DYNAMIC="the death-action flags of awB1_wall_walker (FL11 owns the table); the stale awB2_stair_climb and awB3_vine_reveal names of the inventory: find where those sites live now"
LEADS="Native Village has 72 persistent sites over 15 indices (shared AC B6 BF-C1); daC5_weaver; awB4 snake pit entry"
```

```text
ITER=FL29 TITLE="Pyramid, Babel Tower, Ending" DIRS="pyramid, babel_tower, ending, unused" SCENECOUNT=37 SITES=186 FILES=45 IDX="11 scratch, 17 persistent, 7 at or above 0100" SPINE=9
DYNAMIC="falling_orb_flags (pyD4_falling_orb, F2 F3), dark_space_portal_death_flags (pyCC, 0173); pyD0 breakable wall (stale name)"
LEADS="pyCC mystic ball and dark space portal; pyDD mummy queen (boss flag, FL15); pyCD hieroglyph puzzle and hieroglyphSlots ($0B28, FL40 owns the slots); Kara scenes btDE-btE4; comet lair sE8 uses flag FF and the handshake #02/#03; crystal gates 0175-0179 (word waits, shared with other groups); epilogue sE5 uses #02, #04, #DB; extracted/unused is dead code: classify, never use as evidence of intent. This is the largest group: if it does not fit, stop after Babel Tower and report the remainder"
```

---

## E. Phase 3 - spine and progression (paste block A first)

### FL30 - Engine-owned flags

```text
ITERATION FL30 (engine-owned flags). Scope: extracted/system/* (boot_logos, title_screen, diary_menu, dark_space/sE6_gaia.asm, inventory, statue_inventory, item_use_system), extracted/actors/* (player/player_character.asm, scene_flag_init.asm, overworld_exit.asm, jeweler_gem.asm, hit_switch.asm, player_transition_handlers.asm, shadow_shimmer.asm), extracted/thinkers/*. Baseline: 145 sites, 45 spine flags, 7 scratch indices.
Questions: (1) flag 00: scene_flag_init sets it in 26 scenes; the player code calls it the Shadow flag; the idle/ladder/shimmy sprite choice reads it; four scripts clear it around events. What does it mean in the extracted code (list every writer and reader with the form of Will it implies)? Do not accept either name without a trace; grade accordingly. (2) 10 (boot logo latch) and the title/diary flags. (3) overworld_exit flags 25 and 26 and the other 11 indices there. (4) jeweler_gem (19 sites, 7 indices): the jeweler's state machine. (5) statue reward flags F8-FD (dynamic trace statue_reward_flags: system/statue_inventory/statue_inventory_reward.asm, inventory_statue_slot.asm). (6) The handshake conventions of scratch flags 01-04 as used by the player and actors. (7) item_use_system flags (for example 2E Incan Melody) and which scene each belongs to.
Spine flags: record roles and a proposal (FL31 finalizes), but for flags owned by the engine (used nowhere else) write full records. Pass: every site classified; flags 00 and 10 resolved or graded UNKNOWN with a queue item.
```

### FL31 - Cross-group spine

```text
ITERATION FL31 (spine flags). Needs: FL11-FL15, FL20-FL30 fragments and reports (read all "proposals" and all scene notes that mention a spine flag). Scope: the 62 persistent literal indices used in two or more directory groups (derive the list from the inventory; include the seven at or above 0100 and the widest-spread flag FF: 38 sites in 11 groups, 12 sets), plus every index reuse the iterations reported (same index, different meaning).
For each spine flag: collect every site and every proposal; decide the meaning and the name; resolve conflicts with the evidence that decides (quote file:line and offset); write the final record with scope null or an explicit scope list; write the relations (requires, excludes, pairsWith). For FF: list all 38 sites with the actor and the state machine around each and decide whether it is one flag with one meaning or a convention (for example "cutscene finished" used by several unrelated actors); do not call it an idiom without evidence.
Output: the final records (registry fragment FL31_registry.json that supersedes the proposals), a conflicts table (index | proposals | decision | evidence), the index-reuse table, shipped-note contradictions (spec). Pass: no spine flag remains a proposal; every conflict is closed or graded INFERRED with a queue item.
```

### FL32 - Progression graph, scene entry, presets

```text
ITERATION FL32 (progression graph). Needs FL31 and FL40 (items, form, abilities). Scope: all persistent records plus every scene.
1. Assign each persistent flag a stage tag and a milestone: define milestones M01... in story order (new game, first dream/feast, Edward's Castle letter, ..., final boss, epilogue) from the code (what guards what), using the walkthrough only as a naming and ordering hint. Write the table: milestone | flags set | key items given | abilities | form | scenes unlocked | evidence.
2. Prerequisite edges: for each guard (BranchOnFlag* before a spawn, door, dialog, scene meta) write requires/excludes into the records (a fragment update FL32_registry.json, edit rows with expectOld).
3. Scene entry: classify all 228 scenes (db-us/groups.json): free | locked-until-flag | cutscene | unreachable | unknown, with the flags needed to make the player free on arrival and the source sites; the FL20-FL29 reports' "scene entry" tables are your input; write specs/FL32_scene-flags.json in the format of plan 3.2 (flags, note, source, names, entry, grade INFERRED).
4. Presets: one per milestone that matters for testing (at least: new game start, after the castle letter, before each dungeon, before each boss, before the final area): flags (global indices and names), items (ids and slots), form, gem count, abilities, and a verification scene with the observation expected there (an NPC present, a door open, a boss flag clear). Write specs/FL32_presets.json (format of plan 3.3).
Pass: every persistent flag has a stage; every scene has an entry class; every preset names a verification scene and expectation. No runtime claim: grade everything INFERRED until FR40/FR50.
```

---

## F. Phase 4 - non-bitfield gates and closure (paste block A first)

### FL40 - Non-bitfield gates

```text
ITERATION FL40 (items, form, state gates). Domain D8. Scope: COP GiveItem (49 sites), RemoveItem (34), BranchIfHasItem (35), BranchIfItemEquipped (5); SwitchCase operands other than $0000 (at least $0AD4 characterForm and $0AA6); direct reads and writes of $0A00-$0BFB outside flag_helpers and save_system (abilityBitmask $0AA2, gemCount $0AD6, inventory slots $0AB4-$0AC3, hieroglyphSlots $0B28-$0B33, $0B06 saved scene, $0AF0-$0AF8 scene save data, equipped item); form checks (BranchIfPlayerForm-style COPs, characterForm tests).
Deliver: (1) item flow table: item id (name from system_strings item_name_table) | given by (scene, actor, ROM offset) | removed by | tested by (what it gates) | notes; mark key items (those tested by BranchIfHasItem that gate a door, NPC, scene). (2) form gates: scene, actor, which form, effect. (3) every direct access outside the flag helpers with the variable name from docs/wram-memory-map.md and the reason. (4) the inputs a preset needs (which items, which form, gems, abilities at each stage). (5) the interplay of item gates and flags (item given then flag set; flag tested instead of the item). Registry: a "stateGates" section (kinds item, form, counter) in the fragment. Pass: every item op site classified; every direct access explained.
```

### FL41 - Gap analysis and quality audit

```text
ITERATION FL41 (gap analysis). Needs: all FL fragments (merged or in plans/flags/results/registry/). Scope: the whole array.
1. Bit-level matrix of 0A00-0AB3 (index 0000-059F, 1,440 bits): status per bit from {named record, scene row only, helper-only (no literal COP), table-only, set-only, test-only, referenced by a direct read, unreferenced, overlaps inventory/ability/other state}. Write plans/flags/results/coverage.md with a summary table per byte and a list per status. The word "free" never appears: an unreferenced bit says which searches found nothing.
2. The 28 set-only and 10 test-only literal flags: where does their other half live (helper, table, dynamic trace, dead code)? Close each or queue it.
3. Unresolved dynamic inputs (the SceneCmd_Branch operands should be decoded by FL10; check) and any helper caller whose input is not bounded.
4. Quality: duplicate or non-unique names, D1 records with scope null, names that do not state what is true when set, grades without evidence, spine flags still proposals, records whose two fragments disagree. List them with the fix.
5. Rank the runtime queue (P1: spine and UNKNOWN, entry flags; P2: INFERRED single-area; P3: VERIFIED-STATIC confirmations, one trial in five) and write plans/flags/results/queue/ranked_queue.json with the FR iteration that should run each item.
Pass: every bit has a status row; no UNKNOWN without a queue item; the ranked queue covers every INFERRED/UNKNOWN record.
```

---

## G. Runtime addendum (paste the Mesen2 common block 12.1 first, then this, then the FR prompt)

```text
FLAG ADDENDUM for runtime steps. Workspace c:\Work\gaia-iog-baserom. Besides the sections the Mesen2 common block names, read plans/flags/flag-analysis-plan.md sections 2, 3, 6 and your row of 5.6, and the queue items assigned to you (plans/flags/results/queue/*.json or ranked_queue.json; registry fragments for the flags concerned).
1. Your writes follow the Mesen2 hard rules: results under plans/extracted-audit/mesen2-results/ (FRxx_<yyyymmdd>.md in the plan 8.1 template), kit/harness code there, states in rebuilt/states/, and your verdicts as plans/extracted-audit/mesen2-results/specs/FRxx_flag_verdicts.json: [{ "flag": <global index>, "scope": null | {scenes:[...]}, "queueId": "...", "verdict": "VERIFIED-RUNTIME" | "CONTRADICTED" | "INCONCLUSIVE", "grade": "VERIFIED-RUNTIME" | "...", "effects": { "set": "...", "clear": "..." }, "expectGrade": "<grade now in the fragment>", "evidence": "<result file section>" }]. Never edit plans/flags/, db-us/ or extracted/.
2. Flag convention: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7 (write with write_memory on the work-RAM type; read back and report). Flags 0000-000F are cleared at every scene load: set a scratch flag AFTER the scene finished loading (sceneCurrent equals the id, banner dismissed) and observe in the same scene.
3. Every trial has a control run (flag untouched) and a forced run (flag toggled) from the SAME loaded state, same frames, same input; record the observables the queue names (actor list from $56 via +6, joypadMaskStd $065A, a screenshot, the dialog state, the tile or collision cell). A trial with no visible difference is INCONCLUSIVE with the observables you checked, not "no effect".
4. Standing positive control in every run: scene 0A with and without flag 63 (quick warp or run_recipe warp {scene:10, flags:[63]}; without the flag joypadMaskStd stays CFF0). If this control does not behave, stop and report.
5. Write the flag array only in disposable states; never save a poked state to the library unless the step says so and states-index.md gets the flags written; do not write low DP ($00-$94). Use set_input / play_input for buttons (logical bits vs physical buttons: Mesen2 common block rule 8).
6. Final message: counts of VERIFIED-RUNTIME / CONTRADICTED / INCONCLUSIVE by queue item, every registry grade that must change (flag, old grade, new grade), every shipped note now wrong (file:line), tool issues logged, new questions (text only), recommended next step.
```

### FR00 - Flag instrumentation and controls

```text
STEP FR00 (flag instrumentation). Needs FL00, FL01, FL10 (queue from FL10). ROM: O, state orig_S01r_south-cape-ready.mss.
1. Kit helpers in plans/extracted-audit/mesen2-results/kit/lib/gaia_kit.lua (extend, never edit the server's kits): gaia.flags.get(n), set(n), clear(n) (by global index; by registry name once artifacts/flags.json exists: read it in the Python harness and pass numbers into Lua), dump() (180 bytes of 0A00-0AB3 as hex), diff(a, b) (list of changed flag indices), and gaia.flagwatch(opts) (write callback over 0A00-0AB3, logs frame, scene, the instruction that ENDS at the reported PC mapped to a decimal ROM offset, changed bits; cap 200 lines; filter out the known ClearSceneState zeroing of 0A00-0A01 into one summary line). Harness: harness/flag_census.py (one atomic run_script per experiment, control and forced run).
2. Test every helper with a firing control: write 0A00 bit and read back; the NMI write control of H4; flagwatch must report the SetEventFlag store when you run a scene's known setter (for example the jar door sc01_jar_door setting flag 11 in scene 01, or the sc01_house_intro latches): choose one, log its offset.
3. Verify the lifecycle claims of FL10's queue: write 0A00-0A01 = FFFF, quick warp to another scene, read 0A00-0A01 after the scene loaded (expected 0000 plus whatever the scene sets), and flags 0010+ written beforehand stay (write 0A02 = FF first); the inventory overlay (open with Select, close) restores the first word (write 0A00 = 0005, open, close, read).
4. Positive control per addendum item 4.
Pass: helpers tested; the scene-clear claim VERIFIED-RUNTIME or CONTRADICTED with the numbers; the overlay behavior recorded; every helper has a firing control. Deliver FR00_<date>.md and the kit code.
```

### FR10 - Early-game natural capture

```text
STEP FR10 (early-game capture). Needs FR00, FL20, FL21. ROM: O. Start from the title state orig_S06_title.mss (scene FC).
Goal: record, from real input, the flag changes of the early game and save natural states. Use gaia.flagwatch (FR00) over 0A00-0AB3 and record_input to keep the button sequence. Route: New Game (verify the menu path first in a disposable run) -> prologue scenes -> South Cape (house intro narrations, Seth's jar door, Lance, Erik, coastal cave) -> Edward's Castle entrance (the guard). Take a screenshot at each scene change and at each dialog; stop at the castle gate and on the first flag-triggered lock if the input route fails four times (report where).
Deliver: timeline table frame | scene | flag index | set/clear | setter ROM offset | actor/routine | registry name (or "no record"); the recorded input files; natural states orig_N01_<name>.mss for at least: first free control in South Cape, after the dream/feast scene (Will's house), at the castle gate; states-index.md rows with the flags present (read the array at save time). Compare each flag change with the registry fragments of FL20/FL21: list confirmations, contradictions (quote the record), and unknown flags. Pass: timeline reaches the castle gate, or the failure point is documented with the last good state.
```

### FR20-FR24 - Area trials (one template)

```text
STEP <FRxx> (area trials). QUEUES: <list: FL20 + FL21 | FL22 + FL23 | FL24 + FL25 | FL26 + FL27 | FL28 + FL29>. Needs FR00 (FR20 also FR10). ROM: O.
Take the queue items of your iterations in priority order (P1 first). For each item: build the start state (quick warp or run_recipe warp with the flags the item names; use the preset flags from the item, or the FL32 draft if present), run the control and the forced trial from the same loaded state, record the observables, grade. Group items that share a scene so you warp once per scene and use load_state_file between trials. Time-box: at most 4 trials per item; at four failures mark INCONCLUSIVE with what blocked you.
Also for each scene you visit: confirm the scene-entry row of the FL report (is the player free? joypadMaskStd $065A after the banner; flags needed) and add it to a "scene entry" table in your result (feeds FR40).
Deliver: FRxx_<date>.md with one verdict row per queue item and the verdicts JSON (addendum item 1). Pass: all P1 items have a verdict; P2 80 % have one or an INCONCLUSIVE with the reason.
```

### FR30 - Engine and table domains

```text
STEP FR30 (engine and table domain trials). Needs FR00; queues of FL10-FL15 and FL30. ROM: O.
Trials (each with control and forced run and the standing control): (1) chest flag: in a chest scene (scene 0E herb chest, flag 01 of the 0200 group = global 0201; the harness has states orig_C1_chest-0E.mss and orig_C1_chest-1D-fanfare.mss) set the chest's global flag, reload the scene, confirm the chest is drawn open (PlaceOpenedChestTiles) and interaction gives nothing. (2) scene reward flag (0300 + scene): set it for a scene with a reward actor, reload, confirm the reward does not respawn. (3) kill flag: set 0400 + enemyNum for an enemy of a dungeon scene, reload, confirm the enemy is absent; enter the world map (scene FE) and confirm 0A80-0A9F are cleared and 0A00-0A7F are not. (4) boss reward flag 0500-0507 for one boss lair: set it, enter the lair, observe. (5) ability flags 0510+: set one, open the status menu, confirm the ability slot shows (TestAbilityFlag path) and that abilityBitmask 0AA2 reflects it (they are the same bits: write one, read the other). (6) event-block flag 0100+n: pick a block FL11 mapped, set the flag, reload the scene, confirm the tile change. (7) any other queue item of these iterations.
Deliver: FR30_<date>.md and the verdicts JSON; update nothing else. Pass: each domain has at least one VERIFIED-RUNTIME or CONTRADICTED trial with a firing control.
```

### FR40 - Scene entry sweep

```text
STEP FR40 (scene entry sweep). Needs FR00, FL32 (specs/FL32_scene-flags.json draft), the Mesen2 R2 sweep (extend its driver; do not duplicate its measurements). ROM: O.
For all 228 scene ids of db-us/groups.json (artifacts/scenes.json has the list): (a) quick warp with NO flags from a free-play state (A: the standing S01r), dismiss the banner, wait 60 frames, record sceneCurrent, joypadMaskStd $065A, actor count, whether the player moves with a 20-frame hold of each direction, a screenshot; (b) if the player is locked or the scene is a cutscene, retry with the draft flags of FL32 (and then with each single flag of the draft to find the minimal set); (c) classify free | locked-until-flag | cutscene | unreachable (does not load or crashes) | needs-spawn-position (the quick warp lands in a wall; give x,y from the spawn minus 8/16). Use run_script with kit.finish in batches of 20-40 scenes; positive control per batch (scene 0A with and without 63).
Deliver: FR40_<date>.md with one row per scene; specs/FR40_scene-flags.json in the format of plan 3.2 (entry, flags minimal set, note, source "Mesen2 FR40", grade VERIFIED-RUNTIME); the list of scenes whose draft differs from the observation. Pass: every scene classified or listed unreachable with the reason; the minimal flag set found for every locked scene or INCONCLUSIVE with what was tried.
```

### FR50 - Preset replay

```text
STEP FR50 (preset replay). Needs FR40, FL32 (specs/FL32_presets.json), FL40. ROM: O.
For each preset: from the standing free-play state write the flags (global indices), the items (inventory slots 0AB4-0AC3 as the preset lists them, then check the inventory screen once), the form (characterForm 0AD4 and the matching player state: verify what the game needs besides the word, by trial), abilities (abilityBitmask 0AA2 bits), gems; quick warp or full warp to the preset's verification scene; check the expected observation (NPC present, door open, boss flag clear...) with a control (the same warp without the preset). Save a library state orig_P<nn>_<name>.mss (meta {scene, flags, form}) when the validity test passes twice (load, test, load, test) and add the states-index.md row.
Deliver: FR50_<date>.md with one row per preset (expectation, observed, grade), the specs/FR50_presets_verdicts.json (flag-preset names, grade, corrections: for instance a missing flag or item), and the state files. Pass: each preset replayed with a firing control; failures name the missing piece.
```

---

## H. Apply pass and review prompts

### FA - Apply pass (hand to an agent only when you want it to run the steps; it still must not commit)

```text
APPLY PASS <phase/iterations>. Workspace c:\Work\gaia-iog-baserom. Read plan sections 3, 7 and the progress log. Inputs: plans/flags/results/registry/*.json, specs/*.json, plans/extracted-audit/mesen2-results/specs/FR*_flag_verdicts.json (when runtime results exist). For each input of the iterations I name, in order: (1) npm run flags -- <fragment> --dry-run; show me the counts and every rejection; stop if there are rejections I have not approved. (2) After my OK: apply, then npm run flags -- --check. (3) For each notes spec: npm run merge -- <spec> --dry-run, show the counts, apply after my OK. (4) Names specs the same way (npm run names). (5) Ask me to run npm run extract:lt myself if a spec needs tagged addresses; otherwise: npm run extract:lt, npm run rebuild (two separate commands), compare with the newest GATE: line of plans/extracted-audit/audit-of-audit/ACTION_PLAN.md, then npm run extract. (6) npm run flags -- export and npm run flags -- docs. (7) Update the progress log of plan section 12 with the dry-run counts. Never edit db files by hand, never commit: end with "Please commit when you're ready" and a suggested commit message.
```

### FLQA - Independent spot check (run after each phase; optional but recommended)

```text
QUALITY CHECK of <ITER list>. You did not write these records. Read plan sections 3.1, 3.6, 4.3 and the fragments plus reports of the iterations I name. Pick 12 flags at random across tiers (at least 3 scratch, 3 spine, 2 with grade VERIFIED-STATIC, 2 INFERRED). For each, re-derive the meaning from extracted/ without reading the author's conclusion first (find the sites yourself with the search recipes of plan 4.4), then compare with the record: meaning, name, kinds, grade, requires/excludes, evidence lines (open each cited file:line and check it says what is claimed). Also check 5 coverage-table rows against the inventory (site counts) and 3 scene notes against scene_actors.asm. Write plans/flags/results/FLQA_<yyyymmdd>.md: per flag agree / disagree / evidence wrong, systematic errors (for example branch sense reversed, scratch flag without scope, WRAM-relative index not converted), and a recommendation (accept, fix list, redo the iteration). Write nothing else; no git write commands.
```
