; Carpet merchant NPC in Dao — town exposition.
; 
; Says: "This town is famous for spices and carpet. It's said
; the carpets of Edward Castle took 40 years to weave."
; Establishes Dao's cultural identity as a trade hub.
---------------------------------------------

---------------------------------------------

daC3_carpet_man [
  actor-def < #04, #00, #10, {

  code_08AB8B:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08AB94 )
    COP [SetEntryHere]
    RTL 
} >
]

code_08AB94 {
    COP [PrintDialogString] ( &dialogstring_08AB99 )
    RTL 
}

dialogstring_08AB99 `[DEF]This town is famous for[N]spices and carpet.[FIN]It's said the carpets[N]of Edward Castle took[N]40 years to weave here.[END]`