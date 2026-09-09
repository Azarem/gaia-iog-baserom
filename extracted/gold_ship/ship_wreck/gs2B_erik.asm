?INCLUDE 'camera_drift'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetY                  06C2
!layerPriorityFlag              06EE
!playerActor                    09AA
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

gs2B_erik [
  actor-def < #0B, #00, #10, {

  code_05919C:
    COP [BranchIfFlagByte] ( #51, #01, &code_0591AB )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05923B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0591AB {
    COP [SpawnAfterAbsFlags] ( @code_05927E, #$01D8, #$0260, #$1000 )
    COP [SetTilePos] ( #19, #26 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_0593DA )
    COP [SetFlagByte] ( #02 )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @code_058598, #$2B00 )
    COP [SpawnAfterFlags] ( @code_0591F8, #$2000 )
    COP [WaitByte] ( #4F )
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #06 )

  loc_0591EA:
    COP [TickGravity]
    CMP #$0000
    BMI loc_0591F5
    COP [SetEntryExit]
    BRA loc_0591EA

  loc_0591F5:
    COP [SetEntryContinue]
    RTL 
}

code_0591F8 {
    COP [WaitByte] ( #77 )
    LDA #$0008
    TSB $12
    LDA #$0200
    TSB $layerPriorityFlag
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #03 )

  loc_059221:
    COP [TickGravity]
    CMP #$0000
    BMI loc_059239
    LDY $playerActor
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetEntryExit]
    BRA loc_059221

  loc_059239:
    COP [Die]
}

code_05923B {
    COP [PrintWideString] ( &widestring_059240 )
    RTL 
}

widestring_059240 `[DEF][TPL:3]Erik: [N]I was surprised!! [FIN]Oh, it's you, Will. [N]Don't scare me!![PAL:0][END]`

code_05927E {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_0592FF )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #EF )
    COP [SetFlagByte] ( #01 )

  code_0592AA:
    COP [RngByte]
    AND #$0060
    BEQ loc_0592C2
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2000 )
    LDA #$FFFF
    STA $0024, Y

  loc_0592C2:
    COP [BranchIfFlagByte] ( #02, #01, &code_0592CD )
    COP [SetEntryExitNow] ( @code_0592AA )
}

code_0592CD {
    COP [WaitByte] ( #63 )
    COP [InitGravity] ( #08, #07, #00 )
    COP [StageForceMoveX] ( #07 )

  loc_0592D8:
    COP [TickGravity]
    CMP #$0000
    BMI loc_0592E3
    COP [SetEntryExit]
    BRA loc_0592D8

  loc_0592E3:
    COP [ClearFlagByte] ( #4D )
    LDA #$0000
    STA $0AA6
    LDA #$0808
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00B0, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

widestring_0592FF `[TPL:E][TPL:4]Lance: [N]What happened to Seth? [N]Something happened! [FIN][TPL:3][DLY:0]Erik: [N]Eeeeeeeh!!! [N]It's Seth!!... [FIN]A huge, enormous, giant [N]fish ran into the ship![N]Sob... [FIN]Seth fell in the [N]water! Sob... [FIN]He was swallowed!  [N]Gulp...Sob... [FIN][TPL:4]Lance: [N]What was that?[PAL:0][END]`

widestring_0593DA `[TPL:E][TPL:3]Erik: Aaaggh! It's that [N]fish again! We'll [N]all be dessert!! [FIN][TPL:4]Lance: Stop crying, and [N]grab this, or  you'll [N]fall overboard!![PAL:0][END]`
---------------------------------------------

code_058598 {
    LDA $cameraTargetY
    STA $16
    LDA #$0000
    STA $chatPtr, X

  loc_0585A4:
    PHX 
    LDA $chatPtr, X
    TAX 
    LDA $@unk18_058606, X
    STA $0000
    LDA $@unk18_058606+1, X
    STA $0002
    PLX 
    LDA #$0000
    SEP #$20
    LDA $0000
    BPL loc_0585C6
    XBA 
    DEC 
    XBA 

  loc_0585C6:
    REP #$20
    STA $orbitAngle, X
    LDA $0002
    AND #$00FF
    BEQ loc_0585FD
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BEQ loc_0585F1
    DEC 
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTL 

  loc_0585F1:
    LDA $chatPtr, X
    INC 
    INC 
    STA $chatPtr, X
    BRA loc_0585A4

  loc_0585FD:
    LDA #$0020
    STA $chatPtr, X
    BRA loc_0585A4
}
---------------------------------------------

unk18_058606 [
  camera-keyframe < #04, #04 >   ;00
  camera-keyframe < #FC, #06 >   ;01
  camera-keyframe < #04, #06 >   ;02
  camera-keyframe < #FC, #06 >   ;03
  camera-keyframe < #04, #06 >   ;04
  camera-keyframe < #FC, #06 >   ;05
  camera-keyframe < #04, #06 >   ;06
  camera-keyframe < #FC, #06 >   ;07
  camera-keyframe < #08, #05 >   ;08
  camera-keyframe < #F8, #06 >   ;09
  camera-keyframe < #08, #06 >   ;0A
  camera-keyframe < #F8, #06 >   ;0B
  camera-keyframe < #08, #06 >   ;0C
  camera-keyframe < #F8, #06 >   ;0D
  camera-keyframe < #10, #06 >   ;0E
  camera-keyframe < #F0, #08 >   ;0F
  camera-keyframe < #10, #08 >   ;10
  camera-keyframe < #F0, #08 >   ;11
  camera-keyframe < #00, #00 >   ;12
]