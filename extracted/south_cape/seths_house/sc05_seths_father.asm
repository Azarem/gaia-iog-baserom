; Seth's father NPC -- one side of the arguing parents.
; 
; Dialog about spending money. Part of the fighting-parents theme
; that drives Seth's character.
---------------------------------------------

---------------------------------------------

sc05_seths_father [
  actor-def < #05, #00, #10, {

  code_049185:
    COP [SetOnInteract] ( &code_04918E )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04918E {
    COP [PrintDialogString] ( &dialogstring_049193 )
    RTL 
}

dialogstring_049193 `[TPL:B]Seth's father:[N]What's wrong with[N]having a little fun with[N]my hard-earned money!![END]`