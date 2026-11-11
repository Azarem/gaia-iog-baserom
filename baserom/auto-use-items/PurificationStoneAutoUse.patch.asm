; ==============================================================================
; Purification Stone auto-use (Seaside Palace fountain) - sp5D_fountain hook
; ==============================================================================
; What it does: When fountain puzzle flags allow and player lacks item #11 but
;   has Purify Stone via inventory or key_item_flags+1 bit $10, spawns
;   sp5D_fountain_activator; interact jumps to ItemUseStub at code_039230.
; Vanilla behavior: sp5D_fountain code_0693FB requires BranchIfHasItem #11 to
;   enter code_069412 cutscene path; otherwise jumps to code_0694A8 (Die).
; Hooks (overrides): sp5D_fountain.code_0693FB! inserts activator spawn branch
;   before vanilla item check / fallthrough.
; Adds: sp5D_fountain_activator (+ _interact); JML ItemUseStub with #&code_039230.
; Depends on: !key_item_flags $0B58; ItemUseStub; flag bytes #6F, #70 fountain
;   state; item #11 (Purification Stone).
; State: STZ $066D preserved from vanilla entry; activator at abs #$00F8,$0148;
;   WaitOnFlagByte #70.
; Hazards/notes: BRA code_069412 re-enters vanilla cutscene when stub path taken;
;   COP spawn/interact needs actor slot in X.
; ==============================================================================

!key_item_flags      0B58

----------------------------------------------

sp5D_fountain_activator {
    COP [SetInteractHandler] ( &sp5D_fountain_activator_interact )
    COP [WaitOnFlagByte] ( #70, #01 )
    COP [Die]

  sp5D_fountain_activator_interact:
    LDA #&code_039230
    JML $@ItemUseStub
}

;sp5D_fountain

sp5D_fountain.code_0693FB! {
    STZ $066D
    COP [BranchOnFlagByte] ( #70, #01, &code_0694A8 )
    COP [BranchOnFlagByte] ( #6F, #00, &code_0694A8 )
    COP [BranchIfHasItem] ( #11, &sp5D_fountain_stub )
    LDA $key_item_flags+1
    BIT #$0010
    BNE sp5D_fountain_stub
    JMP $&code_0694A8

  sp5D_fountain_stub:
    COP [SpawnAfterAbsFlags] ( @sp5D_fountain_activator, #$00F8, #$0148, #$7000 )
    BRA code_069412
}