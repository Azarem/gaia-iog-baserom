?BANK 08

?INCLUDE 'pyDA_lithograph1'

!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph6 [
  actor-def < #00, #00, #30, {

  code_08CAEF:
    COP [BranchIfFlagByte] ( #C7, #01, &code_08CB06 )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08CB0D )
    COP [ExitIfFlagByte] ( #C7, #01 )
} >
]

code_08CB06 {
    COP [StageBgChange] ( #99 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08CB0D {
    COP [BranchIfFlagByte] ( #C7, #01, &code_08CB2B )
    COP [PrintDialogString] ( &pyDA_lithograph1.dialogstring_08C7C9 )
    COP [GiveItem] ( #23, &pyDA_lithograph1.pyDA_lithograph_full )
    COP [SetFlagByte] ( #C7 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @pyDA_lithograph1.dialogstring_08C831 )
}

code_08CB2B {
    RTL 
}

