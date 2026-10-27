---------------------------------------------

h_it18_warning_woman [
  actor-def < #0C, #00, #10, {

  code_04D7BE:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04D7C7 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04D7C7 {
    COP [PrintDialogString] ( &dialogstring_04D7CC )
    RTL 
}

dialogstring_04D7CC `[TPL:A]遺跡は 古代人たちの おはか.[N]なぜ そっとしておいて[N]あげないのでしょう···[END]`