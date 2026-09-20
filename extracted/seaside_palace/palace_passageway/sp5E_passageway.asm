; Passageway discovery in the Seaside Palace.
; 
; Lilly speaks from pocket: "A passageway... I wonder if it
; goes clear to Mu?" Reveals a connection between the
; palace and Mu. Links the two underwater locations.
---------------------------------------------

---------------------------------------------

sp5E_passageway [
  actor-def < #00, #00, #30, {

  code_069739:
    COP [BranchOnFlagByte] ( #7D, #01, &code_069751 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #14, #08, #16, #0C, &code_06974A )
    RTL 
} >
]

code_06974A {
    COP [SetFlagByte] ( #7D )
    COP [PrintDialogString] ( &dialogstring_069753 )
}

code_069751 {
    COP [Die]
}

dialogstring_069753 `[TPL:A][TPL:2]Lilly speaks from[N]his pocket.[FIN][TPL:2]Lilly: A passageway... [N]I wonder if it goes [N]clear to Mu? [PAL:0][END]`