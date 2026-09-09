?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'chunk_03BAE1'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'music_actors'
?INCLUDE 'table_0EE000'

!sceneNext                      0642
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!BG1SC                          2107
!BG2SC                          2108
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

statue_inventory_reward [
  actor-def < #00, #00, #30, {

  code_00CD5C:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @inventory_spritemap )
    SEP #$20
    LDA #$08
    STA $BG1SC
    LDA #$0C
    STA $BG2SC
    LDA #$13
    STA $TM
    LDA #$11
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$02
    STA $CGADSUB
    REP #$20
    STZ $0676
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00CD9D
    COP [AddPosition] ( #00, #F8 )

  loc_00CD9D:
    LDA #$2000
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@statue_reward_00CE97, X
    AND #$00FF
    JSL $@cop_handlers_script.TestFlagRaw
    BCC loc_00CDBB
    JMP $&code_00CE7B

  loc_00CDBB:
    LDA $@statue_reward_00CE97+2, X
    AND #$00FF
    CMP $0AAC
    BEQ loc_00CDCA
    JMP $&code_00CE93

  loc_00CDCA:
    LDA $@statue_reward_00CE97, X
    AND #$00FF
    JSL $@cop_handlers_script.SetFlagRaw
    LDA $@statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_03BAE1.func_03CA55
    LDA #$0001
    STA $26

  loc_00CDEA:
    COP [SpawnAfterFlags] ( @code_00CEAF, #$1802 )
    LDA $26
    CLC 
    ADC #$0020
    STA $26
    STA $0026, Y
    CMP #$0101
    BNE loc_00CDEA
    TYA 
    STA $26
    LDA #$00B4
    STA $0AAC
    COP [SetEntryContinue]
    DEC $0AAC
    BEQ loc_00CE46
    JSL $@music_actors.IsMusicPlaying
    BCC loc_00CE18
    RTL 

  loc_00CE18:
    LDA #$0000
    STA $0AAC
    COP [WaitByte] ( #0F )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetEntryExit]
    PHX 
    LDX $26
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BEQ loc_00CE35
    RTL 

  loc_00CE35:
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #3C )
    COP [SpawnAfterFlags] ( @code_00CEFF, #$1802 )
    COP [LoopNext]

  loc_00CE46:
    LDA $0B12
    STA $sceneNext
    LDA $0B08
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064C
    LDA $0B0C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064E
    LDA #$0003
    STA $0650
    LDA $0B10
    STA $0652
    LDA #$0303
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [SetEntryContinue]
    RTL 
} >
]

code_00CE7B {
    LDA $@statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_03BAE1.func_03CA55
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

code_00CE93 {
    PLX 
    COP [SetEntryContinue]
    RTL 
}

statue_reward_00CE97 [
  statue-reward < #F8, #3A, #00 >   ;00
  statue-reward < #F9, #3B, #01 >   ;01
  statue-reward < #FA, #3C, #02 >   ;02
  statue-reward < #FB, #3D, #03 >   ;03
  statue-reward < #FC, #3E, #04 >   ;04
  statue-reward < #FD, #3F, #05 >   ;05
]

code_00CEAF {
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$00FC
    STA $orbitDiameter, X
    LDA $26
    STA $orbitAngle, X

  loc_00CEC7:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_00CEC7
    LDA $08
    INC 
    STA $26
    STZ $08
    COP [SetEntryContinue]
    DEC $26
    BMI loc_00CEC7
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    CLC 
    ADC #$0004
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_00CEFD
    SEC 
    SBC #$0002
    STA $orbitDiameter, X
    RTL 

  loc_00CEFD:
    COP [Die]
}

code_00CEFF {
    LDA $0036
    AND #$0003
    BNE loc_00CF27
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    LDA $16
    SEC 
    SBC #$0008
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_00CF27:
    COP [Die]
}