; Woman in the Adequacy Manor — apologizes for the mess.
; 
; Simple NPC. Says: "The upstairs is a mess... I'm ashamed..."
; One of the manor residents.
---------------------------------------------

---------------------------------------------

fr38_ashamed [
  actor-def < #02, #00, #10, {

  code_05BA54:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BA5D )
    COP [SetEntryHere]
    RTL 
} >
]

code_05BA5D {
    COP [PrintDialogString] ( &dialogstring_05BA62 )
    RTL 
}

dialogstring_05BA62 `[TPL:A]The upstairs is a mess...[N]I'm ashamed...[END]`