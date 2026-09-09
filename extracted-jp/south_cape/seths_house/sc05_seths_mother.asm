---------------------------------------------

h_sc05_seths_mother [
  actor-def < #14, #00, #10, {

  code_048FD2:
    COP [SetOnInteract] ( &code_048FDB )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048FDB {
    COP [PrintWideString] ( &widestring_048FE0 )
    RTL 
}

widestring_048FE0 `[TPL:B]モリスの母:[N]じょうだんじゃないわよっ![N]あの男っ![FIN]息子の モリスがいるから[N]がまんしてるけど[N]そうじゃなかったら あたしは[N]とっくに 别れてるわよっ![END]`