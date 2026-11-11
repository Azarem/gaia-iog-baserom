; Statue of Hope pickups of the Mu west room (scene $62) and the Mu maze (scene $65).
; 
; mu62_hope_statue sets flag $78 as soon as it spawns, installs an interact handler and dies once flag $79 is set. The handler does nothing while music is playing; otherwise it calls GiveItem #12 (Statue of Hope), sets $79 and shows "You've found the Statue of Hope! ... Was there a room with the same name...?". A full inventory prints the inventory-is-full message and leaves $79 clear. mu62_hope_statue2 (the maze) does the same with flag $7F and the text "Was there another room with the same name...?".
; 
; The statue is a key item: UseItem_StatueOfHope consumes it on a pedestal of the prayer room (scene $63). It gives no stat boost.
---------------------------------------------

?INCLUDE 'music_actors'

!displayModeFlags               09EC

---------------------------------------------

mu62_hope_statue [
  actor-def < #00, #00, #30, {

  code_0698A5:
    COP [SetFlagByte] ( #78 )
    COP [SetInteractHandler] ( &code_0698B2 )
    COP [WaitOnFlagByte] ( #79, #01 )
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
    COP [MusicAndText] ( #17, @dialogstring_0698D2 )

  loc_0698CC:
    RTL 
}

code_0698CD {
    COP [PrintDialogString] ( &dialogstring_069925 )
    RTL 
}

dialogstring_0698D2 `[DEF][SFX:0][DLY:9]You've found the [N]Statue of Hope! [N][PAU:3C][DLY:2]The Statue of Hope... [N][PAU:1E]Was there a room [N]with the same name...?[PAU:5A][END]`

dialogstring_069925 `[DEF]You've found the Statue [N]of Hope! But your [N]inventory is full! [END]`

mu62_hope_statue2 [
  actor-def < #00, #00, #30, {

  code_069950:
    COP [SetInteractHandler] ( &code_06995A )
    COP [WaitOnFlagByte] ( #7F, #01 )
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
    COP [MusicAndText] ( #17, @dialogstring_069975 )

  loc_069974:
    RTL 
}

dialogstring_069975 `[DEF][SFX:0][DLY:9]You've found the [N]Statue of Hope! [N][PAU:3C][DLY:2]The Statue of Hope... [N][PAU:1E]Was there another room[N]with the same name...?[PAU:5A][END]`