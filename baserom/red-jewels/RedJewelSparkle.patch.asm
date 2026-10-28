
!activator_type      001C

-----------------------------------
;hidden_red_jewel

code_00C672- {
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS hidden_red_jewel_destroy
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFFC )
    STY $26
}

code_00C672+ {
  hidden_red_jewel_destroy:
    COP [Die]
    
}

HiddenRedJewelInteract! {
    COP [GiveItem] ( #01, &HiddenRedJewelInventoryFull )
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@flag_helpers.SetEventFlag_0200

  hrji_complete:
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &HiddenRedJewelFoundString )
    COP [Die]
}
