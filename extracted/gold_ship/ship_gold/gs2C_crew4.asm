---------------------------------------------

gs2C_crew4 [
  actor-def < #02, #00, #10, {

  code_058386:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05838F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05838F {
    COP [PrintDialogString] ( &dialogstring_058394 )
    RTL 
}

dialogstring_058394 `[DEF]It's the King![N]You're safe![FIN][::][TPL:0]Will: [N](I'm the King???)[PAL:0][END]`