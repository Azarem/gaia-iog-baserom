; Actor and thinker execution loop system (248565–250357, Bank 03).
; 
; Contains the complete actor update pipeline — five distinct execution contexts that the main game loop calls to process active actors each frame, plus actor/thinker pool initialization and scene actor spawning infrastructure.
; 
; === EXECUTION CONTEXTS ===
; 
; Five actor processing modes selected by game state flags:
; 
; 1. RunActors_Normal (248565): Standard gameplay. Checks playerFlags for pause ($0010) → PauseFiltered, or displayModeFlags ($0080) → DisplayFiltered. Processes each actor in the linked list ($56 head → $06 next). For each actor: sets DP/X to slot, checks COP script timer ($08), manages iframe countdown via $7F0028,X, dispatches to actor's COP script via the RTL trick ($00:$02), then applies post-tick movement.
; 
; 2. RunActors_DisplayFiltered (248739): Active when displayModeFlags bit 7 set. Only processes actors with bit 12 ($1000) set in primary ($10) or secondary ($12) flags.
; 
; 3. RunActors_PauseFiltered (248893): Active when playerFlags bit 4 set. Only processes actors with $12 bits 12|2 ($1004) or $10 bits 12|10 ($1400). Has a special iframe-only tail for non-immune actors.
; 
; 4. RunActors_CutsceneOnly (249087): Cutscene playback. Only processes actors with $10 bit 11 ($0800). Clears bit 2 each frame.
; 
; 5. RunActors_OverlayOnly (249198): Overlay rendering. Checks display filter first. Only processes actors with $12 bit 12 ($1000). Always uses simple ApplyMovement (no collision).
; 
; === COP SCRIPT DISPATCH ===
; 
; All contexts use the same indirect call mechanism: PHK / PEA PostTick-1 / SEP #$20 / LDA $02 (bank) / PHA / REP #$20 / LDA $00 (addr-1) / PHA / RTL. This pushes a return address and a target address; RTL pops the target and jumps. The -1 adjustments account for RTL adding 1.
; 
; === IFRAME COUNTER ($7F0028,X) ===
; 
; Positive values count down (invincibility frames). Negative values count up toward zero (recovery/stagger). When zero, bit 7 ($0080) of $10 is cleared. The player actor (CPX $playerActor) is exempt from the next-actor skip — always gets full processing.
; 
; === ACTOR POOL (InitActorPool, 249308) ===
; 
; Actor pool: base $0E00, 84 slots of $30 bytes, free list at $4E/$50. Data regions: $1000–$1FBF (primary), $7F1000 (callbacks), $7F2000 (extended). Thinker pool: base $7E3000, 16 slots of $10 bytes, free list at $52/$54. Data at $0F00, $7F0E00, $7F3000. Scene $FF uses simplified clear (skips $7F2000/$7F3000).
; 
; === SCENE SPAWNING (SpawnSceneActors, 249505) ===
; 
; Reads scene_actors table to spawn actors. Each actor: allocate slot via ActorPoolAllocator, link into doubly-linked list ($04/$06), call InitActorFromSceneData to parse the binary record.
; 
; === ACTOR RECORD FORMAT (InitActorFromSceneData, 249627) ===
; 
; Variable-length record: byte 0-1 = X/Y tile (×16→pixels), byte 2 = type flags (bit 0 = addressing mode), bytes 3-4 = code pointer, byte 5 = bank, byte 6 = stats index, byte 7 = enemy number, byte 8 = death action. Player actors (bit 15 of $10) get special init: load character form body table, set spriteset, compute camera centering.
; 
; Enemies with nonzero enemyNum are checked against WRAM defeat flags (CheckEnemyDefeatedFlag). Already-defeated actors are freed via AdvanceSceneDataAndFree and their event block tiles are swapped.
; 
; === THINKER TYPES (250157–250357) ===
; 
; Four thinker execution filters on $7F000E,X (animScratch2):
; - TypeA: bit 2 CLEAR (general-purpose thinkers)
; - TypeB: bit 2 SET (deferred/secondary thinkers)
; - TypeC: bit 11 SET and bit 2 CLEAR (cutscene overlay thinkers)
; - TypeD: bits 11 AND 2 both SET (cutscene deferred thinkers)
; 
; All use the same COP dispatch pattern, traversing the thinker list ($5A → $06).
---------------------------------------------

?BANK 03

?INCLUDE 'body_table'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'dir_sprite_01ABDE'
?INCLUDE 'event_blocks'
?INCLUDE 'scene_actors'
?INCLUDE 'sprite_composition'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'tile_collision_physics'

!sceneCurrent                   0644
!joypadCurrent                  0656
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!playerActorDp                  09F4
!wramFlags                      0A80
!characterForm                  0AD4
!activeActorCount               0DBC
!thinkerPoolAddrs               7E3000
!spritesetPtr                   7F0006
!animScratch2                   7F000E
!statsPtr                       7F0020
!enemyNum                       7F0022
!deathActionIdx                 7F0024
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!onHitCallback                  7F1000

---------------------------------------------

; Standard actor execution loop — primary gameplay processing mode.
; 
; Entry point for actor updates during normal gameplay. Saves processor state (PHP/PHD), switches to 16-bit mode, then checks game state flags to determine processing mode:
; - playerFlags bit 3 ($0008): Input lock — clears B button ($8000) from joypadCurrent
; - playerFlags bit 4 ($0010): Game paused — redirects to RunActors_PauseFiltered
; - displayModeFlags bit 7 ($0080): Display filter — redirects to RunActors_DisplayFiltered
; 
; If no filter is active, processes the actor linked list starting from $56. For each actor:
; 1. Sets DP and X to the actor's slot address (TCD/TAX)
; 2. Checks COP script mode (bit 13 $2000 in $10) — if active, dispatches to the actor's COP script entry point
; 3. Manages iframe counter ($7F0028,X): positive counts down (invincibility), negative counts up (recovery), zero clears the $0080 flag
; 4. Non-player actors skip COP dispatch during active iframes (player always gets full processing)
; 5. Dispatches to the actor's script via the RTL indirect call trick
; 6. Post-tick: clears bit 2 of $10, then applies movement (collision-aware if grounded $0008, simple otherwise)
; 7. Follows $06 link to next actor
; 
; The COP dispatch pattern (PHK/PEA/SEP/LDA/PHA/REP/LDA/DEC/PHA/RTL) constructs a 3-byte target address and 3-byte return address on the stack. RTL pops and jumps to the target; when the actor script returns via RTL, execution resumes at the PostTick handler.

RunActors_Normal {
    PHP                   ; Save processor status and direct page — restored at exit (loc_03CB90)
    PHD 
    REP #$20              ; 16-bit accumulator for all flag checks and actor data access
    LDA $playerFlags      ; Load player flags to check for input lock, pause, and display filter states
    BIT #$0008            ; Bit 3 ($0008) = input lock flag; suppress B button when set
    BEQ loc_03CB07
    LDA #$8000            ; Clear bit 15 ($8000) of joypad state — prevent attack input during input lock
    TRB $joypadCurrent

  loc_03CB07:
    BIT #$0010            ; Bit 4 ($0010) = game paused; redirect to PauseFiltered processing
    BEQ loc_03CB0F
    JMP $&RunActors_PauseFiltered

  loc_03CB0F:
    LDA $displayModeFlags ; Check display mode flags for rendering-only state
    BIT #$0080            ; Bit 7 ($0080) = display filter active; redirect to DisplayFiltered processing
    BEQ loc_03CB1A
    JMP $&RunActors_DisplayFiltered

  loc_03CB1A:
    LDA $56               ; Load first actor pointer from linked list head ($56)
    BEQ loc_03CB90        ; No actors in list → skip directly to exit

  loc_03CB1E:
    TCD                   ; Set direct page to actor slot address for DP-relative field access
    TAX                   ; Also set X to actor slot for absolute,X indexed access to extended fields
    LDA $10               ; Load actor primary flags word ($10 = status/control register)
    BIT #$2000            ; Bit 13 ($2000) = actor is executing a COP script
    BEQ loc_03CB3D        ; Not in COP script → skip to iframe check
    DEC $08               ; Decrement COP script frame delay counter ($08)
    BPL RunActors_CopScriptPostTick ; Timer still positive → skip COP dispatch, jump to CopScriptPostTick
    STZ $08               ; Timer expired — reset to zero and prepare COP script dispatch
    PHK                   ; Push current bank (K) as return bank for RTL trick
    PEA $&RunActors_CopScriptPostTick-1 ; Push CopScriptPostTick-1 as return address (RTL adds 1)
    SEP #$20              ; Switch to 8-bit A to push bank byte of actor script address
    LDA $02               ; Load actor script bank byte from DP $02
    PHA 
    REP #$20              ; Back to 16-bit A for script address push
    LDA $00               ; Load actor script entry point address from DP $00
    DEC                   ; Subtract 1 — RTL will add 1 to the popped address
    PHA 
    RTL                   ; RTL: pop 3-byte address from stack and jump to actor's COP script

  loc_03CB3D:
    BIT #$0080            ; Bit 7 ($0080) = actor has active invincibility/iframe state
    BEQ loc_03CB62        ; No iframe state → skip to COP dispatch
    LDA $iframeCounter, X ; Load iframe counter from extended actor data ($7F0028,X)
    BEQ loc_03CB5D        ; Counter is zero → clear iframe flag (bit 7 of $10)
    BMI loc_03CB56        ; Counter negative → recovery phase, incrementing toward zero
    DEC                   ; Counter positive → decrement invincibility frames
    STA $iframeCounter, X ; Write decremented counter back to extended data
    CPX $playerActor      ; Check if this is the player actor ($09AA)
    BEQ loc_03CB62        ; Player actor always gets full COP dispatch regardless of iframes
    BRA loc_03CB8C        ; Non-player actor during iframes: skip COP dispatch, jump to next actor

  loc_03CB56:
    INC                   ; Recovery phase: increment negative counter toward zero
    STA $iframeCounter, X
    BNE loc_03CB62

  loc_03CB5D:
    LDA #$0080            ; Counter reached zero — clear iframe state
    TRB $10               ; Clear bit 7 ($0080) from primary flags to end iframe state

  loc_03CB62:
    DEC $08               ; Decrement frame delay counter for standard (non-COP) actors
    BPL RunActors_PostTick ; Timer still positive → skip directly to PostTick
    STZ $08               ; Timer expired — reset and dispatch to actor's script via RTL trick
    PHK 
    PEA $&RunActors_PostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

---------------------------------------------
; Post-tick handler shared by Normal and CopScriptPostTick paths.
; 
; Clears bit 2 ($0004) of $10 — the per-frame collision contact flag is reset before movement. Then checks bit 3 ($0008 = grounded): if set, calls ApplyMovementWithCollision for full tile collision-aware movement; otherwise calls ApplyMovement for simple delta application.
; 
; After movement, reads $06 (next actor link). If nonzero, loops back to process the next actor. If zero (end of list), restores DP/flags via PLD/PLP/RTL.

RunActors_PostTick {
    LDA $10               ; Post-tick: clear transient flags and apply per-frame movement
    AND #$FFFB            ; Clear bit 2 ($0004) — collision contact flag reset each frame
    STA $10
    BIT #$0008            ; Bit 3 ($0008) = grounded flag; determines collision mode
    BEQ loc_03CB89        ; Not grounded → use simple ApplyMovement (no tile collision)
    JSR $&tile_collision_physics.ApplyMovementWithCollision ; Grounded: full tile collision-aware movement via ApplyMovementWithCollision
    BRA loc_03CB8C

  loc_03CB89:
    JSR $&tile_collision_physics.ApplyMovement ; Airborne path: simple position delta application via ApplyMovement

  loc_03CB8C:
    LDA $06               ; Load next actor link from DP $06 (linked list forward pointer)
    BNE loc_03CB1E        ; Nonzero = more actors in list → loop back to process next

  loc_03CB90:
    PLD                   ; All actors processed — restore DP and processor flags, exit
    PLP 
    RTL 
}

---------------------------------------------
; Post-tick handler for actors that just returned from COP script execution.
; 
; Checks if the actor is still in COP mode (bit 13 $2000). If cleared (script completed this frame), falls through to normal PostTick. If still in COP mode, checks secondary flags ($12) bit 3 ($0008) — this flag requests collision movement even during COP execution. If set, performs PostTick; if clear, skips directly to the next actor.

RunActors_CopScriptPostTick {
    LDA $10               ; Post-tick for actors returning from COP script execution
    BIT #$2000            ; Check if actor is still in COP mode (bit 13 $2000)
    BEQ RunActors_PostTick ; COP mode ended → normal PostTick path
    LDA $12               ; Still in COP mode — check secondary flags for movement request
    BIT #$0008            ; Bit 3 ($0008) of $12 = COP script requested collision movement
    BEQ loc_03CB8C        ; No collision request → skip to next actor (no movement this frame)
    BRA RunActors_PostTick ; Has collision request → perform normal PostTick movement
}

---------------------------------------------
; Display-filtered actor execution — processes only display-active actors.
; 
; Active when displayModeFlags bit 7 ($0080) is set. Iterates the actor linked list but only processes actors where bit 12 ($1000) is set in either primary flags ($10) or secondary flags ($12). Actors without this flag are skipped entirely (no COP dispatch, no movement).
; 
; Otherwise identical lifecycle to RunActors_Normal: iframe management, COP script dispatch, collision/simple movement selection.

RunActors_DisplayFiltered {
    LDA $56               ; Display-filtered execution: only process actors with display-active flag
    BNE loc_03CBAA        ; Check actor list head — empty list jumps to exit
    JMP $&RunActors_DisplayFiltered_Exit

  loc_03CBAA:
    TCD 
    TAX 
    LDA $10               ; Load primary flags for display-active check
    BIT #$1000            ; Bit 12 ($1000) in primary = actor renders during display filter
    BNE loc_03CBBC        ; Primary display flag set → process this actor
    LDA $12               ; Check secondary flags ($12) for display-active
    BIT #$1000            ; Bit 12 ($1000) in secondary also qualifies actor for processing
    BEQ loc_03CC26        ; Neither flag set → skip to next actor (no processing during display filter)
    LDA $10               ; Reload primary flags for COP mode check

  loc_03CBBC:
    BIT #$2000
    BEQ loc_03CBD7
    DEC $08
    BPL RunActors_DisplayFiltered_CopPostTick
    STZ $08
    PHK 
    PEA $&RunActors_DisplayFiltered_CopPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CBD7:
    BIT #$0080
    BEQ loc_03CBFC
    LDA $iframeCounter, X
    BEQ loc_03CBF7
    BMI loc_03CBF0
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CBFC
    BRA loc_03CC26

  loc_03CBF0:
    INC 
    STA $iframeCounter, X
    BNE loc_03CBFC

  loc_03CBF7:
    LDA #$0080
    TRB $10

  loc_03CBFC:
    DEC $08
    BPL RunActors_DisplayFiltered_PostTick
    STZ $08
    PHK 
    PEA $&RunActors_DisplayFiltered_PostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunActors_DisplayFiltered_PostTick {
    LDA $10               ; Display-filtered PostTick: same movement logic as normal PostTick
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03CC23
    JSR $&tile_collision_physics.ApplyMovementWithCollision
    BRA loc_03CC26

  loc_03CC23:
    JSR $&tile_collision_physics.ApplyMovement

  loc_03CC26:
    LDA $06
    BNE loc_03CBAA
}

RunActors_DisplayFiltered_Exit {
    PLD                   ; Display-filtered exit: restore DP and processor flags
    PLP 
    RTL 
}

RunActors_DisplayFiltered_CopPostTick {
    LDA $10               ; Display-filtered COP PostTick: check COP continuation and movement request
    BIT #$2000
    BEQ RunActors_DisplayFiltered_PostTick
    LDA $12
    BIT #$0008
    BEQ loc_03CC26
    BRA RunActors_DisplayFiltered_PostTick
}

---------------------------------------------
; Pause-filtered actor execution — processes only pause-immune actors.
; 
; Active when playerFlags bit 4 ($0010) is set (game paused). Two paths to qualify:
; 1. Secondary flags ($12) bits 12|2 ($1004) set — secondary pause immunity
; 2. Primary flags ($10) bits 12|10 ($1400) set — primary pause immunity
; 
; Actors failing both checks go to an iframe-only handler (loc_03CCCD) that still counts down iframe timers but skips COP dispatch entirely. This ensures invincibility timers don't freeze during pause.
; 
; Pause-immune actors get full COP dispatch and collision movement, allowing cutscene actors, UI elements, and certain effects to continue running during pause.

RunActors_PauseFiltered {
    LDA $56               ; Pause-filtered execution: only process pause-immune actors
    BNE RunActors_PauseFiltered_Body
    JMP $&RunActors_PauseFiltered_Exit

  RunActors_PauseFiltered_Body:
    TCD                   ; Per-actor loop body: set DP/X to actor slot
    TAX 
    LDA $12               ; Load secondary flags ($12) for pause-immunity check
    BIT #$1004            ; Bits 12|2 ($1004) = secondary pause-immunity flags
    BNE loc_03CC54        ; Secondary immunity → process this actor
    LDA $10               ; Fall through: check primary flags for pause immunity
    BIT #$1400            ; Bits 12|10 ($1400) = primary pause-immunity flags
    BEQ loc_03CCCD        ; No immunity → skip to iframe-only processing (no COP dispatch)

  loc_03CC54:
    BIT #$2000            ; Pause-immune actor: check for COP script mode
    BEQ loc_03CC72        ; Not in COP mode → skip to iframe check
    DEC $08               ; Decrement COP timer during pause-filtered mode
    BMI loc_03CC60        ; Timer positive → jump directly to CopPostTick
    JMP $&RunActors_PauseFiltered_CopPostTick

  loc_03CC60:
    STZ $08
    PHK 
    PEA $&RunActors_PauseFiltered_CopPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CC72:
    BIT #$0080
    BEQ loc_03CC97
    LDA $iframeCounter, X
    BEQ loc_03CC92
    BMI loc_03CC8B
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CC97
    BRA loc_03CCC3

  loc_03CC8B:
    INC 
    STA $iframeCounter, X
    BNE loc_03CC97

  loc_03CC92:
    LDA #$0080
    TRB $10

  loc_03CC97:
    DEC $08
    BPL RunActors_PauseFiltered_PostTick
    STZ $08
    PHK 
    PEA $&RunActors_PauseFiltered_PostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunActors_PauseFiltered_PostTick {
    LDA $10               ; Pause-filtered PostTick: same collision/simple movement choice
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03CCBE
    JSR $&tile_collision_physics.ApplyMovementWithCollision
    BRA loc_03CCC3

  loc_03CCBE:
    JSR $&tile_collision_physics.ApplyMovement
    BRA loc_03CCC3

  loc_03CCC3:
    LDA $06               ; Load next actor link; exit if zero, loop if nonzero
    BEQ RunActors_PauseFiltered_Exit
    JMP $&RunActors_PauseFiltered_Body
}

RunActors_PauseFiltered_Exit {
    PLD                   ; Pause-filtered exit: restore DP and processor flags
    PLP 
    RTL 

  loc_03CCCD:
    BIT #$0080            ; Iframe-only processing for non-immune paused actors (no COP dispatch)
    BEQ loc_03CCC3        ; No iframe state → skip directly to next actor link
    LDA $iframeCounter, X ; Load iframe counter for paused actor
    BEQ loc_03CCE8
    BMI loc_03CCE1
    DEC 
    STA $iframeCounter, X
    BRA loc_03CCC3

  loc_03CCE1:
    INC 
    STA $iframeCounter, X
    BRA loc_03CCC3

  loc_03CCE8:
    LDA #$0080            ; Counter reached zero during pause — clear iframe bit 7
    TRB $10
    BRA loc_03CCC3
}

RunActors_PauseFiltered_CopPostTick {
    LDA $10               ; Pause-filtered COP PostTick: check continuation and movement request
    BIT #$2000
    BEQ RunActors_PauseFiltered_PostTick
    LDA $12
    BIT #$0008
    BEQ loc_03CCC3
    BRA RunActors_PauseFiltered_PostTick
}

---------------------------------------------
; Cutscene-only actor execution — processes only cutscene-flagged actors.
; 
; Active during cutscene playback. Clears bit 2 of $10 for every actor (not just processed ones). Only dispatches COP scripts for actors with bit 11 ($0800) set — the cutscene-active flag. Actors without this flag skip directly to the next-actor link.
; 
; No iframe management is performed in this mode.

RunActors_CutsceneOnly {
    PHP                   ; Cutscene-only execution: save state, process only cutscene-flagged actors
    PHD 
    REP #$20
    LDA $56               ; Load actor list head ($56); empty → skip to exit
    BEQ loc_03CD5B

  loc_03CD07:
    TCD 
    TAX 
    LDA $10               ; Clear bit 2 ($0004) — collision flag cleared for all cutscene actors
    AND #$FFFB
    STA $10
    BIT #$0800            ; Bit 11 ($0800) = cutscene-active flag; skip actors without it
    BEQ loc_03CD57        ; Not cutscene-active → skip to next actor link
    LDA $10               ; Reload $10 for COP mode check (AND destroyed bit 2 above)
    BIT #$2000
    BEQ loc_03CD32
    DEC $08
    BPL RunActors_CutsceneOnly_CopPostTick
    STZ $08
    PHK 
    PEA $&RunActors_CutsceneOnly_CopPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CD32:
    DEC $08
    BPL RunActors_CutsceneOnly_PostTick
    STZ $08
    PHK 
    PEA $&RunActors_CutsceneOnly_PostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunActors_CutsceneOnly_PostTick {
    LDA $10               ; Cutscene PostTick: collision-aware or simple movement
    BIT #$0008
    BEQ loc_03CD54
    JSR $&tile_collision_physics.ApplyMovementWithCollision
    BRA loc_03CD57

  loc_03CD54:
    JSR $&tile_collision_physics.ApplyMovement ; Airborne: simple ApplyMovement

  loc_03CD57:
    LDA $06               ; Load next actor link; loop or exit
    BNE loc_03CD07

  loc_03CD5B:
    PLD                   ; Cutscene exit: restore DP and processor flags
    PLP 
    RTL 
}

RunActors_CutsceneOnly_CopPostTick {
    LDA $10               ; Cutscene COP PostTick: check continuation and movement request
    BIT #$2000
    BEQ RunActors_CutsceneOnly_PostTick
    LDA $12
    BIT #$0008
    BEQ loc_03CD57
    BRA RunActors_CutsceneOnly_PostTick
}

---------------------------------------------
; Overlay-only actor execution — processes overlay actors with special display handling.
; 
; First checks displayModeFlags bit 7 ($0080) — if set, redirects entirely to RunActors_DisplayFiltered (display filter takes precedence over overlay).
; 
; Otherwise, only processes actors with bit 12 ($1000) set in secondary flags ($12). Unlike other modes, the PostTick always uses simple ApplyMovement (no tile collision check), since overlay actors typically don't interact with terrain.

RunActors_OverlayOnly {
    PHP                   ; Overlay-only execution: save state, check display filter first
    PHD 
    REP #$20
    LDA $displayModeFlags ; Check display mode flags — display filter takes precedence
    BIT #$0080            ; Bit 7 ($0080) set → redirect entirely to RunActors_DisplayFiltered
    BEQ loc_03CD7D
    JMP $&RunActors_DisplayFiltered

  loc_03CD7D:
    LDA $56               ; Load actor list head; empty → skip to exit
    BEQ loc_03CDC9

  loc_03CD81:
    TCD 
    TAX 
    LDA $12               ; Check secondary flags ($12) for overlay-active bit
    BIT #$1000            ; Bit 12 ($1000) in secondary = overlay-active actor
    BEQ loc_03CDC5        ; Not overlay-active → skip to next actor link
    LDA $10               ; Clear bit 2, then check COP mode
    AND #$FFFB
    STA $10
    BIT #$2000
    BEQ loc_03CDAC        ; Not in COP mode → standard frame delay dispatch
    DEC $08
    BPL loc_03CDC5
    STZ $08
    PHK 
    PEA $&RunActors_OverlayOnly_CopPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CDAC:
    DEC $08
    BPL RunActors_OverlayOnly_PostTick
    STZ $08
    PHK 
    PEA $&RunActors_OverlayOnly_PostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunActors_OverlayOnly_PostTick {
    JSR $&tile_collision_physics.ApplyMovement ; Overlay PostTick: always uses simple ApplyMovement (no collision for overlays)

  loc_03CDC5:
    LDA $06               ; Load next actor link; loop back if more actors
    BNE loc_03CD81

  loc_03CDC9:
    PLD                   ; Overlay exit: restore DP and processor flags
    PLP 
    RTL 
}

RunActors_OverlayOnly_CopPostTick {
    LDA $10               ; Overlay COP PostTick: check continuation and movement request
    BIT #$2000
    BEQ RunActors_OverlayOnly_PostTick
    LDA $12
    BIT #$0008
    BEQ loc_03CDC5
    BRA RunActors_OverlayOnly_PostTick
}

---------------------------------------------
; Initialize both actor and thinker memory pools.
; 
; Actor pool:
; - Free list stored at $0E00 as word-sized entries
; - Pool head pointer at $4E, count at $50
; - 84 actor slots, each $30 bytes, starting at $1000 ($1000, $1030, $1060, ... $1F90)
; - Free list built by storing ascending slot addresses, terminated by $FFFF sentinel
; - Zeroes primary actor data ($1000–$1FBF), callback table ($7F1000), and extended data ($7F2000)
; 
; Thinker pool:
; - Free list at $7E3000 (long pointer $52/$54)
; - 16 thinker slots, each $10 bytes, starting at $0F00
; - Free list built similarly with $FFFF sentinel
; - Zeroes thinker data at $0F00, $7F0E00, and $7F3000
; 
; Scene $FF (title screen) uses a simplified clear path that skips the $7F2000 actor range and the $7F3000 thinker range, preserving state needed for the title sequence.

InitActorPool {
    PHP                   ; === Initialize actor and thinker memory pools ===
    REP #$20              ; 16-bit accumulator for pool setup
    LDX #$0E00            ; Actor free list base address: $0E00 in WRAM
    STX $4E               ; Store pool base to free list head pointer ($4E)
    LDA #$0000            ; Zero the pool occupancy counter ($50)
    STA $50
    LDA #$1000            ; First actor data slot starts at $1000
    LDX #$0000            ; Begin building free list from index 0

  loc_03CDEF:
    STA $0E00, X          ; Write slot address to free list entry; each slot is $0030 bytes
    INX 
    INX 
    CLC 
    ADC #$0030
    CPX #$00A8            ; 84 actor slots total ($00A8 / 2 entries, $30-byte stride each)
    BMI loc_03CDEF
    LDA #$FFFF            ; $FFFF sentinel marks end of actor free list
    STA $0E00, X
    LDA $sceneCurrent     ; Check current scene for special initialization path
    CMP #$00FF            ; Scene $FF (title screen) uses simplified memory clear
    BEQ loc_03CE23
    LDX #$0000
    TXA 

  loc_03CE0F:
    STA $1000, X          ; Zero actor data: $1000 primary, $7F1000 callbacks, $7F2000 extended
    STA $onHitCallback, X
    STA $7F2000, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE0F        ; Loop until all $0FC0 bytes cleared across three regions
    BRA loc_03CE35        ; Normal scenes: skip to thinker pool init

  loc_03CE23:
    LDX #$0000            ; Scene $FF: simplified clear skips $7F2000 extended region
    TXA 

  loc_03CE27:
    STA $1000, X
    STA $onHitCallback, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE27

  loc_03CE35:
    LDX #$3000            ; Thinker pool pointer: $7E:3000 (long address in $52/$54)
    STX $52
    LDA #$007E
    STA $54
    LDA #$0F00            ; First thinker slot at $0F00; $10 bytes per slot
    LDX #$0000

  loc_03CE45:
    STA $thinkerPoolAddrs, X ; Write thinker slot address to free list at $7E3000,X
    INX 
    INX 
    CLC 
    ADC #$0010
    CPX #$0020            ; 16 thinker slots total ($0020 / 2 entries)
    BMI loc_03CE45
    LDA #$FFFF            ; $FFFF sentinel marks end of thinker free list
    STA $thinkerPoolAddrs, X
    LDA $sceneCurrent     ; Check for scene $FF simplified thinker clear
    CMP #$00FF
    BEQ loc_03CE7B
    LDX #$0000
    TXA 

  loc_03CE67:
    STA $0F00, X          ; Zero thinker data: $0F00, $7F0E00, and $7F3000 regions
    STA $7F0E00, X
    STA $7F3000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE67
    PLP 
    RTL 

  loc_03CE7B:
    LDX #$0000            ; Scene $FF simplified thinker clear: skip $7F3000 region
    TXA 

  loc_03CE7F:
    STA $0F00, X
    STA $7F0E00, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE7F
    PLP 
    RTL 
}

---------------------------------------------
; Allocate one thinker slot from the free list pool.
; 
; Reads the next free slot address via indirect long load [$52]. If the value is negative ($FFFF sentinel), the pool is exhausted — returns with carry set (failure). Otherwise, zeroes the consumed entry to prevent double-allocation, advances the pool pointer ($52) by 2 bytes, transfers the allocated slot address to Y, and returns with carry clear (success).
; 
; Called by SpawnThinker and SpawnThinkerParam COP handlers.

ThinkerPoolAlloc {
    LDA [$52]             ; === Allocate one thinker slot from free pool ===
    BMI loc_03CE9F        ; Read next free slot address via indirect long [$52]
    TAY                   ; Negative ($FFFF sentinel) → pool exhausted
    LDA #$0000            ; Transfer allocated slot address to Y for caller
    STA [$52]             ; Zero consumed entry to prevent double-allocation
    INC $52               ; Advance pool pointer by 2 to next free entry
    INC $52
    CLC                   ; CLC = allocation success
    RTL 

  loc_03CE9F:
    SEC                   ; SEC = pool exhausted, no slot available
    RTL 
}

---------------------------------------------
; Spawn all actors defined in the current scene's actor definition table.
; 
; Clears the actor linked list head ($56) and tail ($58). Reads the scene_actors table using the current scene index ($0646) to find the scene's actor definition data.
; 
; For each actor entry in the table (terminated by $FF byte):
; 1. Allocates a slot via cop_handlers_actors.ActorPoolAllocator
; 2. Links the new slot into a doubly-linked list ($04=prev, $06=next)
; 3. Calls InitActorFromSceneData to parse the binary actor record
; 4. If InitActorFromSceneData returns carry set (enemy was already defeated), the loop continues but the slot was freed internally
; 
; After all actors are spawned, sets playerActorDp ($09F4) to $1000 (first actor slot).

SpawnSceneActors {
    PHP                   ; === Spawn all actors from current scene's definition table ===
    REP #$20
    STZ $0056             ; Zero first actor pointer ($56) and last actor pointer ($58)
    STZ $0058
    LDA #$*scene_actors   ; Load bank byte of scene_actors table
    STA $40
    LDX $0646             ; Store to $40 for long pointer construction with $3E
    LDA $@scene_actors, X ; Load scene index from $0646 for table lookup
    STA $3E               ; Read scene-specific actor list pointer from long table
    BEQ loc_03CEEC        ; Null pointer = no actors defined for this scene
    LDA [$3E]             ; Read first byte of actor data (type byte)
    AND #$00FF
    CMP #$00FF            ; $FF = end-of-actor-list marker
    BEQ loc_03CEEC
    JSL $@cop_handlers_actors.ActorPoolAllocator ; Allocate first actor slot via ActorPoolAllocator
    STY $0056             ; Store as linked list head ($56 = first actor)
    BRA loc_03CEE3

  loc_03CECD:
    LDA [$3E]             ; Actor list loop: read next actor type byte
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEE9        ; $FF = end of list → store tail pointer
    JSL $@cop_handlers_actors.ActorPoolAllocator ; Allocate next actor slot
    TYA 
    STA $0006, X          ; Link new actor's $06 (next) to previous actor
    TXA 
    STA $0004, Y          ; Link previous actor's $04 (prev) to new allocation

  loc_03CEE3:
    TYX 
    JSR $&InitActorFromSceneData ; Parse binary record into allocated actor slot
    BCC loc_03CECD        ; Carry clear = success; carry set = enemy defeated, slot freed internally

  loc_03CEE9:
    STX $0058

  loc_03CEEC:
    LDA #$1000            ; Set playerActorDp ($09F4) to $1000 — first actor slot base
    STA $playerActorDp
    PLP 
    RTL 
}

AdvanceSceneDataAndFree {
    TYA 
    INC 
    CLC 
    ADC $3E
    STA $3E
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BNE InitActorFromSceneData
    DEC $4E
    DEC $4E
    TXA 
    STA [$4E]
    DEC $activeActorCount
    LDY $0004, X
    LDA #$0000
    STA $0006, Y
    TYX 
    SEC 
    RTS 
}

---------------------------------------------
; Parse a variable-length binary actor record from the scene data stream.
; 
; Reads sequentially from [$3E] with Y as the stream offset:
; - Bytes 0-1: X/Y tile coordinates → ×16 (ASL ×4) → pixel positions at $0014,X and $0016,X
; - Byte 2: Type/flags byte. Bit 0 selects sprite addressing: 0=high-byte swap mode (mask $F6, XBA, ORA $06F0), 1=direct mode (mask $FF, LSR). Stored to $000E,X
; - Bytes 3-4: Code pointer → $42 (work area)
; - Byte 5: Bank byte → $44
; - Byte 6: Stats table index → $7F0020,X. Zero = no stats (skip enemy init)
; - Byte 7: Enemy number → $7F0022,X. Used for defeat flag check
; - Byte 8: Death action index → $7F0024,X
; 
; If enemy number is nonzero, calls CheckEnemyDefeatedFlag. If already defeated (carry set), jumps to AdvanceSceneDataAndFree to skip this actor and free the pool slot.
; 
; For live enemies, sets bit 8 ($0100) in extended flags ($7F002A,X) and increments both binary ($0AEC) and BCD ($0AEE via SED) enemy counters.
; 
; Then parses the code header at [$42]: byte 0 = animation state ($0028,X), bytes 1-2 = initial flags (ORed with $4000 for visibility → $0010,X), computed entry point → $0000,X/$0002,X.
; 
; Player path (bit 15 of $10 set): Clears playerFlags $0088, parses direction sprite for initial facing, loads character form body table for spriteset, computes initial camera position with centering offsets (X-8, Y-$80 for camera, Y-$10 for playerYPos), and initializes scroll registers.
; 
; Normal path: Sets default spriteset ($4000 bank $7E), calls UpdateActorAnimation, adds 8px X offset, then resolves stats table if present (index × 4 + base → statsPtr, first byte → currentHp).

InitActorFromSceneData {
    LDY #$0000            ; === Parse binary actor record from scene data stream ===
    LDA [$3E], Y          ; Read actor X tile coordinate (byte 0 of record)
    INY 
    AND #$00FF
    ASL                   ; ×16 (ASL ×4): convert tile position to pixel X coordinate
    ASL 
    ASL 
    ASL 
    STA $0014, X          ; Store pixel X to actor position field $0014,X
    LDA [$3E], Y          ; Read actor Y tile coordinate (byte 1)
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0016, X          ; Store pixel Y to $0016,X
    LDA [$3E], Y          ; Read type/flags byte (byte 2)
    INY 
    BIT #$0001            ; Bit 0 selects sprite addressing mode: 0=swap, 1=direct
    BNE loc_03CF4C
    AND #$00F6            ; Swap mode: mask $F6, XBA to swap hi/lo bytes, OR with base sprite $06F0
    XBA 
    ORA $06F0
    STA $000E, X          ; Store composed sprite/flags value to actor field $000E,X
    BRA loc_03CF53

  loc_03CF4C:
    AND #$00FF            ; Direct mode: mask $FF, shift right, store to $000E,X
    LSR 
    STA $000E, X

  loc_03CF53:
    LDA [$3E], Y          ; Read actor code pointer (bytes 3-4, 16-bit word)
    INY 
    INY 
    STA $42               ; Store code pointer to work area $42
    LDA [$3E], Y          ; Read bank byte (byte 5)
    INY 
    AND #$00FF
    STA $44               ; Store bank to work area $44
    LDA [$3E], Y          ; Read stats table index (byte 6); zero = no combat stats
    INY 
    AND #$00FF
    STA $statsPtr, X      ; Store stats index to $7F0020,X (statsPtr extended field)
    BEQ loc_03CFA5        ; Zero stats → skip all enemy-specific initialization
    LDA [$3E], Y          ; Read enemy number (byte 7) for defeat flag tracking
    INY 
    AND #$00FF
    STA $enemyNum, X      ; Store enemy number to $7F0022,X (enemyNum extended field)
    BEQ loc_03CF81        ; Enemy number zero → skip defeat check (non-enemy actor with stats)
    JSR $&CheckEnemyDefeatedFlag ; Check WRAM defeat flags — has this enemy already been killed?
    BCC loc_03CF81
    JMP $&AdvanceSceneDataAndFree ; Already defeated → free slot and advance scene data stream

  loc_03CF81:
    LDA $extendedFlags, X ; Set bit 8 ($0100) in extendedFlags — marks as stat-bearing enemy
    ORA #$0100
    STA $extendedFlags, X
    LDA [$3E], Y          ; Read death action index (byte 8)
    INY 
    AND #$00FF
    STA $deathActionIdx, X ; Store to $7F0024,X (deathActionIdx extended field)
    INC $0AEC             ; Increment live enemy count ($0AEC binary counter)
    SED                   ; SED: switch to BCD arithmetic for display-ready counter
    LDA $0AEE             ; Load BCD enemy total from $0AEE
    CLC 
    ADC #$0001            ; Add 1 in BCD mode for accurate decimal display
    STA $0AEE
    CLD                   ; CLD: return to binary arithmetic

  loc_03CFA5:
    TYA                   ; Advance scene data pointer past consumed record bytes
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000            ; Begin parsing actor code header (pointed to by $42:$44)
    LDA [$42], Y          ; Read initial animation state / sprite index (byte 0)
    INY 
    AND #$00FF
    STA $0028, X          ; Store to actor animation field $0028,X
    LDA [$42], Y          ; Read initial flags word (bytes 1-2 of code header)
    INY 
    INY 
    ORA #$4000            ; OR with $4000 — actor starts with visibility flag set
    STA $0010, X          ; Store to primary flags field $0010,X
    TYA                   ; Compute code entry point: code header base + header size offset
    CLC 
    ADC $42
    STA $0000, X          ; Store entry point address to actor field $0000,X
    LDA $44
    STA $0002, X          ; Store bank byte from $44 to actor field $0002,X
    PHD                   ; Save outer direct page for restore after nested TCD
    TXA 
    TCD 
    LDA $10               ; Set DP to actor slot base for field-relative access (DP $10, $14, etc.)
    BMI loc_03D00F        ; Bit 15 of $10 = player actor flag
    LDA #$4000            ; === Normal actor init: set spriteset, animation, and stats ===
    STA $spritesetPtr, X  ; Default spriteset pointer = $4000
    LDA #$007E
    STA $7F0008, X        ; Spriteset bank byte = $7E (WRAM mirror for sprite tiles)
    JSL $@sprite_composition.UpdateActorAnimation ; Initialize actor animation via sprite_composition.UpdateActorAnimation
    LDA $14               ; Add 8px centering offset to X position
    CLC 
    ADC #$0008
    STA $14
    STZ $08               ; Zero the frame delay counter ($08) for immediate execution
    PLD                   ; Restore original direct page
    LDA $statsPtr, X      ; Check if actor has stats (statsPtr nonzero)
    BNE loc_03CFF8
    RTS                   ; No stats → return immediately (non-enemy actor successfully initialized)

  loc_03CFF8:
    ASL                   ; Compute stats table address: index × 4 + stats_01ABF0 base
    ASL 
    CLC 
    ADC #$&stats_01ABF0
    STA $statsPtr, X      ; Store computed address to statsPtr ($7F0020,X)
    TAY 
    LDA $0000, Y          ; Read base HP value (byte 0 of stats entry)
    AND #$00FF
    STA $currentHp, X     ; Store to currentHp ($7F0026,X)
    CLC 
    RTS                   ; CLC = actor initialized successfully

  loc_03D00F:
    LDA #$0088            ; === Player actor init: form-specific spriteset, camera, position ===
    TRB $playerFlags      ; Clear bits 7|3 ($0088) from playerFlags — unflag freeze + dead
    LDA $0E               ; Read type field $0E for special player state flags
    BIT #$0600            ; Bits 9|10 ($0600) = scene-defined player state overrides
    BEQ loc_03D03B
    PHA                   ; Save original type field to stack for individual bit testing
    AND #$F9FF
    STA $0E
    LDA $01, S
    BIT #$0200            ; Bit 9 ($0200) = set input lock on spawn
    BEQ loc_03D02F
    LDA #$0008            ; Set input lock bit 3 ($0008) in playerFlags
    TSB $playerFlags

  loc_03D02F:
    PLA                   ; PLA — recover original type field for next test
    BIT #$0400            ; Bit 10 ($0400) = set freeze state on spawn
    BEQ loc_03D03B
    LDA #$0080
    TSB $playerFlags      ; Set freeze bit 7 ($0080) in playerFlags

  loc_03D03B:
    LDA $0650             ; Look up initial facing direction from $0650 scene data
    AND #$00FF
    ASL 
    TAY                   ; Index direction sprite table for initial body pose
    LDA $&dir_sprite_01ABDE, Y
    AND #$00FF
    STA $28
    LDA $characterForm    ; Load characterForm (0=Will, 1=Freedan, 2=Shadow) for body table
    ASL                   ; Compute body table index: form × 6 (ASL ×2 + ADC form ×2)
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC $characterForm
    TAY 
    LDA $&body_table, Y   ; Read spriteset pointer from character form body table
    STA $spritesetPtr, X  ; Store spriteset pointer for sprite composition system
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA $064C             ; Check for spawn position override at $064C/$064E
    ORA $064E
    BEQ loc_03D092        ; No override → use standard tile-based position
    LDA $064C             ; Apply position override with centering offsets (+8 X, +16 Y)
    CLC 
    ADC #$0008
    STA $14
    LDA $064E
    CLC 
    ADC #$0010
    STA $16
    STZ $064C             ; Clear override values after consumption to prevent re-use
    STZ $064E
    JSL $@sprite_composition.UpdateActorAnimation ; Update actor animation with overridden position
    STZ $08
    BRA loc_03D09A

  loc_03D092:
    LDA $14               ; Standard position: add 8px X centering offset
    CLC 
    ADC #$0008
    STA $14

  loc_03D09A:
    LDA $14               ; Store final X to playerXPos ($09A2)
    STA $playerXPos
    LSR                   ; Convert pixel X to tile X (÷16 via LSR ×4)
    LSR 
    LSR 
    LSR 
    STA $playerXTile      ; Store to playerXTile ($09A6)
    LDA $14               ; Reload X for camera target: playerX − $80 (half screen width)
    SEC 
    SBC #$0080
    BPL loc_03D0B1        ; Clamp to 0 minimum — camera cannot scroll past left edge
    LDA #$0000

  loc_03D0B1:
    STA $cameraTargetX    ; Set both cameraTargetX and bg1ScrollH to initial position
    STA $bg1ScrollH
    LDA $16               ; Process Y axis: subtract $10 (16px) from raw Y for player hotspot
    SEC 
    SBC #$0010
    STA $playerYPos       ; Store to playerYPos ($09A4)
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile      ; Store to playerYTile ($09A8)
    LDA $16               ; Compute camera Y: playerY − $80 (half screen height)
    SEC 
    SBC #$0080
    BPL loc_03D0D2        ; Clamp to 0 minimum
    LDA #$0000

  loc_03D0D2:
    STA $cameraTargetY    ; Set both cameraTargetY and bg2ScrollH to initial Y position
    STA $bg2ScrollH
    PLD 
    CLC                   ; CLC = player actor initialized successfully
    RTS 
}

---------------------------------------------
; Check if an enemy has been permanently defeated via WRAM flag bit.
; 
; Converts enemy number A to a byte index (÷8 → Y) and bit position (AND #$07 → X). Looks up a bitmask from BitMaskTable_Wram ($01/$02/$04/$08/$10/$20/$40/$80) and ANDs it with the WRAM flag byte at $0A80,Y.
; 
; If the bit is set (enemy defeated): checks for an associated event block swap. Reads the event block index from the scene data at the saved Y offset. If nonzero, calls event_blocks.LookupEventBlock and event_blocks.SwapEventBlockTiles to update the tilemap for the defeated enemy's area (e.g., removing a barrier or revealing a passage). Returns carry set.
; 
; If the bit is clear (enemy alive): returns carry clear.

CheckEnemyDefeatedFlag {
    PHY                   ; === Check WRAM defeat flag for enemy number in A ===
    PHX 
    STA $0000             ; Save enemy number to $0000 work area for bit manipulation
    LSR                   ; ÷8 (LSR ×3) → byte index Y in the WRAM flag array
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20              ; Switch to 8-bit for flag byte operations
    LDA $0000             ; Reload enemy number in 8-bit for bit index extraction
    AND #$07              ; AND #$07: isolate bit position within byte (0-7)
    TAX 
    LDA $@BitMaskTable_Wram, X ; Look up bitmask from BitMaskTable_Wram ($01/$02/$04/$08/$10/$20/$40/$80)
    AND $wramFlags, Y     ; AND with WRAM flag byte at $0A80,Y — test if enemy's bit is set
    BNE loc_03D0FE        ; Nonzero = enemy already permanently defeated
    CLC                   ; Not defeated: CLC (carry clear = enemy is alive)
    REP #$20
    PLX 
    PLY 
    RTS 

  loc_03D0FE:
    REP #$20              ; Defeated path: check for associated event block tile swap
    LDA $03, S            ; Load saved Y offset from stack to read event block index from scene data
    TAY 
    LDA [$3E], Y
    AND #$00FF            ; Read event block index byte at offset Y in scene data stream
    BEQ loc_03D121        ; Zero event block index = no tile swap needed
    NOP 
    JSL $@event_blocks.LookupEventBlock ; Look up event block definition via event_blocks.LookupEventBlock
    BCS loc_03D121        ; Carry set = event block not found; skip swap
    LDY $3E               ; Save $3E/$40 around event block swap to preserve scene data pointer
    PHY 
    LDY $40
    PHY 
    JSL $@event_blocks.SwapEventBlockTiles ; Swap event block tiles for the defeated enemy's map area
    PLY 
    STY $40
    PLY 
    STY $3E

  loc_03D121:
    SEC                   ; SEC = enemy was defeated (carry set tells caller to skip spawning)
    PLX 
    PLY 
    RTS 
}

BitMaskTable_Wram [
  #01   ;00
  #02   ;01
  #04   ;02
  #08   ;03
  #10   ;04
  #20   ;05
  #40   ;06
  #80   ;07
]

---------------------------------------------
; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) CLEAR.
; 
; Processes general-purpose thinkers that should run during normal gameplay. Iterates the thinker linked list from $5A. For each thinker: checks the flag — if bit 2 is set, skips to next. Otherwise performs standard COP dispatch (frame timer check → script call → next link).
; 
; TypeA thinkers typically handle ambient effects, palette cycling, background animations, and other non-deferred tasks.

RunThinkers_TypeA {
    PHP                   ; === TypeA thinker execution: bit 2 CLEAR (general-purpose) ===
    PHD 
    REP #$20
    LDA $5A               ; Load thinker linked list head from $5A
    BEQ loc_03D15A        ; Empty thinker list → skip to exit

  loc_03D135:
    TCD 
    TAX 
    LDA $animScratch2, X  ; Read animScratch2 ($7F000E,X) — thinker type flag register
    BIT #$0004            ; Bit 2 ($0004) = thinker type B flag
    BNE RunThinkers_TypeA_Next ; Bit set → skip (TypeA only processes bit-2-clear thinkers)
    DEC $08               ; Decrement frame delay counter for COP dispatch
    BPL RunThinkers_TypeA_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeA_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeA_Next {
    LDA $06               ; Load next thinker link from DP $06; loop if nonzero
    BNE loc_03D135

  loc_03D15A:
    PLD                   ; All thinkers processed — restore state and exit
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) SET.
; 
; Processes deferred/secondary thinkers. Complementary to TypeA — only runs thinkers that TypeA skips. The bit 2 flag acts as a phase selector: TypeA runs first (bit clear), then TypeB runs afterward (bit set), allowing ordered execution of thinker groups within a single frame.

RunThinkers_TypeB {
    PHP                   ; === TypeB thinker execution: bit 2 SET (deferred/secondary) ===
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D18A

  loc_03D165:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004            ; Bit 2 ($0004) = thinker type B flag
    BEQ RunThinkers_TypeB_Next ; Bit clear → skip (TypeB only processes bit-2-set thinkers)
    DEC $08
    BPL RunThinkers_TypeB_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeB_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeB_Next {
    LDA $06
    BNE loc_03D165

  loc_03D18A:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 bit 11 ($0800) SET and bit 2 ($0004) CLEAR.
; 
; Processes cutscene/overlay thinkers that are in the primary (non-deferred) phase. Requires bit 11 to be set (cutscene-active) and bit 2 to be clear (not deferred). Used during cutscene playback to run overlay effects like palette transitions or HDMA animations.

RunThinkers_TypeC {
    PHP                   ; === TypeC thinker execution: bit 11 SET and bit 2 CLEAR ===
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1BF

  loc_03D195:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800            ; Bit 11 ($0800) = cutscene/overlay thinker flag
    BEQ RunThinkers_TypeC_Next ; Bit 11 clear → skip (TypeC requires bit 11)
    BIT #$0004            ; Check bit 2 ($0004) — must be clear for TypeC
    BNE RunThinkers_TypeC_Next ; Bit 2 set → skip (TypeC excludes type-B thinkers)
    DEC $08
    BPL RunThinkers_TypeC_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeC_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeC_Next {
    LDA $06
    BNE loc_03D195

  loc_03D1BF:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with BOTH animScratch2 bits 11 ($0800) AND 2 ($0004) SET.
; 
; Processes cutscene thinkers in the deferred phase. Uses AND #$0804 / CMP #$0804 to verify both bits are set simultaneously. Complementary to TypeC — runs after TypeC to handle deferred cutscene effects.

RunThinkers_TypeD {
    PHP                   ; === TypeD thinker execution: bits 11 AND 2 both SET ===
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1F2

  loc_03D1CA:
    TCD 
    TAX 
    LDA $animScratch2, X
    AND #$0804            ; AND #$0804: isolate both type flags simultaneously
    CMP #$0804            ; CMP #$0804: verify both bits are set (AND result must equal mask)
    BNE RunThinkers_TypeD_Next ; Not both set → skip this thinker
    DEC $08
    BPL RunThinkers_TypeD_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeD_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeD_Next {
    LDA $06
    BNE loc_03D1CA

  loc_03D1F2:
    PLD 
    PLP 
    RTL 
}