!playerActor                    09AA
!playerFlags                    09AE
!chatPtr                        7F000A
!metaspritePtr                  7F000C

---------------------------------------------

SceneTransPaletteThinker_unused {
    LDY $playerActor
    LDA $0028, Y
    STA $metaspritePtr, X
    COP [SpawnThinker] ( @code_00B592 )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0002
    BNE loc_00B56F
    PHX 
    LDY $playerActor
    TYX 
    SEP #$20
    LDA $7F0008, X
    PLX 
    CMP #$8F
    BNE loc_00B562
    REP #$20
    LDA $0028, Y
    CMP $metaspritePtr, X
    BNE loc_00B562
    RTL 

  loc_00B562:
    REP #$20
    JSR $&code_00B5A6
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 

  loc_00B56F:
    JSR $&code_00B5A6
    COP [SpawnThinker] ( @code_00B59E )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0002
    BEQ loc_00B587
    RTL 

  loc_00B587:
    JSR $&code_00B5A6
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B592 {
    COP [PaletteStart] ( #20 )
    COP [PaletteStep]

  loc_00B597:
    COP [PaletteStart] ( #21 )
    COP [PaletteStep]
    BRA loc_00B597
}

code_00B59E {
    COP [PaletteStart] ( #22 )
    COP [PaletteStep]
    COP [SetEntryContinue]
    RTL 
}

code_00B5A6 {
    PHX 
    PHD 
    LDA $chatPtr, X
    TCD 
    TAX 
    COP [KillThinker]
    PLD 
    PLX 
    RTS 
}