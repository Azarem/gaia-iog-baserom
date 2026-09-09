?BANK 03

?INCLUDE 'cop_handlers_actors'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'overworld_names'
?INCLUDE 'overworld_options'
?INCLUDE 'overworld_routes'
?INCLUDE 'pr_actor_0BCF52'
?INCLUDE 'pr_proc_03A83E'
?INCLUDE 'table_01B086'

!sceneNext                      0642
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!joypadRaw                      0660
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!characterForm                  0AD4
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch2                   7F002E

---------------------------------------------

sFE_actor_03A2F1 [
  actor-def < #00, #00, #20, {

  code_03A2F4:
    LDA #$0000
    STA $characterForm
    COP [SpawnThinkerParam] ( #0B, @cop_handlers_actors.PaletteResetAndKillThinker )
    JSL $@cop_handlers_script.ClearAllWramFlags
    COP [SpawnThinkerParam] ( #0B, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [SpawnAfterFlags] ( @code_03A35E, #$3800 )
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA $0D58
    BEQ loc_03A35C
    COP [SetEntryExit]
    PHX 
    TYX 
    LDA $animScratch2, X
    ORA #$0804
    STA $animScratch2, X
    PLX 
    LDA $0D58
    STA $24
    AND #$001F
    STA $0000
    COP [SetSavedPtr] ( &code_03A341 )
    COP [SwitchCase] ( #$0000, &overworld_options )
} >
]

code_03A341 {
    LDA $0D5A
    BEQ loc_03A35C
    SEP #$20
    LDA $sceneNext
    STA $0D6E
    REP #$20
    LDA $0652
    STA $0D6C
    STZ $0652
    STZ $sceneNext

  loc_03A35C:
    COP [Die]
}

code_03A35E {
    LDA $0D54
    STA $14
    SEC 
    SBC #$0080
    STA $cameraTargetX
    LDA $0D56
    STA $16
    SEC 
    SBC #$0070
    STA $cameraTargetY
    COP [InitGravity] ( #20, #05, #00 )
    COP [LoopInit] ( #2C )
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    COP [SetEntryExit]
    COP [LoopNext]
    LDA $0D58
    BEQ loc_03A3A4
    COP [WaitByte] ( #0F )
    COP [SpawnThinker] ( @pr_proc_03A83E.e_pr_proc_03A83E )
    COP [SetEntryContinue]
    LDA $0D5A
    BNE loc_03A3A4
    RTL 

  loc_03A3A4:
    LDA $0D6F
    AND #$00FF
    STA $0000
    COP [SpawnBeforeFlags] ( @pr_actor_0BCF52, #$2000 )
    JSR $&code_03A692
    TYA 
    LDY $04
    STA $0026, Y
    COP [InitGravity] ( #00, #07, #00 )
    COP [LoopInit] ( #5D )
    COP [TickGravity]
    LDA $00B6
    CLC 
    ADC $moveScratch2, X
    STA $00B6
    INC $00B8
    COP [LoopNext]
    LDA #$0000
    STA $moveScratch2, X
    LDA #$2000
    TRB $10
    LDY #$0000

  loc_03A3E6:
    INY 
    INY 
    CPY #$000C
    BCS loc_03A3F2
    LDA $0D60, Y
    BNE loc_03A3E6

  loc_03A3F2:
    PHX 
    TYX 
    DEX 
    DEX 
    LDA $@binary_list_03A503, X
    STA $18
    LDA #$*binary_list_03A503
    STA $1A
    PLX 
    LDA $0D60
    STA $28
    LDA [$18]
    STA $24
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $25
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $16
    INC $18
    INC $18
    LDY #$0000

  loc_03A426:
    INY 
    INY 
    STY $26
    LDA $0D60, Y
    BEQ loc_03A450
    PHA 
    COP [SpawnAfterFlags] ( @code_03A469, #$1800 )
    PLA 
    STA $0028, Y
    LDA [$18]
    STA $0024, Y
    LDA $24
    STA $0026, Y
    INC $18
    INC $18
    LDY $26
    CPY #$000A
    BCC loc_03A426

  loc_03A450:
    LDA $24
    STA $orbitDiameter, X
    COP [LoopInit] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    STZ $00DA
    COP [SpawnBefore] ( @code_03A52F )
    BRA loc_03A497
}

code_03A469 {
    LDA $26
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    LDA $25
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 )
    LDA $orbitAngle, X
    STA $24

  loc_03A497:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryContinue]
    LDA $24
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $24
    XBA 
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $16
    LDA $0D5A
    BEQ loc_03A4C6
    DEC $26
    BMI loc_03A4C4
    RTL 

  loc_03A4C4:
    BRA loc_03A497

  loc_03A4C6:
    LDA $orbitDiameter, X
    AND #$00FF
    CLC 
    ADC $cameraTargetX
    STA $moveXAlt, X
    CMP $14
    BNE loc_03A4EE
    LDA $7F0013, X
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    CMP $16
    BNE loc_03A4EE
    COP [Die]

  loc_03A4EE:
    LDA $7F0013, X
    AND #$00FF
    CLC 
    ADC $cameraTargetY
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #01 )
    COP [Die]
}

binary_list_03A503 [
  &binary_03A511   ;00
  &binary_03A521   ;01
  &binary_03A511   ;02
  &binary_03A511   ;03
  &binary_03A525   ;04
  &binary_03A511   ;05
  &binary_03A511   ;06
]

binary_03A511 #80807090909068A098A0809860B0A0B0

binary_03A521 #78808880

binary_03A525 #80807090909068A098A0

code_03A52F {
    PHX 
    LDA $0D5A
    ASL 
    TAX 
    LDA $@overworld_routes, X
    STA $2C
    LDA #$*overworld_routes
    STA $2E
    PLX 

  code_03A541:
    LDA [$2C]
    AND #$00FF
    CMP #$00FF
    BNE loc_03A54E
    JMP $&code_03A5FE

  loc_03A54E:
    INC $2C
    CMP #$00FE
    BNE loc_03A558
    JMP $&code_03A5F0

  loc_03A558:
    ASL 
    TAY 
    LDA $&table_01B086, Y
    STA $18
    LDA [$2C]
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&table_01B086, Y
    STA $1A
    LDA [$2C]
    AND #$00FF
    INC $2C
    ASL 
    TAY 
    LDA $&table_01B086, Y
    STA $1C
    LDA [$2C]
    AND #$00FF
    INC $2C
    STA $24
    COP [SetEntryContinue]
    LDA $18
    BEQ loc_03A5A2
    LDA ($18)
    INC $18
    INC $18
    CLC 
    ADC $00CA
    STA $00CA
    SEC 
    SBC #$0080
    STA $cameraTargetX
    LDA ($18)
    STA $18

  loc_03A5A2:
    LDA $1A
    BEQ loc_03A5BE
    LDA ($1A)
    INC $1A
    INC $1A
    CLC 
    ADC $00CC
    STA $00CC
    SEC 
    SBC #$0070
    STA $cameraTargetY
    LDA ($1A)
    STA $1A

  loc_03A5BE:
    LDA $1C
    BEQ loc_03A5D3
    LDA ($1C)
    INC $1C
    INC $1C
    CLC 
    ADC $00BC
    STA $00BC
    LDA ($1C)
    STA $1C

  loc_03A5D3:
    DEC $24
    BMI loc_03A5D8
    RTL 

  loc_03A5D8:
    JMP $&code_03A541
}

code_03A5DB {
    LDA $0D6E
    AND #$00FF
    STA $sceneNext
    LDA $0D6C
    STA $0652
    JSR $&code_03A681
    COP [SetEntryContinue]
    RTL 
}

code_03A5F0 {
    LDA $2C
    INC 
    INC 
    STA $0D5C
    LDA [$2C]
    STA $2C
    JMP $&code_03A541
}

code_03A5FE {
    LDA $0D5C
    BEQ loc_03A60B
    STZ $0D5C
    STA $2C
    JMP $&code_03A541

  loc_03A60B:
    STZ $0D5A
    STZ $0D58
    LDA $0D6E
    AND #$00FF
    STA $0000
    COP [SpawnAfterFlags] ( @pr_actor_0BCF52, #$2000 )
    JSR $&code_03A692
    TYA 
    LDY $06
    STA $0026, Y
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDA $00B6
    SEC 
    SBC #$0010
    BMI loc_03A644
    STA $00B6
    LDA $joypadRaw
    BIT #$1000
    BNE code_03A5DB
    RTL 

  loc_03A644:
    LDA #$0000
    STA $00B6
    COP [SetEntryExit]
    STZ $00DA
    LDA #$0800
    TSB $10
    COP [InitGravity] ( #00, #06, #00 )
    LDA #$0406
    STA $gfxCacheIdxB
    LDA $0D6E
    AND #$00FF
    STA $sceneNext
    LDA $0D6C
    STA $0652
    JSR $&code_03A681
    COP [SetEntryContinue]
    COP [TickGravity]
    LDA $moveScratch2, X
    CLC 
    ADC $00B8
    STA $00B8
    RTL 
}

code_03A681 {
    LDA #$0000
    LDY #$0000

  loc_03A687:
    STA $0D52, Y
    INY 
    INY 
    CPY #$001C
    BCC loc_03A687
    RTS 
}

code_03A692 {
    PHP 
    PHX 
    LDX #$0000
    SEP #$20
    PHB 
    LDA #$^overworld_names
    PHA 
    PLB 

  loc_03A69E:
    LDA $&overworld_names, X
    BEQ loc_03A6B6
    CMP $0000
    BEQ loc_03A6AD
    INX 
    INX 
    INX 
    BRA loc_03A69E

  loc_03A6AD:
    REP #$20
    LDY $&overworld_names+1, X
    PLB 
    PLX 
    PLP 
    RTS 

  loc_03A6B6:
    PLB 
    PLX 
    PLP 
    RTS 
}