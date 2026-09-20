; Desert explorer 1 — marvels at the Pyramid's construction.
; 
; NPC: "The Pyramid is made of huge stones. Strange that it
; doesn't sink into the desert." Flavor dialog about the
; Pyramid's engineering mystery.
---------------------------------------------

---------------------------------------------

daC7_explorer1 [
  actor-def < #05, #00, #10, {

  code_08A991:
    COP [SetOnInteract] ( &code_08A99A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A99A {
    COP [PrintDialogString] ( &dialogstring_08A99F )
    RTL 
}

dialogstring_08A99F `[DEF]The Pyramid is made of[N]huge stones. Strange[N]that it doesn't sink[N]into the desert....[END]`