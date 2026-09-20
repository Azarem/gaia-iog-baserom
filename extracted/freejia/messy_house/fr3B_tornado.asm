; Messy house resident — humorous dialog about the mess.
; 
; NPC in a cluttered house. Says: "It's not like a tornado came
; through here. Maybe you'd be more comfortable elsewhere."
; Light humor scene.
---------------------------------------------

---------------------------------------------

fr3B_tornado [
  actor-def < #02, #00, #10, {

  code_05BBF2:
    COP [SetInteractHandler] ( &code_05BBFB )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05BBFB {
    COP [PrintDialogString] ( &dialogstring_05BC00 )
    RTL 
}

dialogstring_05BC00 `[TPL:A]It's not like a tornado [N]came through here. [FIN]Maybe you'd be more[N]comfortable in a place[N]not quite so neat?[END]`