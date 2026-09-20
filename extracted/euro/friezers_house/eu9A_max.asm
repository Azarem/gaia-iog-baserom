; Max (Friezer's companion) — nervous about the next expedition.
; 
; NPC: "I wonder where you're taking us exploring this time...
; I'm afraid it might be dangerous." Shows the team's dynamic.
---------------------------------------------

---------------------------------------------

eu9A_max [
  actor-def < #05, #00, #10, {

  code_07E699:
    COP [BranchIfFlagByte] ( #A7, #01, &eu9A_max_destroy )
    COP [SetOnInteract] ( &code_07E6A8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E6A8 {
    COP [PrintDialogString] ( &dialogstring_07E6AD )
    RTL 
}

dialogstring_07E6AD `[DEF]Max: I wonder where[N]you're taking us[N]exploring this time...[FIN]I'm afraid it's up to[N]the whims of the[N]captain. Heh heh.[END]`
---------------------------------------------

eu9A_max_destroy {
    COP [Die]
}