---------------------------------------------

eu9A_friezer [
  actor-def < #0A, #00, #10, {

  code_07E607:
    COP [BranchIfFlagByte] ( #A7, #01, &eu9A_friezer_destroy )
    COP [SetOnInteract] ( &code_07E618 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

eu9A_friezer_destroy {
    COP [Die]
}

code_07E618 {
    COP [PrintDialogString] ( &dialogstring_07E61D )
    RTL 
}

dialogstring_07E61D `[DEF]Friezer: I am the [N]explorer, Friezer.[FIN]I, too, plan on leaving[N]my name in history[N]as the discoverer [N]of the Tower of Babel.[END]`