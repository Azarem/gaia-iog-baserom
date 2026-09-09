?INCLUDE 'music_actors'

!displayModeFlags               09EC

---------------------------------------------

mu62_hope_statue [
  actor-def < #00, #00, #30, {

  code_0698A5:
    COP [SetFlagByte] ( #78 )
    COP [SetOnInteract] ( &code_0698B2 )
    COP [ExitIfFlagByte] ( #79, #01 )
    COP [Die]
} >
]

code_0698B2 {
    JSL $@music_actors.IsMusicPlaying
    BCS loc_0698CC
    COP [GiveItem] ( #12, &code_0698CD )
    COP [SetFlagByte] ( #79 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @widestring_0698D2 )

  loc_0698CC:
    RTL 
}

code_0698CD {
    COP [PrintWideString] ( &widestring_069925 )
    RTL 
}

widestring_0698D2 `[DEF][SFX:0][DLY:9]You've found the [N]Statue of Hope! [N][PAU:3C][DLY:2]The Statue of Hope... [N][PAU:1E]Was there a room [N]with the same name...?[PAU:5A][END]`

widestring_069925 `[DEF]You've found the Statue [N]of Hope! But your [N]inventory is full! [END]`

mu62_hope_statue2 [
  actor-def < #00, #00, #30, {

  code_069950:
    COP [SetOnInteract] ( &code_06995A )
    COP [ExitIfFlagByte] ( #7F, #01 )
    COP [Die]
} >
]

code_06995A {
    JSL $@music_actors.IsMusicPlaying
    BCS loc_069974
    COP [GiveItem] ( #12, &code_0698CD )
    COP [SetFlagByte] ( #7F )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @widestring_069975 )

  loc_069974:
    RTL 
}

widestring_069975 `[DEF][SFX:0][DLY:9]You've found the [N]Statue of Hope! [N][PAU:3C][DLY:2]The Statue of Hope... [N][PAU:1E]Was there another room[N]with the same name...?[PAU:5A][END]`