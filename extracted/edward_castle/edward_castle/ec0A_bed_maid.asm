; Castle maid NPC near the bedroom.
; 
; Single dialog about a hunter being hired by the King.
---------------------------------------------

---------------------------------------------

ec0A_bed_maid [
  actor-def < #25, #00, #10, {

  code_04C7B1:
    COP [SetInteractHandler] ( &code_04C7BA )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_04C7BA {
    COP [PrintDialogString] ( &dialogstring_04C7BF )
    RTL 
}

dialogstring_04C7BF `[DEF]Recently, a hunter was[N]hired.[N]I wonder what the King[N]is thinking...[END]`