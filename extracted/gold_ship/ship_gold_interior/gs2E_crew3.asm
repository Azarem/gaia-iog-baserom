; Freed ship crew member — laments the invasion.
; 
; Simple solid NPC. Dialog: "Why must we flee? It is our home."
; Reflects on being driven from their homeland by invaders.
---------------------------------------------

---------------------------------------------

gs2E_crew3 [
  actor-def < #15, #00, #10, {

  code_0589CD:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_0589D6 )
    COP [SetEntryHere]
    RTL 
} >
]

code_0589D6 {
    COP [PrintDialogString] ( &dialogstring_0589DB )
    RTL 
}

dialogstring_0589DB `[TPL:A]Why must[N]we flee? It is[N]our home.[END]`