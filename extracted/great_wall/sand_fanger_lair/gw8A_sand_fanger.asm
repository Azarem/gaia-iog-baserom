; Sand Fanger boss fight — Great Wall area boss (~1,610 lines).
; 
; The largest boss script in the game. Multi-phase sand worm
; boss that burrows underground and surfaces to attack.
; Uses position prediction to emerge near the player. Multiple
; attack types: sand spray, lunging bite, tail sweep. Phase
; transitions increase speed and attack variety. The arena
; has shifting sand terrain. Defeat triggers Mystic Statue
; reward: "You've defeated the Sand Fanger! Look! A Mystic Statue!"
---------------------------------------------

?INCLUDE 'ApplyOrbitalOffsetXY'
?INCLUDE 'cop_handlers_flags'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'EnemyDefeatDispatch'
?INCLUDE 'hardware_math'
?INCLUDE 'math_lookup_tables'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'sE6_gaia'
?INCLUDE 'SetPlayerGameOverFlag'
?INCLUDE 'smooth_follow_child'
?INCLUDE 'spriteset_enemies'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraBoundsY                  06DC
!playerXPos                     09A2
!playerXTile                    09A6
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!activeActorCount               0DBC
!animScratch                    7F0000
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026
!extendedFlags                  7F002A

---------------------------------------------

btF5_neo_fanger [
  actor-def < #00, #00, #01, {

  code_0B8003:
    LDA #$8019
    TSB $12
    LDA $cameraBoundsY
    CLC 
    ADC #$0020
    STA $cameraBoundsY
    LDY $playerActor
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [SetDeathCallback] ( @code_0B8582 )
    COP [SpawnLastRel] ( @code_0B80F0, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0B8037
    JMP $&code_0B81E3

  loc_0B8037:
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_WillToShadow
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_WillToShadow
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0B805D
    RTL 

  loc_0B805D:
    JMP $&code_0B81E3
} >
]

code_0B8060 {
    COP [SetEntryContinue]
    LDA $playerFlags
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

dialogstring_0B80B5 `[DEF][TPL:0]You've defeated the [N]Sand Fanger!  [N]Look! A Mystic Statue![PAL:0][END]`

code_0B80F0 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0B80F8
    RTL 

  loc_0B80F8:
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_ShadowToWill
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_ShadowToWill
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0B811E
    RTL 

  loc_0B811E:
    COP [SetFlagWord] ( #$0178 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$02F8, #$00A0, #03, #$1800 )
    COP [Die]

  code_0B813A:
    LDY $playerActor
    LDA $0016, Y
    CMP #$01C7
    BCS loc_0B8152
    LDA $000E, Y
    AND #$CFFF
    ORA #$2000
    STA $000E, Y
    RTL 

  loc_0B8152:
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    RTL 
}

gw8A_sand_fanger [
  actor-def < #00, #00, #01, {

  code_0B815F:
    COP [SpawnLastRel] ( @code_0B813A, #00, #00, #$2000 )
    LDA #$0003
    JSL $@cop_handlers_flags.TestWramFlag_Offset100
    BCC loc_0B8179
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0B8179:
    LDA #$8019
    TSB $12
    COP [SpawnLastRel] ( @code_0B8060, #00, #00, #$2000 )
    COP [SetDeathCallback] ( @code_0B8582 )
    COP [SolidHighAbs] ( #0F, #2A )
    COP [SolidHighAbs] ( #10, #2A )
    COP [SolidHighAbs] ( #0F, #2B )
    COP [SolidHighAbs] ( #10, #2B )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0D, #19, #12, #1B, &code_0B81A7 )
    RTL 
} >
]

code_0B81A7 {
    LDY $playerActor
    LDA $000E, Y
    ORA #$3000
    STA $000E, Y
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0F, #2C, #11, #2E, &code_0B81BE )
    RTL 
}

code_0B81BE {
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

code_0B81E3 {
    COP [SpawnMarkedBefore] ( @code_0B8A09, #$2000 )
    COP [SpawnAfterFlags] ( @code_0B861C, #$2200 )
    LDA #$0009

  loc_0B81F4:
    PHA 
    COP [SpawnAfterFlags] ( @code_0B86EE, #$2200 )
    PLA 
    DEC 
    BPL loc_0B81F4

  code_0B8200:
    COP [WaitByte] ( #4F )
    LDA #$0080
    TRB $10
    LDA $playerXTile
    LSR 
    LSR 
    LSR 
    BCS loc_0B8226
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B821E )
}

code_list_0B821E [
  &code_0B823C   ;00
  &code_0B823C   ;01
  &code_0B825D   ;02
  &code_0B82FC   ;03
]

loc_0B8226 {
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B8234 )
}

code_list_0B8234 [
  &code_0B825D   ;00
  &code_0B825D   ;01
  &code_0B823C   ;02
  &code_0B82FC   ;03
]

code_0B823C {
    JSR $&code_0B8BCB
    JSR $&code_0B8BBE
    COP [WaitByte] ( #3B )
    LDA #$02C8
    STA $16
    COP [CallScript] ( &code_0B8313 )
    JSR $&code_0B8BCB
    LDA #$0048
    STA $16
    COP [CallScript] ( &code_0B8348 )
    JMP $&code_0B8200
}

code_0B825D {
    LDA $playerXPos
    CMP #$0180
    BCC loc_0B82B3
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC #$0278
    STA $14
    STA $24
    JSR $&code_0B8BBE
    LDA #$0000
    STA $7F100C, X
    COP [WaitByte] ( #13 )

  loc_0B8283:
    LDA #$02E0
    STA $16
    LDA #$0003
    STA $26
    JSR $&code_0B8B86
    JSR $&code_0B8B32
    COP [CallScript] ( &code_0B837D )
    LDA $moveXAlt, X
    SEC 
    SBC #$0080
    STA $14
    STA $24
    BPL loc_0B82A8
    JMP $&code_0B8200

  loc_0B82A8:
    CMP #$00E8
    BCS loc_0B8283
    COP [WaitByte] ( #31 )
    JMP $&code_0B8200

  loc_0B82B3:
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC #$0088
    STA $14
    STA $24
    JSR $&code_0B8BBE
    LDA #$0000
    STA $7F100C, X
    COP [WaitByte] ( #13 )

  loc_0B82D1:
    LDA #$02E0
    STA $16
    LDA #$0004
    STA $26
    JSR $&code_0B8B86
    JSR $&code_0B8B5C
    COP [CallScript] ( &code_0B8422 )
    LDA $moveXAlt, X
    CLC 
    ADC #$0080
    STA $14
    STA $24
    CMP #$0218
    BCC loc_0B82D1
    COP [WaitByte] ( #31 )
    JMP $&code_0B8200
}

code_0B82FC {
    LDA $activeActorCount
    CMP #$003C
    BCC loc_0B8307
    JMP $&code_0B8200

  loc_0B8307:
    LDA #$0005
    STA $26
    COP [CallScript] ( &code_0B84C7 )
    JMP $&code_0B8200
}

code_0B8313 {
    LDA #$0001
    STA $26
    JSR $&code_0B8AE1
    COP [StageSprAndHitbox] ( #00 )
    COP [StageForceMoveY] ( #08 )
    COP [SetEntryContinue]
    JSR $&sub_0B9CE8
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
    BCC loc_0B8344
    RTL 

  loc_0B8344:
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0B8348 {
    LDA #$0002
    STA $26
    JSR $&code_0B8AE1
    COP [StageSprAndHitbox] ( #04 )
    COP [StageForceMoveY] ( #0B )
    COP [SetEntryContinue]
    JSR $&sub_0B9CE8
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
    BCS loc_0B8379
    RTL 

  loc_0B8379:
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0B837D {
    LDA $chatPtr, X
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    STZ $08
    STZ $2E
    STZ $2C

  code_0B838C:
    COP [SetEntryExit]
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@ApplyOrbitalOffsetXY
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
    BEQ loc_0B83E1
    STA $animScratch, X
    PHX 
    TAX 
    STZ $28
    SEP #$20
    LDA #$40
    TRB $0F
    LDA $@byte_0B841A, X
    PLX 
    CLC 
    ADC $chatPtr, X
    STA $28
    BPL loc_0B83DA
    AND #$7F
    STA $28
    LDA #$40
    TSB $0F
    BRA loc_0B83DC

  loc_0B83DA:
    STA $28

  loc_0B83DC:
    REP #$20
    COP [StageSprAndHitbox] ( #FF )

  loc_0B83E1:
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    STA $7F0011, X
    SEC 
    SBC $animScratch+2, X
    BIT #$80
    BEQ loc_0B8411
    LDA $animScratch+2, X
    CLC 
    ADC #$80
    STA $animScratch+2, X
    LDA $animScratch2, X
    DEC 
    BMI loc_0B8416
    STA $animScratch2, X

  loc_0B8411:
    REP #$20
    JMP $&code_0B838C

  loc_0B8416:
    REP #$20
    COP [RestoreSavedPtr]
}

byte_0B841A [
  #82   ;00
  #81   ;01
  #00   ;02
  #01   ;03
  #02   ;04
  #03   ;05
  #04   ;06
  #83   ;07
]

code_0B8422 {
    LDA $chatPtr, X
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    STZ $08
    STZ $2E
    STZ $2C

  code_0B8431:
    COP [SetEntryExit]
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@ApplyOrbitalOffsetXY
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
    BEQ loc_0B8486
    STA $animScratch, X
    PHX 
    TAX 
    STZ $28
    SEP #$20
    LDA #$40
    TRB $0F
    LDA $@byte_0B84BF, X
    PLX 
    CLC 
    ADC $chatPtr, X
    STA $28
    BPL loc_0B847F
    AND #$7F
    STA $28
    LDA #$40
    TSB $0F
    BRA loc_0B8481

  loc_0B847F:
    STA $28

  loc_0B8481:
    REP #$20
    COP [StageSprAndHitbox] ( #FF )

  loc_0B8486:
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$FE
    STA $orbitAngle, X
    STA $7F0011, X
    CLC 
    ADC $animScratch+2, X
    BIT #$80
    BEQ loc_0B84B6
    LDA $animScratch+2, X
    SEC 
    SBC #$80
    STA $animScratch+2, X
    LDA $animScratch2, X
    DEC 
    BMI loc_0B84BB
    STA $animScratch2, X

  loc_0B84B6:
    REP #$20
    JMP $&code_0B8431

  loc_0B84BB:
    REP #$20
    COP [RestoreSavedPtr]
}

byte_0B84BF [
  #02   ;00
  #03   ;01
  #04   ;02
  #83   ;03
  #82   ;04
  #81   ;05
  #00   ;06
  #01   ;07
]

code_0B84C7 {
    COP [RngByte]
    SEC 
    SBC #$007F
    CLC 
    ADC $playerXPos
    BPL loc_0B84D7

  loc_0B84D3:
    CLC 
    ADC #$007F

  loc_0B84D7:
    CMP #$0030
    BCC loc_0B84D3
    CMP #$02D0
    BCC loc_0B84E5
    SEC 
    SBC #$007F

  loc_0B84E5:
    STA $14
    JSR $&code_0B8BBE
    COP [WaitByte] ( #3B )
    LDA #$02CF
    STA $16
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    PEA $&code_0B8531-1
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B8508 )
}

code_list_0B8508 [
  &code_0B8518   ;00
  &code_0B851D   ;01
  &code_0B8522   ;02
  &code_0B8527   ;03
  &code_0B852C   ;04
  &code_0B8518   ;05
  &code_0B8518   ;06
  &code_0B8518   ;07
]

code_0B8518 {
    JSR $&code_0B856E
    BRA code_0B8578
}

code_0B851D {
    JSR $&code_0B856E
    BRA loc_0B8546
}

code_0B8522 {
    JSR $&code_0B8578
    BRA loc_0B8550
}

code_0B8527 {
    JSR $&code_0B856E
    BRA loc_0B8564
}

code_0B852C {
    JSR $&code_0B8578
    BRA loc_0B855A
}

code_0B8531 {
    COP [StageSpriteLoop] ( #19, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [StageForceMoveY] ( #13 )
    COP [WaitByte] ( #09 )
    STZ $2E
    COP [RestoreSavedPtr]

  loc_0B8546:
    COP [SpawnLastRel] ( @code_0B87E4, #00, #F8, #$0301 )
    RTS 

  loc_0B8550:
    COP [SpawnLastRel] ( @code_0B87DA, #00, #F8, #$0301 )
    RTS 

  loc_0B855A:
    COP [SpawnLastRel] ( @code_0B8891, #00, #F8, #$0301 )
    RTS 

  loc_0B8564:
    COP [SpawnLastRel] ( @code_0B8896, #00, #F8, #$0301 )
    RTS 
}

code_0B856E {
    COP [SpawnLastRel] ( @code_0B88CD, #00, #F8, #$0111 )
    RTS 
}

code_0B8578 {
    COP [SpawnLastRel] ( @code_0B88DB, #00, #F8, #$0111 )
    RTS 
}

code_0B8582 {
    LDA $playerFlags
    BIT #$0200
    BEQ loc_0B858D
    COP [SetEntryContinue]
    RTL 

  loc_0B858D:
    LDA #$0020
    TSB $playerFlags
    COP [SpawnLastRel] ( @SetPlayerGameOverFlag, #00, #00, #$2000 )
    LDA #$000A
    STA $0000
    LDA #$0014
    STA $0002
    LDY $06

  loc_0B85AA:
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0B85BA
    LDA #$&loc_0B8618
    STA $0000, Y
    BRA loc_0B85CD

  loc_0B85BA:
    LDA #$&loc_0B860C
    STA $0000, Y
    LDA $0002
    STA $0008, Y
    CLC 
    ADC #$0008
    STA $0002

  loc_0B85CD:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0B85AA
    PHX 
    LDX $0056

  loc_0B85DA:
    LDA $extendedFlags, X
    BIT #$0080
    BEQ loc_0B85FB
    LDA $0010, X
    BIT #$0040
    BNE loc_0B85FB
    BIT #$2000
    BEQ loc_0B85F5
    LDA #$&loc_0B8618
    BRA loc_0B85F8

  loc_0B85F5:
    LDA #$&loc_0B860C

  loc_0B85F8:
    STA $0000, X

  loc_0B85FB:
    LDA $0006, X
    BEQ loc_0B8603
    TAX 
    BRA loc_0B85DA

  loc_0B8603:
    PLX 
    COP [WaitByte] ( #10 )
    COP [JumpScript] ( @EnemyDefeatDispatch )

  loc_0B860C:
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #10, #$0302 )

  loc_0B8618:
    COP [Die]

  code_0B861A:
    COP [SetEntryContinue]
}

code_0B861C {
    LDY $24
    LDA $0026, Y
    BNE code_0B8624
    RTL 

  code_0B8624:
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0026, Y
    DEC 
    STA $0000
    LDA #$0000
    STA $0026, Y
    COP [SwitchCase] ( #$0000, &code_list_0B863E )
}

code_list_0B863E [
  &code_0B8648   ;00
  &code_0B8672   ;01
  &code_0B869C   ;02
  &code_0B86C3   ;03
  &code_0B861A   ;04
]

code_0B8648 {
    COP [StageSprAndHitbox] ( #0A )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8659:
    JSR $&code_0B8AF6
    LDY $24
    LDA $0016, Y
    CLC 
    ADC #$00C0
    STA $16
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B8624
    BRA loc_0B8659
}

code_0B8672 {
    COP [StageSprAndHitbox] ( #0E )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8683:
    JSR $&code_0B8B05
    LDY $24
    LDA $0016, Y
    SEC 
    SBC #$00B0
    STA $16
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B8624
    BRA loc_0B8683
}

code_0B869C {
    LDA #$000A
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B32
    COP [CallScript] ( &code_0B837D )

  loc_0B86B6:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    BEQ loc_0B86C2
    JMP $&code_0B8624

  loc_0B86C2:
    RTL 
}

code_0B86C3 {
    LDA #$000A
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B5C
    COP [CallScript] ( &code_0B8422 )
    BRA loc_0B86B6

  code_0B86DF:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    CMP #$0005
    BNE loc_0B86EC
    RTL 

  loc_0B86EC:
    COP [SetEntryContinue]
}

code_0B86EE {
    LDY $24
    LDA $0026, Y
    BNE code_0B86F6
    RTL 

  code_0B86F6:
    LDY $24
    LDA $0024, Y
    STA $14
    LDA $0026, Y
    DEC 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0B870A )
}

code_list_0B870A [
  &code_0B8714   ;00
  &code_0B8744   ;01
  &code_0B8774   ;02
  &code_0B879B   ;03
  &code_0B86DF   ;04
]

code_0B8714 {
    COP [StageSprAndHitbox] ( #05 )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8725:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8725
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B8732:
    JSR $&code_0B8AF6
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B86F6
    DEC $26
    BMI loc_0B8725
    BRA loc_0B8732
}

code_0B8744 {
    COP [StageSprAndHitbox] ( #09 )
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X

  loc_0B8755:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8755
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B8762:
    JSR $&code_0B8B05
    COP [SetEntryExit]
    LDY $24
    LDA $0026, Y
    BNE code_0B86F6
    DEC $26
    BMI loc_0B8755
    BRA loc_0B8762
}

code_0B8774 {
    LDA #$0005
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B32
    COP [CallScript] ( &code_0B837D )

  loc_0B878E:
    COP [SetEntryContinue]
    LDY $24
    LDA $0026, Y
    BEQ loc_0B879A
    JMP $&code_0B86F6

  loc_0B879A:
    RTL 
}

code_0B879B {
    LDA #$0005
    STA $chatPtr, X
    LDY $24
    LDA $0024, Y
    STA $14
    LDA #$02E0
    STA $16
    JSR $&code_0B8B5C
    COP [CallScript] ( &code_0B8422 )
    BRA loc_0B878E

  code_0B87B7:
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
    BCC loc_0B87D8
    COP [LoopNext]

  loc_0B87D8:
    COP [Die]
}

code_0B87DA {
    LDA #$4000
    TSB $12
    COP [StageForceMoveX] ( #11 )
    BRA loc_0B87E9
}

code_0B87E4 {
    COP [StageForceMoveX] ( #11 )
    COP [SetHFlip]

  loc_0B87E9:
    LDA #$0002
    TSB $12
    COP [StageSprAndHitbox] ( #10 )
    COP [CallScript] ( &code_0B89D7 )
    LDA #$0101
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #26 )
    COP [StageSprAndHitbox] ( #1D )
    STZ $26

  loc_0B8807:
    COP [StageForceMoveXY] ( #03, #01 )

  loc_0B880B:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B8807
    LDA $08
    STZ $08
    STA $24

  loc_0B8817:
    LDA $14
    CMP #$02C8
    BCC loc_0B8839
    LDA #$4000
    TSB $12
    LDA $26
    INC $26
    CMP #$0002
    BCS loc_0B8879
    CLC 
    ADC #$001E
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [ClearHFlip]
    BRA loc_0B8859

  loc_0B8839:
    LDA $14
    CMP #$0038
    BCS loc_0B8859
    LDA #$4000
    TRB $12
    LDA $26
    INC $26
    CMP #$0002
    BCS loc_0B8879
    CLC 
    ADC #$001E
    STA $28
    COP [StageSprAndHitbox] ( #FF )
    COP [SetHFlip]

  loc_0B8859:
    LDA $16
    CMP #$02F0
    BCC loc_0B8865
    LDA #$2000
    TSB $12

  loc_0B8865:
    LDA $16
    CMP #$02B0
    BCS loc_0B8871
    LDA #$2000
    TRB $12

  loc_0B8871:
    COP [SetEntryExit]
    DEC $24
    BPL loc_0B8817
    BRA loc_0B880B

  loc_0B8879:
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

code_0B8891 {
    LDA #$4000
    TSB $12
}

code_0B8896 {
    COP [StageForceMoveX] ( #13 )
    COP [StageSprAndHitbox] ( #21 )
    COP [CallScript] ( &code_0B89D7 )
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #13 )
    COP [StageSpriteLoop] ( #22, #06 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #14 )
    COP [SpawnLastRel] ( @code_0B88C1, #00, #FD, #$0302 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [Die]
}

code_0B88C1 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0B88CD {
    LDA #$4000
    TSB $12
    BRA code_0B88DB

  loc_0B88D4:
    LDA #$4000
    TSB $12
    BRA loc_0B88E0
}

code_0B88DB {
    COP [StageForceMoveX] ( #13 )
    BRA loc_0B88E3

  loc_0B88E0:
    COP [StageForceMoveX] ( #11 )

  loc_0B88E3:
    COP [PlaySoundCh1] ( #13 )
    COP [StageSprAndHitbox] ( #10 )
    COP [CallScript] ( &code_0B89D7 )
    COP [PlaySoundCh1] ( #1D )
    LDA #$&enemy_stats_table+DC
    STA $statsPtr, X
    LDA $@enemy_stats_table+DC
    AND #$00FF
    STA $currentHp, X
    COP [PlaySoundCh1] ( #28 )
    LDA #$0010
    TRB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA #$00B0
    TSB $12

  loc_0B8914:
    LDA #$2000
    TSB $10
    COP [RngByte]
    AND #$007F
    CLC 
    ADC #$0064
    STA $08
    COP [SetEntryExit]

  code_0B8926:
    COP [RngByte]
    PHA 
    SEC 
    SBC #$007F
    CLC 
    ADC $playerXPos
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
    COP [BranchIfSolid] ( &code_0B8926 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #14, #02 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #02, &code_0B8972 )
    COP [SpawnLastRel] ( @code_0B8979, #00, #F0, #$0200 )
    COP [StageSpriteLoop] ( #14, #02 )
    COP [AnimLoop]
}

code_0B8972 {
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    BRA loc_0B8914
}

code_0B8979 {
    COP [OrActorFlags] ( #$0010 )
    COP [PlaySoundCh1] ( #1E )
    LDA #$0002
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @smooth_follow_child.SmoothFollowChildTick, #$2000 )
    CPY #$1FC0
    BEQ loc_0B89D0
    LDA $playerActor
    STA $0024, Y
    COP [StageSprAndHitbox] ( #17 )

  loc_0B899C:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B899C
    LDA $08
    STZ $08
    INC 
    STA $26

  loc_0B89A9:
    LDA $14
    CMP #$0030
    BCC loc_0B89D2
    CMP #$02D0
    BCS loc_0B89D2
    LDA $16
    CMP #$0294
    BCC loc_0B89D2
    CMP #$02F8
    BCS loc_0B89D2
    COP [SetEntryExit]
    LDA $10
    BIT #$4000
    BNE loc_0B899C
    DEC $26
    BPL loc_0B89A9
    BRA loc_0B899C

  loc_0B89D0:
    COP [Die]

  loc_0B89D2:
    COP [JumpScript] ( @player_transition_handlers )
}

code_0B89D7 {
    COP [OrActorFlags] ( #$0080 )
    COP [SetSpritePriority] ( #30 )
    COP [InitGravity] ( #02, #08, #00 )
    COP [SetEntryContinue]
    LDA $14
    CMP #$02D0
    BCC loc_0B89F1
    LDA #$4000
    TSB $12

  loc_0B89F1:
    LDA $14
    CMP #$0030
    BCS loc_0B89FD
    LDA #$4000
    TRB $12

  loc_0B89FD:
    COP [TickGravity]
    CMP #$0000
    BMI loc_0B8A05
    RTL 

  loc_0B8A05:
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0B8A09 {
    LDA #$0180
    TSB $12
    COP [SpawnMarkedBefore] ( @code_0B8AD5, #$2300 )
    STY $20
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B8A26
    JMP $&code_0B8AC7

  loc_0B8A26:
    LDA #$000B
    STA $0000
    LDY $06
    STY $0002
    STZ $0004
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0B8A3F
    INC $0004

  loc_0B8A3F:
    LDA #$02D0
    CMP $0016, Y
    BCS loc_0B8A52
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    BRA loc_0B8A5B

  loc_0B8A52:
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_0B8A5B:
    CPY $0002
    BEQ loc_0B8A7D
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    LDA $0004
    BEQ loc_0B8A7D
    LDA $0036
    LSR 
    BCC loc_0B8A7D
    LDA $000E, Y
    ORA #$0800
    STA $000E, Y

  loc_0B8A7D:
    DEC $0000
    BMI loc_0B8A88
    LDA $0006, Y
    TAY 
    BRA loc_0B8A3F

  loc_0B8A88:
    LDA #$000B
    STA $0000
    LDY $06

  loc_0B8A90:
    LDA #$02C8
    SEC 
    SBC $0016, Y
    BPL loc_0B8A9D
    EOR #$FFFF
    INC 

  loc_0B8A9D:
    CMP #$000A
    BCS loc_0B8ABC
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

  loc_0B8ABC:
    DEC $0000
    BMI loc_0B8AC9
    LDA $0006, Y
    TAY 
    BRA loc_0B8A90
}

code_0B8AC7 {
    COP [SetEntryContinue]

  loc_0B8AC9:
    LDY $20
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTL 
}

code_0B8AD5 {
    LDA #$2000
    TRB $10

  loc_0B8ADA:
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    BRA loc_0B8ADA
}

code_0B8AE1 {
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0020
    STA $orbitDiameter, X
    LDA $14
    STA $7F100C, X
    RTS 
}

code_0B8AF6 {
    LDY $04
    JSR $&code_0B8B14
    LDA $0016, Y
    CLC 
    ADC #$0010
    STA $16
    RTS 
}

code_0B8B05 {
    LDY $04
    JSR $&code_0B8B14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    RTS 
}

code_0B8B14 {
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

code_0B8B32 {
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

code_0B8B5C {
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

code_0B8B86 {
    LDA $7F100C, X
    BEQ loc_0B8B8D
    RTS 

  loc_0B8B8D:
    INC 
    STA $7F100C, X
    LDA #$0000
    STA $chatPtr, X
    LDA #$000A
    STA $0000
    LDA #$0004
    STA $0002
    LDY $06

  loc_0B8BA7:
    LDA $0002
    STA $0008, Y
    CLC 
    ADC #$0003
    STA $0002
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_0B8BA7
    RTS 
}

code_0B8BBE {
    COP [PlaySoundCh1] ( #27 )
    COP [SpawnLastRel] ( @code_0B87B7, #00, #00, #$0301 )
    RTS 
}

code_0B8BCB {
    LDA $playerXPos
    CMP #$00F8
    BCS loc_0B8BD8
    LDA #$0088
    BRA loc_0B8BE5

  loc_0B8BD8:
    CMP #$01F8
    BCS loc_0B8BE2
    LDA #$0188
    BRA loc_0B8BE5

  loc_0B8BE2:
    LDA #$0288

  loc_0B8BE5:
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
---------------------------------------------

sub_0B9CE8 {
    LDA $orbitAngle, X
    TAY 
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.sine_table_8bit, Y
    BPL loc_0B9CF9
    EOR #$FF
    INC 
    SEC 

  loc_0B9CF9:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_0B9D0E
    EOR #$FFFF
    INC 

  loc_0B9D0E:
    RTS 
}