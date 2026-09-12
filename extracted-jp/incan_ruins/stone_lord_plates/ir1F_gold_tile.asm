?INCLUDE 'chunk_008000'

---------------------------------------------

h_ir1F_gold_tile [
  actor-def < #00, #00, #23, {

  code_058003:
    COP [BranchIfFlagByte] ( #3C, #01, &code_058053 )
    COP [AddPosition] ( #08, #08 )
} >
]

code_05800D {
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_058033 )
    COP [BranchIfActorNear] ( #02, #01, &code_05804C )
    COP [BranchIfActorNear] ( #03, #01, &code_05804C )
    COP [BranchIfActorNear] ( #04, #01, &code_05804C )
    COP [BranchIfActorNear] ( #05, #01, &code_05804C )
    LDA $0E
    JSL $@chunk_008000.code_00B573
    RTL 
}

code_058033 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_058040 )
    COP [PrintDialogString] ( &dialogstring_058055 )
    COP [SetFlagByte] ( #0F )
}

code_058040 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_05804C )
    COP [SetEntryExitNow] ( @code_05800D )
}

code_05804C {
    LDA $0E
    JSL $@chunk_008000.code_00B56C
    RTL 
}

code_058053 {
    COP [Die]
}

dialogstring_058055 `[DEF]この 黄金のユカを ふむと[N]何か 音がするようだ···[FIN]黄金のユカは 4つ····[N]何か 重りにできるものは[N]ないだろうか···[END]`