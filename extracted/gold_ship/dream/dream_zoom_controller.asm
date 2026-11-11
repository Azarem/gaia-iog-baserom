; Camera zoom controller for Will's dream about his mother (scene $2A).
; 
; Waits for scratch flag $0E (set by gs2A_shira in its talk handler). Then it writes $00F6 = $0088 minus bg1ScrollH and $00FA = $0180 minus mapScrollV, starts $00FE at $00A0, lowers $00FE by 2 each frame and dies when $00FE is below $0040.
---------------------------------------------

!bg1ScrollH                     068A
!mapScrollV                     068E

---------------------------------------------

dream_zoom_controller [
  actor-def < #00, #00, #28, {

  code_00C1AD:
    COP [WaitOnFlagByte] ( #0E, #01 )
    LDA #$0088
    SEC 
    SBC $bg1ScrollH
    STA $00F6
    LDA #$0180
    SEC 
    SBC $mapScrollV
    STA $00FA
    LDA #$00A0
    STA $00FE
    COP [SetEntryHere]
    LDA $00FE
    SEC 
    SBC #$0002
    STA $00FE
    CMP #$0040
    BCC loc_00C1DD
    RTL 

  loc_00C1DD:
    COP [Die]
} >
]