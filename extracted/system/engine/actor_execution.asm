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
?INCLUDE 'palette_bundles'
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
    PHP 
    PHD 
    REP #$20
    LDA $playerFlags
    BIT #$0008
    BEQ loc_03CB07
    LDA #$8000
    TRB $joypadCurrent

  loc_03CB07:
    BIT #$0010
    BEQ loc_03CB0F
    JMP $&RunActors_PauseFiltered

  loc_03CB0F:
    LDA $displayModeFlags
    BIT #$0080
    BEQ loc_03CB1A
    JMP $&RunActors_DisplayFiltered

  loc_03CB1A:
    LDA $56
    BEQ loc_03CB90

  loc_03CB1E:
    TCD 
    TAX 
    LDA $10
    BIT #$2000
    BEQ loc_03CB3D
    DEC $08
    BPL RunActors_CopScriptPostTick
    STZ $08
    PHK 
    PEA $&RunActors_CopScriptPostTick-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CB3D:
    BIT #$0080
    BEQ loc_03CB62
    LDA $iframeCounter, X
    BEQ loc_03CB5D
    BMI loc_03CB56
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CB62
    BRA loc_03CB8C

  loc_03CB56:
    INC 
    STA $iframeCounter, X
    BNE loc_03CB62

  loc_03CB5D:
    LDA #$0080
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
    AND #$FFFB
    STA $10
    BIT #$0008
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
    BIT #$0008
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
    BIT #$1000
    BNE loc_03CBBC
    LDA $12
    BIT #$1000
    BEQ loc_03CC26
    LDA $10

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
    BIT #$1004
    BNE loc_03CC54
    LDA $10
    BIT #$1400
    BEQ loc_03CCCD

  loc_03CC54:
    BIT #$2000
    BEQ loc_03CC72
    DEC $08
    BMI loc_03CC60
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
    BIT #$0080
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
    LDA #$0080
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
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0800
    BEQ loc_03CD57
    LDA $10
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
    BIT #$0080
    BEQ loc_03CD7D
    JMP $&RunActors_DisplayFiltered

  loc_03CD7D:
    LDA $56
    BEQ loc_03CDC9

  loc_03CD81:
    TCD 
    TAX 
    LDA $12
    BIT #$1000
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
    JSR $&tile_collision_physics.ApplyMovement

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
    LDX #$0E00
    STX $4E
    LDA #$0000
    STA $50
    LDA #$1000
    LDX #$0000

  loc_03CDEF:
    STA $0E00, X
    INX 
    INX 
    CLC 
    ADC #$0030
    CPX #$00A8
    BMI loc_03CDEF
    LDA #$FFFF
    STA $0E00, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CE23
    LDX #$0000
    TXA 

  loc_03CE0F:
    STA $1000, X
    STA $onHitCallback, X
    STA $7F2000, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE0F
    BRA loc_03CE35

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
    LDX #$3000
    STX $52
    LDA #$007E
    STA $54
    LDA #$0F00
    LDX #$0000

  loc_03CE45:
    STA $thinkerPoolAddrs, X
    INX 
    INX 
    CLC 
    ADC #$0010
    CPX #$0020
    BMI loc_03CE45
    LDA #$FFFF
    STA $thinkerPoolAddrs, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CE7B
    LDX #$0000
    TXA 

  loc_03CE67:
    STA $0F00, X
    STA $7F0E00, X
    STA $7F3000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE67
    PLP 
    RTL 

  loc_03CE7B:
    LDX #$0000
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
    LDA [$52]
    BMI loc_03CE9F
    TAY 
    LDA #$0000
    STA [$52]
    INC $52
    INC $52
    CLC 
    RTL 

  loc_03CE9F:
    SEC 
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
    STZ $0056
    STZ $0058
    LDA #$*scene_actors
    STA $40
    LDX $0646
    LDA $@scene_actors, X
    STA $3E
    BEQ loc_03CEEC
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEEC
    JSL $@cop_handlers_actors.ActorPoolAllocator
    STY $0056
    BRA loc_03CEE3

  loc_03CECD:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEE9
    JSL $@cop_handlers_actors.ActorPoolAllocator
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03CEE3:
    TYX 
    JSR $&InitActorFromSceneData
    BCC loc_03CECD

  loc_03CEE9:
    STX $0058

  loc_03CEEC:
    LDA #$1000
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
    AND #$FF
    BRK #$C9
    SBC $@palette_bundles.palette_bundle_16CFCF+31, X
    DEC $4E
    DEC $4E
    TXA 
    STA [$4E]
    DEC $activeActorCount
    LDY $0004, X
    LDA #$00
    BRK #$99
    ASL $00
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
    LDY #$0000
    LDA [$3E], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0014, X
    LDA [$3E], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0016, X
    LDA [$3E], Y
    INY 
    BIT #$0001
    BNE loc_03CF4C
    AND #$00F6
    XBA 
    ORA $06F0
    STA $000E, X
    BRA loc_03CF53

  loc_03CF4C:
    AND #$00FF
    LSR 
    STA $000E, X

  loc_03CF53:
    LDA [$3E], Y
    INY 
    INY 
    STA $42
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $44
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $statsPtr, X
    BEQ loc_03CFA5
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $enemyNum, X
    BEQ loc_03CF81
    JSR $&CheckEnemyDefeatedFlag
    BCC loc_03CF81
    JMP $&AdvanceSceneDataAndFree

  loc_03CF81:
    LDA $extendedFlags, X
    ORA #$0100
    STA $extendedFlags, X
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $deathActionIdx, X
    INC $0AEC
    SED 
    LDA $0AEE
    CLC 
    ADC #$0001
    STA $0AEE
    CLD 

  loc_03CFA5:
    TYA 
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000
    LDA [$42], Y
    INY 
    AND #$00FF
    STA $0028, X
    LDA [$42], Y
    INY 
    INY 
    ORA #$4000
    STA $0010, X
    TYA 
    CLC 
    ADC $42
    STA $0000, X
    LDA $44
    STA $0002, X
    PHD 
    TXA 
    TCD 
    LDA $10
    BMI loc_03D00F
    LDA #$4000
    STA $spritesetPtr, X
    LDA #$007E
    STA $7F0008, X
    JSL $@sprite_composition.UpdateActorAnimation
    LDA $14
    CLC 
    ADC #$0008
    STA $14
    STZ $08
    PLD 
    LDA $statsPtr, X
    BNE loc_03CFF8
    RTS 

  loc_03CFF8:
    ASL 
    ASL 
    CLC 
    ADC #$&stats_01ABF0
    STA $statsPtr, X
    TAY 
    LDA $0000, Y
    AND #$00FF
    STA $currentHp, X
    CLC 
    RTS 

  loc_03D00F:
    LDA #$0088
    TRB $playerFlags
    LDA $0E
    BIT #$0600
    BEQ loc_03D03B
    PHA 
    AND #$F9FF
    STA $0E
    LDA $01, S
    BIT #$0200
    BEQ loc_03D02F
    LDA #$0008
    TSB $playerFlags

  loc_03D02F:
    PLA 
    BIT #$0400
    BEQ loc_03D03B
    LDA #$0080
    TSB $playerFlags

  loc_03D03B:
    LDA $0650
    AND #$00FF
    ASL 
    TAY 
    LDA $&dir_sprite_01ABDE, Y
    AND #$00FF
    STA $28
    LDA $characterForm
    ASL 
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC $characterForm
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA $064C
    ORA $064E
    BEQ loc_03D092
    LDA $064C
    CLC 
    ADC #$0008
    STA $14
    LDA $064E
    CLC 
    ADC #$0010
    STA $16
    STZ $064C
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
    LDA $14
    STA $playerXPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $14
    SEC 
    SBC #$0080
    BPL loc_03D0B1
    LDA #$0000

  loc_03D0B1:
    STA $cameraTargetX
    STA $bg1ScrollH
    LDA $16
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $16
    SEC 
    SBC #$0080
    BPL loc_03D0D2
    LDA #$0000

  loc_03D0D2:
    STA $cameraTargetY
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
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@BitMaskTable_Wram, X
    AND $wramFlags, Y
    BNE loc_03D0FE
    CLC 
    REP #$20
    PLX 
    PLY 
    RTS 

  loc_03D0FE:
    REP #$20
    LDA $03, S
    TAY 
    LDA [$3E], Y
    AND #$00FF
    BEQ loc_03D121
    NOP 
    JSL $@event_blocks.LookupEventBlock
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
    SEC 
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
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D15A

  loc_03D135:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BNE RunThinkers_TypeA_Next
    DEC $08
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
    LDA $06
    BNE loc_03D135

  loc_03D15A:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) SET.
; 
; Processes deferred/secondary thinkers. Complementary to TypeA — only runs thinkers that TypeA skips. The bit 2 flag acts as a phase selector: TypeA runs first (bit clear), then TypeB runs afterward (bit set), allowing ordered execution of thinker groups within a single frame.

RunThinkers_TypeB {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D18A

  loc_03D165:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BEQ RunThinkers_TypeB_Next
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
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1BF

  loc_03D195:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800
    BEQ RunThinkers_TypeC_Next
    BIT #$0004
    BNE RunThinkers_TypeC_Next
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
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1F2

  loc_03D1CA:
    TCD 
    TAX 
    LDA $animScratch2, X
    AND #$0804
    CMP #$0804
    BNE RunThinkers_TypeD_Next
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