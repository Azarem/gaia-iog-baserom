# Rename and doc-correction proposals — sanity check I051–I060

No new rename proposals. Names are not changed in audit iterations (renames are processed in a separate run), and the sanity pass found no wrong or misleading identifier beyond those already recorded in `I051_renames.md` … `I060_renames.md`. The ledgers were not edited.

## Ledger and doc corrections found (not applied)

| ID | Where | Statement | Correct reading |
|----|-------|-----------|-----------------|
| D-S5160-1 | `renames/I060_renames.md` R-I060-3 | the bytes after `code_03B922` "are the text Nothing!!" | They are the empty `[TPL:11]` template (the same as `dialogstring_03B92B`); "Nothing!!" is `dialogstring_03B949`, printed by choice `$26`. The rename itself (`loc_03B928` → `dialogstring_03B928`, type `DialogString`) is correct and is already in the user's staged `db-us/types.json` (244008) |
| D-S5160-2 | `notes/partNotes/bank03.json` line 237 (`"loc_03B928"`) | orphan note for the label that no longer exists | Delete the line by hand; `merge` cannot remove a note whose label is gone. The new `dialogstring_03B928` note replaces it |
| D-S5160-3 | `extracted/system/world_map/world_map_routes.asm` header (cannot be annotated: no bank information) | steps are `route-step < flags, direction, ?, distance >` | A step is three `movement_delta_table` indices (X `$CA`, Y `$CC`, rotation `$BC`; 0 = still) and a tick count n (n + 1 ticks); see the `world_map_options` and `WorldMapController` block notes. Fixing the file's own header needs a bank source in the merge tool (or a `?BANK` line in the extracted file) |
| D-S5160-4 | any doc that states a `WaitByte` / `WaitWord` operand as the number of frames | "WaitByte #1D waits 29 frames" | `WaitByte(n)` resumes n + 1 ticks later (`cop_handlers_wait`); the ledgers' `I051`–`I060` results files still quote the operand in places and are frozen |
