---------------------------------------------

daC3_jackal_girl [
  actor-def < #14, #00, #10, {

  code_08ACC8:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08ACD1 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08ACD1 {
    COP [PrintWideString] ( &widestring_08ACE0 )
    COP [WriteApuIo0] ( #7F )
    COP [PrintWideString] ( &widestring_08AD0C )
    COP [WriteApuIo0] ( #01 )
    RTL 
}

widestring_08ACE0 `[DEF]The girl silently offers[N]one sheet of paper.[FIN]`

widestring_08AD0C `[CLR][DLY:4]There was a picture [N]of a jackal! [FIN][DLY:0][TPL:0]A shiver ran down my [N]spine. It was a warning [N]from the Jackal, who had[N]been stalking us....[PAL:0][END]`