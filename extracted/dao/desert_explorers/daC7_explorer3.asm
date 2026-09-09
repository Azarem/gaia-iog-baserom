---------------------------------------------

daC7_explorer3 [
  actor-def < #04, #00, #10, {

  code_08AA9E:
    COP [SetOnInteract] ( &code_08AAA7 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08AAA7 {
    COP [PrintWideString] ( &widestring_08AAAC )
    RTL 
}

widestring_08AAAC `[DEF]We're explorers. I hear[N]there's a treasure[N]inside the Pyramid...[END]`