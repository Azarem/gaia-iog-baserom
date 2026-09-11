?BANK 03

?INCLUDE 'body_table'

!deathFlag                      0200
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!layerPriorityFlag              06EE
!playerFlags                    09AE
!displayModeFlags               09EC
!characterForm                  0AD4
!spritesetPtr                   7F0006
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!iframeCounter                  7F0028
!oamComposeBuffer               7F3100

---------------------------------------------

SortActorsByDepth {
    PHP 
    PHD 
    REP #$20
    LDY #$0000
    LDA $0058

  code_03C609:
    TAX 
    TCD 
    BNE loc_03C610
    JMP $&SortActors_BuildFinalList

  loc_03C610:
    LDA $14
    SEC 
    SBC $18
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCC loc_03C631
    BMI loc_03C623
    JMP $&SortActors_OffScreen

  loc_03C623:
    LDA $14
    CLC 
    ADC $1C
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCS SortActors_OffScreen

  loc_03C631:
    LDA $16
    SEC 
    SBC $1A
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCC loc_03C64F
    BPL SortActors_OffScreen
    LDA $16
    CLC 
    ADC $1E
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCS SortActors_OffScreen

  loc_03C64F:
    LDA $10
    BIT #$2000
    BNE loc_03C687
    BIT #$0003
    BEQ loc_03C665
    BIT #$0002
    BNE loc_03C670
    LDA #$01FE
    BRA loc_03C677

  loc_03C665:
    LDA $16
    SEC 
    SBC $bg2ScrollH
    CMP #$0100
    BCC loc_03C673

  loc_03C670:
    LDA #$00FF

  loc_03C673:
    EOR #$00FF
    ASL 

  loc_03C677:
    CMP #$0200
    BCS loc_03C677
    STA $0C00, Y
    TXA 
    STA $0C02, Y
    INY 
    INY 
    INY 
    INY 

  loc_03C687:
    LDA #$4000
    TRB $10
    LDA $04
    JMP $&code_03C609
}

SortActors_OffScreen {
    LDA #$4000
    TSB $10
    LDA $04
    JMP $&code_03C609
}

SortActors_BuildFinalList {
    LDA #$FFFF
    STA $0C00, Y
    LDA #$0000
    TCD 
    LDA #$0422
    STA $02
    TSC 
    STA $00
    LDA #$0BFF
    TCS 

  loc_03C6B1:
    PLX 
    BMI loc_03C6EB
    LDY $deathFlag, X
    BNE loc_03C6D3
    LDA $02
    STA $deathFlag, X
    TAY 
    PLA 
    STA $0000, Y
    LDA #$0000
    STA $0002, Y
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C6B1

  loc_03C6D3:
    LDA $02
    STA $deathFlag, X
    TAX 
    PLA 
    STA $0000, X
    TYA 
    STA $0002, X
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C6B1

  loc_03C6EB:
    LDA #$01FF
    TCS 
    LDX #$0000
    BRA loc_03C6F6

  loc_03C6F4:
    PHA 
    PLA 

  loc_03C6F6:
    PLY 
    BEQ loc_03C6F6
    BMI loc_03C70B

  loc_03C6FB:
    LDA $0000, Y
    STA $0C00, X
    INX 
    INX 
    LDA $0002, Y
    BEQ loc_03C6F4
    TAY 
    BRA loc_03C6FB

  loc_03C70B:
    STZ $0C00, X
    LDA $00
    TCS 
    PLD 
    PLP 
    RTL 
}

ComposeAllSprites {
    PHP 
    REP #$20
    LDA #$06FE
    STA $08
    STZ $06FF
    STZ $070F
    STZ $14
    LDA $bg1ScrollH
    SEC 
    SBC #$0010
    STA $1A
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    STA $1E
    LDA #$0622
    STA $06
    LDA #$0004
    STA $0E
    TSC 
    STA $00
    LDA #$0621
    TCS 
    LDX #$0010
    LDA #$E080

  loc_03C74D:
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    DEX 
    BNE loc_03C74D
    LDA $00
    TCS 
    JSR $&RenderComposeBuffer
    STZ $00D8
    LDX #$0000

  loc_03C76C:
    LDA $0C00, X
    BEQ loc_03C77D
    INX 
    INX 
    PHX 
    TAX 
    JSR $&DecomposeActorMetasprites
    PLX 
    BCC loc_03C76C
    BRA loc_03C789

  loc_03C77D:
    SEP #$20
    LDA $00

  loc_03C781:
    LSR 
    LSR 
    DEC $0E
    BNE loc_03C781
    STA ($06)

  loc_03C789:
    PLP 
    RTL 
}

RenderComposeBuffer {
    LDX #$0000
    TXY 
    LDA $layerPriorityFlag
    BIT #$1000
    BNE loc_03C7F0

  loc_03C797:
    LDA $oamComposeBuffer, X
    BPL loc_03C79E
    RTS 

  loc_03C79E:
    LDA $7F3102, X
    SEC 
    SBC $bg2ScrollH
    CMP #$00F0
    BCS loc_03C7E8
    STA $0423, Y
    LDA $7F3104, X
    STA $0424, Y
    LDA $oamComposeBuffer, X
    SEC 
    SBC $bg1ScrollH
    CMP #$0110
    BCS loc_03C7E8
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    CLC 
    ROR $00
    DEC $0E
    BNE loc_03C7DC
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C7DC:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BNE loc_03C7E8
    RTS 

  loc_03C7E8:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_03C797

  loc_03C7F0:
    LDA $00DA
    BNE loc_03C7F6
    RTS 

  loc_03C7F6:
    LDX #$0600
    LDY #$0422
    LDA $00DA
    BIT #$FE00
    BEQ loc_03C807
    LDA #$0200

  loc_03C807:
    DEC 
    PHB 
    MVN #$00, #$7F
    PLB 
    LDA $00DA
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0E
    LDA $00DA
    LSR 
    AND #$0006
    STA $00
    SEP #$20

  loc_03C821:
    DEC $0E
    BMI loc_03C82D
    LDA #$AA
    STA ($06)
    INC $06
    BRA loc_03C821

  loc_03C82D:
    LDY $00DA
    LDX $00
    LDA $@OamHiTableMasks, X
    STA $00
    LDA $@OamHiTableMasks+1, X
    STA $0E
    REP #$20
    RTS 
}

OamHiTableMasks #00048003A002A801

DecomposeActorMetasprites {
    PHB 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0014, X
    SEC 
    SBC $0018, X
    SEC 
    SBC $1A
    STA $18
    LDA $0016, X
    SEC 
    SBC $001A, X
    SEC 
    SBC $1E
    STA $1C
    LDA $000E, X
    STA $04
    STZ $02
    LDA $0010, X
    BIT #$0080
    BEQ loc_03C896
    BIT #$0010
    BNE loc_03C896
    BIT #$0400
    BNE loc_03C885

  loc_03C885:
    LDA $iframeCounter, X
    BEQ loc_03C893
    LSR 
    BCC loc_03C893
    LDA #$0E00
    STA $02

  loc_03C893:
    LDA $0010, X

  loc_03C896:
    BIT #$8000
    BPL loc_03C89E
    JMP $&DecomposePlayerSprites

  loc_03C89E:
    LDA $metaspritePtr, X
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  loc_03C8B0:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C8B9
    XBA 

  loc_03C8B9:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCS loc_03C920
    SBC #$0010
    STA $0423, Y
    LDA $0005, X
    EOR $04
    ORA $02
    STA $0424, Y
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C8DE
    XBA 

  loc_03C8DE:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS loc_03C920
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C909
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C909:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C91E

  loc_03C914:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BNE loc_03C8B0

  loc_03C91E:
    PLB 
    RTS 

  loc_03C920:
    LDA #$E080
    STA $0422, Y
    BRA loc_03C914
}

DecomposePlayerSprites {
    JSR $&CheckPlayerSpriteCache
    LDA $playerFlags
    BPL loc_03C936
    LDA $animScratch2, X
    BRA loc_03C93F

  loc_03C936:
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 

  loc_03C93F:
    TAX 
    LDA $@body_table+3, X
    STA $06FC
    LDA $@body_table+5, X
    AND #$00FF
    STA ($08)
    INC $08
    LDA $09CC
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  code_03C963:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C96C
    XBA 

  loc_03C96C:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCC loc_03C97A
    JMP $&PlayerSprite_OffScreen

  loc_03C97A:
    SBC #$0010
    STA $0423, Y
    LDA $0005, X
    EOR $04
    ORA $02
    PHA 
    AND #$01FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ADC $06FC
    STA ($08)
    INC $08
    INC $08
    PLA 
    AND #$FE00
    ORA $14
    STA $0424, Y
    LDA $14
    INC 
    INC 
    BIT #$0010
    BEQ loc_03C9AF
    CLC 
    ADC #$0010

  loc_03C9AF:
    STA $14
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C9BB
    XBA 

  loc_03C9BB:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS PlayerSprite_OffScreen
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C9E6
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C9E6:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C9FE

  loc_03C9F1:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BEQ loc_03C9FE
    JMP $&code_03C963

  loc_03C9FE:
    LDA #$0000
    STA ($08)
    PLB 
    RTS 
}

PlayerSprite_OffScreen {
    LDA #$0004
    TSB $playerFlags
    LDA #$0008
    TSB $displayModeFlags
    LDA #$E080
    STA $0422, Y
    BRA loc_03C9F1
}

CheckPlayerSpriteCache {
    LDA $playerFlags
    BIT #$0004
    BNE loc_03CA37
    LDA $metaspritePtr, X
    CMP $09CC
    BNE loc_03CA37
    LDA $7F0008, X
    CMP $09CE
    BNE loc_03CA37
    LDA $09CC
    RTS 

  loc_03CA37:
    LDA $playerFlags
    AND #$FFFB
    STA $playerFlags
    LDA $7F0008, X
    STA $09CE
    LDA $metaspritePtr, X
    STA $09CC
    LDA #$0008
    TSB $displayModeFlags
    RTS 
}

UpdateActorAnimation {
    PHB 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $28
    ASL 
    CLC 
    ADC $spritesetPtr, X
    TAY 
    LDA $2A
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_03CAF0
    STA $08
    LDA $0002, Y
    TAY 
    CLC 
    ADC #$0004
    STA $metaspritePtr, X
    LDA $0E
    ROL 
    PHP 
    LDA $0002, Y
    STA $0002
    BCC loc_03CA92
    XBA 

  loc_03CA92:
    SEP #$20
    STA $1A
    XBA 
    STA $1E
    REP #$20
    LDA $0000, Y
    STA $0000
    PLP 
    BPL loc_03CAA5
    XBA 

  loc_03CAA5:
    STA $0000
    AND #$00FF
    BIT #$0080
    BEQ loc_03CAB3
    ORA #$FF00

  loc_03CAB3:
    STA $18
    LDA $0001
    AND #$00FF
    BIT #$0080
    BEQ loc_03CAC3
    ORA #$FF00

  loc_03CAC3:
    STA $1C
    INC $2A
    LDA $12
    BIT #$0100
    BNE loc_03CAED
    BIT #$0080
    BNE loc_03CAE3
    LDA $0000
    STA $20
    LDA $0002
    SEC 
    SBC #$0008
    STA $22
    BRA loc_03CAED

  loc_03CAE3:
    LDA $0000
    STA $20
    LDA $0002
    STA $22

  loc_03CAED:
    CLC 
    PLB 
    RTL 

  loc_03CAF0:
    STZ $2A
    SEC 
    PLB 
    RTL 
}