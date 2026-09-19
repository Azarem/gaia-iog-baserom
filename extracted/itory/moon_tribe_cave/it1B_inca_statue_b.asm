; Incan Statue B collectible in the Moon Tribe cave.
; 
; Key item pickup with inventory-full fallback dialog.
; Second of the two statues needed for the Incan Ruins.
---------------------------------------------

!displayModeFlags               09EC

---------------------------------------------

it1B_inca_statue_b [
  actor-def < #00, #00, #30, {

  code_04FAC8:
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04FADF )
    COP [ExitIfFlagByte] ( #48, #01 )
    COP [StageBgChange] ( #1D )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011D )
    COP [Die]
} >
]

code_04FADF {
    COP [GiveItem] ( #04, &code_04FAF4 )
    COP [SetFlagByte] ( #48 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_04FAF9 )
    RTL 
}

code_04FAF4 {
    COP [PrintDialogString] ( &dialogstring_04FB16 )
    RTL 
}

dialogstring_04FAF9 `[DLG:3,6][SIZ:D,3][SFX:0][DLY:9]You've got[N]Incan Statue B![PAU:FF][END]`

dialogstring_04FB16 `[DLG:3,6][SIZ:D,3]You've found Incan [N]Statue B! But your [N]inventory is full! [END]`