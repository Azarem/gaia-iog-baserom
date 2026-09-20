; Kruk bird 2 in Dao — ambient animal.
; 
; Decorative NPC. Says: "Kiaaa... Kiaaa..." Second kruk
; for atmosphere.
---------------------------------------------

---------------------------------------------

daC3_kruk2 [
  actor-def < #1A, #00, #10, {

  code_08AC26:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08AC38 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AC38 {
    COP [PrintDialogString] ( &dialogstring_08AC3D )
    RTL 
}

dialogstring_08AC3D `[DEF]Kiaaa...Kiaaa...[END]`