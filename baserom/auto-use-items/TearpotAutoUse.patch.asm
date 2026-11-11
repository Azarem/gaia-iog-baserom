; ==============================================================================
; Teapot auto-use (Euro scene $95, Neil's mother) - statue interact + use stub
; ==============================================================================
; What it does: Neil's mother interact (code_07E316) checks Teapot (#19) or
;   key_item_flags+2 bit $40, then JML eu95_neils_mother_use_stub which shows
;   try dialog and JSR vanilla code_039856 (pour tears, remove item, flag #A8).
; Vanilla behavior: code_07E316 only prints Neil's mother dialog and RTL;
;   Teapot use from inventory requires scene $95 and tile box via UseItem_Teapot.
; Hooks (overrides): eu95_neils_mother.code_07E316! adds key-item gate + stub
;   jump; item_use_system.code_039856+ adds eu95_neils_mother_use_stub entry.
; Adds: eu95_neils_mother_use, eu95_neils_mother_use_stub (JSR code_039856, RTL).
; Depends on: !key_item_flags $0B58; dialogstring_07E31B/039861/039890; flag #A8.
; State: Item #19 Teapot; key_item_flags+2 $0040; actor blocks until flag #A8
;   (vanilla eu95_neils_mother parent actor).
; Hazards/notes: Stub runs item handler without ItemUseStub long-address load;
;   COP interact on mother actor needs X=actor slot.
; ==============================================================================

!key_item_flags      0B58

----------------------------------------------

eu95_neils_mother.code_07E316! {
    LDA $key_item_flags+2
    BIT #$0040
    BNE eu95_neils_mother_use
    COP [BranchIfHasItem] ( #19, &eu95_neils_mother_use )
    COP [PrintDialogString] ( &dialogstring_07E31B )
    RTL 
}

eu95_neils_mother_use {
    JML $@eu95_neils_mother_use_stub
}

item_use_system.code_039856+ {
  eu95_neils_mother_use_stub:
    COP [PrintDialogString] ( &dialogstring_039861 )
    JSR $&code_039856
    RTL
}
