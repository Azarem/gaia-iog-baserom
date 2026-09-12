---------------------------------------------

sc01_sprint_man [
  actor-def < #02, #00, #10, {

  code_04922F:
    COP [SetOnInteract] ( &code_049238 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_049238 {
    COP [PrintDialogString] ( &dialogstring_04923D )
    RTL 
}

dialogstring_04923D `[DEF]You look like a fast[N]runner. To run, push the[N]Control Pad twice.[END]`