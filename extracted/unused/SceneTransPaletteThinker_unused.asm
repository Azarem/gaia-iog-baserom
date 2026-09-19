; Unreferenced scene-transition palette thinker, likely an earlier design for palette fades during map changes.
; 
; Would spawn looping child thinkers for palette #20/#21 or #22 depending on player flag $0002, with a one-shot #0B fade on exit. Superseded by the current scene-load palette system.
---------------------------------------------

!playerActor                    09AA
!playerFlags                    09AE
!chatPtr                        7F000A
!metaspritePtr                  7F000C

---------------------------------------------

SceneTransPaletteThinker_unused {
    LDY $playerActor
    LDA $0028, Y          ; OR Y to check both axes simultaneously
    STA $metaspritePtr, X
    COP [SpawnThinker] ( @SceneTransPaletteWarmLoop )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0002            ; ResumeAfterSnap: restore saved script PC
    BNE loc_00B56F
    PHX 
    LDY $playerActor      ; Restore saved bank byte from $7F101A
    TYX 
    SEP #$20
    LDA $7F0008, X
    PLX 
    CMP #$8F
    BNE loc_00B562        ; StageMove: read animation index
    REP #$20
    LDA $0028, Y
    CMP $metaspritePtr, X
    BNE loc_00B562        ; ProcessAnimFlag: set animation with directional flip
    RTL 

  loc_00B562:
    REP #$20              ; X delta: moveXAlt - actor.X
    JSR $&SceneTransPaletteKillChild
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]     ; Store absolute X distance
    RTL 

  loc_00B56F:
    JSR $&SceneTransPaletteKillChild
    COP [SpawnThinker] ( @SceneTransPaletteChildTick )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue] ; Store absolute Y distance
    LDA $playerFlags      ; Select larger axis for frame count calc
    BIT #$0002
    BEQ loc_00B587
    RTL 

  loc_00B587:
    JSR $&SceneTransPaletteKillChild
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]     ; Loop: halve distances while high byte nonzero
    RTL 
}

SceneTransPaletteWarmLoop {
    COP [PaletteStart] ( #20 )
    COP [PaletteStep]

  loc_00B597:
    COP [PaletteStart] ( #21 )
    COP [PaletteStep]     ; Distance (single byte) as WRDIVL dividend
    BRA loc_00B597        ; Read speed byte operand
}

SceneTransPaletteChildTick {
    COP [PaletteStart] ( #22 )
    COP [PaletteStep]
    COP [SetEntryContinue] ; Speed >= $80: treat as signed negative
    RTL 
}

SceneTransPaletteKillChild {
    PHX 
    PHD 
    LDA $chatPtr, X
    TCD                   ; HalveMovementDistance: LSR both axis distances
    TAX 
    COP [KillThinker]
    PLD 
    PLX 
    RTS 
}