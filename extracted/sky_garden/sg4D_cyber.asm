; Cyber enemy — the largest regular enemy in Sky Garden (~1,469 lines).
; 
; Massive flying enemy AI with multiple movement phases,
; projectile attacks, and complex directional behavior trees.
; Uses BranchOnPlayer* and BranchNearerAxis extensively for
; 4-directional pursuit. Fires projectile children from
; multiple offsets. One of the most complex non-boss enemies
; in the game.
---------------------------------------------

?INCLUDE 'sg_bird_flight_patterns'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sg4D_blue_cyber [
  actor-def < #00, #00, #00, {

  code_0AB4B3:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0AB509 )
    COP [NudgePosition] ( #01, #00 )

  loc_0AB4C0:
    COP [WaitWhileOffscreen] ( #0F )

  loc_0AB4C3:
    COP [RngByte]
    AND #$0007
    STA $orbitAngle, X
    COP [LoopStart] ( #03 )
    COP [NudgePosition] ( #FF, #00 )
    COP [CallNear] ( &code_0ABFC6 )
    COP [CallNear] ( &code_0ABFED )
    COP [CallNear] ( &code_0AC014 )
    COP [CallNear] ( &code_0AC03B )
    COP [CallNear] ( &code_0AC062 )
    COP [NudgePosition] ( #01, #00 )
    COP [CallNear] ( &code_0AC089 )
    COP [CallNear] ( &code_0AC0B0 )
    COP [CallNear] ( &code_0AC0D7 )
    LDA $10
    BIT #$4000
    BNE loc_0AB4C0
    LDA #$FFFF
    STA $orbitAngle, X
    COP [LoopEnd]
    BRA loc_0AB4C3
} >
]

code_0AB509 {
    LDA $14
    AND #$0007
    BEQ loc_0AB514
    COP [NudgePosition] ( #FF, #00 )

  loc_0AB514:
    LDA #$0011
    TRB $12

  code_0AB519:
    COP [SetHitCallback] ( &code_0AB72C )
    COP [BranchNearerAxis] ( &code_0AB523, &code_0AB626 )
}

code_0AB523 {
    COP [SetEntryHereAndYield]
    COP [BranchOnPlayerX] ( #$0000, &code_0AB52F, &code_0AB52F, &code_0AB5AA )
}

code_0AB52F {
    COP [StageSpriteLoop] ( #02, #0A )
    COP [AnimLoop]
    COP [SetEntryHereAndYield]
    COP [CallNear] ( &code_0AB7C2 )
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )

  loc_0AB540:
    COP [BranchIfSolidWest] ( &code_0AB54E )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [LoopEnd]
    BRA code_0AB519
}

code_0AB54E {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB55C )
}

code_list_0AB55C [
  &code_0AB560   ;00
  &code_0AB585   ;01
]

code_0AB560 {
    COP [BranchIfSolidWest] ( &code_0AB566 )
    BRA loc_0AB540
}

code_0AB566 {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0007
    BNE code_0AB579
    COP [BranchIfSolidEast] ( &code_0AB579 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AB579 {
    COP [BranchIfSolidSouth] ( &code_0AB585 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    BRA code_0AB560
}

code_0AB585 {
    COP [BranchIfSolidWest] ( &code_0AB58B )
    BRA loc_0AB540
}

code_0AB58B {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB59E
    COP [BranchIfSolidEast] ( &code_0AB59E )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AB59E {
    COP [BranchIfSolidNorth] ( &code_0AB560 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    BRA code_0AB560
}

code_0AB5AA {
    COP [StageSpriteLoop] ( #82, #0A )
    COP [AnimLoop]
    COP [SetEntryHereAndYield]
    COP [CallNear] ( &code_0AB7F9 )
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )

  loc_0AB5BB:
    COP [BranchIfSolidEast] ( &code_0AB5CA )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB519
}

code_0AB5CA {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB5D8 )
}

code_list_0AB5D8 [
  &code_0AB5DC   ;00
  &code_0AB601   ;01
]

code_0AB5DC {
    COP [BranchIfSolidEast] ( &code_0AB5E2 )
    BRA loc_0AB5BB
}

code_0AB5E2 {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0007
    BNE code_0AB5F5
    COP [BranchIfSolidWest] ( &code_0AB5F5 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AB5F5 {
    COP [BranchIfSolidSouth] ( &code_0AB601 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    BRA code_0AB5DC
}

code_0AB601 {
    COP [BranchIfSolidEast] ( &code_0AB607 )
    BRA loc_0AB5BB
}

code_0AB607 {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB61A
    COP [BranchIfSolidWest] ( &code_0AB61A )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AB61A {
    COP [BranchIfSolidNorth] ( &code_0AB5DC )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    BRA code_0AB5DC
}

code_0AB626 {
    COP [SetEntryHereAndYield]
    COP [BranchOnPlayerY] ( #$0000, &code_0AB632, &code_0AB632, &code_0AB6AE )
}

code_0AB632 {
    COP [StageSpriteLoop] ( #01, #0A )
    COP [AnimLoop]
    COP [SetEntryHereAndYield]
    COP [CallNear] ( &code_0AB78B )
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )

  code_0AB643:
    COP [BranchIfSolidNorth] ( &code_0AB652 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB519
}

code_0AB652 {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB660 )
}

code_list_0AB660 [
  &code_0AB664   ;00
  &code_0AB689   ;01
]

code_0AB664 {
    COP [BranchIfSolidNorth] ( &code_0AB66A )
    BRA code_0AB643
}

code_0AB66A {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0007
    BNE loc_0AB67D
    COP [BranchIfSolidSouth] ( &code_0AB5F5 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]

  loc_0AB67D:
    COP [BranchIfSolidWest] ( &code_0AB689 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    BRA code_0AB664
}

code_0AB689 {
    COP [BranchIfSolidNorth] ( &code_0AB68F )
    BRA code_0AB643
}

code_0AB68F {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB6A2
    COP [BranchIfSolidSouth] ( &code_0AB6A2 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
}

code_0AB6A2 {
    COP [BranchIfSolidEast] ( &code_0AB664 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    BRA code_0AB689
}

code_0AB6AE {
    COP [StageSpriteLoop] ( #00, #0A )
    COP [AnimLoop]
    COP [SetEntryHereAndYield]
    COP [CallNear] ( &code_0AB754 )
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0AB6CE )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB519
}

code_0AB6CE {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB6DC )
}

code_list_0AB6DC [
  &code_0AB6E0   ;00
  &code_0AB706   ;01
]

code_0AB6E0 {
    COP [BranchIfSolidSouth] ( &code_0AB6E7 )
    JMP $&code_0AB643
}

code_0AB6E7 {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0007
    BNE loc_0AB6FA
    COP [BranchIfSolidNorth] ( &code_0AB5F5 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]

  loc_0AB6FA:
    COP [BranchIfSolidWest] ( &code_0AB706 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    BRA code_0AB6E0
}

code_0AB706 {
    COP [BranchIfSolidSouth] ( &code_0AB70D )
    JMP $&code_0AB643
}

code_0AB70D {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    BIT #$0007
    BNE loc_0AB720
    COP [BranchIfSolidNorth] ( &code_0AB6A2 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]

  loc_0AB720:
    COP [BranchIfSolidEast] ( &code_0AB6E0 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    BRA code_0AB706
}

code_0AB72C {
    COP [SnapToGrid]
    COP [SetSavedPtr] ( &code_0AB519 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB744 )
}

code_list_0AB744 [
  &code_0AB795   ;00
  &code_0AB795   ;01
  &code_0AB803   ;02
  &code_0AB803   ;03
  &code_0AB75E   ;04
  &code_0AB75E   ;05
  &code_0AB7CC   ;06
  &code_0AB7CC   ;07
]

code_0AB754 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #00, #02, #04, &code_0AB75E )
    COP [RestoreSavedPtr]
}

code_0AB75E {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryHereAndYield]
    COP [StageSprAndHitbox] ( #06 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0AB830, #$FFF4, #$FFF0, #$0202 )
    COP [SpawnAfterOffsetFlags] ( @code_0AB830, #$000C, #$FFF0, #$0202 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB78B {
    COP [BranchIfPlayerInRelTiles] ( #FE, #FA, #02, #00, &code_0AB795 )
    COP [RestoreSavedPtr]
}

code_0AB795 {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryHereAndYield]
    COP [StageSprAndHitbox] ( #07 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0AB84F, #$FFF4, #$FFD0, #$0202 )
    COP [SpawnAfterOffsetFlags] ( @code_0AB84F, #$000C, #$FFD0, #$0202 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB7C2 {
    COP [BranchIfPlayerInRelTiles] ( #FC, #FE, #00, #02, &code_0AB7CC )
    COP [RestoreSavedPtr]
}

code_0AB7CC {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryHereAndYield]
    COP [StageSprAndHitbox] ( #08 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0AB86E, #$FFF3, #$FFE0, #$0202 )
    COP [SpawnAfterOffsetFlags] ( @code_0AB86E, #$FFF3, #$FFE8, #$0202 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB7F9 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #04, #02, &code_0AB803 )
    COP [RestoreSavedPtr]
}

code_0AB803 {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryHereAndYield]
    COP [StageSprAndHitbox] ( #88 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0AB88F, #$000D, #$FFE0, #$0202 )
    COP [SpawnAfterOffsetFlags] ( @code_0AB88F, #$000D, #$FFE8, #$0202 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB830 {
    COP [OrExtraFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #09, #03 )
    COP [AnimOnce]

  loc_0AB840:
    COP [StageSpriteMoveY] ( #09, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB840
    COP [Die]
}

code_0AB84F {
    COP [OrExtraFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #0A, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0A, #04 )
    COP [AnimOnce]

  loc_0AB85F:
    COP [StageSpriteMoveY] ( #0A, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB85F
    COP [Die]
}

code_0AB86E {
    COP [OrExtraFlags] ( #$0010 )
    COP [StageSpriteMoveXY] ( #0B, #02, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0B, #04, #13 )
    COP [AnimOnce]

  loc_0AB880:
    COP [StageSpriteMoveX] ( #0B, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB880
    COP [Die]
}

code_0AB88F {
    COP [OrExtraFlags] ( #$0010 )
    COP [StageSpriteMoveXY] ( #8B, #01, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #8B, #03, #13 )
    COP [AnimOnce]

  loc_0AB8A1:
    COP [StageSpriteMoveX] ( #8B, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB8A1
    COP [Die]
}

sg4D_red_cyber [
  actor-def < #00, #00, #00, {

  code_0AB8B3:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0AB9AC )
    COP [SetDeathCallback] ( @code_0AB96D )

  code_0AB8C1:
    COP [WaitWhileOffscreen] ( #0F )
    LDA #$FFFF
    STA $orbitAngle, X
    COP [CallNear] ( &code_0ABFC6 )
    COP [CallNear] ( &code_0ABFED )
    COP [CallNear] ( &code_0AC014 )
    COP [CallNear] ( &code_0AC03B )
    COP [CallNear] ( &code_0AC062 )
    COP [NudgePosition] ( #01, #00 )
    COP [CallNear] ( &code_0AC089 )
    COP [CallNear] ( &code_0AC0B0 )
    COP [CallNear] ( &code_0AC0D7 )
    COP [NudgePosition] ( #FF, #00 )
    LDA $10
    BIT #$4000
    BNE code_0AB8C1
    COP [StageSpriteLoop] ( #0C, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0ABFC6 )
    COP [StageSpriteLoop] ( #0D, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0ABFED )
    COP [StageSpriteLoop] ( #0E, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC014 )
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC03B )
    COP [StageSpriteLoop] ( #10, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC062 )
    COP [NudgePosition] ( #01, #00 )
    COP [StageSpriteLoop] ( #8F, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC089 )
    COP [StageSpriteLoop] ( #8E, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC0B0 )
    COP [StageSpriteLoop] ( #8D, #02 )
    COP [AnimLoop]
    JSR $&sub_0ADD1E
    COP [CallNear] ( &code_0AC0D7 )
    COP [NudgePosition] ( #FF, #00 )
    JMP $&code_0AB8C1
} >
]

code_0AB96D {
    LDA $orbitAngle, X
    BNE loc_0AB976
    JMP $&code_0AB9A5

  loc_0AB976:
    PHX 
    STX $0000
    TXA 
    TYX 
    TAY 
    LDX $0006, Y
    LDA $0000
    CMP $orbitDiameter, X
    BNE loc_0AB9A4
    LDA #$0000
    STA $orbitDiameter, X
    TXY 
    LDX $0006, Y
    LDA $0000
    CMP $orbitDiameter, X
    BNE loc_0AB9A4
    LDA #$0000
    STA $orbitDiameter, X

  loc_0AB9A4:
    PLX 
}

code_0AB9A5 {
    COP [SetEntryHereAndYield]
    COP [JumpFar] ( @StandardEnemyDefeatHandler )
}

code_0AB9AC {
    COP [SnapToGrid]
    LDA $14
    AND #$0007
    BEQ loc_0AB9B9
    COP [NudgePosition] ( #FF, #00 )

  loc_0AB9B9:
    LDA #$0011
    TRB $12

  code_0AB9BE:
    COP [SetHitCallback] ( &code_0ABAB1 )
    COP [BranchIfPlayerNear] ( #04, &code_0ABA4F )
    COP [RngByte]
    AND #$0003
    BNE loc_0AB9E8
    COP [BranchNearerAxis] ( &code_0AB9D4, &code_0AB9DE )
}

code_0AB9D4 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AB9FE, &code_0AB9FE, &code_0ABA13 )
}

code_0AB9DE {
    COP [BranchOnPlayerY] ( #$0000, &code_0ABA3B, &code_0ABA3B, &code_0ABA27 )

  loc_0AB9E8:
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB9F6 )
}

code_list_0AB9F6 [
  &code_0ABA01   ;00
  &code_0ABA15   ;01
  &code_0ABA29   ;02
  &code_0ABA3D   ;03
]

code_0AB9FE {
    COP [WaitByte] ( #00 )
}

code_0ABA01 {
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidWest] ( &code_0ABA13 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB9BE
}

code_0ABA13 {
    COP [SetEntryHereAndYield]
}

code_0ABA15 {
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidEast] ( &code_0ABA27 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB9BE
}

code_0ABA27 {
    COP [SetEntryHereAndYield]
}

code_0ABA29 {
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0ABA3B )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB9BE
}

code_0ABA3B {
    COP [SetEntryHereAndYield]
}

code_0ABA3D {
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AB9FE )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopEnd]
    JMP $&code_0AB9BE
}

code_0ABA4F {
    COP [BranchNearerAxis] ( &code_0ABA85, &code_0ABA57 )

  code_0ABA55:
    COP [SetEntryHereAndYield]
}

code_0ABA57 {
    COP [BranchOnPlayerX] ( #$0000, &code_0ABA72, &code_0ABA72, &code_0ABA61 )
}

code_0ABA61 {
    COP [BranchIfSolidWest] ( &code_0ABA83 )
    COP [StageSpriteMoveX] ( #85, #12 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ABCAE )
    JMP $&code_0AB9BE
}

code_0ABA72 {
    COP [BranchIfSolidEast] ( &code_0ABA83 )
    COP [StageSpriteMoveX] ( #05, #11 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ABC13 )
    JMP $&code_0AB9BE
}

code_0ABA83 {
    COP [SetEntryHereAndYield]
}

code_0ABA85 {
    COP [BranchOnPlayerY] ( #$0000, &code_0ABAA0, &code_0ABAA0, &code_0ABA8F )
}

code_0ABA8F {
    COP [BranchIfSolidNorth] ( &code_0ABA55 )
    COP [StageSpriteMoveY] ( #03, #12 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ABADB )
    JMP $&code_0AB9BE
}

code_0ABAA0 {
    COP [BranchIfSolidSouth] ( &code_0ABA55 )
    COP [StageSpriteMoveY] ( #04, #11 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0ABB78 )
    JMP $&code_0AB9BE
}

code_0ABAB1 {
    COP [SnapToGrid]
    COP [SetSavedPtr] ( &code_0AB9BE )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0ABAC9 )
}

code_list_0ABAC9 [
  &code_0ABBAC   ;00
  &code_0ABBAC   ;01
  &code_0ABCE2   ;02
  &code_0ABCE2   ;03
  &code_0ABB0F   ;04
  &code_0ABB0F   ;05
  &code_0ABC47   ;06
  &code_0ABC47   ;07
]

code_0ABAD9 {
    COP [RestoreSavedPtr]
}

code_0ABADB {
    COP [BranchIfPlayerInRelTiles] ( #FD, #00, #03, #06, &code_0ABB0F )
    COP [BranchOnPlayerX] ( #$0000, &code_0ABAED, &code_0ABAED, &code_0ABAFF )
}

code_0ABAED {
    COP [BranchIfSolidWest] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ABAD9 )
    COP [StageSpriteMoveX] ( #03, #02 )
    COP [AnimOnce]
    BRA code_0ABB0F
}

code_0ABAFF {
    COP [BranchIfSolidEast] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0ABAD9 )
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
}

code_0ABB0F {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #11 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [SetEntryHere]
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0ABD49, #$FFF4, #$FFF0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFEC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterOffsetFlags] ( @code_0ABD49, #$000C, #$FFF0, #$2200 )
    PHX 
    TYX 
    LDA #$000C
    STA $7F100C, X
    LDA #$FFEC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryHere]
    LDA $orbitAngle, X
    BEQ loc_0ABB72
    RTL 

  loc_0ABB72:
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABB78 {
    COP [BranchIfPlayerInRelTiles] ( #FD, #FB, #03, #00, &code_0ABBAC )
    COP [BranchOnPlayerX] ( #$0000, &code_0ABB8A, &code_0ABB8A, &code_0ABB9C )
}

code_0ABB8A {
    COP [BranchIfSolidWest] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ABAD9 )
    COP [StageSpriteMoveX] ( #04, #02 )
    COP [AnimOnce]
    BRA code_0ABBAC
}

code_0ABB9C {
    COP [BranchIfSolidEast] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0ABAD9 )
    COP [StageSpriteMoveX] ( #04, #01 )
    COP [AnimOnce]
}

code_0ABBAC {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #12 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0ABDBC, #$FFF4, #$FFD0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFDC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterOffsetFlags] ( @code_0ABDBC, #$000C, #$FFD0, #$2200 )
    PHX 
    TYX 
    LDA #$000C
    STA $7F100C, X
    LDA #$FFDC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryHere]
    LDA $orbitAngle, X
    BEQ loc_0ABC0D
    RTL 

  loc_0ABC0D:
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABC13 {
    COP [BranchIfPlayerInRelTiles] ( #FB, #FE, #00, #02, &code_0ABC47 )
    COP [BranchOnPlayerY] ( #$0000, &code_0ABC25, &code_0ABC25, &code_0ABC37 )
}

code_0ABC25 {
    COP [BranchIfSolidNorth] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ABAD9 )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    BRA code_0ABC47
}

code_0ABC37 {
    COP [BranchIfSolidSouth] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0ABAD9 )
    COP [StageSpriteMoveY] ( #05, #01 )
    COP [AnimOnce]
}

code_0ABC47 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #13 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0ABE2F, #$FFF3, #$FFE0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF3
    STA $7F100C, X
    LDA #$FFE0
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterOffsetFlags] ( @code_0ABE2F, #$FFF3, #$FFE8, #$2200 )
    PHX 
    TYX 
    LDA #$FFF3
    STA $7F100C, X
    LDA #$FFE8
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryHere]
    LDA $orbitAngle, X
    BEQ loc_0ABCA8
    RTL 

  loc_0ABCA8:
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABCAE {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #05, #02, &code_0ABCE2 )
    COP [BranchOnPlayerY] ( #$0000, &code_0ABCC0, &code_0ABCC0, &code_0ABCD2 )
}

code_0ABCC0 {
    COP [BranchIfSolidNorth] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ABAD9 )
    COP [StageSpriteMoveY] ( #85, #02 )
    COP [AnimOnce]
    BRA code_0ABCE2
}

code_0ABCD2 {
    COP [BranchIfSolidSouth] ( &code_0ABAD9 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0ABAD9 )
    COP [StageSpriteMoveY] ( #85, #01 )
    COP [AnimOnce]
}

code_0ABCE2 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #93 )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterOffsetFlags] ( @code_0ABEA8, #$000D, #$FFE0, #$2200 )
    PHX 
    TYX 
    LDA #$000D
    STA $7F100C, X
    LDA #$FFE0
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterOffsetFlags] ( @code_0ABEA8, #$000D, #$FFE8, #$2200 )
    PHX 
    TYX 
    LDA #$000D
    STA $7F100C, X
    LDA #$FFE8
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryHere]
    LDA $orbitAngle, X
    BEQ loc_0ABD43
    RTL 

  loc_0ABD43:
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABD49 {
    COP [SetSpritePriority] ( #30 )
    COP [OrExtraFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABD90 )
    COP [SetCustomCallback] ( &code_0ABD90 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #09, #03 )
    COP [AnimOnce]
    LDY $playerActor
    LDA $14
    SEC 
    SBC $0014, Y
    JSR $&code_0ABF73
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0050
    STA $moveYAlt, X
    COP [MoveToward] ( #09, #03 )
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
}

code_0ABD90 {
    COP [AndExtraFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABD98:
    LDA $orbitDiameter, X
    BEQ loc_0ABDAC
    JSR $&code_0ABF8F
    BCS loc_0ABDA6
    JMP $&code_0ABF1E

  loc_0ABDA6:
    COP [MoveToward] ( #14, #02 )
    BRA loc_0ABD98

  loc_0ABDAC:
    COP [StageSpriteLoopMoveY] ( #09, #03, #03 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABDAC
    COP [Die]
}

code_0ABDBC {
    COP [SetSpritePriority] ( #30 )
    COP [OrExtraFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABE03 )
    COP [SetCustomCallback] ( &code_0ABE03 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #0A, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0A, #04 )
    COP [AnimOnce]
    LDY $playerActor
    LDA $14
    SEC 
    SBC $0014, Y
    JSR $&code_0ABF73
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    SEC 
    SBC #$0050
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #03 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
}

code_0ABE03 {
    COP [AndExtraFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABE0B:
    LDA $orbitDiameter, X
    BEQ loc_0ABE1F
    JSR $&code_0ABF8F
    BCS loc_0ABE19
    JMP $&code_0ABF1E

  loc_0ABE19:
    COP [MoveToward] ( #15, #02 )
    BRA loc_0ABE0B

  loc_0ABE1F:
    COP [StageSpriteLoopMoveY] ( #0A, #03, #04 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABE1F
    COP [Die]
}

code_0ABE2F {
    COP [SetSpritePriority] ( #30 )
    COP [OrExtraFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABE7C )
    COP [SetCustomCallback] ( &code_0ABE7C )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveXY] ( #0B, #02, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0B, #04, #13 )
    COP [AnimOnce]
    LDY $playerActor
    LDA $16
    SEC 
    SBC $0030
    SEC 
    SBC $0016, Y
    JSR $&code_0ABF73
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA $14
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    COP [MoveToward] ( #0B, #03 )
    COP [StageSpriteMoveX] ( #0B, #01 )
    COP [AnimOnce]
}

code_0ABE7C {
    COP [AndExtraFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABE84:
    LDA $orbitDiameter, X
    BEQ loc_0ABE98
    JSR $&code_0ABF8F
    BCS loc_0ABE92
    JMP $&code_0ABF1E

  loc_0ABE92:
    COP [MoveToward] ( #16, #02 )
    BRA loc_0ABE84

  loc_0ABE98:
    COP [StageSpriteLoopMoveX] ( #0B, #03, #04 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABE98
    COP [Die]
}

code_0ABEA8 {
    COP [SetSpritePriority] ( #30 )
    COP [OrExtraFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABEF5 )
    COP [SetCustomCallback] ( &code_0ABEF5 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveXY] ( #8B, #01, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #8B, #03, #13 )
    COP [AnimOnce]
    LDY $playerActor
    LDA $16
    SEC 
    SBC $0030
    SEC 
    SBC $0016, Y
    JSR $&code_0ABF73
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA $14
    CLC 
    ADC #$0050
    STA $moveXAlt, X
    COP [MoveToward] ( #8B, #03 )
    COP [StageSpriteMoveX] ( #8B, #01 )
    COP [AnimOnce]
}

code_0ABEF5 {
    COP [AndExtraFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABEFD:
    LDA $orbitDiameter, X
    BEQ loc_0ABF0E
    JSR $&code_0ABF8F
    BCC code_0ABF1E
    COP [MoveToward] ( #96, #02 )
    BRA loc_0ABEFD

  loc_0ABF0E:
    COP [StageSpriteLoopMoveX] ( #8B, #03, #03 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABF0E
    COP [Die]
}

code_0ABF1E {
    LDA $orbitDiameter, X
    BEQ loc_0ABF70
    PHX 
    TAX 
    LDA $orbitAngle, X
    LSR 
    STA $orbitAngle, X
    TXY 
    PLX 
    LDA $0014, Y
    SEC 
    SBC $14
    STA $7F100C, X
    LDA $0016, Y
    SEC 
    SBC $16
    STA $7F100E, X

  loc_0ABF45:
    LDA $0014, Y
    SEC 
    SBC $7F100C, X
    STA $14
    LDA $0016, Y
    SEC 
    SBC $7F100E, X
    STA $16
    COP [SetEntryHereAndYield]
    PHX 
    LDA $orbitDiameter, X
    BEQ loc_0ABF70
    TAX 
    LDA $orbitAngle, X
    TXY 
    PLX 
    CMP #$0000
    BNE loc_0ABF45
    COP [Die]

  loc_0ABF70:
    PLX 
    COP [Die]
}

code_0ABF73 {
    BMI loc_0ABF82
    CMP #$0010
    BCC loc_0ABF7D
    LDA #$0008

  loc_0ABF7D:
    EOR #$FFFF
    INC 
    RTS 

  loc_0ABF82:
    EOR #$FFFF
    INC 
    CMP #$0010
    BCC loc_0ABF8E
    LDA #$0008

  loc_0ABF8E:
    RTS 
}

code_0ABF8F {
    LDA $orbitDiameter, X
    TAY 
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    CMP $14
    BNE loc_0ABFB8
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    CMP $16
    SEC 
    BEQ loc_0ABFB6
    RTS 

  loc_0ABFB6:
    CLC 
    RTS 

  loc_0ABFB8:
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    SEC 
    RTS 
}

code_0ABFC6 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0004
    BNE loc_0ABFEB
    COP [StageSpriteLoop] ( #0C, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns, #$0000, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #0C, #02 )
    COP [AnimLoop]

  loc_0ABFEB:
    COP [RestoreSavedPtr]
}

code_0ABFED {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0005
    BNE loc_0AC012
    COP [StageSpriteLoop] ( #0D, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADA69, #$FFFA, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #0D, #02 )
    COP [AnimLoop]

  loc_0AC012:
    COP [RestoreSavedPtr]
}

code_0AC014 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0006
    BNE loc_0AC039
    COP [StageSpriteLoop] ( #0E, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADAA0, #$FFF5, #$FFDA, #$2202 )
    COP [StageSpriteLoop] ( #0E, #02 )
    COP [AnimLoop]

  loc_0AC039:
    COP [RestoreSavedPtr]
}

code_0AC03B {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0007
    BNE loc_0AC060
    COP [StageSpriteLoop] ( #0F, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADAD1, #$FFF9, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]

  loc_0AC060:
    COP [RestoreSavedPtr]
}

code_0AC062 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0000
    BNE loc_0AC087
    COP [StageSpriteLoop] ( #10, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADB04, #$0000, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #10, #02 )
    COP [AnimLoop]

  loc_0AC087:
    COP [RestoreSavedPtr]
}

code_0AC089 {
    COP [StageSpriteFrame] ( #8F )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0001
    BNE loc_0AC0AE
    COP [StageSpriteLoop] ( #8F, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADAE7, #$0007, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #8F, #02 )
    COP [AnimLoop]

  loc_0AC0AE:
    COP [RestoreSavedPtr]
}

code_0AC0B0 {
    COP [StageSpriteFrame] ( #8E )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0002
    BNE loc_0AC0D5
    COP [StageSpriteLoop] ( #8E, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADAB5, #$000B, #$FFDA, #$2202 )
    COP [StageSpriteLoop] ( #8E, #02 )
    COP [AnimLoop]

  loc_0AC0D5:
    COP [RestoreSavedPtr]
}

code_0AC0D7 {
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0003
    BNE loc_0AC0FC
    COP [StageSpriteLoop] ( #8D, #08 )
    COP [AnimLoop]
    COP [SpawnAfterOffsetFlags] ( @sg_bird_flight_patterns.code_0ADA81, #$0006, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #8D, #02 )
    COP [AnimLoop]

  loc_0AC0FC:
    COP [RestoreSavedPtr]
}
---------------------------------------------

sub_0ADD1E {
    COP [DirToPlayerFrom] ( #00, #D0 )
    STA $orbitAngle, X
    RTS 
}