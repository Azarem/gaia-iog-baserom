---------------------------------------------

h_it18_warning_woman [
  actor-def < #0C, #00, #10, {

  code_04D7BE:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04D7C7 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D7C7 {
    COP [PrintWideString] ( &widestring_04D7CC )
    RTL 
}

widestring_04D7CC `[TPL:A]遺跡は 古代人たちの おはか.[N]なぜ そっとしておいて[N]あげないのでしょう···[END]`