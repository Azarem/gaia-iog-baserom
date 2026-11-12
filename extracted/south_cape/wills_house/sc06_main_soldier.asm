; Edward Castle soldier who arrests Kara in Will's house.
; 
; Cutscene actor. At spawn flag $1B set kills it; otherwise it waits for scratch flag $04 (Lola's line), takes tile (0A,19) and watches for the player inside tiles (04,19)-(0E,1D). On entry it locks the joypad ($CFFC), waits 30 ticks (WaitByte #1D), steps in, prints the soldier and Kara exchange, sets scratch $07 and waits for scratch $08 (Kara's reply), then walks off and dies. It sets no persistent flag: sc06_kara sets $1B, and sc06_bill releases the joypad lock.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

sc06_main_soldier [
  actor-def < #1A, #00, #30, {

  code_04A363:
    COP [BranchOnFlagByte] ( #1B, #01, &code_04A3B9 )
    COP [WaitOnFlagByte] ( #04, #01 )
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #0A, #19 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #04, #19, #0E, #1D, &code_04A386 )
    RTL 
} >
]

code_04A386 {
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04A3BB )
    COP [SetFlagByte] ( #07 )
    COP [WaitOnFlagByte] ( #08, #01 )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #20, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #0A, #11 )
    COP [AnimLoop]
}

code_04A3B9 {
    COP [Die]
}

dialogstring_04A3BB `[TPL:B]Soldier: Princess! I've[N]been looking for you![FIN][TPL:1]Kara: [N]I don't know you.[N]Be gone![FIN][PAL:0][SFX:10]Soldier: What are you [N]saying? If I don't take [N]you home,[N]I'll lose my head? [END]`