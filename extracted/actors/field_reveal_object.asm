?INCLUDE 'cop_handlers_script'
?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'interaction_handlers'
?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!chatPtr                        7F000A
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!collisionLayer                 7FC000

---------------------------------------------

field_reveal_object {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    LDA #$6000
    TRB $12
    LDA $26
    BNE code_00DAD9
    LDA $sceneCurrent
    JSL $@cop_handlers_script.TestFlag_0300
    BCS code_00DAD9
    LDY $sceneCurrent
    LDA $&enemy_clear_reward_table, Y
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00DAA4 )
}

code_list_00DAA4 [
  &code_00DAD9   ;00
  &code_00DAAC   ;01
  &code_00DABB   ;02
  &code_00DACA   ;03
]

code_00DAAC {
    COP [StageSprAndHitbox] ( #0C )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0080
    BRA loc_00DB0B
}

code_00DABB {
    COP [StageSprAndHitbox] ( #0D )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0081
    BRA loc_00DB0B
}

code_00DACA {
    COP [StageSprAndHitbox] ( #0E )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0082
    BRA loc_00DB0B
}

code_00DAD9 {
    LDA $statsPtr, X
    TAY 
    LDA $0003, Y
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00DAED )
}

code_list_00DAED [
  &code_00DB88   ;00
  &code_00DAF5   ;01
  &code_00DAFD   ;02
  &code_00DB05   ;03
]

code_00DAF5 {
    COP [StageSprAndHitbox] ( #04 )
    LDA #$0083
    BRA loc_00DB0B
}

code_00DAFD {
    COP [StageSprAndHitbox] ( #05 )
    LDA #$0084
    BRA loc_00DB0B
}

code_00DB05 {
    COP [StageSprAndHitbox] ( #06 )
    LDA #$0085

  loc_00DB0B:
    STA $chatPtr, X
    LDA $16
    STA $24
    LDA #$0007
    STA $26
    LDA $16
    AND #$FFF0
    STA $16
    BRA loc_00DB43

  code_00DB21:
    DEC $26
    BPL loc_00DB2C
    LDA $24
    INC 
    STA $16
    BRA loc_00DB47

  loc_00DB2C:
    PHX 
    TYX 
    LDA $collisionLayer, X
    PLX 
    AND #$00FF
    CMP #$000E
    BEQ loc_00DB47
    LDA $16
    CLC 
    ADC #$0010
    STA $16

  loc_00DB43:
    COP [BranchIfSolid] ( &code_00DB21 )

  loc_00DB47:
    LDA $16
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    LDA $24
    STA $16
    COP [MoveToward] ( #FF, #04 )
    COP [StageForceMoveXY] ( #00, #45 )
    COP [WaitByte] ( #0B )
    COP [SpawnMarkedAfter] ( @interaction_handlers.collect_handler_gem, #$2300 )

  loc_00DB69:
    COP [LoopInit] ( #64 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
    LDA $28
    CMP #$0008
    BCS loc_00DB69
    CLC 
    ADC #$0005
    STA $28
    COP [LoopInit] ( #0A )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_00DB88 {
    COP [Die]
}