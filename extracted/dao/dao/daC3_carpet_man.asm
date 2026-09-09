---------------------------------------------

daC3_carpet_man [
  actor-def < #04, #00, #10, {

  code_08AB8B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AB94 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08AB94 {
    COP [PrintWideString] ( &widestring_08AB99 )
    RTL 
}

widestring_08AB99 `[DEF]This town is famous for[N]spices and carpet.[FIN]It's said the carpets[N]of Edward Castle took[N]40 years to weave here.[END]`