---------------------------------------------

h_it15_running_man [
  actor-def < #02, #00, #10, {

  code_04D781:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04D78A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D78A {
    COP [PrintWideString] ( &widestring_04D78F )
    RTL 
}

widestring_04D78F `[DEF]そこの坂を かけおりて[N]そのまま 走っていってごらん.[N]きっと びっくりするよ.[END]`