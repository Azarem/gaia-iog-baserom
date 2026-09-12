---------------------------------------------

fr38_ashamed [
  actor-def < #02, #00, #10, {

  code_05BA54:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BA5D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BA5D {
    COP [PrintDialogString] ( &dialogstring_05BA62 )
    RTL 
}

dialogstring_05BA62 `[TPL:A]The upstairs is a mess...[N]I'm ashamed...[END]`