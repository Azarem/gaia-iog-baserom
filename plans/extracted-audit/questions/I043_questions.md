# I043 open questions

Mesen2 MCP was reachable but no ROM was running and no runtime session was set up, so everything below is UNVERIFIED-RUNTIME.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I043-1 | I043 | Does a `town_door` that is already on-screen at its first pass (the runtime spawn from `fr32_guide`, or a scene whose first actor tick finds the off-screen flag `$4000` clear) re-enter at `AnimOnce` and open without the Up hold, or is `WaitWhileOffscreen` always the loop head? | `InitActorFromSceneData` sets Flags10 `$4000` at spawn, so a scene-record door yields at `WaitWhileOffscreen` and keeps it as the entry pointer (`$00`); `WaitWhileOffscreen` only stores itself when the flag is set. If the flag were clear at the first pass the door would run `AnimOnce`, `MarkSolidHere` and the Init-time `BranchIfPlayerNear` -> `TownDoorOpenIdle` every frame | In scene `$01` / `$32`, watch the door actor's `$00` (entry pointer) for the first 10 frames after scene load and while walking up to a door; for the `fr32_guide` door (X `$0278`, Y `$0230`) walk next to it without pressing Up and check whether it opens |
