; Mushroom Drop gate B in the Kress circuit.
; 
; Second Mushroom Drop-controlled gate. Requires a different
; Mushroom Drop activation flag. Longer reveal sequence than gate A.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

mtA5_mushroom_drop_gate_b [
  actor-def < #00, #00, #30, {

  code_07E899:
    COP [BranchOnFlagWord] ( #$0167, #01, &f_mtA5_actor_07E896_destroy )
    COP [WaitOnFlagByte] ( #02, #01 )
    LDA #$EFFC
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
    LDA #$EFFC
    TRB $joypadMaskStd
    COP [Die]
} >
]
---------------------------------------------

f_mtA5_actor_07E896_destroy {
    COP [Die]
}