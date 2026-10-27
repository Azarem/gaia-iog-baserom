---------------------------------------------

h_ec0A_stair_guard [
  actor-def < #1A, #00, #10, {

  code_04BE91:
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #21, #01, &code_04BEBA )
    COP [SetInteractHandler] ( &code_04BEC6 )
    COP [WaitOnFlagByte] ( #19, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_04BEBA {
    COP [SetInteractHandler] ( &code_04BED6 )
    LDA #$0200
    TSB $12
    COP [SetEntryHere]
    RTL 
}

code_04BEC6 {
    COP [BranchOnFlagByte] ( #19, #01, &code_04BED1 )
    COP [PrintDialogString] ( &dialogstring_04BEDB )
    RTL 
}

code_04BED1 {
    COP [PrintDialogString] ( &dialogstring_04BF0D )
    RTL 
}

code_04BED6 {
    COP [PrintDialogString] ( &dialogstring_04BF3A )
    RTL 
}

dialogstring_04BEDB `[DEF]エドワード国王は 朝食を[N]とられているところだ.[N]今しばらくしてから くるがよい.[END]`

dialogstring_04BF0D `[DEF]この先は えっけん室.[N]国王に会見するなら この階段を[N]登るがよい.[END]`

dialogstring_04BF3A `[DEF]うつら うつら···[END]`