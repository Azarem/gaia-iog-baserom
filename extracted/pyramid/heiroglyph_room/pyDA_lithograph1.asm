?BANK 08

?INCLUDE 'f_inventory_full'

!cameraBoundsY                  06DC
!displayModeFlags               09EC

---------------------------------------------

pyDA_lithograph1 [
  actor-def < #00, #00, #30, {

  code_08C782:
    LDA #$0100
    STA $cameraBoundsY
    COP [BranchIfFlagByte] ( #C2, #01, &code_08C79F )
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_08C7A6 )
    COP [ExitIfFlagByte] ( #C2, #01 )
} >
]

code_08C79F {
    COP [StageBgChange] ( #94 )
    COP [ApplyBgChange]
    COP [Die]
}

code_08C7A6 {
    COP [BranchIfFlagByte] ( #C2, #01, &code_08C7C4 )
    COP [PrintDialogString] ( &dialogstring_08C7C9 )
    COP [GiveItem] ( #1E, &pyDA_lithograph_full )
    COP [SetFlagByte] ( #C2 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_08C831 )
}

code_08C7C4 {
    RTL 
}

pyDA_lithograph_full {
    JML $@f_inventory_full.InventoryFullMessage
}

dialogstring_08C7C9 `[DEF][TPL:0]There's a lithograph on[N]this wall. I heard in[N]Dao that it's[N]a hieroglyph...[FIN]Let's try to remove[N]the lithograph.[PAL:0][FIN]`

dialogstring_08C831 `[CLR][SFX:0][DLY:9]You've got the [N]Hieroglyph Stone![PAU:78][END]`