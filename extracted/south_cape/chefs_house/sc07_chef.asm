; Chef's house NPC in South Cape.
; 
; Single dialog about cooking in a pot since there is no stove.
---------------------------------------------

---------------------------------------------

sc07_chef [
  actor-def < #05, #00, #10, {

  code_0491DF:
    COP [SetInteractHandler] ( &code_0491E8 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_0491E8 {
    COP [PrintDialogString] ( &dialogstring_0491ED )
    RTL 
}

dialogstring_0491ED `[TPL:A]Mmmm, nice smell.[N]There's no stove, so[N]I'm cooking in this pot.[END]`