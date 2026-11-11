; ==============================================================================
; IncanStatueAutoUse - auto-place Inca statues on Larai cliff mantels
; ==============================================================================
; What it does: Mantel actors A/B gain interact handlers; with statues #03/#04 or
;   key_item_flags bits $0004/$0008, calls ItemUseStub to the matching UseItem_Inca
;   handler entry (loc_0386B3 / loc_0387C9) instead of opening the item menu.
; Vanilla behavior: ir1E_cliff_mantel_a/b wait on flags $30/$31, no interact;
;   placement only via inventory tile checks in item_use_system.
; Hooks (overrides): ir1E_cliff_mantel_a.code_09C550!; ir1E_cliff_mantel_b.code_09C566!.
; Adds: isau_interact_a/b, isau_use_a/b, isau_interact_str_a; B reuses A stub dialog.
; Depends on: !key_item_flags $0B58; $@ItemUseStub; items #03, #04.
; State: Flags $30, $31; actor $10 bit $2000 cleared after placement wait.
; Hazards/notes: X = actor slot for COP; SetSpritePriority #30 on mantels.
; ==============================================================================

!key_item_flags      0B58

------------------------------------------------

ir1E_cliff_mantel_a.code_09C550! {
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [SetInteractHandler] ( &isau_interact_a )
    COP [WaitOnFlagByte] ( #30, #01 )
    COP [SetInteractHandler] ( #$0000 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

isau_interact_a {
    LDA $key_item_flags
    BIT #$0004
    BNE isau_use_a
    COP [BranchIfHasItem] ( #03, &isau_use_a )

  isau_interact_a_stub:
    COP [PrintDialogString] ( &isau_interact_str_a )
    RTL
}

isau_use_a {
    LDA #&loc_0386B3
    JML $@ItemUseStub
}

isau_interact_str_a `[DEF]There is a strange[N]mantel here. It's as if[N]something were missing...[END]`

------------------------------------------------

ir1E_cliff_mantel_b.code_09C566! {
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [SetInteractHandler] ( &isau_interact_b )
    COP [WaitOnFlagByte] ( #31, #01 )
    COP [SetInteractHandler] ( #$0000 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

isau_interact_b {
    LDA $key_item_flags
    BIT #$0008
    BNE isau_use_b
    COP [BranchIfHasItem] ( #04, &isau_use_b )
    JML $@isau_interact_a_stub
}

isau_use_b {
    LDA #&loc_0387C9
    JML $@ItemUseStub
}
