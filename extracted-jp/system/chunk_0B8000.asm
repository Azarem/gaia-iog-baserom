?BANK 0B

?INCLUDE 'array_01D3F7'
?INCLUDE 'binary_01C36C'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_0A8000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'parallax_table'
?INCLUDE 'scene_meta'
?INCLUDE 'stats_table'
?INCLUDE 'table_018000'
?INCLUDE 'table_0EE000'

!extVelocityX                   0408
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!cameraBoundsY                  06DC
!layerPriorityFlag              06EE
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!playerDef                      0ADC
!playerStr                      0ADE
!INIDISP                        2100
!WH0                            2126
!TM                             212C
!TS                             212D
!HDMAEN                         420C
!MEMSEL                         420D
!DASB4                          4347
!decompressedTilesets           7E4000
!mode7Tilemap                   7EE000
!thinkerExtendedData            7EF000
!animScratch                    7F0000
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!retPtr2                        7F001E
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!currentHp                      7F0026
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!cgramPalette                   7F0A00
!scratch1010                    7F1010
!collisionLayer                 7FC000
!L_RDNMI                        804210
!S_effectLayerTilemap           C000

---------------------------------------------

actor_def_0B8000 [
  actor-def < #00, #00, #01, {

  code_0B8003:
    LDA #$8019
    TSB $12
    LDA $cameraBoundsY
    CLC 
    ADC #$0020
    STA $cameraBoundsY
    LDY $decelStepCounter
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [SetDeathCallback] ( @code_0B856E )
    COP [SpawnLastRel] ( @code_0B80E7, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0B8037
    JMP $&code_0B81DA

  loc_0B8037:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0B805D
    RTL 

  loc_0B805D:
    JMP $&code_0B81DA
} >
]

code_0B8060 {
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0020
    BNE loc_0B806B
    RTL 

  loc_0B806B:
    BIT #$0200
    BEQ loc_0B8073
    COP [SetEntryContinue]
    RTL 

  loc_0B8073:
    COP [ExitIfFlagWord] ( #$016A, #01 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_0B80B5 )
    LDA #$0003
    STA $0AAC
    LDA #$008A
    STA $0B12
    LDA #$0016
    STA $0B08
    STA $0B0A
    LDA #$002C
    STA $0B0C
    STA $0B0E
    LDA #$3300
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

dialogstring_0B80B5 `[DEF][TPL:0]サンドファンガーを たおすと[N]しかばねから ミステリードールが[N]見つかった!![PAL:0][END]`

code_0B80E7 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0B80EF
    RTL 

  loc_0B80EF:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0B8115
    RTL 

  loc_0B8115:
    COP [SetFlagWord] ( #$0178 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$02F8, #$00A0, #03, #$1800 )
    COP [Die]

  code_0B8131:
    LDY $decelStepCounter
    LDA $0016, Y
    CMP #$01C7
    BCS loc_0B8149
    LDA $000E, Y
    AND #$CFFF
    ORA #$2000
    STA $000E, Y
    RTL 

  loc_0B8149:
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    RTL 
}

actor_def_0B8153 [
  actor-def < #00, #00, #01, {

  code_0B8156:
    COP [SpawnLastRel] ( @code_0B8131, #00, #00, #$2000 )
    LDA #$0003
    JSL $@chunk_008000.code_00B10F
    BCC loc_0B8170
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0B8170:
    LDA #$8019
    TSB $12
    COP [SpawnLastRel] ( @code_0B8060, #00, #00, #$2000 )
    COP [SetDeathCallback] ( @code_0B856E )
    COP [SolidHighAbs] ( #0F, #2A )
    COP [SolidHighAbs] ( #10, #2A )
    COP [SolidHighAbs] ( #0F, #2B )
    COP [SolidHighAbs] ( #10, #2B )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0D, #19, #12, #1B, &code_0B819E )
    RTL 
} >
]

code_0B819E {
    LDY $decelStepCounter
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0F, #2C, #11, #2E, &code_0B81B5 )
    RTL 
}

code_0B81B5 {
    COP [ClearLowAbs] ( #0F, #2A )
    COP [ClearLowAbs] ( #10, #2A )
    COP [ClearLowAbs] ( #0F, #2B )
    COP [ClearLowAbs] ( #10, #2B )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1F )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #3B )
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_0B81DA {
    COP [SpawnMarkedBefore] ( @code_0B89F5, #$2000 )
    COP [SpawnAfterFlags] ( @code_0B8608, #$2200 )
    LDA #$0009

  loc_0B81EB:
    PHA 
    COP [SpawnAfterFlags] ( @code_0B86DA, #$2200 )
    PLA 
    DEC 
    BPL loc_0B81EB

  code_0B81F7:
    COP [WaitByte] ( #4F )
    LDA #$0080
    TRB $10
    LDA $playerSpeedNs
    LSR 
    LSR 
    LSR 
    BCS loc_0B821D
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B8215 )
}

code_list_0B8215 [
  &code_0B8233   ;00
  &code_0B8233   ;01
  &code_0B8254   ;02
  &code_0B82F3   ;03
]

loc_0B821D {
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B822B )
}

code_list_0B822B [
  &code_0B8254   ;00
  &code_0B8254   ;01
  &code_0B8233   ;02
  &code_0B82F3   ;03
]

code_0B8233 {
    JSR $&code_0B8BB7
    JSR $&code_0B8BAA
    COP [WaitByte] ( #3B )
    LDA #$02C8
    STA $16
    COP [CallScript] ( &code_0B82FF )
    JSR $&code_0B8BB7
    LDA #$0048
    STA $16
    COP [CallScript] ( &code_0B8334 )
    JMP $&code_0B81F7
}

code_0B8254 {
    LDA $playerWallType
    CMP #$0180
    BCC loc_0B82AA
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC #$0278
    STA $14
    STA $24
    JSR $&code_0B8BAA
    LDA #$0000
    STA $7F100C, X
    COP [WaitByte] ( #13 )

  loc_0B827A:
    LDA #$02E0
    STA $16
    LDA #$0003
    STA $26
    JSR $&code_0B8B72
    JSR $&code_0B8B1E
    COP [CallScript] ( &code_0B8369 )
    LDA $moveXAlt, X
    SEC 
    SBC #$0080
    STA $14
    STA $24
    BPL loc_0B829F
    JMP $&code_0B81F7

  loc_0B829F:
    CMP #$00E8
    BCS loc_0B827A
    COP [WaitByte] ( #31 )
    JMP $&code_0B81F7

  loc_0B82AA:
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC #$0088
    STA $14
    STA $24
    JSR $&code_0B8BAA
    LDA #$0000
    STA $7F100C, X
    COP [WaitByte] ( #13 )

  loc_0B82C8:
    LDA #$02E0
    STA $16
    LDA #$0004
    STA $26
    JSR $&code_0B8B72
    JSR $&code_0B8B48
    COP [CallScript] ( &code_0B840E )
    LDA $moveXAlt, X
    CLC 
    ADC #$0080
    STA $14
    STA $24
    CMP #$0218
    BCC loc_0B82C8
    COP [WaitByte] ( #31 )
    JMP $&code_0B81F7
}

code_0B82F3 {
    LDA #$0005
    STA $26
    COP [CallScript] ( &code_0B84B3 )
    JMP $&code_0B81F7
}

code_0B82FF {
    LDA #$0001
    STA $26
    JSR $&code_0B8ACD
    COP [StageSprAndHitbox] ( #00 )
    COP [StageForceMoveY] ( #08 )
    COP [SetEntryContinue]
    JSR $&code_0B9CD4
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $orbitAngle, X
    CLC 
    ADC #$0006
    AND #$00FF
    STA $orbitAngle, X
    LDA $16
    CMP #$0050
    BCC loc_0B8330
    RTL 

  loc_0B8330:
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0B8334 {
    LDA #$0002
    STA $26
    JSR $&code_0B8ACD
    COP [StageSprAndHitbox] ( #04 )
    COP [StageForceMoveY] ( #0B )
    COP [SetEntryContinue]
    JSR $&code_0B9CD4
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $orbitAngle, X
    CLC 
    ADC #$0008
    AND #$00FF
    STA $orbitAngle, X
    LDA $16
    CMP #$03A0
    BCS loc_0B8365
    RTL 

  loc_0B8365:
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0B8369 {
    LDA $chatPtr, X
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    STZ $08
    STZ $2E
    STZ $2C

  code_0B8378:
    COP [SetEntryExit]
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@chunk_008000.code_00F526
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    AND #$00FF
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    CMP $animScratch, X
    BEQ loc_0B83CD
    STA $animScratch, X
    PHX 
    TAX 
    STZ $28
    SEP #$20
    LDA #$40
    TRB $0F
    LDA $@loc_0B8406, X
    PLX 
    CLC 
    ADC $chatPtr, X
    STA $28
    BPL loc_0B83C6
    AND #$7F
    STA $28
    LDA #$40
    TSB $0F
    BRA loc_0B83C8

  loc_0B83C6:
    STA $28

  loc_0B83C8:
    REP #$20
    COP [StageSprAndHitbox] ( #FF )

  loc_0B83CD:
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    STA $7F0011, X
    SEC 
    SBC $animScratch+2, X
    BIT #$80
    BEQ loc_0B83FD
    LDA $animScratch+2, X
    CLC 
    ADC #$80
    STA $animScratch+2, X
    LDA $animScratch2, X
    DEC 
    BMI loc_0B8402
    STA $animScratch2, X

  loc_0B83FD:
    REP #$20
    JMP $&code_0B8378

  loc_0B8402:
    REP #$20
    COP [RestoreSavedPtr]

  loc_0B8406:
    BRL loc_0B848A

  loc_0B8409:
    ORA ($02, X)
    ORA $04, S
    STA $BF, S
    ASL 
    BRK #$7F
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    STZ $08
    STZ $2E
    STZ $2C

  code_0B841D:
    COP [SetEntryExit]
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@chunk_008000.code_00F526
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    AND #$00FF
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    CMP $animScratch, X
    BEQ loc_0B8472
    STA $animScratch, X
    PHX 
    TAX 
    STZ $28
    SEP #$20
    LDA #$40
    TRB $0F
    LDA $@loc_0B84AB, X
    PLX 
    CLC 
    ADC $chatPtr, X
    STA $28
    BPL loc_0B846B
    AND #$7F
    STA $28
    LDA #$40
    TSB $0F
    BRA loc_0B846D

  loc_0B846B:
    STA $28

  loc_0B846D:
    REP #$20
    COP [StageSprAndHitbox] ( #FF )

  loc_0B8472:
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$FE
    STA $orbitAngle, X
    STA $7F0011, X
    CLC 
    ADC $animScratch+2, X
    BIT #$80

  loc_0B848A:
    BEQ loc_0B84A2
    LDA $animScratch+2, X
    SEC 
    SBC #$9F80
    COP [GenHdmaSine]
    ADC $000EBF, X
    ADC $09303A, X
    STA $animScratch2, X

  loc_0B84A2:
    REP #$20
    JMP $&code_0B841D
}

code_0B84A7 {
    REP #$20
    COP [RestoreSavedPtr]

  loc_0B84AB:
    COP [QueueHdmaChannel] ( #04, #$8283, #$0081 )
    ORA ($02, X)
    AND $38, S
    SBC #$007F
    CLC 
    ADC $playerWallType
    BPL loc_0B84C3

  loc_0B84BF:
    CLC 
    ADC #$007F

  loc_0B84C3:
    CMP #$0030
    BCC loc_0B84BF
    CMP #$02D0
    BCC loc_0B84D1
    SEC 
    SBC #$007F

  loc_0B84D1:
    STA $14
    JSR $&code_0B8BAA
    COP [WaitByte] ( #3B )
    LDA #$02CF
    STA $16
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    PEA $&code_0B851D-1
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B84F4 )
}

code_list_0B84F4 [
  &code_0B8504   ;00
  &code_0B8509   ;01
  &code_0B850E   ;02
  &code_0B8513   ;03
  &code_0B8518   ;04
  &code_0B8504   ;05
  &code_0B8504   ;06
  &code_0B8504   ;07
]

code_0B8504 {
    JSR $&code_0B855A
    BRA code_0B8564
}

code_0B8509 {
    JSR $&code_0B855A
    BRA loc_0B8532
}

code_0B850E {
    JSR $&code_0B8564
    BRA loc_0B853C
}

code_0B8513 {
    JSR $&code_0B855A
    BRA loc_0B8550
}

code_0B8518 {
    JSR $&code_0B8564
    BRA loc_0B8546
}

code_0B851D {
    COP [StageSpriteLoop] ( #19, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [StageForceMoveY] ( #13 )
    COP [WaitByte] ( #09 )
    STZ $2E
    COP [RestoreSavedPtr]

  loc_0B8532:
    COP [SpawnLastRel] ( @code_0B87D0, #00, #F8, #$0301 )
    RTS 

  loc_0B853C:
    COP [SpawnLastRel] ( @code_0B87C6, #00, #F8, #$0301 )
    RTS 

  loc_0B8546:
    COP [SpawnLastRel] ( @code_0B887D, #00, #F8, #$0301 )
    RTS 

  loc_0B8550:
    COP [SpawnLastRel] ( @code_0B8882, #00, #F8, #$0301 )
    RTS 
}

code_0B855A {
    COP [SpawnLastRel] ( @code_0B88B9, #00, #F8, #$0111 )
    RTS 
}

code_0B8564 {
    COP [SpawnLastRel] ( @code_0B88C7, #00, #F8, #$0111 )
    RTS 
}

code_0B856E {
    LDA $slopeCurvePtrB
    BIT #$0200
    BEQ loc_0B8579
    COP [SetEntryContinue]
    RTL 

  loc_0B8579:
    LDA #$0020
    TSB $slopeCurvePtrB
    COP [SpawnLastRel] ( @chunk_0A8000.code_0AA2B1, #00, #00, #$2000 )
    LDA #$000A
    STA $0000
    LDA #$0014
    STA $0002
    LDY $06

  loc_0B8596:
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0B85A6
    LDA #$8604
    STA $0000, Y
    BRA loc_0B85B9

  loc_0B85A6:
    LDA #$85F8
    STA $0000, Y
    LDA $0002
    STA $0008, Y
    CLC 
    ADC #$0008
    STA $0002

  loc_0B85B9:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0B8596
    PHX 
    LDX $0056

  loc_0B85C6:
    LDA $extendedFlags, X
    BIT #$0080
    BEQ loc_0B85E7
    LDA $0010, X
    BIT #$0040
    BNE loc_0B85E7
    BIT #$2000
    BEQ loc_0B85E1
    LDA #$8604
    BRA loc_0B85E4

  loc_0B85E1:
    LDA #$85F8

  loc_0B85E4:
    STA $0000, X

  loc_0B85E7:
    LDA $0006, X
    BEQ loc_0B85EF
    TAX 
    BRA loc_0B85C6

  loc_0B85EF:
    PLX 
    COP [WaitByte] ( #10 )
    COP [JumpScript] ( @chunk_0A8000.code_0AA382 )

  loc_0B85F8:
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #10, #$0302 )
    COP [Die]

  code_0B8606:
    COP [SetEntryContinue]
}

code_0B8608 {
    LDY $24
    LDA $0026, Y
    BNE code_0B8610
    RTL 

  code_0B8610:
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0026, Y
    DEC 
    STA $0000
    LDA #$0000
    STA $0026, Y
    COP [SwitchCase] ( #$0000, &code_list_0B862A )
}

code_list_0B862A [
  &code_0B8634   ;00
  &code_0B865E   ;01
  &code_0B8688   ;02
  &code_0B86AF   ;03
  &code_0B8606   ;04
]

code_0B8634 {
    COP [StageSprAndHitbox] ( #0A )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8645:
    JSR $&code_0B8AE2
    LDY $24
    LDA $0016, Y
    CLC 
    ADC #$00C0
    STA $16
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B8610
    BRA loc_0B8645
}

code_0B865E {
    COP [StageSprAndHitbox] ( #0E )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B866F:
    JSR $&code_0B8AF1
    LDY $24
    LDA $0016, Y
    SEC 
    SBC #$00B0
    STA $16
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B8610
    BRA loc_0B866F
}

code_0B8688 {
    LDA #$000A
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B1E
    COP [CallScript] ( &code_0B8369 )

  loc_0B86A2:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    BEQ loc_0B86AE
    JMP $&code_0B8610

  loc_0B86AE:
    RTL 
}

code_0B86AF {
    LDA #$000A
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B48
    COP [CallScript] ( &code_0B840E )
    BRA loc_0B86A2

  code_0B86CB:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    CMP #$0005
    BNE loc_0B86D8
    RTL 

  loc_0B86D8:
    COP [SetEntryContinue]
}

code_0B86DA {
    LDY $24
    LDA $0026, Y
    BNE code_0B86E2
    RTL 

  code_0B86E2:
    LDY $24
    LDA $0024, Y
    STA $14
    LDA $0026, Y
    DEC 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B86F6 )
}

code_list_0B86F6 [
  &code_0B8700   ;00
  &code_0B8730   ;01
  &code_0B8760   ;02
  &code_0B8787   ;03
  &code_0B86CB   ;04
]

code_0B8700 {
    COP [StageSprAndHitbox] ( #05 )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8711:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8711
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B871E:
    JSR $&code_0B8AE2
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B86E2
    DEC $26
    BMI loc_0B8711
    BRA loc_0B871E
}

code_0B8730 {
    COP [StageSprAndHitbox] ( #09 )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8741:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8741
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B874E:
    JSR $&code_0B8AF1
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B86E2
    DEC $26
    BMI loc_0B8741
    BRA loc_0B874E
}

code_0B8760 {
    LDA #$0005
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B1E
    COP [CallScript] ( &code_0B8369 )

  loc_0B877A:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    BEQ loc_0B8786
    JMP $&code_0B86E2

  loc_0B8786:
    RTL 
}

code_0B8787 {
    LDA #$0005
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B48
    COP [CallScript] ( &code_0B840E )
    BRA loc_0B877A

  code_0B87A3:
    COP [SetSpritePriority] ( #30 )
    LDA #$02D0
    STA $16
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [LoopInit] ( #3C )
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    CMP #$02C8
    BCC loc_0B87C4
    COP [LoopNext]

  loc_0B87C4:
    COP [Die]
}

code_0B87C6 {
    LDA #$4000
    TSB $12
    COP [StageForceMoveX] ( #11 )
    BRA loc_0B87D5
}

code_0B87D0 {
    COP [StageForceMoveX] ( #11 )
    COP [SetHFlip]

  loc_0B87D5:
    LDA #$0002
    TSB $12
    COP [StageSprAndHitbox] ( #10 )
    COP [CallScript] ( &code_0B89C3 )
    LDA #$0101
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #26 )
    COP [StageSprAndHitbox] ( #1D )
    STZ $26

  loc_0B87F3:
    COP [StageForceMoveXY] ( #03, #01 )

  loc_0B87F7:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B87F3
    LDA $08
    STZ $08
    STA $24

  loc_0B8803:
    LDA $14
    CMP #$02C8
    BCC loc_0B8825
    LDA #$4000
    TSB $12
    LDA $26
    INC $26
    CMP #$0002
    BCS loc_0B8865
    CLC 
    ADC #$001E
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [ClearHFlip]
    BRA loc_0B8845

  loc_0B8825:
    LDA $14
    CMP #$0038
    BCS loc_0B8845
    LDA #$4000
    TRB $12
    LDA $26
    INC $26
    CMP #$0002
    BCS loc_0B8865
    CLC 
    ADC #$001E
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [SetHFlip]

  loc_0B8845:
    LDA $16
    CMP #$02F0
    BCC loc_0B8851
    LDA #$2000
    TSB $12

  loc_0B8851:
    LDA $16
    CMP #$02B0
    BCS loc_0B885D
    LDA #$2000
    TRB $12

  loc_0B885D:
    COP [SetEntryExit]
    DEC $24
    BPL loc_0B8803
    BRA loc_0B87F7

  loc_0B8865:
    COP [StageForceMoveXY] ( #13, #45 )
    COP [WaitByte] ( #0A )
    STZ $2C
    STZ $2E
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [Die]
}

code_0B887D {
    LDA #$4000
    TSB $12
}

code_0B8882 {
    COP [StageForceMoveX] ( #13 )
    COP [StageSprAndHitbox] ( #21 )
    COP [CallScript] ( &code_0B89C3 )
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #13 )
    COP [StageSpriteLoop] ( #22, #06 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #14 )
    COP [SpawnLastRel] ( @code_0B88AD, #00, #FD, #$0302 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [Die]
}

code_0B88AD {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0B88B9 {
    LDA #$4000
    TSB $12
    BRA code_0B88C7

  loc_0B88C0:
    LDA #$4000
    TSB $12
    BRA loc_0B88CC
}

code_0B88C7 {
    COP [StageForceMoveX] ( #13 )
    BRA loc_0B88CF

  loc_0B88CC:
    COP [StageForceMoveX] ( #11 )

  loc_0B88CF:
    COP [PlaySoundCh1] ( #13 )
    COP [StageSprAndHitbox] ( #10 )
    COP [CallScript] ( &code_0B89C3 )
    COP [PlaySoundCh1] ( #1D )
    LDA #$ACB4
    STA $statsPtr, X
    LDA $@stats_table+DC
    AND #$00FF
    STA $currentHp, X
    COP [PlaySoundCh1] ( #28 )
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA #$00B0
    TSB $12

  loc_0B8900:
    LDA #$2000
    TSB $10
    COP [RngByte]
    AND #$007F
    CLC 
    ADC #$0064
    STA $08
    COP [SetEntryExit]

  code_0B8912:
    COP [RngByte]
    PHA 
    SEC 
    SBC #$007F
    CLC 
    ADC $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    PLA 
    AND #$0070
    SEC 
    SBC #$0030
    CLC 
    ADC #$02D0
    STA $16
    COP [SetEntryExit]
    COP [BranchIfSolid] ( &code_0B8912 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #14, #02 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #02, &code_0B895E )
    COP [SpawnLastRel] ( @code_0B8965, #00, #F0, #$0200 )
    COP [StageSpriteLoop] ( #14, #02 )
    COP [AnimLoop]
}

code_0B895E {
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    BRA loc_0B8900
}

code_0B8965 {
    COP [OrActorFlags] ( #$0010 )
    COP [PlaySoundCh1] ( #1E )
    LDA #$0002
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E5F3, #$2000 )
    CPY #$1FC0
    BEQ loc_0B89BC
    LDA $decelStepCounter
    STA $0024, Y
    COP [StageSprAndHitbox] ( #17 )

  loc_0B8988:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8988
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B8995:
    LDA $14
    CMP #$0030
    BCC loc_0B89BE
    CMP #$02D0
    BCS loc_0B89BE
    LDA $16
    CMP #$0294
    BCC loc_0B89BE
    CMP #$02F8
    BCS loc_0B89BE
    COP [SetEntryExit]
    LDA $10
    BIT #$4000
    BNE loc_0B8988
    DEC $26
    BPL loc_0B8995
    BRA loc_0B8988

  loc_0B89BC:
    COP [Die]

  loc_0B89BE:
    COP [JumpScript] ( @chunk_008000.code_00C560 )
}

code_0B89C3 {
    COP [OrActorFlags] ( #$0080 )
    COP [SetSpritePriority] ( #30 )
    COP [InitGravity] ( #02, #08, #00 )
    COP [SetEntryContinue]
    LDA $14
    CMP #$02D0
    BCC loc_0B89DD
    LDA #$4000
    TSB $12

  loc_0B89DD:
    LDA $14
    CMP #$0030
    BCS loc_0B89E9
    LDA #$4000
    TRB $12

  loc_0B89E9:
    COP [TickGravity]
    CMP #$0000
    BMI loc_0B89F1
    RTL 

  loc_0B89F1:
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0B89F5 {
    LDA #$0180
    TSB $12
    COP [SpawnMarkedBefore] ( @code_0B8AC1, #$2300 )
    STY $20
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B8A12
    JMP $&code_0B8AB3

  loc_0B8A12:
    LDA #$000B
    STA $0000
    LDY $06
    STY $0002
    STZ $0004
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0B8A2B
    INC $0004

  loc_0B8A2B:
    LDA #$02D0
    CMP $0016, Y
    BCS loc_0B8A3E
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    BRA loc_0B8A47

  loc_0B8A3E:
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0B8A47:
    CPY $0002
    BEQ loc_0B8A69
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    LDA $0004
    BEQ loc_0B8A69
    LDA $0036
    LSR 
    BCC loc_0B8A69
    LDA $000E, Y
    ORA #$0800
    STA $000E, Y

  loc_0B8A69:
    DEC $0000
    BMI loc_0B8A74
    LDA $0006, Y
    TAY 
    BRA loc_0B8A2B

  loc_0B8A74:
    LDA #$000B
    STA $0000
    LDY $06

  loc_0B8A7C:
    LDA #$02C8
    SEC 
    SBC $0016, Y
    BPL loc_0B8A89
    EOR #$FFFF
    INC 

  loc_0B8A89:
    CMP #$000A
    BCS loc_0B8AA8
    PHX 
    LDX $20
    LDA $0010, X
    AND #$DFFF
    STA $0010, X
    LDA $0014, Y
    STA $0014, X
    LDA #$02D8
    STA $0016, X
    PLX 
    RTL 

  loc_0B8AA8:
    DEC $0000
    BMI loc_0B8AB5
    LDA $0006, Y
    TAY 
    BRA loc_0B8A7C
}

code_0B8AB3 {
    COP [SetEntryContinue]

  loc_0B8AB5:
    LDY $20
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTL 
}

code_0B8AC1 {
    LDA #$2000
    TRB $10

  loc_0B8AC6:
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    BRA loc_0B8AC6
}

code_0B8ACD {
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0020
    STA $orbitDiameter, X
    LDA $14
    STA $7F100C, X
    RTS 
}

code_0B8AE2 {
    LDY $04
    JSR $&code_0B8B00
    LDA $0016, Y
    CLC 
    ADC #$0010
    STA $16
    RTS 
}

code_0B8AF1 {
    LDY $04
    JSR $&code_0B8B00
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    RTS 
}

code_0B8B00 {
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $animScratch, X
    LDA $animScratch2, X
    STA $animScratch+2, X
    LDA $0014, Y
    STA $animScratch2, X
    RTS 
}

code_0B8B1E {
    LDA #$0000
    STA $animScratch2, X
    LDA $14
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$4040
    STA $orbitAngle, X
    STA $animScratch+2, X
    LDA #$FFA0
    STA $orbitDiameter, X
    RTS 
}

code_0B8B48 {
    LDA #$0000
    STA $animScratch2, X
    LDA $14
    CLC 
    ADC #$0050
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$C0C0
    STA $orbitAngle, X
    STA $animScratch+2, X
    LDA #$FFA0
    STA $orbitDiameter, X
    RTS 
}

code_0B8B72 {
    LDA $7F100C, X
    BEQ loc_0B8B79
    RTS 

  loc_0B8B79:
    INC 
    STA $7F100C, X
    LDA #$0000
    STA $chatPtr, X
    LDA #$000A
    STA $0000
    LDA #$0004
    STA $0002
    LDY $06

  loc_0B8B93:
    LDA $0002
    STA $0008, Y
    CLC 
    ADC #$0003
    STA $0002
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0B8B93
    RTS 
}

code_0B8BAA {
    COP [PlaySoundCh1] ( #27 )
    COP [SpawnLastRel] ( @code_0B87A3, #00, #00, #$0301 )
    RTS 
}

code_0B8BB7 {
    LDA $playerWallType
    CMP #$00F8
    BCS loc_0B8BC4
    LDA #$0088
    BRA loc_0B8BD1

  loc_0B8BC4:
    CMP #$01F8
    BCS loc_0B8BCE
    LDA #$0188
    BRA loc_0B8BD1

  loc_0B8BCE:
    LDA #$0288

  loc_0B8BD1:
    STA $14
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $14
    STA $14
    STA $24
    RTS 
}

actor_def_0B8BE4 [
  actor-def < #1C, #00, #02, {

  code_0B8BE7:
    LDA $0E
    STA $08
    LDA #$2000
    STA $0E
    COP [SetEntryExit]

  loc_0B8BF2:
    COP [WaitByte] ( #3B )
    LDA $10
    BIT #$4000
    BNE loc_0B8BFF
    COP [PlaySoundCh1] ( #1E )

  loc_0B8BFF:
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
    BRA loc_0B8BF2
} >
]

actor_def_0B8C1C [
  actor-def < #1C, #00, #02, {

  code_0B8C1F:
    LDA $0E
    STA $08
    LDA #$2000
    STA $0E
    COP [SetEntryExit]

  loc_0B8C2A:
    COP [WaitByte] ( #3B )
    LDA $10
    BIT #$4000
    BNE loc_0B8C37
    COP [PlaySoundCh1] ( #1E )

  loc_0B8C37:
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
    BRA loc_0B8C2A
} >
]

actor_def_0B8C5C [
  actor-def < #18, #00, #00, {

  code_0B8C5F:
    COP [OrActorFlags] ( #$0020 )
    COP [SetDeathCallback] ( @code_0B8DA5 )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $26

  loc_0B8C72:
    COP [BranchIfOffscreen] ( &code_0B8C80 )
    COP [WaitWhileOffscreen] ( #05 )

  code_0B8C79:
    LDA $10
    BIT #$4000
    BNE loc_0B8C72
} >
]

code_0B8C80 {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0040, &code_0B8C8F, &code_0B8CC0, &code_0B8CA7 )
}

code_0B8C8F {
    LDA $7F100C, X
    SEC 
    SBC #$00C1
    CMP $14
    BPL code_0B8CA7
    LDA #$FFC0
    JSR $&code_0B8D51
    COP [MoveToward] ( #19, #02 )
    BRA code_0B8C79
}

code_0B8CA7 {
    LDA $7F100C, X
    CLC 
    ADC #$00C1
    CMP $14
    BMI code_0B8C8F
    LDA #$0040
    JSR $&code_0B8D51
    COP [MoveToward] ( #99, #02 )
    JMP $&code_0B8C79
}

code_0B8CC0 {
    LDA #$2000
    TSB $12
    COP [BranchOnPlayerX] ( #$0000, &code_0B8CCF, &code_0B8CCF, &code_0B8CE0 )
}

code_0B8CCF {
    LDA $7F100C, X
    SEC 
    SBC #$00B0
    CMP $14
    BPL code_0B8CE0
    COP [StageSprAndHitbox] ( #19 )
    BRA loc_0B8CF4
}

code_0B8CE0 {
    LDA $7F100C, X
    CLC 
    ADC #$00A1
    CMP $14
    BMI code_0B8CCF
    COP [StageSprAndHitbox] ( #99 )
    LDA #$4000
    TSB $12

  loc_0B8CF4:
    COP [InitGravity] ( #02, #0A, #00 )

  loc_0B8CF9:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    COP [TickGravity]
    COP [StageForceMoveX] ( #02 )
    LDA $16
    CMP $26
    BCC loc_0B8D14
    DEC $24
    BMI loc_0B8CF9
    RTL 

  loc_0B8D14:
    LDA #$6000
    TRB $12
    STZ $2C
    LDA #$0000
    STA $moveScratch2, X
    LDA $26
    CMP $16
    BEQ loc_0B8D3A
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #19, #02 )
    LDA $26
    STA $16

  loc_0B8D3A:
    LDA $10
    BIT #$4000
    BEQ loc_0B8D44
    JMP $&code_0B8C79

  loc_0B8D44:
    COP [SpawnAfterFlags] ( @code_0B8D5F, #$0201 )
    COP [PlaySoundCh1] ( #21 )
    JMP $&code_0B8C79
}

code_0B8D51 {
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    RTS 
}

code_0B8D5F {
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0B8D6E )
    BRA loc_0B8D76
}

code_0B8D6E {
    COP [LoopNext]
    COP [Die]

  loc_0B8D72:
    COP [BranchIfSolidSouth] ( &code_0B8D7D )

  loc_0B8D76:
    COP [SpawnAfterFlags] ( @code_0B8D85, #$0200 )
}

code_0B8D7D {
    COP [StageSpriteLoop] ( #04, #04 )
    COP [AnimLoop]

  loc_0B8D83:
    COP [Die]
}

code_0B8D85 {
    LDA $10
    BIT #$4000
    BNE loc_0B8D83
    COP [PlaySoundCh1] ( #21 )
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #04, #01 )
    BRA loc_0B8D72
}

code_0B8DA5 {
    COP [JumpScript] ( @chunk_0A8000.code_0AA382 )
}

actor_def_0B8DAA [
  actor-def < #00, #00, #00, {

  loc_0B8DAD:
    COP [WaitWhileOffscreen] ( #07 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    LDA $10
    BIT #$4000
    BNE loc_0B8DAD
    COP [BranchIfPlayerNear] ( #04, &code_0B8E15 )

  code_0B8DCB:
    COP [BranchOnPlayerX] ( #$0000, &code_0B8DD6, &code_0B8DD6, &code_0B8DDE )
    RTL 
} >
]

code_0B8DD6 {
    COP [StageSprAndHitbox] ( #02 )
    LDA #$FFE0
    BRA loc_0B8DE9
}

code_0B8DDE {
    COP [StageSprAndHitbox] ( #82 )
    LDA #$0002
    TSB $12
    LDA #$0020

  loc_0B8DE9:
    CLC 
    ADC $14
    STA $moveXAlt, X
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #FF, #01 )
    LDA #$0008
    TRB $10
    LDA #$0002
    TRB $12
    BRA loc_0B8DAD
}

code_0B8E15 {
    LDA #$0001
    TSB $12
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]
    COP [LoopInit] ( #03 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [RngByte]
    COP [SpawnAfterRelFlags] ( @code_0B8E53, #$0000, #$FFF6, #$0302 )
    COP [SpawnAfterRelFlags] ( @code_0B8E58, #$0000, #$FFF6, #$0302 )
    COP [PlaySoundCh1] ( #1E )
    COP [LoopNext]
    COP [StageSpriteLoop] ( #00, #02 )
    COP [AnimLoop]
    LDA #$0001
    TRB $12
    JMP $&code_0B8DCB
}

code_0B8E53 {
    LDA #$4000
    TSB $12
}

code_0B8E58 {
    COP [InitGravity] ( #02, #0A, #00 )
    PEA $&code_0B8E7D-1
    LDA $0410
    AND #$0003
    BNE loc_0B8E6C
    COP [StageForceMoveX] ( #00 )
    RTS 

  loc_0B8E6C:
    DEC 
    BNE loc_0B8E72
    COP [StageForceMoveX] ( #13 )

  loc_0B8E72:
    DEC 
    BNE loc_0B8E79
    COP [StageForceMoveX] ( #11 )
    RTS 

  loc_0B8E79:
    COP [StageForceMoveX] ( #13 )
    RTS 
}

code_0B8E7D {
    COP [RngByte]
    AND #$001F
    STA $24
    LDA $12
    BIT #$4000
    BEQ loc_0B8E93
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_0B8E93:
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [StageSprAndHitbox] ( #04 )

  loc_0B8E9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BNE loc_0B8EB4
    COP [ReloadForceMove]
    STZ $2E
    BRA loc_0B8E9F

  loc_0B8EB4:
    COP [SetEntryContinue]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0B8EC2
    DEC $24
    BMI loc_0B8E9F
    RTL 

  loc_0B8EC2:
    LDA #$0102
    TRB $10
    STZ $2C
    STZ $2E
    COP [BranchIfBehindWall] ( &code_0B8EDC )
    COP [StageSpriteMoveXY] ( #04, #47, #45 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
}

code_0B8EDC {
    COP [Die]

  loc_0B8EDE:
    ORA [$00]
    ORA $80, S
    ASL 
    ORA [$00]
    ORA $02, S
    TYX 
    BRA loc_0B8EED
}

actor_def_0B8EEA [
  actor-def < #05, #00, #03, {

  loc_0B8EED:
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0B8F01 )
    RTL 
} >
]

code_0B8F01 {
    COP [BranchIfNotOnGridline] ( &code_0B8F07 )
    BRA loc_0B8F0C
}

code_0B8F07 {
    COP [SetEntryExitNow] ( @code_0B8F01 )

  loc_0B8F0C:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #06 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #06 )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0010
    TRB $12
    LDA #$0300
    TRB $10
    COP [ClearLowHere]
    JMP $&code_0B9166
}

actor_def_0B8F3B [
  actor-def < #05, #00, #01, {

  code_0B8F3E:
    LDA #$0010
    TSB $12
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SolidHighHere]
    COP [SetHitCallback] ( &code_0B8F56 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0B8F56 {
    LDA #$0200
    TSB $10
    JMP $&code_0B8F01
}

actor_def_0B8F5E [
  actor-def < #05, #00, #01, {

  code_0B8F61:
    LDA #$0020
    TSB $12
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @code_0B8FE7, #$2700 )
    COP [SolidHighHere]
    LDA $currentHp, X
    STA $26

  loc_0B8F78:
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    LDA $26
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $14
    CMP $orbitAngle, X
    BNE loc_0B8FAB
    LDA $16
    CMP $orbitDiameter, X
    BNE loc_0B8FAB
    LDA $currentHp, X
    CMP $26
    BNE loc_0B8F78
    COP [BranchIfFlagByte] ( #0F, #01, &code_0B8FC9 )
    RTL 

  loc_0B8FAB:
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $orbitAngle, X
    STA $14
    LDA $orbitDiameter, X
    STA $16
    COP [ClearLowHere]
    PLA 
    STA $16
    PLA 
    STA $14
    COP [SolidHighHere]
    BRA loc_0B8F78
} >
]

code_0B8FC9 {
    LDA #$0200
    TSB $10
    LDA #$0020
    TRB $12
    LDA #$ACA4
    STA $statsPtr, X
    LDA $&stats_table+CC
    AND #$00FF
    STA $currentHp, X
    JMP $&code_0B8F01
}

code_0B8FE7 {
    COP [SetSavedPtr] ( &code_0B8FE7 )
    COP [SetEntryExit]
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0B9002
    RTL 

  loc_0B9002:
    COP [BranchIfButton] ( #$0031, &code_0B9009 )

  code_0B9008:
    RTL 
}

code_0B9009 {
    COP [BranchIfPlayerNear] ( #0F, &code_0B900F )
    RTL 
}

code_0B900F {
    COP [BranchOnPlayerX] ( #$000F, &code_0B909C, &code_0B9019, &code_0B909C )
}

code_0B9019 {
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_0B9063
    BPL loc_0B902A
    EOR #$FFFF
    INC 

  loc_0B902A:
    CMP #$0020
    BCC code_0B9061
    LDA $0028, Y
    CMP #$003A
    BNE code_0B9061
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0000
    BNE code_0B9061
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0B9061 )
    JSR $&code_0B9129
    COP [AddPosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_0B9135
}

code_0B9061 {
    COP [RestoreSavedPtr]

  loc_0B9063:
    CMP #$0020
    BCC code_0B909A
    LDA $0028, Y
    CMP #$003B
    BNE code_0B909A
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0001
    BNE code_0B909A
    COP [BranchIfSolidOffset] ( #00, #01, &code_0B909A )
    JSR $&code_0B9129
    COP [AddPosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_0B9135
}

code_0B909A {
    COP [RestoreSavedPtr]
}

code_0B909C {
    COP [BranchOnPlayerY] ( #$000F, &code_0B9008, &code_0B90A6, &code_0B9008 )
}

code_0B90A6 {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_0B90F0
    BPL loc_0B90B7
    EOR #$FFFF
    INC 

  loc_0B90B7:
    CMP #$0020
    BCC code_0B90EE
    LDA $0028, Y
    CMP #$003D
    BNE code_0B90EE
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0003
    BNE code_0B90EE
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0B90EE )
    JSR $&code_0B9129
    COP [AddPosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_0B9135
}

code_0B90EE {
    COP [RestoreSavedPtr]

  loc_0B90F0:
    CMP #$0020
    BCC code_0B9127
    LDA $0028, Y
    CMP #$003C
    BNE code_0B9127
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0002
    BNE code_0B9127
    COP [BranchIfSolidOffset] ( #01, #00, &code_0B9127 )
    JSR $&code_0B9129
    COP [AddPosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_0B9135
}

code_0B9127 {
    COP [RestoreSavedPtr]
}

code_0B9129 {
    LDY $24
    LDA $0012, Y
    ORA #$0010
    STA $0012, Y
    RTS 
}

code_0B9135 {
    LDY $24
    LDA $0012, Y
    AND #$FFEF
    STA $0012, Y
    RTS 
}

actor_def_0B9141 [
  actor-def < #07, #00, #00, {

  code_0B9144:
    COP [SetHitCallback] ( &code_0B9166 )

  loc_0B9148:
    COP [WaitWhileOffscreen] ( #09 )
    COP [CallScript] ( &code_0B919B )
    BRA loc_0B9148
} >
]

actor_def_0B9151 [
  actor-def < #07, #00, #00, {

  code_0B9154:
    COP [SetHFlip]
    COP [SetHitCallback] ( &code_0B9166 )

  loc_0B915A:
    COP [WaitWhileOffscreen] ( #09 )
    COP [CallScript] ( &code_0B91B2 )
    BRA loc_0B915A
} >
]

actor_def_0B9163 [
  actor-def < #05, #00, #00, {

  code_0B9166:
    COP [WaitWhileOffscreen] ( #09 )
    COP [SetSavedPtr] ( &code_0B9177 )
    COP [BranchOnPlayerX] ( #$0000, &code_0B919B, &code_0B919B, &code_0B91B2 )
} >
]

code_0B9177 {
    LDA $10
    BIT #$4000
    BNE code_0B9166
    COP [SetSavedPtr] ( &code_0B9177 )
    COP [BranchIfPlayerNear] ( #04, &code_0B91EB )
    COP [BranchOnPlayerY] ( #$000E, &code_0B91C9, &code_0B9191, &code_0B91D5 )
}

code_0B9191 {
    COP [BranchOnPlayerX] ( #$0000, &code_0B919B, &code_0B919B, &code_0B91B2 )
}

code_0B919B {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0B9258, #$0000, #$FFF5, #$0300 )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91B2 {
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0B923F, #$0000, #$FFF5, #$0300 )
    COP [StageSpriteFrame] ( #8E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91C9 {
    COP [BranchIfSolidNorth] ( &code_0B91E1 )
    COP [StageSpriteMoveY] ( #09, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91D5 {
    COP [BranchIfSolidSouth] ( &code_0B91E1 )
    COP [StageSpriteMoveY] ( #08, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91E1 {
    COP [BranchOnPlayerX] ( #$0000, &code_0B919B, &code_0B919B, &code_0B91B2 )
}

code_0B91EB {
    COP [BranchOnPlayerX] ( #$0000, &code_0B921A, &code_0B921A, &code_0B91F5 )
}

code_0B91F5 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0B91E1 )
    COP [StageSprAndHitbox] ( #8A )
    COP [StageForceMoveX] ( #04 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidWest] ( &code_0B91E1 )
    COP [StageForceMoveX] ( #04 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0B91E1
}

code_0B921A {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0B91E1 )
    COP [StageSprAndHitbox] ( #0A )
    COP [StageForceMoveX] ( #03 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidEast] ( &code_0B91E1 )
    COP [StageForceMoveX] ( #03 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0B91E1
}

code_0B923F {
    COP [SetExtraCallback] ( &code_0B92D5 )
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0B9306, #$2000 )
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [StageForceMoveX] ( #05 )
    BRA loc_0B926F
}

code_0B9258 {
    COP [SetExtraCallback] ( &code_0B92E5 )
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0B9361, #$2000 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [StageForceMoveX] ( #06 )

  loc_0B926F:
    COP [PlaySoundCh1] ( #1E )
    LDA #$0064
    STA $24
    COP [SetEntryContinue]
    COP [BranchIfSolidNibbleNe] ( #0F, &code_0B9294 )
    DEC $24
    BMI loc_0B9283
    RTL 

  loc_0B9283:
    COP [SetEntryContinue]
    COP [BranchIfSolidNibbleNe] ( #0F, &code_0B9294 )
    LDA $10
    BIT #$4000
    BNE loc_0B9292
    RTL 

  loc_0B9292:
    COP [Die]
}

code_0B9294 {
    STZ $2C
    LDA $0E
    BIT #$4000
    BNE loc_0B92AC
    COP [KillNext]
    COP [StageSpriteLoop] ( #0D, #0A )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92AC:
    COP [KillNext]
    COP [StageSpriteLoop] ( #8D, #0A )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92BB:
    COP [StageSpriteLoop] ( #0D, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92C8:
    COP [StageSpriteLoop] ( #8D, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [Die]
}

code_0B92D5 {
    LDA #$0004
    STA $extVelocityX
    LDA $14
    CLC 
    ADC #$000E
    STA $14
    BRA loc_0B92F3
}

code_0B92E5 {
    LDA #$FFFC
    STA $extVelocityX
    LDA $14
    SEC 
    SBC #$000E
    STA $14

  loc_0B92F3:
    LDA $16
    SEC 
    SBC #$000E
    STA $16
    COP [SpawnLastRel] ( @chunk_008000.code_00C56B, #00, #00, #$0302 )
    COP [Die]
}

code_0B9306 {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B9314
    COP [SetEntryContinue]
    RTL 

  loc_0B9314:
    BIT #$2280
    BEQ loc_0B931A
    RTL 

  loc_0B931A:
    LDA #$0000
    JSR $&code_0B93F4
    CLC 
    ADC #$0008
    BPL loc_0B932A
    EOR #$FFFF
    INC 

  loc_0B932A:
    CMP #$0005
    BCC loc_0B9330
    RTL 

  loc_0B9330:
    LDA $0016, Y
    SEC 
    SBC #$0014
    SEC 
    SBC $001C
    BPL loc_0B9341
    EOR #$FFFF
    INC 

  loc_0B9341:
    CMP #$000F
    BCC loc_0B9347
    RTL 

  loc_0B9347:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA #$0002
    LDY #$0003
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$92C8
    JSR $&code_0B93E7
    BRA loc_0B93B4
}

code_0B9361 {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B936F
    COP [SetEntryContinue]
    RTL 

  loc_0B936F:
    BIT #$2280
    BEQ loc_0B9375
    RTL 

  loc_0B9375:
    LDA #$0010
    JSR $&code_0B93F4
    SEC 
    SBC #$0008
    BPL loc_0B9385
    EOR #$FFFF
    INC 

  loc_0B9385:
    CMP #$0005
    BCC loc_0B938B
    RTL 

  loc_0B938B:
    LDA $0016, Y
    SEC 
    SBC #$0014
    SEC 
    SBC $001C
    BPL loc_0B939C
    EOR #$FFFF
    INC 

  loc_0B939C:
    CMP #$000F
    BCC loc_0B93A2
    RTL 

  loc_0B93A2:
    PHY 
    LDA #$0002
    LDY #$0002
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$92BB
    JSR $&code_0B93E7

  loc_0B93B4:
    PHX 
    LDX $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $0014, X
    STA $14
    LDA $0016, Y
    SEC 
    SBC $0016, X
    STA $16
    PLX 
    COP [SetEntryContinue]
    PHX 
    LDX $decelStepCounter
    LDY $24
    LDA $0014, X
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0016, X
    CLC 
    ADC $16
    STA $0016, Y
    PLX 
    RTL 
}

code_0B93E7 {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    RTS 
}

code_0B93F4 {
    CLC 
    ADC $playerWallType
    STA $0018
    LDA $playerSpeedEw
    SEC 
    SBC #$0001
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}

actor_def_0B940F [
  actor-def < #13, #00, #00, {

  code_0B9412:
    STZ $24

  loc_0B9414:
    COP [WaitWhileOffscreen] ( #0A )

  code_0B9417:
    LDA $10
    BIT #$4000
    BNE loc_0B9414
    LDA $playerWallType
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    BMI loc_0B944B
    LDA $24
    AND #$0040
    BNE loc_0B9442
    COP [StageSpriteFrame] ( #93 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0B9533 )
    INC $24
    COP [SetEntryExitNow] ( @code_0B9417 )

  loc_0B9442:
    STZ $24
    COP [StageSpriteFrame] ( #94 )
    COP [AnimOnce]
    BRA code_0B9417

  loc_0B944B:
    LDA $24
    AND #$0040
    BNE loc_0B9463
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0B94F6 )
    INC $24
    COP [SetEntryExitNow] ( @code_0B9417 )

  loc_0B9463:
    STZ $24
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    BRA code_0B9417

  code_0B946C:
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]
    JSR $&code_0B9624
    BPL loc_0B947E
    EOR #$FFFF
    INC 

  loc_0B947E:
    CMP #$0040
    BCC loc_0B9486
    LDA #$0040

  loc_0B9486:
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #15, #01 )
    LDA #$0008
    TRB $10

  code_0B949F:
    COP [BranchOnPlayerX] ( #$0000, &code_0B94A9, &code_0B94A9, &code_0B9417 )
} >
]

code_0B94A9 {
    COP [BranchIfPlayerInRelTiles] ( #FB, #FF, #00, #00, &code_0B9566 )
    BRA code_0B946C

  code_0B94B3:
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]
    JSR $&code_0B9624
    BPL loc_0B94C5
    EOR #$FFFF
    INC 

  loc_0B94C5:
    CMP #$0040
    BCC loc_0B94CD
    LDA #$0040

  loc_0B94CD:
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #95, #01 )
    LDA #$0008
    TRB $10

  code_0B94E2:
    COP [BranchOnPlayerX] ( #$0000, &code_0B9417, &code_0B94EC, &code_0B94EC )
}

code_0B94EC {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #05, #00, &code_0B9588 )
    BRA code_0B94B3
}

code_0B94F6 {
    COP [RngByte]
    AND #$0003
    STA $08
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B969D, #$2000 )
    LDA #$4000
    TSB $12
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #1B, #48, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B946C
}

code_0B9533 {
    COP [RngByte]
    AND #$0003
    STA $08
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #94 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #97 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B963A, #$2000 )
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #9B, #48, #49 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B94B3
}

code_0B9566 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B969D, #$2000 )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveXY] ( #1B, #48, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    COP [KillNext]
    JMP $&code_0B949F
}

code_0B9588 {
    COP [StageSpriteFrame] ( #96 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B963A, #$2000 )
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #9B, #48, #49 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B94E2
}

code_0B95AA {
    LDA #$8000
    TSB $joypadMaskStd
    COP [SetDeathCallback] ( @code_0B9619 )

  loc_0B95B5:
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    BRA loc_0B95B5

  loc_0B95BC:
    COP [SetDeathCallback] ( $000000 )
    LDA #$0200
    TRB $10
    LDA $14
    CLC 
    ADC $26
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC $26
    STA $moveYAlt, X
    LDA #$0010
    TRB $12
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #1A, #02 )
    COP [StageSpriteMoveXY] ( #1A, #47, #45 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10

  code_0B95F2:
    COP [SetEntryExit]

  loc_0B95F4:
    COP [BranchIfOffscreen] ( &code_0B95F2 )
    COP [BranchIfSolid] ( &code_0B95FF )
    JMP $&code_0B9417
}

code_0B95FF {
    PHX 
    TYX 
    LDA $collisionLayer, X
    PLX 
    AND #$00FF
    BIT #$000F
    BNE loc_0B9611
    JMP $&code_0B9417

  loc_0B9611:
    COP [StageSpriteMoveY] ( #1A, #01 )
    COP [AnimOnce]
    BRA loc_0B95F4
}

code_0B9619 {
    LDA #$8000
    TRB $joypadMaskStd
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0B9624 {
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    LDA $playerWallType
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    RTS 
}

code_0B963A {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B9648
    COP [SetEntryContinue]
    RTL 

  loc_0B9648:
    BIT #$2280
    BEQ loc_0B964E
    RTL 

  loc_0B964E:
    LDA #$0000
    JSR $&code_0B980C
    CLC 
    ADC #$0014
    BPL loc_0B965E
    EOR #$FFFF
    INC 

  loc_0B965E:
    CMP #$0003
    BCC loc_0B9664
    RTL 

  loc_0B9664:
    LDA $0016, Y
    SEC 
    SBC #$0004
    SEC 
    SBC $001C
    BPL loc_0B9675
    EOR #$FFFF
    INC 

  loc_0B9675:
    CMP #$000B
    BCC loc_0B967B
    RTL 

  loc_0B967B:
    PHY 
    LDA #$0001
    LDY #$0004
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA $0012, Y
    ORA #$0010
    STA $0012, Y
    LDA #$95AA
    JSR $&code_0B97E4
    BCC loc_0B9699
    RTL 

  loc_0B9699:
    STZ $2C
    BRA loc_0B96F8
}

code_0B969D {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B96AB
    COP [SetEntryContinue]
    RTL 

  loc_0B96AB:
    BIT #$2280
    BEQ loc_0B96B1
    RTL 

  loc_0B96B1:
    LDA #$0013
    JSR $&code_0B980C
    SEC 
    SBC #$0010
    BPL loc_0B96C1
    EOR #$FFFF
    INC 

  loc_0B96C1:
    CMP #$0003
    BCC loc_0B96C7
    RTL 

  loc_0B96C7:
    LDA $0016, Y
    SEC 
    SBC #$0004
    SEC 
    SBC $001C
    BPL loc_0B96D8
    EOR #$FFFF
    INC 

  loc_0B96D8:
    CMP #$000B
    BCC loc_0B96DE
    RTL 

  loc_0B96DE:
    PHY 
    LDA #$0001
    LDY #$0004
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$95AA
    JSR $&code_0B97E4
    BCC loc_0B96F3
    RTL 

  loc_0B96F3:
    LDA #$0001
    STA $2C

  loc_0B96F8:
    LDA $0012, Y
    AND #$9FFF
    ORA #$0002
    STA $0012, Y
    PHX 
    LDX $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $0014, X
    BPL loc_0B9715
    EOR #$FFFF
    INC 

  loc_0B9715:
    STA $14
    LDA $0016, Y
    SEC 
    SBC $0016, X
    BPL loc_0B9724
    EOR #$FFFF
    INC 

  loc_0B9724:
    STA $16
    PLX 
    STZ $2A
    STZ $28
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$2040
    BEQ loc_0B973B
    JMP $&code_0B97BB

  loc_0B973B:
    LDA $28
    INC 
    STA $28
    CMP #$0078
    BCC loc_0B9751
    STZ $28
    LDA #$8001
    LDY #$0004
    JSL $@chunk_008000.code_00C4DF

  loc_0B9751:
    PHX 
    LDX $decelStepCounter
    LDY $24
    LDA $2C
    BEQ loc_0B9769
    LDA $joypadCurrent
    BIT #$0100
    BEQ loc_0B9773
    INC $2A
    STZ $2C
    BRA loc_0B9773

  loc_0B9769:
    LDA $joypadCurrent
    BIT #$0200
    BEQ loc_0B9773
    INC $2C

  loc_0B9773:
    LDA $2A
    CMP #$0004
    BCS loc_0B97B8
    LDA $2C
    BNE loc_0B979B
    LDA $000E, Y
    ORA #$4000
    STA $000E, Y
    LDA $0014, X
    SEC 
    SBC $14
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC $16
    STA $0016, Y
    PLX 
    RTL 

  loc_0B979B:
    LDA $000E, Y
    AND #$BFFF
    STA $000E, Y
    LDA $0014, X
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC $16
    STA $0016, Y
    PLX 
    RTL 

  loc_0B97B8:
    PLX 
    COP [SetEntryExit]
}

code_0B97BB {
    LDY $24
    LDA #$95BC
    JSR $&code_0B97E4
    BCS loc_0B97DC
    LDA $0012, Y
    AND #$BFFD
    STA $0012, Y
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    SEC 
    SBC $0016, Y
    STA $0026, Y

  loc_0B97DC:
    LDA #$8000
    TRB $joypadMaskStd
    COP [Die]
}

code_0B97E4 {
    PHA 
    LDA $0010, Y
    BIT #$0040
    BNE loc_0B9807
    SEP #$20
    LDA $0002, Y
    CMP #$8B
    BNE loc_0B9807
    REP #$20
    PLA 
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    CLC 
    RTS 

  loc_0B9807:
    REP #$20
    PLA 
    SEC 
    RTS 
}

code_0B980C {
    CLC 
    ADC $playerWallType
    STA $0018
    LDA $playerSpeedEw
    CLC 
    ADC #$0004
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}

actor_def_0B9827 [
  actor-def < #00, #00, #00, {

  code_0B982A:
    LDA #$0011
    TSB $12
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X

  loc_0B983B:
    COP [WaitWhileOffscreen] ( #09 )

  code_0B983E:
    LDA $10
    BIT #$4000
    BNE loc_0B983B
    LDA #$000A
    STA $24
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #06, &code_0B986C )
    DEC $24
    BMI loc_0B9856
    RTL 

  loc_0B9856:
    COP [CallScript] ( &code_0B98ED )
    BRA code_0B983E

  code_0B985C:
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    COP [SetEntryExit]
    BRA loc_0B987F
} >
]

code_0B986C {
    COP [AndActorFlags] ( #$FFFD )
    LDA #$0200
    TRB $12
    COP [SpawnMarkedAfter] ( @code_0B9917, #$2200 )
    COP [LoopInit] ( #06 )

  loc_0B987F:
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    JSR $&code_0BA5C1
    CLC 
    ADC $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    JSR $&code_0BA5C1
    CLC 
    ADC $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $16
    COP [BranchIfSolid] ( &code_0B985C )
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    PLA 
    STA $moveYAlt, X
    PLA 
    STA $moveXAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [StageSpriteLoop] ( #00, #04 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [SetHitCallback] ( #$0000 )

  code_0B98DB:
    COP [AndActorFlags] ( #$FFFD )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoop] ( #00, #0C )
    COP [AnimLoop]
    JMP $&code_0B983E
}

code_0B98ED {
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [RestoreSavedPtr]
}

code_0B9917 {
    COP [LoopInit] ( #04 )
    COP [SpawnAfterFlags] ( @code_0B9939, #$0300 )
    LDA $24
    STA $0024, Y
    COP [WaitByte] ( #3F )
    COP [LoopNext]
    PHX 
    PHD 
    LDA $24
    TCD 
    TAX 
    COP [SetHitCallback] ( &code_0B98DB )
    PLD 
    PLX 
    COP [Die]
}

code_0B9939 {
    COP [PlaySoundCh1] ( #26 )
    LDA #$0080
    STA $orbitDiameter, X
    LDA #$0080
    STA $orbitAngle, X
    LDA #$0000
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #1D )
    BRA loc_0B9979

  loc_0B9956:
    LDA $28
    CMP #$001F
    BCS loc_0B9979
    LDA $7F100C, X
    INC 
    STA $7F100C, X
    AND #$0001
    BNE loc_0B9979
    INC $28
    LDA $28
    CMP #$001F
    BCC loc_0B9979
    LDA #$0100
    TRB $10

  loc_0B9979:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9956
    JSR $&code_0B9B86
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B9979
    LDY $24
    LDA $0012, Y
    BIT #$0200
    BNE loc_0B99BD
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B999F
    JMP $&code_0B9A89

  loc_0B999F:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 
}

code_0B99B2 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ code_0B99B2
    JSR $&code_0B9B86

  loc_0B99BD:
    COP [SetEntryContinue]
    DEC $26
    BMI code_0B99B2
    LDA $orbitDiameter, X
    BEQ loc_0B99ED
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitDiameter, X
    SEC 
    SBC #$0002
    BPL loc_0B99DC
    LDA #$0000

  loc_0B99DC:
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 

  loc_0B99ED:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B99ED
    JSR $&code_0B9B86
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B99ED
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitDiameter, X
    CLC 
    ADC #$0008
    CLC 
    ADC $0B02
    BIT #$FF00
    BNE loc_0B9A48
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    LDA $14
    SEC 
    SBC $7F100C, X
    STA $moveXAlt, X
    LDA $14
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $7F100E, X
    STA $moveYAlt, X
    LDA $16
    STA $7F100E, X
    RTL 

  loc_0B9A48:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9A48
    JSR $&code_0B9B86
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B9A48
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_0B9A71
    RTL 

  loc_0B9A71:
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #13 )
    LDA $parentId, X
    TAY 
    LDA $0012, Y
    AND #$FDFF
    STA $0012, Y
    COP [Die]
}

code_0B9A89 {
    LDY $24
    LDA $0014, Y
    STA $animScratch, X
    LDA $0016, Y
    STA $animScratch+2, X
    BRA loc_0B9AA6

  loc_0B9A9B:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9A9B
    JSR $&code_0B9B86

  loc_0B9AA6:
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B9A9B
    LDA $orbitDiameter, X
    BEQ loc_0B9AE0
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $16
    JSL $@chunk_008000.code_00F4C7
    LDA $orbitDiameter, X
    SEC 
    SBC #$0002
    BPL loc_0B9ACF
    LDA #$0000

  loc_0B9ACF:
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 

  loc_0B9AE0:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9AE0
    JSR $&code_0B9B86
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B9AE0
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $16
    JSL $@chunk_008000.code_00F4C7
    LDA $orbitDiameter, X
    CLC 
    ADC #$0008
    CLC 
    ADC $0B02
    BIT #$FF00
    BNE loc_0B9B45
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    LDA $14
    SEC 
    SBC $7F100C, X
    STA $moveXAlt, X
    LDA $14
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $7F100E, X
    STA $moveYAlt, X
    LDA $16
    STA $7F100E, X
    RTL 

  loc_0B9B45:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9B45
    JSR $&code_0B9B86
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0B9B45
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_0B9B6E
    RTL 

  loc_0B9B6E:
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #13 )
    LDA $parentId, X
    TAY 
    LDA $0012, Y
    AND #$FDFF
    STA $0012, Y
    COP [Die]
}

code_0B9B86 {
    LDA $08
    INC 
    STA $26
    STZ $08
    RTS 
}

actor_def_0B9B8E [
  actor-def < #03, #00, #00, {

  code_0B9B91:
    LDA #$2000
    TSB $12
    BRA loc_0B9B9B
} >
]

actor_def_0B9B98 [
  actor-def < #02, #00, #00, {

  loc_0B9B9B:
    LDA #$0010
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X
    LDA #$0150
    STA $7F100E, X
    LDA $14
    STA $7F100C, X

  loc_0B9BBE:
    LDA $16
    STA $26

  loc_0B9BC2:
    COP [StageForceMoveY] ( #01 )

  loc_0B9BC5:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9BC2
    LDA $08
    INC 
    STA $24
    STZ $08
    JSR $&code_0B9CD4
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $26
    SEC 
    SBC $16
    BPL loc_0B9BF8
    EOR #$FFFF
    INC 

  loc_0B9BF8:
    CMP $7F100E, X
    BEQ loc_0B9C05
    DEC $24
    BMI loc_0B9C03
    RTL 

  loc_0B9C03:
    BRA loc_0B9BC5

  loc_0B9C05:
    STZ $2E
    LDA $12
    BIT #$2000
    BNE loc_0B9C1F
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$2000
    TSB $12
    BRA loc_0B9BBE

  loc_0B9C1F:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    BRA loc_0B9BBE
} >
]

actor_def_0B9C30 [
  actor-def < #04, #00, #00, {

  code_0B9C33:
    LDA #$4000
    TSB $12
    BRA loc_0B9C3F
} >
]

actor_def_0B9C3A [
  actor-def < #04, #00, #00, {

  code_0B9C3D:
    COP [SetHFlip]

  loc_0B9C3F:
    LDA #$0010
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X
    LDA #$0150
    STA $7F100E, X
    LDA $16
    STA $7F100C, X

  loc_0B9C62:
    LDA $14
    STA $26

  loc_0B9C66:
    COP [StageForceMoveX] ( #01 )

  loc_0B9C69:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9C66
    LDA $08
    INC 
    STA $24
    STZ $08
    JSR $&code_0B9CD4
    CLC 
    ADC $7F100C, X
    STA $16
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $26
    SEC 
    SBC $14
    BPL loc_0B9C9C
    EOR #$FFFF
    INC 

  loc_0B9C9C:
    CMP $7F100E, X
    BEQ loc_0B9CA9
    DEC $24
    BMI loc_0B9CA7
    RTL 

  loc_0B9CA7:
    BRA loc_0B9C69

  loc_0B9CA9:
    STZ $2C
    LDA $12
    BIT #$4000
    BNE loc_0B9CC3
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    LDA #$4000
    TSB $12
    BRA loc_0B9C62

  loc_0B9CC3:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    BRA loc_0B9C62
} >
]

code_0B9CD4 {
    LDA $orbitAngle, X
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C36C.binary_01C43D, Y
    BPL loc_0B9CE5
    EOR #$FF
    INC 
    SEC 

  loc_0B9CE5:
    XBA 
    LDA $orbitDiameter, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_0B9CFA
    EOR #$FFFF
    INC 

  loc_0B9CFA:
    RTS 
}

actor_def_0B9CFB [
  actor-def < #02, #00, #00, {

  code_0B9CFE:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9D06:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9D09:
    LDA $10
    BIT #$4000
    BNE loc_0B9D06
    COP [BranchOnPlayerY] ( #$0000, &code_0B9DD8, &code_0B9D1A, &code_0B9D1A )
} >
]

code_0B9D1A {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #08, &code_0B9D30 )

  loc_0B9D22:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #02, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9D3F
}

code_0B9D30 {
    COP [CallScript] ( &code_0B9D72 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D22

  loc_0B9D3C:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9D3F:
    LDA $10
    BIT #$4000
    BNE loc_0B9D3C
    COP [BranchOnPlayerY] ( #$0000, &code_0B9E0E, &code_0B9D50, &code_0B9D50 )
}

code_0B9D50 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #08, &code_0B9D66 )

  loc_0B9D58:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #02, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D09
}

code_0B9D66 {
    COP [CallScript] ( &code_0B9D72 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D58
}

code_0B9D72 {
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9D95, #$FFFD, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9D95, #$0004, #$FFF8, #$0202 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9D95 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #20, #03 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9DAA:
    COP [StageSpriteMoveY] ( #20, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9DAA
    COP [Die]
}

actor_def_0B9DB9 [
  actor-def < #03, #00, #00, {

  code_0B9DBC:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9DC4:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9DC7:
    LDA $10
    BIT #$4000
    BNE loc_0B9DC4
    COP [BranchOnPlayerY] ( #$0000, &code_0B9DD8, &code_0B9DD8, &code_0B9D1A )
} >
]

code_0B9DD8 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #F8, #01, #00, &code_0B9DEE )

  loc_0B9DE0:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #03, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9DFD
}

code_0B9DEE {
    COP [CallScript] ( &code_0B9E30 )
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    BRA loc_0B9DE0

  loc_0B9DFA:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9DFD:
    LDA $10
    BIT #$4000
    BNE loc_0B9DFA
    COP [BranchOnPlayerY] ( #$0000, &code_0B9E0E, &code_0B9E0E, &code_0B9D50 )
}

code_0B9E0E {
    COP [BranchIfPlayerInRelTiles] ( #FF, #F8, #01, #00, &code_0B9E24 )

  loc_0B9E16:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #03, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9DC7
}

code_0B9E24 {
    COP [CallScript] ( &code_0B9E30 )
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    BRA loc_0B9E16
}

code_0B9E30 {
    COP [StageSpriteLoop] ( #1B, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9E53, #$FFFD, #$FFF8, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0B9E53, #$0004, #$FFF8, #$0200 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9E53 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9E68:
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9E68
    COP [Die]
}

actor_def_0B9E77 [
  actor-def < #04, #00, #00, {

  code_0B9E7A:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9E82:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9E85:
    LDA $10
    BIT #$4000
    BNE loc_0B9E82
    COP [BranchOnPlayerX] ( #$0000, &code_0B9E96, &code_0B9E96, &code_0B9F60 )
} >
]

code_0B9E96 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #F8, #FF, #00, #01, &code_0B9EB1 )

  loc_0B9EA3:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #04, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9EC0
}

code_0B9EB1 {
    COP [CallScript] ( &code_0B9EF8 )
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
    BRA loc_0B9EA3

  loc_0B9EBD:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9EC0:
    LDA $10
    BIT #$4000
    BNE loc_0B9EBD
    COP [BranchOnPlayerX] ( #$0000, &code_0B9ED1, &code_0B9ED1, &code_0B9F9B )
}

code_0B9ED1 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #F8, #FF, #00, #01, &code_0B9EEC )

  loc_0B9EDE:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #04, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9E85
}

code_0B9EEC {
    COP [CallScript] ( &code_0B9EF8 )
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
    BRA loc_0B9EDE
}

code_0B9EF8 {
    COP [StageSpriteLoop] ( #1C, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9F1B, #$FFFA, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9F1B, #$FFFA, #$FFF6, #$0202 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9F1B {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveX] ( #20, #04 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9F30:
    COP [StageSpriteMoveX] ( #20, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9F30
    COP [Die]
}

actor_def_0B9F3F [
  actor-def < #04, #00, #00, {

  code_0B9F42:
    COP [SetHFlip]
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9F4C:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9F4F:
    LDA $10
    BIT #$4000
    BNE loc_0B9F4C
    COP [BranchOnPlayerX] ( #$0000, &code_0B9E96, &code_0B9F60, &code_0B9F60 )
} >
]

code_0B9F60 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #08, #01, &code_0B9F7B )

  loc_0B9F6D:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #84, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9F8A
}

code_0B9F7B {
    COP [CallScript] ( &code_0B9FC2 )
    COP [StageSpriteLoop] ( #84, #02 )
    COP [AnimLoop]
    BRA loc_0B9F6D

  loc_0B9F87:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9F8A:
    LDA $10
    BIT #$4000
    BNE loc_0B9F87
    COP [BranchOnPlayerX] ( #$0000, &code_0B9ED1, &code_0B9F9B, &code_0B9F9B )
}

code_0B9F9B {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #08, #01, &code_0B9FB6 )

  loc_0B9FA8:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #84, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9F4F
}

code_0B9FB6 {
    COP [CallScript] ( &code_0B9FC2 )
    COP [StageSpriteLoop] ( #84, #02 )
    COP [AnimLoop]
    BRA loc_0B9FA8
}

code_0B9FC2 {
    COP [StageSpriteLoop] ( #9C, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9FE5, #$0006, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9FE5, #$0006, #$FFF6, #$0202 )
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9FE5 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveX] ( #20, #03 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9FFA:
    COP [StageSpriteMoveX] ( #20, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9FFA
    COP [Die]
}

actor_def_0BA009 [
  actor-def < #06, #00, #00, {

  code_0BA00C:
    COP [SetHitCallback] ( &code_0BA0BE )

  code_0BA010:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0BA021 )
    RTL 
} >
]

code_0BA021 {
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0BA010 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA538, #$0201 )
    BRA code_0BA010
}

actor_def_0BA035 [
  actor-def < #05, #00, #00, {

  code_0BA038:
    COP [SetHitCallback] ( &code_0BA0BE )

  code_0BA03C:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #05, &code_0BA04D )
    RTL 
} >
]

code_0BA04D {
    COP [BranchIfSolidOffset] ( #00, #04, &code_0BA03C )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA546, #$0201 )
    BRA code_0BA03C
}

actor_def_0BA061 [
  actor-def < #07, #00, #00, {

  code_0BA064:
    COP [SetHitCallback] ( &code_0BA0BE )

  code_0BA068:
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FC, #FF, #00, #01, &code_0BA079 )
    RTL 
} >
]

code_0BA079 {
    COP [BranchIfSolidOffset] ( #FC, #00, &code_0BA068 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA4EE, #$0201 )
    BRA code_0BA068
}

actor_def_0BA08D [
  actor-def < #07, #00, #00, {

  code_0BA090:
    COP [SetHFlip]
    COP [SetHitCallback] ( &code_0BA0BE )

  code_0BA096:
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #04, #01, &code_0BA0A7 )
    RTL 
} >
]

code_0BA0A7 {
    COP [BranchIfSolidOffset] ( #04, #00, &code_0BA096 )
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA513, #$0201 )
    BRA code_0BA096
}

actor_def_0BA0BB [
  actor-def < #05, #00, #00, {

  code_0BA0BE:
    COP [WaitWhileOffscreen] ( #0B )
    COP [BranchNearerAxis] ( &code_0BA0C7, &code_0BA2D7 )
} >
]

code_0BA0C7 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA0D1, &code_0BA0D1, &code_0BA1BA )
}

code_0BA0D1 {
    COP [BranchIfSolidWest] ( &code_0BA117 )
    COP [StageSpriteMoveX] ( #0A, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FB, #FE, #00, #01, &code_0BA0E5 )
    BRA code_0BA0BE
}

code_0BA0E5 {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA0EF
    JMP $&code_0BA5A6

  loc_0BA0EF:
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA4EE, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA101, &code_0BA2D7 )
}

code_0BA101 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA10B, &code_0BA10B, &code_0BA0C7 )
}

code_0BA10B {
    COP [BranchIfSolidEast] ( &code_0BA0BE )
    COP [StageSpriteMoveX] ( #0A, #11 )
    COP [AnimOnce]
    BRA code_0BA0BE
}

code_0BA117 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0BA12C )
    LDA #$FFE0
    BRA loc_0BA16A
}

code_0BA12C {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0BA13C )
    LDA #$FFD0
    BRA loc_0BA16A
}

code_0BA13C {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FC, #00, &code_0BA14C )
    LDA #$FFC0
    BRA loc_0BA16A
}

code_0BA14C {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FB, #00, &code_0BA15C )
    LDA #$FFB0
    BRA loc_0BA16A
}

code_0BA15C {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FA, #00, &code_0BA5A6 )
    LDA #$FFA0

  loc_0BA16A:
    STA $24
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA2B6, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA180:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA2AA, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA180
    LDA $14
    CLC 
    ADC $24
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA1A2
    RTL 

  loc_0BA1A2:
    COP [MoveToward] ( #87, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0BE
}

code_0BA1BA {
    COP [BranchIfSolidEast] ( &code_0BA202 )
    COP [StageSpriteMoveX] ( #8A, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #05, #01, &code_0BA1CF )
    JMP $&code_0BA0BE
}

code_0BA1CF {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA1D9
    JMP $&code_0BA5A6

  loc_0BA1D9:
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA513, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA1EB, &code_0BA2D7 )
}

code_0BA1EB {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA0C7, &code_0BA0C7, &code_0BA1F5 )
}

code_0BA1F5 {
    COP [BranchIfSolidWest] ( &code_0BA0BE )
    COP [StageSpriteMoveX] ( #8A, #12 )
    COP [AnimOnce]
    JMP $&code_0BA0BE
}

code_0BA202 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #02, #00, &code_0BA217 )
    LDA #$0020
    BRA loc_0BA255
}

code_0BA217 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0BA227 )
    LDA #$0030
    BRA loc_0BA255
}

code_0BA227 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #04, #00, &code_0BA237 )
    LDA #$0040
    BRA loc_0BA255
}

code_0BA237 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #05, #00, &code_0BA247 )
    LDA #$0050
    BRA loc_0BA255
}

code_0BA247 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #06, #00, &code_0BA5A6 )
    LDA #$0060

  loc_0BA255:
    STA $24
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA2B6, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA26B:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA2AA, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA26B
    LDA #$0010
    TSB $12
    LDA $14
    CLC 
    ADC $24
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA292
    RTL 

  loc_0BA292:
    COP [MoveToward] ( #07, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0BE
}

code_0BA2AA {
    COP [StageSprAndHitbox] ( #19 )
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    JSL $@chunk_0A8000.code_0AA35F
    RTL 
}

code_0BA2B6 {
    LDA $26
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #19, #02 )
    LDA $parentId, X
    TAY 
    LDA #$0000
    STA $0024, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BA2D7 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA2E1, &code_0BA2E1, &code_0BA3D1 )
}

code_0BA2E1 {
    COP [BranchIfSolidNorth] ( &code_0BA329 )
    COP [StageSpriteMoveY] ( #09, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #FF, &code_0BA2F6 )
    JMP $&code_0BA0BE
}

code_0BA2F6 {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA300
    JMP $&code_0BA5A6

  loc_0BA300:
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA538, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA0C7, &code_0BA312 )
}

code_0BA312 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA31C, &code_0BA31C, &code_0BA2D7 )
}

code_0BA31C {
    COP [BranchIfSolidSouth] ( &code_0BA0BE )
    COP [StageSpriteMoveY] ( #09, #11 )
    COP [AnimOnce]
    JMP $&code_0BA0BE
}

code_0BA329 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0BA33E )
    LDA #$FFE0
    BRA loc_0BA37C
}

code_0BA33E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0BA34E )
    LDA #$FFD0
    BRA loc_0BA37C
}

code_0BA34E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0BA35E )
    LDA #$FFC0
    BRA loc_0BA37C
}

code_0BA35E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FB, &code_0BA36E )
    LDA #$FFB0
    BRA loc_0BA37C
}

code_0BA36E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FA, &code_0BA5A6 )
    LDA #$FFB0

  loc_0BA37C:
    STA $24
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA4CD, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA392:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA4C1, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA392
    LDA #$0010
    TSB $12
    LDA $14
    STA $moveXAlt, X
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA3B9
    RTL 

  loc_0BA3B9:
    COP [MoveToward] ( #05, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0BE
}

code_0BA3D1 {
    COP [BranchIfSolidSouth] ( &code_0BA419 )
    COP [StageSpriteMoveY] ( #08, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #05, &code_0BA3E6 )
    JMP $&code_0BA0BE
}

code_0BA3E6 {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA3F0
    JMP $&code_0BA5A6

  loc_0BA3F0:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA546, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA0C7, &code_0BA402 )
}

code_0BA402 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA2D7, &code_0BA2D7, &code_0BA40C )
}

code_0BA40C {
    COP [BranchIfSolidNorth] ( &code_0BA0BE )
    COP [StageSpriteMoveY] ( #08, #12 )
    COP [AnimOnce]
    JMP $&code_0BA0BE
}

code_0BA419 {
    JSR $&code_0BA592
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BA42E )
    LDA #$0020
    BRA loc_0BA46C
}

code_0BA42E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #03, &code_0BA43E )
    LDA #$0030
    BRA loc_0BA46C
}

code_0BA43E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0BA44E )
    LDA #$0040
    BRA loc_0BA46C
}

code_0BA44E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #05, &code_0BA45E )
    LDA #$0050
    BRA loc_0BA46C
}

code_0BA45E {
    JSR $&code_0BA592
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #06, &code_0BA5A6 )
    LDA #$0060

  loc_0BA46C:
    STA $24
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA4CD, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA482:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA4C1, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA482
    LDA #$0010
    TSB $12
    LDA $14
    STA $moveXAlt, X
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA4A9
    RTL 

  loc_0BA4A9:
    COP [MoveToward] ( #06, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0BE
}

code_0BA4C1 {
    COP [StageSprAndHitbox] ( #18 )
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    JSL $@chunk_0A8000.code_0AA35F
    RTL 
}

code_0BA4CD {
    LDA $14
    STA $moveXAlt, X
    LDA $26
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #18, #02 )
    LDA $parentId, X
    TAY 
    LDA #$0000
    STA $0024, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BA4EE {
    COP [PlaySoundCh1] ( #1E )
    COP [AddPosition] ( #00, #F8 )
    LDA $14
    SEC 
    SBC #$0040
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #15, #03 )
    BRA loc_0BA564
}

code_0BA513 {
    COP [PlaySoundCh1] ( #1E )
    COP [AddPosition] ( #00, #F8 )
    LDA $14
    CLC 
    ADC #$0040
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #95, #03 )
    BRA loc_0BA564
}

code_0BA538 {
    COP [PlaySoundCh1] ( #1E )
    COP [StageSprAndHitbox] ( #14 )
    LDA $16
    CLC 
    ADC #$FFC0
    BRA loc_0BA552
}

code_0BA546 {
    COP [PlaySoundCh1] ( #1E )
    COP [StageSprAndHitbox] ( #13 )
    LDA $16
    CLC 
    ADC #$0040

  loc_0BA552:
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #FF, #03 )

  loc_0BA564:
    COP [AndActorFlags] ( #$FFEF )
    COP [BranchIfSolid] ( &code_0BA57F )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #12, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #16, #0A )
    COP [AnimLoop]
    COP [Die]
}

code_0BA57F {
    COP [LoopInit] ( #10 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_0BA592 {
    PHD 
    LDA #$0000
    TCD 
    LDA [$80], Y
    AND #$000F
    PLD 
    CMP #$000F
    BCS loc_0BA5A3
    RTS 

  loc_0BA5A3:
    PLA 
    COP [SetEntryExit]
}

code_0BA5A6 {
    LDA #$0010
    TRB $12
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BA5B9 )
}

code_list_0BA5B9 [
  &code_0BA0D1   ;00
  &code_0BA1BA   ;01
  &code_0BA3D1   ;02
  &code_0BA2E1   ;03
]

code_0BA5C1 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    RTS 
}

actor_def_0BA5CB [
  actor-def < #00, #00, #20, {

  loc_0BA5CE:
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FFFE
    STA $0010, Y
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #08, #0C, #0D, #0E, &code_0BA5ED )
    COP [BranchIfPlayerInAbsTiles] ( #14, #0C, #19, #0E, &code_0BA5ED )
    RTL 
} >
]

code_0BA5ED {
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$0001
    STA $0010, Y
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$01B0
    BEQ loc_0BA604
    RTL 

  loc_0BA604:
    BRA loc_0BA5CE
}

actor_def_0BA606 [
  actor-def < #00, #00, #00, {

  code_0BA609:
    LDA #$8191
    TSB $12
    COP [SpawnLastRel] ( @code_0BA64B, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0BA622
    JMP $&code_0BA6B2

  loc_0BA622:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0BA648
    RTL 

  loc_0BA648:
    JMP $&code_0BA6B2
} >
]

code_0BA64B {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0BA653
    RTL 

  loc_0BA653:
    COP [ExitIfFlagByte] ( #01, #00 )
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0BA67D
    RTL 

  loc_0BA67D:
    COP [SetFlagWord] ( #$0179 )
    LDA #$0002
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$01F8, #$03A0, #03, #$4430 )
    COP [Die]
}

actor_def_0BA699 [
  actor-def < #00, #00, #00, {

  code_0BA69C:
    LDA #$0004
    JSL $@chunk_008000.code_00B10F
    BCC loc_0BA6AD
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0BA6AD:
    LDA #$8191
    TSB $12
} >
]

code_0BA6B2 {
    LDY $decelStepCounter
    LDA $0012, Y
    ORA #$0008
    STA $0012, Y
    LDA #$0A0A
    STA $20
    LDA #$1858
    STA $22
    LDA #$0000
    STA $orbitAngle, X
    COP [SpawnMarkedAfter] ( @code_0AFF40, #$2000 )
    TYA 
    STA $scratch1010+6, X
    COP [SetDeathCallback] ( @code_0BA9A5 )

  code_0BA6E0:
    LDA $orbitAngle, X
    CMP #$0002
    BCC loc_0BA6EF
    COP [SetHitCallback] ( &code_0BA7A0 )
    BRA loc_0BA6F3

  loc_0BA6EF:
    COP [SetHitCallback] ( &code_0BA88D )

  loc_0BA6F3:
    COP [SetSavedPtr] ( &code_0BA6E0 )
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BA705 )
}

code_list_0BA705 [
  &code_0BA950   ;00
  &code_0BA950   ;01
  &code_0BA74C   ;02
  &code_0BA74C   ;03
  &code_0BA715   ;04
  &code_0BA715   ;05
  &code_0BA715   ;06
  &code_0BA715   ;07
]

code_0BA715 {
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [RngByte]
    PHA 
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $playerWallType
    STA $moveXAlt, X
    PLA 
    LSR 
    LSR 
    SEC 
    SBC #$001F
    CLC 
    ADC $playerSpeedEw
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #01, #FF )
    COP [TickMove]
    COP [RestoreSavedPtr]
}

code_0BA74C {
    COP [SpawnBeforeFlags] ( @code_0BA765, #$2202 )
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSpriteLoop] ( #FF, #0A )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BA765 {
    COP [AddPosition] ( #0C, #B2 )
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #20 )
    LDA #$0004
    CLC 
    ADC $0B02
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E5F3, #$2000 )
    LDA $decelStepCounter
    STA $0024, Y

  loc_0BA791:
    COP [StageSpriteLoop] ( #0C, #08 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0BA791
    COP [Die]
}

code_0BA7A0 {
    LDA #$0007
    STA $26

  loc_0BA7A5:
    COP [SpawnAfterRelFlags] ( @code_0BAA8D, #$0000, #$FFFC, #$2200 )
    LDA #$0000
    STA $0026, Y
    DEC $26
    BPL loc_0BA7A5
    LDA #$0001
    STA $0026, Y
    LDA #$0200
    TSB $10
    COP [PlaySoundCh1] ( #0C )
    LDA $orbitAngle, X
    CLC 
    ADC #$0009
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA #$0008
    TSB $12
    LDA #$0001
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    COP [SetEntryExit]
    LDA $26
    BEQ loc_0BA80C
    JSR $&code_0BA825
    JSR $&code_0BA859
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    RTL 

  loc_0BA80C:
    LDA #$0008
    TRB $12
    LDA #$00FF
    STA $24
    LDA #$0007
    STA $0000
    LDA #$AC62
    JSR $&code_0BAA2D
    JMP $&code_0BA8DE
}

code_0BA825 {
    LDA $moveXAlt, X
    BPL loc_0BA842
    LDA $14
    BMI loc_0BA835
    CMP #$0050
    BCC loc_0BA835
    RTS 

  loc_0BA835:
    LDA $moveXAlt, X
    EOR #$FFFF
    INC 
    STA $moveXAlt, X
    RTS 

  loc_0BA842:
    LDA $14
    BMI loc_0BA84B
    CMP #$01B0
    BCS loc_0BA84C

  loc_0BA84B:
    RTS 

  loc_0BA84C:
    LDA $moveXAlt, X
    EOR #$FFFF
    INC 
    STA $moveXAlt, X
    RTS 
}

code_0BA859 {
    LDA $moveYAlt, X
    BPL loc_0BA876
    LDA $16
    BMI loc_0BA869
    CMP #$0080
    BCC loc_0BA869
    RTS 

  loc_0BA869:
    LDA $moveYAlt, X
    EOR #$FFFF
    INC 
    STA $moveYAlt, X
    RTS 

  loc_0BA876:
    LDA $16
    BMI loc_0BA87F
    CMP #$01B0
    BCS loc_0BA880

  loc_0BA87F:
    RTS 

  loc_0BA880:
    LDA $moveYAlt, X
    EOR #$FFFF
    INC 
    STA $moveYAlt, X
    RTS 
}

code_0BA88D {
    LDA #$0007
    STA $26

  loc_0BA892:
    COP [SpawnAfterRelFlags] ( @code_0BAB96, #$0000, #$FFFC, #$2200 )
    DEC $26
    BPL loc_0BA892
    STZ $26
    LDA #$0200
    TSB $10
    LDA #$00FF
    STA $24
    COP [PlaySoundCh1] ( #0C )
    LDA $orbitAngle, X
    CLC 
    ADC #$0009
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA $0B02
    XBA 
    LSR 
    LSR 
    CLC 
    ADC #$0168
    STA $08
    COP [SetEntryExit]
    LDA #$0007
    STA $0000
    LDA #$AC60
    JSR $&code_0BAA46
}

code_0BA8DE {
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA8E5
    RTL 

  loc_0BA8E5:
    LDA #$0007
    STA $0000
    LDA #$AC92
    JSR $&code_0BAA2D
    LDA $currentHp, X
    CMP #$0014
    BCC loc_0BA919
    CMP #$001E
    BCC loc_0BA901
    BRA loc_0BA931

  loc_0BA901:
    LDA $orbitAngle, X
    CMP #$0001
    BEQ loc_0BA931
    LDA #$0001
    STA $orbitAngle, X
    COP [SpawnThinkerParam] ( #5C, @chunk_008000.code_00B5C4 )
    BRA loc_0BA931

  loc_0BA919:
    LDA $orbitAngle, X
    CMP #$0002
    BEQ loc_0BA931
    LDA #$0002
    STA $orbitAngle, X
    COP [SpawnThinkerParam] ( #5D, @chunk_008000.code_00B5C4 )
    BRA loc_0BA931

  loc_0BA931:
    COP [PlaySoundCh1] ( #29 )
    LDA #$2000
    TRB $10
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    JMP $&code_0BA6E0
}

code_0BA950 {
    COP [SetHitCallback] ( &code_0BA99A )
    COP [PlaySoundCh1] ( #15 )
    LDA $orbitAngle, X
    CLC 
    ADC #$0003
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $28
    CLC 
    ADC #$0003
    STA $28
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BAC9F, #$2800 )
    COP [StageSpriteLoop] ( #FF, #0A )
    COP [AnimLoop]
    LDY $06
    LDA #$0001
    STA $0024, Y
    LDA $orbitAngle, X
    CLC 
    ADC #$0000
    STA $28
    COP [StageSpriteLoop] ( #FF, #12 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BA99A {
    LDY $06
    LDA #$0001
    STA $0024, Y
    JMP $&code_0BA88D
}

code_0BA9A5 {
    LDY $06
    LDA #$0001
    STA $0024, Y
    LDA $slopeCurvePtrB
    BIT #$0200
    BEQ loc_0BA9B8
    COP [SetEntryContinue]
    RTL 

  loc_0BA9B8:
    LDA #$0020
    TSB $slopeCurvePtrB
    COP [SpawnLastRel] ( @chunk_0A8000.code_0AA2B1, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0BA9D5, #00, #E0, #$2300 )
    COP [WaitByte] ( #3B )
    COP [Die]
}

code_0BA9D5 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0C )
    COP [SpawnLastRel] ( @code_0BA9FC, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0BAA06, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [LoopNext]
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0BA9FC {
    JSR $&code_0BAA10
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BAA06 {
    JSR $&code_0BAA10
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0BAA10 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0BAA2D {
    LDY $06
    PHA 

  loc_0BAA30:
    LDA #$0000
    STA $0008, Y
    LDA $01, S
    STA $0000, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0BAA30
    PLA 
    RTS 
}

code_0BAA46 {
    LDY $06
    STZ $0018
    STZ $001C
    PHA 

  loc_0BAA4F:
    LDA #$0000
    STA $0008, Y
    LDA $01, S
    STA $0000, Y
    LDA $0014, Y
    CLC 
    ADC $0018
    STA $0018
    LDA $0016, Y
    CLC 
    ADC $001C
    STA $001C
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0BAA4F
    LDA $0018
    LSR 
    LSR 
    LSR 
    STA $14
    LDA $001C
    LSR 
    LSR 
    LSR 
    STA $16
    PLA 
    RTS 
}

code_0BAA8D {
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    LDA #$00B9
    STA $12
    LDA $26
    STA $animScratch+2, X
    LDA $24
    STA $26
    COP [StageSprAndHitbox] ( #0E )

  loc_0BAAA7:
    COP [WaitByte] ( #03 )
    COP [PlaySoundCh1] ( #26 )
    LDY $26
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BAAA7
    LDA $0026, Y
    AND #$0007
    PHX 
    TAX 
    INC 
    STA $0026, Y
    LDA $@loc_0BAC97, X
    PLX 
    AND #$00FF
    STA $orbitAngle, X
    LDA #$0002
    STA $orbitDiameter, X
    LDA #$0000
    STA $animScratch, X

  loc_0BAADD:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAADD
    LDA $08
    STA $24
    STZ $08

  loc_0BAAE9:
    JSR $&code_0BAB8F
    COP [SetEntryExit]
    LDA $orbitDiameter, X
    CMP #$0080
    BCS loc_0BAB08
    CLC 
    ADC #$0003
    ADC $0B02
    STA $orbitDiameter, X
    DEC $24
    BPL loc_0BAAE9
    BRA loc_0BAADD

  loc_0BAB08:
    LDA $animScratch+2, X
    BNE loc_0BAB43

  loc_0BAB0E:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAB0E
    LDA $08
    STZ $08
    STA $24
    JSR $&code_0BAB8F
    COP [SetEntryExit]

  loc_0BAB1F:
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    CLC 
    ADC $0B02
    STA $orbitAngle, X
    LDA $0036
    LSR 
    BCC loc_0BAB3C
    LDA #$2000
    TSB $10
    BRA loc_0BAB0E

  loc_0BAB3C:
    LDA #$2000
    TRB $10
    BRA loc_0BAB0E

  loc_0BAB43:
    LDA #$0200
    TRB $10
    COP [SetDeathCallback] ( @code_0BAB7B )
    LDA #$0000
    STA $currentHp, X

  loc_0BAB54:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAB54
    LDA $08
    STZ $08
    STA $24

  loc_0BAB60:
    JSR $&code_0BAB8F
    COP [SetEntryExit]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    CLC 
    ADC $0B02
    STA $orbitAngle, X
    DEC $24
    BPL loc_0BAB60
    BRA loc_0BAB54
}

code_0BAB7B {
    LDA #$0200
    TSB $10
    LDA #$0040
    TRB $10
    LDY $26
    LDA #$0000
    STA $0026, Y
    BRA loc_0BAB1F
}

code_0BAB8F {
    LDY $26
    JSL $@chunk_008000.code_00F4BD
    RTS 
}

code_0BAB96 {
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    COP [StageSprAndHitbox] ( #0E )

  loc_0BABA1:
    COP [WaitByte] ( #03 )
    COP [PlaySoundCh1] ( #26 )
    LDY $24
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BABA1
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDY $24
    LDA $0026, Y
    AND #$0007
    PHX 
    TAX 
    INC 
    STA $0026, Y
    LDA $@loc_0BAC97, X
    PLX 
    AND #$00FF
    STA $orbitAngle, X
    LDA #$000A
    STA $orbitDiameter, X
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    LDA #$0000
    STA $animScratch, X

  loc_0BABEA:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BABEA
    LDA $08
    STA $26
    STZ $08
    LDA $animScratch, X
    CMP #$0006
    BCS loc_0BAC10
    INC 
    STA $animScratch, X

  loc_0BAC04:
    JSL $@chunk_008000.code_00F4C7
    COP [SetEntryExit]
    DEC $26
    BPL loc_0BAC04
    BRA loc_0BABEA

  loc_0BAC10:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA $24
    STA $26
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E79D, #$2000 )
    TYA 
    STA $orbitDiameter, X
    LDA #$800E
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    LDA $decelStepCounter
    STA $0024, Y
    COP [SetEntryExit]

  loc_0BAC3B:
    LDA $orbitDiameter, X
    TAY 
    LDA $decelStepCounter
    STA $0024, Y
    COP [CallScript] ( &code_0BBF47 )
    LDA $orbitDiameter, X
    TAY 
    PHX 
    LDX $26
    LDA $scratch1010+6, X
    PLX 
    STA $0024, Y
    COP [CallScript] ( &code_0BBF47 )
    BRA loc_0BAC3B

  loc_0BAC60:
    COP [KillNext]
    LDA #$2000
    TRB $10
    LDY $26
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC #$FFFC
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDY $26
    LDA $0024, Y
    LSR 
    STA $0024, Y

  loc_0BAC8B:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    BRA loc_0BAC8B

  loc_0BAC92:
    COP [WaitByte] ( #07 )
    COP [Die]

  loc_0BAC97:
    BRK #$20
    RTI 
    RTS 
}

code_0BAC9B {
    BRA loc_0BAC3D

  loc_0BAC9D:
    CPY #$02E0
    LDX #$ACBB
    PHB 
    BRK #$20
    STZ $24

  loc_0BACA8:
    COP [PaletteStart] ( #5F )
    COP [PaletteStep]
    LDA $24
    BEQ loc_0BACA8
    LDY $06
    LDA #$ACE1
    STA $0000, Y
    COP [Die]

  loc_0BACBB:
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X
    COP [WaitByte] ( #0F )
    LDA $26
    INC 
    CMP #$0020
    BCC loc_0BACDB
    COP [SpawnAfterFlags] ( @code_0BAD4E, #$0202 )
    LDA #$0000

  loc_0BACDB:
    STA $26
    JSR $&code_0BACF6
    RTL 
}

code_0BACE1 {
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X
    COP [LoopInit] ( #78 )
    JSR $&code_0BACF6
    COP [LoopNext]
    COP [Die]
}

code_0BACF6 {
    LDA $layerPriorityFlag
    BIT #$0200
    BNE loc_0BAD2C
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X

  loc_0BAD09:
    COP [RngByte]
    PHA 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    PLA 
    LSR 
    LSR 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTS 

  loc_0BAD2C:
    LDA $7F100C, X
    BNE loc_0BAD42
    LDA $cameraTargetX
    STA $7F100C, X
    LDA $cameraTargetY
    STA $7F100E, X
    BRA loc_0BAD09

  loc_0BAD42:
    STA $cameraTargetX
    LDA $7F100E, X
    STA $cameraTargetY
    BRA loc_0BAD09
}

code_0BAD4E {
    COP [StageSprAndHitbox] ( #0D )
    LDA #$0002
    TSB $12
    COP [RngByte]
    PHA 
    AND #$001F
    STA $16
    PLA 
    ASL 
    STA $14

  loc_0BAD62:
    COP [StageForceMoveX] ( #01 )
    COP [RngByte]
    LSR 
    BCC loc_0BAD71
    LDA $12
    EOR #$4000
    STA $12

  loc_0BAD71:
    COP [InitGravity] ( #02, #07, #05 )
    COP [SetEntryContinue]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0BAD80
    RTL 

  loc_0BAD80:
    COP [ToggleHFlip]
    LDA $10
    BIT #$4000
    BNE loc_0BAD96
    COP [PlaySoundCh1] ( #15 )
    LDA #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY

  loc_0BAD96:
    LDA $16
    BMI loc_0BAD62
    CMP #$0200
    BCC loc_0BAD62
    COP [Die]
}

actor_def_0BADA1 [
  actor-def < #15, #01, #07, {

  code_0BADA4:
    LDA #$7FFF
    STA $08
    RTL 
} >
]

actor_def_0BADAA [
  actor-def < #0F, #01, #07, {

  code_0BADAD:
    BRA loc_0BADB2
} >
]

actor_def_0BADAF [
  actor-def < #0F, #01, #07, {

  loc_0BADB2:
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BADC3
    RTL 

  loc_0BADC3:
    LDA $slopeCurvePtrB
    BIT #$0002
    BEQ loc_0BADCC
    RTL 

  loc_0BADCC:
    COP [BranchIfPlayerNear] ( #01, &code_0BADD2 )
    RTL 
} >
]

code_0BADD2 {
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0BADFB, #$2700 )
    LDA #$0001
    STA $24
    COP [SetEntryExit]
    LDA $24
    BEQ loc_0BADB2
    PHX 
    LDX $decelStepCounter
    LDY $06
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLX 
    RTL 
}

code_0BADFB {
    LDA #$0008
    TSB $12
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA $playerWallType
    CLC 
    ADC #$0008
    STA $14
    LDA $playerSpeedEw
    CLC 
    ADC #$0010
    STA $16
    COP [MoveToward] ( #FF, #04 )
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2200
    STA $0010, Y
    LDA #$2000
    TRB $10
    COP [PlaySoundCh2] ( #0C )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $04
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$00F0
    STA $moveYAlt, X
    COP [MoveToward] ( #27, #08 )
    COP [SetMetasprite] ( $7E4000 )
    COP [PlaySoundCh2] ( #0C )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $14
    CMP #$0100
    BCC loc_0BAE7C
    LDA #$4000
    TSB $12

  loc_0BAE7C:
    LDA $14
    CLC 
    ADC #$0020
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #27, #04 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    PHX 
    PHD 
    TYA 
    TCD 
    TAX 
    LDA $00
    PHA 
    COP [StagePlayerSprite] ( #00 )
    JSL $@chunk_3B7DD.code_03C761
    STZ $2A
    STZ $08
    PLA 
    STA $00
    PLD 
    PLX 
    LDY $04
    LDA #$0000
    STA $0024, Y
    LDA #$2000
    TSB $10
    LDA #$0028
    STA $24
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    COP [SetEntryContinue]
    DEC $24
    BMI loc_0BAF10
    LDY $decelStepCounter
    LDA $0036
    LSR 
    LDA $0010, Y
    BCS loc_0BAF00
    ORA #$0001
    STA $0010, Y
    LDA $000E, Y
    AND #$CFFF
    BRA loc_0BAF0C

  loc_0BAF00:
    AND #$FFFE
    STA $0010, Y
    LDA $000E, Y
    ORA #$3000

  loc_0BAF0C:
    STA $000E, Y
    RTL 

  loc_0BAF10:
    LDA $joypadMaskStd
    BIT #$0F00
    BNE loc_0BAF24
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FDFF
    STA $0010, Y

  loc_0BAF24:
    LDY $decelStepCounter
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [Die]
}

actor_def_0BAF32 [
  actor-def < #00, #00, #00, {

  code_0BAF35:
    COP [SetSpritePriority] ( #30 )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    STZ $24

  loc_0BAF46:
    COP [BranchIfOffscreen] ( &code_0BAF54 )
    COP [WaitWhileOffscreen] ( #0F )

  code_0BAF4D:
    LDA $10
    BIT #$4000
    BNE loc_0BAF46
} >
]

code_0BAF54 {
    COP [SetSavedPtr] ( &code_0BAF4D )
    LDA $24
    INC 
    STA $24
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BAF6B )
}

code_list_0BAF6B [
  &code_0BAF7B   ;00
  &code_0BAFA2   ;01
  &code_0BAFF0   ;02
  &code_0BAFC9   ;03
  &code_0BB017   ;04
  &code_0BB04E   ;05
  &code_0BB084   ;06
  &code_0BB0BD   ;07
]

code_0BAF7B {
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCS code_0BAFA2
    COP [StageSpriteLoopMoveX] ( #02, #04, #08 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFA0
    STZ $24
    COP [StageSpriteLoop] ( #07, #0A )
    COP [AnimLoop]
    JMP $&code_0BB0F6

  loc_0BAFA0:
    COP [RestoreSavedPtr]
}

code_0BAFA2 {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCC code_0BAF7B
    COP [StageSpriteLoopMoveX] ( #82, #04, #07 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFC7
    STZ $24
    COP [StageSpriteLoop] ( #07, #0A )
    COP [AnimLoop]
    JMP $&code_0BB0F6

  loc_0BAFC7:
    COP [RestoreSavedPtr]
}

code_0BAFC9 {
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCS code_0BAFF0
    COP [StageSpriteLoopMoveY] ( #01, #04, #08 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BAFC7
    STZ $24
    COP [StageSpriteLoop] ( #06, #0A )
    COP [AnimLoop]
    JMP $&code_0BB0F6
}

code_0BAFEE {
    COP [RestoreSavedPtr]
}

code_0BAFF0 {
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCC code_0BAFC9
    COP [StageSpriteLoopMoveY] ( #00, #04, #07 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB015
    STZ $24
    COP [StageSpriteLoop] ( #05, #0A )
    COP [AnimLoop]
    JMP $&code_0BB0F6

  loc_0BB015:
    COP [RestoreSavedPtr]
}

code_0BB017 {
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCC code_0BAFF0
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCC loc_0BB032
    JMP $&code_0BAFA2

  loc_0BB032:
    COP [StageSpriteLoopMoveXY] ( #03, #04, #06, #05 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB04C
    STZ $24
    COP [StageSpriteLoop] ( #08, #0A )
    COP [AnimLoop]
    JMP $&code_0BB0F6

  loc_0BB04C:
    COP [RestoreSavedPtr]
}

code_0BB04E {
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCS code_0BAFF0
    LDA $7F100C, X
    SEC 
    SBC #$0040
    CMP $14
    BCC loc_0BB069
    JMP $&code_0BAFA2

  loc_0BB069:
    COP [StageSpriteLoopMoveXY] ( #04, #04, #06, #06 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB082
    STZ $24
    COP [StageSpriteLoop] ( #09, #0A )
    COP [AnimLoop]
    BRA code_0BB0F6

  loc_0BB082:
    COP [RestoreSavedPtr]
}

code_0BB084 {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCS loc_0BB093
    JMP $&code_0BAF7B

  loc_0BB093:
    LDA $7F100E, X
    CLC 
    ADC #$0040
    CMP $16
    BCS loc_0BB0A2
    JMP $&code_0BAFC9

  loc_0BB0A2:
    COP [StageSpriteLoopMoveXY] ( #83, #04, #05, #05 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB0BB
    STZ $24
    COP [StageSpriteLoop] ( #88, #0A )
    COP [AnimLoop]
    BRA code_0BB0F6

  loc_0BB0BB:
    COP [RestoreSavedPtr]
}

code_0BB0BD {
    LDA $7F100C, X
    CLC 
    ADC #$0040
    CMP $14
    BCS loc_0BB0CC
    JMP $&code_0BAF7B

  loc_0BB0CC:
    LDA $7F100E, X
    SEC 
    SBC #$0040
    CMP $16
    BCC loc_0BB0DB
    JMP $&code_0BAFF0

  loc_0BB0DB:
    COP [StageSpriteLoopMoveXY] ( #84, #04, #05, #06 )
    COP [AnimLoop]
    LDA $24
    AND #$000F
    BNE loc_0BB0F4
    STZ $24
    COP [StageSpriteLoop] ( #89, #0A )
    COP [AnimLoop]
    BRA code_0BB0F6

  loc_0BB0F4:
    COP [RestoreSavedPtr]
}

code_0BB0F6 {
    COP [BranchIfPlayerNear] ( #04, &code_0BB0FD )
    COP [RestoreSavedPtr]
}

code_0BB0FD {
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB10B )
}

code_list_0BB10B [
  &code_0BB11B   ;00
  &code_0BB12A   ;01
  &code_0BB13A   ;02
  &code_0BB149   ;03
  &code_0BB159   ;04
  &code_0BB168   ;05
  &code_0BB178   ;06
  &code_0BB187   ;07
]

code_0BB11B {
    COP [StageSpriteLoop] ( #01, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #01, #06, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB12A {
    COP [StageSpriteLoop] ( #84, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #84, #06, #05, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB13A {
    COP [StageSpriteLoop] ( #82, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #82, #06, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB149 {
    COP [StageSpriteLoop] ( #83, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #83, #06, #05, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB159 {
    COP [StageSpriteLoop] ( #00, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #00, #06, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB168 {
    COP [StageSpriteLoop] ( #03, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #03, #06, #06, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB178 {
    COP [StageSpriteLoop] ( #02, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #06, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0BB187 {
    COP [StageSpriteLoop] ( #04, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #04, #06, #06, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

actor_def_0BB197 [
  actor-def < #0A, #00, #01, {

  code_0BB19A:
    LDA #$0018
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SetHitCallback] ( &code_0BB1AC )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0BB1AC {
    COP [ClearLowHere]
    LDA #$0100
    TRB $10
    LDA #$0110
    TRB $12
    BRA code_0BB1CC
}

actor_def_0BB1BA [
  actor-def < #0A, #00, #00, {

  code_0BB1BD:
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [WaitWhileOffscreen] ( #15 )
    COP [BranchIfPlayerNear] ( #05, &code_0BB1CC )
    BRA code_0BB1BD
} >
]

code_0BB1CC {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BB1DC, &code_0BB21A )
}

code_0BB1DC {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB1E6, &code_0BB1E6, &code_0BB1FB )
}

code_0BB1E6 {
    COP [BranchIfSolidWest] ( &code_0BB1F2 )
    COP [StageSpriteMoveX] ( #0E, #04 )
    COP [AnimOnce]
    BRA code_0BB1E6
}

code_0BB1F2 {
    COP [StageSpriteMoveXY] ( #0B, #4B, #49 )
    COP [AnimOnce]
    BRA code_0BB1BD
}

code_0BB1FB {
    COP [BranchIfSolidEast] ( &code_0BB207 )
    COP [StageSpriteMoveX] ( #0E, #03 )
    COP [AnimOnce]
    BRA code_0BB1FB
}

code_0BB207 {
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveXY] ( #0B, #4B, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    BRA code_0BB1BD
}

code_0BB21A {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB224, &code_0BB224, &code_0BB239 )
}

code_0BB224 {
    COP [BranchIfSolidNorth] ( &code_0BB230 )
    COP [StageSpriteMoveY] ( #0D, #04 )
    COP [AnimOnce]
    BRA code_0BB224
}

code_0BB230 {
    COP [StageSpriteMoveY] ( #0B, #4B )
    COP [AnimOnce]
    JMP $&code_0BB1BD
}

code_0BB239 {
    COP [BranchIfSolidSouth] ( &code_0BB245 )
    COP [StageSpriteMoveY] ( #0D, #03 )
    COP [AnimOnce]
    BRA code_0BB239
}

code_0BB245 {
    LDA #$2000
    TSB $12
    COP [StageSpriteMoveY] ( #0B, #4B )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    JMP $&code_0BB1BD
}

actor_def_0BB258 [
  actor-def < #1F, #00, #00, {

  code_0BB25B:
    LDA #$0020
    TSB $12
    LDA $&stats_table+120
    AND #$00FF
    STA $orbitAngle, X
    BRA loc_0BB28B

  code_0BB26C:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB283 )
} >
]

code_list_0BB283 [
  &code_0BB2AB   ;00
  &code_0BB2F8   ;01
  &code_0BB399   ;02
  &code_0BB34F   ;03
]

loc_0BB28B {
    LDA #$00FF
    STA $currentHp, X
    COP [SetSavedPtr] ( &loc_0BB28B )
    COP [SetEntryExit]
    COP [WaitWhileOffscreen] ( #11 )
    COP [BranchNearerAxis] ( &code_0BB2A1, &code_0BB345 )
}

code_0BB2A1 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB2AB, &code_0BB2AB, &code_0BB2F8 )
}

code_0BB2AB {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0BB26C )
    COP [BranchIfPlayerNear] ( #03, &code_0BB2CE )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB26C )
    COP [BranchIfPlayerNear] ( #03, &code_0BB2DA )
    COP [StageSpriteMoveX] ( #2A, #02 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB2CE {
    COP [BranchIfSolidWest] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    BRA loc_0BB2E4
}

code_0BB2DA {
    COP [BranchIfSolidWest] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #2A, #02 )
    COP [AnimOnce]

  loc_0BB2E4:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0001
    BEQ loc_0BB2F3
    JMP $&code_0BB3E3

  loc_0BB2F3:
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB2F8 {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB31B )
    COP [BranchIfSolidEast] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB327 )
    COP [BranchIfSolidEast] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #AA, #01 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB31B {
    COP [BranchIfSolidEast] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    BRA loc_0BB331
}

code_0BB327 {
    COP [BranchIfSolidEast] ( &code_0BB26C )
    COP [StageSpriteMoveX] ( #AA, #01 )
    COP [AnimOnce]

  loc_0BB331:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0003
    BEQ loc_0BB340
    JMP $&code_0BB3E3

  loc_0BB340:
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB345 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB34F, &code_0BB34F, &code_0BB399 )
}

code_0BB34F {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB372 )
    COP [BranchIfSolidNorth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB37E )
    COP [BranchIfSolidNorth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB372 {
    COP [BranchIfSolidNorth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    BRA loc_0BB388
}

code_0BB37E {
    COP [BranchIfSolidNorth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]

  loc_0BB388:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0002
    BNE code_0BB3E3
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB399 {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB3BC )
    COP [BranchIfSolidSouth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB3C8 )
    COP [BranchIfSolidSouth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #28, #01 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB3BC {
    COP [BranchIfSolidSouth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    BRA loc_0BB3D2
}

code_0BB3C8 {
    COP [BranchIfSolidSouth] ( &code_0BB26C )
    COP [StageSpriteMoveY] ( #28, #01 )
    COP [AnimOnce]

  loc_0BB3D2:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0000
    BNE code_0BB3E3
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB3E3 {
    AND #$0003
    STA $26
    COP [BranchIfPlayerNear] ( #05, &code_0BB3EF )
    COP [RestoreSavedPtr]
}

code_0BB3EF {
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB3FA )
}

code_list_0BB3FA [
  &code_0BB402   ;00
  &code_0BB4CC   ;01
  &code_0BB45D   ;02
  &code_0BB53B   ;03
]

code_0BB402 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0BB732, #00, #D0, #$2002 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6A0, #00, #D2, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6A0, #00, #DA, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6A0, #00, #E0, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB671, #00, #E6, #$2202 )
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB445
    RTL 

  loc_0BB445:
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    LDA $26
    BEQ loc_0BB456
    JMP $&code_0BB5A7

  loc_0BB456:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB45D {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB720, #$2002 )
    LDA #$FFD0
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB671, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB669
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB4B4
    RTL 

  loc_0BB4B4:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BEQ loc_0BB4C5
    JMP $&code_0BB5A7

  loc_0BB4C5:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB4CC {
    COP [StageSpriteFrame] ( #A7 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB6AF, #$2002 )
    LDA #$FFD8
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB671, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB669
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #91 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB523
    RTL 

  loc_0BB523:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BEQ loc_0BB534
    JMP $&code_0BB5A7

  loc_0BB534:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB53B {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB6BF, #$2002 )
    LDA #$FFD8
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB6A0, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB669
    COP [SpawnMarkedBefore] ( @code_0BB671, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB669
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB592
    RTL 

  loc_0BB592:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BNE code_0BB5A7
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB5A7 {
    LDA #$ACF4
    STA $statsPtr, X
    LDA $&stats_table+11C
    AND #$00FF
    STA $currentHp, X
    LDA #$0020
    TRB $12
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]

  code_0BB5C2:
    COP [SetSavedPtr] ( &code_0BB5C2 )
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #07, &code_0BB5E3 )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB5DB )
}

code_list_0BB5DB [
  &code_0BB5F3   ;00
  &code_0BB60E   ;01
  &code_0BB633   ;02
  &code_0BB64E   ;03
]

code_0BB5E3 {
    COP [BranchNearerAxis] ( &code_0BB5E9, &code_0BB629 )
}

code_0BB5E9 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB5F3, &code_0BB5F3, &code_0BB60E )
}

code_0BB5F3 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidWest] ( &code_0BB5C2 )
    COP [StageSpriteMoveX] ( #14, #04 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB5C2 )
    COP [StageSpriteMoveX] ( #17, #04 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB60E {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BB5C2 )
    COP [StageSpriteMoveX] ( #94, #03 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BB5C2 )
    COP [StageSpriteMoveX] ( #97, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB629 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB633, &code_0BB633, &code_0BB64E )
}

code_0BB633 {
    COP [LoopInit] ( #07 )
    COP [BranchIfSolidNorth] ( &code_0BB5C2 )
    COP [StageSpriteMoveY] ( #13, #04 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BB5C2 )
    COP [StageSpriteMoveY] ( #16, #04 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB64E {
    COP [LoopInit] ( #07 )
    COP [BranchIfSolidSouth] ( &code_0BB5C2 )
    COP [StageSpriteMoveY] ( #12, #03 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BB5C2 )
    COP [StageSpriteMoveY] ( #15, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB669 {
    CLC 
    ADC $0016, Y
    STA $0016, Y
    RTS 
}

code_0BB671 {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [SetEntryContinue]
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTL 
}

code_0BB6A0 {
    LDA #$2000
    TRB $10
    COP [StageSprAndHitbox] ( #1E )
    COP [SetEntryContinue]
    JSL $@chunk_0A8000.code_0AA35F
    RTL 
}

code_0BB6AF {
    COP [StageSprAndHitbox] ( #9D )
    LDA #$0002
    TSB $12
    LDA $14
    CLC 
    ADC #$0040
    BRA loc_0BB6C8
}

code_0BB6BF {
    COP [StageSprAndHitbox] ( #1D )
    LDA $14
    CLC 
    ADC #$FFC0

  loc_0BB6C8:
    STA $moveXAlt, X
    LDA $24
    STA $26
    PHX 
    TAX 
    LDA $orbitAngle, X
    PLX 
    STA $currentHp, X
    LDA #$ACF8
    STA $statsPtr, X
    LDA #$FFD8
    STA $7F100E, X
    LDA #$0000
    STA $7F100C, X
    LDA $16
    CLC 
    ADC #$0018
    STA $16
    LDA #$2000
    TRB $10
    COP [BranchOnPlayerY] ( #$0020, &code_0BB710, &code_0BB707, &code_0BB710 )
}

code_0BB707 {
    LDA $playerSpeedEw
    CLC 
    ADC #$0008
    BRA loc_0BB712
}

code_0BB710 {
    LDA $16

  loc_0BB712:
    STA $moveYAlt, X
    LDA $16
    CLC 
    ADC #$FFE8
    STA $16
    BRA loc_0BB781
}

code_0BB720 {
    COP [StageSprAndHitbox] ( #19 )
    LDA #$FFD8
    STA $7F100E, X
    LDA $16
    CLC 
    ADC #$0050
    BRA loc_0BB742
}

code_0BB732 {
    COP [StageSprAndHitbox] ( #1B )
    LDA #$FFD0
    STA $7F100E, X
    LDA $16
    CLC 
    ADC #$FFD0

  loc_0BB742:
    STA $moveYAlt, X
    LDA $24
    STA $26
    PHX 
    TAX 
    LDA $orbitAngle, X
    PLX 
    STA $currentHp, X
    LDA #$ACF8
    STA $statsPtr, X
    LDA #$0000
    STA $7F100C, X
    LDA #$2000
    TRB $10
    COP [BranchOnPlayerX] ( #$0020, &code_0BB77B, &code_0BB772, &code_0BB77B )
}

code_0BB772 {
    LDA $playerWallType
    CLC 
    ADC #$0008
    BRA loc_0BB77D
}

code_0BB77B {
    LDA $14

  loc_0BB77D:
    STA $moveXAlt, X

  loc_0BB781:
    COP [SetDeathCallback] ( @code_0BB7E3 )
    COP [MoveToward] ( #FF, #02 )
    DEC $28
    LDY $26

  loc_0BB78E:
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #02 )
    LDY $26
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    SEC 
    SBC $14
    BPL loc_0BB7BD
    EOR #$FFFF
    INC 

  loc_0BB7BD:
    CMP #$0002
    BCS loc_0BB78E
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    SEC 
    SBC $16
    BPL loc_0BB7D3
    EOR #$FFFF
    INC 

  loc_0BB7D3:
    CMP #$0002
    BCS loc_0BB78E
    LDY $26
    LDA #$0000
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BB7E3 {
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [SetEntryContinue]
    RTL 
}

actor_def_0BB7FA [
  actor-def < #00, #00, #00, {

  code_0BB7FD:
    COP [WaitWhileOffscreen] ( #0F )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #04, &code_0BB91C )
    RTL 
} >
]

actor_def_0BB808 [
  actor-def < #00, #00, #20, {

  code_0BB80B:
    COP [BranchIfPlayerNear] ( #05, &code_0BB811 )
    RTL 
} >
]

code_0BB811 {
    COP [SpawnAfterFlags] ( @code_0BBA45, #$0300 )
    COP [SpawnAfterFlags] ( @code_0BBA4C, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBA63, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBA7A, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBA91, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAA8, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBABF, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAD6, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAED, #$0300 )
    LDA #$FFFF
    STA $26
    COP [SetEntryContinue]
    LDA $26
    BPL loc_0BB871
    RTL 

  loc_0BB871:
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    LDA #$2000
    TRB $10
    BRA loc_0BB88D

  loc_0BB88A:
    COP [WaitWhileOffscreen] ( #08 )

  loc_0BB88D:
    LDA $10
    BIT #$4000
    BNE loc_0BB88A
    COP [BranchIfPlayerNear] ( #04, &code_0BB977 )
    COP [BranchNearerAxis] ( &code_0BB89F, &code_0BB8D5 )
}

code_0BB89F {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB8A9, &code_0BB8A9, &code_0BB8BF )
}

code_0BB8A9 {
    COP [BranchIfSolidWest] ( &code_0BB95F )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB95F )
    COP [StageSpriteMoveX] ( #2A, #12 )
    COP [AnimOnce]
    BRA loc_0BB88D
}

code_0BB8BF {
    COP [BranchIfSolidEast] ( &code_0BB95F )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BB95F )
    COP [StageSpriteMoveX] ( #AA, #11 )
    COP [AnimOnce]
    BRA loc_0BB88D
}

code_0BB8D5 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB8DF, &code_0BB8DF, &code_0BB8F5 )
}

code_0BB8DF {
    COP [BranchIfSolidNorth] ( &code_0BB95F )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BB95F )
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    BRA loc_0BB88D
}

code_0BB8F5 {
    COP [BranchIfSolidSouth] ( &code_0BB90B )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BB90B )
    COP [StageSpriteMoveY] ( #28, #11 )
    COP [AnimOnce]
    BRA loc_0BB88D
}

code_0BB90B {
    COP [BranchOnPlayerY] ( #$0010, &code_0BB95F, &code_0BB95F, &code_0BB915 )
}

code_0BB915 {
    COP [BranchIfSolidTypeSouth] ( #08, &code_0BB91C )
    BRA code_0BB95F
}

code_0BB91C {
    LDA #$0011
    TSB $12
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]

  loc_0BB926:
    COP [StageSpriteMoveY] ( #2D, #07 )
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &code_0BB933 )
    BRA loc_0BB926
}

code_0BB933 {
    LDA #$0011
    TRB $12
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnMarkedAfter] ( @code_0BB9A1, #$2000 )
    LDA #$0010
    TSB $10
    COP [SpawnLastRel] ( @code_0BB9C2, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [KillNext]
    COP [SetSpritePalette] ( #00 )
}

code_0BB95F {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB96F )
}

code_list_0BB96F [
  &code_0BB8A9   ;00
  &code_0BB8BF   ;01
  &code_0BB8F5   ;02
  &code_0BB8DF   ;03
]

code_0BB977 {
    COP [SetEntryExit]
    LDA #$0010
    TSB $10
    COP [SpawnMarkedAfter] ( @code_0BB9A1, #$2000 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #08, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [KillNext]
    LDA #$0010
    TRB $10
    COP [SetSpritePalette] ( #00 )
    BRA code_0BB95F
}

code_0BB9A1 {
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    COP [WaitByte] ( #01 )
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    ORA #$0200
    STA $000E, Y
    COP [WaitByte] ( #01 )
    BRA code_0BB9A1
}

code_0BB9C2 {
    COP [LoopInit] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BB9DF, #$2300 )
    COP [SpawnLastRel] ( @chunk_008000.code_00D149, #00, #00, #$2000 )
    CLC 
    ADC #$0020
    STA $08
    COP [LoopNext]
    COP [Die]
}

code_0BB9DF {
    COP [RngByte]
    CLC 
    ADC $bg1ScrollH
    STA $14
    STA $moveXAlt, X
    COP [RngByte]
    CLC 
    ADC $bg2ScrollH
    STA $16
    STA $moveYAlt, X
    COP [BranchIfSolid] ( &code_0BBA37 )
    COP [SpawnAfterFlags] ( @code_0BBA39, #$0300 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TRB $10
    LDA $bg2ScrollH
    SEC 
    SBC #$0020
    STA $16
    COP [StageMove] ( #18, #04, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #14 )
    COP [StageSpriteLoopMoveY] ( #18, #0B, #45 )
    COP [AnimLoop]
    COP [KillNext]
    LDA #$0100
    TRB $10
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SetEntryExit]
}

code_0BBA37 {
    COP [Die]
}

code_0BBA39 {
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0BBA3E:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0BBA3E
}

code_0BBA45 {
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    BRA code_0BBA45
}

code_0BBA4C {
    JSR $&code_0BBB29
    COP [StageMove] ( #09, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #09, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBA63 {
    JSR $&code_0BBB29
    COP [StageMove] ( #0A, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0A, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBA7A {
    JSR $&code_0BBB29
    COP [StageMove] ( #0B, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0B, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBA91 {
    JSR $&code_0BBB29
    COP [StageMove] ( #0C, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0C, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAA8 {
    JSR $&code_0BBB29
    COP [StageMove] ( #0D, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0D, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBABF {
    JSR $&code_0BBB29
    COP [StageMove] ( #0E, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0E, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAD6 {
    JSR $&code_0BBB29
    COP [StageMove] ( #0F, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0F, #11, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAED {
    JSR $&code_0BBB29
    LDA $24
    STA $26
    LDA $moveYAlt, X
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [StageMove] ( #10, #08, #FF )
    COP [TickMove]
    LDA $14
    STA $moveXAlt, X
    LDA $16
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [StageMove] ( #10, #04, #FF )
    COP [TickMove]
    LDY $26
    LDA #$0000
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BBB29 {
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    STA $16
    RTS 
}

actor_def_0BBB3F [
  actor-def < #13, #00, #00, {

  code_0BBB42:
    LDA #$0001
    STA $26
    BRA loc_0BBB4E
} >
]

actor_def_0BBB49 [
  actor-def < #13, #00, #00, {

  code_0BBB4C:
    STZ $26

  loc_0BBB4E:
    LDA #$0011
    TSB $12
    COP [SetDeathCallback] ( @code_0BBD2B )

  code_0BBB58:
    COP [SetHitCallback] ( &code_0BBB79 )

  loc_0BBB5C:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #06, &code_0BBB6B )
    COP [RngByte]
    AND #$000F
    STA $08
    RTL 
} >
]

code_0BBB6B {
    COP [SpawnMarkedAfterRel] ( @code_0BBCE5, #00, #E6, #$0202 )
    COP [WaitByte] ( #77 )
    BRA loc_0BBB5C
}

code_0BBB79 {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    LDA $26
    BNE loc_0BBBB4
    COP [SpawnAfterRelFlags] ( @code_0BBBE7, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD64
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBBE7, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD64
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBBE7, #$0000, #$0000, #$0302 )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    BRA code_0BBB58

  loc_0BBBB4:
    COP [SpawnAfterRelFlags] ( @code_0BBC69, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD64
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC69, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD64
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC69, #$0000, #$0000, #$0302 )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    JMP $&code_0BBB58
}

code_0BBBE7 {
    COP [PlaySoundCh1] ( #28 )
    LDA #$00A0
    TSB $12
    COP [RngByte]
    LSR 
    BCS code_0BBC02
    COP [BranchIfSolidOffset] ( #00, #03, &code_0BBC02 )
    LDA $16
    CLC 
    ADC #$0030
    BRA loc_0BBC14
}

code_0BBC02 {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BBCE3 )
    LDA $14
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020

  loc_0BBC14:
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #2F, #02 )
    COP [OrActorFlags] ( #$0080 )
    LDA #$0302
    TRB $10
    COP [BranchOnPlayerX] ( #$0000, &code_0BBC35, &code_0BBC35, &code_0BBC4F )
}

code_0BBC35 {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0BBC4F )
    COP [StageSpriteFrame] ( #A0 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A7, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBC35
    COP [Die]
}

code_0BBC4F {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0BBC35 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #27, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBC4F
    COP [Die]
}

code_0BBC69 {
    COP [PlaySoundCh1] ( #28 )
    LDA #$00A0
    TSB $12
    COP [RngByte]
    LSR 
    BCS code_0BBC84
    COP [BranchIfSolidOffset] ( #01, #02, &code_0BBC84 )
    LDA $14
    CLC 
    ADC #$0010
    BRA loc_0BBC8C
}

code_0BBC84 {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BBCE3 )
    LDA $14

  loc_0BBC8C:
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #02 )
    COP [OrActorFlags] ( #$0080 )
    LDA #$0302
    TRB $10
    COP [BranchOnPlayerY] ( #$0000, &code_0BBCB1, &code_0BBCB1, &code_0BBCCB )
}

code_0BBCB1 {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0BBCCB )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBCB1
    COP [Die]
}

code_0BBCCB {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0BBCB1 )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBCCB
}

code_0BBCE3 {
    COP [Die]
}

code_0BBCE5 {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0BBCFC, #$0000, #$0002, #$0202 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0BBCFC {
    COP [PlaySoundCh1] ( #1E )
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA $decelStepCounter
    STA $24
    LDA #$0003
    STA $0028, X
    LDA #$0002
    STA $loopCounter, X
    SEP #$20
    LDA #$80
    PHA 
    REP #$20
    LDA #$E5D1
    PHA 
    RTL 
}

code_0BBD2B {
    LDA $0AEC
    CMP #$0001
    BNE loc_0BBD38
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0BBD38:
    COP [CallScript] ( &code_0BC0FE )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00DB97, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [LoopInit] ( #28 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_0BBD64 {
    COP [RngByte]
    AND #$001F
    CLC 
    ADC #$0008
    STA $08
    RTS 
}

actor_def_0BBD70 [
  actor-def < #16, #00, #00, {

  code_0BBD73:
    LDA #$0010
    TSB $12
    COP [SpawnMarkedAfter] ( @code_0AFF40, #$2000 )
    TYA 
    STA $26
    BRA loc_0BBD88

  code_0BBD84:
    COP [MoveToward] ( #FF, #02 )

  loc_0BBD88:
    LDA $14
    STA $7F100C, X
    STA $moveXAlt, X
    LDA $16
    STA $7F100E, X
    STA $moveYAlt, X
    LDA #$2060
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]

  loc_0BBDA8:
    COP [WaitWhileOffscreen] ( #08 )

  code_0BBDAB:
    LDA $10
    BIT #$4000
    BNE loc_0BBDA8
    LDA #$0000
    STA $orbitDiameter, X
    COP [LoopInit] ( #FF )
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC $0B02
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $7F0011, X
    CLC 
    ADC $0B02
    CLC 
    ADC #$01
    STA $7F0011, X
    LDA $orbitDiameter, X
    BMI loc_0BBDE9
    CLC 
    ADC #$03
    STA $orbitDiameter, X

  loc_0BBDE9:
    LDA $7F0013, X
    BMI loc_0BBDF6
    CLC 
    ADC #$02
    STA $7F0013, X

  loc_0BBDF6:
    REP #$20
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    JSL $@chunk_008000.code_00F526
    LDA $7F100C, X
    CMP $moveXAlt, X
    BEQ loc_0BBE26
    BPL loc_0BBE1E
    CLC 
    ADC #$0001
    STA $7F100C, X
    BRA loc_0BBE26

  loc_0BBE1E:
    SEC 
    SBC #$0001
    STA $7F100C, X

  loc_0BBE26:
    LDA $7F100E, X
    CMP $moveYAlt, X
    BEQ loc_0BBE44
    BPL loc_0BBE3C
    CLC 
    ADC #$0001
    STA $7F100E, X
    BRA loc_0BBE44

  loc_0BBE3C:
    SEC 
    SBC #$0001
    STA $7F100E, X

  loc_0BBE44:
    COP [LoopNext]
    LDA $10
    BIT #$4000
    BEQ loc_0BBE50
    JMP $&code_0BBD84

  loc_0BBE50:
    LDA #$2200
    TSB $10
    COP [SpawnLastRel] ( @code_0BBECC, #00, #00, #$0200 )
    TYA 
    STA $7F100C, X
    LDA $26
    STA $0026, Y
    COP [SpawnLastRel] ( @code_0BBEDA, #00, #00, #$0200 )
    TYA 
    STA $7F100E, X
    LDA $26
    STA $0026, Y
    COP [WaitWord] ( #$0167 )
    LDA $7F100C, X
    TAY 
    LDA #$BF6F
    STA $0000, Y
    LDA $7F100E, X
    TAY 
    LDA #$BF6F
    STA $0000, Y
    LDA #$0003
    STA $24
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BBEA1
    RTL 

  loc_0BBEA1:
    LDA $7F100C, X
    PHD 
    TCD 
    TAX 
    COP [MarkDeath]
    LDA $01, S
    TAX 
    LDA $7F100E, X
    TCD 
    TAX 
    COP [MarkDeath]
    PLA 
    TCD 
    TAX 
    LDA #$2200
    TRB $10
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    JMP $&code_0BBDAB
} >
]

code_0BBECC {
    LDA $24
    STA $7F100C, X
    LDA $14
    SEC 
    SBC #$0020
    BRA loc_0BBEE6
}

code_0BBEDA {
    LDA $24
    STA $7F100C, X
    LDA $14
    CLC 
    ADC #$0020

  loc_0BBEE6:
    STA $moveXAlt, X
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $moveXAlt, X
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #17, #01 )
    LDA #$8017
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E79D, #$2000 )
    TYA 
    STA $orbitDiameter, X
    LDA $decelStepCounter
    STA $0024, Y
    COP [SetEntryExit]

  loc_0BBF28:
    LDA $orbitDiameter, X
    TAY 
    LDA $decelStepCounter
    STA $0024, Y
    COP [CallScript] ( &code_0BBF47 )
    LDA $orbitDiameter, X
    TAY 
    LDA $26
    STA $0024, Y
    COP [CallScript] ( &code_0BBF47 )
    BRA loc_0BBF28
}

code_0BBF47 {
    LDA #$BF58
    STA $retPtr2, X
    COP [RngByte]
    AND #$0001
    INC 
    STA $loopCounter, X

  loc_0BBF58:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BBF58
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryExit]
    DEC $24
    BMI loc_0BBF6B
    RTL 

  loc_0BBF6B:
    COP [LoopNext]
    COP [RestoreSavedPtr]

  loc_0BBF6F:
    COP [KillNext]
    LDA $7F100C, X
    TAY 
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDA $7F100C, X
    TAY 
    LDA $0024, Y
    LSR 
    STA $0024, Y

  loc_0BBF97:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    BRA loc_0BBF97
}

actor_def_0BBF9E [
  actor-def < #16, #00, #00, {

  code_0BBFA1:
    JSR $&code_0BBFE4
    COP [SetSpritePalette] ( #0A )
    COP [WaitWhileOffscreen] ( #15 )
    LDA #$0000
    STA $26
    STA $24
    BRA loc_0BBFC3
} >
]

actor_def_0BBFB3 [
  actor-def < #16, #00, #00, {

  code_0BBFB6:
    JSR $&code_0BBFE4
    COP [SetSpritePalette] ( #0A )
    LDA #$0001
    STA $26
    STA $24

  loc_0BBFC3:
    LDA #$0011
    TSB $12
    COP [SpawnMarkedAfter] ( @code_0BC0CD, #$2000 )
    LDA $orbitAngle, X
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BBFDC )
} >
]

code_list_0BBFDC [
  &code_0BC05F   ;00
  &code_0BBFF0   ;01
  &code_0BC090   ;02
  &code_0BC02A   ;03
]

code_0BBFE4 {
    LDA $0E
    XBA 
    AND #$0006
    LSR 
    STA $orbitAngle, X
    RTS 
}

code_0BBFF0 {
    COP [SetEntryExit]

  loc_0BBFF2:
    COP [BranchIfSolidWest] ( &code_0BBFFB )
    JMP $&code_0BC098
}

code_0BBFF9 {
    COP [SetEntryExit]
}

code_0BBFFB {
    COP [BranchIfSolidNorth] ( &code_0BC032 )
    LDA $24
    STA $26
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    COP [SetEntryExit]
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    LDA $16
    AND #$000F
    BEQ loc_0BC021
    RTL 

  loc_0BC021:
    LDA #$0000
    STA $moveScratch2, X
    BRA loc_0BBFF2
}

code_0BC02A {
    COP [SetEntryExit]

  loc_0BC02C:
    COP [BranchIfSolidNorth] ( &code_0BC034 )
    BRA code_0BBFF9
}

code_0BC032 {
    COP [SetEntryExit]
}

code_0BC034 {
    COP [BranchIfSolidEast] ( &code_0BC067 )
    LDA $24
    STA $26
    LDA $26
    STA $moveScratch1, X
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch1, X
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BEQ loc_0BC056
    RTL 

  loc_0BC056:
    LDA #$0000
    STA $moveScratch1, X
    BRA loc_0BC02C
}

code_0BC05F {
    COP [SetEntryExit]

  loc_0BC061:
    COP [BranchIfSolidEast] ( &code_0BC069 )
    BRA code_0BC032
}

code_0BC067 {
    COP [SetEntryExit]
}

code_0BC069 {
    COP [BranchIfSolidSouth] ( &code_0BC098 )
    LDA $24
    STA $26
    LDA $26
    STA $moveScratch2, X
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch2, X
    LDA $16
    AND #$000F
    BEQ loc_0BC087
    RTL 

  loc_0BC087:
    LDA #$0000
    STA $moveScratch2, X
    BRA loc_0BC061
}

code_0BC090 {
    COP [SetEntryExit]

  loc_0BC092:
    COP [BranchIfSolidSouth] ( &code_0BC09A )
    BRA code_0BC067
}

code_0BC098 {
    COP [SetEntryExit]
}

code_0BC09A {
    COP [BranchIfSolidWest] ( &code_0BBFF9 )
    LDA $24
    STA $26
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch1, X
    COP [SetEntryExit]
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch1, X
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BEQ loc_0BC0C4
    RTL 

  loc_0BC0C4:
    LDA #$0000
    STA $moveScratch1, X
    BRA loc_0BC092
}

code_0BC0CD {
    COP [SetEntryContinue]
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BNE loc_0BC0DA
    RTL 

  loc_0BC0DA:
    LDA $0024, Y
    BNE loc_0BC0E4
    LDA #$0001
    BRA loc_0BC0E5

  loc_0BC0E4:
    ASL 

  loc_0BC0E5:
    STA $0024, Y
    CMP #$0008
    BCS loc_0BC0FC
    COP [SetEntryContinue]
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0BC0FA
    RTL 

  loc_0BC0FA:
    BRA code_0BC0CD

  loc_0BC0FC:
    COP [Die]
}

code_0BC0FE {
    COP [PlaySoundCh1] ( #06 )
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [SetDungeonKillFlag]
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0BC13D
    COP [ClearLowHere]

  loc_0BC13D:
    LDA $deathActionIdx, X
    BEQ loc_0BC165
    JSL $@chunk_008000.code_00B5A4
    BCS loc_0BC165
    LDA $deathActionIdx, X
    JSL $@chunk_008000.code_00B58E
    COP [SpawnLastRel] ( @chunk_008000.code_00DF11, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0BC165:
    COP [RestoreSavedPtr]
}

actor_def_0BC167 [
  actor-def < #0A, #00, #01, {

  code_0BC16A:
    COP [SetDeathCallback] ( @code_0BC2A5 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0BC177 )
    RTL 
} >
]

code_0BC177 {
    COP [BranchIfSolidOffset] ( #00, #01, &code_0BC183 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
}

code_0BC183 {
    LDA #$0100
    TRB $10
    BRA code_0BC197
}

actor_def_0BC18A [
  actor-def < #07, #00, #00, {

  code_0BC18D:
    COP [SetDeathCallback] ( @code_0BC2A5 )

  loc_0BC192:
    COP [SetEntryExit]
    COP [WaitWhileOffscreen] ( #08 )

  code_0BC197:
    LDA $14
    SEC 
    SBC $playerWallType
    BPL loc_0BC1A3
    EOR #$FFFF
    INC 

  loc_0BC1A3:
    CMP #$0100
    BCS loc_0BC192
    LDA $16
    SEC 
    SBC $playerSpeedEw
    BPL loc_0BC1B4
    EOR #$FFFF
    INC 

  loc_0BC1B4:
    CMP #$0100
    BCS loc_0BC192
    COP [BranchNearerAxis] ( &code_0BC1BF, &code_0BC20B )
} >
]

code_0BC1BF {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC1C9, &code_0BC1C9, &code_0BC1EA )
}

code_0BC1C9 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidWest] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #0C, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC1E6, &code_0BC20B )
}

code_0BC1E6 {
    COP [LoopNext]
    BRA code_0BC197
}

code_0BC1EA {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #8C, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #98, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC207, &code_0BC20B )
}

code_0BC207 {
    COP [LoopNext]
    BRA code_0BC197
}

code_0BC20B {
    COP [BranchOnPlayerY] ( #$0000, &code_0BC215, &code_0BC215, &code_0BC237 )
}

code_0BC215 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidNorth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #0B, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC232, &code_0BC1BF )
}

code_0BC232 {
    COP [LoopNext]
    JMP $&code_0BC197
}

code_0BC237 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC254, &code_0BC1BF )
}

code_0BC254 {
    COP [LoopNext]
    JMP $&code_0BC197
}

code_0BC259 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC269 )
}

code_list_0BC269 [
  &code_0BC271   ;00
  &code_0BC27E   ;01
  &code_0BC28B   ;02
  &code_0BC298   ;03
]

code_0BC271 {
    COP [BranchIfSolidWest] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    JMP $&code_0BC197
}

code_0BC27E {
    COP [BranchIfSolidEast] ( &code_0BC259 )
    COP [StageSpriteMoveX] ( #8C, #01 )
    COP [AnimOnce]
    JMP $&code_0BC197
}

code_0BC28B {
    COP [BranchIfSolidNorth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #0B, #02 )
    COP [AnimOnce]
    JMP $&code_0BC197
}

code_0BC298 {
    COP [BranchIfSolidSouth] ( &code_0BC259 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
    JMP $&code_0BC197
}

code_0BC2A5 {
    COP [SpawnAfterFlags] ( @code_0BC2C7, #$0000 )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0BC2B6:
    ORA $0000
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    BRA loc_0BC317
}

code_0BC2C7 {
    COP [OrActorFlags] ( #$0090 )
    LDA #$AD0C
    STA $statsPtr, X
    LDA $&stats_table+134
    AND #$00FF
    STA $currentHp, X
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #0D )
    COP [WaitByte] ( #17 )
    COP [PlaySoundBoth] ( #$0606 )
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #0C )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #08 )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #04 )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #02 )
    COP [LoopNext]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]

  loc_0BC317:
    COP [BranchIfOffscreen] ( &code_0BC325 )

  loc_0BC31B:
    COP [WaitWhileOffscreen] ( #15 )

  loc_0BC31E:
    LDA $10
    BIT #$4000
    BNE loc_0BC31B
}

code_0BC325 {
    LDA $7F100C, X
    SEC 
    SBC $playerWallType
    BPL loc_0BC333
    EOR #$FFFF
    INC 

  loc_0BC333:
    CMP #$0070
    BCS loc_0BC379
    LDA $7F100E, X
    SEC 
    SBC $playerSpeedEw
    BPL loc_0BC346
    EOR #$FFFF
    INC 

  loc_0BC346:
    CMP #$0070
    BCS loc_0BC379
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $playerWallType
    SEC 
    SBC #$001F
    STA $moveXAlt, X
    LDA $0410
    LSR 
    LSR 
    LSR 
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $playerSpeedEw
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #02 )

  loc_0BC379:
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    BRA loc_0BC31E
}

actor_def_0BC380 [
  actor-def < #00, #00, #00, {

  code_0BC383:
    LDA #$0180
    TSB $12
    LDA #$1010
    STA $20
    LDA #$0428
    STA $22
    COP [SpawnMarkedAfter] ( @code_0BC50C, #$2000 )

  loc_0BC399:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC39C:
    LDA $10
    BIT #$4000
    BNE loc_0BC399
    COP [BranchIfPlayerNear] ( #04, &code_0BC494 )
    COP [BranchNearerAxis] ( &code_0BC3AE, &code_0BC3FA )
} >
]

code_0BC3AE {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC3B8, &code_0BC3B8, &code_0BC3D9 )
}

code_0BC3B8 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #15, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3D5, &code_0BC3FA )
}

code_0BC3D5 {
    COP [LoopNext]
    BRA code_0BC39C
}

code_0BC3D9 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #85, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #95, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3F6, &code_0BC3FA )
}

code_0BC3F6 {
    COP [LoopNext]
    BRA code_0BC39C
}

code_0BC3FA {
    COP [BranchOnPlayerY] ( #$0000, &code_0BC404, &code_0BC404, &code_0BC426 )
}

code_0BC404 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidNorth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #04, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #14, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3AE, &code_0BC421 )
}

code_0BC421 {
    COP [LoopNext]
    JMP $&code_0BC39C
}

code_0BC426 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #13, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3AE, &code_0BC443 )
}

code_0BC443 {
    COP [LoopNext]
    JMP $&code_0BC39C
}

code_0BC448 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC458 )
}

code_list_0BC458 [
  &code_0BC460   ;00
  &code_0BC46D   ;01
  &code_0BC47A   ;02
  &code_0BC487   ;03
]

code_0BC460 {
    COP [BranchIfSolidWest] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #05, #02 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC46D {
    COP [BranchIfSolidEast] ( &code_0BC448 )
    COP [StageSpriteMoveX] ( #95, #01 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC47A {
    COP [BranchIfSolidNorth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #14, #02 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC487 {
    COP [BranchIfSolidSouth] ( &code_0BC448 )
    COP [StageSpriteMoveY] ( #13, #01 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC494 {
    COP [SetEntryExit]
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC4A4 )
}

code_list_0BC4A4 [
  &code_0BC47A   ;00
  &code_0BC4DC   ;01
  &code_0BC487   ;02
  &code_0BC4AC   ;03
]

code_0BC4AC {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $14
    CLC 
    ADC #$FFD0
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #11, #03 )
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC4DC {
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    LDA $14
    CLC 
    ADC #$0030
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #91, #03 )
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    JMP $&code_0BC39C
}

code_0BC50C {
    LDY $24
    LDA $0010, Y
    AND #$FFEF
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0140
    BEQ loc_0BC52D
    RTL 

  loc_0BC52D:
    LDY $24
    LDA $0028, Y
    AND #$000F
    CMP #$0006
    BCC loc_0BC53B
    RTL 

  loc_0BC53B:
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC544 )
}

code_list_0BC544 [
  &code_0BC550   ;00
  &code_0BC558   ;01
  &code_0BC560   ;02
  &code_0BC550   ;03
  &code_0BC558   ;04
  &code_0BC560   ;05
]

code_0BC550 {
    COP [CardinalToPlayer]
    CMP #$0002
    BEQ loc_0BC57A
    RTL 
}

code_0BC558 {
    COP [CardinalToPlayer]
    CMP #$0000
    BEQ loc_0BC57A
    RTL 
}

code_0BC560 {
    LDY $24
    LDA $000E, Y
    BIT #$4000
    BNE loc_0BC572
    COP [CardinalToPlayer]
    CMP #$0003
    BEQ loc_0BC57A
    RTL 

  loc_0BC572:
    COP [CardinalToPlayer]
    CMP #$0001
    BEQ loc_0BC57A
    RTL 

  loc_0BC57A:
    LDY $24
    LDA $0010, Y
    ORA #$0010
    STA $0010, Y
    RTL 
}

actor_def_0BC586 [
  actor-def < #0F, #00, #00, {

  code_0BC589:
    COP [SetDeathCallback] ( @code_0BC6CA )
    LDA #$0010
    TSB $12

  loc_0BC593:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC596:
    LDA $10
    BIT #$4000
    BNE loc_0BC593
    COP [SetSavedPtr] ( &code_0BC5AB )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC5AB, &code_0BC638, &code_0BC5AB )
} >
]

code_0BC5AB {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0BC5BC )
    COP [StageSpriteMoveX] ( #0F, #12 )
    COP [AnimOnce]
    BRA code_0BC596

  loc_0BC5B9:
    COP [WaitWhileOffscreen] ( #07 )
}

code_0BC5BC {
    LDA $10
    BIT #$4000
    BNE loc_0BC5B9
    COP [SetSavedPtr] ( &code_0BC5D1 )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC5D1, &code_0BC638, &code_0BC5D1 )
}

code_0BC5D1 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0BC596 )
    COP [StageSpriteMoveX] ( #0F, #11 )
    COP [AnimOnce]
    BRA code_0BC5BC
}

actor_def_0BC5DF [
  actor-def < #0F, #00, #00, {

  code_0BC5E2:
    COP [SetDeathCallback] ( @code_0BC6CA )
    LDA #$0010
    TSB $12

  loc_0BC5EC:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC5EF:
    LDA $10
    BIT #$4000
    BNE loc_0BC5EC
    COP [SetSavedPtr] ( &code_0BC604 )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC604, &code_0BC638, &code_0BC604 )
} >
]

code_0BC604 {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0BC615 )
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    BRA code_0BC5EF

  loc_0BC612:
    COP [WaitWhileOffscreen] ( #07 )
}

code_0BC615 {
    LDA $10
    BIT #$4000
    BNE loc_0BC612
    COP [SetSavedPtr] ( &code_0BC62A )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC62A, &code_0BC638, &code_0BC62A )
}

code_0BC62A {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0BC5EF )
    COP [StageSpriteMoveY] ( #0F, #11 )
    COP [AnimOnce]
    BRA code_0BC615
}

code_0BC638 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC6A2, &code_0BC6A2, &code_0BC67A )
}

actor_def_0BC642 [
  actor-def < #0F, #00, #00, {

  code_0BC645:
    COP [SetDeathCallback] ( @code_0BC6CA )
    LDA #$0010
    TSB $12

  loc_0BC64F:
    COP [SetSavedPtr] ( &code_0BC65D )
    COP [BranchOnPlayerY] ( #$0010, &code_0BC65D, &code_0BC664, &code_0BC65D )
} >
]

code_0BC65D {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_0BC64F
}

code_0BC664 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC672 )
}

code_list_0BC672 [
  &code_0BC65D   ;00
  &code_0BC67A   ;01
  &code_0BC65D   ;02
  &code_0BC6A2   ;03
]

code_0BC67A {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterRelFlags] ( @code_0BC6F0, #$000A, #$FFF6, #$0300 )
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @chunk_0A8000.code_0AD944, #$000A, #$FFF6, #$2200 )
    COP [SetEntryExit]
    COP [RestoreSavedPtr]
}

code_0BC6A2 {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterRelFlags] ( @code_0BC6F0, #$FFF6, #$FFF6, #$0300 )
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @chunk_0A8000.code_0AD92F, #$FFF6, #$FFF6, #$2200 )
    COP [SetEntryExit]
    COP [RestoreSavedPtr]
}

code_0BC6CA {
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    LDA $0AEC
    CMP #$0001
    BNE loc_0BC6DC
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0BC6DC:
    COP [CallScript] ( &code_0BC71B )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00DB97, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [Die]
}

code_0BC6F0 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $16
    STA $16
    LDA $0410
    LSR 
    LSR 
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $14
    STA $14
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}

code_0BC71B {
    COP [PlaySoundCh1] ( #06 )
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SetDungeonKillFlag]
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0BC751
    COP [ClearLowHere]

  loc_0BC751:
    LDA $deathActionIdx, X
    BEQ loc_0BC779
    JSL $@chunk_008000.code_00B5A4
    BCS loc_0BC779
    LDA $deathActionIdx, X
    JSL $@chunk_008000.code_00B58E
    COP [SpawnLastRel] ( @chunk_008000.code_00DF11, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0BC779:
    COP [RestoreSavedPtr]
}

actor_def_0BC77B [
  actor-def < #1B, #00, #00, {

  code_0BC77E:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0BC7EA )

  loc_0BC787:
    COP [WaitWhileOffscreen] ( #0D )
    COP [WaitByte] ( #77 )
    COP [BranchOnPlayerX] ( #$0000, &code_0BC797, &code_0BC797, &code_0BC7A4 )
} >
]

code_0BC797 {
    COP [SpawnAfterRelFlags] ( @code_0BC7B1, #$FFF4, #$FFF0, #$0200 )
    BRA loc_0BC787
}

code_0BC7A4 {
    COP [SpawnAfterRelFlags] ( @code_0BC7B1, #$000C, #$FFF0, #$0200 )
    BRA loc_0BC787
}

code_0BC7B1 {
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [AddPosition] ( #00, #02 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [AddPosition] ( #00, #FA )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $decelStepCounter
    STA $24
    LDA #$0008
    STA $0028, X
    LDA #$0001
    STA $loopCounter, X
    SEP #$20
    LDA #$80
    PHA 
    REP #$20
    LDA #$E5D1
    PHA 
    RTL 
}

code_0BC7EA {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC7F4, &code_0BC7F4, &code_0BC7F9 )
}

code_0BC7F4 {
    COP [StageSprAndHitbox] ( #1A )
    BRA loc_0BC7FC
}

code_0BC7F9 {
    COP [StageSprAndHitbox] ( #9A )

  loc_0BC7FC:
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]

  loc_0BC80D:
    COP [WaitWhileOffscreen] ( #0D )
    COP [BranchOnPlayerX] ( #$0000, &code_0BC81A, &code_0BC81A, &code_0BC82D )
}

code_0BC81A {
    COP [SpawnAfterRelFlags] ( @code_0BC840, #$FFF4, #$FFF0, #$0200 )
    COP [StageSpriteLoop] ( #1A, #04 )
    COP [AnimLoop]
    BRA loc_0BC80D
}

code_0BC82D {
    COP [SpawnAfterRelFlags] ( @code_0BC840, #$000C, #$FFF0, #$0200 )
    COP [StageSpriteLoop] ( #9A, #04 )
    COP [AnimLoop]
    BRA loc_0BC80D
}

code_0BC840 {
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [AddPosition] ( #00, #02 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [AddPosition] ( #00, #FA )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA $decelStepCounter
    STA $24
    LDA #$0003
    STA $0028, X
    LDA #$0003
    STA $loopCounter, X
    SEP #$20
    LDA #$80
    PHA 
    REP #$20
    LDA #$E5D1
    PHA 
    RTL 
}

actor_def_0BC879 [
  actor-def < #00, #10, #01, {

  code_0BC87C:
    LDA #$8011
    TSB $12
    LDA $14
    SEC 
    SBC #$0008
    STA $14
    LDA $16
    CLC 
    ADC #$0100
    STA $16
    LDA #$0000
    STA $cameraTargetX
    STA $cameraTargetY
    STA $cameraDeltaX
    STA $cameraDeltaY
    COP [SpawnAfterFlags] ( @code_0BD524, #$2300 )
    COP [SpawnAfterFlags] ( @code_0BD507, #$2300 )
    COP [SpawnAfterFlags] ( @code_0BD552, #$2300 )
    COP [SpawnMarkedBefore] ( @code_0BD3D2, #$2000 )
    COP [SpawnMarkedAfterRel] ( @code_0BD119, #C8, #33, #$0111 )
    COP [SpawnMarkedAfterRel] ( @code_0BD175, #38, #33, #$0111 )
    COP [SpawnMarkedAfterRel] ( @code_0BD391, #BF, #0B, #$0301 )
    COP [SpawnMarkedAfterRel] ( @code_0BD38A, #41, #0B, #$0301 )
    STZ $24
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    LDA $24
    BNE loc_0BC8EE
    RTL 

  loc_0BC8EE:
    LDA #$0100
    TRB $10
    LDA #$0003
    STA $0000
    LDY $06

  loc_0BC8FB:
    LDA $0010, Y
    AND #$FEFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0BC8FB

  loc_0BC90D:
    LDY $06
    LDA #$D399
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$D399
    STA $0000, Y
    LDA #$021C
    STA $animScratch, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BC977
    LDA $animScratch, X
    DEC 
    STA $animScratch, X
    BMI loc_0BC938
    RTL 

  loc_0BC938:
    LDY $06
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    LDA $0026, Y
    BNE loc_0BC94D
    LDA #$D185
    STA $0000, Y

  loc_0BC94D:
    LDA $0006, Y
    TAY 
    LDA $0026, Y
    BNE loc_0BC95C
    LDA #$D129
    STA $0000, Y

  loc_0BC95C:
    LDA #$00B4
    STA $animScratch, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BC977
    LDA $animScratch, X
    DEC 
    STA $animScratch, X
    BMI loc_0BC975
    RTL 

  loc_0BC975:
    BRA loc_0BC90D

  loc_0BC977:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetDeathCallback] ( @code_0BCA00 )

  loc_0BC981:
    COP [SpawnLastRel] ( @code_0BD7C9, #00, #00, #$2000 )
    LDA #$0010
    TRB $10
    COP [WaitByte] ( #1D )
    COP [SetHitCallback] ( &code_0BC9F9 )

  loc_0BC996:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #29 )
    COP [SpawnLastRel] ( @code_0BD6C1, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0BD7D0, #00, #00, #$2000 )
    COP [SetHitCallback] ( #$0000 )
    COP [WaitWord] ( #$00B3 )
    LDA #$0010
    TSB $10
    LDY $06
    LDA #$D3B8
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$D3B8
    STA $0000, Y
    LDY $06
    LDA $0006, Y
    TAY 
    LDA $0006, Y
    TAY 
    LDA #$D1F5
    STA $0000, Y
    LDA $0006, Y
    TAY 
    LDA #$D1F5
    STA $0000, Y
    COP [WaitWord] ( #$01DF )
    BRA loc_0BC981
} >
]

code_0BC9F9 {
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA loc_0BC996
}

code_0BCA00 {
    COP [SpawnLastRel] ( @code_0BD7D0, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    LDY $04
    LDA #$D4B1
    STA $0000, Y
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    LDA $26
    BEQ loc_0BCA22
    RTL 

  loc_0BCA22:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #F5 )
    COP [AdhocVramDma] ( $7EE000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7EE800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7EF000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7EF800, #$5C00, #$0800 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SpawnLastRel] ( @code_0BCA60, #00, #00, #$0012 )
    COP [Die]
}

code_0BCA60 {
    COP [SetDeathCallback] ( @code_0BCFE0 )
    LDA #$AD34
    STA $statsPtr, X
    LDA $&stats_table+15C
    AND #$00FF
    STA $currentHp, X
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfterRel] ( @code_0BCBBE, #EA, #E0, #$2200 )
    COP [SpawnMarkedAfterRel] ( @code_0BCBF6, #16, #E0, #$2200 )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0080
    STA $moveXAlt, X
    STA $moveYAlt, X
    COP [StageMove] ( #1E, #FF, #FF )
    COP [TickMove]
    COP [StageSpriteLoop] ( #1E, #04 )
    COP [AnimLoop]
    LDA #$0010
    TRB $10

  code_0BCAAD:
    COP [SetHitCallback] ( &code_0BCB1C )
    COP [SetEntryContinue]
    LDA $0036
    LSR 
    BCS loc_0BCACA
    LDA $decelStepCounter
    LDA $0014, Y
    STA $0018
    LDA $0016, Y
    STA $001C
    BRA loc_0BCAD8

  loc_0BCACA:
    COP [RngByte]
    STA $0018
    LDA $0411
    AND #$00FF
    STA $001C

  loc_0BCAD8:
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $0018
    CMP #$0020
    BCS loc_0BCAEB
    RTL 

  loc_0BCAEB:
    CMP #$00E0
    BCC loc_0BCAF1
    RTL 

  loc_0BCAF1:
    STA $moveXAlt, X
    LDA $0411
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $001C
    CMP #$0040
    BCS loc_0BCB09
    RTL 

  loc_0BCB09:
    CMP #$00E0
    BCC loc_0BCB0F
    RTL 

  loc_0BCB0F:
    STA $moveYAlt, X
    COP [StageMove] ( #1E, #FF, #FF )
    COP [TickMove]
    BRA code_0BCAAD
}

code_0BCB1C {
    LDA #$0001
    STA $26
    COP [StageSpriteFrame] ( #42 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0BCB4A, #00, #EC, #$0211 )
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    STZ $26
    JMP $&code_0BCAAD
}

code_0BCB43 {
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    BRA code_0BCB43
}

code_0BCB4A {
    COP [SetDeathCallback] ( @code_0BCBB2 )
    COP [OrActorFlags] ( #$0080 )
    COP [StageSpriteLoopMoveY] ( #22, #10, #07 )
    COP [AnimLoop]
    COP [WaitByte] ( #13 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    LDA #$0210
    TRB $10
    LDA #$AD30
    STA $statsPtr, X
    LDA $&stats_table+158
    AND #$00FF
    STA $currentHp, X

  loc_0BCB78:
    COP [SetHitCallback] ( &code_0BCBAB )
    COP [SetEntryContinue]
    COP [RngByte]
    CMP #$0014
    BCS loc_0BCB86
    RTL 

  loc_0BCB86:
    CMP #$00E0
    BCC loc_0BCB8C
    RTL 

  loc_0BCB8C:
    STA $moveXAlt, X
    COP [RngByte]
    CMP #$0014
    BCS loc_0BCB98
    RTL 

  loc_0BCB98:
    CMP #$00E0
    BCC loc_0BCB9E
    RTL 

  loc_0BCB9E:
    STA $moveYAlt, X
    COP [StageMove] ( #24, #02, #FF )
    COP [TickMove]
    BRA loc_0BCB78
}

code_0BCBAB {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_0BCB78
}

code_0BCBB2 {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [Die]
}

code_0BCBBE {
    COP [SpawnMarkedAfterRel] ( @code_0BCC5D, #B0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD0B9, #C0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #D0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #E0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #F0, #00, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD0A6, #00, #00, #$0202 )
    BRA loc_0BCC2C
}

code_0BCBF6 {
    COP [SpawnMarkedAfterRel] ( @code_0BCF52, #50, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD0B9, #40, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #30, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #20, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD098, #10, #E0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0BD0A6, #00, #E0, #$0202 )

  loc_0BCC2C:
    LDA $14
    LDY $24
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    LDY $24
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [SetEntryContinue]
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTL 
}

code_0BCC5D {
    COP [StageSprAndHitbox] ( #29 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0070
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $parentId, X
    TAY 
    LDA $0010, Y
    BIT #$0010
    BEQ code_0BCC81
    JSR $&code_0BD060
    RTL 

  code_0BCC81:
    COP [SetSavedPtr] ( &code_0BCC81 )
    COP [DirToPlayer]
    PHX 
    AND #$0007
    STA $0000
    TAX 
    LDA $@code_0BD067, X
    PLX 
    AND #$00FF
    STA $7F100C, X
    SEP #$20
    SEC 
    SBC $orbitAngle, X
    REP #$20
    BPL loc_0BCCD5

  loc_0BCCA6:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    JSR $&code_0BD07F
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    AND #$00FF
    STA $orbitAngle, X
    SEC 
    SBC $7F100C, X
    BPL loc_0BCCCE
    EOR #$FFFF
    INC 

  loc_0BCCCE:
    CMP #$0003
    BCS loc_0BCCA6
    BRA code_0BCC81

  loc_0BCCD5:
    AND #$00FF
    CMP #$0010
    BCC code_0BCD0D
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    JSR $&code_0BD07F
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    SEC 
    SBC $7F100C, X
    BPL loc_0BCD05
    EOR #$FFFF
    INC 

  loc_0BCD05:
    CMP #$0003
    BCS loc_0BCCD5
    JMP $&code_0BCC81

  code_0BCD0D:
    LDA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    PHX 
    TAX 
    LDA $@loc_0BD069+E, X
    PLX 
    AND #$00FF
    STA $0000
    LDA $0410
    AND #$0001
    SEC 
    SBC #$0001
    CLC 
    ADC $0000
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BCD3D )
}

code_list_0BCD3D [
  &code_0BCD4D   ;00
  &code_0BCD71   ;01
  &code_0BCD95   ;02
  &code_0BCDB9   ;03
  &code_0BCDDD   ;04
  &code_0BCE01   ;05
  &code_0BCE25   ;06
  &code_0BCE49   ;07
]

code_0BCD4D {
    COP [StageSprAndHitbox] ( #2A )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCEB1, #00, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCD71 {
    COP [StageSprAndHitbox] ( #2F )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCEC3, #08, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCD95 {
    COP [StageSprAndHitbox] ( #2C )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCED5, #08, #00, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCDB9 {
    COP [StageSprAndHitbox] ( #30 )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCEE7, #08, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCDDD {
    COP [StageSprAndHitbox] ( #29 )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCEF9, #00, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCE01 {
    COP [StageSprAndHitbox] ( #2D )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCF0A, #F8, #08, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCE25 {
    COP [StageSprAndHitbox] ( #2B )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCF1B, #F8, #00, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCE49 {
    COP [StageSprAndHitbox] ( #2E )
    JSR $&code_0BCE8F
    COP [LoopInit] ( #10 )
    JSR $&code_0BD060
    COP [LoopNext]
    COP [SpawnLastRel] ( @code_0BCF2C, #F8, #F8, #$0202 )
    COP [LoopInit] ( #0A )
    JSR $&code_0BD060
    COP [LoopNext]
    JSR $&code_0BCE6D
    COP [RestoreSavedPtr]
}

code_0BCE6D {
    LDA $parentId, X
    TAY 
    LDA $0026, Y
    BNE loc_0BCE8D
    LDA $0010, Y
    BIT #$0040
    BNE loc_0BCE8D
    LDA #$CAAD
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    CLC 
    RTS 

  loc_0BCE8D:
    SEC 
    RTS 
}

code_0BCE8F {
    LDA $parentId, X
    TAY 
    LDA $0026, Y
    BNE loc_0BCEAF
    LDA $0010, Y
    BIT #$0040
    BNE loc_0BCEAF
    LDA #$CB43
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    CLC 
    RTS 

  loc_0BCEAF:
    SEC 
    RTS 
}

code_0BCEB1 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3B )
    COP [StageForceMoveXY] ( #00, #08 )
    JMP $&code_0BCF3F
}

code_0BCEC3 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #40 )
    COP [StageForceMoveXY] ( #05, #06 )
    JMP $&code_0BCF3F
}

code_0BCED5 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #35 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3D )
    COP [StageForceMoveXY] ( #07, #00 )
    JMP $&code_0BCF3F
}

code_0BCEE7 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #41 )
    COP [StageForceMoveXY] ( #05, #05 )
    JMP $&code_0BCF3F
}

code_0BCEF9 {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3A )
    COP [StageForceMoveXY] ( #00, #07 )
    BRA code_0BCF3F
}

code_0BCF0A {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3E )
    COP [StageForceMoveXY] ( #06, #05 )
    BRA code_0BCF3F
}

code_0BCF1B {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3C )
    COP [StageForceMoveXY] ( #08, #00 )
    BRA code_0BCF3F
}

code_0BCF2C {
    COP [PlaySoundCh1] ( #23 )
    COP [StageSpriteFrame] ( #37 )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #3F )
    COP [StageForceMoveXY] ( #06, #06 )
    BRA code_0BCF3F

  loc_0BCF3D:
    COP [ReloadForceMove]
}

code_0BCF3F {
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0BCF3D
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [Die]
}

code_0BCF52 {
    COP [StageSprAndHitbox] ( #29 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0070
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $parentId, X
    TAY 
    LDA $0010, Y
    BIT #$0010
    BEQ code_0BCF76
    JSR $&code_0BD060
    RTL 

  code_0BCF76:
    COP [SetSavedPtr] ( &code_0BCF76 )
    LDA $0410
    LSR 
    BCS loc_0BCF86
    JMP $&code_0BCD0D
}

code_0BCF83 {
    COP [StageSprAndHitbox] ( #29 )

  loc_0BCF86:
    COP [RngByte]
    STA $7F100C, X
    LDA $0036
    LSR 
    BCC loc_0BCFB9

  loc_0BCF92:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    JSR $&code_0BD07F
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    INC 
    AND #$00FF
    STA $orbitAngle, X
    LDA $7F100C, X
    DEC 
    STA $7F100C, X
    BPL loc_0BCF92
    COP [RestoreSavedPtr]

  loc_0BCFB9:
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    JSR $&code_0BD07F
    COP [StageSprAndHitbox] ( #FF )
    COP [SetEntryExit]
    LDA $orbitAngle, X
    DEC 
    AND #$00FF
    STA $orbitAngle, X
    LDA $7F100C, X
    DEC 
    STA $7F100C, X
    BPL loc_0BCFB9
    COP [RestoreSavedPtr]
}

code_0BCFE0 {
    LDA #$0001
    STA $26
    COP [SpawnLastRel] ( @chunk_0A8000.code_0AA2B1, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0BD005, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0BD843, #00, #00, #$2000 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

code_0BD005 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_0BD029, #00, #C8, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0BD036, #00, #C8, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_0BD029 {
    JSR $&code_0BD043
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD036 {
    JSR $&code_0BD043
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD043 {
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0BD060 {
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    RTS 
}

code_0BD067 {
    BRA loc_0BD0C9

  loc_0BD069:
    PLP 
    JSR $&code_0BE000
    CPY #$29A0
    BMI loc_0BD09E
    AND $2B2E2A
    AND $0304
    COP [QueueHdma] ( $060700, #05 )
}

code_0BD07F {
    LDA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    PHX 
    TAX 
    LDA $@loc_0BD069+6, X
    PLX 
    AND #$00FF
    STA $28
    RTS 
}

code_0BD098 {
    COP [StageSprAndHitbox] ( #28 )
    STZ $08
    JSR $&code_0BD0C3
    COP [SetEntryContinue]
    JSR $&code_0BD0D8
    RTL 
}

code_0BD0A6 {
    COP [StageSprAndHitbox] ( #28 )
    STZ $08
    JSR $&code_0BD0C3
    COP [SetEntryContinue]
    JSR $&code_0BD0D8
    LDA $0014, Y
    STA $14
    RTL 
}

code_0BD0B9 {
    COP [StageSprAndHitbox] ( #28 )
    COP [SetEntryContinue]
    JSL $@chunk_0A8000.code_0AA35F
    RTL 
}

code_0BD0C3 {
    LDA $14
    STA $7F100C, X

  loc_0BD0C9:
    STA $orbitAngle, X
    LDA $16
    STA $7F100E, X
    STA $orbitDiameter, X
    RTS 
}

code_0BD0D8 {
    LDY $06
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    CLC 
    BPL loc_0BD0E6
    SEC 

  loc_0BD0E6:
    ROR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    CLC 
    BPL loc_0BD0F5
    SEC 

  loc_0BD0F5:
    ROR 
    STA $16
    LDA $orbitAngle, X
    STA $7F100C, X
    LDA $orbitDiameter, X
    STA $7F100E, X
    LDY $04
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    RTS 
}

code_0BD119 {
    JSR $&code_0BD81F
    COP [SetDeathCallback] ( @code_0BD1D1 )

  loc_0BD121:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BD129 {
    LDY $24
    LDA $0024, Y
    CMP #$0001
    BEQ loc_0BD139
    LDA $0036
    LSR 
    BCC loc_0BD121

  loc_0BD139:
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @code_0BD333, #10, #00, #$0202 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    LDA #$0010
    TSB $10
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    BRA loc_0BD121
}

code_0BD175 {
    JSR $&code_0BD81F
    COP [SetDeathCallback] ( @code_0BD1D1 )

  loc_0BD17D:
    COP [StageSpriteFrame] ( #85 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BD185 {
    LDY $24
    LDA $0024, Y
    CMP #$0001
    BEQ loc_0BD195
    LDA $0036
    LSR 
    BCS loc_0BD17D

  loc_0BD195:
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #96 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @code_0BD2F2, #F0, #00, #$0202 )
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #9B )
    COP [AnimOnce]
    LDA #$0010
    TSB $10
    COP [StageSpriteFrame] ( #85 )
    COP [AnimOnce]
    BRA loc_0BD17D
}

code_0BD1D1 {
    LDA #$0001
    STA $26
    LDY $24
    LDA $0024, Y
    LSR 
    STA $0024, Y
    COP [SpawnLastRel] ( @code_0BD284, #00, #00, #$0300 )
    LDA #$0002
    TSB $12

  loc_0BD1ED:
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BD1F5 {
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #20 )
    COP [SpawnLastRel] ( @code_0BD208, #00, #00, #$0302 )
    BRA loc_0BD1ED
}

code_0BD208 {
    LDA #$0080
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #30 )
    COP [MoveToward] ( #0C, #02 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $0E
    BIT #$C000
    BEQ loc_0BD252
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteLoopMoveY] ( #0E, #06, #0C )
    COP [AnimLoop]
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #0E )
    COP [SpawnAfterFlags] ( @code_0BD254, #$0202 )
    COP [WaitByte] ( #0E )
    COP [LoopNext]

  loc_0BD252:
    COP [Die]
}

code_0BD254 {
    COP [PlaySoundCh1] ( #23 )
    COP [RngByte]
    STA $14
    COP [RngByte]
    LSR 
    BCS loc_0BD272

  loc_0BD260:
    COP [StageSpriteLoopMoveY] ( #0F, #14, #03 )
    COP [AnimLoop]
    LDA $16
    BMI loc_0BD260
    CMP #$0120
    BCC loc_0BD260
    COP [Die]

  loc_0BD272:
    COP [StageSpriteLoopMoveY] ( #0F, #14, #05 )
    COP [AnimLoop]
    LDA $16
    BMI loc_0BD272
    CMP #$0120
    BCC loc_0BD272
    COP [Die]
}

code_0BD284 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0002
    TSB $12

  loc_0BD28C:
    COP [RngByte]
    LDA $0036
    LSR 
    BCS loc_0BD29D
    COP [SpawnAfterFlags] ( @code_0BD2D4, #$0302 )
    BRA loc_0BD2A4

  loc_0BD29D:
    COP [SpawnAfterFlags] ( @code_0BD2E3, #$0302 )

  loc_0BD2A4:
    LDA $0410
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0411
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $16
    STA $0016, Y
    COP [StageSpriteLoopMoveY] ( #05, #07, #01 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0BD28C
    COP [Die]
}

code_0BD2D4 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD2E3 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD2F2 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0005
    STA $26

  loc_0BD2FA:
    COP [SpawnAfterFlags] ( @code_0BD30B, #$0202 )
    LDA $26
    STA $0026, Y
    DEC 
    STA $26
    BNE loc_0BD2FA
}

code_0BD30B {
    COP [OrActorFlags] ( #$0010 )
    LDA $26
    PHX 
    TAX 
    LDA $@loc_0BD385, X
    AND #$00FF
    PLX 
    STA $moveYAlt, X
    LDA #$0008
    STA $moveXAlt, X
    COP [ReloadForceMove]
    COP [StageSpriteLoop] ( #11, #20 )
    COP [AnimLoop]
    COP [StageForceMoveX] ( #08 )
    BRA loc_0BD372
}

code_0BD333 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0005
    STA $26

  loc_0BD33B:
    COP [SpawnAfterFlags] ( @code_0BD34C, #$0202 )
    LDA $26
    STA $0026, Y
    DEC 
    STA $26
    BNE loc_0BD33B
}

code_0BD34C {
    COP [OrActorFlags] ( #$0010 )
    LDA $26
    PHX 
    TAX 
    LDA $@loc_0BD385, X
    AND #$00FF
    PLX 
    STA $moveYAlt, X
    LDA #$0007
    STA $moveXAlt, X
    COP [ReloadForceMove]
    COP [StageSpriteLoop] ( #91, #20 )
    COP [AnimLoop]
    COP [StageForceMoveX] ( #07 )

  loc_0BD372:
    COP [SetEntryContinue]
    LDA $10
    BIT #$4000
    BNE loc_0BD37C
    RTL 

  loc_0BD37C:
    LDA #$0014
    STA $08
    COP [SetEntryExit]
    COP [Die]

  loc_0BD385:
    ORA $01, S
    BRK #$02
    TSB $A9
    COP [GenHdmaSine]
    TSB $12
    COP [SetHFlip]
}

code_0BD391 {
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BD399 {
    COP [LoopInit] ( #05 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0BD5B3, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0BD391

  loc_0BD3B8:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0BD5B3, #00, #00, #$0202 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    BRA code_0BD391
}

code_0BD3D2 {
    LDY $06
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0010
    STA $orbitDiameter, X
    LDA $16
    STA $7F100C, X
    LDA $16
    SEC 
    SBC #$0100
    STA $26
    COP [SetEntryContinue]
    LDA $16
    BEQ loc_0BD439
    SEC 
    SBC #$0002
    STA $16
    LDA #$FFFE
    STA $001C
    STZ $0018
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    JSR $&code_0BD7D7
    LDA $16
    SEC 
    SBC $26
    BMI loc_0BD423
    RTL 

  loc_0BD423:
    EOR #$FFFF
    INC 
    STA $001C
    STZ $16
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    JSR $&code_0BD7D7
    RTL 

  loc_0BD439:
    LDY $24
    LDA #$0003
    STA $0024, Y
    BRA loc_0BD458

  loc_0BD443:
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0028
    STA $08
    COP [SetEntryExit]

  loc_0BD458:
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    CMP #$0040
    BEQ loc_0BD443
    CMP #$00C0
    BEQ loc_0BD443
    CLC 
    ADC #$0002
    AND #$00FF
    STA $orbitAngle, X
    JSR $&code_0BD864
    CLC 
    ADC $7F100C, X
    STA $16
    LDY $06
    LDA $20
    SEC 
    SBC $14
    EOR #$FFFF
    INC 
    STA $0018
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA $22
    SEC 
    SBC $16
    EOR #$FFFF
    INC 
    STA $001C
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $14
    STA $20
    LDA $16
    STA $22
    JSR $&code_0BD7D7
    RTL 
}

code_0BD4B1 {
    LDA $14
    STA $orbitAngle, X
    COP [LoopInit] ( #80 )
    COP [RngByte]
    LDA $16
    CLC 
    ADC #$0002
    STA $16
    LDA #$0002
    STA $001C
    LDY $06
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $14
    PHA 
    LDA $0410
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $orbitAngle, X
    STA $14
    SEC 
    SBC $01, S
    STA $0018
    PLA 
    LDA $0018
    CLC 
    ADC $0014, Y
    STA $0014, Y
    JSR $&code_0BD7D7
    COP [LoopNext]
    LDY $06
    LDA #$0000
    STA $0026, Y
    COP [Die]
}

code_0BD507 {
    LDY $24
    LDA $0026, Y
    BNE loc_0BD515
    COP [PaletteStart] ( #63 )
    COP [PaletteStep]
    BRA code_0BD507

  loc_0BD515:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    CMP #$0002
    BEQ loc_0BD522
    RTL 

  loc_0BD522:
    COP [Die]
}

code_0BD524 {
    COP [PaletteStart] ( #62 )
    COP [PaletteStep]
    COP [RngByte]
    CMP #$00C0
    BCC loc_0BD549
    COP [PaletteStart] ( #66 )
    COP [PaletteStep]
    COP [RngByte]
    AND #$0007
    CLC 
    ADC #$0004
    STA $08
    COP [SetEntryExit]
    COP [PaletteStart] ( #66 )
    COP [PaletteStep]
    COP [RngByte]

  loc_0BD549:
    STA $08
    STA $072A
    COP [SetEntryExit]
    BRA code_0BD524
}

code_0BD552 {
    COP [SetSpritePriority] ( #30 )
    LDA #$00A0
    STA $14
    LDA #$00C0
    STA $16
    COP [SetEntryContinue]
    LDY $24
    LDA $0016, Y
    SEC 
    SBC #$0030
    SEC 
    SBC $16
    BMI loc_0BD570
    RTL 

  loc_0BD570:
    COP [SetEntryContinue]
    COP [SpawnAfterFlags] ( @code_0BD592, #$0300 )
    LDA $0410
    AND #$0003
    CLC 
    ADC #$0005
    STA $08
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_0BD590
    RTL 

  loc_0BD590:
    COP [Die]
}

code_0BD592 {
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $16
    STA $16
    LDA $0411
    AND #$0003
    CLC 
    ADC $14
    STA $14
    COP [StageSpriteMoveX] ( #15, #08 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD5B3 {
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    LDA $0E
    BIT #$4000
    BEQ loc_0BD5CC
    COP [AddPosition] ( #04, #FA )
    COP [StageForceMoveXY] ( #01, #02 )
    BRA loc_0BD5D4

  loc_0BD5CC:
    COP [AddPosition] ( #FC, #FA )
    COP [StageForceMoveXY] ( #02, #02 )

  loc_0BD5D4:
    LDA #$0020
    TSB $12
    LDA #$0000
    STA $currentHp, X
    COP [SetDeathCallback] ( @code_0BD65A )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    LDA #$D60D
    STA $retPtr2, X
    STA $00
    LDA $0B02
    CLC 
    ADC #$0005
    STA $loopCounter, X
    COP [SetEntryContinue]
    COP [RngByte]
    LDY $decelStepCounter
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0014, Y
    STA $moveXAlt, X
    BPL loc_0BD626
    RTL 

  loc_0BD626:
    CMP #$0108
    BCC loc_0BD62C
    RTL 

  loc_0BD62C:
    LDA $0411
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0016, Y
    STA $moveYAlt, X
    BPL loc_0BD641
    RTL 

  loc_0BD641:
    CMP #$00E8
    BCC loc_0BD647
    RTL 

  loc_0BD647:
    COP [MoveToward] ( #18, #02 )
    LDA $10
    BIT #$4000
    BNE loc_0BD689
    COP [StageSpriteLoop] ( #18, #02 )
    COP [AnimLoop]
    COP [LoopNext]
}

code_0BD65A {
    COP [SetMetasprite] ( @table_0EE000 )
    LDA $16
    SEC 
    SBC #$0008
    STA $16
    LDA #$0003
    STA $24

  loc_0BD66C:
    COP [SpawnAfterFlags] ( @code_0BD68B, #$0202 )
    DEC $24
    BPL loc_0BD66C
    STZ $24
    LDA $16
    CLC 
    ADC #$0004
    STA $16
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_0BD689:
    COP [Die]
}

code_0BD68B {
    PEA $&code_0BD6BA-1
    LDY $24
    LDA $0024, Y
    INC 
    STA $0024, Y
    CMP #$0001
    BEQ loc_0BD6B5
    CMP #$0002
    BEQ loc_0BD6B0
    CMP #$0003
    BEQ loc_0BD6AB
    COP [StageForceMoveXY] ( #01, #01 )
    RTS 

  loc_0BD6AB:
    COP [StageForceMoveXY] ( #01, #02 )
    RTS 

  loc_0BD6B0:
    COP [StageForceMoveXY] ( #02, #01 )
    RTS 

  loc_0BD6B5:
    COP [StageForceMoveXY] ( #02, #02 )
    RTS 
}

code_0BD6BA {
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BD6C1 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveY] ( #12, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #02 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1E )
    COP [RngByte]
    STA $26
    COP [SpawnAfterFlags] ( @code_0BD6FE, #$0202 )
    LDA $26
    CLC 
    ADC #$0055
    AND #$00FF
    STA $0026, Y
    COP [SpawnAfterFlags] ( @code_0BD6FE, #$0202 )
    LDA $26
    CLC 
    ADC #$00AA
    AND #$00FF
    STA $0026, Y
}

code_0BD6FE {
    LDA $26
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0001
    STA $7F100E, X
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #13 )

  loc_0BD725:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BD725
    LDA $08
    STZ $08
    STA $26

  loc_0BD731:
    COP [SetEntryExit]
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CLC 
    ADC #$04
    STA $orbitDiameter, X
    BCS loc_0BD77B
    REP #$20
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@chunk_008000.code_00F4C7
    PLA 
    SEC 
    SBC $16
    STA $7F100E, X
    PLA 
    SEC 
    SBC $14
    STA $7F100C, X
    DEC $26
    BPL loc_0BD731
    BRA loc_0BD725

  loc_0BD77B:
    REP #$20
    LDA #$6000
    TRB $12
    LDA $7F100C, X
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA $7F100E, X
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BRA loc_0BD7AA

  loc_0BD79C:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BD79C
    LDA $08
    STZ $08
    STA $26

  loc_0BD7A8:
    COP [SetEntryExit]

  loc_0BD7AA:
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_0BD7C7
    DEC $26
    BPL loc_0BD7A8
    BRA loc_0BD79C

  loc_0BD7C7:
    COP [Die]
}

code_0BD7C9 {
    COP [PaletteStart] ( #6A )
    COP [PaletteStep]
    COP [Die]
}

code_0BD7D0 {
    COP [PaletteStart] ( #69 )
    COP [PaletteStep]
    COP [Die]
}

code_0BD7D7 {
    PHX 
    LDX $0006, Y
    STY $0000

  loc_0BD7DE:
    LDA $0000
    CMP $parentId, X
    BNE loc_0BD801
    LDA $0014, X
    CLC 
    ADC $0018
    STA $0014, X
    LDA $0016, X
    CLC 
    ADC $001C
    STA $0016, X
    LDA $0006, X
    TAX 
    BRA loc_0BD7DE

  loc_0BD801:
    PLX 
    LDA $0018
    EOR #$FFFF
    INC 
    CLC 
    ADC $cameraDeltaX
    STA $cameraDeltaX
    LDA $001C
    EOR #$FFFF
    INC 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    RTS 
}

code_0BD81F {
    LDA #$8011
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080
    STA $extendedFlags, X
    LDA #$AD2C
    STA $statsPtr, X
    LDA $&stats_table+154
    AND #$00FF
    STA $currentHp, X
    STZ $26
    RTS 
}

code_0BD843 {
    LDA #$8000
    TSB $joypadMaskStd
    COP [WaitByte] ( #EF )
    LDA #$0000
    STA $characterForm
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_0BD864 {
    LDA $orbitAngle, X
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C36C.binary_01C43D, Y
    BPL loc_0BD875
    EOR #$FF
    INC 
    SEC 

  loc_0BD875:
    XBA 
    LDA $orbitDiameter, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_0BD88A
    EOR #$FFFF
    INC 

  loc_0BD88A:
    RTS 
}

code_0BD88B {
    BRK #$00
    ORA $A9, S
    ORA ($00, S), Y
    STA $playerMaxHp
    STA $playerHp
    LDA #$0020
    STA $playerStr
    INC 
    STA $playerDef
    SEP #$20
    LDA #$01
    STA $MEMSEL
    REP #$20
    LDA #$0002
    STA $characterForm
    LDA #$00FF
    STA $abilityBitmask
    LDY $decelStepCounter
    LDA #$0200
    ORA $0010, Y
    STA $0010, Y
    LDA #$0000
    STA $28

  loc_0BD8C7:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $joypadCurrent
    BIT #$0080
    BNE loc_0BD8D4
    RTL 

  loc_0BD8D4:
    LDA $28
    INC 
    CMP #$0042
    BCC loc_0BD8DF
    LDA #$0000

  loc_0BD8DF:
    STA $28
    STZ $2A
    LDA #$0080
    TSB $joypadHeld
    COP [SetEntryExit]
    BRA loc_0BD8C7

  loc_0BD8ED:
    RTL 
}

code_0BD8EE {
    BRK #$00
    ORA $02, S
    DEY 
    BRK #$E0
    STX $00A9
    BRK #$85
    PLP 

  loc_0BD8FB:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $joypadCurrent
    BIT #$0080
    BNE loc_0BD908
    RTL 

  loc_0BD908:
    LDA $28
    INC 
    CMP #$0033
    BCC loc_0BD913
    LDA #$0000

  loc_0BD913:
    STA $28
    STZ $2A
    LDA #$0080
    TSB $joypadHeld
    COP [SetEntryExit]
    BRA loc_0BD8FB

  loc_0BD921:
    RTL 
}

code_0BD922 {
    PHX 
    PHD 
    PHB 
    PHP 
    REP #$20
    LDA #$0000
    TCD 
    LDA #$0100
    STA $3E
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDA #$7F
    STA $40
    LDA $06BF
    SEC 
    SBC $06C1
    STA $18
    LDA $06C3
    SEC 
    SBC $06C5
    STA $1C
    STZ $19
    STZ $1D

  loc_0BD951:
    LDA $19
    CLC 
    ADC $18
    BMI loc_0BD994
    CMP $0693
    BCS loc_0BD99E
    LDA $1D
    CLC 
    ADC $1C
    BMI loc_0BD99E
    CMP $0697
    BCS loc_0BD9AA
    LDA $1D
    XBA 
    LDA $0695
    JSL $@chunk_028000.code_0282F6
    CLC 
    ADC $19
    XBA 
    LDA #$00
    TAY 
    LDA $1D
    CLC 
    ADC $1C
    XBA 
    LDA $0693
    JSL $@chunk_028000.code_0282F6
    CLC 
    ADC $19
    CLC 
    ADC $18
    XBA 
    LDA #$00
    TAX 
    JSR $&code_0BD9AF

  loc_0BD994:
    LDA $19
    INC 
    STA $19
    CMP $0695
    BCC loc_0BD951

  loc_0BD99E:
    STZ $19
    LDA $1D
    INC 
    STA $1D
    CMP $0699
    BCC loc_0BD951

  loc_0BD9AA:
    PLP 
    PLB 
    PLD 
    PLX 
    RTL 
}

code_0BD9AF {
    LDA $S_effectLayerTilemap, Y
    BEQ loc_0BD9BC
    STA $3E
    LDA [$3E]
    STA $collisionLayer, X

  loc_0BD9BC:
    INY 
    INX 
    TXA 
    BNE code_0BD9AF
    RTS 
}

code_0BD9C2 {
    BRK #$00
    JSR $00A9
    PHP 
    TSB $10
    LDA #$00
    BPL loc_0BD9D2
    ORA ($02)
    STZ $D9D9
    PHB 
    BRK #$20
    COP [SetEntryContinue]
    RTL 
}

code_0BD9D9 {
    COP [WaitByte] ( #03 )
    LDA #$78
    BRK #$85
    BIT $02
    ASL 
    BRK #$02
    LDA $@chunk_028000.loc_02D9E7+1B, X
    TSB $02
    COP [WaitByte] ( #3B )
    COP [WriteApuIo0] ( #00 )
    COP [PrintDialogString] ( &dialogstring_0BDA02 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #3B )
    COP [BranchIfButton] ( #$0080, &code_0BD9E1 )
    RTL 
}

dialogstring_0BDA02 `[DLG:3,6][SIZ:D,3,0][TPL:1]カレン: ひどいじゃない?![N]あたしを おいてけぼりにして[N]どこまで 行こうっていうのよっ![PAL:0][END]`

actor_def_0BDA3F [
  actor-def < #00, #00, #28, {

  code_0BDA42:
    LDA #$FF
    SBC $@scene_meta.0D928D, X
    STA $0D96
    STA $0D98
    LDA #$01
    RTI 
    TSB $09FA
    SEP #$20
    LDA #$88
    STA $2124
    LDA #$22
    STA $2125
    REP #$20
    LDA #$0000
    STA $cgramPalette
    SEP #$20
    LDA #$01
    STA $212C
    LDA #$04
    STA $212D
    LDA #$82
    STA $2130
    LDA #$41
    STA $2131
    REP #$20
    LDA #$0080
    STA $068A
    STA $06BE
    LDA #$0300
    STA $068E
    STA $06C2
    LDA #$3000
    TSB $065A
    LDA #$2800
    TSB $09BC
    COP [RunBg3Script] ( @01E780 )
    COP [PrintDialogString] ( &dialogstring_0BDB45 )
    JSR $&code_0BEA6C
    LDA #$0F00
    STA $065C
    STZ $18
    COP [SetEntryContinue]
    LDA $0654
    BNE loc_0BDABB
    RTL 

  loc_0BDABB:
    BRA loc_0BDAC1

  code_0BDABD:
    COP [PrintDialogStringAlt] ( &dialogstring_0BDB45 )

  loc_0BDAC1:
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D98

  code_0BDACD:
    COP [RunBg3Script] ( @01E780 )
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0800, &code_0BDAE7 )
    COP [BranchIfButton] ( #$0400, &code_0BDB00 )
    COP [BranchIfButton] ( #$0080, &code_0BDB1C )
    RTL 
} >
]

code_0BDAE7 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D98
    DEC 
    BPL loc_0BDAF3
    LDA #$0003

  loc_0BDAF3:
    STA $0D98
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BDB00 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D98
    INC 
    CMP #$0004
    BCC loc_0BDB0F
    LDA #$0000

  loc_0BDB0F:
    STA $0D98
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BDB1C {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D98
    AND #$0003
    STA $0000
    LDA #$FFFF
    STA $0D98
    COP [SwitchCase] ( #$0000, &code_list_0BDB3D )
}

code_list_0BDB3D [
  &code_0BDB7C   ;00
  &code_0BE397   ;01
  &code_0BE17C   ;02
  &code_0BDE2C   ;03
]

dialogstring_0BDB45 `[DLG:6,A][SIZ:A,4,0]旅を始める[N]旅の記録を消す[N]旅の記録をうつす[N]サウンド/ボタンの変こう`

code_0BDB7C {
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BDD33 )
    COP [CallScript] ( &code_0BE556 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA $0D8C
    AND #$0003
    STA $0D92
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BDBB3 )
    COP [BranchIfButton] ( #$0400, &code_0BDBCC )
    COP [BranchIfButton] ( #$0080, &code_0BDBFA )
    COP [BranchIfButton] ( #$8000, &code_0BDBE8 )
    RTL 
}

code_0BDBB3 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BDBBF
    LDA #$0002

  loc_0BDBBF:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BDBCC {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BDBDB
    LDA #$0000

  loc_0BDBDB:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BDBE8 {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    JSR $&code_0BE8BC
    JMP $&code_0BDABD
}

code_0BDBFA {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D92
    STA $0D8C
    LDA #$FFFF
    STA $0D92
    LDA $0D8C
    STA $306000
    JSL $@chunk_3B7DD.code_03D65D
    BCS loc_0BDC4E
    JSR $&code_0BDDEE
    LDA $0AB2
    STA $0AAC
    LDA #$00E6
    STA $0642
    LDA #$0078
    STA $064C
    LDA #$0090
    STA $064E
    LDA #$0003
    STA $0650
    LDA #$1100
    STA $0652
    LDA #$2800
    TRB $09BC
    COP [Die]

  loc_0BDC4E:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D8E
    STA $0D90
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BE074 )
    COP [PrintDialogString] ( &dialogstring_0BE0DD )
    COP [PrintDialogString] ( &dialogstring_0BE0E8 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA #$0000
    STA $0D98

  code_0BDC80:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &code_0BDCB6 )
    COP [BranchIfButton] ( #$0800, &code_0BDED3 )
    COP [BranchIfButton] ( #$0400, &code_0BDEEC )
    COP [BranchIfButton] ( #$8000, &code_0BDC9B )
    RTL 
}

code_0BDC9B {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    STA $0D92
    JMP $&code_0BDB7C
}

code_0BDCB6 {
    LDA $0D98
    BEQ loc_0BDCF3
    DEC 
    BNE loc_0BDCD7
    COP [PlaySoundCh2] ( #0D )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintDialogString] ( &dialogstring_0BE0DD )
    COP [RunBg3Script] ( @01E780 )
    JMP $&code_0BDC80

  loc_0BDCD7:
    DEC 
    BNE loc_0BDCF3
    COP [PlaySoundCh2] ( #0D )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintDialogString] ( &dialogstring_0BE0E8 )
    COP [RunBg3Script] ( @01E780 )
    JMP $&code_0BDC80

  loc_0BDCF3:
    COP [BranchIfButton] ( #$0080, &code_0BDCFA )
    RTL 
}

code_0BDCFA {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA #$FFFF
    STA $0D98
    LDA $0D90
    STA $0B24
    LDA $0D8E
    STA $0B26
    JSR $&code_0BDDEE
    LDA #$0008
    STA $0642
    COP [QueueMapChange] ( #08, #$0050, #$00A0, #00, #$1200 )
    LDA #$2800
    TRB $09BC
    COP [Die]
}

dialogstring_0BDD33 `[DLG:2,8][SIZ:E,7,0]どの記録にしますか?[N] 旅の記録1 [ADR:&chunk_0B8000.loc_0BE5C4,D74][N][N] 旅の記録2 [ADR:&chunk_0B8000.loc_0BE5C4,D76][N][N] 旅の記録3 [ADR:&chunk_0B8000.loc_0BE5C4,D78]`

dialogstring_0BDD79 `[DLG:2,C][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

dialogstring_0BDDA0 `[DLG:2,10][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

dialogstring_0BDDC7 `[DLG:2,14][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

code_0BDDEE {
    LDA $0B24
    BNE loc_0BDDFE
    SEP #$20
    LDA #$91
    STA $2140
    REP #$20
    BRA loc_0BDE07

  loc_0BDDFE:
    SEP #$20
    LDA #$90
    STA $2140
    REP #$20

  loc_0BDE07:
    LDA $0B26
    BNE loc_0BDE25
    LDA #$8000
    STA $0DAC
    LDA #$4000
    STA $0DAA
    LDA #$2000
    STA $0DB0
    LDA #$0040
    STA $0DAE
    RTS 

  loc_0BDE25:
    LDA #$2000
    STA $0DB0
    RTS 
}

code_0BDE2C {
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BE12D )
    COP [CallScript] ( &code_0BE556 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA #$0000
    STA $0D92

  code_0BDE45:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BE3CB )
    COP [BranchIfButton] ( #$0400, &code_0BE3E4 )
    COP [BranchIfButton] ( #$0080, &code_0BDE72 )
    COP [BranchIfButton] ( #$8000, &code_0BDE60 )
    RTL 
}

code_0BDE60 {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    JSR $&code_0BE8BC
    JMP $&code_0BDABD
}

code_0BDE72 {
    COP [PlaySoundCh2] ( #12 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BDE89
    RTL 

  loc_0BDE89:
    COP [PlaySoundCh2] ( #11 )
    LDA $0D92
    STA $0D94
    JSR $&code_0BDFAF
    LDA #$FFFF
    STA $0D92
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BE007 )
    COP [PrintDialogString] ( &dialogstring_0BE0DD )
    COP [PrintDialogString] ( &dialogstring_0BE0E8 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA #$0000
    STA $0D98

  code_0BDEB8:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &code_0BDF1D )
    COP [BranchIfButton] ( #$0800, &code_0BDED3 )
    COP [BranchIfButton] ( #$0400, &code_0BDEEC )
    COP [BranchIfButton] ( #$8000, &code_0BDF08 )
    RTL 
}

code_0BDED3 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D98
    DEC 
    BPL loc_0BDEE8
    LDA #$0002

  loc_0BDEE8:
    STA $0D98
    RTL 
}

code_0BDEEC {
    COP [PlaySoundCh2] ( #10 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D98
    INC 
    CMP #$0003
    BCC loc_0BDF04
    LDA #$0000

  loc_0BDF04:
    STA $0D98
    RTL 
}

code_0BDF08 {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    LDA #$FFFF
    STA $0D98
    JMP $&code_0BDE2C
}

code_0BDF1D {
    LDA $0D98
    BEQ loc_0BDF5A
    DEC 
    BNE loc_0BDF3E
    COP [PlaySoundCh2] ( #10 )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintDialogString] ( &dialogstring_0BE0DD )
    COP [RunBg3Script] ( @01E780 )
    JMP $&code_0BDEB8

  loc_0BDF3E:
    DEC 
    BNE loc_0BDF5A
    COP [PlaySoundCh2] ( #10 )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintDialogString] ( &dialogstring_0BE0E8 )
    COP [RunBg3Script] ( @01E780 )
    JMP $&code_0BDEB8

  loc_0BDF5A:
    COP [BranchIfButton] ( #$0080, &code_0BDF61 )
    RTL 
}

code_0BDF61 {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    JSR $&code_0BDFDB
    PHX 
    LDA $0D94
    XBA 
    ASL 
    TAX 
    JSL $@chunk_3B7DD.code_03D6C1
    LDA $0018
    STA $3063FC, X
    LDA $001C
    STA $3063FE, X
    PLX 
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BE12D )
    COP [CallScript] ( &code_0BE556 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA $0D94
    STA $0D92
    JMP $&code_0BDE45
}

code_0BDFAF {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D90
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D8E
    PLX 
    PLX 
    RTS 
}

code_0BDFDB {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D90
    STA $306200, X
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D8E
}

code_0BE000 {
    STA $306200, X
    PLX 
    PLX 
    RTS 
}

dialogstring_0BE007 `[DLG:6,8][SIZ:A,8,0][SKP:2]サウンド/ボタンの変こう[N]変こうおわり[N]サウンド[N]ボタン タイプ[N][SKP:5] こうげき/会話[N][SKP:5] アイテム/キャンセル[N][SKP:5] アイテムパレット[N][SKP:5] 使用しません`

dialogstring_0BE074 `[DLG:6,8][SIZ:A,8,0]このせっていで いいですか[N]旅をはじめる[N]サウンド[N]ボタン タイプ[N][SKP:5] こうげき/会話[N][SKP:5] アイテム/キャンセル[N][SKP:5] アイテムパレット[N][SKP:5] 使用しません`

dialogstring_0BE0DD `[DLG:D,C][SFX:0][ADR:&chunk_0B8000.dialogstring_0BE11B,D90]`

dialogstring_0BE0E8 `[DLG:11,E][SFX:0][ADR:&chunk_0B8000.dialogstring_0BE0F3,D8E]`

dialogstring_0BE0F3 `[F7][E0]ぞ[E1]1[DLG:8,10]A[DLG:8,12]B[DLG:8,14]X[DLG:8,16]Y`

dialogstring_0BE109 `2[DLG:8,10]B[DLG:8,12]Y[DLG:8,14]X[DLG:8,16]A`

dialogstring_0BE11B `.[E1]F[E1]ステレオ`

dialogstring_0BE126 `モノラル`

dialogstring_0BE12D `[DLG:2,8][SIZ:E,7,0]どのサウンド/ボタンを変こうしますか[N] 旅の記録1 [ADR:&chunk_0B8000.loc_0BE5C4,D74][N][N] 旅の記録2 [ADR:&chunk_0B8000.loc_0BE5C4,D76][N][N] 旅の記録3 [ADR:&chunk_0B8000.loc_0BE5C4,D78]`

code_0BE17C {
    LDA $0D74
    BEQ loc_0BE19D
    LDA $0D76
    BEQ loc_0BE19D
    LDA $0D78
    BEQ loc_0BE19D
    LDA #$0002
    STA $0D98
    COP [PrintDialogString] ( &dialogstring_0BE363 )
    COP [RunBg3Script] ( @01E780 )
    JMP $&code_0BDACD

  loc_0BE19D:
    JSR $&code_0BE8BC
    LDA #$0000
    STA $0D92

  code_0BE1A6:
    COP [PrintDialogString] ( &dialogstring_0BE31B )
    COP [CallScript] ( &code_0BE556 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0800, &code_0BE1D1 )
    COP [BranchIfButton] ( #$0400, &code_0BE1EA )
    COP [BranchIfButton] ( #$0080, &code_0BE218 )
    COP [BranchIfButton] ( #$8000, &code_0BE206 )
    RTL 
}

code_0BE1D1 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE1DD
    LDA #$0002

  loc_0BE1DD:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE1EA {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE1F9
    LDA #$0000

  loc_0BE1F9:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE206 {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    JSR $&code_0BE8BC
    JMP $&code_0BDABD
}

code_0BE218 {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE22F
    RTL 

  loc_0BE22F:
    LDY #$0000

  loc_0BE232:
    LDA $0D74, Y
    BEQ loc_0BE241
    INY 
    INY 
    CPY #$0006
    BCC loc_0BE232
    BNE loc_0BE241
    RTL 

  loc_0BE241:
    TYA 
    LSR 
    STA $0D96
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BE261 )
    COP [BranchIfButton] ( #$0400, &code_0BE286 )
    COP [BranchIfButton] ( #$0080, &code_0BE2BD )
    COP [BranchIfButton] ( #$8000, &code_0BE2AE )
    RTL 
}

code_0BE261 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE267:
    DEC 
    BPL loc_0BE26D
    LDA #$0002

  loc_0BE26D:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE267
    ASL 
    TAY 
    LDA $0D74, Y
    BNE code_0BE261
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE286 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE28C:
    INC 
    CMP #$0003
    BCC loc_0BE295
    LDA #$0000

  loc_0BE295:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE28C
    ASL 
    TAY 
    LDA $0D74, Y
    BNE code_0BE286
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE2AE {
    COP [PlaySoundCh2] ( #0D )
    JSR $&code_0BE8BC
    LDA #$FFFF
    STA $0D96
    JMP $&code_0BE1A6
}

code_0BE2BD {
    LDA $0D96
    ASL 
    TAY 
    LDA $0D74, Y
    BEQ loc_0BE2CA
    JMP $&code_0BE218

  loc_0BE2CA:
    COP [PlaySoundCh2] ( #29 )
    LDA $0656
    ORA $0658
    STA $0658
    PHX 
    LDA $0D92
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAX 
    LDA $0D96
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAY 
    SEP #$20
    LDA #$30
    STA $0405
    LDA #$30
    STA $0404
    REP #$20
    LDA #$01FF
    JSR $0402
    PLX 
    LDA $0D96
    STA $0D92
    LDA #$FFFF
    STA $0D96
    JSR $&code_0BEA6C
    JSR $&code_0BE8BC
    JMP $&code_0BE1A6
}

dialogstring_0BE31B `[DLG:2,8][SIZ:E,7,0]どの記録をうつしますか?[N] 旅の記録1 [ADR:&chunk_0B8000.loc_0BE5C4,D74][N][N] 旅の記録2 [ADR:&chunk_0B8000.loc_0BE5C4,D76][N][N] 旅の記録3 [ADR:&chunk_0B8000.loc_0BE5C4,D78]`

dialogstring_0BE363 `[ZZZ][DLG:4,15][SIZ:C,2,0][DLY:0]旅の記録が空いていません.[N]記録を消してから選んでください.[FIN][CLD][RET]`

dialogstring_0BE396 ``

code_0BE397 {
    JSR $&code_0BE8BC

  code_0BE39A:
    COP [PrintDialogString] ( &dialogstring_0BE510 )
    COP [CallScript] ( &code_0BE556 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    LDA #$0000
    STA $0D92

  code_0BE3B0:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BE3CB )
    COP [BranchIfButton] ( #$0400, &code_0BE3E4 )
    COP [BranchIfButton] ( #$0080, &code_0BE412 )
    COP [BranchIfButton] ( #$8000, &code_0BE400 )
    RTL 
}

code_0BE3CB {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE3D7
    LDA #$0002

  loc_0BE3D7:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE3E4 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE3F3
    LDA #$0000

  loc_0BE3F3:
    STA $0D92
    LDA $0656
    ORA $0658
    STA $0658
    RTL 
}

code_0BE400 {
    COP [PlaySoundCh2] ( #0D )
    LDA $0656
    ORA $0658
    STA $0658
    JSR $&code_0BE8BC
    JMP $&code_0BDABD
}

code_0BE412 {
    COP [PlaySoundCh2] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE435
    COP [PlaySoundCh2] ( #12 )
    LDA $0D92
    JSL $@chunk_3B7DD.code_03D69D
    JMP $&code_0BE3B0

  loc_0BE435:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    JSR $&code_0BE8BC
    COP [PrintDialogString] ( &dialogstring_0BE4B8 )
    COP [RunBg3Script] ( @01E780 )
    LDA $0D94
    ASL 
    TAY 
    LDA $0D7A, Y
    PHY 
    JSR $&code_0BED8D
    PLY 
    STA $0D9A
    LDA $0D80, Y
    PHY 
    JSR $&code_0BED8D
    PLY 
    STA $0D9E
    LDA $0D86, Y
    PHY 
    JSR $&code_0BED8D
    PLY 
    STA $0D9C
    COP [PrintDialogString] ( &dialogstring_0BE4A9 )
    COP [RunBg3Script] ( @01E780 )
    JSR $&code_0BE8E4
    COP [DialogueOptions] ( #02, #03, &code_list_0BE485 )
}

code_list_0BE485 [
  &code_0BE397   ;00
  &code_0BE397   ;01
  &code_0BE48B   ;02
]

code_0BE48B {
    COP [PlaySoundCh2] ( #13 )
    COP [SetEntryContinue]
    LDA $0D94
    JSL $@chunk_3B7DD.code_03D69D
    COP [WaitByte] ( #1D )
    LDA $1C
    STA $1A
    STZ $1C
    JSR $&code_0BE8BC
    JSR $&code_0BEA6C
    JMP $&code_0BE39A
}

dialogstring_0BE4A9 `[DLG:4,8][ADR:&chunk_0B8000.dialogstring_0BE4B2,D94]`

dialogstring_0BE4B2 `9[DD][A3][DD][RET]`

dialogstring_0BE4B7 `[DD]`

dialogstring_0BE4B8 `[DLG:4,6][SIZ:D,5,0][ADR:&chunk_0B8000.dialogstring_0BE4DD,D94][N][N]の記録を消しますか?[N] いいえ[N] はい`

dialogstring_0BE4DD `[E3][E4][F2][E4]ぎ[E5]旅の記録1 [ADR:&chunk_0B8000.loc_0BE5C4,D74]`

dialogstring_0BE4F2 `旅の記録2 [ADR:&chunk_0B8000.loc_0BE5C4,D76]`

dialogstring_0BE501 `旅の記録3 [ADR:&chunk_0B8000.loc_0BE5C4,D78]`

dialogstring_0BE510 `[DLG:2,8][SIZ:E,7,0]どの記録を 消しますか?[N]旅の記録1 [ADR:&chunk_0B8000.loc_0BE5C4,D74][N][N]旅の記録2 [ADR:&chunk_0B8000.loc_0BE5C4,D76][N][N]旅の記録3 [ADR:&chunk_0B8000.loc_0BE5C4,D78]`

code_0BE556 {
    LDA $0D74
    BEQ loc_0BE57A
    LDA $0D7A
    JSR $&code_0BED8D
    STA $0D9A
    LDA $0D80
    JSR $&code_0BED8D
    STA $0D9E
    LDA $0D86
    JSR $&code_0BED8D
    STA $0D9C
    COP [PrintDialogString] ( &dialogstring_0BDD79 )

  loc_0BE57A:
    LDA $0D76
    BEQ loc_0BE59E
    LDA $0D7C
    JSR $&code_0BED8D
    STA $0D9A
    LDA $0D82
    JSR $&code_0BED8D
    STA $0D9E
    LDA $0D88
    JSR $&code_0BED8D
    STA $0D9C
    COP [PrintDialogString] ( &dialogstring_0BDDA0 )

  loc_0BE59E:
    LDA $0D78
    BEQ loc_0BE5C2
    LDA $0D7E
    JSR $&code_0BED8D
    STA $0D9A
    LDA $0D84
    JSR $&code_0BED8D
    STA $0D9E
    LDA $0D8A
    JSR $&code_0BED8D
    STA $0D9C
    COP [PrintDialogString] ( &dialogstring_0BDDC7 )

  loc_0BE5C2:
    COP [RestoreSavedPtr]

  loc_0BE5C4:
    CPY $E7
    CMP $@27C4E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CLD 
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$E5]
    SBC [$C4]
    SBC [$C4]
    SBC [$EF]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$FB]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$06]
    INX 
    CPY $E7
    ASL $E8
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    ORA ($E8), Y
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    ORA $@27C4E8, X
    CPY $E7
    ORA $@27C4E8, X
    ORA $@27C4E8, X
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    BIT $C4E8
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$2C]
    INX 
    CPY $E7
    CPY $E7
    BIT $C4E8
    SBC [$2C]
    INX 
    CPY $E7
    CPY $E7
    CPY $E7
    AND $E8, X
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    AND $@27C4E8, X
    AND $@27C4E8, X
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    PHA 
    INX 
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    EOR ($E8), Y
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    PHY 
    INX 
    PHY 
    INX 
    CPY $E7
    PHY 
    INX 
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    STZ $E8
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    ADC ($E8), Y
    CPY $E7
    ADC ($E8), Y
    CPY $E7
    CPY $E7
    CPY $E7
    ADC ($E8), Y
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    ADC $C4E8, Y
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$C4]
    SBC [$85]
    INX 
    CPY $E7
    STY $E8, X
    CPY $E7
    CPY $E7
    STY $E8, X
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    STA $@27C4E8, X
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    PLB 
    INX 
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    LDA ($E8, S), Y
    CPY $E7
    CPY $E7
    LDA ($E8, S), Y
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7

  loc_0BE7B2:
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    CPY $E7
    STA ($1B, X)
    BRA loc_0BE79F

  loc_0BE7C8:
    RTI 
    ADC ($54, X)
    ASL $5C
    ADC $CC, S
    PEI ($45)
    AND $DASB4, X
    ADC ($1B, S), Y
    CMP $CC, X
    PEI ($3E)
    ASL $7366
    ASL $4A80
    CMP $65, X
    AND $&parallax_table.binary_01CC3B+23, X
    PEI ($3E)
    ASL $7366
    ASL $4A80
    CMP $CC, X
    PEI ($3C)
    LSR $7362
    BRA loc_0BE841

  loc_0BE7F6:
    CMP $53, X
    BRA loc_0BE846

  loc_0BE7FA:
    CPY $61D4
    ADC ($3C, X)
    CMP $53, X
    PEI ($00)
    EOR $D5, S
    CPY $3CD4
    PLA 
    RTI 
    CMP $53, X
    BRA loc_0BE7B2

  loc_0BE80E:
    STA ($7F, X)
    CPY $4F80
    EOR ($80, S), Y
    BVC loc_0BE837
    PEI ($56)
    PER loc_0BEE8F
    TSC 
    CMP $CC, X
    PEI ($0A)
    BIT $5D5E, X
    PLA 
    ASL $5180
    BRA loc_0BE87C

  loc_0BE82A:
    CMP $CC, X
    BRA loc_0BE832

  loc_0BE82E:
    BRA loc_0BE84D

  loc_0BE830:
    STA ($99, X)

  loc_0BE832:
    STA ($9A, X)
    CPY $5880

  loc_0BE837:
    BRA loc_0BE892

  loc_0BE839:
    EOR ($70, X)
    AND $680D, X
    CPY $5BD4

  loc_0BE841:
    ADC ($80, S), Y
    AND ($80), Y
    EOR [$D5], Y
    CPY $&table_018000+A
    PHY 
    BRA loc_0BE8A8

  loc_0BE84D:
    EOR ($80, S), Y
    EOR #$D4CC
    AND $736D, X
    LSR 
    PHY 
    TSC 
    CMP $CC, X
    BRA loc_0BE8BA

  loc_0BE85C:
    BRA loc_0BE8BD

  loc_0BE85E:
    EOR ($80, S), Y
    RTS 
}

code_0BE861 {
    BRA loc_0BE8AD

  loc_0BE863:
    CPY $3180
    BRA loc_0BE8B8

  loc_0BE868:
    BRA loc_0BE8C7

  loc_0BE86A:
    JSR $3ED4
    AND $&array_01D3F7+16E, X
    CPY $5280
    EOR ($80, S), Y
    ADC ($80, X)
    PER loc_0B6946
    ADC $80, S

  loc_0BE87C:
    STZ $80
    ADC $53
    BRA loc_0BE8CE

  loc_0BE882:
    BRA loc_0BE8EA

  loc_0BE884:
    CPY $3BD4
    PLA 
    MVP #$73, #$63
    ROR $6E
    LSR $1D80
    STA ($99, X)

  loc_0BE892:
    CMP $CC, X
    PEI ($3B)
    PLA 
    MVP #$73, #$63
    ROR $6E
    LSR $&parallax_table.binary_01CC92+43
    EOR $14
    WDM 
    EOR ($80, S), Y
    EOR #$D420
    ASL 

  loc_0BE8A8:
    AND $@gfx_greatwall+B3D, X
    INC 

  loc_0BE8AD:
    ADC ($5A, X)
    ROR $&array_01D3F7+117
    CPY $14D4
    ORA [$63], Y
    CMP $53, X
    BRA loc_0BE922

  loc_0BE8BB:
    CPY $0BDA
    LDA #$0000
    TCD 
    SEP #$20
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282E1
    JSL $@chunk_028000.code_02FCBC
    JSL $@chunk_028000.code_02FCA6
    LDA #$00
    STA $HDMAEN
    REP #$20
    LDA #$0000
    STA $worldReadyFlag
    PLD 
    PLX 
    RTS 
}

code_0BE8E4 {
    LDA #$0000
    SEP #$20
    PHX 

  loc_0BE8EA:
    PHD 
    TCD 
    JSL $@chunk_028000.code_0282D4
    REP #$20
    LDA #$000F
    STA $worldReadyFlag
    SEP #$20
    LDA $0066
    STA $HDMAEN
    JSL $@chunk_028000.code_028168
    LDA #$0F
    STA $INIDISP
    REP #$20
    PLD 
    PLX 
    RTS 
}

code_0BE90E {
    COP [BranchIfButton] ( #$8000, &code_0BE994 )
    COP [BranchIfButton] ( #$6040, &code_0BE9A9 )
    COP [BranchIfButton] ( #$0800, &code_0BE974 )
    COP [BranchIfButton] ( #$0400, &code_0BE97C )
    LDA $14
    CMP #$0002
    BCS loc_0BE939
    COP [BranchIfButton] ( #$0200, &code_0BE984 )
    COP [BranchIfButton] ( #$0100, &code_0BE98C )

  loc_0BE939:
    LDA $18
    INC $18
    BIT #$000F
    BEQ loc_0BE95B
    LDA $1A
    CLC 
    RTS 
}

code_0BE946 {
    STA $1A
    JSR $&code_0BEA03
    STZ $18
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $18

  loc_0BE95B:
    BIT #$0010
    BNE loc_0BE967
    JSR $&code_0BE9B9
    LDA $1A
    CLC 
    RTS 

  loc_0BE967:
    JSR $&code_0BE9E1
    LDA #$0001
    TSB $09FA
    LDA $1A
    CLC 
    RTS 
}

code_0BE974 {
    LDA $1A
    SEC 
    SBC #$0001
    BRA code_0BE946
}

code_0BE97C {
    LDA $1A
    CLC 
    ADC #$0001
    BRA code_0BE946
}

code_0BE984 {
    LDA $1A
    SEC 
    SBC #$0002
    BRA code_0BE946
}

code_0BE98C {
    LDA $1A
    CLC 
    ADC #$0002
    BRA code_0BE946
}

code_0BE994 {
    JSR $&code_0BE9B9
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA $1A
    SEC 
    RTS 
}

code_0BE9A9 {
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA #$FFFF
    SEC 
    RTS 
}

code_0BE9B9 {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@code_0BEA44, X
    SEC 
    SBC #$EA44
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@code_0BEA44+2, X
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    LDA #$0001
    TSB $09FA
    RTS 
}

code_0BE9E1 {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@code_0BEA44, X
    SEC 
    SBC #$EA44
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@code_0BEA44+2, X
    TAX 
    LDA #$2020
    STA $7F0200, X
    PLX 
    RTS 
}

code_0BEA03 {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@code_0BEA44, X
    SEC 
    SBC #$EA44
    TAX 
    LDA $1A
    BPL loc_0BEA1A
    CLC 
    ADC $@code_0BEA44, X

  loc_0BEA1A:
    CMP $@code_0BEA44, X
    BCC loc_0BEA25
    SEC 
    SBC $@code_0BEA44, X

  loc_0BEA25:
    STA $1A
    LDA $@code_0BEA44, X
    TAY 
    DEY 
    INX 
    INX 

  loc_0BEA2F:
    LDA $@code_0BEA44, X
    PHX 
    TAX 
    LDA #$2020
    STA $7F0200, X
    PLX 
    INX 
    INX 
    DEY 
    BPL loc_0BEA2F
    PLX 
    RTS 
}

code_0BEA44 {
    JMP $56EA
    NOP 
    JML $@code_2A64EA
}

code_0BEA4C {
    TSB $00
    LSR 
    ORA ($CA, X)
    ORA ($60, X)
    ORA ($E0, X)
    ORA ($02, X)
    BRK #$CE
    ORA ($D8, X)
    ORA ($03, X)
    BRK #$CA
    COP [ResumeAfterSnap]
    TSB $CA
    ORA $03
    BRK #$4A
    ORA $CA, S
    ORA $4A, S
    TSB $DA
    LDA #$0000
    STA $0D74
    STA $0D76
    STA $0D78
    STA $0D7A
    STA $0D7C
    STA $0D7E
    STA $0D80
    STA $0D82
    STA $0D84
    STA $0D80
    STA $0D82
    STA $0D84
    LDA #$0002
    STA $24
    STZ $26
    LDA $306000
    CMP #$0003
    BCC loc_0BEAAB
    LDA #$0000
    STA $306000

  loc_0BEAAB:
    STA $0D8C

  code_0BEAAE:
    LDA $24
    XBA 
    ASL 
    TAX 
    JSL $@chunk_3B7DD.code_03D6C1
    LDA $0018
    CMP $3063FC, X
    BNE loc_0BEB19
    LDA $001C
    CMP $3063FE, X
    BNE loc_0BEB19
    PHX 
    LDA $24
    ASL 
    TAY 
    TXA 
    CLC 
    ADC #$0B12
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D74, Y
    LDA $01, S
    CLC 
    ADC #$0ACA
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D7A, Y
    LDA $01, S
    CLC 
    ADC #$0ADC
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D80, Y
    LDA $01, S
    CLC 
    ADC #$0ADE
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D86, Y
    PLA 
    SEC 
    BRA loc_0BEB1A

  loc_0BEB19:
    CLC 

  loc_0BEB1A:
    ROL $26
    LDA $24
    DEC 
    STA $24
    BMI loc_0BEB26
    JMP $&code_0BEAAE

  loc_0BEB26:
    PLX 
    RTS 
}

code_0BEB28 {
    COP [GenHdmaSine]
    BPL loc_0BEB2E
    PHD 
    COP [SetOnInteract] ( &code_0BEB34 )
    COP [SetEntryContinue]
    RTL 
}

code_0BEB34 {
    LDA #$0028
    STA $playerMaxHp
    STA $playerHp
    LDA #$007F
    STA $playerStr
    STA $playerDef
    LDA #$00FF
    STA $abilityBitmask
    COP [PrintDialogString] ( &dialogstring_0BEC14 )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEB56 )
}

code_list_0BEB56 [
  &code_0BEB60   ;00
  &code_0BEB60   ;01
  &code_0BEB8D   ;02
  &code_0BEBAB   ;03
  &code_0BEB9C   ;04
]

code_0BEB60 {
    COP [PrintDialogString] ( &dialogstring_0BEC7A )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEB6A )
}

code_list_0BEB6A [
  &code_0BEB74   ;00
  &code_0BEB74   ;01
  &code_0BEBBA   ;02
  &code_0BEBC9   ;03
  &code_0BEBD8   ;04
]

code_0BEB74 {
    COP [PrintDialogString] ( &dialogstring_0BECA0 )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEB7E )
}

code_list_0BEB7E [
  &code_0BEB88   ;00
  &code_0BEB88   ;01
  &code_0BEBE7   ;02
  &code_0BEBF6   ;03
  &code_0BEC05   ;04
]

code_0BEB88 {
    COP [PrintDialogString] ( &dialogstring_0BECCE )
    RTL 
}

code_0BEB8D {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #82, #$0020, #$0090, #07, #$1400 )
    RTL 
}

code_0BEB9C {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #78, #$0250, #$0370, #03, #$4500 )
    RTL 
}

code_0BEBAB {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    RTL 
}

code_0BEBBA {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    RTL 
}

code_0BEBC9 {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #49, #$0050, #$00D0, #00, #$1100 )
    RTL 
}

code_0BEBD8 {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #0F, #$0078, #$05D0, #00, #$6100 )
    RTL 
}

code_0BEBE7 {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #91, #$0370, #$0430, #03, #$5400 )
    RTL 
}

code_0BEBF6 {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #07, #$2200 )
    RTL 
}

code_0BEC05 {
    COP [PrintDialogString] ( &dialogstring_0BECF8 )
    COP [QueueMapChange] ( #C3, #$0010, #$00E8, #07, #$2300 )
    RTL 
}

dialogstring_0BEC14 `[DEF]はあーい! ぼくは デバッグマン![N]シナリオ上で まだ行けないところへ[N]君を つれてってあげようっ!![FIN] その他  [N] 万里の長城[N] だ天使の町[N] 水上都市 `

dialogstring_0BEC7A `[CLR] その他[N] イトリー村[N] ニールの小屋[N] 城の地下`

dialogstring_0BECA0 `[CLR] やめる[N] 大都市エウロ[N] 原住民の村落[N] ドレイ商人の町`

dialogstring_0BECCE `[CLR]そうかい.[N]シナリオどおりに 進むなら ぼくは[N]むしして つづけてくれっ![END]`

dialogstring_0BECF8 `[CLR]OK! わかった!![N]ただし フラグが めちゃめちゃに[N]なるから 注意が必要だぜっ![END]`

dialogstring_0BED2A `[AD][E0]がM[E2]が[8D][E2]が[AD][E2]がぺ[E0]が[AD][E0]が[89]かが[F0]([AC][B8]ぞ[B9]┌がそぜが[99]┌が[A9]かがづ[E2]がぅ[9C][DE]がぅ[EE][DE]がぅ[AD][E0]が[89]が送ぎぅ[AD][DE]が [8D][ED][8D]がが[AD][8A]じぼぁ┌が[8D]ぼが[AD][8E]じぼぁゅが[8D]ぺが[A9]がR[8D]ぐがB[DD][B7][83]ぅ`

code_0BED8D {
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8
    BCS loc_0BEDF7
    CMP #$01F4
    BCC loc_0BEDAA
    SEC 
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_0BEDAA:
    CMP #$0064
    BCC loc_0BEDB8
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_0BEDAA

  loc_0BEDB8:
    PHA 
    LDA $0000
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20
    CMP #$32
    BCC loc_0BEDD4
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_0BEDD4:
    CMP #$0A
    BCC loc_0BEDE0
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_0BEDD4

  loc_0BEDE0:
    PHA 
    LDA $0000
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $01, S
    STA $01, S
    PLA 
    REP #$20
    STA $01, S
    STY $0000
    PLA 
    CLC 
    RTS 

  loc_0BEDF7:
    STY $0000
    PLA 
    SEC 
    RTS 
}

code_0BEDFD {
    LDA $00E1
    BIT #$F040
    ASL $A9
    TSB $22
    INC $8282
    RTL 
}

code_0BEE0B {
    LDA $421A
    STA $00E0
    RTL 
}

code_0BEE12 {
    RTL 
}

code_0BEE13 {
    LDA $0660
    BIT #$0080
    BEQ loc_0BEE57

  loc_0BEE1B:
    JSL $@chunk_028000.code_0282B6
    JSL $@code_0BEE58
    JSL $@chunk_028000.code_0282C7
    LDA $0660
    BIT #$0080
    BNE loc_0BEE1B

  loc_0BEE2F:
    JSL $@chunk_028000.code_0282B6
    JSL $@code_0BEE58
    JSL $@chunk_028000.code_0282C7
    LDA $0660
    BIT #$0080
    BEQ loc_0BEE2F

  loc_0BEE43:
    JSL $@chunk_028000.code_0282B6
    JSL $@code_0BEE58
    JSL $@chunk_028000.code_0282C7
    LDA $0660
    BIT #$0080
    BNE loc_0BEE43

  loc_0BEE57:
    RTL 
}

code_0BEE58 {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

  loc_0BEE62:
    LDA $L_RDNMI
    BPL loc_0BEE62
    LDA $L_RDNMI
    LDA $06EF
    BIT #$08
    BEQ loc_0BEEBB
    LDA $C2
    STA $211B
    LDA $C3
    STA $211B
    LDA $C4
    STA $211C
    LDA $C5
    STA $211C
    LDA $C6
    STA $211D
    LDA $C7
    STA $211D
    LDA $C8
    STA $211E
    LDA $C9
    STA $211E
    LDA $CA
    STA $211F
    LDA $CB
    AND #$1F
    STA $211F
    LDA $CC
    STA $2120
    LDA $CD
    AND #$1F
    STA $2120
    LDX $BE
    STX $CE
    LDX $C0
    STX $D0

  loc_0BEEBB:
    REP #$20
    LDA $09BA
    BEQ loc_0BEECB
    STA $0656
    STZ $09BA
    PLA 
    PLP 
    RTL 

  loc_0BEECB:
    LDA $0660
    AND #$0F00
    STA $065E
    LDA $0DB2
    BEQ loc_0BEEE7
    LDA $0660
    BIT #$1000
    BEQ loc_0BEEE7
    LDA $0DB2
    TSB $065E

  loc_0BEEE7:
    LDA $0DB4
    BEQ loc_0BEEFA
    LDA $0660
    BIT #$2000
    BEQ loc_0BEEFA
    LDA $0DB4
    TSB $065E

  loc_0BEEFA:
    LDA $0DAA
    BEQ loc_0BEF0D
    LDA $0660
    BIT #$8000
    BEQ loc_0BEF0D
    LDA $0DAA
    TSB $065E

  loc_0BEF0D:
    LDA $0DAE
    BEQ loc_0BEF20
    LDA $0660
    BIT #$4000
    BEQ loc_0BEF20
    LDA $0DAE
    TSB $065E

  loc_0BEF20:
    LDA $0DAC
    BEQ loc_0BEF33
    LDA $0660
    BIT #$0080
    BEQ loc_0BEF33
    LDA $0DAC
    TSB $065E

  loc_0BEF33:
    LDA $0DB0
    BEQ loc_0BEF46
    LDA $0660
    BIT #$0040
    BEQ loc_0BEF46
    LDA $0DB0
    TSB $065E

  loc_0BEF46:
    LDA $0DA8
    BEQ loc_0BEF59
    LDA $0660
    BIT #$0020
    BEQ loc_0BEF59
    LDA $0DA8
    TSB $065E

  loc_0BEF59:
    LDA $0DA6
    BEQ loc_0BEF6C
    LDA $0660
    BIT #$0010
    BEQ loc_0BEF6C
    LDA $0DA6
    TSB $065E

  loc_0BEF6C:
    LDA $065E
    STA $0656
    STA $0660
    AND $0658
    STA $0658
    BEQ loc_0BEF94
    AND $065C
    BEQ loc_0BEF94
    LDA $0662
    INC 
    STA $0662
    CMP #$000C
    BNE loc_0BEF97
    LDA $065C
    TRB $0658

  loc_0BEF94:
    STZ $0662

  loc_0BEF97:
    LDA $0658
    TRB $0656
    LDA $065A
    TRB $0656
    PLA 
    PLP 
    RTL 
}

thinker_def_0BEFA6 [
  thinker-def < #04, #08, {

  code_0BEFA8:
    COP [SetEntryExit]
    LDA $0720
    CLC 
    ADC #$FFF8
    STA $0720
    COP [QueueHdma] ( @dma_channel_0BEFBB, #0E )
    RTL 
} >
]

dma_channel_0BEFBB [
  dma-channel < #20, #20, #07 >
]

thinker_def_0BEFBF [
  thinker-def < #04, #08, {

  code_0BEFC1:
    SEP #$20
    LDA #$16
    STA $212C
    LDA #$00
    STA $212D
    LDA #$82
    STA $2130
    LDA #$02
    STA $2131
    LDA #$10
    STA $2107
    LDA #$18
    STA $2108
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0BEFC1 )
    RTL 
} >
]

code_0BEFEC {
    SEP #$20
    LDA #$17
    STA $212C
    LDA #$02
    STA $212D
    LDA #$82
    STA $2130
    LDA #$11
    STA $2131
    LDA #$10
    STA $2107
    LDA #$18
    STA $2108
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0BEFEC )
    RTL 
}

code_0BF017 {
    SEP #$20
    LDA #$17
    STA $212C
    LDA #$00
    STA $212D
    LDA #$80
    STA $2130
    LDA #$80
    STA $2131
    LDA #$10
    STA $2107
    LDA #$18
    STA $2108
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0BF017 )
    RTL 
}

code_0BF042 {
    SEP #$20
    LDA #$00
    STA $2126
    STA $2127
    LDA #$17
    STA $212C
    LDA #$00
    STA $212D
    LDA #$30
    STA $2125
    LDA #$22
    STA $2130
    LDA #$03
    STA $2131
    LDA #$57
    STA $7F0C02
    LDA #$10
    STA $2107
    LDA #$18
    STA $2108
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0BF042 )
    RTL 
}

code_0BF080 {
    SEP #$20
    LDA #$00
    STA $2125
    LDA #$17
    STA $212C
    LDA #$00
    STA $212D
    LDA #$80
    STA $2130
    LDA #$3F
    STA $2131
    LDA #$10
    STA $2107
    LDA #$18
    STA $2108
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0BF080 )
    RTL 
}

code_0BF0B0 {
    LDA #$0004
    STA $animScratch2, X
    LDA #$0000
    STA $animScratch, X
    STA $animScratch+2, X
    STA $spritesetPtr, X
    COP [SetEntryContinue]
    LDA $animScratch, X
    LSR 
    BCS loc_0BF0D4
    LDY #$0000
    BRA loc_0BF0D7

  loc_0BF0D4:
    LDY #$0200

  loc_0BF0D7:
    SEP #$20
    PHB 
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    PHD 
    LDA #$0000
    TCD 
    LDA $animScratch+2, X
    INC 
    INC 
    STA $animScratch+2, X
    STA $0E
    LDA #$857A
    STA $18
    LDA #$00FF
    STA $7C01, Y
    SEP #$20
    LDA #$45
    STA $7C00, Y
    INY 
    INY 
    INY 

  loc_0BF106:
    LDA #$04
    STA $7C00, Y
    LDA $18
    DEC 
    STA $18
    STA $7C01, Y
    LDA $19
    INC 
    STA $19
    STA $7C02, Y
    INY 
    INY 
    INY 
    DEC $0E
    BPL loc_0BF106
    LDA #$01
    STA $7C00, Y
    REP #$20
    LDA #$00FF
    STA $7C01, Y
    SEP #$20
    LDA #$00
    STA $7C03, Y
    PLD 
    PLB 
    LDA $animScratch, X
    LSR 
    BCS loc_0BF147
    COP [QueueDma] ( $7E7C00, #26 )
    BRA loc_0BF14D

  loc_0BF147:
    COP [QueueDma] ( $7E7E00, #26 )

  loc_0BF14D:
    LDA $animScratch, X
    INC 
    STA $animScratch, X
    LDA $animScratch+2, X
    CMP #$24
    BCS loc_0BF15F
    RTL 

  loc_0BF15F:
    LDA #$23
    STA $animScratch+2, X
    LDA $spritesetPtr, X
    INC 
    STA $spritesetPtr, X
    COP [ClearFlagByte] ( #02 )
    COP [SetEntryExit]
    COP [SetEntryExit]
    LDA #$FF
    STA $WH0
    COP [KillThinker]
    RTL 
}

code_0BF17D {
    COP [PaletteStart] ( #7D )
    COP [PaletteStep]
    COP [Die]

  code_0BF184:
    COP [PaletteStart] ( #7F )
    COP [PaletteStep]
    COP [Die]

  code_0BF18B:
    COP [PaletteStart] ( #69 )
    COP [PaletteStep]
    COP [Die]

  loc_0BF192:
    LDA #$08
    BRK #$14
    BPL loc_0BF19A
    STA $@0EA51B
    ORA #$00
    BRA loc_0BF125

  loc_0BF1A0:
    ASL $7AA9
    BRK #$85
    TRB $A9
    TYX 
    BRK #$85
    ASL $A9, X
    STY $03
    STA $26

  loc_0BF1B0:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BF1B0
    LDA $08
    STZ $08
    STA $24

  loc_0BF1BC:
    COP [SetEntryExit]
    DEC $26
    BMI loc_0BF1C8
    DEC $24
    BPL loc_0BF1BC
    BRA loc_0BF1B0

  loc_0BF1C8:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BF1F1, #$0300 )
    LDA $16
    BPL loc_0BF1C8
    BPL loc_0BF1DF
    EOR #$FF
    SBC $@30C91A, X
    BRK #$90
    CPX $02
    ROL $E8
    BRK #$00
    BRK #$00
    BRA loc_0BF1ED

  loc_0BF1ED:
    AND ($02, X)
    CMP ($6B, X)
}

code_0BF1F1 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [RngByte]
    AND #$0F
    BRK #$38
    SBC #$08
    BRK #$18
    ADC $14
    STA $14
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}

actor_def_0BF20B [
  actor-def < #00, #10, #29, {

  code_0BF20E:
    COP [SpawnAfter] ( @code_0BF2E1 )
    LDA #$02
    BRK #$8D
    PEI ($0A)
    LDY $decelStepCounter
    LDA #$92
    SBC ($99), Y
    BRK #$00
    LDA #$8B
    BRK #$99
    COP [GenHdmaSine]
    LDA #$00
    BRK #$99
    PHP 
    BRK #$A9
    BRK #$08
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    COP [RngByte]
    AND #$07
    BRK #$8D
    BRK #$00
    COP [SwitchCase] ( #$0000, &code_list_0BF244 )
} >
]

code_list_0BF244 [
  &code_0BF254   ;00
  &code_0BF254   ;01
  &code_0BF25D   ;02
  &code_0BF25D   ;03
  &code_0BF266   ;04
  &code_0BF266   ;05
  &code_0BF26F   ;06
  &code_0BF26F   ;07
]

code_0BF254 {
    COP [SpawnAfterFlags] ( @code_0BF284, #$0902 )
    BRA loc_0BF278
}

code_0BF25D {
    COP [SpawnAfterFlags] ( @code_0BF289, #$0902 )
    BRA loc_0BF278
}

code_0BF266 {
    COP [SpawnAfterFlags] ( @code_0BF28E, #$0902 )
    BRA loc_0BF278
}

code_0BF26F {
    COP [SpawnAfterFlags] ( @code_0BF293, #$0902 )
    BRA loc_0BF278

  loc_0BF278:
    COP [RngByte]
    AND #$07
    BRK #$18
    ADC #$10
    BRK #$85
    PHP 
    RTL 
}

code_0BF284 {
    COP [StageSprAndHitbox] ( #00 )
    BRA loc_0BF296
}

code_0BF289 {
    COP [StageSprAndHitbox] ( #01 )
    BRA loc_0BF296
}

code_0BF28E {
    COP [StageSprAndHitbox] ( #02 )
    BRA loc_0BF296
}

code_0BF293 {
    COP [StageSprAndHitbox] ( #03 )

  loc_0BF296:
    COP [OrActorFlags] ( #$0080 )
    LDA #$30
    BRK #$04
    ORA ($02)
    AND $85, S
    TRB $C9
    ROR 
    BRK #$90
    ORA $C9
    TXA 
    BRK #$90
    AND ($A9)
    CPY #$85FF
    ASL $A9, X
    BRK #$00
    STA $moveXAlt, X
    LDA $0410
    LSR 
    BCS loc_0BF2C8
    LDA #$0B
    BRK #$9F
    INC 
    BRK #$7F
    BRA loc_0BF2CF

  loc_0BF2C8:
    LDA #$09
    BRK #$9F
    INC 
    BRK #$7F

  loc_0BF2CF:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $16
    BMI loc_0BF2CF
    CMP #$80
    ORA ($90, X)
    BEQ loc_0BF2E2
    CPX #$20E2
    LDA #$15
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    RTL 
}

actor_def_0BF2F0 [
  actor-def < #00, #00, #21, {

  code_0BF2F3:
    LDA #$0010
    TSB $12
    LDA #$0000
    STA $cameraTargetY
    STA $cameraTargetX
    STA $cameraDeltaY
    STA $cameraDeltaX
    LDA #$0081
    STA $14
    LDA #$00EA
    STA $16
    LDY $decelStepCounter
    LDA #$FA35
    STA $0000, Y
    LDA #$008B
    STA $0002, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0BF337
    RTL 

  loc_0BF337:
    COP [SpawnAfter] ( @code_0BF17D )
    COP [SetEntryExit]
    LDY #$0F00
    LDA #$EFEC
    STA $0000, Y
    COP [StartMusic] ( #10 )
    COP [SetDeathCallback] ( @code_0BF3CE )
    COP [WaitByte] ( #FE )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]

  loc_0BF357:
    COP [SetHitCallback] ( &code_0BF382 )
    LDA #$2000
    TRB $10
    COP [SpawnLastRel] ( @code_0BF996, #00, #00, #$0301 )
    STY $24
    LDA #$0064
    STA $26
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0BF377
    RTL 

  loc_0BF377:
    LDA #$2000
    TSB $10

  loc_0BF37C:
    COP [WaitWord] ( #$01DF )
    BRA loc_0BF357
} >
]

code_0BF382 {
    LDA #$2000
    TSB $10
    COP [SpawnLastRel] ( @code_0BF3B3, #00, #00, #$2000 )
    COP [LoopInit] ( #10 )
    LDY $24
    BEQ loc_0BF3A0
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y

  loc_0BF3A0:
    COP [SetEntryExit]
    LDY $24
    BEQ loc_0BF3AF
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0BF3AF:
    COP [LoopNext]
    BRA loc_0BF37C
}

code_0BF3B3 {
    COP [LoopInit] ( #10 )
    SEP #$20
    LDA #$16
    STA $TM
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA #$17
    STA $TM
    REP #$20
    COP [LoopNext]
    COP [Die]
}

code_0BF3CE {
    COP [SetFlagByte] ( #03 )
    COP [SetHitCallback] ( #$0000 )
    COP [SetDeathCallback] ( $000000 )
    LDA #$2300
    TSB $10
    LDY $24
    BEQ loc_0BF3EC
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y

  loc_0BF3EC:
    COP [SpawnAfter] ( @code_0BF184 )
    COP [WaitByte] ( #3B )
    LDY #$0F00
    LDA #$EFC1
    STA $0000, Y
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitByte] ( #77 )
    LDA #$AD2C
    STA $statsPtr, X
    LDA $&stats_table+154
    AND #$00FF
    STA $currentHp, X
    LDA #$0301
    STA $10
    LDA #$1000
    TSB $12
    LDA #$0080
    TSB $09FA
    COP [SetEntryExit]
    LDA #$0800
    TSB $slopeCurvePtrB
    LDY $decelStepCounter
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y
    COP [LoopInit] ( #80 )
    LDA $bg2ScrollH
    CLC 
    ADC #$0002
    STA $cameraTargetY
    LDY $0056

  loc_0BF44A:
    LDA $0010, Y
    BIT #$0400
    BEQ loc_0BF45C
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y

  loc_0BF45C:
    LDA $0006, Y
    TAY 
    BNE loc_0BF44A
    COP [LoopNext]
    COP [SetEntryExit]
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    LDY #$0F00
    LDA #$EFEC
    STA $0000, Y
    COP [SetFlagByte] ( #01 )
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y
    COP [WaitByte] ( #63 )
    LDY #$0F00
    LDA #$F042
    STA $0000, Y
    COP [WaitByte] ( #63 )
    LDA #$0080
    TRB $09FA
    COP [StageBgChange] ( #9D )
    COP [ApplyBgChange]
    COP [SpawnMarkedAfter] ( @code_0BF929, #$0301 )
    TYA 
    STA $orbitAngle, X
    COP [SpawnMarkedAfter] ( @code_0BF842, #$2200 )
    COP [SpawnMarkedAfter] ( @code_0BF849, #$2200 )
    LDA #$0080
    STA $14
    LDA #$0150
    STA $16
    LDA #$2000
    TRB $10
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]

  code_0BF4D0:
    COP [SetDeathCallback] ( @code_0BF59A )

  code_0BF4D5:
    COP [SetEntryContinue]
    LDA $orbitDiameter, X
    BMI loc_0BF4E8
    DEC 
    STA $orbitDiameter, X
    LDA #$0000
    JMP $&code_0BF581

  loc_0BF4E8:
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BF4F6 )
}

code_list_0BF4F6 [
  &code_0BF581   ;00
  &code_0BF581   ;01
  &code_0BF506   ;02
  &code_0BF506   ;03
  &code_0BF506   ;04
  &code_0BF506   ;05
  &code_0BF506   ;06
  &code_0BF506   ;07
]

code_0BF506 {
    LDA #$0003
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    TAY 
    LDA #$F964
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    LDA #$0200
    TSB $10
    LDA #$0057
    STA $7F0C02
    COP [SpawnThinker] ( @code_0BF0B0 )
    COP [SetFlagByte] ( #02 )
    COP [SpawnLastRel] ( @code_0BF18B, #00, #00, #$2000 )
    COP [PlaySoundCh1] ( #20 )
    COP [SpawnLastRel] ( @code_0BF6AC, #00, #00, #$2200 )

  code_0BF551:
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #02, #01, &code_0BF551 )
    LDA #$00FF
    STA $WH0
    COP [StageSpriteLoop] ( #06, #3C )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    LDA $orbitAngle, X
    TAY 
    LDA #$F945
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    JMP $&code_0BF4D5
}

code_0BF581 {
    COP [SpawnLastRel] ( @code_0BF738, #00, #00, #$0301 )
    COP [SpawnLastRel] ( @code_0BF765, #00, #00, #$0301 )
    COP [WaitWord] ( #$012B )
    JMP $&code_0BF4D0
}

code_0BF59A {
    COP [SetFlagByte] ( #04 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SpawnLastRel] ( @chunk_0A8000.code_0AA2B1, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0BF647, #00, #E0, #$2300 )
    COP [SpawnLastRel] ( @code_0BF614, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0BF625, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0BF636, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0BF6D7, #00, #00, #$2800 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDY #$0F00
    LDA #$F080
    STA $0000, Y
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitWord] ( #$012B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
    LDA #$0800
    TSB $10
    COP [WaitByte] ( #01 )
    LDA #$0000
    STA $characterForm
    RTL 
}

code_0BF614 {
    LDA #$0060
    STA $14
    LDA #$01B8
    STA $16

  loc_0BF61E:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    BRA loc_0BF61E
}

code_0BF625 {
    LDA #$00B1
    STA $14
    LDA #$01B8
    STA $16

  loc_0BF62F:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    BRA loc_0BF62F
}

code_0BF636 {
    LDA #$00B4
    STA $14
    LDA #$01A0
    STA $16

  loc_0BF640:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    BRA loc_0BF640
}

code_0BF647 {
    LDA #$0080
    STA $14
    LDA #$0170
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0C )
    COP [SpawnLastRel] ( @code_0BF675, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0BF682, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [LoopNext]
    COP [Die]
}

code_0BF675 {
    COP [PlaySoundCh1] ( #06 )
    JSR $&code_0BF68F
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0BF682 {
    COP [PlaySoundCh1] ( #06 )
    JSR $&code_0BF68F
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0BF68F {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0BF6AC {
    LDA #$AD38
    STA $statsPtr, X
    LDA $&stats_table+160
    AND #$00FF
    STA $currentHp, X
    LDA #$0080
    STA $14
    LDA #$01D0
    STA $16
    COP [WaitByte] ( #09 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoop] ( #1F, #0A )
    COP [AnimLoop]
    COP [Die]
}

code_0BF6D7 {
    LDA #$0220
    STA $16
    COP [LoopInit] ( #1E )
    COP [SpawnAfterFlags] ( @code_0BF701, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterFlags] ( @code_0BF70E, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterFlags] ( @code_0BF71B, #$0B00 )
    COP [WaitByte] ( #0E )
    COP [LoopNext]
    COP [Die]
}

code_0BF701 {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1B, #00, #06 )
    COP [AnimOnce]
    BRA loc_0BF728
}

code_0BF70E {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1C, #00, #06 )
    COP [AnimOnce]
    BRA loc_0BF728
}

code_0BF71B {
    COP [RngByte]
    STA $14
    COP [StageSpriteMoveXY] ( #1D, #00, #08 )
    COP [AnimOnce]
    BRA loc_0BF728

  loc_0BF728:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $16
    CMP #$00E0
    BCS loc_0BF728
    COP [Die]
}

code_0BF738 {
    LDA #$0031
    STA $14
    LDA #$0197
    STA $16
    COP [SpawnAfterFlags] ( @code_0BF835, #$0301 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    LDA #$0010
    STA $14
    LDA #$0150
    STA $16
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$0004
    STA $26
    JMP $&code_0BF799
}

code_0BF765 {
    COP [SetHFlip]
    LDA #$0002
    TSB $12
    LDA #$00CF
    STA $14
    LDA #$0197
    STA $16
    COP [SpawnAfterFlags] ( @code_0BF835, #$0301 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    LDA #$00F0
    STA $14
    LDA #$0150
    STA $16
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$000C
    STA $26
    JMP $&code_0BF799
}

code_0BF799 {
    COP [PlaySoundCh1] ( #20 )
    COP [OrActorFlags] ( #$0010 )
    LDA #$00A0
    TSB $12
    LDA #$0100
    TRB $10
    LDA #$AD30
    STA $statsPtr, X
    LDA $&stats_table+158
    AND #$00FF
    STA $currentHp, X
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E77A, #$2000 )
    LDA #$800B
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $decelStepCounter
    STA $0024, Y
    PHX 
    TYX 
    LDA $26
    STA $animScratch2, X
    PLX 
    LDA #$0002
    TSB $10
    COP [StageSpriteLoop] ( #0B, #05 )
    COP [AnimLoop]
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $7F100E, X
    LDA $0000
    STA $7F100C, X
    COP [KillNext]

  loc_0BF80B:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryContinue]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_0BF82C
    RTL 

  loc_0BF82C:
    LDA $10
    BIT #$4000
    BEQ loc_0BF80B
    COP [Die]
}

code_0BF835 {
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [Die]

  loc_0BF83C:
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
}

code_0BF842 {
    LDA #$0018
    STA $14
    BRA loc_0BF84E
}

code_0BF849 {
    LDA #$00E8
    STA $14

  loc_0BF84E:
    LDA #$01D8
    STA $16

  loc_0BF853:
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0078
    STA $08
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #04, #01, &code_0BF927 )
    COP [SpawnMarkedAfter] ( @code_0BF86F, #$0200 )
    BRA loc_0BF853
}

code_0BF86F {
    COP [OrActorFlags] ( #$0080 )
    LDA #$00A0
    TSB $12
    COP [StageSpriteLoop] ( #11, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$AD34
    STA $statsPtr, X
    LDA $&stats_table+15C
    AND #$00FF
    STA $currentHp, X
    COP [PlaySoundCh1] ( #1D )
    COP [SetDeathCallback] ( @code_0BF91F )
    LDA #$0200
    TRB $10
    COP [StageSpriteMoveY] ( #13, #0A )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #13, #2A )
    COP [AnimOnce]
    LDA #$0000
    STA $currentHp, X
    LDA #$F8C4
    STA $retPtr2, X
    STA $00
    LDA #$0005
    STA $loopCounter, X
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #04, #01, &code_0BF922 )
    COP [RngByte]
    LDY $decelStepCounter
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0014, Y
    STA $moveXAlt, X
    BPL loc_0BF8E3
    RTL 

  loc_0BF8E3:
    CMP #$0108
    BCC loc_0BF8E9
    RTL 

  loc_0BF8E9:
    LDA $0411
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $0016, Y
    CMP #$0100
    BCS loc_0BF8FD
    RTL 

  loc_0BF8FD:
    CMP #$01E8
    BCC loc_0BF903
    RTL 

  loc_0BF903:
    STA $moveYAlt, X
    COP [MoveToward] ( #13, #02 )
    LDA $10
    BIT #$4000
    BNE code_0BF927
    COP [StageSpriteLoop] ( #13, #01 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [SetDeathCallback] ( $000000 )
}

code_0BF91F {
    COP [PlaySoundCh1] ( #1B )
}

code_0BF922 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
}

code_0BF927 {
    COP [Die]
}

code_0BF929 {
    LDA #$0080
    STA $14
    LDA #$01AA
    STA $16
    COP [SpawnMarkedAfterRel] ( @code_0BF98F, #FC, #FC, #$0301 )
    COP [SpawnMarkedAfterRel] ( @code_0BF989, #04, #00, #$0301 )
    LDY $06
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0BF95D:
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    BRA loc_0BF95D

  loc_0BF964:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDY $06
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0BF989 {
    COP [StageSprAndHitbox] ( #0C )
    COP [WaitByte] ( #09 )
}

code_0BF98F {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA code_0BF98F
}

code_0BF996 {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BF9B6, #$0202 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDY $24
    LDA #$0000
    STA $0024, Y
    COP [Die]
}

code_0BF9B6 {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )

  loc_0BF9BE:
    COP [StageSpriteMoveY] ( #15, #0C )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_0BF9F3 )
    LDA $16
    BPL loc_0BF9BE
    BPL loc_0BF9D4
    EOR #$FFFF
    INC 

  loc_0BF9D4:
    CMP #$0030
    BCC loc_0BF9BE
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #0E )
    COP [BranchIfFlagByte] ( #03, #01, &code_0BF9F3 )
    COP [SpawnAfterFlags] ( @code_0BF9F5, #$0202 )
    COP [WaitByte] ( #0E )
    COP [LoopNext]
}

code_0BF9F3 {
    COP [Die]
}

code_0BF9F5 {
    COP [BranchIfFlagByte] ( #03, #01, &code_0BF9F3 )
    COP [PlaySoundCh1] ( #23 )
    COP [RngByte]
    STA $14
    COP [RngByte]
    LSR 
    BCS loc_0BFA1E

  loc_0BFA07:
    COP [StageSpriteMoveY] ( #16, #09 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_0BF9F3 )
    LDA $16
    BMI loc_0BFA07
    CMP #$0120
    BCC loc_0BFA07
    COP [Die]

  loc_0BFA1E:
    COP [StageSpriteMoveY] ( #16, #0D )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #01, &code_0BF9F3 )
    LDA $16
    BMI loc_0BFA1E
    CMP #$0120
    BCC loc_0BFA1E
    COP [Die]

  loc_0BFA35:
    LDA #$0008
    TRB $10
    LDA #$0088
    STA $14
    LDA #$FFC0
    STA $16

  loc_0BFA44:
    COP [StagePlayerMoveY] ( #1B, #07 )
    COP [AnimOnce]
    LDA $16
    BMI loc_0BFA44
    CMP #$00E0
    BCC loc_0BFA44
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    JML $@chunk_028000.code_02D01B
}

code_0BFA65 {
    BRK #$00
    JSR $&code_0BFF6B
    SBC $@3FFFFF, X
    SBC $@3FFFFF, X
}