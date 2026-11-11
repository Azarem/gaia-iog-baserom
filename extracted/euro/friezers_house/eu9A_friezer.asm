; Friezer in his Euro house (scene $9A).
; 
; $A7 set (the Mt. Kress entrance intro has played): the actor dies at spawn. Otherwise: 'I am the explorer, Friezer. I, too, plan on leaving my name in history as the discoverer of the Tower of Babel.'.
---------------------------------------------

---------------------------------------------

eu9A_friezer [
  actor-def < #0A, #00, #10, {

  code_07E607:
    COP [BranchOnFlagByte] ( #A7, #01, &eu9A_friezer_destroy )
    COP [SetInteractHandler] ( &code_07E618 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
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