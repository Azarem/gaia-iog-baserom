---------------------------------------------

it15_running_man [
  actor-def < #02, #00, #10, {

  code_04DE24:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04DE2D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DE2D {
    COP [PrintWideString] ( &widestring_04DE32 )
    RTL 
}

widestring_04DE32 `[DEF]Try running down that[N]hill, and keep running.[N]You'll be surprised.[END]`