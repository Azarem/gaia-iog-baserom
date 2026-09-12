---------------------------------------------

eu92_erasquez [
  actor-def < #2D, #00, #10, {

  code_07D7A1:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D7AA )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07D7AA {
    COP [BranchIfNoItem] ( #19, &code_07D7C2 )
    COP [BranchIfFlagByte] ( #9F, #01, &code_07D7BD )
    COP [SetFlagByte] ( #9F )
    COP [PrintDialogString] ( &dialogstring_07D7C7 )
    RTL 
}

code_07D7BD {
    COP [PrintDialogString] ( &dialogstring_07D892 )
    RTL 
}

code_07D7C2 {
    COP [PrintDialogString] ( &dialogstring_07D8D2 )
    RTL 
}

dialogstring_07D7C7 `[TPL:B][TPL:4]Erasquez: Hey, you![N]I feel a strange power[N]coming from you...[FIN]My intuition is so[N]developed, I can sense[N]things even if I can't[N]see them.[FIN]At the right time, go to[N]Mt.Kress and take [N]a look at the Teapot. [FIN][TPL:0]Rofsky marked Mt.Kress [N]on Will's map![PAL:0][END]`

dialogstring_07D892 `[TPL:B][TPL:4]Erasquez: The spirits' [N]tears in the teapot [N]reflect your true form.[PAL:0][END]`

dialogstring_07D8D2 `[TPL:A][TPL:4]Erasquez: I feel the [N]presence of evil from [N]somewhere in town... [FIN]Maybe the townspeople[N]have been changed[N]into demons.[FIN]It may be someone in the[N]town square, or one[N]of your friends.[FIN]Use the Teapot on anyone[N]you suspect.[PAL:0][END]`