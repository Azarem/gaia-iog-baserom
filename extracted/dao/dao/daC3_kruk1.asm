; Kruk bird 1 in Dao — ambient animal.
; 
; Decorative NPC. Says: "Kiaaa... Kiaaa..." Simple bird
; call for the desert town atmosphere.
---------------------------------------------

---------------------------------------------

daC3_kruk1 [
  actor-def < #1A, #00, #10, {

  code_08ABFA:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08AC0C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AC0C {
    COP [PrintDialogString] ( &dialogstring_08AC11 )
    RTL 
}

dialogstring_08AC11 `[DEF]Kiaaa...Kiaaa...[END]`