---------------------------------------------

eu9A_rudy [
  actor-def < #04, #00, #10, {

  code_07E716:
    COP [BranchIfFlagByte] ( #A7, #01, &eu9A_rudy_destroy )
    COP [SetOnInteract] ( &code_07E725 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E725 {
    COP [PrintWideString] ( &widestring_07E72A )
    RTL 
}

widestring_07E72A `[DEF]Rudy: The ruins are a[N]great place. They just[N]take my breath away.[END]`
---------------------------------------------

eu9A_rudy_destroy {
    COP [Die]
}