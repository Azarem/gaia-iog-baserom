; Ishtar and her self-portrait in the tunnel rooms (scene $74).
; 
; Flag $89 is set by the test scene ($75) after the fourth correct answer. With $89 clear the actor stands at its post in frame #12 and its interact handler prints 'I wonder if you're here to get Kara. Go into this room. If you solve all the riddles, I'll give back the girl.'; with $89 set the actor dies at spawn.
; 
; At spawn the actor also starts a child actor (code_06CEB8, offset (0,-16)) for the self-portrait. With $89 clear the child shows frame #13 and has no interact handler. With $89 set it shows frame #15 and installs the handler code_06CEDF, which sets flag $8B and prints the long speech ('I have been waiting for you. Sprinkle magic powder on the painting, and give it a kiss...') the first time and '.............' on every later talk.
; 
; No actor of scene $74 starts a fight (the scene lists the player, the camera, av74_kara, av74_ishtar and a hidden Red Jewel).
---------------------------------------------

---------------------------------------------

av74_ishtar [
  actor-def < #12, #00, #10, {

  code_06CE85:
    COP [NudgePosition] ( #00, #FC )
    LDA #$0200
    TSB $12
    COP [SpawnAfterOffsetFlags] ( @code_06CEB8, #$0000, #$FFF0, #$0300 )
    COP [SetInteractHandler] ( &code_06CEDA )
    COP [BranchOnFlagByte] ( #89, #00, &code_06CEA5 )
    COP [Die]
} >
]

code_06CEA5 {
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    RTL 
}

actor_def_06CEAD [
  actor-def < #13, #00, #10, {

  code_06CEB0:
    COP [MarkSolidAbs] ( #25, #08 )
    COP [NudgePosition] ( #08, #00 )
} >
]

code_06CEB8 {
    COP [BranchOnFlagByte] ( #89, #00, &code_06CECE )
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &code_06CEDF )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    BRA loc_06CED3
}

code_06CECE {
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]

  loc_06CED3:
    COP [MarkSolidAbs] ( #25, #08 )
    COP [SetEntryHere]
    RTL 
}

code_06CEDA {
    COP [PrintDialogString] ( &dialogstring_06CEF2 )
    RTL 
}

code_06CEDF {
    COP [BranchOnFlagByte] ( #8B, #01, &code_06CEED )
    COP [SetFlagByte] ( #8B )
    COP [PrintDialogString] ( &dialogstring_06CF5E )
    RTL 
}

code_06CEED {
    COP [PrintDialogString] ( &dialogstring_06D039 )
    RTL 
}

dialogstring_06CEF2 `[TPL:A][TPL:3]Ishtar: I wonder if you're[N]here to get Kara. [FIN]Go into this room.[FIN]If you solve all the[N]riddles, I'll give back[N]the girl. [END]`

dialogstring_06CF5B `[PAL:0][END]`

dialogstring_06CF5E `[TPL:A][TPL:3]Ishtar:[N]I have been[N]waiting for you.[FIN]Sprinkle magic powder[N]on the painting, and[N]give it a kiss.[FIN]If you care about her [N]deeply, something will [N]happen. You'll see. [FIN]I painted a[N]self-portrait.[FIN]Soon I will become[N]the painting...[FIN]You must take care[N]of her...[PAL:0][END]`

dialogstring_06D039 `[TPL:A][TPL:3].............[PAL:0][END]`