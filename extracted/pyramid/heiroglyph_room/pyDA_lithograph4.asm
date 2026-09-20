; Lithograph 4 in the hieroglyph room.
; 
; Fourth hieroglyph panel in the puzzle sequence.
---------------------------------------------

?BANK 08

?INCLUDE 'pyDA_lithograph1'

!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph4 [
  actor-def < #00, #00, #30, {

  code_08C99F:
    COP [BranchOnFlagByte] ( #C5, #01, &code_08C9B6 )
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #00, #02 )
    COP [SetInteractHandler] ( &code_08C9BD )
    COP [WaitOnFlagByte] ( #C5, #01 )
} >
]

code_08C9B6 {
    COP [StageBgChange] ( #97 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C9BD {
    COP [BranchOnFlagByte] ( #C5, #01, &code_08C9DB )
    COP [PrintDialogString] ( &pyDA_lithograph1.dialogstring_08C7C9 )
    COP [GiveItem] ( #21, &pyDA_lithograph1.pyDA_lithograph_full )
    COP [SetFlagByte] ( #C5 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @pyDA_lithograph1.dialogstring_08C831 )
}

code_08C9DB {
    RTL 
}

