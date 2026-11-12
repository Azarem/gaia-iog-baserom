; Pair of flame statues of the Pyramid puzzle room (scene $CD), the receiver of Lola's Melody. Both statues are solid, wait for scratch $01 (set when the melody is used) and fire once: the left statue (pyCD_flame_statue) waits 30 ticks (WaitByte #1D), plays sound $1919, spawns the camera drift, shows frame #1D, spawns the flame stream code_08B7D0 and sets scratch $03; the right statue (pyCD_flame_statue2) waits 90 ticks (WaitByte #59), shows frame #9D and spawns its flame stream.
; 
; code_08B7D0 spawns five flame sprites of pyCD_jackal.code_08B804 and ends. Scratch $03 is read by pyCD_jackal, which starts its panic path. The statues do not fire periodically.
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
    COP [MarkSolidHere]
    COP [NudgePosition] ( #F8, #00 )
    COP [WaitOnFlagByte] ( #01, #01 )
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
    COP [SpawnAfterOffsetFlags] ( @code_08B7D0, #$0004, #$FFF0, #$2800 )
    LDA #$0008
    STA $0026, Y
    COP [SetFlagByte] ( #03 )
    COP [SetEntryHere]
    RTL 
} >
]

pyCD_flame_statue2 [
  actor-def < #9C, #00, #10, {

  code_08B7A0:
    COP [StageSpriteFrame] ( #9C )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [NudgePosition] ( #08, #00 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [WaitByte] ( #59 )
    LDA #$0800
    TSB $10
    COP [StageSpriteFrame] ( #9D )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08B7D0, #$FFFC, #$FFF0, #$2800 )
    LDA #$FFF8
    STA $0026, Y
    COP [SetEntryHere]
    RTL 
} >
]

code_08B7D0 {
    COP [LoopStart] ( #05 )
    COP [SpawnAfterFlags] ( @pyCD_jackal.code_08B804, #$0B02 )
    COP [WaitByte] ( #03 )
    LDA $14
    CLC 
    ADC $26
    STA $14
    COP [LoopEnd]
    COP [Die]
}