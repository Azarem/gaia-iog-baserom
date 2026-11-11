# I061 open questions

Mesen2 MCP was not available, so everything below is UNVERIFIED-RUNTIME. IDs are cited in the merged notes.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I061-1 | I061 | Which code reaches `body_table` rows `$03` and `$08`? Row `$03` is a copy of row `$02` (Shadow) and row `$08` is Shadow mode | E1/E2: `SetPlayerSpriteDirect` documents operands 0-8 but no `#03` / `#08` site was found; `characterForm` 3 is not traced; `GetPlayerFacingDirection` has no table for rows 0-3 and 8 | Break on `SetPlayerSpriteDirect` (COP #8E) and on `characterForm` writes through a Shadow sequence; list the operands |
| OQ-I061-2 | I061 | Why do `direction_velocity_table` rows `$00`=`$05`, `$01`=`$03`, `$02`=`$04` repeat, and which step codes do the real warp and walk-step streams use? | E1: both loaders index the table by a stream byte; the rows were decoded but the data in `scene_warps` (stair-warp 13-byte streams) was not matched against the codes | Break on `ReadDirSprite_YVelocity` / `_XVelocity` and `InitActorFromSceneData` (`warpFacing`) over all warps and log the step codes |
| OQ-I061-3 | I061 | Can any of the 16 scene ids that share `scene_event_0C8200` (title TEST MAP) be loaded? | E2: no `scene-warp` destination and no `QueueMapChange` operand with those ids was found by search; scripts that build a scene id from data were not traced | Break on `sceneCurrent` writes for those ids through a full playthrough, or scan every `QueueMapChange` operand and warp table in the ROM |
