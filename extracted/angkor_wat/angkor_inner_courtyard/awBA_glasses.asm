; Black Crystal Glasses pickup in the Angkor Wat inner courtyard.
; 
; Collectible item: "There's something shiny on the ground."
; Then: "You've found the Black Crystal Glasses!" Key item
; needed for seeing hidden spirits and puzzle solutions.
---------------------------------------------

?INCLUDE 'f_inventory_full'
?INCLUDE 'spriteset_enemies'

!displayModeFlags               09EC

---------------------------------------------

awBA_glasses [
  actor-def < #02, #01, #10, {

  code_089F7F:
    COP [BranchIfFlagByte] ( #BA, #01, &code_089FB5 )
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetOnInteract] ( &code_089F9D )

  loc_089F93:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_089F93
} >
]

code_089F9D {
    COP [PrintDialogString] ( &dialogstring_089FBB )
    COP [GiveItem] ( #1C, &code_089FB7 )
    COP [SetFlagByte] ( #BA )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_089FDC )
}

code_089FB5 {
    COP [Die]
}

code_089FB7 {
    JML $@f_inventory_full.InventoryFullMessage
}

dialogstring_089FBB `[DEF]There's something shiny[N]on the ground.[FIN]`

dialogstring_089FDC `[CLR][SFX:0][DLY:9]You've found the Black[N]Crystal Glasses![PAU:78][END]`