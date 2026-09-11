?INCLUDE 'sprite_composition'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!decompressedTilesets           7E4000
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

pyDD_teleporter [
  actor-def < #0F, #01, #07, {

  code_0BADCA:
    BRA loc_0BADCF
} >
]

pyDD_teleporter_right [
  actor-def < #0F, #01, #07, {

  loc_0BADCF:
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BADE0
    RTL 

  loc_0BADE0:
    LDA $playerFlags
    BIT #$0002
    BEQ loc_0BADE9
    RTL 

  loc_0BADE9:
    COP [BranchIfPlayerNear] ( #01, &code_0BADEF )
    RTL 
} >
]

code_0BADEF {
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0BAE18, #$2700 )
    LDA #$0001
    STA $24
    COP [SetEntryExit]
    LDA $24
    BEQ loc_0BADCF
    PHX 
    LDX $playerActor
    LDY $06
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLX 
    RTL 
}

code_0BAE18 {
    LDA #$0008
    TSB $12
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA $playerXPos
    CLC 
    ADC #$0008
    STA $14
    LDA $playerYPos
    CLC 
    ADC #$0010
    STA $16
    COP [MoveToward] ( #FF, #04 )
    LDY $playerActor
    LDA $0010, Y
    ORA #$2200
    STA $0010, Y
    LDA #$2000
    TRB $10
    COP [PlaySoundCh2] ( #0C )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $04
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$00F0
    STA $moveYAlt, X
    COP [MoveToward] ( #27, #08 )
    COP [SetMetasprite] ( $7E4000 )
    COP [PlaySoundCh2] ( #0C )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $14
    CMP #$0100
    BCC loc_0BAE99
    LDA #$4000
    TSB $12

  loc_0BAE99:
    LDA $14
    CLC 
    ADC #$0020
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #27, #04 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    PHX 
    PHD 
    TYA 
    TCD 
    TAX 
    LDA $00
    PHA
    LDA $02
    PHA 
    COP [StagePlayerSprite] ( #00 )
    JSL $@sprite_composition.UpdateActorAnimation
    STZ $2A
    STZ $08
    PLA
    STA $02
    PLA 
    STA $00
    PLD 
    PLX 
    LDY $04
    LDA #$0000
    STA $0024, Y
    LDA #$2000
    TSB $10
    LDA #$0028
    STA $24
    LDY $playerActor
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    COP [SetEntryContinue]
    DEC $24
    BMI loc_0BAF2D
    LDY $playerActor
    LDA $0036
    LSR 
    LDA $0010, Y
    BCS loc_0BAF1D
    ORA #$0001
    STA $0010, Y
    LDA $000E, Y
    AND #$CFFF
    BRA loc_0BAF29

  loc_0BAF1D:
    AND #$FFFE
    STA $0010, Y
    LDA $000E, Y
    ORA #$3000

  loc_0BAF29:
    STA $000E, Y
    RTL 

  loc_0BAF2D:
    LDA $joypadMaskStd
    BIT #$0F00
    BNE loc_0BAF41
    LDY $playerActor
    LDA $0010, Y
    AND #$FDFF
    STA $0010, Y

  loc_0BAF41:
    LDY $playerActor
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [Die]
}