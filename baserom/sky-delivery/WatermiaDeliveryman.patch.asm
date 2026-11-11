; ==============================================================================
; Watermia (scene $78) - Sky Deliveryman fast travel NPC
; ==============================================================================
; What it does: Appends a Sky Deliveryman actor to scene $78; dialog offers a
;   one-way trip to South Cape (scene $0D in $0D60, warp COP 65/26 to $78 coords).
; Vanilla behavior: scene_78_actors had no deliveryman entry at the patched slot.
; Hooks (overrides): scene_actors.scene_78_actors+= (actor-spawn append).
; Adds: One actor-spawn row only (no new actor_def in this file).
; Depends on: @wa78_men actor pointer (vanilla label in extracted/watermia/wa78_men.asm).
; State: Writes nextScene $0D60, map queue $064A $0404 on confirm.
; Hazards/notes: Actor COP requires X = actor slot; skyd_confirm uses fixed warp
;   operands (#$00D4, #$03A4, scene #78) — verify against intended destination.
; ==============================================================================

scene_actors.scene_78_actors+=: actor-spawn < #14, #23, #07, @wa78_men >
