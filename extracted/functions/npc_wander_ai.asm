; Reusable town-NPC wander behavior (Bank 00) used by ~12 ambient NPC actors in Watermia, Euro, Dao, Angel Village, South Cape, and similar field scenes.
; 
; SyncActorPosFromDP copies the actor's DP position ($14/$16) into WRAM home coordinates at $7F0010/$7F0012. NpcRandomWanderAI rolls RNG & $07 and dispatches through an 8-case SwitchCase table: cases 0–3 idle-turn in place (adding 0–3 to the facing/sprite index, staging animation, waiting $78 frames, SolidHighHere), cases 4–7 attempt a one-tile forced move south/north/west/east if within ±$30 pixels of home and the path is not blocked.
; 
; Successful moves call UpdateActorAnimation and ClearLowHere; idle turns hold collision high. The pattern gives lightweight random patrol without pathfinding.
---------------------------------------------

?INCLUDE 'sprite_composition'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!currentHp                      7F0026

---------------------------------------------

SyncActorPosFromDP {
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    RTL 
}

NpcRandomWanderAI {
    COP [RngByte]         ; NpcRandomWanderAI: RngByte AND #$07 selects one of eight direction handlers
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00C733 )
}

code_list_00C733 [
  &NpcWanderStandAnim1   ;00
  &NpcWanderStandAnim0   ;01
  &NpcWanderStandAnim2   ;02
  &NpcWanderStandAnim3   ;03
  &NpcWanderStepNorth   ;04
  &NpcWanderStepSouth   ;05
  &NpcWanderStepWest   ;06
  &NpcWanderStepEast   ;07
]

NpcWanderStandAnim0 {
    LDA $currentHp, X
    CLC 
    ADC #$0000
    BRA loc_00C76B
}

NpcWanderStandAnim1 {
    LDA $currentHp, X     ; Wander stand path: store anim index in $28, idle timer $78 frames
    CLC 
    ADC #$0001
    BRA loc_00C76B
}

NpcWanderStandAnim2 {
    LDA $currentHp, X
    CLC 
    ADC #$0002
    BRA loc_00C76B
}

NpcWanderStandAnim3 {
    LDA $currentHp, X
    CLC 
    ADC #$0003
    BRA loc_00C76B

  loc_00C76B:
    STA $28
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$0078
    STA $08
    COP [SolidHighHere]
    RTL 
}

NpcWanderStepSouth {
    LDA $orbitDiameter, X ; Wander south: probe Y+$30 against solid; StageForceMoveY #11 on blocked path
    CLC 
    ADC #$0030
    CMP $16
    BCC NpcWanderStandAnim0
    COP [BranchIfSolidSouth] ( &NpcWanderStandAnim0 )
    COP [StageForceMoveY] ( #11 )
    LDA $currentHp, X
    CLC 
    ADC #$0004
    BRA loc_00C7EF
}

NpcWanderStepNorth {
    LDA $orbitDiameter, X
    SEC 
    SBC #$0030
    CMP $16
    BCS NpcWanderStandAnim1
    COP [BranchIfSolidNorth] ( &NpcWanderStandAnim1 )
    COP [StageForceMoveY] ( #12 )
    LDA $currentHp, X
    CLC 
    ADC #$0005
    BRA loc_00C7EF
}

NpcWanderStepWest {
    LDA $orbitAngle, X
    SEC 
    SBC #$0030
    CMP $14
    BCS NpcWanderStandAnim2
    COP [BranchIfSolidWest] ( &NpcWanderStandAnim2 )
    COP [StageForceMoveX] ( #12 )
    LDA $currentHp, X
    CLC 
    ADC #$0006
    BRA loc_00C7EF
}

NpcWanderStepEast {
    LDA $orbitAngle, X
    CLC 
    ADC #$0030
    CMP $14
    BCC NpcWanderStandAnim3
    COP [BranchIfSolidEast] ( &NpcWanderStandAnim3 )
    COP [StageForceMoveX] ( #11 )
    LDA $currentHp, X
    CLC 
    ADC #$0007
    BRA loc_00C7EF

  loc_00C7EF:
    STA $28
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    COP [ClearLowHere]
    RTL 
}