?BANK 03

?INCLUDE 'itemcomp_table_01EB0F'
?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'SpawnHitSparkSprites'

!sceneStateHelper               099F
!enemyHpDisplay                 09E4
!displayModeFlags               09EC
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!playerMaxHp                    0ACA
!playerHp                       0ACE
!gemCount                       0AD6
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

AsciiStringRenderer {
    PHP 
    PHB 

  loc_03EA64:
    SEP #$20
    LDA $0000, Y
    INY 
    CMP #$12
    BCS loc_03EA7C
    REP #$20
    PHX 
    AND #$00FF
    ASL 
    TAX 
    JSR ($&AsciiStringCommandTable, X)
    PLX 
    BRA loc_03EA64

  loc_03EA7C:
    STA $7F0200, X
    XBA 
    LDA $sceneStateHelper
    STA $7F0201, X
    INX 
    INX 
    BRA loc_03EA64
}

AsciiStringCommandTable [
  &AsciiCmd_End   ;00
  &AsciiCmd_SetVramAddr   ;01
  &AsciiCmd_InsertRemoteString   ;02
  &AsciiCmd_SetPalette   ;03
  &AsciiCmd_IndirectString   ;04
  &AsciiCmd_PrintBcdNumber   ;05
  &AsciiCmd_DrawBox   ;06
  &AsciiCmd_ClearColumn   ;07
  &AsciiCmd_FillTile   ;08
  &AsciiCmd_PrintEquipIcons   ;09
  &AsciiCmd_DrawPlayerHpBar   ;0A
  &AsciiCmd_DrawEnemyHpBar   ;0B
  &AsciiCmd_PrintRawBytes   ;0C
  &AsciiCmd_AdvanceRow4   ;0D
  &AsciiCmd_Print3DigitNumber   ;0E
  &AsciiCmd_ClearRect   ;0F
  &AsciiCmd_InsertItemName   ;10
  &AsciiCmd_AdvanceRow2   ;11
]

AsciiCmd_AdvanceRow2 {
    LDA $09A0
    CLC 
    ADC #$40
    BRK #$8D
    LDY #$8309
    ORA $60, S
}

AsciiCmd_InsertItemName {
    PHY 
    PHB 
    LDA $06, S
    TAX 
    LDA $0000, Y
    AND #$FF
    BRK #$0A
    PHA 
    SEP #$20
    LDA #$^itemcomp_table_01EB0F
    PHA 
    PLB 
    REP #$20
    PLY 
    LDA $&itemcomp_table_01EB0F, Y
    TAY 
    JSL $@AsciiStringRenderer
    TXA 
    STA $06, S
    PLB 
    PLY 
    INY 
    RTS 
}

AsciiCmd_ClearRect {
    PHY 
    LDA $05, S
    STA $00
    TAX 
    LDA $0000, Y
    AND #$00FF
    STA $0E
    STA $10
    LDA $0001, Y
    STA $12

  loc_03EAF7:
    LDA #$0000

  loc_03EAFA:
    STA $7F0200, X
    INX 
    INX 
    DEC $10
    BPL loc_03EAFA
    DEC $12
    BMI loc_03EB17
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA $0E
    STA $10
    BRA loc_03EAF7

  loc_03EB17:
    PLY 
    INY 
    INY 
    RTS 
}

AsciiCmd_DrawPlayerHpBar {
    PHY 
    STZ $08
    LDA $playerMaxHp
    CMP #$0029
    BMI loc_03EB3A
    LDA #$0028
    STA $playerMaxHp
    LDA $playerHp
    CMP #$0029
    BMI loc_03EB3A
    LDA #$0028
    STA $playerHp

  loc_03EB3A:
    LDA $playerHp
    LSR 
    STA $00
    BCC loc_03EB44
    INC $08

  loc_03EB44:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $playerMaxHp
    EOR #$FFFF
    INC 
    LSR 
    STA $02
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $playerMaxHp
    BCS loc_03EB64
    INC $02

  loc_03EB64:
    LDA #$0800
    STA $0004
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

DrawHpBar {
    TAX 
    LDY #$000A
    STZ $06
    LDA $00
    BEQ loc_03EB93
    LDA #$2006
    ORA $0004

  loc_03EB81:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EB8D
    JSR $&HpBar_AdvanceRow

  loc_03EB8D:
    DEC $00
    BEQ loc_03EB93
    BRA loc_03EB81

  loc_03EB93:
    LDA $08
    BEQ loc_03EBA8
    LDA #$2007
    ORA $04
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBA8
    JSR $&HpBar_AdvanceRow

  loc_03EBA8:
    LDA $02
    BEQ loc_03EBC3
    LDA #$20FF
    ORA $04

  loc_03EBB1:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBBD
    JSR $&HpBar_AdvanceRow

  loc_03EBBD:
    DEC $02
    BEQ loc_03EBC3
    BRA loc_03EBB1

  loc_03EBC3:
    LDA $06
    BNE loc_03EBD9
    LDA #$0000

  loc_03EBCA:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBCA
    JSR $&HpBar_AdvanceRow
    LDY #$000A

  loc_03EBD9:
    LDA #$0000

  loc_03EBDC:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBDC
    RTS 
}

HpBar_AdvanceRow {
    PHA 
    TXA 
    CLC 
    ADC #$002C
    TAX 
    STA $06
    CMP #$0100
    BCS loc_03EBF9
    PLA 
    LDY #$000A
    RTS 

  loc_03EBF9:
    PLA 
    PLA 
    RTS 
}

AsciiCmd_DrawEnemyHpBar {
    PHY 
    STZ $0008
    LDA $enemyHpDisplay
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $enemyHpDisplay
    LDA $09E6
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $09E6

  loc_03EC1C:
    LDA $09E6
    LSR 
    STA $00
    BCC loc_03EC26
    INC $08

  loc_03EC26:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $enemyHpDisplay
    EOR #$FFFF
    INC 
    LSR 
    STA $02
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $enemyHpDisplay
    BCS loc_03EC46
    INC $02

  loc_03EC46:
    LDA #$0400
    STA $04
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

AsciiCmd_End {
    PLA 
    PLX 
    PLB 
    PLP 
    RTL 
}

AsciiCmd_AdvanceRow4 {
    LDA $09A0
    CLC 
    ADC #$0080
    STA $09A0
    STA $03, S
    RTS 
}

AsciiCmd_Print3DigitNumber {
    PHY 
    LDA $05, S
    TAX 
    STZ $0006
    STZ $0000
    LDA $099E
    ORA #$0030
    STA $0004
    LDA $0000, Y
    TAY 
    LDA $0000, Y
    SEC 

  loc_03EC7F:
    INC $0000
    SBC #$0064
    BCS loc_03EC7F
    ADC #$0064
    STA $0002
    LDA $0000
    DEC 
    CMP #$0009
    BCC loc_03EC99
    LDA #$0009

  loc_03EC99:
    BIT #$000F
    BEQ loc_03ECA6
    ORA $0004
    INC $0006
    BRA loc_03ECA9

  loc_03ECA6:
    LDA #$2000

  loc_03ECA9:
    STZ $0000
    LDA $0002
    SEC 

  loc_03ECB0:
    INC $0000
    SBC #$000A
    BCS loc_03ECB0
    ADC #$000A
    STA $0002
    LDA $0000
    DEC 
    BNE loc_03ECD1
    LDA $0006
    BNE loc_03ECCE
    LDA #$2000
    BRA loc_03ECD4

  loc_03ECCE:
    LDA #$0000

  loc_03ECD1:
    ORA $0004

  loc_03ECD4:
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    LDA $0002
    SEC 

  loc_03ECE1:
    INC $0000
    SBC #$0001
    BCS loc_03ECE1
    LDA $0000
    DEC 
    ORA $0004
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    TXA 
    STA $05, S
    PLY 
    INY 
    INY 
    RTS 
}

AsciiCmd_SetVramAddr {
    LDA $0000, Y
    INY 
    INY 
    STA $09A0
    STA $03, S
    RTS 
}

AsciiCmd_InsertRemoteString {
    LDA $03, S
    TAX 
    PHY 
    PHB 
    LDA $0000, Y
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLY 
    JSL $@AsciiStringRenderer
    PLB 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

AsciiCmd_SetPalette {
    SEP #$20
    LDA $sceneStateHelper
    AND #$E3
    ORA $0000, Y
    INY 
    STA $sceneStateHelper
    REP #$20
    RTS 
}

AsciiCmd_IndirectString {
    PHY 
    PHB 
    LDX $0003, Y
    LDA $0000, X
    ASL 
    PHA 
    LDA $0000, Y
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    TAY 
    PLA 
    LDA $0000, Y
    TAY 
    LDA $06, S
    TAX 
    JSL $@AsciiStringRenderer
    PLB 
    PLA 
    CLC 
    ADC #$0005
    TAY 
    TXA 
    STA $03, S
    RTS 
}

AsciiCmd_PrintBcdNumber {
    LDA $03, S
    TAX 
    PHY 
    LDA $0000, Y
    AND #$00FF
    STA $000E
    STA $0010
    ASL 
    PHX 
    CLC 
    ADC $01, S
    STA $01, S
    TAX 
    LDA $0001, Y
    TAY 
    LDA $099E
    SEP #$20

  loc_03ED90:
    LDA $0000, Y
    AND #$0F
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BEQ loc_03EDC1
    LDA $0000, Y
    INY 
    AND #$F0
    LSR 
    LSR 
    LSR 
    LSR 
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BNE loc_03ED90

  loc_03EDC1:
    DEC $0010
    BEQ loc_03EDD8
    LDA $7F0200, X
    CMP #$30
    BNE loc_03EDD8
    LDA #$20
    STA $7F0200, X
    INX 
    INX 
    BRA loc_03EDC1

  loc_03EDD8:
    REP #$20
    PLX 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

AsciiCmd_DrawBox {
    PHY 
    LDA $0000, Y
    AND #$00FF
    STA $0000
    LDA $0001, Y
    AND #$00FF
    STA $0002
    LDA $0002, Y
    TAX 
    PHA 
    LDA $099E
    ORA #$0010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$0011

  loc_03EE11:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE11
    LDA $099E
    ORA #$4010
    STA $7F0202, X
    LDA $01, S
    CLC 
    ADC #$0040
    TAX 
    LDA $0002
    STA $000E

  loc_03EE33:
    PHX 
    LDA $099E
    ORA #$0012
    STA $7F0200, X
    LDA $0000
    STA $0010
    LDA $099E
    ORA #$0040

  loc_03EE4A:
    STA $7F0202, X
    INX 
    INX 
    DEC $0010
    BNE loc_03EE4A
    LDA $099E
    ORA #$4012
    STA $7F0202, X
    PLA 
    CLC 
    ADC #$0040
    TAX 
    DEC $000E
    BNE loc_03EE33
    LDA $099E
    ORA #$8010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$8011

  loc_03EE80:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE80
    LDA $099E
    ORA #$C010
    STA $7F0202, X
    PLA 
    PLY 
    CLC 
    ADC #$0082
    STA $09A0
    STA $03, S
    INY 
    INY 
    INY 
    INY 
    RTS 
}

AsciiCmd_ClearColumn {
    PHY 
    LDA $0000, Y
    TAX 
    STZ $0000
    SEP #$20
    PHX 

  loc_03EEB0:
    LDA $7F0200, X
    BEQ loc_03EEBD
    INX 
    INX 
    INC $0000
    BRA loc_03EEB0

  loc_03EEBD:
    DEC $0000
    REP #$20
    PLX 

  loc_03EEC3:
    LDA $0000
    STA $000E
    PHX 
    LDA #$0000

  loc_03EECD:
    STA $7F0200, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EECD
    LDA $7F0200, X
    TAY 
    LDA #$0000
    STA $7F0200, X
    PLX 
    TXA 
    CLC 
    ADC #$0040
    TAX 
    LDA $7F0200, X
    BNE loc_03EEC3
    PLY 
    INY 
    INY 
    RTS 
}

AsciiCmd_FillTile {
    PHY 
    LDA $0001, Y
    TAX 
    LDA $0000, X
    PHA 
    LDA $07, S
    TAX 
    LDA $099E
    SEP #$20
    LDA $0000, Y
    REP #$20
    PLY 
    BEQ loc_03EF17

  loc_03EF0E:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EF0E

  loc_03EF17:
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

AsciiCmd_PrintRawBytes {
    LDA $03, S
    TAX 

  loc_03EF22:
    LDA $0000, Y
    AND #$00FF
    CMP #$00FF
    BEQ loc_03EF39
    ORA $099E
    STA $7F0200, X
    INX 
    INX 
    INY 
    BRA loc_03EF22

  loc_03EF39:
    INY 
    TXA 
    STA $03, S
    RTS 
}

AsciiCmd_PrintEquipIcons {
    LDA $03, S
    TAX 
    LDA #$0000
    PHA 
    PHY 

  loc_03EF46:
    SEP #$20
    LDA $0000, Y
    BMI loc_03EF8A
    REP #$20
    AND #$00FF
    CMP #$0008
    BCS loc_03EF5D
    ASL 
    ORA #$01E0
    BRA loc_03EF65

  loc_03EF5D:
    SEC 
    SBC #$0008
    ASL 
    ORA #$02E0

  loc_03EF65:
    ORA $099E
    INX 
    INX 
    STA $7F01BE, X
    INC 
    STA $7F01C0, X
    CLC 
    ADC #$000F
    STA $7F01FE, X
    INC 
    STA $7F0200, X
    INX 
    INX 
    INY 
    LDA $01, S
    INC 
    STA $01, S
    BRA loc_03EF46

  loc_03EF8A:
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    INC 
    TAY 
    PLA 
    TXA 
    STA $03, S
    RTS 
}

GiveItemToPlayer {
    PHP 
    SEP #$20
    BIT #$80
    BNE loc_03EFB3
    PHA 
    LDY #$0000

  loc_03EFA2:
    LDA $inventorySlots, Y
    BNE loc_03EFAA
    JMP $&GiveItem_StoreInSlot

  loc_03EFAA:
    INY 
    CPY #$0010
    BNE loc_03EFA2
    JMP $&GiveItem_InventoryFull

  loc_03EFB3:
    SEC 
    SBC #$80
    BEQ loc_03F00C
    DEC 
    BEQ loc_03F032
    DEC 
    BNE loc_03EFC1
    JMP $&GiveItem_DefUp

  loc_03EFC1:
    DEC 
    BEQ loc_03EFE9
    DEC 
    BEQ loc_03EFED
    DEC 
    BEQ loc_03EFF1
    REP #$20
    LDA #$0005
    CLC 
    ADC $damageFlashTimer
    STA $damageFlashTimer
    PHD 
    TXA 
    TCD 
    COP [SpawnLastRel] ( @SpawnHitSparkSprites, #00, #00, #$2F00 )
    PLD 
    COP [PlaySoundCh2] ( #22 )
    JMP $&GiveItem_Success

  loc_03EFE9:
    LDA #$01
    BRA loc_03EFF3

  loc_03EFED:
    LDA #$02
    BRA loc_03EFF3

  loc_03EFF1:
    LDA #$05

  loc_03EFF3:
    REP #$20
    AND #$00FF
    CLC 
    ADC $gemCount
    CMP #$03E7
    BCC loc_03F004
    LDA #$03E7

  loc_03F004:
    STA $gemCount
    COP [PlaySoundCh2] ( #22 )
    BRA GiveItem_Success

  loc_03F00C:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerMaxHp
    CLC 
    ADC #$01
    BVC loc_03F023
    LDA #$55

  loc_03F023:
    STA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDY #$0000
    BRA GiveItem_Success

  loc_03F032:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerStr
    CLC 
    ADC #$01
    BVC loc_03F049
    LDA #$55

  loc_03F049:
    STA $playerStr
    LDY #$0000
    BRA GiveItem_Success
}

GiveItem_DefUp {
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerDef
    CLC 
    ADC #$01
    BVC loc_03F068
    LDA #$55

  loc_03F068:
    STA $playerDef
    LDY #$0000
    BRA GiveItem_Success
}

GiveItem_StoreInSlot {
    PLA 
    STA $inventorySlots, Y
    STA $0DB8
    STZ $0DB9
    LDY #$&itemget_table_01FD24.widestring_01FF1F
}

GiveItem_Success {
    PLP 
    CLC 
    RTL 
}

GiveItem_InventoryFull {
    PLA 
    STA $0DB8
    STZ $0DB9
    LDY #$&itemget_table_01FD24.widestring_01FF02
    PLP 
    SEC 
    RTL 
}

RemoveItemFromInventory {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03F093:
    CMP $inventorySlots, Y
    BEQ loc_03F0A0
    INY 
    CPY #$0010
    BNE loc_03F093
    BRA loc_03F0B1

  loc_03F0A0:
    LDA #$00
    STA $inventorySlots, Y
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType
    DEC 
    STA $inventoryEquippedIndex

  loc_03F0B1:
    PLP 
    RTL 
}

CheckInventoryForItem {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03F0B9:
    CMP $inventorySlots, Y
    BEQ loc_03F0C7
    INY 
    CPY #$0010
    BNE loc_03F0B9
    PLP 
    SEC 
    RTL 

  loc_03F0C7:
    PLP 
    CLC 
    RTL 
}