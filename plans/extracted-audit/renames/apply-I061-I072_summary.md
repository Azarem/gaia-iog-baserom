# Names pass I061-I072 (applied)

Specs: `apply-I061_names.json` ... `apply-I072_names.json` in this folder. Applied with `npm run names -- <spec>`, then `npm run extract:lt`, `npm run rebuild` (gate unchanged: checksum 223006080, crc 2083230829, totalSize 3062204) and `npm run names -- --check` (3510 names).

`apply-I061` and `apply-I062` were written with hex addresses before the rule "address = decimal `; {n}` integer" was settled. They were applied and are not replayable. I063 onward use decimal integers.

| Spec | Entries | Content |
|------|---------|---------|
| I061 | 242 | `walk_step_table`, `scene_default_actors`, `scene_00_actors` ... `scene_FF_actors` |
| I062 | 103 | `ability_damage_*`, adrift wave, `move_chain_*` |
| I063 | 97 | snake pit fx, `shared_word_*`, `freedan_anim_*` |
| I064 | 92 | `forced_walk_pan_*`, freejia tilefx, `will_anim_*` |
| I065 | 41 | `dialog_template_*`, `parallax_empty_*`, `SceneCmd_*` |
| I066 | 79 | `aura_anim_*`, `shadow_anim_*` |
| I067 | 67 | `item_pickup_text_*` (table, 32 strings), item dialog wrappers, `projectile_launch/travel_*`, `transform_pose_*` |
| I068 | 258 | `npc_props_*`, `display_preset_*`, `warp_def_*` (200 lists) |
| I069 | 34 | `freedan_fx_*`, `shadow_fx_*`, block `spriteset_pickups_effects` and `pickups_effects_*` |
| I070 | 7 | `dark_friar_*` |
| I071 | 44 | `spriteset_shadow_aura_body`, `shadow_aura_anim_*`, `chest_list_none`, `chest_list_scene_NN` |
| I072 | 4 | `boot_title_strings`, `item_name_line_table`, `thinker_spawn_dispatcher_only`, `spriteset_will_abilities` |

## Deviations from the ledgers

- I067: the ledger name `item_name_table` is already the name at 121535 (the menu item names). The dialog table is `item_pickup_text_table`, its strings `item_pickup_text_NN`.
- I071: the block is `spriteset_shadow_aura_body` (the ledger's safer wording), so it does not read like `spriteset_aura`.
- I072-R1: `consolestring_01D9D8` (blocks.json part) shadowed the names entry `boot_screen_strings` on the same address. `names-merge` now accepts the label the asm prints as `old` in that case and renames both.
- The block `spriteset_will_projectile` became `spriteset_darkgaia_projectile`, so `baserom/equipped-icon/spriteset_will_projectile.asm` was moved to `spriteset_darkgaia_projectile.asm` (block patches are matched by file name).

## Not applied

Mnemonic and struct field names (`structs.json`, `mnemonics.json`), extractor-generated or derived labels (`meta_label_NN`, `scene_actors_extract_table`), the 456 dictionary index names (I070-R2), `blocks.json` part additions for hidden sprite groups (R-I071-3, R-I072-6), extractor changes (R-I069-3), the `scene_reward_tier` transform (R-I070-4), and the doc-fact rows (`R-*-5`, `R-I071-4`, `R-I072-5`: edited by the user).
