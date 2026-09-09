?INCLUDE 'EscortFollowPathTracker'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ec0A_kara [
  actor-def < #15, #00, #10, {

  code_04CB5D:
    COP [BranchIfFlagByte] ( #22, #01, &code_04CC5A )
    COP [SetSpritePriority] ( #30 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04CC07 )
    COP [BranchIfFlagByte] ( #19, #01, &code_04CBFE )
    COP [BranchIfFlagByte] ( #1A, #01, &code_04CBAA )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetFlagByte] ( #1A )
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04CC6E )
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #16, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04CC84 )
    COP [SetFlagByte] ( #02 )
} >
]

code_04CBAA {
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SetTilePos] ( #0B, #0C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_04CBBD )
    RTL 
}

code_04CBBD {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintWideString] ( &widestring_04CC96 )
    COP [WaitByte] ( #1D )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoopMoveY] ( #15, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #15, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #15, #10 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04CCE4 )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [PrintWideString] ( &widestring_04CDC0 )
    COP [SetFlagByte] ( #19 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04CBFE {
    COP [SetOnInteract] ( &code_04CC61 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_04CC07 {
    COP [SpawnAfterFlags] ( @code_04CF5C, #$2000 )
    COP [SetTilePos] ( #05, #0A )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04CC66 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SolidHighAbs] ( #06, #36 )
    COP [ClearLowHere]
    LDA #$1000
    TRB $10
    LDA #$0300
    TSB $10
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0012
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_04CC5A {
    COP [Die]

  loc_04CC5C:
    COP [PrintWideString] ( &widestring_04CDC0 )
    RTL 
}

code_04CC61 {
    COP [PrintWideString] ( &widestring_04CE45 )
    RTL 
}

code_04CC66 {
    COP [PrintWideString] ( &widestring_04CE4A )
    COP [SetFlagByte] ( #01 )
    RTL 
}

widestring_04CC6E `[TPL:9][TPL:1]Kara: Who is it?[PAL:0][PAU:5A][CLD]`

widestring_04CC84 `[TPL:9][TPL:1][CLR]Kara: A guest?[PAL:0][END]`

widestring_04CC96 `[TPL:B][TPL:1]Kara: [N]You...yesterday...[FIN][TPL:0]Will: I was told to[N]bring the Crystal Ring[N]to King Edward...[PAL:0][END]`

widestring_04CCE4 `[TPL:A][TPL:1]Kara: [N]Terrible![N]It's terrible![FIN]Again my father is[N]trying to take something[N]important from someone![FIN]I've escaped from the[N]castle before. Now they[N]won't let me go out![FIN]Recently, something very[N]strange has happened in[N]the castle.[FIN]My mother has hired[N]a famous hunter.[N]It's ominous...[PAL:0][END]`

widestring_04CDC0 `[PAU:28][TPL:A][TPL:1]Kara:  I feel scared.[N]My father and mother[N]seem to have changed.[FIN]Please save me![N]Take me out of here![N]Please...[FIN][SFX:10][PAL:0]Soldier: Princess...[FIN][::][TPL:1]Kara: [N]Please come back, Will.[PAL:0][END]`

widestring_04CE45 `[TPL:A][JMP:&ec0A_kara.widestring_04CDC0+M]`

widestring_04CE4A `[TPL:B][TPL:1]Kara: [N]Of course, you've come![N]Thank you.[FIN]Was the guard asleep[N]outside? His nickname is[N]"Old Snorehead.ˮ[N]Sleeping again.[FIN][TPL:0]Will: Your little[N]pig has come....[FIN][TPL:1]Kara: His name is [N]Hamlet. Cute, isn't he?[FIN][TPL:1]Kara: He's very smart.[N]He has some kind of[N]strange pig power...[FIN]Please, take me out of[N]here![PAL:0][END]`

code_04CF5C {
    COP [BranchIfFlagByte] ( #22, #01, &code_04CFD9 )
    COP [SolidHighAbs] ( #1E, #2D )
    COP [SolidHighAbs] ( #1F, #2D )
    COP [SolidHighAbs] ( #20, #2D )
    COP [SolidHighAbs] ( #21, #2D )

  code_04CF72:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #1E, #2C, #22, #2D, &code_04CF7D )
    RTL 
}

code_04CF7D {
    COP [BranchIfButton] ( #$0400, &code_04CF88 )
    COP [SetEntryExitNow] ( @code_04CF72 )
}

code_04CF88 {
    COP [BranchIfFlagByte] ( #01, #00, &code_04CF95 )
    COP [BranchIfNoItem] ( #0A, &code_04CFA7 )
    BRA loc_04CF9E
}

code_04CF95 {
    COP [PrintWideString] ( &widestring_04CFDB )
    COP [SetEntryExitNow] ( @code_04CF72 )

  loc_04CF9E:
    COP [PrintWideString] ( &widestring_04D012 )
    COP [SetEntryExitNow] ( @code_04CF72 )
}

code_04CFA7 {
    COP [SetFlagByte] ( #22 )
    COP [SetFlagWord] ( #$0119 )
    COP [PrintWideString] ( &widestring_04D069 )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0402
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0104, #$0334, #00, #02 )
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    COP [SetEntryContinue]
    RTL 
}

code_04CFD9 {
    COP [Die]
}

widestring_04CFDB `[TPL:A][TPL:0]Will: [N](If you want to take her[N]away, now's the time...)[END]`

widestring_04D012 `[TPL:A][TPL:1]Karen: Oh, wait![N]It will be a long trip,[N]we should take food![FIN]Would you go to the[N]cellar with me?[PAL:0][END]`

widestring_04D069 `[TPL:A][TPL:1]Kara: [N]At last, we leave.[FIN]Let's go to your house.[N]I'm worried about your[N]grandparents.[FIN][DLG:3,6][SIZ:D,3][PAL:0]They hurry to Will's.[END]`