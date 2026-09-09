---------------------------------------------

daC7_explorer2 [
  actor-def < #02, #00, #10, {

  code_08A9E0:
    COP [SetOnInteract] ( &code_08A9E9 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A9E9 {
    COP [PrintWideString] ( &widestring_08A9EE )
    RTL 
}

widestring_08A9EE `[DEF]There's a strange legend[N]around here.[FIN]"The Pyramid is not for[N] the living. Only those[N] who've transcended the[N] body may enter.ˮ[FIN]These are the words...[N]The Pyramid is a big[N]tomb. The living can't[N]go in? Hmmm...[END]`