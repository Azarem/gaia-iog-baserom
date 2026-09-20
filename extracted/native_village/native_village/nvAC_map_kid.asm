; Map-drawing child — shows the temple location.
; 
; Interactive NPC (~64 lines). "The boy points to the northeast...
; Show him the map? Yes/No" On Yes: "He drew a picture of the
; temple on the map!" Non-verbal exchange that adds the
; Angkor Wat temple to the player's world map.
---------------------------------------------

---------------------------------------------

nvAC_map_kid [
  actor-def < #24, #00, #18, {

  code_088F8B:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088FC2 )
    COP [SetOnInteract] ( &code_088FC4 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #26, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_088FC2 {
    COP [Die]
}

code_088FC4 {
    COP [PrintDialogString] ( &dialogstring_088FE1 )
    COP [DialogueOptions] ( #02, #01, &code_list_088FCE )
}

code_list_088FCE [
  &code_088FD4   ;00
  &code_088FD9   ;01
  &code_088FD4   ;02
]

code_088FD4 {
    COP [PrintDialogString] ( &dialogstring_089078 )
    RTL 
}

code_088FD9 {
    COP [PrintDialogString] ( &dialogstring_08901E )
    COP [SetFlagByte] ( #B1 )
    RTL 
}

dialogstring_088FE1 `[TPL:E]The boy points to[N]the northeast...[FIN]Show him the map?[N] Yes[N] No`

dialogstring_08901E `[CLR]He drew a picture of the[N]temple on the map![FIN]I think he's saying[N]he wants to go to[N]the temple...[PAL:0][END]`

dialogstring_089078 `[CLR]He looks lonely...[PAL:0][END]`