?INCLUDE 'spriteset_npc_props'

---------------------------------------------

st68_campfire [
  actor-def < #08, #00, #18, {

  code_06AAB0:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AABC )
} >
]

code_list_06AABC [
  &code_06AAC2   ;00
  &code_06AAD3   ;01
  &code_06AAD3   ;02
]

code_06AAC2 {
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #08 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_06AAD3 {
    COP [Die]
}