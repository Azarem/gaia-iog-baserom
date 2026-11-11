; Statue actor in the aqueduct lockway: always a solid push block (MarkSolidHere, push_handler_solid child). With $21 set the first block also stores the inspect handler as chatPtr and then falls through into the same solid-and-push code, so the statue stays solid and pushable and can also be inspected.
; 
; Will recognizes the statue as similar to the one from the
; coastal cave.
---------------------------------------------

?INCLUDE 'interaction_handlers'

---------------------------------------------

ec0E_statue [
  actor-def < #36, #00, #10, {

  code_0A8838:
    LDA #$0200
    TSB $12
    COP [BranchOnFlagByte] ( #21, #00, &code_0A8847 )
    COP [SetInteractHandler] ( &code_0A8853 )
} >
]

code_0A8847 {
    COP [MarkSolidHere]
    COP [SpawnAfterMarked] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SetEntryHere]
    RTL 
}

code_0A8853 {
    COP [PrintDialogString] ( &dialogstring_0A8858 )
    RTL 
}

dialogstring_0A8858 `[DLG:3,11][SIZ:D,4][TPL:0]This has the same shape[N]as the statue from the[N]seaside cave...[PAL:0][END]`