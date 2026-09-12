?INCLUDE 'chunk_008000'

---------------------------------------------

h_ec0A_right_guard [
  actor-def < #1C, #00, #10, {

  code_04BD67:
    COP [BranchIfFlagByte] ( #21, #01, &code_04BDA6 )
    COP [SetOnInteract] ( &code_04BDB1 )
    COP [StageSpriteLoopMoveX] ( #20, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #1B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [SetOnInteract] ( &code_04BDB6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04BDA6 {
    COP [SetTilePos] ( #38, #29 )
    COP [SetOnInteract] ( &code_04BDD6 )
    COP [SetEntryContinue]
    RTL 
}

code_04BDB1 {
    COP [PrintDialogString] ( &dialogstring_04BDDB )
    RTL 
}

code_04BDB6 {
    COP [BranchIfFlagByte] ( #D8, #01, &code_04BDD1 )
    COP [PrintDialogString] ( &dialogstring_04BE21 )
    COP [GiveItem] ( #01, &code_04BDCD )
    COP [PrintDialogString] ( &dialogstring_04BE45 )
    COP [SetFlagByte] ( #D8 )
    RTL 
}

code_04BDCD {
    JML $@chunk_008000.code_00C7E3
}

code_04BDD1 {
    COP [PrintDialogString] ( &dialogstring_04BE64 )
    RTL 
}

code_04BDD6 {
    COP [PrintDialogString] ( &dialogstring_04BE87 )
    RTL 
}

dialogstring_04BDDB `[TPL:B]ここは エドワード国王の城.[N]くれぐれも そそうのないようにな.[N]それでなくても 国王は きびしい[N]お方 なんだから.[END]`

dialogstring_04BE21 `[TPL:9]しっ. 声をたてるなよ.[N]さぼっているのが バレるだろっ.[FIN]`

dialogstring_04BE45 `そのかわり 君には 赤い宝石を[N]ーつ あげるから.[END]`

dialogstring_04BE64 `[TPL:9]しっ. 声をたてるなよ.[N]さぼっているのが バレるだろっ.[END]`

dialogstring_04BE87 `[TPL:8]すぅすぅ[END]`