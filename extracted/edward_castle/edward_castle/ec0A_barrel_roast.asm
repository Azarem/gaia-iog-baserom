?INCLUDE 'f_inventory_full'

!displayModeFlags               09EC

---------------------------------------------

ec0A_barrel_roast [
  actor-def < #00, #00, #30, {

  code_04D0D6:
    COP [AddPosition] ( #08, #01 )
    COP [BranchIfFlagByte] ( #46, #01, &code_04D0FF )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_04D0FA )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #22, #37, #26, #3D, &code_04D0F3 )
    RTL 
} >
]

code_04D0F3 {
    COP [PrintWideString] ( &widestring_04D114 )
    COP [SetEntryContinue]
    RTL 
}

code_04D0FA {
    COP [GiveItem] ( #0A, &code_04D110 )
}

code_04D0FF {
    COP [SetFlagByte] ( #46 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @widestring_04D141 )
    COP [Die]
}

code_04D110 {
    JML $@f_inventory_full.InventoryFullMessage
}

widestring_04D114 `[TPL:A][TPL:1]Kara: [N]I think someone put food[N]in one of these barrels.[PAL:0][END]`

widestring_04D141 `[DEF][SFX:0][DLY:9]You've found a large,[N]yummy roast leg of yak![PAU:FF][FIN][DLY:1][TPL:1]Kara: [N]Everything's ready![N]Let's go before the[N]soldiers find us![PAL:0][END]`