---------------------------------------------

gw88_short_wall_spear [
  actor-def < #1C, #00, #02, {

  code_0B8BFB:
    LDA $0E
    STA $08
    LDA #$2000
    STA $0E
    COP [SetEntryExit]

  loc_0B8C06:
    COP [WaitByte] ( #3B )
    LDA $10
    BIT #$4000
    BNE loc_0B8C13
    COP [PlaySoundCh1] ( #1E )

  loc_0B8C13:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #3B )
    COP [ClearLowHere]
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    BRA loc_0B8C06
} >
]