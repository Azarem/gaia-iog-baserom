; Lithograph 3 in the hieroglyph room.
; 
; Third hieroglyph panel in the puzzle sequence.
---------------------------------------------

?BANK 08

?INCLUDE 'pyDA_lithograph1'

!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph3 [
  actor-def < #00, #00, #30, {

  code_08C8F7:
    COP [BranchIfFlagByte] ( #C4, #01, &code_08C90E )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C915 )
    COP [ExitIfFlagByte] ( #C4, #01 )
} >
]

code_08C90E {
    COP [StageBgChange] ( #96 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C915 {
    COP [BranchIfFlagByte] ( #C4, #01, &code_08C933 )
    COP [PrintDialogString] ( &pyDA_lithograph1.dialogstring_08C7C9 )
    COP [GiveItem] ( #20, &pyDA_lithograph1.pyDA_lithograph_full )
    COP [SetFlagByte] ( #C4 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @pyDA_lithograph1.dialogstring_08C831 )
}

code_08C933 {
    RTL 
}

