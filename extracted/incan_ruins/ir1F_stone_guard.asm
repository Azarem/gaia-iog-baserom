; Stone Guard mini-boss — shielded enemy with complex attack AI (~770 lines).
; 
; Heavily armored enemy with shield that blocks attacks from certain
; directions. Uses BranchOnPlayer* for directional decision-making.
; Patrol state walks in cardinal directions checking wall collisions.
; Attack state charges toward player, has shield-up and shield-down
; phases affecting vulnerability. Uses hit callbacks to track damage
; and switch between defensive and aggressive stances. Spawns
; projectile children for ranged attacks. Includes dungeon kill
; counter tracking for room-clear progression.
---------------------------------------------

?INCLUDE 'ApplyPlayerHitstun'
?INCLUDE 'interaction_handlers'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!orbitAngle                     7F0010
!currentHp                      7F0026

---------------------------------------------

ir1F_stone_guard1 [
  actor-def < #00, #00, #03, {

  code_0A9064:
    BRA loc_0A9077
} >
]
---------------------------------------------

ir1F_stone_guard2 [
  actor-def < #01, #00, #03, {

  code_0A9069:
    BRA loc_0A9077
} >
]
---------------------------------------------

ir1F_stone_guard3 [
  actor-def < #02, #00, #03, {

  code_0A906E:
    BRA loc_0A9077
} >
]
---------------------------------------------

ir1F_stone_guard4 [
  actor-def < #02, #00, #03, {

  code_0A9073:
    COP [SetHFlip]
    BRA loc_0A9077

  loc_0A9077:
    LDA #$0010
    TSB $12
    LDA $0F
    AND #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $orbitAngle, X
    COP [SetSpritePalette] ( #0E )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #08 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    LDA $orbitAngle, X
    BEQ loc_0A90BB
    BRA loc_0A90C3

  loc_0A90A3:
    LDA #$0200
    TRB $10
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$000A
    BNE loc_0A90B4
    RTL 

  loc_0A90B4:
    LDA #$0200
    TSB $10
    BRA code_0A90C7

  loc_0A90BB:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_0A90C7 )
    RTL 

  loc_0A90C3:
    COP [ExitIfFlagByte] ( #0F, #01 )
} >
]

code_0A90C7 {
    COP [BranchIfNotOnGridline] ( &code_0A90CD )
    BRA loc_0A90D2
}

code_0A90CD {
    COP [SetEntryExitNow] ( @code_0A90C7 )

  loc_0A90D2:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0300
    TRB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    JMP $&code_0A910A
}
---------------------------------------------

ir1F_stone_guard5 [
  actor-def < #00, #00, #00, {

  code_0A9104:
    COP [SetSpritePriority] ( #20 )

  loc_0A9107:
    COP [WaitWhileOffscreen] ( #0E )
} >
]

code_0A910A {
    COP [SetEntryExit]

  code_0A910C:
    LDA $10
    BIT #$4000
    BNE loc_0A9107
    COP [BranchNearerAxis] ( &code_0A9119, &code_0A9123 )
}

code_0A9119 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A9146, &code_0A9123, &code_0A9161 )
}

code_0A9123 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A917C, &code_0A912D, &code_0A9198 )
}

code_0A912D {
    RTL 
}

code_0A912E {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A913E )
}

code_list_0A913E [
  &code_0A9146   ;00
  &code_0A9161   ;01
  &code_0A917C   ;02
  &code_0A9198   ;03
]

code_0A9146 {
    COP [BranchIfPlayerNear] ( #04, &code_0A91B4 )

  code_0A914B:
    COP [BranchIfSolidWest] ( &code_0A912E )
    COP [StageSpriteMoveX] ( #07, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A912E )
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    BRA code_0A910C
}

code_0A9161 {
    COP [BranchIfPlayerNear] ( #04, &code_0A91C9 )

  code_0A9166:
    COP [BranchIfSolidEast] ( &code_0A912E )
    COP [StageSpriteMoveX] ( #87, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A912E )
    COP [StageSpriteMoveX] ( #88, #01 )
    COP [AnimOnce]
    BRA code_0A910C
}

code_0A917C {
    COP [BranchIfPlayerNear] ( #04, &code_0A91DE )

  code_0A9181:
    COP [BranchIfSolidNorth] ( &code_0A912E )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A912E )
    COP [StageSpriteMoveY] ( #06, #02 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A9198 {
    COP [BranchIfPlayerNear] ( #04, &code_0A91F3 )

  code_0A919D:
    COP [BranchIfSolidSouth] ( &code_0A912E )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A912E )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A91B4 {
    COP [BranchIfPlayerInRelTiles] ( #FA, #FF, #00, #01, &code_0A9208 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    JMP $&code_0A914B
}

code_0A91C9 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #06, #01, &code_0A923C )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    JMP $&code_0A9166
}

code_0A91DE {
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0A92A4 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    JMP $&code_0A9181
}

code_0A91F3 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #06, &code_0A9270 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_0A919D
}

code_0A9208 {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A92D8, #FC, #E8, #$0202 )
    COP [StageSpriteLoop] ( #2E, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A92F2, #$FFF0, #$FFE0, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A923C {
    COP [StageSpriteFrame] ( #AD )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A9310, #04, #E8, #$0202 )
    COP [StageSpriteLoop] ( #AE, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #AF )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A932A, #$0010, #$FFE0, #$0300 )
    COP [StageSpriteFrame] ( #AF )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #82 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A9270 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A9348, #F6, #EC, #$0202 )
    COP [StageSpriteLoop] ( #28, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A9362, #$FFFC, #$0010, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A92A4 {
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A9380, #0B, #ED, #$0202 )
    COP [StageSpriteLoop] ( #2B, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A939A, #$0004, #$FFF8, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    JMP $&code_0A910C
}

code_0A92D8 {
    JSR $&code_0A93B8
    COP [LoopInit] ( #20 )

  loc_0A92DE:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A92DE
    JSR $&code_0A93D2
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A92EE
    RTL 

  loc_0A92EE:
    COP [LoopNext]
    COP [Die]
}

code_0A92F2 {
    COP [SpawnMarkedAfter] ( @code_0A94EE, #$2000 )

  loc_0A92F9:
    COP [StageSpriteMoveX] ( #11, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A92F9
    COP [Die]

  loc_0A9308:
    COP [StageSpriteLoop] ( #94, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9310 {
    JSR $&code_0A93B8
    COP [LoopInit] ( #20 )

  loc_0A9316:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A9316
    JSR $&code_0A93D2
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A9326
    RTL 

  loc_0A9326:
    COP [LoopNext]
    COP [Die]
}

code_0A932A {
    COP [SpawnMarkedAfter] ( @code_0A9497, #$2000 )

  loc_0A9331:
    COP [StageSpriteMoveX] ( #91, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A9331
    COP [Die]

  loc_0A9340:
    COP [StageSpriteLoop] ( #14, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9348 {
    JSR $&code_0A93B8
    COP [LoopInit] ( #20 )

  loc_0A934E:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A934E
    JSR $&code_0A93D2
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A935E
    RTL 

  loc_0A935E:
    COP [LoopNext]
    COP [Die]
}

code_0A9362 {
    COP [SpawnMarkedAfter] ( @code_0A93E9, #$2000 )

  loc_0A9369:
    COP [StageSpriteMoveY] ( #0F, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A9369
    COP [Die]

  loc_0A9378:
    COP [StageSpriteLoop] ( #12, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9380 {
    JSR $&code_0A93B8
    COP [LoopInit] ( #20 )

  loc_0A9386:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A9386
    JSR $&code_0A93D2
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A9396
    RTL 

  loc_0A9396:
    COP [LoopNext]
    COP [Die]
}

code_0A939A {
    COP [SpawnMarkedAfter] ( @code_0A9441, #$2000 )

  loc_0A93A1:
    COP [StageSpriteMoveY] ( #10, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A93A1
    COP [Die]

  loc_0A93B0:
    COP [StageSpriteLoop] ( #13, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A93B8 {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #0E )
    RTS 
}

code_0A93D2 {
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTS 
}

code_0A93E9 {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A93F7
    COP [SetEntryContinue]
    RTL 

  loc_0A93F7:
    BIT #$2280
    BEQ loc_0A93FD
    RTL 

  loc_0A93FD:
    LDA #$0008
    JSR $&code_0A9598
    BPL loc_0A9409
    EOR #$FFFF
    INC 

  loc_0A9409:
    CMP #$0005
    BCC loc_0A940F
    RTL 

  loc_0A940F:
    LDA $0014, Y
    SEC 
    SBC $0018
    BPL loc_0A941C
    EOR #$FFFF
    INC 

  loc_0A941C:
    CMP #$0007
    BCC loc_0A9422
    RTL 

  loc_0A9422:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA $0B02
    CLC 
    ADC #$0002
    LDY #$0000
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0A9378
    JSR $&code_0A9570
    JMP $&code_0A953D
}

code_0A9441 {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A944F
    COP [SetEntryContinue]
    RTL 

  loc_0A944F:
    BIT #$2280
    BEQ loc_0A9455
    RTL 

  loc_0A9455:
    LDA #$0008
    JSR $&code_0A9598
    SEC 
    SBC #$0020
    BPL loc_0A9465
    EOR #$FFFF
    INC 

  loc_0A9465:
    CMP #$0005
    BCC loc_0A946B
    RTL 

  loc_0A946B:
    LDA $0014, Y
    SEC 
    SBC $0018
    BPL loc_0A9478
    EOR #$FFFF
    INC 

  loc_0A9478:
    CMP #$0007
    BCC loc_0A947E
    RTL 

  loc_0A947E:
    PHY 
    LDA $0B02
    CLC 
    ADC #$0002
    LDY #$0001
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0A93B0
    JSR $&code_0A9570
    JMP $&code_0A953D
}

code_0A9497 {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A94A5
    COP [SetEntryContinue]
    RTL 

  loc_0A94A5:
    BIT #$2280
    BEQ loc_0A94AB
    RTL 

  loc_0A94AB:
    LDA #$0000
    JSR $&code_0A957D
    CLC 
    ADC #$0004
    BPL loc_0A94BB
    EOR #$FFFF
    INC 

  loc_0A94BB:
    CMP #$0005
    BCC loc_0A94C1
    RTL 

  loc_0A94C1:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_0A94CE
    EOR #$FFFF
    INC 

  loc_0A94CE:
    CMP #$000D
    BCC loc_0A94D4
    RTL 

  loc_0A94D4:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA #$0002
    LDY #$0003
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0A9308
    JSR $&code_0A9570
    BRA code_0A953D
}

code_0A94EE {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A94FC
    COP [SetEntryContinue]
    RTL 

  loc_0A94FC:
    BIT #$2280
    BEQ loc_0A9502
    RTL 

  loc_0A9502:
    LDA #$0010
    JSR $&code_0A957D
    SEC 
    SBC #$0004
    BPL loc_0A9512
    EOR #$FFFF
    INC 

  loc_0A9512:
    CMP #$0005
    BCC loc_0A9518
    RTL 

  loc_0A9518:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_0A9525
    EOR #$FFFF
    INC 

  loc_0A9525:
    CMP #$000D
    BCC loc_0A952B
    RTL 

  loc_0A952B:
    PHY 
    LDA #$0002
    LDY #$0002
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0A9340
    JSR $&code_0A9570
}

code_0A953D {
    PHX 
    LDX $playerActor
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
    LDX $playerActor
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

code_0A9570 {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    RTS 
}

code_0A957D {
    CLC 
    ADC $playerXPos
    STA $0018
    LDA $playerYPos
    CLC 
    ADC #$0004
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}

code_0A9598 {
    CLC 
    ADC $playerYPos
    STA $001C
    LDA $playerXPos
    CLC 
    ADC #$0008
    STA $0018
    LDY $24
    LDA $0016, Y
    SEC 
    SBC $001C
    RTS 
}