---------------------------------------------

eu91_shop_door [
  actor-def < #00, #00, #20, {

  loc_07D5D8:
    COP [SetEntryContinue]
    COP [BranchIfSolid] ( &code_07D5DF )
    RTL 
} >
]

code_07D5DF {
    COP [WaitWord] ( #$0707 )
    COP [ClearLowHere]
    BRA loc_07D5D8
}