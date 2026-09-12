?INCLUDE 'dm_actor_05D49E'

---------------------------------------------

dm47_imas [
  actor-def < #28, #00, #10, {

  code_05D091:
    COP [BranchIfFlagByte] ( #5E, #01, &dm47_imas_destroy )
    COP [SpawnAfterFlags] ( @dm_actor_05D49E, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D0BF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D0B6
    RTL 

  loc_05D0B6:
    COP [SetOnInteract] ( &code_05D0C4 )
    COP [SetEntryContinue]
    RTL 
} >
]

dm47_imas_destroy {
    COP [Die]
}

code_05D0BF {
    COP [PrintDialogString] ( &dialogstring_05D0C9 )
    RTL 
}

code_05D0C4 {
    COP [PrintDialogString] ( &dialogstring_05D0E3 )
    RTL 
}

dialogstring_05D0C9 `[DEF][TPL:5]Imas:[N]Cut the chain![PAL:0][END]`

dialogstring_05D0E3 `[DEF][TPL:5]Imas: Thank you. [N]All living things in our [N]home country have [N]grown strange. [FIN]People have turned to [N]stone. Some are sick [N]with unknown diseases...[PAL:0][END]`