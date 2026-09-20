; Ishtar (angel leader) in the tunnel rooms — guards Kara.
; 
; Boss-gating NPC. Says: "I wonder if you're here to get Kara.
; Go into this room..." Ishtar controls access to the puzzle
; test rooms and later becomes the area boss. Sets up the
; Ishtar's test sequence.
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