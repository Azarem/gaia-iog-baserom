!joypadMaskStd                  065A
!characterForm                  0AD4

---------------------------------------------

mu67_erik [
  actor-def < #0C, #00, #10, {

  code_06A2C1:
    LDA $characterForm
    BEQ loc_06A2CB
    LDA #$FFFF
    STA $24

  loc_06A2CB:
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06A34F )
    COP [BranchIfFlagByte] ( #86, #01, &code_06A305 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_06A2EF )
    RTL 
} >
]

code_06A2EF {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #17 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_06A36B )
    COP [SetFlagByte] ( #86 )
}

code_06A305 {
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$2000
    TSB $10
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$2000
    TRB $10
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #0E, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #11, #13 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06A34F {
    COP [BranchIfFlagByte] ( #01, #01, &code_06A35A )
    COP [PrintWideString] ( &widestring_06A38D )
    RTL 
}

code_06A35A {
    LDA $24
    CMP #$FFFF
    BEQ loc_06A366
    COP [PrintWideString] ( &widestring_06A3E6 )
    RTL 

  loc_06A366:
    COP [PrintWideString] ( &widestring_06A3B8 )
    RTL 
}

widestring_06A36B `[DEF][TPL:3]Erik: [N]Heeeeelp!! [N]Someone save me! ![PAL:0][END]`

widestring_06A38D `[DEF][TPL:3]First, defuse the bomb![N]Hurry! Hurry![PAL:0][END]`

widestring_06A3B8 `[DEF][TPL:3]Erik: [N]Don't tell anyone that [N]Will's in disguise.[PAL:0][END]`

widestring_06A3E6 `[DEF][TPL:3]Erik: [N]Once again Will has [N]saved me...[PAL:0][END]`