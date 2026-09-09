?INCLUDE 'hit_stagger_controller'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!playerHp                       0ACE
!iframeCounter                  7F0028
!extendedFlags                  7F002A

---------------------------------------------

ApplyPlayerHitstun {
    PHX 
    PHD 
    STZ $0002
    STY $0000
    ASL 
    BCC loc_00C3AA
    PHA 
    LDA #$FFC4
    STA $0002
    PLA 

  loc_00C3AA:
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_00C3B8
    LDA #$0000

  loc_00C3B8:
    STA $playerHp
    LDA $playerActor
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA $0002
    BNE loc_00C3CD
    LDA #$003C

  loc_00C3CD:
    STA $iframeCounter, X
    LDA $playerFlags
    BIT #$0800
    BNE loc_00C410
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 )
    CPY #$1FC0
    BNE loc_00C3ED
    LDA #$0F00
    TRB $joypadMaskStd

  loc_00C3ED:
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA $0000
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y

  loc_00C40A:
    COP [PlaySoundCh2] ( #07 )
    PLD 
    PLX 
    RTL 

  loc_00C410:
    LDA #$0F00
    TRB $joypadMaskStd
    BRA loc_00C40A
}