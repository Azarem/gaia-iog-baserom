; South Cape fisherman NPC on the south shore, with the strange pot.
; 
; At spawn one RNG byte picks the layout: below $C8 he stands at tile (06,2F) and says 'Gosh. I can't pull it up...'; $C8-$EF puts him at tile (0B,33), mirrored, with 'Even if I move to another place I can't pull it up...'; $F0 and above puts him at tile (29,30) beside the pot actor e_sc01_pot ('He lifted the strange teapot.'), unless flag $D7 is set, in which case the second layout is used.
; 
; The pot's interact handler gives item $01 (Red Jewel) once, prints 'You've found a Red Jewel!' and sets flag $D7. A full inventory jumps to hidden_red_jewel.HiddenRedJewelInventoryFull before the flag is set.
; 
; Every pass the fisherman writes scratch flag $00: set while the player's Y position is $0250 or more, clear otherwise. The player idle-sprite code in player_character reads the same flag. Scratch flags $00-$0F are cleared at every scene load.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

!playerYPos                     09A4

---------------------------------------------

sc01_fisherman [
  actor-def < #22, #00, #10, {

  code_048372:
    LDA #$0200
    TSB $12
    COP [RngByte]
    CMP #$00F0
    BCS loc_0483AA
    CMP #$00C8
    BCS code_048393
    COP [SetInteractHandler] ( &code_0483E7 )
    COP [SetTilePos] ( #06, #2F )
    COP [MarkSolidHere]
    COP [NudgePosition] ( #04, #00 )
    BRA loc_0483D0

  code_048393:
    COP [SetInteractHandler] ( &code_0483EC )
    COP [SetTilePos] ( #0B, #33 )
    COP [SetHMirror]
    LDA #$0002
    TSB $12
    COP [MarkSolidHere]
    COP [NudgePosition] ( #FC, #00 )
    BRA loc_0483D0

  loc_0483AA:
    COP [BranchOnFlagByte] ( #D7, #01, &code_048393 )
    COP [SetInteractHandler] ( &code_0483F1 )
    COP [SetTilePos] ( #29, #30 )
    COP [SpawnAfterOffsetFlags] ( @e_sc01_pot, #$FFF0, #$0000, #$1000 )
    COP [SetHMirror]
    LDA #$0002
    TSB $12
    COP [MarkSolidHere]
    COP [NudgePosition] ( #FC, #FE )

  loc_0483D0:
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    LDA $playerYPos
    CMP #$0250
    BCC loc_0483E3
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_0483E3:
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_0483E7 {
    COP [PrintDialogString] ( &dialogstring_0483F6 )
    RTL 
}

code_0483EC {
    COP [PrintDialogString] ( &dialogstring_04840F )
    RTL 
}

code_0483F1 {
    COP [PrintDialogString] ( &dialogstring_048436 )
    RTL 
}

dialogstring_0483F6 `[DEF]Gosh.[N]I can't pull it up...[END]`

dialogstring_04840F `[DEF]Even if I move to[N]another place[N]I can't pull it up...[END]`

dialogstring_048436 `[DEF]He lifted the[N]strange teapot.[END]`

e_sc01_pot {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3E )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_048462 )
    COP [SetEntryHere]
    RTL 
}

code_048462 {
    COP [BranchOnFlagByte] ( #D7, #01, &code_048474 )
    COP [GiveItem] ( #01, &code_048475 )
    COP [PrintDialogString] ( &dialogstring_048479 )
    COP [SetFlagByte] ( #D7 )
}

code_048474 {
    RTL 
}

code_048475 {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

dialogstring_048479 `[DLG:3,11][SIZ:D,3]You've found[N]a Red Jewel![END]`