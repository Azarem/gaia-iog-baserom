?INCLUDE 'EscortFollowPathTracker'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

it1A_lily [
  actor-def < #1B, #00, #10, {

  code_04F444:
    COP [BranchIfFlagByte] ( #4A, #01, &code_04F4E9 )
    COP [SpawnAfterFlags] ( @code_04F77B, #$2000 )
    COP [SpawnAfterFlags] ( @code_04F828, #$2000 )
    COP [BranchIfFlagByte] ( #49, #01, &code_04F4C0 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04F53C )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$1000
    TRB $10
    LDA #$0300
    TSB $10
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #49, #01, &code_04F4AC )
    RTL 
} >
]

code_04F4AC {
    COP [KillNext]
    LDA #$0000
    STA $2A
    COP [SetEntryExit]
    COP [PrintWideString] ( &widestring_04F575 )
    COP [SetOnInteract] ( &code_04F4EB )
    COP [SetEntryContinue]
    RTL 
}

code_04F4C0 {
    COP [SetTilePos] ( #0D, #1A )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04F4F0 )
    COP [ExitIfFlagByte] ( #4A, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #03, #01 )
    COP [AnimLoop]
}

code_04F4E9 {
    COP [Die]
}

code_04F4EB {
    COP [PrintWideString] ( &widestring_04F575 )
    RTL 
}

code_04F4F0 {
    COP [BranchIfNoItem] ( #04, &code_04F4FA )
    COP [PrintWideString] ( &widestring_04F591 )
    RTL 
}

code_04F4FA {
    COP [SetFlagByte] ( #4A )
    COP [PrintWideString] ( &widestring_04F5EA )
    COP [DialogueOptions] ( #02, #02, &code_list_04F507 )
}

code_list_04F507 [
  &code_04F50D   ;00
  &code_04F511   ;01
  &code_04F50D   ;02
]

code_04F50D {
    COP [PrintWideString] ( &widestring_04F653 )
}

code_04F511 {
    COP [PrintWideString] ( &widestring_04F68F )
    LDA #$0000
    STA $0D60
    LDA #$0002
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0094, #$0254, #00, #06 )
    COP [QueueMapChange] ( #1C, #$0070, #$0160, #00, #$2200 )
    COP [SetEntryContinue]
    RTL 
}

widestring_04F53C `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Ah, we've[N]arrived. This is the[N]Moon Tribe's home.[END]`

widestring_04F575 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly:[N]I'll wait here.[END]`

widestring_04F591 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly:[N]What happened?[FIN]......... I can see[N]in your face.....[FIN]Don't be depressed,[N]try again.[END]`

widestring_04F5EA `[DLG:3,6][SIZ:D,4][TPL:2]Lilly:[N]Oh, that statue![N]You are great!! [FIN]There are two statues. [N]Go to the Incan ruins? [N][PAL:0] Yes[N] No`

widestring_04F653 `[CLR][TPL:2]Lilly: [N]Will, I know you're. [N]lying. You must go [N]no matter what you say. [FIN]`

widestring_04F68F `[CLR][TPL:0]Will: [N]Yes. My father [N]summoned me... [FIN]I don't want to fight [N]the demons, but if my [N]father's alive, I'll risk [N]anything to see him. [FIN]You don't really[N]understand until you[N]lose your parents...[FIN][TPL:2]Lilly:[N]Typical....[FIN]I understand.[N]Let's go to the ruins.[FIN][PAL:0][SFX:10]They headed to [N]the Incan ruins. [END]`

code_04F77B {
    COP [SolidHighAbs] ( #15, #1C )
    COP [SolidHighAbs] ( #16, #1C )

  code_04F783:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #4A, #01, &code_04F7B7 )
    COP [BranchIfPlayerInAbsTiles] ( #15, #1B, #17, #1C, &code_04F794 )
    RTL 
}

code_04F794 {
    COP [BranchIfButton] ( #$0400, &code_04F79F )
    COP [SetEntryExitNow] ( @code_04F783 )
}

code_04F79F {
    COP [BranchIfFlagByte] ( #49, #01, &code_04F7AE )
    COP [PrintWideString] ( &widestring_04F7C1 )
    COP [SetEntryExitNow] ( @code_04F783 )
}

code_04F7AE {
    COP [PrintWideString] ( &widestring_04F7F7 )
    COP [SetEntryExitNow] ( @code_04F783 )
}

code_04F7B7 {
    COP [ClearLowAbs] ( #15, #1C )
    COP [ClearLowAbs] ( #16, #1C )
    COP [Die]
}

widestring_04F7C1 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Wait! We came[N]here for a reason! We[N]can't just leave![END]`

widestring_04F7F7 `[DLG:3,6][SIZ:D,3][TPL:0]Will: [N](I can't go without the [N]Incan Statue...)[PAL:0][END]`

code_04F828 {
    COP [SolidHighAbs] ( #0C, #18 )
    COP [BranchIfFlagByte] ( #2A, #01, &code_04F857 )

  code_04F832:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0C, #19, #0D, #1A, &code_04F83D )
    RTL 
}

code_04F83D {
    COP [BranchIfButton] ( #$0800, &code_04F848 )
    COP [SetEntryExitNow] ( @code_04F832 )
}

code_04F848 {
    COP [BranchIfFlagByte] ( #2A, #01, &code_04F857 )
    COP [PrintWideString] ( &widestring_04F860 )
    COP [SetEntryExitNow] ( @code_04F832 )
}

code_04F857 {
    COP [SetFlagByte] ( #49 )
    COP [ClearLowAbs] ( #0C, #18 )
    COP [Die]
}

widestring_04F860 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Let's talk to the[N]Moon Tribe, and then[N]have a look around.[END]`