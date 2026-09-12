?INCLUDE 'InitPlayerScriptVariant'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

st68_lily [
  actor-def < #23, #00, #10, {

  code_06B4EF:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06B4FB )
} >
]

code_list_06B4FB [
  &code_06B501   ;00
  &code_06B51F   ;01
  &code_06B571   ;02
]

code_06B501 {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3F )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06B578 )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06B51F {
    COP [SetTilePos] ( #11, #1C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06B606 )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #28 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #28, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06B661 )
    LDA #$0003
    JSL $@InitPlayerScriptVariant
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_06B67B )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0160, #$01C0, #00, #$2211 )
    COP [SetEntryContinue]
    RTL 
}

code_06B571 {
    COP [SetTilePos] ( #19, #1D )
    COP [SetEntryContinue]
    RTL 
}

code_06B578 {
    COP [PrintDialogString] ( &dialogstring_06B57D )
    RTL 
}

dialogstring_06B57D `[TPL:B][TPL:2]Lilly:[N]People are strange...[FIN]I am afraid the longer [N]we travel in this tunnel, [N]the easier it will be to [N]forget why we are here. [FIN]Maybe all ancient [N]people were that way.[PAL:0][END]`

dialogstring_06B606 `[TPL:A][TPL:0]Eighth day in the [N]tunnel.[FIN]Unable to sleep. [N]I stared at an  [N]underground river.....[PAL:0][END]`

dialogstring_06B661 `[TPL:A][TPL:2]Lilly:[N]Can't sleep?[PAL:0][END]`

dialogstring_06B67B `[PAU:1E][TPL:B][TPL:0]Will: No. [N]I'm looking for more [N]mushrooms, just kidding. [FIN][TPL:2]Lilly: Will. [N]You've changed during [N]this journey. [FIN]Somehow you've [N]grown up. [FIN][TPL:0]Will: [N]I don't understand it [N]myself, but.... [FIN]I can use some strange[N]power, and my body has[N]changed to the body[N]of a warrior.[FIN]The change seems to [N]have started when my [N]father went to the [N]Tower of Babel. [FIN]I'm just starting to[N]understand that power.[FIN]Why did you join this[N]dangerous expedition?[FIN][TPL:2]Lilly: At first it was [N]just for fun. But now [N]it's a secret. Heh heh. [FIN]We will walk all day [N]again tomorrow... [N]Let's get some sleep...[PAL:0][END]`