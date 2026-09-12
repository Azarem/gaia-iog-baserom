---------------------------------------------

eu94_employee [
  actor-def < #15, #00, #10, {

  code_07CEFD:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07CF1A )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #06, #07, #07, #08, &code_07CF13 )
    RTL 
} >
]

code_07CF13 {
    COP [PrintDialogString] ( &dialogstring_07CF75 )
    COP [SetEntryContinue]
    RTL 
}

code_07CF1A {
    COP [PrintDialogString] ( &dialogstring_07CF1F )
    RTL 
}

dialogstring_07CF1F `[TPL:A][TPL:4]Company employee:[N]What?!![N]A child...[FIN]The old guys are talking[N]about work. Go[N]over there![END]`

dialogstring_07CF75 `[TPL:B][SFX:0][TPL:0]It sounds like they're[N]talking about work...[FIN][SFX:10][PAL:0]Man: I hear if I do [N]business with this [N]company, I can get [N]anything I want... [FIN][TPL:4]Company employee:[N]We can get anything.[N]Tea, fruit, even furs...[FIN]I can't say it out loud, [N]but workers, too...[PAL:0][END]`