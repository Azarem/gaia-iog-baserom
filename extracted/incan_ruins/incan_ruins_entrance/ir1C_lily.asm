?INCLUDE 'EscortFollowPathTracker'
?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'sE6_gaia'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ir1C_lily [
  actor-def < #1D, #00, #10, {

  code_09CA02:
    COP [BranchIfFlagByte] ( #4B, #01, &code_09CAB1 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_09CAE5 )
    COP [SolidHighAbs] ( #06, #19 )
    COP [SolidHighAbs] ( #07, #19 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0003
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #01, #01, &code_09CA54 )
    RTL 
} >
]

code_09CA54 {
    LDA #$0800
    TRB $10
    COP [KillNext]
    COP [ClearLowAbs] ( #06, #19 )
    COP [ClearLowAbs] ( #07, #19 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$0000
    JSL $@InitPlayerScriptVariant
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_09CCD0 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    LDA $16
    AND #$FFF0
    STA $16
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #14 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_09CE01 )
    COP [SetFlagByte] ( #4B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
}

code_09CAB1 {
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetTilePos] ( #16, #13 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09CAE0 )
    LDA $characterForm
    BEQ loc_09CADD
    LDY $playerActor
    SEP #$20
    LDA #$^sE6_gaia.func_08F37D
    STA $0002, Y
    REP #$20
    LDA #$&sE6_gaia.func_08F37D
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags

  loc_09CADD:
    COP [SetEntryContinue]
    RTL 
}

code_09CAE0 {
    COP [PrintDialogString] ( &dialogstring_09CE01 )
    RTL 
}

dialogstring_09CAE5 `[DLG:3,11][SIZ:D,4][TPL:2]Lilly: Here's the[N]entrance to the ruins.[FIN]They say that this is [N]where the puzzle of the [N]Incan legend is hidden. [FIN]I heard this story from[N]the Elder when[N]I was a child...[FIN]After being invaded, the[N]Incas decided to leave[N]their native land to[N]find a new world.[FIN]They secretly built[N]a huge ship and filled[N]it with priceless[N]gold artifacts.[FIN]But there's no record of[N]the ship leaving...[FIN]That's probably the Incan [N]Gold Ship in the story. [FIN]I don't think the Elder[N]has ever told that story[N]to any outsider.[FIN]I wonder what he wants[N]you to do...[PAL:0][END]`

dialogstring_09CCB3 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly:[N]Come here a moment.[END]`

dialogstring_09CCD0 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Why are you in a[N]place like this![N]It's dangerous![FIN][TPL:1]Kara: Lola told me [N]about this place. I've [N]been waiting! [FIN]I thought you'd left[N]me. You should tell me[N]where you're going!![FIN]What is Will looking [N]for in the ruins? [FIN]I can't just wait around [N]and eat while Will is [N]working so hard. [FIN]I'm waiting here for [N]Will to return. [FIN][TPL:2]Lilly: Well, a princess[N]wouldn't understand...[FIN]I'll wait for [N]you here. OK? [END]`

dialogstring_09CE01 `[DLG:3,6][SIZ:D,4][TPL:2]Lilly: [N]Will. I remember what [N]the Elder said. [FIN]"Put the statue on the [N]Larai Cliff below the [N]ruins, where the spirits'[N]breath cannot reach. [FIN]The valley wind will [N]lead you to the [N]Gold Shipˮ.  [PAL:0][END]`