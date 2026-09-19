; Grandpa Bill NPC in Itory Village.
; 
; Multi-state dialog: initially directs Will to the Elder,
; later asks about the Red Jewel from Edward Castle.
---------------------------------------------

---------------------------------------------

it15_bill [
  actor-def < #2A, #00, #10, {

  code_04EF77:
    COP [SetOnInteract] ( &code_04EFA4 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #47, #01, &code_04EF9E )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04EF9B )
    COP [ExitIfFlagByte] ( #3B, #01 )
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
} >
]

code_04EF9B {
    COP [SetEntryContinue]
    RTL 
}

code_04EF9E {
    COP [SetOnInteract] ( &code_04EFA9 )
    BRA code_04EF9B
}

code_04EFA4 {
    COP [PrintDialogString] ( &dialogstring_04EFAE )
    RTL 
}

code_04EFA9 {
    COP [PrintDialogString] ( &dialogstring_04EFDF )
    RTL 
}

dialogstring_04EFAE `[DEF][TPL:4]Bill:[N]Meet with the Elder.[N]He knows something.[PAL:0][END]`

dialogstring_04EFDF `[DEF][TPL:4]Bill: How is the [N]Elder? [FIN]When you fought the [N]demon at Edward Castle, [N]did you find a shiny [N]silver stone? [FIN]There's a strange power[N]in that stone.[FIN]Even if defeated by an[N]enemy, if you have[N]100 of them, you[N]will live again.[PAL:0][END]`