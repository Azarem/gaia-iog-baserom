; Stairway maid NPC in Edward Castle.
; 
; Two-state dialog: initially warns Will about the King, later
; asks Will to take care of Kara during the escape.
---------------------------------------------

---------------------------------------------

ec0A_stair_maid [
  actor-def < #24, #00, #10, {

  code_04C7FF:
    COP [SetInteractHandler] ( &code_04C808 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_04C808 {
    COP [BranchOnFlagByte] ( #21, #01, &code_04C813 )
    COP [PrintDialogString] ( &dialogstring_04C818 )
    RTL 
}

code_04C813 {
    COP [PrintDialogString] ( &dialogstring_04C85A )
    RTL 
}

dialogstring_04C818 `[DEF]So you're Will.[N]You were summoned by[N]King Edward?[FIN]Be careful when you[N]meet with him.[END]`

dialogstring_04C85A `[DEF]Are you going to take [N]Kara out of the castle?[FIN]Don't let the King find[N]you... Please take [N]care of the Princess.[END]`