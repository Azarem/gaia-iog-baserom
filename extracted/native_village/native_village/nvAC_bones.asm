?INCLUDE 'spriteset_npc_props'

---------------------------------------------

nvAC_bones [
  actor-def < #00, #01, #10, {

  code_088003:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08801B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08801B {
    COP [PrintDialogString] ( &dialogstring_088020 )
    RTL 
}

dialogstring_088020 `[DEF][TPL:0]They're not weathered[N]yet... Only recently[N]bleached white.[PAL:0][END]`