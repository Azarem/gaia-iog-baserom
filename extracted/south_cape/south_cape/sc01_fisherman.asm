?INCLUDE 'hidden_red_jewel'

!playerYPos                     09A4

---------------------------------------------

sc01_fisherman [
  actor-def < #22, #00, #10, {

  code_048372:
    LDA #$0200
    TSB $12
    COP [RngByte]
    CMP #$00F8
    BCS loc_0483AA
    CMP #$00C8
    BCS code_048393
    COP [SetOnInteract] ( &code_0483E7 )
    COP [SetTilePos] ( #06, #2F )
    COP [SolidHighHere]
    COP [AddPosition] ( #04, #00 )
    BRA loc_0483D0

  code_048393:
    COP [SetOnInteract] ( &code_0483EC )
    COP [SetTilePos] ( #0B, #33 )
    COP [SetHFlip]
    LDA #$0002
    TSB $12
    COP [SolidHighHere]
    COP [AddPosition] ( #FC, #00 )
    BRA loc_0483D0

  loc_0483AA:
    COP [BranchIfFlagByte] ( #D7, #01, &code_048393 )
    COP [SetOnInteract] ( &code_0483F1 )
    COP [SetTilePos] ( #29, #30 )
    COP [SpawnAfterRelFlags] ( @e_sc01_pot, #$FFF0, #$0000, #$1000 )
    COP [SetHFlip]
    LDA #$0002
    TSB $12
    COP [SolidHighHere]
    COP [AddPosition] ( #FC, #FE )

  loc_0483D0:
    COP [SetEntryContinue]
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
    COP [PrintWideString] ( &widestring_0483F6 )
    RTL 
}

code_0483EC {
    COP [PrintWideString] ( &widestring_04840F )
    RTL 
}

code_0483F1 {
    COP [PrintWideString] ( &widestring_048436 )
    RTL 
}

widestring_0483F6 `[DEF]Gosh.[N]I can't pull it up...[END]`

widestring_04840F `[DEF]Even if I move to[N]another place[N]I can't pull it up...[END]`

widestring_048436 `[DEF]He lifted the[N]strange teapot.[END]`

e_sc01_pot {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3E )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_048462 )
    COP [SetEntryContinue]
    RTL 
}

code_048462 {
    COP [BranchIfFlagByte] ( #D7, #01, &code_048474 )
    COP [GiveItem] ( #01, &code_048475 )
    COP [PrintWideString] ( &widestring_048479 )
    COP [SetFlagByte] ( #D7 )
}

code_048474 {
    RTL 
}

code_048475 {
    JML $@hidden_red_jewel.code_00C6A1
}

widestring_048479 `[DLG:3,11][SIZ:D,3]You've found[N]a Red Jewel![END]`