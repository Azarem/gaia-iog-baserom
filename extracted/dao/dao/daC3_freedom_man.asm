; Freedom movement NPC in Dao — mentions Rolek's role.
; 
; Says: "A freedom movement has started recently. The president
; of Rolek started the labor trade from this town."
; Connects the Rolek Company to the slavery subplot.
---------------------------------------------

---------------------------------------------

daC3_freedom_man [
  actor-def < #05, #00, #10, {

  code_08AB26:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08AB2F )
    COP [SetEntryHere]
    RTL 
} >
]

code_08AB2F {
    COP [PrintDialogString] ( &dialogstring_08AB34 )
    RTL 
}

dialogstring_08AB34 `[DEF]A freedom movement [N]has started recently. [FIN]The president of Rolek [N]started the labor trade [N]freedom movement. [END]`