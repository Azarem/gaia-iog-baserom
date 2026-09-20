; Freed ship crew member — tells about the Queen's ring.
; 
; Solid NPC. Dialog describes the Queen still wearing the ring
; from the King: "Since then, she has thought of nothing but him."
; Establishes the King/Queen relationship backstory.
---------------------------------------------

---------------------------------------------

gs2E_crew1 [
  actor-def < #0C, #00, #10, {

  code_058830:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058839 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058839 {
    COP [PrintDialogString] ( &dialogstring_05883E )
    RTL 
}

dialogstring_05883E `[TPL:A]The Queen is still[N]wearing the ring she[N]got from the King.[FIN]That's right.[FIN]It's the ring he gave her[N]when they were separated[N]by the invaders.[FIN]Since then, she has [N]thought of nothing [N]but him. [END]`