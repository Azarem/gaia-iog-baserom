---------------------------------------------

daC7_explorer1 [
  actor-def < #05, #00, #10, {

  code_08A991:
    COP [SetOnInteract] ( &code_08A99A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A99A {
    COP [PrintDialogString] ( &dialogstring_08A99F )
    RTL 
}

dialogstring_08A99F `[DEF]The Pyramid is made of[N]huge stones. Strange[N]that it doesn't sink[N]into the desert....[END]`