?INCLUDE 'interaction_handlers'

---------------------------------------------

ec0E_statue [
  actor-def < #36, #00, #10, {

  code_0A8838:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #21, #00, &code_0A8847 )
    COP [SetOnInteract] ( &code_0A8853 )
} >
]

code_0A8847 {
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0A8853 {
    COP [PrintDialogString] ( &dialogstring_0A8858 )
    RTL 
}

dialogstring_0A8858 `[DLG:3,11][SIZ:D,4][TPL:0]This has the same shape[N]as the statue from the[N]seaside cave...[PAL:0][END]`