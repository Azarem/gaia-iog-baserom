!joypadMaskStd                  065A

---------------------------------------------

mtA5_crystal_ball_gate_a [
  actor-def < #00, #00, #30, {

  code_07E846:
    COP [BranchIfFlagWord] ( #$015F, #01, &f_mtA5_actor_07E843_destroy )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [RemoveItem] ( #1A )
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5A )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5B )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5C )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5D )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5E )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #5F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$015F )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]
---------------------------------------------

f_mtA5_actor_07E843_destroy {
    COP [Die]
}