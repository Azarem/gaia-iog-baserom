; Barrel with the yak roast in Edward Castle (scene $0A, scene_actors row 13 at tile (28,3B)).
; 
; Flag $46 set at spawn: the script jumps into code_04D0FF, which sets $46 again, sets displayModeFlags bit $80, plays MusicAndText #17 ('You've found a large, yummy roast leg of yak!' and Kara's 'Everything's ready!') and dies; as written the pickup message therefore replays whenever the scene loads with $46 set (not watched in the emulator).
; 
; $46 clear: waits for scratch $01 (set by the Kara-door guard's talk before the throne scene and by Kara's talk after it, so the barrel is not gated on $21), then installs the talk handler: GiveItem #0A (inventory full: InventoryFullMessage and the flag stays clear), then the code_04D0FF path. A tile trigger at (22,37)-(26,3D) prints Kara's hint 'I think someone put food in one of these barrels.' The escape in ec0A_kara tests the item (BranchIfHasItem #0A), not $46.
---------------------------------------------

?INCLUDE 'f_inventory_full'

!displayModeFlags               09EC

---------------------------------------------

ec0A_barrel_roast [
  actor-def < #00, #00, #30, {

  code_04D0D6:
    COP [NudgePosition] ( #08, #01 )
    COP [BranchOnFlagByte] ( #46, #01, &code_04D0FF )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [SetInteractHandler] ( &code_04D0FA )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #22, #37, #26, #3D, &code_04D0F3 )
    RTL 
} >
]

code_04D0F3 {
    COP [PrintDialogString] ( &dialogstring_04D114 )
    COP [SetEntryHere]
    RTL 
}

code_04D0FA {
    COP [GiveItem] ( #0A, &code_04D110 )
}

code_04D0FF {
    COP [SetFlagByte] ( #46 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_04D141 )
    COP [Die]
}

code_04D110 {
    JML $@f_inventory_full.InventoryFullMessage
}

dialogstring_04D114 `[TPL:A][TPL:1]Kara: [N]I think someone put food[N]in one of these barrels.[PAL:0][END]`

dialogstring_04D141 `[DEF][SFX:0][DLY:9]You've found a large,[N]yummy roast leg of yak![PAU:FF][FIN][DLY:1][TPL:1]Kara: [N]Everything's ready![N]Let's go before the[N]soldiers find us![PAL:0][END]`