; Flame statue trap in the Pyramid puzzle room.
; 
; Animated flame-shooting statue (~75 lines). Fires periodic
; flame projectiles from a fixed position. Part of the
; puzzle room hazards that the player must avoid while
; solving the arrangement puzzle.
---------------------------------------------

?INCLUDE 'camera_drift'
?INCLUDE 'pyCD_jackal'

!cameraBoundsY                  06DC

---------------------------------------------

pyCD_flame_statue [
  actor-def < #1C, #00, #10, {

  code_08B750:
    LDA #$0100
    STA $cameraBoundsY
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #F8, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [PlaySoundBoth] ( #$1919 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopSimple, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    LDA #$0800
    TSB $10
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08B7D0, #$0004, #$FFF0, #$2800 )
    LDA #$0008
    STA $0026, Y
    COP [SetFlagByte] ( #03 )
    COP [SetEntryContinue]
    RTL 
} >
]

pyCD_flame_statue2 [
  actor-def < #9C, #00, #10, {

  code_08B7A0:
    COP [StageSpriteFrame] ( #9C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #59 )
    LDA #$0800
    TSB $10
    COP [StageSpriteFrame] ( #9D )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_08B7D0, #$FFFC, #$FFF0, #$2800 )
    LDA #$FFF8
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
} >
]

code_08B7D0 {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterFlags] ( @pyCD_jackal.code_08B804, #$0B02 )
    COP [WaitByte] ( #03 )
    LDA $14
    CLC 
    ADC $26
    STA $14
    COP [LoopNext]
    COP [Die]
}