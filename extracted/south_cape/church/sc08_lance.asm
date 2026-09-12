---------------------------------------------

sc08_lance [
  actor-def < #03, #00, #10, {

  code_048D24:
    COP [SetOnInteract] ( &code_048D35 )
    COP [BranchIfFlagByte] ( #10, #00, &code_048D30 )
    COP [Die]
} >
]

code_048D30 {
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_048D35 {
    COP [PrintDialogString] ( &dialogstring_048D3A )
    RTL 
}

dialogstring_048D3A `[TPL:B][TPL:4]Lance:[N]Like always, the cave[N]at the seashore![PAL:0][END]`