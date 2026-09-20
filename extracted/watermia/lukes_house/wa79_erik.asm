; Erik at Luke's house in Watermia — found something behind the house.
; 
; NPC. Says: "Heh heh. I've found something good. Go outside
; and look behind the house." Hints at a hidden item or
; secret area accessible from behind the building.
---------------------------------------------

---------------------------------------------

wa79_erik [
  actor-def < #0A, #00, #10, {

  code_07A42B:
    COP [BranchIfFlagByte] ( #94, #01, &code_07A44A )
    COP [BranchIfFlagByte] ( #97, #01, &code_07A459 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A44C )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07A466 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A44A {
    COP [Die]
}

code_07A44C {
    COP [SetTilePos] ( #05, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A46B )
    COP [SetEntryContinue]
    RTL 
}

code_07A459 {
    COP [SetTilePos] ( #05, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A470 )
    COP [SetEntryContinue]
    RTL 
}

code_07A466 {
    COP [PrintDialogString] ( &dialogstring_07A475 )
    RTL 
}

code_07A46B {
    COP [PrintDialogString] ( &dialogstring_07A4C8 )
    RTL 
}

code_07A470 {
    COP [PrintDialogString] ( &dialogstring_07A506 )
    RTL 
}

dialogstring_07A475 `[TPL:A][TPL:3]Erik: Heh heh. I've [N]found something good. [FIN]Go outside and look [N]behind the house. I feel [N]a little guilty, but ...[END]`

dialogstring_07A4C8 `[TPL:A][TPL:3]Erik: There is a full[N]moon tonight. The [N]village seems different.[PAL:0][END]`

dialogstring_07A506 `[TPL:A][TPL:3]Erik: I wish Lance [N]and Lilly were coming,[N]too...[PAL:0][END]`