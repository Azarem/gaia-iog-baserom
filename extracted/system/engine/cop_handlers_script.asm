?BANK 00

?INCLUDE 'AsciiStringRenderer'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'MenuSelectionHandler'
?INCLUDE 'system_core'
?INCLUDE 'WideStringRenderer'

!L_wramFlags                    000A80
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRaw                      0660
!displayModeFlags               09EC
!eventFlags                     0A00
!wramFlags                      0A80
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!retPtr1                        7F0004
!chatPtr                        7F000A
!loopCounter                    7F0014
!retPtr2                        7F001E
!enemyNum                       7F0022
!loopStartPcActor               7F2100
!loopCounterActor               7F2102

---------------------------------------------

WaitForButton {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009498
    BIT $joypadCurrent
    BNE loc_00949D
    BRA loc_0094A2

  loc_009498:
    BIT $joypadRaw
    BEQ loc_0094A2

  loc_00949D:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094A2:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

WaitForRelease {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094C0
    BIT $joypadCurrent
    BEQ loc_0094C5
    BRA loc_0094CA

  loc_0094C0:
    BIT $joypadRaw
    BNE loc_0094CA

  loc_0094C5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094CA:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

BranchIfPressed {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094E8
    BIT $joypadCurrent
    BNE loc_0094F8
    BRA loc_0094ED

  loc_0094E8:
    BIT $joypadRaw
    BNE loc_0094F8

  loc_0094ED:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0094F8:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfNotPressed {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009514
    BIT $joypadCurrent
    BEQ loc_00951B
    BRA loc_009524

  loc_009514:
    BIT $joypadRaw
    BEQ loc_00951B
    BRA loc_009524

  loc_00951B:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009524:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

StageWorldMapMove {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    STZ $0D58
    LDA $0A
    STA $02, S
    RTI 
}

StageWorldMapChoice {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D58
    LDA $0A
    STA $02, S
    RTI 
}

StageWorldMapMoveIds {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

RunBg3Script {
    PHY 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    JSL $@AsciiStringRenderer
    PLB 
    PLA 
    TAX 
    TCD 
    LDA #$0001
    TSB $displayModeFlags
    LDA $0A
    STA $02, S
    RTI 
}

DialogueOptions {
    TYX 
    LDA $worldReadyFlag
    CMP #$000F
    BEQ loc_00A8A6
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00A8A6:
    LDA #$2000
    TSB $displayModeFlags
    LDA #$0F00
    STA $joypadMaskInv
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@MenuSelectionHandler
    ASL 
    PHA 
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $01, S
    TAY 
    PLA 
    PLA 
    TSB $10
    PLA 
    STA $joypadMaskStd
    STZ $joypadMaskInv
    LDA #$2000
    TRB $displayModeFlags
    LDA $0000, Y
    PLB 
    STA $02, S
    RTI 
}

PrintWideString {
    TYX 
    LDA #$2000
    TSB $displayModeFlags
    LDA $0A
    PHA 
    SEP #$20
    LDA $0C
    PHA 
    JSL $@system_core.UpdateFrameRender
    PLA 
    STA $0C
    REP #$20
    PLA 
    STA $0A
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@WideStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd
    TRB $joypadCurrent
    LDA #$0F00
    TRB $joypadHeld
    LDA #$2000
    TRB $displayModeFlags
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

PrintWideStringAlt {
    TYX 
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@WideStringRenderer
    PLB 
    PLA 
    STA $joypadMaskStd
    LDA #$0F00
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

SetInteractHandler {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $chatPtr, X
    LDA $0A
    STA $02, S
    RTI 
}

SetEntryHere {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

SetEntryHereAndYield {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

JumpAfterDelay {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    LDA [$0A]
    INC $0A
    INC $0A
    STA $08
    PLA 
    PLA 
    RTL 
}

JumpNextFrame {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    PLA 
    PLA 
    RTL 
}

SetEntryFar {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    LDA $0A
    STA $02, S
    RTI 
}

RestoreSavedPtr {
    TYX 
    LDA $retPtr1, X
    BEQ loc_00AA71
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    RTI 

  loc_00AA71:
    PLA 
    PLA 
    RTL 
}

ReturnWithSignal {
    TYX 
    LDA $retPtr1, X
    BEQ loc_00AA88
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    LDA #$FFFF
    RTI 

  loc_00AA88:
    PLA 
    PLA 
    RTL 
}

SetSavedPtr {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $retPtr1, X
    LDA $0A
    STA $02, S
    RTI 
}

JumpFar {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    STA $02, S
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $02
    STA $04, S
    REP #$20
    RTI 
}

CallNear {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    LDA $0A
    STA $retPtr1, X
    RTI 
}

CallNearDeferred {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA $0A
    STA $retPtr1, X
    PLA 
    PLA 
    RTL 
}

LoopStart {
    TYX 
    CPX #$1000
    BCC loc_00AAF6
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounter, X
    LDA $0A
    STA $retPtr2, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 

  loc_00AAF6:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounterActor, X
    LDA $0A
    STA $loopStartPcActor, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 
}

LoopEnd {
    TYX 
    CPX #$1000
    BCC loc_00AB2D
    LDA $loopCounter, X
    DEC 
    BEQ loc_00AB28
    STA $loopCounter, X
    LDA $retPtr2, X
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00AB28:
    LDA $0A
    STA $02, S
    RTI 

  loc_00AB2D:
    LDA $loopCounterActor, X
    DEC 
    BEQ loc_00AB28
    STA $loopCounterActor, X
    LDA $loopStartPcActor, X
    STA $00
    PLA 
    PLA 
    RTL 
}

SetFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&SetEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

SetFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&SetEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

ClearFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ClearEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

ClearFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&ClearEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

BranchOnFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&TestEventFlag
    BCS loc_00ABA5
    BCC loc_00AB9A
}

BranchOnFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&TestEventFlag
    BCS loc_00ABA5

  loc_00AB9A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00ABB7
    BRA loc_00ABAE

  loc_00ABA5:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00ABB7

  loc_00ABAE:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_00ABB7:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

WaitOnFlagByte {
    TYX 
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&TestEventFlag
    BCS loc_00ABF4
    BCC loc_00ABE9
}

WaitOnFlagWord {
    TYX 
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&TestEventFlag
    BCS loc_00ABF4

  loc_00ABE9:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00AC00
    BRA loc_00ABFD

  loc_00ABF4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00AC00

  loc_00ABFD:
    PLA 
    PLA 
    RTL 

  loc_00AC00:
    LDA $0A
    STA $02, S
    RTI 
}

GiveItem {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS loc_00AC1E
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC1E:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

RemoveItem {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.RemoveItemFromInventory
    LDA $0A
    STA $02, S
    RTI 
}

BranchIfMissingItem {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem
    BCC loc_00AC51
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC51:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfItemEquipped {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    LDY $inventoryEquippedIndex
    CMP $inventorySlots, Y
    REP #$20
    BEQ loc_00AC79
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC79:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

SetDungeonKillFlag {
    TYX 
    LDA $enemyNum, X
    AND #$00FF
    BEQ loc_00AC8F
    JSR $&SetWramFlag

  loc_00AC8F:
    LDA $0A
    STA $02, S
    RTI 
}

SwitchCase {
    LDA [$0A]
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X
    AND #$00FF
    ASL 
    STA $0000
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0000
    TAX 
    LDA $0000, X
    PLB 
    TYX 
    STA $02, S
    RTI 
}

WaitByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00ACC9:
    STA $08
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

WaitWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BRA loc_00ACC9
}
---------------------------------------------

TestWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&TestWramFlag
    RTL 
}

SetWramFlag_Offset100 {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&SetWramFlag
    RTL 
}

SetWramFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $wramFlags, Y
    ORA $@bitmasks_bit_position, X
    STA $wramFlags, Y
    REP #$20
    PLX 
    RTS 
}

TestWramFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X
    AND $wramFlags, Y
    SEC 
    BNE loc_00B0B3
    CLC 

  loc_00B0B3:
    REP #$20
    PLX 
    RTS 
}

SetEventFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $eventFlags, Y
    ORA $@bitmasks_bit_position, X
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

ClearEventFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X
    EOR #$FF
    AND $eventFlags, Y
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

TestEventFlag {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@bitmasks_bit_position, X
    AND $eventFlags, Y
    SEC 
    BNE loc_00B119
    CLC 

  loc_00B119:
    REP #$20
    PLX 
    RTS 
}

bitmasks_bit_position [
  #01   ;00
  #02   ;01
  #04   ;02
  #08   ;03
  #10   ;04
  #20   ;05
  #40   ;06
  #80   ;07
]
---------------------------------------------

SetEventFlag_0200 {
    CLC 
    ADC #$0200
    JSR $&SetEventFlag
    RTL 
}

TestEventFlag_0200 {
    REP #$20
    AND #$00FF
    CLC 
    ADC #$0200
    JSR $&TestEventFlag
    RTL 
}

TestFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&TestEventFlag
    RTL 
}

SetFlag_0300 {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&SetEventFlag
    RTL 
}

TestFlag_0510 {
    AND #$00FF
    CLC 
    ADC #$0510
    JSR $&TestEventFlag
    RTL 
}

TestFlagRaw {
    AND #$00FF
    JSR $&TestEventFlag
    RTL 
}

SetFlagRaw {
    AND #$00FF
    JSR $&SetEventFlag
    RTL 
}

ClearFlagRaw {
    AND #$00FF
    JSR $&ClearEventFlag
    RTL 
}

ClearAllWramFlags {
    PHX 
    LDX #$0000
    LDA #$0000

  loc_00B4D3:
    STA $L_wramFlags, X
    INX 
    INX 
    CPX #$0020
    BNE loc_00B4D3
    PLX 
    RTL 
}

SetFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&SetEventFlag
    RTL 
}

ClearFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&ClearEventFlag
    RTL 
}

TestFlag_0100 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&TestEventFlag
    RTL 
}