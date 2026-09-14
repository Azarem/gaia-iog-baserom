; Actor execution loop system (248565–250157, Bank 03).
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
; === ACTOR/THINKER POOL (InitActorPool, 249308) ===
; 
; Initializes both pools. Actor pool: base $0E00, 84 slots of $30 bytes, free list at $4E/$50. Data regions: $1000–$1FBF (primary), $7F1000 (callbacks), $7F2000 (extended). Thinker pool: base $7E3000, 16 slots of $10 bytes, free list at $52/$54. Data at $0F00, $7F0E00, $7F3000. Scene $FF uses simplified clear (skips $7F2000/$7F3000).
; 
; ThinkerPoolAlloc reads the next free thinker slot via indirect long [$52], returns it in Y with carry clear, or returns carry set if the pool is exhausted. Called by SpawnSceneThinkers (thinker_execution) and COP handlers (SpawnThinker/SpawnThinkerParam).
; 
; === SCENE SPAWNING (SpawnSceneActors, 249505) ===
; 
; Reads scene_actors table to spawn actors. Each actor: allocate slot via ActorPoolAllocator, link into doubly-linked list ($04/$06), call InitActorFromSceneData to parse the binary record.
; 
; === DEFEATED ENEMY HANDLING (AdvanceSceneDataAndFree, 249588) ===
; 
; Called when CheckEnemyDefeatedFlag determines an actor was already killed. Advances the scene data pointer past the remaining record bytes, then either continues the spawn loop (if more actors follow) or returns the allocated slot to the free list, unlinks it from the actor chain, and decrements activeActorCount.
; 
; === ACTOR RECORD FORMAT (InitActorFromSceneData, 249627) ===
; 
; Variable-length record: byte 0-1 = X/Y tile (×16→pixels), byte 2 = type flags (bit 0 = addressing mode), bytes 3-4 = code pointer, byte 5 = bank, byte 6 = stats index, byte 7 = enemy number, byte 8 = death action. Player actors (bit 15 of $10) get special init: load character form body table, set spriteset, compute camera centering.
; 
; Enemies with nonzero enemyNum are checked against WRAM defeat flags (CheckEnemyDefeatedFlag). Already-defeated actors are freed via AdvanceSceneDataAndFree and their event block tiles are swapped.
---------------------------------------------

?BANK 03

?INCLUDE 'body_table'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'direction_velocity_table'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'event_blocks'
?INCLUDE 'scene_actors'
?INCLUDE 'sprite_composition'
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
    PHP 
    PHD 
    REP #$20
    LDA $playerFlags
    BIT #$0008            ; Bit 3 ($0008) = input lock; suppress B button ($8000) when set
    BEQ loc_03CB07
    LDA #$8000
    TRB $joypadCurrent

  loc_03CB07:
    BIT #$0010            ; Bit 4 ($0010) = game paused → PauseFiltered
    BEQ loc_03CB0F
    JMP $&RunActors_PauseFiltered

  loc_03CB0F:
    LDA $displayModeFlags
    BIT #$0080            ; Bit 7 ($0080) = display filter → DisplayFiltered
    BEQ loc_03CB1A
    JMP $&RunActors_DisplayFiltered

  loc_03CB1A:
    LDA $56
    BEQ loc_03CB90

  loc_03CB1E:
    TCD 
    TAX 
    LDA $10
    BIT #$2000            ; Bit 13 ($2000) = COP script mode active
    BEQ loc_03CB3D
    DEC $08
    BPL RunActors_CopScriptPostTick
    STZ $08
    PHK                   ; RTL dispatch: push return to CopScriptPostTick, then actor script at $02:$00
    PEA $&RunActors_CopScriptPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC                   ; DEC: RTL adds 1 to popped address
    PHA 
    RTL 

  loc_03CB3D:
    BIT #$0080            ; Iframe state ($0080): positive → count down, negative → count up toward zero
    BEQ loc_03CB62
    LDA $iframeCounter, X
    BEQ loc_03CB5D
    BMI loc_03CB56
    DEC 
    STA $iframeCounter, X
    CPX $playerActor      ; Player actor always gets full COP dispatch despite iframes
    BEQ loc_03CB62
    BRA loc_03CB8C

  loc_03CB56:
    INC                   ; Recovery: INC negative counter toward zero
    STA $iframeCounter, X
    BNE loc_03CB62

  loc_03CB5D:
    LDA #$0080            ; Counter reached zero — clear iframe flag
    TRB $10

  loc_03CB62:
    DEC $08
    BPL RunActors_PostTick
    STZ $08
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
    LDA $10
    AND #$FFFB            ; Clear bit 2 ($0004) — per-frame collision contact reset
    STA $10
    BIT #$0008            ; Bit 3 ($0008) = grounded: collision-aware vs simple movement
    BEQ loc_03CB89
    JSR $&tile_collision_physics.ApplyMovementWithCollision
    BRA loc_03CB8C

  loc_03CB89:
    JSR $&tile_collision_physics.ApplyMovement

  loc_03CB8C:
    LDA $06
    BNE loc_03CB1E

  loc_03CB90:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Post-tick handler for actors that just returned from COP script execution.
; 
; Checks if the actor is still in COP mode (bit 13 $2000). If cleared (script completed this frame), falls through to normal PostTick. If still in COP mode, checks secondary flags ($12) bit 3 ($0008) — this flag requests collision movement even during COP execution. If set, performs PostTick; if clear, skips directly to the next actor.

RunActors_CopScriptPostTick {
    LDA $10
    BIT #$2000
    BEQ RunActors_PostTick
    LDA $12
    BIT #$0008            ; Bit 3 of $12: COP movement request — collision movement during COP mode
    BEQ loc_03CB8C
    BRA RunActors_PostTick
}

---------------------------------------------
; Display-filtered actor execution — processes only display-active actors.
; 
; Active when displayModeFlags bit 7 ($0080) is set. Iterates the actor linked list but only processes actors where bit 12 ($1000) is set in either primary flags ($10) or secondary flags ($12). Actors without this flag are skipped entirely (no COP dispatch, no movement).
; 
; Otherwise identical lifecycle to RunActors_Normal: iframe management, COP script dispatch, collision/simple movement selection.

RunActors_DisplayFiltered {
    LDA $56
    BNE loc_03CBAA
    JMP $&RunActors_DisplayFiltered_Exit

  loc_03CBAA:
    TCD 
    TAX 
    LDA $10
    BIT #$1000            ; Bit 12 ($1000) in $10 = display-active actor
    BNE loc_03CBBC
    LDA $12
    BIT #$1000            ; Bit 12 ($1000) in $12 also qualifies
    BEQ loc_03CC26
    LDA $10               ; Reload $10 after display check (AND destroyed original)

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
    LDA $10
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
    PLD 
    PLP 
    RTL 
}

RunActors_DisplayFiltered_CopPostTick {
    LDA $10
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
    LDA $56
    BNE RunActors_PauseFiltered_Body
    JMP $&RunActors_PauseFiltered_Exit

  RunActors_PauseFiltered_Body:
    TCD 
    TAX 
    LDA $12
    BIT #$1004            ; $1004 in $12: secondary pause-immunity (bits 12|2)
    BNE loc_03CC54
    LDA $10
    BIT #$1400            ; $1400 in $10: primary pause-immunity (bits 12|10)
    BEQ loc_03CCCD        ; No immunity → iframe-only processing (no COP dispatch)

  loc_03CC54:
    BIT #$2000
    BEQ loc_03CC72
    DEC $08
    BMI loc_03CC60        ; Timer expired (negative) → dispatch COP script
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
    LDA $10
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
    LDA $06
    BEQ RunActors_PauseFiltered_Exit
    JMP $&RunActors_PauseFiltered_Body
}

RunActors_PauseFiltered_Exit {
    PLD 
    PLP 
    RTL 

  loc_03CCCD:
    BIT #$0080            ; Iframe-only tail for non-immune paused actors
    BEQ loc_03CCC3
    LDA $iframeCounter, X
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
    LDA $10
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
    PHP 
    PHD 
    REP #$20
    LDA $56
    BEQ loc_03CD5B

  loc_03CD07:
    TCD 
    TAX 
    LDA $10               ; Clear bit 2 ($0004) — collision flag cleared for all cutscene actors
    AND #$FFFB
    STA $10
    BIT #$0800            ; Bit 11 ($0800) = cutscene-active; skip actors without it
    BEQ loc_03CD57
    LDA $10               ; Reload $10 (AND destroyed bit 2 above)
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
    LDA $10
    BIT #$0008
    BEQ loc_03CD54
    JSR $&tile_collision_physics.ApplyMovementWithCollision
    BRA loc_03CD57

  loc_03CD54:
    JSR $&tile_collision_physics.ApplyMovement

  loc_03CD57:
    LDA $06
    BNE loc_03CD07

  loc_03CD5B:
    PLD 
    PLP 
    RTL 
}

RunActors_CutsceneOnly_CopPostTick {
    LDA $10
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
    PHP 
    PHD 
    REP #$20
    LDA $displayModeFlags
    BIT #$0080            ; Bit 7 ($0080): display filter takes precedence over overlay
    BEQ loc_03CD7D
    JMP $&RunActors_DisplayFiltered

  loc_03CD7D:
    LDA $56
    BEQ loc_03CDC9

  loc_03CD81:
    TCD 
    TAX 
    LDA $12
    BIT #$1000            ; Bit 12 ($1000) in $12 = overlay-active actor
    BEQ loc_03CDC5
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$2000
    BEQ loc_03CDAC
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
    JSR $&tile_collision_physics.ApplyMovement ; Overlay: always simple ApplyMovement (no collision)

  loc_03CDC5:
    LDA $06
    BNE loc_03CD81

  loc_03CDC9:
    PLD 
    PLP 
    RTL 
}

RunActors_OverlayOnly_CopPostTick {
    LDA $10
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
    PHP 
    REP #$20
    LDX #$0E00            ; Actor free list base at $0E00; head pointer → $4E, count → $50
    STX $4E
    LDA #$0000
    STA $50
    LDA #$1000            ; First actor slot at $1000; $30 bytes per slot
    LDX #$0000

  loc_03CDEF:
    STA $0E00, X          ; Build free list: ascending slot addresses ($30-byte stride)
    INX 
    INX 
    CLC 
    ADC #$0030
    CPX #$00A8            ; 84 actor slots ($00A8 / 2 entries)
    BMI loc_03CDEF
    LDA #$FFFF            ; $FFFF sentinel terminates free list
    STA $0E00, X
    LDA $sceneCurrent
    CMP #$00FF            ; Scene $FF: simplified clear — skip $7F2000 extended region
    BEQ loc_03CE23
    LDX #$0000
    TXA 

  loc_03CE0F:
    STA $1000, X          ; Zero three actor regions: $1000 primary, $7F1000 callbacks, $7F2000 extended
    STA $onHitCallback, X
    STA $7F2000, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE0F
    BRA loc_03CE35        ; Normal path: continue to thinker pool init

  loc_03CE23:
    LDX #$0000
    TXA 

  loc_03CE27:
    STA $1000, X
    STA $onHitCallback, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE27

  loc_03CE35:
    LDX #$3000            ; Thinker free list: long pointer $7E:3000 → $52/$54
    STX $52
    LDA #$007E
    STA $54
    LDA #$0F00            ; First thinker at $0F00; $10 bytes per slot, 16 slots
    LDX #$0000

  loc_03CE45:
    STA $thinkerPoolAddrs, X
    INX 
    INX 
    CLC 
    ADC #$0010
    CPX #$0020
    BMI loc_03CE45
    LDA #$FFFF            ; $FFFF sentinel terminates thinker free list
    STA $thinkerPoolAddrs, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CE7B
    LDX #$0000
    TXA 

  loc_03CE67:
    STA $0F00, X          ; Zero three thinker regions: $0F00, $7F0E00, $7F3000
    STA $7F0E00, X
    STA $7F3000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE67
    PLP 
    RTL 

  loc_03CE7B:
    LDX #$0000            ; Scene $FF: skip $7F3000 thinker region
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
    LDA [$52]             ; Read next free slot via indirect long [$52]
    BMI loc_03CE9F        ; $FFFF sentinel → pool exhausted, return carry set
    TAY                   ; Y = allocated slot address for caller
    LDA #$0000
    STA [$52]             ; Zero consumed entry to prevent double-allocation
    INC $52               ; Advance pool pointer by 2 to next entry
    INC $52
    CLC                   ; CLC = allocation success
    RTL 

  loc_03CE9F:
    SEC                   ; SEC = pool exhausted
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
    PHP 
    REP #$20
    STZ $0056             ; Clear actor list head ($56) and tail ($58)
    STZ $0058
    LDA #$*scene_actors   ; Build long pointer [$3E]: scene_actors bank → $40
    STA $40
    LDX $0646
    LDA $@scene_actors, X ; Scene-indexed actor list pointer → $3E
    STA $3E
    BEQ loc_03CEEC        ; Null pointer = no actors for this scene
    LDA [$3E]
    AND #$00FF
    CMP #$00FF            ; $FF = end-of-actor-list marker
    BEQ loc_03CEEC
    JSL $@cop_handlers_actors.ActorPoolAllocator ; Allocate first actor slot
    STY $0056             ; Store as linked list head ($56)
    BRA loc_03CEE3

  loc_03CECD:
    LDA [$3E]             ; Read next actor type byte
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEE9        ; $FF = end of list
    JSL $@cop_handlers_actors.ActorPoolAllocator
    TYA 
    STA $0006, X          ; Link: new.$06 = previous, previous.$04 = new
    TXA 
    STA $0004, Y

  loc_03CEE3:
    TYX 
    JSR $&InitActorFromSceneData ; Parse binary record into allocated slot
    BCC loc_03CECD        ; Carry clear = success; carry set = enemy defeated, slot freed

  loc_03CEE9:
    STX $0058

  loc_03CEEC:
    LDA #$1000            ; Set playerActorDp ($09F4) to $1000 — first actor slot
    STA $playerActorDp
    PLP 
    RTL 
}

---------------------------------------------
; Skip a defeated enemy during scene actor spawning and return its slot to the pool.
; 
; Called from InitActorFromSceneData when CheckEnemyDefeatedFlag returns carry set (enemy already permanently killed). Y holds the stream offset into the current actor record.
; 
; Two outcomes based on whether more actors remain:
; 
; 1. More actors follow (next byte ≠ $FF): Advances the scene data pointer $3E past the remaining record bytes (Y + 1 + $3E → $3E). Branches directly to InitActorFromSceneData to process the next actor record in the same spawn loop iteration.
; 
; 2. End of actor list (next byte = $FF): Returns the allocated slot to the actor free list by decrementing $4E twice (backing up the free list pointer by one word) and writing the slot address (TXA) via STA [$4E]. Decrements activeActorCount ($0DBC). Unlinks the slot from the actor chain by zeroing the previous actor's next pointer ($0006,Y = 0). Sets X to the previous actor (TYX) and returns with carry set to signal SpawnSceneActors that this actor was skipped.

AdvanceSceneDataAndFree {
    TYA                   ; Advance $3E past the defeated enemy's remaining record bytes
    INC 
    CLC 
    ADC $3E
    STA $3E
    LDA [$3E]             ; Read next byte from scene data stream
    AND #$00FF
    CMP #$00FF            ; Check for $FF end-of-actor-list marker
    BNE InitActorFromSceneData ; More actors follow → continue spawn loop at InitActorFromSceneData
    DEC $4E               ; End of list: back up free list pointer $4E by one word (2 bytes)
    DEC $4E
    TXA                   ; Return freed slot address to the free list
    STA [$4E]
    DEC $activeActorCount ; Decrement active actor count ($0DBC)
    LDY $0004, X          ; Read previous actor link from $0004,X (prev pointer)
    LDA #$0000            ; Zero the previous actor's next pointer ($0006,Y) — unlink freed slot
    STA $0006, Y
    TYX                   ; Set X to previous actor for caller (SpawnSceneActors loop)
    SEC                   ; SEC = signal defeated actor was skipped
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
    LDY #$0000
    LDA [$3E], Y          ; Byte 0: X tile coordinate (×16 → pixel X)
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0014, X
    LDA [$3E], Y          ; Byte 1: Y tile coordinate (×16 → pixel Y)
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0016, X
    LDA [$3E], Y          ; Byte 2: type/flags — bit 0 selects sprite addressing mode
    INY 
    BIT #$0001
    BNE loc_03CF4C
    AND #$00F6            ; Mode 0: mask $F6, XBA swap, OR base sprite $06F0
    XBA 
    ORA $06F0
    STA $000E, X
    BRA loc_03CF53

  loc_03CF4C:
    AND #$00FF            ; Mode 1: mask $FF, LSR
    LSR 
    STA $000E, X

  loc_03CF53:
    LDA [$3E], Y          ; Bytes 3-4: code pointer → $42
    INY 
    INY 
    STA $42
    LDA [$3E], Y          ; Byte 5: bank → $44
    INY 
    AND #$00FF
    STA $44
    LDA [$3E], Y          ; Byte 6: stats index; zero = no combat stats
    INY 
    AND #$00FF
    STA $statsPtr, X
    BEQ loc_03CFA5        ; Zero stats → skip enemy-specific init
    LDA [$3E], Y          ; Byte 7: enemy number for defeat tracking
    INY 
    AND #$00FF
    STA $enemyNum, X
    BEQ loc_03CF81        ; Enemy zero → skip defeat check
    JSR $&CheckEnemyDefeatedFlag ; Check WRAM defeat flags — already killed?
    BCC loc_03CF81
    JMP $&AdvanceSceneDataAndFree ; Defeated → free slot, advance scene data

  loc_03CF81:
    LDA $extendedFlags, X ; Set $0100 in extendedFlags — stat-bearing enemy
    ORA #$0100
    STA $extendedFlags, X
    LDA [$3E], Y          ; Byte 8: death action index
    INY 
    AND #$00FF
    STA $deathActionIdx, X
    INC $0AEC             ; Increment binary enemy count ($0AEC)
    SED                   ; BCD increment: SED, add 1 to $0AEE, CLD
    LDA $0AEE
    CLC 
    ADC #$0001
    STA $0AEE
    CLD 

  loc_03CFA5:
    TYA                   ; Advance scene data pointer past consumed record
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000
    LDA [$42], Y          ; Code header byte 0: initial animation state → $0028,X
    INY 
    AND #$00FF
    STA $0028, X
    LDA [$42], Y          ; Code header bytes 1-2: initial flags
    INY 
    INY 
    ORA #$4000            ; OR $4000: actor starts visible
    STA $0010, X
    TYA                   ; Code entry point = header base + header size
    CLC 
    ADC $42
    STA $0000, X
    LDA $44
    STA $0002, X
    PHD 
    TXA 
    TCD 
    LDA $10               ; Bit 15 of $10 = player actor → special init path
    BMI loc_03D00F
    LDA #$4000
    STA $spritesetPtr, X  ; Default spriteset $4000, bank $7E (WRAM sprite tiles)
    LDA #$007E
    STA $7F0008, X
    JSL $@sprite_composition.UpdateActorAnimation
    LDA $14               ; Add 8px X centering offset
    CLC 
    ADC #$0008
    STA $14
    STZ $08               ; Zero frame delay ($08) for immediate execution
    PLD 
    LDA $statsPtr, X      ; Stats nonzero → resolve stats table address
    BNE loc_03CFF8
    RTS 

  loc_03CFF8:
    ASL                   ; Stats address: index × 4 + stats_01ABF0 base → statsPtr
    ASL 
    CLC 
    ADC #$&enemy_stats_table
    STA $statsPtr, X
    TAY 
    LDA $0000, Y          ; First byte of stats entry → currentHp
    AND #$00FF
    STA $currentHp, X
    CLC 
    RTS 

  loc_03D00F:
    LDA #$0088
    TRB $playerFlags      ; Clear playerFlags $0088 (freeze | dead)
    LDA $0E
    BIT #$0600            ; Bits 9|10 ($0600) = scene-defined player state overrides
    BEQ loc_03D03B
    PHA 
    AND #$F9FF
    STA $0E
    LDA $01, S
    BIT #$0200            ; Bit 9 ($0200) → set input lock ($0008 in playerFlags)
    BEQ loc_03D02F
    LDA #$0008
    TSB $playerFlags

  loc_03D02F:
    PLA 
    BIT #$0400            ; Bit 10 ($0400) → set freeze ($0080 in playerFlags)
    BEQ loc_03D03B
    LDA #$0080
    TSB $playerFlags

  loc_03D03B:
    LDA $0650             ; Facing direction from $0650 → direction sprite table → $28
    AND #$00FF
    ASL 
    TAY 
    LDA $&direction_velocity_table, Y
    AND #$00FF
    STA $28
    LDA $characterForm    ; Body table index = characterForm × 6
    ASL 
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC $characterForm
    TAY 
    LDA $&body_table, Y   ; Spriteset pointer from body table → spritesetPtr
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA $064C             ; Check spawn position override ($064C/$064E)
    ORA $064E
    BEQ loc_03D092
    LDA $064C             ; Override: +8 X centering, +16 Y centering
    CLC 
    ADC #$0008
    STA $14
    LDA $064E
    CLC 
    ADC #$0010
    STA $16
    STZ $064C             ; Clear override values after use
    STZ $064E
    JSL $@sprite_composition.UpdateActorAnimation
    STZ $08
    BRA loc_03D09A

  loc_03D092:
    LDA $14
    CLC 
    ADC #$0008
    STA $14

  loc_03D09A:
    LDA $14               ; Final X → playerXPos; LSR ×4 → playerXTile
    STA $playerXPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $14               ; Camera X = playerX − $80 (half screen), clamped to 0
    SEC 
    SBC #$0080
    BPL loc_03D0B1
    LDA #$0000

  loc_03D0B1:
    STA $cameraTargetX    ; Initialize both cameraTargetX and bg1ScrollH
    STA $bg1ScrollH
    LDA $16               ; Pixel Y − $10 → playerYPos; LSR ×4 → playerYTile
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $16               ; Camera Y = playerY − $80 (half screen), clamped to 0
    SEC 
    SBC #$0080
    BPL loc_03D0D2
    LDA #$0000

  loc_03D0D2:
    STA $cameraTargetY    ; Initialize both cameraTargetY and bg2ScrollH
    STA $bg2ScrollH
    PLD 
    CLC 
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
    PHY 
    PHX 
    STA $0000             ; Store enemy number to $0000; LSR ×3 → byte index Y
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07              ; AND #$07 → bit position; look up mask from BitMaskTable_Wram
    TAX 
    LDA $@BitMaskTable_Wram, X
    AND $wramFlags, Y     ; AND wramFlags,Y — test if enemy's defeat bit is set
    BNE loc_03D0FE
    CLC 
    REP #$20
    PLX 
    PLY 
    RTS 

  loc_03D0FE:
    REP #$20              ; Defeated: check for associated event block tile swap
    LDA $03, S            ; Read event block index from scene data at saved Y offset
    TAY 
    LDA [$3E], Y
    AND #$00FF
    BEQ loc_03D121        ; Zero index = no tile swap
    NOP 
    JSL $@event_blocks.LookupEventBlock ; Look up event block; if found, swap tiles (save/restore $3E/$40)
    BCS loc_03D121
    LDY $3E
    PHY 
    LDY $40
    PHY 
    JSL $@event_blocks.SwapEventBlockTiles
    PLY 
    STY $40
    PLY 
    STY $3E

  loc_03D121:
    SEC                   ; SEC = defeated (caller skips spawning)
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