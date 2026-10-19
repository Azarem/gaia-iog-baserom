
!key_item_flags                 0B58

-------------------------------------------

--KeyItemCounters
; 00000001 = Prison Key
; 00000010 = Meat
; 00000100 = Incan Statue A
; 00001000 = Incan Statue B
; 00010000 = Diamond Block
; 00100000 = Elevator Key
; 01000000 = Mine Key A
; 10000000 = Mine Key B

; 00001111 = Crystal Balls
; 00010000 = Purify Stone
; 00100000 = Palace Key
; 11000000 = Statue of Hope

; 00000011 = Rama Statue
; 00000100 = Magic Dust
; 00111000 = Mushroom Drops
; 01000000 = Teapot
; 10000000 = Gorgon Flower

; 00111111 = Hieroglyphs


KeyItemFlagIndex [
    #FF
    #FF
    #00
    #02
    #03
    #FF
    #FF
    #04
    #FF
    #FF
    #01
    #06
    #07
    #FF
    #08
    #05
    #0D  ;10
    #0C
    #0E
    #10
    #12
    #FF
    #FF
    #FF
    #FF
    #16
    #13
    #FF
    #FF
    #17
    #18
    #19
    #1A  ;20
    #1B
    #1C
    #1D
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF  ;30
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
    #FF
]

KeyBucketLookup [
    &KeyBucketPrisonKey     ; +1 DEF
    &KeyBucketMeat          ; +1 HP
    &KeyBucketIncanStatues  ; +1 ATK / +1 DEF
    &KeyBucketDiamondBlock  ; +2 ATK

    &KeyBucketElevatorKey   ; +2 HP
    &KeyBucketMineKeys      ; +2 ATK / +2 DEF
    &KeyBucketCrystalBall   ; +4 HP
    &KeyBucketPurifyStone   ; +0.5 Sec IFrames

    &KeyBucketPalaceKey     ; +4 DEF
    &KeyBucketHopeStatues   ; +2 HP / +2 DEF
    &KeyBucketRamaStatues   ; +4 ATK
    &KeyBucketMagicDust     ; Reduces knockback
    
    &KeyBucketMushroomDrops ; +2 ATK / +2 DEF / +2 HP
    &KeyBucketTeapot        ; Reduces charge time
    &KeyBucketGorgonFlower  ; +3 ATK / +3 DEF
    &KeyBucketHieroglyphs   ; +6 HP
]

KeyBucketPrisonKey [
    key-entry < #00, #02 >  ;Prison Key
]

KeyBucketMeat [
    key-entry < #01, #0A >  ;Meat
]

KeyBucketIncanStatues [
    key-entry < #02, #03 >  ;Incan Statue A
    key-entry < #03, #04 >  ;Incan Statue B
]

KeyBucketDiamondBlock [
    key-entry < #04, #07 >  ;Diamond Block
]

KeyBucketElevatorKey [
    key-entry < #05, #0F >  ;Elevator Key
]

KeyBucketMineKeys [
    key-entry < #06, #0B >  ;Mine Key A
    key-entry < #07, #0C >  ;Mine Key B
]

KeyBucketCrystalBall [
    key-entry < #08, #0E >  ;Crystal Ball
    key-entry < #09, #0E >
    key-entry < #0A, #0E >
    key-entry < #0B, #0E >
]

KeyBucketPurifyStone [
    key-entry < #0C, #11 >  ;Purify Stone
]

KeyBucketPalaceKey [
    key-entry < #0D, #10 >  ;Palace Key
]

KeyBucketHopeStatues [
    key-entry < #0E, #12 >  ;Hope Statue
    key-entry < #0F, #12 >
]

KeyBucketRamaStatues [
    key-entry < #10, #13 >  ;Rama Statue
    key-entry < #11, #13 >
]

KeyBucketMagicDust [
    key-entry < #12, #14 >  ;Magic Dust
]

KeyBucketMushroomDrops [
    key-entry < #13, #1A >  ;Mushroom Drops
    key-entry < #14, #1A >
    key-entry < #15, #1A >
]

KeyBucketTeapot [
    key-entry < #16, #19 >  ;Tearpot
]

KeyBucketGorgonFlower [
    key-entry < #17, #1D >  ;Gorgon Flower
]

KeyBucketHieroglyphs [
    key-entry < #18, #1E >  ;Hieroglyphs
    key-entry < #19, #1F >
    key-entry < #1A, #20 >
    key-entry < #1B, #21 >
    key-entry < #1C, #22 >
    key-entry < #1D, #23 >
]

KeyBucketSizes [
    #01
    #01
    #02
    #01
    #01
    #02
    #04
    #01
    #01
    #02
    #02
    #01
    #03
    #01
    #01
    #06
]

KeyItemRevokeFlags [
    #0000003F
]

---------------------------------------------
;Resolves a bucket index to the next avilable in the bucket
;Accepts: A = item slot index, Y = bucket entry index
;Returns: A = next bucket index, Y = item ID

KeyItemGetNext {
    PHX
    PHY
    PHA
    ASL
    TAX
    LDA $@KeyBucketLookup, X
    SEC
    SBC #&KeyBucketLookup
    STA $0000   ;$0000 now contains the bucket offset

  kign_loop:
    LDA $03, S   ;Get current bucket slot
    BNE kign_continue
    LDA $01, S
    TAX
    LDA $@KeyBucketSizes, X
    AND #$00FF

  kign_continue:
    DEC
    STA $03, S
    ASL
    CLC
    ADC $0000
    TAX

    SEP #$20
    LDA $@KeyBucketLookup, X
    JSR $&KeyItemTestFlag
    REP #$20
    BCC kign_loop

  kign_slot_found:
    LDA $@KeyBucketLookup+1, X
    AND #$00FF
    TAY
    PLA
    PLA
    PLX
    RTL
}

---------------------------------------------
;Tests a key item flag
;Assumes: M == 1, clobbers X, preserves Y
;Accepts: A = flag ID
;Returns: carry set = flag set

KeyItemTestFlag {
    PHX
    PHA
    LSR
    LSR
    LSR
    TAX
    LDA $&key_item_flags, X
    PHA
    LDA $02, S
    AND #$07
    TAX
    LDA $@BitMaskTable, X
    AND $01, S
    BEQ kitf_false

    PLX
    PLX
    SEC
    RTS
    
  kitf_false:
    PLX
    PLX
    CLC
    RTS
}

KeyItemTestFlagWrapper {
    SEP #$20
    JSR $&KeyItemTestFlag
    REP #$20
    RTL
}

---------------------------------------------
;Prepares initialization data for inventory actors
;Assumes M == 1, clobbers Y, preserves X
;Accepts: A = item slot index
;Returns: A = relic count for slot, Y = last item ID
;Side-effect: $0002 = last flagged item index, $0003 = bucket array length

KeyItemCountAndInit {
    PHX
    ASL
    TAX
    LDA $@KeyBucketLookup, X
    SEC
    SBC #&KeyBucketLookup
    TAX
    LDA #$0000
    STA $0000
    STA $0002
    SEP #$20

  kicai_bucket_loop:
    LDA $@KeyBucketLookup, X
    BMI kicai_bucket_end

    JSR $&KeyItemTestFlag
    BCC kicai_flag_continue
    LDA $@KeyBucketLookup+1, X
    STA $0001
    LDA $0003
    STA $0002

  kicai_flag_increment:
    INC $0000

  kicai_flag_continue:
    INX
    INX
    INC $0003
    BRA kicai_bucket_loop

  kicai_bucket_end:
    LDA $0001
    TAY
    LDA $0000
    REP #$20
    PLX
    RTL
}

---------------------------------------------

KeyItemCheckAndStore {
    PHX
    PHA
    TAX  ;This assumes the B register is zero
    LDA $@KeyItemFlagIndex, X
    BPL kic_check_revoke
    
    LDY #$0000
    PLA
    PLX
    CLC
    RTL
    
  kic_inventory_full:
    LDY #$0001
    PLA
    PLA
    PLX
    CLC
    RTL

  kic_check_revoke:
    PHA
    LSR
    LSR
    LSR
    TAX
    LDA $@KeyItemRevokeFlags, X
    TAY
    LDA $01, S
    AND #$07
    TAX
    TYA
    AND $@BitMaskTable, X
    BNE kic_scan_flags

    ;LDA $@KeyItemRevoke
    ;BNE kic_scan_flags
    
    LDA $02, S
    JSL $@InventoryCheckAndStore
    BCS kic_inventory_full

  kic_scan_flags:
    LDA $01, S
    LSR
    LSR
    LSR
    TAY
    LDA $&key_item_flags, Y
    PHA
    LDA $02, S
    AND #$07
    TAX

  kic_set_flag_loop:
    LDA $@BitMaskTable, X
    AND $01, S
    BEQ kic_set_flag_free
    INX
    BRA kic_set_flag_loop
    
  kic_set_flag_free:
    PLA
    ORA $@BitMaskTable, X
    STA $&key_item_flags, Y
    PLA

    PLA
    PLX
    SEC
    RTL
}