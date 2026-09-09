?BANK 02

?INCLUDE 'cop_handlers_script'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'system_strings'

!joypadHeld                     0658
!displayModeFlags               09EC
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!characterForm                  0AD4
!bg1ConfigMode                  0AE6
!itemAbilityIndex               0AE8
!inventoryTabIndex              0AFA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

InventoryMenuDef [
  actor-def < #00, #00, #28, {

  InventoryMenuInit:
    COP [SetMetasprite] ( @inventory_spritemap )
    COP [RunBg3Script] ( @system_strings.asciistring_01E869 )
    STZ $inventoryTabIndex
    LDA #$000F
    STA $24

  loc_02E3AB:
    COP [SpawnAfterFlags] ( @InventorySlotActor, #$1800 )
    PHY 
    LDY $24
    LDA $inventorySlots, Y
    AND #$00FF
    PLY 
    STA $0028, Y
    DEC $24
    BPL loc_02E3AB
    TYA 
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @EquipCursorActor, #$0802 )
    TYA 
    STA $orbitDiameter, X
    LDA $inventoryEquippedIndex
    STA $1A
    JSR $&PositionEquipCursor
    COP [SpawnAfterFlags] ( @EquippedItemDisplay, #$0800 )
    TYA 
    STA $moveXAlt, X
    COP [SpawnAfterFlags] ( @StatusCharRow1, #$0800 )
    COP [SpawnAfterFlags] ( @StatusCharRow2, #$0800 )
    COP [SpawnAfterFlags] ( @StatusCharRow3, #$0800 )
    TYA 
    STA $moveYAlt, X
    COP [SetEntryExit]
    STZ $inventoryTabIndex
    LDA #$1000
    TSB $10

  InventoryMainLoop:
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01E8E9 )
    STZ $1C
    LDA #$FFFF
    STA $18
    LDA #$8000
    TSB $joypadHeld
    COP [SetEntryExit]
    JSR $&TabSelectionLoop
    BCS TabConfirmDispatch
    LDA $inventoryTabIndex
    CMP $18
    BNE loc_02E432
    RTL 

  loc_02E432:
    STA $18
    STA $0000
    COP [SwitchCase] ( #$0000, &TabHoverDispatch )
} >
]

TabHoverDispatch [
  &TabHoverUse   ;00
  &TabHoverArrange   ;01
  &TabHoverDiscard   ;02
  &TabHoverStatus   ;03
]

TabConfirmDispatch {
    COP [PlaySoundCh2] ( #0D )
    LDA $inventoryTabIndex
    STA $18
    STA $0000
    COP [SwitchCase] ( #$0000, &TabActionDispatch )
}

TabActionDispatch [
  &UseItemTab   ;00
  &ArrangeItemsTab   ;01
  &DiscardItemTab   ;02
  &StatusViewTab   ;03
]

UseItemTab {
    LDA #$0004
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA02 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E975 )
    STZ $inventoryEquippedIndex
    JSR $&ShowEquipCursor
    LDA $1A
    BPL code_02E47F
    STZ $1A

  code_02E47F:
    JSR $&PositionEquipCursor
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    LDY $1A
    LDA $inventorySlots, Y
    AND #$00FF
    STA $itemAbilityIndex
    COP [RunBg3Script] ( @system_strings.asciistring_01E9D0 )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$C040, &UseItemConfirm )
    COP [BranchIfButton] ( #$0800, &UseItemCursorUp )
    COP [BranchIfButton] ( #$0400, &UseItemCursorDown )
    COP [BranchIfButton] ( #$0200, &UseItemCursorLeft )
    COP [BranchIfButton] ( #$0100, &UseItemCursorRight )
    RTL 
}

UseItemCursorUp {
    LDA #$0B00
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    SEC 
    SBC #$0004
    AND #$000F
    STA $1A
    BRA code_02E47F
}

UseItemCursorDown {
    LDA #$0700
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    CLC 
    ADC #$0004
    AND #$000F
    STA $1A
    BRA code_02E47F
}

UseItemCursorLeft {
    LDA #$0200
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    DEC 
    AND #$000F
    STA $1A
    BRA code_02E47F
}

UseItemCursorRight {
    LDA #$0100
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    INC 
    AND #$000F
    STA $1A
    JMP $&code_02E47F
}

UseItemConfirm {
    LDA #$C040
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )
    LDA $1A
    STA $inventoryEquippedIndex
    TAY 
    LDA $inventorySlots, Y
    AND #$00FF
    BNE loc_02E530
    LDA #$FFFF
    STA $inventoryEquippedIndex
    STA $1A
    STZ $inventoryEquippedType
    JMP $&InventoryMainLoop

  loc_02E530:
    STA $inventoryEquippedType
    JMP $&InventoryMainLoop
}

ArrangeItemsTab {
    JSR $&HideEquipCursor
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22

  code_02E544:
    STZ $1C
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA14 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E98C )

  code_02E555:
    JSR $&PositionGridCursor
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &ArrangeCancelTab )
    COP [BranchIfButton] ( #$8000, &ArrangePickTarget )
    PEA $&code_02E555-1
    COP [BranchIfButton] ( #$0800, &GridCursorUp )
    COP [BranchIfButton] ( #$0400, &GridCursorDown )
    COP [BranchIfButton] ( #$0200, &GridCursorLeft )
    COP [BranchIfButton] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

ArrangePickTarget {
    COP [PlaySoundCh2] ( #11 )
    LDA #$8000
    TSB $joypadHeld
    LDA $20
    STA $2C
    LDA $22
    STA $2E
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA14 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E9A6 )

  code_02E5AC:
    JSR $&PositionGridCursor
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &ArrangeCancelTarget )
    COP [BranchIfButton] ( #$8000, &ArrangePerformSwap )
    PEA $&code_02E5AC-1
    COP [BranchIfButton] ( #$0800, &GridCursorUp )
    COP [BranchIfButton] ( #$0400, &GridCursorDown )
    COP [BranchIfButton] ( #$0200, &GridCursorLeft )
    COP [BranchIfButton] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

ArrangePerformSwap {
    LDA #$8000
    TSB $joypadHeld
    LDA $22
    CMP $2E
    BEQ code_02E5AC
    COP [PlaySoundCh2] ( #11 )
    LDY $22
    SEP #$20
    LDA $inventorySlots, Y
    XBA 
    LDY $2E
    LDA $inventorySlots, Y
    XBA 
    STA $inventorySlots, Y
    XBA 
    LDY $22
    STA $inventorySlots, Y
    REP #$20
    LDY $2E
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite
    PLA 
    STA $0028, Y
    LDY $22
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite
    PLA 
    STA $0028, Y
    TYA 
    CMP $inventoryEquippedIndex
    BNE loc_02E631
    LDA $2E
    STA $inventoryEquippedIndex
    BRA loc_02E63D

  loc_02E631:
    LDA $2E
    CMP $inventoryEquippedIndex
    BNE loc_02E63D
    LDA $22
    STA $inventoryEquippedIndex

  loc_02E63D:
    PHX 
    PHD 
    LDA $2C
    TAX 
    TCD 
    COP [MarkDeath]
    PLD 
    PLX 
    JMP $&code_02E544
}

ArrangeCancelTarget {
    COP [KillNext]
}

ArrangeCancelTab {
    COP [KillNext]
    LDA #$4040
    TSB $joypadHeld
    JMP $&InventoryMainLoop
}

DiscardItemTab {
    LDA #$0004
    STA $bg1ConfigMode
    JSR $&HideEquipCursor
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22

  code_02E66B:
    STZ $1C
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA27 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E9B7 )

  code_02E67C:
    JSR $&PositionGridCursor
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &DiscardCancelTab )
    COP [BranchIfButton] ( #$8000, &code_02E6AA )
    PEA $&code_02E67C-1
    COP [BranchIfButton] ( #$0800, &GridCursorUp )
    COP [BranchIfButton] ( #$0400, &GridCursorDown )
    COP [BranchIfButton] ( #$0200, &GridCursorLeft )
    COP [BranchIfButton] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

code_02E6AA {
    LDA #$8000
    TSB $joypadHeld
    LDY $22
    LDA $inventorySlots, Y
    AND #$00FF
    BEQ loc_02E705
    STA $itemAbilityIndex
    JSR $&CheckItemDiscardable
    BCS loc_02E705
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E9E2 )
    STZ $28
    COP [SetEntryExit]
    JSR $&YesNoPromptLoop
    BCS loc_02E6D6
    RTL 

  loc_02E6D6:
    LDA $28
    BEQ loc_02E702
    LDY $22
    LDA $inventorySlots, Y
    AND #$FF00
    STA $inventorySlots, Y
    LDA $22
    JSR $&UpdateSlotActorSprite
    LDA $22
    CMP $inventoryEquippedIndex
    BNE loc_02E6FC
    STZ $inventoryEquippedType
    LDA #$FFFF
    STA $inventoryEquippedIndex
    STA $1A

  loc_02E6FC:
    COP [PlaySoundCh2] ( #13 )
    JMP $&code_02E66B

  loc_02E702:
    JMP $&code_02E66B

  loc_02E705:
    COP [PlaySoundCh2] ( #12 )
    JMP $&code_02E66B
}

DiscardCancelTab {
    LDA #$4040
    TSB $joypadHeld
    COP [KillNext]
    JSR $&ShowEquipCursor
    JMP $&InventoryMainLoop
}

StatusViewTab {
    LDA #$0000
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.asciistring_01E90B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA39 )
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22

  loc_02E734:
    JSR $&StatusPositionCursor
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    LDA $characterForm
    STA $0004
    LDA $22
    JSR $&TestAbilityFlag
    BCC loc_02E753
    LDA $22
    JSR $&ComputeAbilityIndex
    COP [RunBg3Script] ( @system_strings.asciistring_01EAB4 )

  loc_02E753:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &StatusCursorUp )
    COP [BranchIfButton] ( #$0400, &StatusCursorDown )
    COP [BranchIfButton] ( #$C040, &StatusConfirmExit )
    RTL 
}

StatusCursorUp {
    LDA #$0800
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC 
    BPL loc_02E779
    LDA #$0002

  loc_02E779:
    STA $22
    BRA loc_02E734
}

StatusCursorDown {
    LDA #$0400
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC 
    CMP #$0003
    BCC loc_02E791
    LDA #$0000

  loc_02E791:
    STA $22
    BRA loc_02E734
}

StatusConfirmExit {
    COP [PlaySoundCh2] ( #11 )
    LDA #$C040
    TSB $joypadHeld
    COP [KillNext]
    JMP $&InventoryMainLoop
}

StatusPositionCursor {
    PHX 
    LDY $20
    LDA $22
    ASL 
    ASL 
    TAX 
    LDA $@StatusCursorPositions, X
    STA $0014, Y
    LDA $@StatusCursorPositions+2, X
    STA $0016, Y
    PLX 
    RTS 
}

StatusCursorPositions [
  screen-pos < #$0098, #$0048 >   ;00
  screen-pos < #$0098, #$0060 >   ;01
  screen-pos < #$0098, #$0078 >   ;02
]

TabHoverUse {
    JSR $&HideAllItemSlots
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors
    COP [RunBg3Script] ( @system_strings.asciistring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E919 )
    LDA #$0004
    STA $bg1ConfigMode
    RTL 
}

TabHoverArrange {
    JSR $&HideAllItemSlots
    JSR $&ShowEquipCursor
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E954 )
    RTL 
}

TabHoverDiscard {
    JSR $&HideAllItemSlots
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E962 )
    LDA #$0004
    STA $bg1ConfigMode
    RTL 
}

TabHoverStatus {
    JSR $&ShowAllItemSlots
    JSR $&HideEquipCursor
    COP [RunBg3Script] ( @system_strings.asciistring_01E912 )
    COP [RunBg3Script] ( @system_strings.asciistring_01E870 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EA70 )
    LDA #$0000
    STA $bg1ConfigMode
    LDA $moveXAlt, X
    TAY 
    LDA $inventoryEquippedIndex
    BMI loc_02E84A
    LDA $inventoryEquippedType
    JSR $&SetSlotSprite
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_02E84A:
    LDA $moveYAlt, X
    STA $0002
    LDA $characterForm
    STA $0004
    LDA #$0000
    JSR $&TestAbilityFlag
    BCC loc_02E876
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0000
    JSR $&ComputeAbilityIndex
    COP [RunBg3Script] ( @system_strings.asciistring_01EA49 )

  loc_02E876:
    LDY $0002
    LDA $0006, Y
    STA $0002
    LDA #$0001
    JSR $&TestAbilityFlag
    BCC loc_02E89E
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0001
    JSR $&ComputeAbilityIndex
    COP [RunBg3Script] ( @system_strings.asciistring_01EA56 )

  loc_02E89E:
    LDY $0002
    LDA $0006, Y
    STA $0002
    LDA #$0002
    JSR $&TestAbilityFlag
    BCC loc_02E8C6
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0002
    JSR $&ComputeAbilityIndex
    COP [RunBg3Script] ( @system_strings.asciistring_01EA63 )

  loc_02E8C6:
    RTL 
}

InventorySlotActor {
    INC $inventoryTabIndex
    JSR $&ComputeSlotPosition

  loc_02E8CD:
    COP [SetEntryContinue]
    LDA $28
    BNE loc_02E8D9
    LDA #$2000
    TSB $10
    RTL 

  loc_02E8D9:
    LDA #$2000
    TRB $10

  loc_02E8DE:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8DE
    RTL 
}

EquipCursorActor {
    LDA $inventoryEquippedIndex
    BPL SelectionCursorActor
    LDA #$2000
    TSB $10
}

SelectionCursorActor {
    COP [StageSprAndHitbox] ( #40 )
    COP [SetEntryExit]

  loc_02E8F6:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8F6
    RTL 
}

EquippedItemDisplay {
    LDA #$0028
    STA $14
    LDA #$0078
    STA $16
    LDA $inventoryEquippedType
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

StatusCharRow3 {
    LDA #$0098
    STA $14
    LDA #$0048
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0044
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

StatusCharRow2 {
    LDA #$0098
    STA $14
    LDA #$0060
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0045
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

StatusCharRow1 {
    LDA #$0098
    STA $14
    LDA #$0078
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0046
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

ComputeAbilityIndex {
    PHA 
    LDA $characterForm
    ASL 
    ASL 
    CLC 
    ADC $01, S
    INC 
    STA $itemAbilityIndex
    PLA 
    RTS 
}

GridCursorUp {
    LDA #$0B00
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    SEC 
    SBC #$0004
    AND #$000F
    STA $22
    RTS 
}

GridCursorDown {
    LDA #$0700
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    CLC 
    ADC #$0004
    AND #$000F
    STA $22
    RTS 
}

GridCursorLeft {
    LDA #$0200
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC 
    AND #$000F
    STA $22
    RTS 
}

GridCursorRight {
    LDA #$0100
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC 
    AND #$000F
    STA $22
    RTS 
}

SetSlotSprite {
    STA $0028, Y
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    RTS 
}

TestAbilityFlag {
    PHA 
    LDA $0004
    ASL 
    ASL 
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    JSL $@cop_handlers_script.TestFlag_0510
    RTS 
}

UpdateSlotActorSprite {
    STA $000E
    LDA $orbitAngle, X
    TAY 

  loc_02E9F5:
    DEC $000E
    BMI loc_02EA00
    LDA $0006, Y
    TAY 
    BRA loc_02E9F5

  loc_02EA00:
    LDA #$&loc_02E8CD
    STA $0000, Y
    LDA #$0000
    STA $0028, Y
    STA $0008, Y
    STA $002A, Y
    RTS 
}

CheckItemDiscardable {
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
    LDA $@BitMaskTable, X
    AND $&system_strings.binary_01E12A, Y
    SEC 
    BNE loc_02EA31
    CLC 

  loc_02EA31:
    REP #$20
    PLX 
    RTS 
}

BitMaskTable [
  #01   ;00
  #02   ;01
  #04   ;02
  #08   ;03
  #10   ;04
  #20   ;05
  #40   ;06
  #80   ;07
]

PositionGridCursor {
    LDA $22
    STA $0000
    LDY $20
    BRA loc_02EA4D

  loc_02EA46:
    LDA $2E
    STA $0000
    LDY $2C

  loc_02EA4D:
    PHX 
    LDA $0000
    ASL 
    ASL 
    PHA 
    AND #$000C
    TAX 
    LDA #$0030
    AND $01, S
    STA $01, S
    LDA $@GridColumnPositions, X
    STA $0014, Y
    LDA $@GridColumnPositions+2, X
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 
}

PositionEquipCursor {
    LDA $1A
    BMI loc_02EAA1
    PHX 
    LDA $orbitDiameter, X
    TAY 
    LDA $1A
    ASL 
    ASL 
    PHA 
    AND #$000C
    TAX 
    LDA #$0030
    AND $01, S
    STA $01, S
    LDA $@GridColumnPositions, X
    STA $0014, Y
    LDA $@GridColumnPositions+2, X
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 

  loc_02EAA1:
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

GridColumnPositions [
  screen-pos < #$005C, #$0030 >   ;00
  screen-pos < #$0074, #$0030 >   ;01
  screen-pos < #$008C, #$0030 >   ;02
  screen-pos < #$00A4, #$0030 >   ;03
]

HideStatusActors {
    LDA $moveXAlt, X
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $moveYAlt, X
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

ShowEquipCursor {
    LDA $inventoryEquippedIndex
    BMI HideEquipCursor
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    RTS 
}

HideEquipCursor {
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

HideAllItemSlots {
    LDA $10
    BIT #$1000
    BEQ loc_02EB22
    RTS 

  loc_02EB22:
    LDA #$1000
    TSB $10
    LDA #$000F
    STA $0000
    LDA $orbitAngle, X
    TAY 

  loc_02EB32:
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02EB32
    RTS 
}

ShowAllItemSlots {
    LDA $10
    BIT #$1000
    BNE loc_02EB4D
    RTS 

  loc_02EB4D:
    LDA #$1000
    TRB $10
    LDA #$000F
    STA $0000
    LDA $orbitAngle, X
    TAY 

  loc_02EB5D:
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02EB5D
    RTS 
}

ComputeSlotPosition {
    PHX 
    LDA $inventoryTabIndex
    DEC 
    ASL 
    ASL 
    TAX 
    LDA $@SlotPositionTable, X
    STA $14
    LDA $@SlotPositionTable+2, X
    STA $16
    PLX 
    RTS 
}

SlotPositionTable [
  screen-pos < #$005C, #$0031 >   ;00
  screen-pos < #$0074, #$0031 >   ;01
  screen-pos < #$008C, #$0031 >   ;02
  screen-pos < #$00A4, #$0031 >   ;03
  screen-pos < #$005C, #$0041 >   ;04
  screen-pos < #$0074, #$0041 >   ;05
  screen-pos < #$008C, #$0041 >   ;06
  screen-pos < #$00A4, #$0041 >   ;07
  screen-pos < #$005C, #$0051 >   ;08
  screen-pos < #$0074, #$0051 >   ;09
  screen-pos < #$008C, #$0051 >   ;0A
  screen-pos < #$00A4, #$0051 >   ;0B
  screen-pos < #$005C, #$0061 >   ;0C
  screen-pos < #$0074, #$0061 >   ;0D
  screen-pos < #$008C, #$0061 >   ;0E
  screen-pos < #$00A4, #$0061 >   ;0F
]

YesNoPromptLoop {
    COP [BranchIfButton] ( #$8000, &YesNoConfirm )
    COP [BranchIfButton] ( #$0800, &YesNoSelectUp )
    COP [BranchIfButton] ( #$0400, &YesNoSelectDown )
    LDA $1C
    INC $1C
    BIT #$000F
    BEQ loc_02EBE3
    CLC 
    RTS 

  loc_02EBE3:
    BIT #$0010
    BNE loc_02EBED
    JSR $&YesNoDrawCursor
    CLC 
    RTS 

  loc_02EBED:
    JSR $&YesNoClearCursor
    CLC 
    RTS 
}

YesNoSelectUp {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0800
    TSB $joypadHeld
    LDA $28
    DEC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&YesNoDrawCursor
    CLC 
    RTS 
}

YesNoSelectDown {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0400
    TSB $joypadHeld
    LDA $28
    INC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&YesNoDrawCursor
    CLC 
    RTS 
}

YesNoConfirm {
    LDA #$8000
    TSB $joypadHeld
    JSR $&YesNoDrawCursor
    SEC 
    RTS 
}

YesNoDrawCursor {
    JSR $&YesNoClearCursor
    PHX 
    LDA $28
    AND #$00FF
    XBA 
    LSR 
    CLC 
    ADC #$0696
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    RTS 
}

YesNoClearCursor {
    LDA #$0001
    TSB $displayModeFlags
    LDA #$2040
    STA $7F0896
    STA $7F0916
    RTS 
}

TabSelectionLoop {
    COP [BranchIfButton] ( #$8000, &TabConfirm )
    COP [BranchIfButton] ( #$0800, &TabSelectUp )
    COP [BranchIfButton] ( #$0400, &TabSelectDown )
    COP [BranchIfButton] ( #$6040, &TabCancel )
    LDA $1C
    INC $1C
    BIT #$000F
    BEQ loc_02EC7B
    CLC 
    RTS 

  loc_02EC7B:
    BIT #$0010
    BNE loc_02EC85
    JSR $&TabDrawCursor
    CLC 
    RTS 

  loc_02EC85:
    JSR $&TabClearCursor
    CLC 
    RTS 
}

TabSelectUp {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0800
    TSB $joypadHeld
    STZ $1C
    LDA $inventoryTabIndex
    DEC 
    AND #$0003
    STA $inventoryTabIndex
    JSR $&TabDrawCursor
    CLC 
    RTS 
}

TabSelectDown {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0400
    TSB $joypadHeld
    STZ $1C
    LDA $inventoryTabIndex
    INC 
    AND #$0003
    STA $inventoryTabIndex
    JSR $&TabDrawCursor
    CLC 
    RTS 
}

TabCancel {
    COP [SetFlagByte] ( #00 )
    CLC 
    RTS 
}

TabConfirm {
    LDA #$8000
    TSB $joypadHeld
    JSR $&TabDrawCursor
    SEC 
    RTS 
}

TabDrawCursor {
    JSR $&TabClearCursor
    PHX 
    LDA $inventoryTabIndex
    AND #$00FF
    XBA 
    LSR 
    CLC 
    ADC #$0584
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    RTS 
}

TabClearCursor {
    LDA #$0001
    TSB $displayModeFlags
    LDA #$2040
    STA $7F0784
    STA $7F0804
    STA $7F0884
    STA $7F0904
    RTS 
}