---------------------------------------------

ec0A_caring_maid [
  actor-def < #25, #00, #10, {

  code_04C8E9:
    COP [AddPosition] ( #10, #00 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04C8F6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C8F6 {
    COP [PrintWideString] ( &widestring_04C8FB )
    RTL 
}

widestring_04C8FB `[TPL:B]Well, he's[N]shy...[FIN]I'm glad that somewhere[N]in the world there is[N]someone who is[N]thinking of me.[END]`