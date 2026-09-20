; Ground object hint on Larai Cliff — gold statue clue.
; 
; Solid interactable prop. When examined: "There's something on the
; ground there... If I can move that gold statue, I can pass..."
; Hints that the player needs to push the gold statue to proceed.
---------------------------------------------

---------------------------------------------

ir1D_bones [
  actor-def < #2E, #01, #10, {

  code_09C272:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09C280 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09C280 {
    COP [PrintDialogString] ( &dialogstring_09C285 )
    RTL 
}

dialogstring_09C285 `[DEF][TPL:0]There's something on the[N]ground there...[FIN][PAL:0]If I can move that gold [N]statue, I can pass... [END]`