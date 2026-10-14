; =============================================================================
; Options Input Remap — Action flag conversion and button mapping persistence
; =============================================================================
;
; Provides the runtime conversion between save-data button mapping bytes
; and the engine's remap word table ($0DA6-$0DB4).
;
; Save data layout ($0B34-$0B39, inside the 508-byte save block):
;   $0B34 = A button actions
;   $0B35 = B button actions
;   $0B36 = X button actions
;   $0B37 = Y button actions
;   $0B38 = L button actions
;   $0B39 = R button actions
;
; Each save byte uses action bit flags:
;   Bit 7: Act/Confirm Bit 6: Cancel      Bit 5: Attack      Bit 4: Run
;   Bit 3: Block1      Bit 2: Block2      Bit 1: Use Item    Bit 0: Cycle Item
;
; joypadCurrent ($0656) action flag layout after remap:
;   Bit 15 ($8000): ACTION_CONFIRM
;   Bit 14 ($4000): ACTION_CANCEL
;   Bit 13 ($2000): Select (fixed)
;   Bit 12 ($1000): Start (fixed)
;   Bits 11-8: D-pad (fixed)
;   Bit 7  ($0080): ACTION_ATTACK
;   Bit 6  ($0040): ACTION_RUN
;   Bit 5  ($0020): ACTION_BLOCK1
;   Bit 4  ($0010): ACTION_BLOCK2
;   Bit 3  ($0008): ACTION_USE_ITEM
;   Bit 2  ($0004): ACTION_CYCLE_ITEM
;   Bits 1-0: Reserved

?BANK 03

!btnMapA                        0B34
!btnMapB                        0B35
!btnMapX                        0B36
!btnMapY                        0B37
!btnMapL                        0B38
!btnMapR                        0B39

; Remap variables — variable name vs physical button is non-obvious:
;   remapA      ($0DAC) -> physical A  ($0080)
;   remapB      ($0DAA) -> physical B  ($8000)
;   remapX      ($0DB0) -> physical X  ($0040)
;   remapY      ($0DAE) -> physical Y  ($4000)
;   remapL      ($0DA8) -> physical L  ($0020)
;   remapR      ($0DA6) -> physical R  ($0010)
;   remapStart  ($0DB2) -> physical Start ($1000) -- passthrough
;   remapSelect ($0DB4) -> physical Select($2000) -- passthrough

!remapR                         0DA6
!remapL                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapX                         0DB0
!remapStart                     0DB2
!remapSelect                    0DB4

---------------------------------------------
; Lookup table: save byte bit position -> joypadCurrent action flag word.
; Indexed by bit position (0-7), each entry is a 16-bit word.
; Bit 0 is shifted out first by LSR, so entry 0 = Cycle Item.

ActionFlagTable [
  #$0004   ;00 bit 0 -> ACTION_CYCLE_ITEM
  #$0008   ;01 bit 1 -> ACTION_USE_ITEM
  #$0010   ;02 bit 2 -> ACTION_BLOCK2
  #$0020   ;03 bit 3 -> ACTION_BLOCK1
  #$0040   ;04 bit 4 -> ACTION_RUN
  #$0080   ;05 bit 5 -> ACTION_ATTACK
  #$4000   ;06 bit 6 -> ACTION_CANCEL
  #$8000   ;07 bit 7 -> ACTION_CONFIRM
]

---------------------------------------------
; Default button mapping bytes — written on new game and old-save detection.
;   A=$A0 (Confirm+Attack), B=$42 (Cancel+UseItem), X=$01 (Cycle Item)
;   Y=$10 (Run), L=$08 (Block2), R=$04 (Block1)

DefaultButtonMap [
  #$A0   ;00 A
  #$42   ;01 B
  #$01   ;02 X
  #$10   ;03 Y
  #$08   ;04 L
  #$04   ;05 R
]

AlternateButtonMap [
  #$10   ;00 A
  #$A0   ;01 B
  #$01   ;02 X
  #$42   ;03 Y
  #$08   ;04 L
  #$04   ;05 R
]

---------------------------------------------
; ConvertActionByte — expand a save byte into a 16-bit remap word.
;
; Entry: A = save byte (low 8 bits valid, high byte ignored)
; Exit:  A = 16-bit remap word
; Clobbers: $00, $02, X

ConvertActionByte {
    AND #$00FF
    STA $0000
    STZ $0002
    LDX #$0000

  cab_loop:
    LSR $0000
    BCC cab_skip
    LDA $@ActionFlagTable, X
    TSB $0002

  cab_skip:
    INX
    INX
    CPX #$0010
    BNE cab_loop
    LDA $0002
    RTS
}

---------------------------------------------
; ApplyButtonMapping — read 6 save bytes and rebuild all remap words.
;
; Called after loading a save, after new game init, and after changing
; a button mapping in the options menu.
;
; Hardcodes Start and Select as passthrough ($1000/$2000).

ApplyButtonMapping {
    PHP
    PHX
    REP #$20

    ; A button -> remapA (physical A $0080)
    LDA $btnMapA
    JSR $&ConvertActionByte
    STA $remapA

    ; B button -> remapB (physical B $8000)
    LDA $btnMapB
    JSR $&ConvertActionByte
    STA $remapB

    ; X button -> remaX (physical X $0040)
    LDA $btnMapX
    JSR $&ConvertActionByte
    STA $remapX

    ; Y button -> remapY (physical Y $4000)
    LDA $btnMapY
    JSR $&ConvertActionByte
    STA $remapY

    ; L button -> remapL (physical L $0020)
    LDA $btnMapL
    JSR $&ConvertActionByte
    STA $remapL

    ; R button -> remapR (physical R $0010)
    LDA $btnMapR
    JSR $&ConvertActionByte
    STA $remapR

    ; Start -> passthrough $1000 (always maps to Start)
    LDA #$1000
    STA $remapStart

    ; Select -> passthrough $2000 (always maps to Select)
    LDA #$2000
    STA $remapSelect

    PLX
    PLP
    RTL
}

---------------------------------------------
; InitDefaultButtonMap — write default mapping bytes to $0B34-$0B39.
;
; Called on new game or when loading an old save without mapping data.

InitDefaultButtonMap {
    PHP
    SEP #$20
    LDX #$0000

  idbm_loop:
    LDA $@DefaultButtonMap, X
    STA $btnMapA, X
    INX
    CPX #$0006
    BNE idbm_loop

    PLP
    RTS
}

---------------------------------------------
; InitAltButtonMap — write default mapping bytes to $0B34-$0B39.
;
; Called on new game or when loading an old save without mapping data.

InitAltButtonMap {
    PHP
    SEP #$20
    LDX #$0000

  iabm_loop:
    LDA $@AlternateButtonMap, X
    STA $btnMapA, X
    INX
    CPX #$0006
    BNE iabm_loop

    PLP
    RTS
}

---------------------------------------------
; DetectAndInitButtonMap — check if save data has button mappings.
; If all 6 bytes at $0B34-$0B39 are zero, assume old save and init defaults.
;
; Entry: called after LoadGameState_Scene returns successfully.

DetectAndInitButtonMap {
    PHP
    REP #$20
    LDA $btnMapA
    AND #$FFFF
    BNE dibm_has_data
    LDA $btnMapX
    AND #$FFFF
    BNE dibm_has_data
    LDA $btnMapL
    AND #$FFFF
    BNE dibm_has_data

    ; All 6 bytes zero — old save, write defaults
    LDA $0B26
    BEQ dibm_init_default
    JSR $&InitAltButtonMap
    BRA dibm_has_data
    
  dibm_init_default:
    JSR $&InitDefaultButtonMap

  dibm_has_data:
    PLP
    RTL
}

