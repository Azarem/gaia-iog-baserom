!moveXAlt                       7F0018
!moveYAlt                       7F001A
!free101C                       7F101C

---------------------------------------------

mu5F_cyclops [
  actor-def < #00, #10, #01, {

  code_0ADDA1:
    LDA #$0001
    STA $free101C, X
    COP [OrActorFlags] ( #$0008 )
    COP [BranchIfSolid] ( &code_0ADDFF )
    COP [AddPosition] ( #F8, #00 )
    COP [SolidHighHere]

  code_0ADDB6:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetHitCallback] ( &code_0AE101 )
    COP [WaitByte] ( #07 )
    COP [LoopInit] ( #78 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADDCD )
    COP [BranchIfPlayerNear] ( #06, &code_0ADE50 )
} >
]

code_0ADDCD {
    COP [LoopNext]
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0110
    TRB $10
    COP [ClearLowHere]

  code_0ADDE5:
    COP [SetSavedPtr] ( &code_0ADE6C )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0ADDF7 )
}

code_list_0ADDF7 [
  &code_0ADF29   ;00
  &code_0ADF68   ;01
  &code_0ADFBA   ;02
  &code_0AE008   ;03
]

code_0ADDFF {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

mu5F_cyclops2 [
  actor-def < #00, #00, #01, {

  code_0ADE0A:
    LDA #$0001
    STA $free101C, X
    COP [BranchIfSolid] ( &code_0ADDFF )
    COP [OrActorFlags] ( #$0008 )
    LDA #$0010
    TSB $12
    COP [AddPosition] ( #F8, #00 )
    COP [SolidHighHere]
    COP [SetHitCallback] ( &code_0ADE2C )
    COP [WaitWhileOffscreen] ( #08 )
    RTL 
} >
]

code_0ADE2C {
    LDA #$0010
    TSB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    BRA code_0ADE50

  code_0ADE3A:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    LDA #$0110
    TSB $10
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_0ADDB6 )
}

code_0ADE50 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [WaitByte] ( #27 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0110
    TRB $10
    COP [ClearLowHere]

  loc_0ADE69:
    COP [WaitWhileOffscreen] ( #08 )
}

code_0ADE6C {
    LDA $10
    BIT #$4000
    BNE loc_0ADE69
    COP [BranchIfPlayerNear] ( #02, &code_0ADE3A )
    COP [BranchNearerAxis] ( &code_0ADE7E, &code_0ADE88 )
}

code_0ADE7E {
    COP [BranchOnPlayerX] ( #$0000, &code_0ADE92, &code_0ADEA5, &code_0ADEA5 )
}

code_0ADE88 {
    COP [BranchOnPlayerY] ( #$0000, &code_0ADECB, &code_0ADECB, &code_0ADEB8 )
}

code_0ADE92 {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]

  loc_0ADE97:
    COP [BranchIfPlayerNear] ( #05, &code_0ADEDE )
    COP [CallScriptDeferred] ( &code_0ADF29 )
    ASL 
    BCS code_0ADE6C
    BRA loc_0ADE97
}

code_0ADEA5 {
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]

  loc_0ADEAA:
    COP [BranchIfPlayerNear] ( #05, &code_0ADEEB )
    COP [CallScriptDeferred] ( &code_0ADF68 )
    ASL 
    BCS code_0ADE6C
    BRA loc_0ADEAA
}

code_0ADEB8 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]

  loc_0ADEBD:
    COP [BranchIfPlayerNear] ( #05, &code_0ADEF9 )
    COP [CallScriptDeferred] ( &code_0ADFBA )
    ASL 
    BCS code_0ADE6C
    BRA loc_0ADEBD
}

code_0ADECB {
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0ADF07 )
    COP [CallScriptDeferred] ( &code_0AE008 )
    ASL 
    BCS code_0ADE6C
    BRA code_0ADECB
}

code_0ADEDE {
    JSR $&code_0ADF15
    COP [CallScript] ( &code_0AE0A7 )
    COP [CallScriptDeferred] ( &code_0ADF29 )
    BRA code_0ADE6C
}

code_0ADEEB {
    JSR $&code_0ADF15
    COP [CallScript] ( &code_0AE0D4 )
    COP [CallScriptDeferred] ( &code_0ADF68 )
    JMP $&code_0ADE6C
}

code_0ADEF9 {
    JSR $&code_0ADF15
    COP [CallScript] ( &code_0AE047 )
    COP [CallScriptDeferred] ( &code_0ADFBA )
    JMP $&code_0ADE6C
}

code_0ADF07 {
    JSR $&code_0ADF15
    COP [CallScript] ( &code_0AE074 )
    COP [CallScriptDeferred] ( &code_0AE008 )
    JMP $&code_0ADE6C
}

code_0ADF15 {
    COP [RngByte]
    AND #$0003
    BNE loc_0ADF26
    LDA $0B02
    CLC 
    ADC #$0004
    STA $24
    RTS 

  loc_0ADF26:
    STZ $24
    RTS 
}

code_0ADF29 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ADF66 )
    COP [BranchIfSolidOffset] ( #FE, #FF, &code_0ADF66 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADF5E )
    COP [StageSpriteMoveX] ( #09, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ADF66 )
    COP [BranchIfSolidOffset] ( #FE, #FF, &code_0ADF66 )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0000, &code_0ADF5C, &code_0ADF5C, &code_0ADF64 )
}

code_0ADF5C {
    COP [RestoreSavedPtr]
}

code_0ADF5E {
    COP [StageSpriteMoveX] ( #09, #02 )
    COP [AnimOnce]
}

code_0ADF64 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADF66 {
    BRA code_0ADFA5
}

code_0ADF68 {
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ADFA5 )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ADFA5 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADF9D )
    COP [StageSpriteMoveX] ( #89, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ADFA5 )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ADFA5 )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0000, &code_0ADFA3, &code_0ADF9B, &code_0ADF9B )
}

code_0ADF9B {
    COP [RestoreSavedPtr]
}

code_0ADF9D {
    COP [StageSpriteMoveX] ( #89, #01 )
    COP [AnimOnce]
}

code_0ADFA3 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADFA5 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0ADFB8
    COP [BranchOnPlayerY] ( #$0000, &code_0AE008, &code_0AE008, &code_0ADFBA )

  loc_0ADFB8:
    COP [RestoreSavedPtr]
}

code_0ADFBA {
    COP [BranchIfSolidSouth] ( &code_0ADFF3 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ADFF3 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADFEB )
    COP [StageSpriteMoveY] ( #07, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0ADFF3 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ADFF3 )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    COP [BranchOnPlayerY] ( #$0000, &code_0ADFF1, &code_0ADFE9, &code_0ADFE9 )
}

code_0ADFE9 {
    COP [RestoreSavedPtr]
}

code_0ADFEB {
    COP [StageSpriteMoveY] ( #07, #01 )
    COP [AnimOnce]
}

code_0ADFF1 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADFF3 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0AE006
    COP [BranchOnPlayerX] ( #$0000, &code_0ADF29, &code_0ADF29, &code_0ADF68 )

  loc_0AE006:
    COP [RestoreSavedPtr]
}

code_0AE008 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AE045 )
    COP [BranchIfSolidOffset] ( #FF, #FE, &code_0AE045 )
    COP [BranchIfPlayerNear] ( #03, &code_0AE03D )
    COP [StageSpriteMoveY] ( #08, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AE045 )
    COP [BranchIfSolidOffset] ( #FF, #FE, &code_0AE045 )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    COP [BranchOnPlayerY] ( #$0000, &code_0AE03B, &code_0AE03B, &code_0AE043 )
}

code_0AE03B {
    COP [RestoreSavedPtr]
}

code_0AE03D {
    COP [StageSpriteMoveY] ( #08, #02 )
    COP [AnimOnce]
}

code_0AE043 {
    COP [RestoreSavedPtrFFFF]
}

code_0AE045 {
    BRA code_0ADFF3
}

code_0AE047 {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE1DB, #$0000, #$FFF4, #$0202 )
    COP [SetHitCallback] ( &code_0ADE3A )

  loc_0AE05B:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0AE0A1
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE1CF, #$0000, #$FFF4, #$0202 )
    BRA loc_0AE05B
}

code_0AE074 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE1D6, #$0000, #$FFCC, #$0200 )
    COP [SetHitCallback] ( &code_0ADE3A )

  loc_0AE088:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0AE0A1
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE1CA, #$0000, #$FFCC, #$0200 )
    BRA loc_0AE088

  loc_0AE0A1:
    COP [SetHitCallback] ( #$0000 )
    COP [RestoreSavedPtr]
}

code_0AE0A7 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE186, #$FFD8, #$FFE8, #$0200 )
    COP [SetHitCallback] ( &code_0ADE3A )

  loc_0AE0BB:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0AE0A1
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE17A, #$FFD8, #$FFE8, #$0200 )
    BRA loc_0AE0BB
}

code_0AE0D4 {
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE181, #$0028, #$FFE8, #$0200 )
    COP [SetHitCallback] ( &code_0ADE3A )

  loc_0AE0E8:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0AE0A1
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE175, #$0028, #$FFE8, #$0200 )
    BRA loc_0AE0E8
}

code_0AE101 {
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0110
    TRB $10
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0AE22A, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE230, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE236, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE23C, #$0000, #$0000, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0AE242, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE248, #$0000, #$0000, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0AE24E, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE254, #$0000, #$0000, #$0200 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    JMP $&code_0ADDE5
}

code_0AE175 {
    LDA #$4000
    TSB $12
}

code_0AE17A {
    COP [RngByte]
    AND #$0003
    BRA loc_0AE189
}

code_0AE181 {
    LDA #$4000
    TSB $12
}

code_0AE186 {
    LDA #$0000

  loc_0AE189:
    PHA 
    COP [StageForceMoveXY] ( #04, #01 )
    LDA #$0080
    TSB $12
    COP [OrActorFlags] ( #$0010 )
    COP [PlaySoundCh1] ( #1E )
    PLA 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE1A4 )
}

code_list_0AE1A4 [
  &code_0AE1AC   ;00
  &code_0AE1B5   ;01
  &code_0AE1BA   ;02
  &code_0AE1AC   ;03
]

code_0AE1AC {
    LDA #$0000
    STA $moveYAlt, X
    STZ $2E
}

code_0AE1B5 {
    LDA #$2000
    TSB $12
}

code_0AE1BA {
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [ReloadForceMove]
    LDA $10
    BIT #$4000
    BEQ code_0AE1BA
    COP [Die]
}

code_0AE1CA {
    LDA #$2000
    TSB $12
}

code_0AE1CF {
    COP [RngByte]
    AND #$0003
    BRA loc_0AE1DE
}

code_0AE1D6 {
    LDA #$2000
    TSB $12
}

code_0AE1DB {
    LDA #$0000

  loc_0AE1DE:
    PHA 
    COP [StageForceMoveXY] ( #02, #03 )
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    PLA 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE1F9 )
}

code_list_0AE1F9 [
  &code_0AE201   ;00
  &code_0AE20F   ;01
  &code_0AE20A   ;02
  &code_0AE201   ;03
]

code_0AE201 {
    LDA #$0000
    STA $moveXAlt, X
    STZ $2C
}

code_0AE20A {
    LDA #$4000
    TSB $12
}

code_0AE20F {
    COP [StageSpriteLoop] ( #1F, #03 )
    COP [AnimLoop]
    LDA #$0002
    TRB $10

  loc_0AE21A:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AE21A
    COP [Die]
}

code_0AE22A {
    COP [StageForceMoveXY] ( #04, #00 )
    BRA loc_0AE258
}

code_0AE230 {
    COP [StageForceMoveXY] ( #03, #00 )
    BRA loc_0AE258
}

code_0AE236 {
    COP [StageForceMoveXY] ( #00, #03 )
    BRA loc_0AE258
}

code_0AE23C {
    COP [StageForceMoveXY] ( #00, #04 )
    BRA loc_0AE258
}

code_0AE242 {
    COP [StageForceMoveXY] ( #02, #01 )
    BRA loc_0AE258
}

code_0AE248 {
    COP [StageForceMoveXY] ( #02, #02 )
    BRA loc_0AE258
}

code_0AE24E {
    COP [StageForceMoveXY] ( #01, #01 )
    BRA loc_0AE258
}

code_0AE254 {
    COP [StageForceMoveXY] ( #01, #02 )

  loc_0AE258:
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]
    LDA #$0002
    TRB $10
    BRA loc_0AE21A
}