---------------------------------------------

ec0A_door_guard [
  actor-def < #1C, #00, #10, {

  code_04C5CB:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04C5D4 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C5D4 {
    COP [PrintWideString] ( &widestring_04C5D9 )
    RTL 
}

widestring_04C5D9 `[DEF]Soldier: So you are [N]Will.[FIN]Sorry to have kept[N]you waiting. Let's go[N]see King Edward.[END]`