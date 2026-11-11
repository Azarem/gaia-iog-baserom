; Coastal cave card pickup (the Ace of Diamonds trick).
; 
; The scene places one card at tile (07,0A); it runs the entry code_04AFB5 (sprite priority $30, a nudge of (8,0), then idles). Lance spawns four more cards at code_04AFBF (SpawnAfterOffsetFlags in sc02_lance). Each of those stages sprite and hitbox $38 and tests every frame whether the player's position (plus 8 in X and $0A in Y) is within 8 pixels of the card in both axes and the button mask $8001 is pressed. Pressing it prints 'Will picks up a card. It is the Ace of Diamonds, of course!', sets scratch flag $08, locks the joypad ($CFFC) and kills the card; sc02_lance releases the lock. A card out of reach switches to an idle entry once $08 is set. No item is given.
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
    COP [NudgePosition] ( #08, #00 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04AFBF {
    COP [StageSprAndHitbox] ( #38 )
    STZ $08
    COP [SetEntryHere]
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
    COP [BranchIfPressed] ( #$8001, &code_04B000 )

  loc_04AFF6:
    COP [BranchOnFlagByte] ( #08, #01, &code_04AFFD )
    RTL 
}

code_04AFFD {
    COP [SetEntryHere]
    RTL 
}

code_04B000 {
    COP [PrintDialogString] ( &dialogstring_04B00F )
    COP [SetFlagByte] ( #08 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [Die]
}

dialogstring_04B00F `[DLG:3,6][SIZ:D,3]Will picks up a card.[FIN]It is the Ace of[N]Diamonds, of course![END]`