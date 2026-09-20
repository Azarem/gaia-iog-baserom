; Gold Ship deck crew member 1 — greets the "King" on arrival.
; 
; Simple solid NPC with interaction: "King! You're safe! Now we
; can set sail." The crew believes Will is their lost king.
---------------------------------------------

---------------------------------------------

gs2C_crew1 [
  actor-def < #02, #00, #10, {

  code_058252:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05825B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05825B {
    COP [PrintDialogString] ( &dialogstring_058260 )
    RTL 
}

dialogstring_058260 `[DEF]King! You're safe![N]Now we can set sail.[END]`