; Waterfall sound and alcove flag in the waterfall tunnel (scene $73).
; 
; At spawn, if the player is inside tiles (00,00)-(40,10) the actor sets scratch flag $00 and dies. Otherwise it spawns a watcher (code_06D733) that sets scratch $00 while the player is inside tiles (2A,17)-(2F,1D) and clears it everywhere else, and its main script writes APUIO0 = $40 + min(2 * |playerXTile - $2C|, $30) every fourth frame, so the value grows with the horizontal distance from tile column $2C. What the sound engine does with that port value (volume or another parameter) is not traced here.
; 
; Scratch $00 is read by the player's idle, ladder and shimmy code, which selects the alternate sprite set while it is set.
---------------------------------------------

!frameCounter                   0036
!playerXTile                    09A6
!APUIO0                         2140

---------------------------------------------

av73_waterfall_sound [
  actor-def < #00, #00, #30, {

  code_06D6F7:
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #40, #10, &code_06D72E )
    COP [SpawnAfterFlags] ( @code_06D733, #$2000 )
    COP [SetEntryHere]
    LDA $frameCounter
    AND #$0003
    BEQ loc_06D711
    RTL 

  loc_06D711:
    SEP #$20
    LDA $playerXTile
    SEC 
    SBC #$2C
    BPL loc_06D71E
    EOR #$FF
    INC 

  loc_06D71E:
    ASL 
    CMP #$30
    BCC loc_06D725
    LDA #$30

  loc_06D725:
    CLC 
    ADC #$40
    STA $APUIO0
    REP #$20
    RTL 
} >
]

code_06D72E {
    COP [SetFlagByte] ( #00 )
    COP [Die]
}

code_06D733 {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #2A, #17, #2F, #1D, &code_06D741 )
    COP [ClearFlagByte] ( #00 )
    RTL 
}

code_06D741 {
    COP [SetFlagByte] ( #00 )
    RTL 
}