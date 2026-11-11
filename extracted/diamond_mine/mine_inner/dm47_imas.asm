; Imas — chained slave in the mine inner room (map $47).
; 
; Spawns as a chain prop (dm_mine_static_prop) with solid collision and dies at spawn when flag $5E is set (tested once, not waited on). Before the chain breaks (status bit $0040 of the prop) the interact handler says "Cut the chain!". After it breaks he says that his homeland has people turned to stone and sick with unknown diseases. One of three chained slaves with Remus and Sam; Sam's talk handler sets $5E when he gives the Memory Melody, not the freeing of the third slave.
---------------------------------------------

?INCLUDE 'dm_mine_static_prop'

---------------------------------------------

dm47_imas [
  actor-def < #28, #00, #10, {

  code_05D091:
    COP [BranchOnFlagByte] ( #5E, #01, &dm47_imas_destroy )
    COP [SpawnAfterFlags] ( @dm_mine_static_prop, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05D0BF )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D0B6
    RTL 

  loc_05D0B6:
    COP [SetInteractHandler] ( &code_05D0C4 )
    COP [SetEntryHere]
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