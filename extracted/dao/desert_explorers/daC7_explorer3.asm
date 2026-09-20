; Desert explorer 3 — seeking the Pyramid treasure.
; 
; NPC: "We're explorers. I hear there's a treasure inside
; the Pyramid." Standard explorer motivation dialog.
---------------------------------------------

---------------------------------------------

daC7_explorer3 [
  actor-def < #04, #00, #10, {

  code_08AA9E:
    COP [SetInteractHandler] ( &code_08AAA7 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_08AAA7 {
    COP [PrintDialogString] ( &dialogstring_08AAAC )
    RTL 
}

dialogstring_08AAAC `[DEF]We're explorers. I hear[N]there's a treasure[N]inside the Pyramid...[END]`