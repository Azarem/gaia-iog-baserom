; Shop door in Euro — access point to interior.
; 
; Interactive door that transitions to a shop interior.
; Standard door mechanic with flag-based open/close state.
---------------------------------------------

---------------------------------------------

eu91_shop_door [
  actor-def < #00, #00, #20, {

  loc_07D5D8:
    COP [SetEntryHere]
    COP [BranchIfSolidHere] ( &code_07D5DF )
    RTL 
} >
]

code_07D5DF {
    COP [WaitWord] ( #$0707 )
    COP [ClearSolidHere]
    BRA loc_07D5D8
}