?BANK 03

?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'SpawnHitSparkSprites'

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