; Wall spear trap — retractable spear hazard on the Great Wall.
; 
; Environmental trap that extends from the wall at timed
; intervals. Damages the player on contact during extension.
; Timer-based cycle. Common corridor hazard throughout
; the Great Wall dungeon.
---------------------------------------------

---------------------------------------------

gw82_wall_spear [
  actor-def < #1C, #00, #02, {

  code_0B8C33:
    LDA $0E
    STA $08
    LDA #$2000
    STA $0E
    COP [SetEntryExit]

  loc_0B8C3E:
    COP [WaitByte] ( #3B )
    LDA $10
    BIT #$4000
    BNE loc_0B8C4B
    COP [PlaySoundCh1] ( #1E )

  loc_0B8C4B:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [WaitByte] ( #3B )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    BRA loc_0B8C3E
} >
]