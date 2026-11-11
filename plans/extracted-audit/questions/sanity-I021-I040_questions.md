# Open questions from the I021–I040 sanity check

Mesen2 MCP was not available, so everything below is UNVERIFIED-RUNTIME. IDs use the prefix `OQ-SAN2-` (the I001–I020 sanity pass added none).

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-SAN2-1 | I025 | `CameraShakeActor` (`player_character`, tag 182097) plays sound `#15`, calls `CameraShakeFrame`, then does `DEC $26` / `BMI` / `RTL` with no `SetEntryHere`. Is sound `#15` queued once or on every tick of the 60-tick shake? | `ClimbDropLand` sets `$26 = $3C` through `STA $0026,Y` right after the spawn, so the length is 60. The actor loop resumes an actor at its entry pointer after an `RTL`; if the entry is still the spawn start, the `COP [PlaySoundCh2]` would run every tick | Land from a Freedan vine drop and log the sound queue (`$06F8` family) for the first 10 ticks |
| OQ-SAN2-2 | I033 | After the `FineAdjustXWest` / `FineAdjustXEast` direction fixes: does the north-wall slide really move the player EAST by `$02 − n` px when `$09` is under the left foot (and the mirror for `FineAdjustXEast`)? | E1 arithmetic (the `ORA #$FFF0` / `EOR #$FFFF` / `INC` chain gives `m = 16 − n`; `$22` is set to the new left edge + 8); the old comments and names said the opposite | Stand with the left foot against a `$09` cell and step up; log `$22` before and after |
