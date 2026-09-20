; Lilly at the Freejia hotel — manages the party reunion scene.
; 
; Multi-state NPC (~95 lines). Initial: "Come in... Will and Kara?!"
; Later explains: "Lance hit his head escaping from the Incan
; ship... The doctor says..." — establishes Lance's amnesia
; and the need for the Memory Melody.
---------------------------------------------

?BANK 05

?INCLUDE 'fr39_kara'

!joypadMaskStd                  065A

---------------------------------------------

fr39_lily [
  actor-def < #22, #00, #10, {

  code_05C5B6:
    COP [BranchIfFlagByte] ( #65, #01, &code_05C629 )
    COP [BranchIfFlagByte] ( #58, #01, &code_05C629 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #26, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #22, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05C654 )
    COP [SetFlagByte] ( #01 )
    COP [SetOnInteract] ( &code_05C634 )
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #1C )
    COP [StageSpriteLoopMoveX] ( #29, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [SetEntryExit]
    COP [StageSpriteLoop] ( #22, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05C67C )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_05C620:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C639 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C629 {
    COP [SetTilePos] ( #16, #1C )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_05C620
}

code_05C634 {
    COP [PrintDialogString] ( &fr39_kara.dialogstring_05C4CD+M )
    RTL 
}

code_05C639 {
    COP [BranchIfFlagByte] ( #68, #01, &code_05C64F )
    COP [BranchIfFlagByte] ( #65, #01, &code_05C64A )
    COP [PrintDialogString] ( &dialogstring_05C70B )
    RTL 
}

code_05C64A {
    COP [PrintDialogString] ( &dialogstring_05C67C+M )
    RTL 
}

code_05C64F {
    COP [PrintDialogString] ( &dialogstring_05C74D )
    RTL 
}

dialogstring_05C654 `[TPL:A][TPL:2]Lilly:[N]Come in...[FIN]Will and Kara...?![PAL:0][END]`

dialogstring_05C67C `[TPL:A][TPL:2]Lilly: Lance hit his [N]head escaping from [N]the Incan ship... [FIN]The doctor said that he[N]has temporary amnesia.[FIN][::][TPL:A][TPL:2]Meanwhile, I think [N]Lance should stay here [N]until he recovers.[PAL:0][END]`

dialogstring_05C70B `[TPL:A][TPL:2]Lilly: Also, I haven't [N]seen Erik since [N]last night. [FIN]I wonder what's happened?[PAL:0][END]`

dialogstring_05C74D `[TPL:A][TPL:2]Lilly:[N]I've experienced much[N]in my travels...[PAL:0][END]`