; Life Medicine vendor in the Euro flea market.
; 
; Interactive NPC: "This is Life Medicine. Try some? Yes/No"
; Offers healing medicine with purchase choice.
---------------------------------------------

!playerMaxHp                    0ACA
!playerHp                       0ACE

---------------------------------------------

eu97_life_medicine [
  actor-def < #00, #00, #30, {

  code_07CCF6:
    COP [NudgePosition] ( #08, #00 )
    COP [SpawnAfterOffsetMarked] ( @code_07CDD4, #00, #EC, #$1000 )
    COP [SetInteractHandler] ( &code_07CD0A )
    COP [SetEntryHere]
    RTL 
} >
]

code_07CD0A {
    COP [BranchOnFlagByte] ( #F0, #01, &code_07CD34 )
    COP [PrintDialogString] ( &dialogstring_07CD39 )
    COP [DialogueOptions] ( #02, #02, &code_list_07CD1A )
}

code_list_07CD1A [
  &code_07CD20   ;00
  &code_07CD25   ;01
  &code_07CD20   ;02
]

code_07CD20 {
    COP [PrintDialogString] ( &dialogstring_07CD9B )
    RTL 
}

code_07CD25 {
    COP [SetFlagByte] ( #F0 )
    INC $playerMaxHp
    INC $playerHp
    COP [PrintDialogString] ( &dialogstring_07CD64 )
    COP [Die]
}

code_07CD34 {
    COP [PrintDialogString] ( &dialogstring_07CDB3 )
    RTL 
}

dialogstring_07CD39 `[DEF]This is Life Medicine.[N]Try some?[N] Yes[N] No`

dialogstring_07CD64 `[CLR][TPL:0]That taste makes my[N]mouth pucker.[FIN]Your power is increased![END]`

dialogstring_07CD9B `[CLR]Really....[N]Don't you like it?[END]`

dialogstring_07CDB3 `[DEF]I'm sorry...[N]One to a customer.[END]`

code_07CDD4 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    RTL 
}