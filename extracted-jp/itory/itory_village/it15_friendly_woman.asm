---------------------------------------------

h_it15_friendly_woman [
  actor-def < #0A, #00, #10, {

  code_04D945:
    COP [SetOnInteract] ( &code_04D94E )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D94E {
    COP [PrintDialogString] ( &dialogstring_04D953 )
    RTL 
}

dialogstring_04D953 `[DEF]この村には リリィと 同い年[N]くらいの子が いないのよ.[N]なかよくしてやってね.[END]`