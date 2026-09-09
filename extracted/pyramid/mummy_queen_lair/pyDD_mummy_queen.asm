?BANK 0B

?INCLUDE 'cop_handlers_actors'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'func_0AA36E'
?INCLUDE 'func_0AFD69'
?INCLUDE 'py_queen_actor_0BAAAA'
?INCLUDE 'py_queen_actor_0BABB3'
?INCLUDE 'py_queen_actor_0BACBC'
?INCLUDE 'sE6_gaia'
?INCLUDE 'smooth_follow_child'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'table_0EE000'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!orbitAngle                     7F0010
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!currentHp                      7F0026
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!scratch1010                    7F1010

---------------------------------------------

btF6_neo_queen [
  actor-def < #00, #00, #00, {

  code_0BA61D:
    LDA #$8191
    TSB $12
    COP [SpawnLastRel] ( @code_0BA65F, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0BA636
    JMP $&code_0BA6CF

  loc_0BA636:
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F5F9
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F5F9
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0BA65C
    RTL 

  loc_0BA65C:
    JMP $&code_0BA6CF
} >
]

code_0BA65F {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0BA667
    RTL 

  loc_0BA667:
    COP [ExitIfFlagByte] ( #01, #00 )
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0BA674
    RTL 

  loc_0BA674:
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F3B1
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F3B1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0BA69A
    RTL 

  loc_0BA69A:
    COP [SetFlagWord] ( #$0179 )
    LDA #$0002
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$01F8, #$03A0, #03, #$4430 )
    COP [Die]
}

pyDD_mummy_queen [
  actor-def < #00, #00, #00, {

  code_0BA6B9:
    LDA #$0004
    JSL $@cop_handlers_script.TestWramFlag_Offset100
    BCC loc_0BA6CA
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0BA6CA:
    LDA #$8191
    TSB $12
} >
]

code_0BA6CF {
    LDY $playerActor
    LDA $0012, Y
    ORA #$0008
    STA $0012, Y
    LDA #$0A0A
    STA $20
    LDA #$1858
    STA $22
    LDA #$0000
    STA $orbitAngle, X
    COP [SpawnMarkedAfter] ( @func_0AFD69, #$2000 )
    TYA 
    STA $scratch1010+6, X
    COP [SetDeathCallback] ( @code_0BA9C2 )

  code_0BA6FD:
    LDA $orbitAngle, X
    CMP #$0002
    BCC loc_0BA70C
    COP [SetHitCallback] ( &code_0BA7BD )
    BRA loc_0BA710

  loc_0BA70C:
    COP [SetHitCallback] ( &code_0BA8AA )

  loc_0BA710:
    COP [SetSavedPtr] ( &code_0BA6FD )
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BA722 )
}

code_list_0BA722 [
  &code_0BA96D   ;00
  &code_0BA96D   ;01
  &code_0BA769   ;02
  &code_0BA769   ;03
  &code_0BA732   ;04
  &code_0BA732   ;05
  &code_0BA732   ;06
  &code_0BA732   ;07
]

code_0BA732 {
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [RngByte]
    PHA 
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $playerXPos
    STA $moveXAlt, X
    PLA 
    LSR 
    LSR 
    SEC 
    SBC #$001F
    CLC 
    ADC $playerYPos
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #01, #FF )
    COP [TickMove]
    COP [RestoreSavedPtr]
}

code_0BA769 {
    COP [SpawnBeforeFlags] ( @code_0BA782, #$2202 )
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSpriteLoop] ( #FF, #0A )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BA782 {
    COP [AddPosition] ( #0C, #B2 )
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #20 )
    LDA #$0004
    CLC 
    ADC $0B02
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @smooth_follow_child.code_00E4FC, #$2000 )
    LDA $playerActor
    STA $0024, Y

  loc_0BA7AE:
    COP [StageSpriteLoop] ( #0C, #08 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0BA7AE
    COP [Die]
}

code_0BA7BD {
    LDA #$0007
    STA $26

  loc_0BA7C2:
    COP [SpawnAfterRelFlags] ( @py_queen_actor_0BAAAA, #$0000, #$FFFC, #$2200 )
    LDA #$0000
    STA $0026, Y
    DEC $26
    BPL loc_0BA7C2
    LDA #$0001
    STA $0026, Y
    LDA #$0200
    TSB $10
    COP [PlaySoundCh1] ( #0C )
    LDA $orbitAngle, X
    CLC 
    ADC #$0009
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA #$0008
    TSB $12
    LDA #$0001
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    COP [SetEntryExit]
    LDA $26
    BEQ loc_0BA829
    JSR $&code_0BA842
    JSR $&code_0BA876
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    RTL 

  loc_0BA829:
    LDA #$0008
    TRB $12
    LDA #$00FF
    STA $24
    LDA #$0007
    STA $0000
    LDA #$&loc_0BAC7F
    JSR $&code_0BAA4A
    JMP $&code_0BA8FB
}

code_0BA842 {
    LDA $moveXAlt, X
    BPL loc_0BA85F
    LDA $14
    BMI loc_0BA852
    CMP #$0050
    BCC loc_0BA852
    RTS 

  loc_0BA852:
    LDA $moveXAlt, X
    EOR #$FFFF
    INC 
    STA $moveXAlt, X
    RTS 

  loc_0BA85F:
    LDA $14
    BMI loc_0BA868
    CMP #$01B0
    BCS loc_0BA869

  loc_0BA868:
    RTS 

  loc_0BA869:
    LDA $moveXAlt, X
    EOR #$FFFF
    INC 
    STA $moveXAlt, X
    RTS 
}

code_0BA876 {
    LDA $moveYAlt, X
    BPL loc_0BA893
    LDA $16
    BMI loc_0BA886
    CMP #$0080
    BCC loc_0BA886
    RTS 

  loc_0BA886:
    LDA $moveYAlt, X
    EOR #$FFFF
    INC 
    STA $moveYAlt, X
    RTS 

  loc_0BA893:
    LDA $16
    BMI loc_0BA89C
    CMP #$01B0
    BCS loc_0BA89D

  loc_0BA89C:
    RTS 

  loc_0BA89D:
    LDA $moveYAlt, X
    EOR #$FFFF
    INC 
    STA $moveYAlt, X
    RTS 
}

code_0BA8AA {
    LDA #$0007
    STA $26

  loc_0BA8AF:
    COP [SpawnAfterRelFlags] ( @py_queen_actor_0BABB3, #$0000, #$FFFC, #$2200 )
    DEC $26
    BPL loc_0BA8AF
    STZ $26
    LDA #$0200
    TSB $10
    LDA #$00FF
    STA $24
    COP [PlaySoundCh1] ( #0C )
    LDA $orbitAngle, X
    CLC 
    ADC #$0009
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA $0B02
    XBA 
    LSR 
    LSR 
    CLC 
    ADC #$0168
    STA $08
    COP [SetEntryExit]
    LDA #$0007
    STA $0000
    LDA #$&code_0BAC7D
    JSR $&code_0BAA63
}

code_0BA8FB {
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA902
    RTL 

  loc_0BA902:
    LDA #$0007
    STA $0000
    LDA #$&loc_0BACAF
    JSR $&code_0BAA4A
    LDA $currentHp, X
    CMP #$0014
    BCC loc_0BA936
    CMP #$001E
    BCC loc_0BA91E
    BRA loc_0BA94E

  loc_0BA91E:
    LDA $orbitAngle, X
    CMP #$0001
    BEQ loc_0BA94E
    LDA #$0001
    STA $orbitAngle, X
    COP [SpawnThinkerParam] ( #5C, @cop_handlers_actors.PaletteResetAndKillThinker )
    BRA loc_0BA94E

  loc_0BA936:
    LDA $orbitAngle, X
    CMP #$0002
    BEQ loc_0BA94E
    LDA #$0002
    STA $orbitAngle, X
    COP [SpawnThinkerParam] ( #5D, @cop_handlers_actors.PaletteResetAndKillThinker )
    BRA loc_0BA94E

  loc_0BA94E:
    COP [PlaySoundCh1] ( #29 )
    LDA #$2000
    TRB $10
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    JMP $&code_0BA6FD
}

code_0BA96D {
    COP [SetHitCallback] ( &code_0BA9B7 )
    COP [PlaySoundCh1] ( #15 )
    LDA $orbitAngle, X
    CLC 
    ADC #$0003
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $28
    CLC 
    ADC #$0003
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @py_queen_actor_0BACBC, #$2800 )
    COP [StageSpriteLoop] ( #FF, #0A )
    COP [AnimLoop]
    LDY $06
    LDA #$0001
    STA $0024, Y
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSpriteLoop] ( #FF, #12 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BA9B7 {
    LDY $06
    LDA #$0001
    STA $0024, Y
    JMP $&code_0BA8AA
}

code_0BA9C2 {
    LDY $06
    LDA #$0001
    STA $0024, Y
    LDA $playerFlags
    BIT #$0200
    BEQ loc_0BA9D5
    COP [SetEntryContinue]
    RTL 

  loc_0BA9D5:
    LDA #$0020
    TSB $playerFlags
    COP [SpawnLastRel] ( @func_0AA36E, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0BA9F2, #00, #E0, #$2300 )
    COP [WaitByte] ( #3B )
    COP [Die]
}

code_0BA9F2 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0C )
    COP [SpawnLastRel] ( @code_0BAA19, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0BAA23, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [LoopNext]
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

code_0BAA19 {
    JSR $&code_0BAA2D
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BAA23 {
    JSR $&code_0BAA2D
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0BAA2D {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0BAA4A {
    LDY $06
    PHA 

  loc_0BAA4D:
    LDA #$0000
    STA $0008, Y
    LDA $01, S
    STA $0000, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0BAA4D
    PLA 
    RTS 
}

code_0BAA63 {
    LDY $06
    STZ $0018
    STZ $001C
    PHA 

  loc_0BAA6C:
    LDA #$0000
    STA $0008, Y
    LDA $01, S
    STA $0000, Y
    LDA $0014, Y
    CLC 
    ADC $0018
    STA $0018
    LDA $0016, Y
    CLC 
    ADC $001C
    STA $001C
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0BAA6C
    LDA $0018
    LSR 
    LSR 
    LSR 
    STA $14
    LDA $001C
    LSR 
    LSR 
    LSR 
    STA $16
    PLA 
    RTS 
}
---------------------------------------------

code_0BAC7D {
    COP [KillNext]

  loc_0BAC7F:
    LDA #$2000
    TRB $10
    LDY $26
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC #$FFFC
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDY $26
    LDA $0024, Y
    LSR 
    STA $0024, Y

  loc_0BACA8:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    BRA loc_0BACA8

  loc_0BACAF:
    COP [WaitByte] ( #07 )
    COP [Die]
}