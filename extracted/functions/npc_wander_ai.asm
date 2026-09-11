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
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00C733 )
}

code_list_00C733 [
  &code_00C74D   ;00
  &code_00C743   ;01
  &code_00C757   ;02
  &code_00C761   ;03
  &code_00C798   ;04
  &code_00C77B   ;05
  &code_00C7B5   ;06
  &code_00C7D2   ;07
]

code_00C743 {
    LDA $currentHp, X
    CLC 
    ADC #$0000
    BRA loc_00C76B
}

code_00C74D {
    LDA $currentHp, X
    CLC 
    ADC #$0001
    BRA loc_00C76B
}

code_00C757 {
    LDA $currentHp, X
    CLC 
    ADC #$0002
    BRA loc_00C76B
}

code_00C761 {
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

code_00C77B {
    LDA $orbitDiameter, X
    CLC 
    ADC #$0030
    CMP $16
    BCC code_00C743
    COP [BranchIfSolidSouth] ( &code_00C743 )
    COP [StageForceMoveY] ( #11 )
    LDA $currentHp, X
    CLC 
    ADC #$0004
    BRA loc_00C7EF
}

code_00C798 {
    LDA $orbitDiameter, X
    SEC 
    SBC #$0030
    CMP $16
    BCS code_00C74D
    COP [BranchIfSolidNorth] ( &code_00C74D )
    COP [StageForceMoveY] ( #12 )
    LDA $currentHp, X
    CLC 
    ADC #$0005
    BRA loc_00C7EF
}

code_00C7B5 {
    LDA $orbitAngle, X
    SEC 
    SBC #$0030
    CMP $14
    BCS code_00C757
    COP [BranchIfSolidWest] ( &code_00C757 )
    COP [StageForceMoveX] ( #12 )
    LDA $currentHp, X
    CLC 
    ADC #$0006
    BRA loc_00C7EF
}

code_00C7D2 {
    LDA $orbitAngle, X
    CLC 
    ADC #$0030
    CMP $14
    BCC code_00C761
    COP [BranchIfSolidEast] ( &code_00C761 )
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