---------------------------------------------

h_sc04_eriks_father [
  actor-def < #03, #00, #10, {

  code_048ED9:
    COP [SetOnInteract] ( &code_048EE2 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048EE2 {
    COP [PrintDialogString] ( &dialogstring_048EE7 )
    RTL 
}

dialogstring_048EE7 `[DEF]エリックの父:[N]みんな この 大きな家を[N]うらやましがる···[FIN]だが なんのことは ないのだよ.[N]うちは みんなより ちょっと早く[N]この町へ ひっこしてきただけ[N]なのさ.[END]`