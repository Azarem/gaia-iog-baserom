; ==============================================================================
; ElevatorKeyAutoUse - auto-use Elevator Key on the mine elevator door
; ==============================================================================
; What it does: Interacting with the elevator door uses the key immediately when
;   the player carries item #0F or key_item_flags bit $0020 (prior auto-use), via
;   the same path as vanilla success (code_05D66B) without requiring equip.
; Vanilla behavior: dm3F_elevator_door code_05D661 BranchIfItemEquipped (#0F) only;
;   otherwise prints one-keyhole dialog; success removes item and sets flag $69.
; Hooks (overrides): dm3F_elevator_door.code_05D661!.
; Depends on: !key_item_flags $0B58; item #0F; falls through to vanilla code_05D66B.
; State: Flag $69; scene $3F (UseItem_ElevatorKey tile check is separate).
; Hazards/notes: COP interact handler; preserve RTL on failure path.
; ==============================================================================
 
!key_item_flags      0B58

-------------------------------------------

dm3F_elevator_door.code_05D661! {
    LDA $key_item_flags
    BIT #$0020
    BNE code_05D66B
    COP [BranchIfHasItem] ( #0F, &code_05D66B )
    COP [PrintDialogString] ( &dialogstring_05D676 )
    RTL 
}
