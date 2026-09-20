; Itory Village NPC who hints about the slope dash.
; 
; Tutorial dialog suggesting Will run down the hill for a surprise.
---------------------------------------------

---------------------------------------------

it15_running_man [
  actor-def < #02, #00, #10, {

  code_04DE24:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04DE2D )
    COP [SetEntryHere]
    RTL 
} >
]

code_04DE2D {
    COP [PrintDialogString] ( &dialogstring_04DE32 )
    RTL 
}

dialogstring_04DE32 `[DEF]Try running down that[N]hill, and keep running.[N]You'll be surprised.[END]`