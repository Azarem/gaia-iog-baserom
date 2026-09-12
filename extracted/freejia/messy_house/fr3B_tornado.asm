---------------------------------------------

fr3B_tornado [
  actor-def < #02, #00, #10, {

  code_05BBF2:
    COP [SetOnInteract] ( &code_05BBFB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BBFB {
    COP [PrintDialogString] ( &dialogstring_05BC00 )
    RTL 
}

dialogstring_05BC00 `[TPL:A]It's not like a tornado [N]came through here. [FIN]Maybe you'd be more[N]comfortable in a place[N]not quite so neat?[END]`