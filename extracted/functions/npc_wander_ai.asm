; Reusable town-NPC wander behaviour (Bank 00, 50968-51193) used by 13 ambient NPC actors in Dao (daC9_businessman, daC3_man1), Watermia (wa78 water_kid, moving_woman, glass_game, centipede_man), Angel Village (av6B villagers2, ocean_ache), Euro (eu91 women2, men2), Seaside Palace (sp5A_villagers) and South Cape (sc01_roof_man, sc04_poverty).
; 
; === CALLING PATTERN ===
; 
; The NPC's init stores its base animation index in currentHp,X ($7F0026) and calls SyncActorPosFromDP once. Its loop is: JSL NpcRandomWanderAI, SetEntryHereAndYield, SetEntryHere, AnimOnce, BRA loop. The routines here only choose and stage; the caller's AnimOnce plays the staged animation.
; 
; === DATA ===
; 
; $7F0010 / $7F0012 (mnemonics orbitAngle / orbitDiameter, there is no orbit here) hold the home X / Y that SyncActorPosFromDP copies from DP $14 / $16. $7F0026 (mnemonic currentHp) is the NPC's base animation index. The sprite sheet is laid out as base + 0 to 3 = stand south / north / west / east and base + 4 to 7 = walk south / north / west / east.
; 
; === DECISION ===
; 
; NpcRandomWanderAI rolls RngByte and 7 (each case has probability 1/8) and runs COP SwitchCase on the byte at $0000. The table is: 0 = stand north, 1 = stand south, 2 = stand west, 3 = stand east, 4 = step north, 5 = step south, 6 = step west, 7 = step east.
; Standing: $28 := base + direction, $2A := 0, UpdateActorAnimation, $08 := $78 (the script sleeps 121 ticks after the caller's SetEntryHereAndYield: $78 skipped passes, then it runs on the next one) and MarkSolidHere (a standing NPC blocks the player).
; Stepping: if the NPC is already more than $30 pixels (3 tiles) from its home in that direction, or the BranchIfSolid test for that side finds a solid tile, it stands facing that direction instead. Otherwise it stages a movement delta chain (StageMoveX / StageMoveY #$11 = +1 pixel every second frame, east or south; #$12 = -1 every second frame, west or north), sets the walk animation (base + 4 to 7), and does ClearSolidHere (a walking NPC is not solid).
; The step lasts for one pass of the walk animation: the caller's AnimOnce moves the NPC at half a pixel per frame until the animation list ends, then clears the chain ($2C / $2E) and the loop rolls again. The step length is therefore half the number of frames of the walk animation, in pixels, and there is no re-roll in the middle of a step.
---------------------------------------------

?INCLUDE 'sprite_composition'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!currentHp                      7F0026

---------------------------------------------

; Copies the actor's pixel position (DP $14 / $16) to the home words $7F0010 / $7F0012. Called once by each NPC's init; the wander never moves more than $30 pixels from this point.

SyncActorPosFromDP {
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    RTL 
}

---------------------------------------------
; One decision of the wander: stores RngByte and 7 in $0000 and dispatches through SwitchCase to npc_wander_case_table. Every case ends in RTL, back to the NPC's loop.

NpcRandomWanderAI {
    COP [RngByte]         ; A := 0 to 255; AND #7 below gives the case, 1/8 each
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &npc_wander_case_table ) ; Case index at $0000 selects an entry of npc_wander_case_table; its RTL returns to the NPC's JSL
}

---------------------------------------------
; SwitchCase table: 0 stand north, 1 stand south, 2 stand west, 3 stand east, 4 step north, 5 step south, 6 step west, 7 step east.

npc_wander_case_table [
  &NpcWanderStandNorth   ;00
  &NpcWanderStandSouth   ;01
  &NpcWanderStandWest   ;02
  &NpcWanderStandEast   ;03
  &NpcWanderStepNorth   ;04
  &NpcWanderStepSouth   ;05
  &NpcWanderStepWest   ;06
  &NpcWanderStepEast   ;07
]

---------------------------------------------
; Stand facing south: animation base + 0. Also the fallback of a blocked or out-of-range step south.

NpcWanderStandSouth {
    LDA $currentHp, X
    CLC 
    ADC #$0000
    BRA NpcWanderStageStand
}

---------------------------------------------
; Stand facing north: animation base + 1. Also the fallback of a step north.

NpcWanderStandNorth {
    LDA $currentHp, X
    CLC 
    ADC #$0001
    BRA NpcWanderStageStand
}

---------------------------------------------
; Stand facing west: animation base + 2. Also the fallback of a step west.

NpcWanderStandWest {
    LDA $currentHp, X
    CLC 
    ADC #$0002
    BRA NpcWanderStageStand
}

---------------------------------------------
; Stand facing east: animation base + 3. Also the fallback of a step east.

NpcWanderStandEast {
    LDA $currentHp, X
    CLC 
    ADC #$0003
    BRA NpcWanderStageStand

; Stand path (shared): stage animation A, wait 121 ticks ($08 = $78: 120 skipped passes) and mark the NPC solid.

  NpcWanderStageStand:
    STA $28               ; Stage the animation: $28 := base + direction, $2A := 0 (first frame)
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$0078            ; $08 := $78: the script sleeps 121 ticks after the caller's SetEntryHereAndYield
    STA $08
    COP [MarkSolidHere]   ; A standing NPC is solid
    RTL 
}

---------------------------------------------
; Step south: stands instead when Y is already more than $30 below the home or the tile south is solid; else delta chain $11 on Y and walk animation base + 4.

NpcWanderStepSouth {
    LDA $orbitDiameter, X ; South bound: stand instead when Y is already more than $30 below the home (home Y + $30 < Y)
    CLC 
    ADC #$0030
    CMP $16
    BCC NpcWanderStandSouth
    COP [BranchIfSolidSouth] ( &NpcWanderStandSouth ) ; Tile south solid: stand facing south instead
    COP [StageMoveY] ( #11 ) ; Delta chain $11: +1 pixel every second frame (south)
    LDA $currentHp, X
    CLC 
    ADC #$0004
    BRA NpcWanderStageWalk
}

---------------------------------------------
; Step north: stands instead when Y is already at least $30 above the home or the tile north is solid; else delta chain $12 on Y and walk animation base + 5.

NpcWanderStepNorth {
    LDA $orbitDiameter, X ; North bound: stand instead when Y is already at or above home Y - $30
    SEC 
    SBC #$0030
    CMP $16
    BCS NpcWanderStandNorth
    COP [BranchIfSolidNorth] ( &NpcWanderStandNorth ) ; Tile north solid: stand facing north instead
    COP [StageMoveY] ( #12 ) ; Delta chain $12: -1 pixel every second frame (north)
    LDA $currentHp, X
    CLC 
    ADC #$0005
    BRA NpcWanderStageWalk
}

---------------------------------------------
; Step west: stands instead when X is already at least $30 left of the home or the tile west is solid; else delta chain $12 on X and walk animation base + 6.

NpcWanderStepWest {
    LDA $orbitAngle, X    ; West bound: stand instead when X is already at or left of home X - $30
    SEC 
    SBC #$0030
    CMP $14
    BCS NpcWanderStandWest
    COP [BranchIfSolidWest] ( &NpcWanderStandWest ) ; Tile west solid: stand facing west instead
    COP [StageMoveX] ( #12 ) ; Delta chain $12: -1 pixel every second frame (west)
    LDA $currentHp, X
    CLC 
    ADC #$0006
    BRA NpcWanderStageWalk
}

---------------------------------------------
; Step east: stands instead when X is already more than $30 right of the home or the tile east is solid; else delta chain $11 on X and walk animation base + 7.

NpcWanderStepEast {
    LDA $orbitAngle, X    ; East bound: stand instead when X is already beyond home X + $30
    CLC 
    ADC #$0030
    CMP $14
    BCC NpcWanderStandEast
    COP [BranchIfSolidEast] ( &NpcWanderStandEast ) ; Tile east solid: stand facing east instead
    COP [StageMoveX] ( #11 ) ; Delta chain $11: +1 pixel every second frame (east)
    LDA $currentHp, X
    CLC 
    ADC #$0007
    BRA NpcWanderStageWalk

; Walk path (shared): stage animation A, mark the NPC not solid.

  NpcWanderStageWalk:
    STA $28               ; Walk animation index (base + 4 to 7); no $08 wait, the caller's AnimOnce plays it while the chain moves the NPC
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    COP [ClearSolidHere]  ; A walking NPC is not solid
    RTL 
}