?INCLUDE 'spriteset_enemies'

!displayModeFlags               09EC

---------------------------------------------

dm45_key [
  actor-def < #02, #01, #10, {

  code_05D4B2:
    COP [BranchIfFlagByte] ( #5D, #01, &code_05D4E4 )
    COP [SetMetasprite] ( @spriteset_enemies )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D4D0 )

  loc_05D4C6:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    BRA loc_05D4C6
} >
]

code_05D4D0 {
    COP [GiveItem] ( #0B, &code_05D4E6 )
    COP [SetFlagByte] ( #5D )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_05D4EB )
}

code_05D4E4 {
    COP [Die]
}

code_05D4E6 {
    COP [PrintDialogString] ( &dialogstring_05D506 )
    RTL 
}

dialogstring_05D4EB `[DEF][SFX:0][DLY:9]You found the Mine Key![PAU:FF][END]`

dialogstring_05D506 `[DEF]You found the Mine Key![N]Your inventory is full![END]`