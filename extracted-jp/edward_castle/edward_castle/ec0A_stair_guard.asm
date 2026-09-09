---------------------------------------------

h_ec0A_stair_guard [
  actor-def < #1A, #00, #10, {

  code_04BE91:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #21, #01, &code_04BEBA )
    COP [SetOnInteract] ( &code_04BEC6 )
    COP [ExitIfFlagByte] ( #19, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04BEBA {
    COP [SetOnInteract] ( &code_04BED6 )
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    RTL 
}

code_04BEC6 {
    COP [BranchIfFlagByte] ( #19, #01, &code_04BED1 )
    COP [PrintWideString] ( &widestring_04BEDB )
    RTL 
}

code_04BED1 {
    COP [PrintWideString] ( &widestring_04BF0D )
    RTL 
}

code_04BED6 {
    COP [PrintWideString] ( &widestring_04BF3A )
    RTL 
}

widestring_04BEDB `[DEF]エドワード国王は 朝食を[N]とられているところだ.[N]今しばらくしてから くるがよい.[END]`

widestring_04BF0D `[DEF]この先は えっけん室.[N]国王に会見するなら この階段を[N]登るがよい.[END]`

widestring_04BF3A `[DEF]うつら うつら···[END]`