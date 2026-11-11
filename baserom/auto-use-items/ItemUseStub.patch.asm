; ==============================================================================
; ItemUseStub - RTS-trick entry to run an item handler and return to caller
; ==============================================================================
; What it does: Jumps here with the handler address in A; runs that code as if
;   called via JSR, then RTL back to the interact script that invoked it.
; Vanilla behavior: N/A (new helper, not an override).
; Hooks (overrides): none.
; Adds: ItemUseStub (A = &item_use handler), ItemUseStubEpilogue (RTL target).
; Depends on: bank 03; callers use JML $@ItemUseStub after LDA #&handler.
; State: none.
; Hazards/notes: Pushes ItemUseStubEpilogue-1 as synthetic return; handler must RTS.
; ==============================================================================
?BANK 03

ItemUseStub {
    PEA #&ItemUseStubEpilogue-1
    DEC
    PHA
    RTS
}

ItemUseStubEpilogue {
    RTL
}