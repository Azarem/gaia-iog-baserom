; Interactable hidden Red Jewel pickup actor.
; 
; Sets an on-interact handler that tests event flag $0200+actorID; on first pickup gives item #01 (Red Jewel) and shows found/full dialog, then sets the flag. Jumped into by native village and Euro mansion hidden-jewel actors. Reusable hidden collectible template placed in secret locations across the world.
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'spriteset_enemies'

---------------------------------------------

hidden_red_jewel [
  actor-def < #00, #00, #30, {

  code_00C672:
    COP [SetInteractHandler] ( &HiddenRedJewelInteract )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #00 )
    COP [SetEntryHere]
    RTL 
} >
]

HiddenRedJewelInteract {
    LDA $0E               ; Hidden jewel interact: test event flag $0200+actorIndex before GiveItem
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS loc_00C6A5
    COP [GiveItem] ( #01, &HiddenRedJewelInventoryFull )
    COP [PrintDialogString] ( &dialogstring_00C6A6 )
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@flag_helpers.SetEventFlag_0200
    RTL 
}

HiddenRedJewelInventoryFull {
    COP [PrintDialogString] ( &dialogstring_00C6BF )

  loc_00C6A5:
    RTL 
}

dialogstring_00C6A6 `[DLG:3,11][SIZ:D,3]You found a Red Jewel![END]`

dialogstring_00C6BF `[DLG:3,11][SIZ:D,3]You found a Jewel but[N]your inventory is full.[END]`