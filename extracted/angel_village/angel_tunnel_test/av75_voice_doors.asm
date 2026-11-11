; Door objects of Ishtar's test corridor (scene $75): eight actors share this script, the door index 0-7 being the low nibble of the actor word $0E.
; 
; An actor dies at spawn when flag $89 (test passed) is set or when the player is inside a room (Y < $F0). In the corridor it installs an interact handler that compares the phase word $0AA6 with the door index: a smaller counter prints 'Ishtar's voice resounds. Don't hurry. Open the doors in order from the left.', a larger one prints 'That door is already open. There's no need to open it.', an equal one plays sound #0E, applies BgChange #49 + index and sets word flag $0149 + index.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

!srcCacheFullGfxL0              067E
!playerYPos                     09A4

---------------------------------------------

av75_voice_doors [
  actor-def < #00, #00, #10, {

  code_06D787:
    LDA #$0200
    TSB $12
    COP [BranchOnFlagByte] ( #89, #01, &code_06D7BB )
    STZ $srcCacheFullGfxL0+1
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $playerYPos
    CMP #$00F0
    BCC code_06D7BB
    COP [NudgePosition] ( #08, #02 )
    LDA $0E
    AND #$000F
    STA $24
    STZ $0E
    COP [SetInteractHandler] ( &code_06D7BD )
    COP [SetEntryHere]
    RTL 
} >
]

code_06D7BB {
    COP [Die]
}

code_06D7BD {
    LDA $0AA6
    CMP $24
    BCC loc_06D834
    BNE loc_06D839
    COP [PlaySoundCh1] ( #0E )
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06D7D4 )
}

code_list_06D7D4 [
  &code_06D7E4   ;00
  &code_06D7EE   ;01
  &code_06D7F8   ;02
  &code_06D802   ;03
  &code_06D80C   ;04
  &code_06D816   ;05
  &code_06D820   ;06
  &code_06D82A   ;07
]

code_06D7E4 {
    COP [StageBgChange] ( #49 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0149 )
    RTL 
}

code_06D7EE {
    COP [StageBgChange] ( #4A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014A )
    RTL 
}

code_06D7F8 {
    COP [StageBgChange] ( #4B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014B )
    RTL 
}

code_06D802 {
    COP [StageBgChange] ( #4C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014C )
    RTL 
}

code_06D80C {
    COP [StageBgChange] ( #4D )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014D )
    RTL 
}

code_06D816 {
    COP [StageBgChange] ( #4E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014E )
    RTL 
}

code_06D820 {
    COP [StageBgChange] ( #4F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014F )
    RTL 
}

code_06D82A {
    COP [StageBgChange] ( #50 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0150 )
    RTL 

  loc_06D834:
    COP [PrintDialogString] ( &dialogstring_06D83E )
    RTL 

  loc_06D839:
    COP [PrintDialogString] ( &dialogstring_06D87B )
    RTL 
}

dialogstring_06D83E `[TPL:A]Istar's voice resounds.[FIN]Don't hurry.[N]Open the doors in order[N]from the left.[END]`

dialogstring_06D87B `[TPL:A]Istar's voice resounds.[FIN]That door is already[N]open. There's no[N]need to open it.[END]`