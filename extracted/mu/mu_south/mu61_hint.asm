; Lilly's hint in Mu south — thinking about the dungeon.
; 
; Lilly speaks from Will's pocket: "Will. I've been thinking..."
; Provides a gameplay hint for navigating the Mu dungeon.
; Uses the "speaks from pocket" framing for spirit companion.
---------------------------------------------

---------------------------------------------

mu61_hint [
  actor-def < #00, #00, #30, {

  code_0697A9:
    COP [BranchOnFlagByte] ( #7A, #01, &code_0697C7 )
    COP [BranchOnFlagByte] ( #78, #00, &code_0697C7 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0A, #30, #0C, #37, &code_0697C0 )
    RTL 
} >
]

code_0697C0 {
    COP [SetFlagByte] ( #7A )
    COP [PrintDialogString] ( &dialogstring_0697C9 )
}

code_0697C7 {
    COP [Die]
}

dialogstring_0697C9 `[DEF][TPL:2]Lilly speaks from[N]his pocket.[FIN][TPL:2]Lilly: Will. [N]I've been thinking... [FIN]It appears as if [N]the treasure chest is [N]in the exact spot where [FIN]the line of vision [N]between both the [N]statues cross. [FIN]I wonder if this is [N]suppose to mean [N]something? Maybe not?[PAL:0][END]`