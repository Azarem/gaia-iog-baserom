; Coastal cave collectible card pickup.
; 
; Displays a dialog when Will picks up the Ace of Diamonds.
; One of the Red Jewel/card collectibles.
---------------------------------------------

?BANK 04

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

sc02_card [
  actor-def < #34, #00, #10, {

  code_04AFB5:
    COP [SetSpritePriority] ( #30 )
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04AFBF {
    COP [StageSprAndHitbox] ( #38 )
    STZ $08
    COP [SetEntryContinue]
    LDA $playerXPos
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    BPL loc_04AFD6
    EOR #$FFFF
    INC 

  loc_04AFD6:
    CMP #$0008
    BCS loc_04AFF6
    LDA $playerYPos
    CLC 
    ADC #$000A
    SEC 
    SBC $16
    BPL loc_04AFEB
    EOR #$FFFF
    INC 

  loc_04AFEB:
    CMP #$0008
    BCS loc_04AFF6
    COP [BranchIfButton] ( #$8001, &code_04B000 )

  loc_04AFF6:
    COP [BranchIfFlagByte] ( #08, #01, &code_04AFFD )
    RTL 
}

code_04AFFD {
    COP [SetEntryContinue]
    RTL 
}

code_04B000 {
    COP [PrintDialogString] ( &dialogstring_04B00F )
    COP [SetFlagByte] ( #08 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [Die]
}

dialogstring_04B00F `[DLG:3,6][SIZ:D,3]Will picks up a card.[FIN]It is the Ace of[N]Diamonds, of course![END]`