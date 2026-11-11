; Lance in Luke's house (scene $79): the party proposal and the later gifts.
; 
; With $97 clear and $96 clear: if $91 is set, or $90 is clear (he has not met his father yet), Lance dies at spawn. With $90 set and $91 clear he locks the player ($CFFC), moves the player's Y by -2, prints "Let's have Lilly's birthday party while we're all together.", sets scratch $01 (Lily's cue), waits for scratch $03 (set by Kara), prints "Ah, Lilly. Can I talk to you for a minute? I'll wait outside.", walks and sets scratch $04.
; 
; With $97 clear and $96 set he stands at tile (07,09) with "I made my father very happy before. I think he will slowly recover.".
; 
; With $97 set the handler depends on $A5: clear -> 'I'm sorry, but I want to stay here...' and scratch $01 is set (it releases Neil's departure talk); set -> the Red Jewel gift once: with $E2 clear it prints 'My father's getting better every day...' and gives item $01 (a full inventory jumps to HiddenRedJewelInventoryFull and $E2 stays clear), then sets $E2; with $E2 set it prints 'I hope you get to see your father soon.'.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

wa79_lance [
  actor-def < #03, #00, #10, {

  code_07AC7F:
    COP [BranchOnFlagByte] ( #97, #01, &code_07ACEC )
    COP [BranchOnFlagByte] ( #96, #01, &code_07ACD6 )
    COP [BranchOnFlagByte] ( #91, #01, &code_07ACD4 )
    COP [BranchOnFlagByte] ( #90, #00, &code_07ACD4 )
    LDA #$CFFC
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07AD31 )
    COP [SetFlagByte] ( #01 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_07AD63 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #11 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #04 )
} >
]

code_07ACD4 {
    COP [Die]
}

code_07ACD6 {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_07AD02 )
    COP [MarkSolidHere]
    COP [NudgePosition] ( #00, #F8 )
    COP [SetEntryHere]
    RTL 
}

code_07ACEC {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [NudgePosition] ( #00, #F8 )
    COP [SetInteractHandler] ( &code_07AD07 )
    COP [SetEntryHere]
    RTL 
}

code_07AD02 {
    COP [PrintDialogString] ( &dialogstring_07ADA9 )
    RTL 
}

code_07AD07 {
    COP [BranchOnFlagByte] ( #A5, #01, &code_07AD15 )
    COP [PrintDialogString] ( &dialogstring_07ADEA )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_07AD15 {
    COP [BranchOnFlagByte] ( #E2, #01, &code_07AD2C )
    COP [PrintDialogString] ( &dialogstring_07AEDE )
    COP [GiveItem] ( #01, &code_07AD28 )
    COP [SetFlagByte] ( #E2 )
    RTL 
}

code_07AD28 {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_07AD2C {
    COP [PrintDialogString] ( &dialogstring_07AFA7 )
    RTL 
}

dialogstring_07AD31 `[TPL:A][TPL:4]Lance: Let's have Lilly's [N]birthday party while [N]we're all together. [END]`

dialogstring_07AD63 `[TPL:A][TPL:4]Lance: Ah, Lilly. [N]Can I talk to you [N]for a minute? [FIN]I'll wait outside.[END]`

dialogstring_07ADA9 `[TPL:A][TPL:4]Lance: I made my father [N]very happy before. [FIN]I think he will slowly[N]recover.[PAL:0][END]`

dialogstring_07ADEA `[TPL:B][TPL:4]Lance: I'm sorry, but [N]I want to stay here. [N]I can't neglect [N]my father. [FIN]And so...[N][PAU:78]I feel a little awkward.[FIN]I wanted to spend[N]time with Lilly.[FIN]Of course, I don't feel [N]good about it. I wanted [N]to go on with everyone. [FIN]And I wanted to[N]stay with Lilly.[FIN]I've enjoyed the[N]journey. I hope[N]you're successful.[PAL:0][END]`

dialogstring_07AEDE `[TPL:B][TPL:4]Lance: [N]My father's getting [N]better every day. [FIN]Now we can talk.[N]I hope you get to[N]see your father soon.[FIN]Right. I believe you[N]have been collecting[N]Red Jewels.[FIN]I found a Red Jewel in[N]my father's possessions.[N]Please take it.[FIN][PAL:0]Will gets a Red Jewel![END]`

dialogstring_07AFA7 `[TPL:B][TPL:4]I hope you get to[N]see your father soon.[PAL:0][END]`