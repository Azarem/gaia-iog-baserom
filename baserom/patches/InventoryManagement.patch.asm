?BANK 03

?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_03BAE1'
?INCLUDE 'jeweler_gem'

!player_actor                   09AA
!jewels_collected               0AB0
!inventory_slots                0AB4
!inventory_equipped_index       0AC4
!inventory_equipped_type        0AC6
;!page_2                         0B34  ;16 items per page

!state_1                        0B54
!herb_count                     0B55
!jewel_count                    0B56
!crystal_count                  0B57
!key_item_flags                 0B58

;Options menu setting (registry format: options_menu_core.asm)
;Storage: $0B3A bit 4 (set = Auto-Jewels off). Temp (TBL switch) word: $0BE4
!auto_jewels_setting            0B3A

AutoJewelsChoices [
  &auto_jewels_on
  &auto_jewels_off
]

auto_jewels_on  |On|
auto_jewels_off |Off|

optstr_auto_jewels |[PAL:0]Auto-Jewels[N] [PAL:14][TBL:@AutoJewelsChoices,BE4][PAL:0]|
optstr_auto_jewels_desc |[PAL:0][POS:96,5]Red Jewels are used[DBL]automatically when[DBL]they are picked up.|

------------------------------------------------
;Checks for an available inventory slot
;Assumes: M == 1, preserves A and X and Y
;Accepts: A = item ID
;Returns: carry set = no slot found

InventoryCheckAndStore {
    PHY
    PHA
    LDY #$0000

  icas_check_loop:
    LDA $inventory_slots, Y
    BEQ icas_check_found
    INY
    CPY #$0010
    BCC icas_check_loop

    PLA
    PLY
    SEC
    RTL
  
  icas_check_found:
    PLA
    STA $inventory_slots, Y
    PLY
    CLC
    RTL
}

------------------------------------------------

  inv_remove_stub:
    SEP #$20
    LDA $inventory_slots, X
    CMP #$01
    BEQ inv_remove_jewel
    CMP #$06
    BEQ inv_remove_herb
    CMP #$0E
    BEQ inv_remove_crystal
    BRA inv_remove_item

  inv_remove_jewel:
    SED
    REP #$20
    LDA $jewels_collected

  inv_add_jewel_count:
    CLC
    ADC #$0001 

    SEP #$20
    DEC $jewel_count
    BMI inv_remove_jewel_minus
    REP #$20
    BEQ inv_finish_jewel_item
    BRA inv_add_jewel_count

  inv_remove_jewel_minus:
    STZ $jewel_count
    REP #$20
   
  inv_finish_jewel_item:
    STA $jewels_collected
    CLD
    SEP #$20
    BRA inv_remove_item

  inv_remove_herb:
    DEC $herb_count
    BMI inv_remove_herb_minus
    BEQ inv_remove_item
    RTS

  inv_remove_herb_minus:
    STZ $herb_count
    BRA inv_remove_item
  
  inv_remove_crystal:
    DEC $crystal_count
    BMI inv_remove_crystal_minus
    BEQ inv_remove_item
    RTS

  inv_remove_crystal_minus:
    STZ $crystal_count

  inv_remove_item:
    STZ $inventory_slots, X
    CPX $inventory_equipped_index
    BNE inv_remove_finish
    REP #$20
    LDA #$0000
    STA $inventory_equipped_type
    DEC
    STA $inventory_equipped_index
    LDA #$1000
    TRB $06EE

  inv_remove_finish:
    RTS

------------------------------------------------
;Entry point for gem use (prevent increase, this is done elsewhere)
UseItem_RedJewel! {
    COP [PrintDialogString] ( &dialogstring_038517 )
    JSR $&RemoveEquippedItem
    BRA UseItem_SpawnSparkle

  UseItem_AddAndSpawn:
    SED 
    LDA $jewels_collected
    CLC 
    ADC #$0001
    STA $jewels_collected
    CLD 

  UseItem_SpawnSparkle:
    PHX 
    PHD 
    LDA $player_actor
    TCD 
    TAX 
    COP [SpawnListAppend] ( @code_038566, #00, #00, #$2000 )
    TYX 
    LDA #$0000
    STA $0012, X
    LDA #$3000
    STA $000E, X
    LDY $player_actor
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLD 
    PLX 
    RTS 
}

---------------------------------------------
;Entry point for removing an item from the inventory upon use

RemoveEquippedItem! {
    PHX
    LDX $inventory_equipped_index
    JSR inv_remove_stub
    PLX
    REP #$20
    RTS
}

---------------------------------------------

AutoUseRedJewelHandler {
    CMP #$01
    BEQ aurjh_continue
    RTS

  aurjh_continue:
    PHA
    LDA $auto_jewels_setting
    AND #$10
    BNE aurjh_disabled
    PLA
    REP #$20
    JSR $&UseItem_AddAndSpawn
    PLA           ;Pull the last JSR from the stack
    SEP #$20
    JMP GiveItem_StoreInSlot+4

  aurjh_disabled:
    PLA           ;Restore the item ID and let it go to the inventory normally
    RTS
}

--------------------------------------------------
;Entry point for adding an item to the inventory

GiveItemToPlayer! {
    PHP 
    SEP #$20
    BIT #$80
    BNE loc_03EFB3
    JSR $&AutoUseRedJewelHandler
    JSL $@KeyItemCheckAndStore
    BCC inv_give_item_normal
    JMP GiveItem_StoreInSlot+4

  inv_give_item_full:
    JMP GiveItem_InventoryFull+1
    
  inv_give_item_normal:
    CPY #$0001
    BEQ inv_give_item_full
    JSL $@InventoryCountersCheckAndStore
    BCC inv_give_item_continue
    JMP GiveItem_StoreInSlot+4

  inv_give_item_continue:
    CPY #$0001
    BEQ inv_give_item_full
    JSL $@InventoryCheckAndStore
    BCS inv_give_item_full
    JMP GiveItem_StoreInSlot+4

  loc_03EFA2!:
  loc_03EFAA!:
}

---------------------------------------------
;Entry point for checking inventory for item

loc_03F0B9! {
    CMP $inventory_slots, Y
    BEQ loc_03F0C7
    INY 
    CPY #$0010
    BNE loc_03F0B9
    ;LDY #$0000

  ;inv_search_page2:
    ;CMP $page_2, Y
    ;BEQ code_03F0C7
    ;INY 
    ;CPY #$0010
    ;BNE inv_search_page2

    PLP 
    SEC 
    RTL 
}

---------------------------------------------
;Route COP item removal through common process

loc_03F0A0! {
    PHX
    TYX
    JSR inv_remove_stub
    PLX
    REP #$20
}

-----------------------------------------
;Entry point for giving Jewels to Gem

JewelerCountJewels! {
    SEP #$20
    LDA #$00
    XBA
    LDA $jewel_count
    BEQ search_inventory
    STZ $jewel_count
    REP #$20
    STA $26
    SED
    LDA $0AB0

  search_add_top:
    CLC
    ADC #$0001
    DEC $26
    BEQ search_store_gems
    BRA search_add_top
  
  search_store_gems:
    STA $0AB0
    CLD
    SEP #$20

  search_inventory:
    LDA #$01
    LDY #$000F

  search_top_1:
    CMP $inventory_slots, Y
    BNE search_next_1
    PHA
    LDA #$00
    STA $inventory_slots, Y		
    PLA

  search_next_1:
    DEY
    BPL search_top_1
    ;LDY #$000F

  ;search_top_2:
    ;CMP $page_2, Y
    ;BNE search_next_2
    ;PHA
    ;LDA #$00
    ;STA $page_2, Y		
    ;PLA 

  ;search_next_2:
  ;  DEY
  ;  BPL search_top_2

    REP #$20
}

loc_08CF74! {
}

loc_08CF84! {
}

------------------------------------------------
;Registration of the Auto-Jewels setting (must stay after the overrides above)

OptionSettingPreset- [
  @optstr_auto_jewels       ;+00 render
  @optstr_auto_jewels_desc  ;+03 desc
  #$0BE4                    ;+06 temp
  #$0B3A                    ;+08 store
  #$0004                    ;+0A shift
  #$0001                    ;+0C mask
  #$0000                    ;+0E xor
  #$0002                    ;+10 count
  #$0000                    ;+12 load   (packed bits)
  #$0000                    ;+14 change
  #$0000                    ;+16 commit (packed bits)
]
