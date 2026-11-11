; Rudy, Friezer's companion (scene $9A).
; 
; $A7 set: the actor dies at spawn. Otherwise: 'The ruins are a great place. They just take my breath away.'.
---------------------------------------------

---------------------------------------------

eu9A_rudy [
  actor-def < #04, #00, #10, {

  code_07E716:
    COP [BranchOnFlagByte] ( #A7, #01, &eu9A_rudy_destroy )
    COP [SetInteractHandler] ( &code_07E725 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_07E725 {
    COP [PrintDialogString] ( &dialogstring_07E72A )
    RTL 
}

dialogstring_07E72A `[DEF]Rudy: The ruins are a[N]great place. They just[N]take my breath away.[END]`
---------------------------------------------

eu9A_rudy_destroy {
    COP [Die]
}