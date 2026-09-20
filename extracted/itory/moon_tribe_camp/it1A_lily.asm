; Lily at the Moon Tribe camp.
; 
; Accompanies Will to the Moon Tribe, waits outside during
; the encounter, and reacts to outcomes. Multi-phase dialog
; with movement sequences.
---------------------------------------------

?INCLUDE 'EscortFollowPathTracker'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

it1A_lily [
  actor-def < #1B, #00, #10, {

  code_04F444:
    COP [BranchOnFlagByte] ( #4A, #01, &code_04F4E9 )
    COP [SpawnAfterFlags] ( @code_04F77B, #$2000 )
    COP [SpawnAfterFlags] ( @code_04F828, #$2000 )
    COP [BranchOnFlagByte] ( #49, #01, &code_04F4C0 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04F53C )
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
    COP [SetInteractHandler] ( #$0000 )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchOnFlagByte] ( #49, #01, &code_04F4AC )
    RTL 
} >
]

code_04F4AC {
    COP [KillNext]
    LDA #$0000
    STA $2A
    COP [SetEntryHereAndYield]
    COP [PrintDialogString] ( &dialogstring_04F575 )
    COP [SetInteractHandler] ( &code_04F4EB )
    COP [SetEntryHere]
    RTL 
}

code_04F4C0 {
    COP [SetTilePos] ( #0D, #1A )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04F4F0 )
    COP [WaitOnFlagByte] ( #4A, #01 )
    COP [ClearSolidHere]
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
    COP [PrintDialogString] ( &dialogstring_04F575 )
    RTL 
}

code_04F4F0 {
    COP [BranchIfMissingItem] ( #04, &code_04F4FA )
    COP [PrintDialogString] ( &dialogstring_04F591 )
    RTL 
}

code_04F4FA {
    COP [SetFlagByte] ( #4A )
    COP [PrintDialogString] ( &dialogstring_04F5EA )
    COP [DialogueOptions] ( #02, #02, &code_list_04F507 )
}

code_list_04F507 [
  &code_04F50D   ;00
  &code_04F511   ;01
  &code_04F50D   ;02
]

code_04F50D {
    COP [PrintDialogString] ( &dialogstring_04F653 )
}

code_04F511 {
    COP [PrintDialogString] ( &dialogstring_04F68F )
    LDA #$0000
    STA $0D60
    LDA #$0002
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0094, #$0254, #00, #06 )
    COP [QueueMapChange] ( #1C, #$0070, #$0160, #00, #$2200 )
    COP [SetEntryHere]
    RTL 
}

dialogstring_04F53C `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Ah, we've[N]arrived. This is the[N]Moon Tribe's home.[END]`

dialogstring_04F575 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly:[N]I'll wait here.[END]`

dialogstring_04F591 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly:[N]What happened?[FIN]......... I can see[N]in your face.....[FIN]Don't be depressed,[N]try again.[END]`

dialogstring_04F5EA `[DLG:3,6][SIZ:D,4][TPL:2]Lilly:[N]Oh, that statue![N]You are great!! [FIN]There are two statues. [N]Go to the Incan ruins? [N][PAL:0] Yes[N] No`

dialogstring_04F653 `[CLR][TPL:2]Lilly: [N]Will, I know you're. [N]lying. You must go [N]no matter what you say. [FIN]`

dialogstring_04F68F `[CLR][TPL:0]Will: [N]Yes. My father [N]summoned me... [FIN]I don't want to fight [N]the demons, but if my [N]father's alive, I'll risk [N]anything to see him. [FIN]You don't really[N]understand until you[N]lose your parents...[FIN][TPL:2]Lilly:[N]Typical....[FIN]I understand.[N]Let's go to the ruins.[FIN][PAL:0][SFX:10]They headed to [N]the Incan ruins. [END]`

code_04F77B {
    COP [MarkSolidAbs] ( #15, #1C )
    COP [MarkSolidAbs] ( #16, #1C )

  code_04F783:
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #4A, #01, &code_04F7B7 )
    COP [BranchIfPlayerInAbsTiles] ( #15, #1B, #17, #1C, &code_04F794 )
    RTL 
}

code_04F794 {
    COP [BranchIfPressed] ( #$0400, &code_04F79F )
    COP [JumpNextFrame] ( @code_04F783 )
}

code_04F79F {
    COP [BranchOnFlagByte] ( #49, #01, &code_04F7AE )
    COP [PrintDialogString] ( &dialogstring_04F7C1 )
    COP [JumpNextFrame] ( @code_04F783 )
}

code_04F7AE {
    COP [PrintDialogString] ( &dialogstring_04F7F7 )
    COP [JumpNextFrame] ( @code_04F783 )
}

code_04F7B7 {
    COP [ClearSolidAbs] ( #15, #1C )
    COP [ClearSolidAbs] ( #16, #1C )
    COP [Die]
}

dialogstring_04F7C1 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Wait! We came[N]here for a reason! We[N]can't just leave![END]`

dialogstring_04F7F7 `[DLG:3,6][SIZ:D,3][TPL:0]Will: [N](I can't go without the [N]Incan Statue...)[PAL:0][END]`

code_04F828 {
    COP [MarkSolidAbs] ( #0C, #18 )
    COP [BranchOnFlagByte] ( #2A, #01, &code_04F857 )

  code_04F832:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0C, #19, #0D, #1A, &code_04F83D )
    RTL 
}

code_04F83D {
    COP [BranchIfPressed] ( #$0800, &code_04F848 )
    COP [JumpNextFrame] ( @code_04F832 )
}

code_04F848 {
    COP [BranchOnFlagByte] ( #2A, #01, &code_04F857 )
    COP [PrintDialogString] ( &dialogstring_04F860 )
    COP [JumpNextFrame] ( @code_04F832 )
}

code_04F857 {
    COP [SetFlagByte] ( #49 )
    COP [ClearSolidAbs] ( #0C, #18 )
    COP [Die]
}

dialogstring_04F860 `[DLG:3,6][SIZ:D,3][TPL:2]Lilly: Let's talk to the[N]Moon Tribe, and then[N]have a look around.[END]`