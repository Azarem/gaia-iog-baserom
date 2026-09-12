---------------------------------------------

h_ec0A_caring_maid [
  actor-def < #25, #00, #10, {

  code_04C42D:
    COP [AddPosition] ( #10, #00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04C43A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C43A {
    COP [PrintDialogString] ( &dialogstring_04C43F )
    RTL 
}

dialogstring_04C43F `[TPL:B]まあ この人ったら[N]てれちゃって···[FIN]でも 世界中のどこかには 必ず[N]自分を 思ってくれている人が[N]いるものなのね···.[END]`