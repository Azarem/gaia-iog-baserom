?INCLUDE 'chunk_008000'

!playerSpeedEw                  09B2

---------------------------------------------

h_sc01_fisherman [
  actor-def < #22, #00, #10, {

  code_04834C:
    LDA #$0200
    TSB $12
    COP [RngByte]
    CMP #$00F8
    BCS loc_048384
    CMP #$00C8
    BCS code_04836D
    COP [SetOnInteract] ( &code_0483C1 )
    COP [SetTilePos] ( #06, #2F )
    COP [SolidHighHere]
    COP [AddPosition] ( #04, #00 )
    BRA loc_0483AA

  code_04836D:
    COP [SetOnInteract] ( &code_0483C6 )
    COP [SetTilePos] ( #0B, #33 )
    COP [SetHFlip]
    LDA #$0002
    TSB $12
    COP [SolidHighHere]
    COP [AddPosition] ( #FC, #00 )
    BRA loc_0483AA

  loc_048384:
    COP [BranchIfFlagByte] ( #D7, #01, &code_04836D )
    COP [SetOnInteract] ( &code_0483CB )
    COP [SetTilePos] ( #29, #30 )
    COP [SpawnAfterRelFlags] ( @code_048416, #$FFF0, #$0000, #$1000 )
    COP [SetHFlip]
    LDA #$0002
    TSB $12
    COP [SolidHighHere]
    COP [AddPosition] ( #FC, #FE )

  loc_0483AA:
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    LDA $playerSpeedEw
    CMP #$0250
    BCC loc_0483BD
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_0483BD:
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_0483C1 {
    COP [PrintWideString] ( &widestring_0483D0 )
    RTL 
}

code_0483C6 {
    COP [PrintWideString] ( &widestring_0483E4 )
    RTL 
}

code_0483CB {
    COP [PrintWideString] ( &widestring_048400 )
    RTL 
}

widestring_0483D0 `[DEF]けっ.[N]ちっとも つれやしねえ···[END]`

widestring_0483E4 `[DEF]場所を 変えても[N]ちっとも つれやしねえ···[END]`

widestring_048400 `[DEF]変なツボを つり上げちまったい.[END]`

code_048416 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3E )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_048429 )
    COP [SetEntryContinue]
    RTL 
}

code_048429 {
    COP [BranchIfFlagByte] ( #D7, #01, &code_04843B )
    COP [GiveItem] ( #01, &code_04843C )
    COP [PrintWideString] ( &widestring_048440 )
    COP [SetFlagByte] ( #D7 )
}

code_04843B {
    RTL 
}

code_04843C {
    JML $@chunk_008000.code_00C7E3
}

widestring_048440 `[DLG:3,11][SIZ:D,3,0]赤い宝石を 見つけた![END]`