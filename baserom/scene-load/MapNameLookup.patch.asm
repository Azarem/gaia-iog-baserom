; ==============================================================================
; SpawnSceneActors epilogue - scene title pointer for name display
; ==============================================================================
; What it does: At the end of scene actor spawning, loads a pointer from
;   scene_actors_extract_table indexed by sceneCurrent ($0646) into $3E, then
;   still sets playerActorDp ($09F4) to $1000 before return.
; Vanilla behavior: loc_03CEEC only stored $1000 to $09F4 and returned; $3E
;   was left on the actor list $FF terminator (title followed in ROM layout).
; Hooks (overrides): actor_execution.loc_03CEEC (SpawnSceneActors exit).
; Depends on: scene_actors.scene_actors_extract_table (extracted title pointer
;   table, parallel to scene id index).
; State: Reads sceneCurrent $0646; writes scene data pointer $3E, playerActorDp
;   $09F4; DEC adjusts table entry to title string address.
; Hazards/notes: No ?BANK in file (patch targets bank $00 actor_execution);
;   table must match post-Extract scene_actors layout.
; ==============================================================================


  actor_execution.loc_03CEEC!:
    LDX $0646
    LDA $@scene_actors_extract_table, X
    DEC
    STA $3E
    LDA #$1000
    STA $09F4
    PLP 
    RTL 