; Crystal ball gate B in the Kress circuit.
; 
; Second crystal ball-controlled gate. Requires a different
; crystal activation. More complex timing or conditional
; logic than gate A.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

mtA5_crystal_ball_gate_b [
  actor-def < #00, #00, #30, {

  code_07E899:
    COP [BranchOnFlagWord] ( #$0167, #01, &f_mtA5_actor_07E896_destroy )
    COP [WaitOnFlagByte] ( #02, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [RemoveItem] ( #1A )
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #60 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #61 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #61 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #62 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #63 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #64 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #65 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #66 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #67 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0167 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]
---------------------------------------------

f_mtA5_actor_07E896_destroy {
    COP [Die]
}