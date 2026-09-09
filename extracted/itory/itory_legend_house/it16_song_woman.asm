---------------------------------------------

it16_song_woman [
  actor-def < #0A, #00, #10, {

  code_04DF88:
    COP [SetOnInteract] ( &code_04DF91 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DF91 {
    COP [PrintWideString] ( &widestring_04DF96 )
    RTL 
}

widestring_04DF96 `[DEF]The Incas who lived here[N]were a tribe without[N]a written language.[FIN]Their legends are[N]left in song.[FIN]Even in seemingly[N]meaningless melodies,[N]there is a message.[END]`