; Crystal ball gate in the Kress crossroads.
; 
; Central gate at the crossroads area. Opens when the
; crystal ball puzzle is solved, connecting the temple
; sections.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

mtA2_crystal_ball_gate [
  actor-def < #00, #00, #30, {

  code_07E7F3:
    COP [BranchOnFlagWord] ( #$0159, #01, &f_mtA2_actor_07E7F0_destroy )
    COP [WaitOnFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [RemoveItem] ( #1A )
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #54 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #55 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #56 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #57 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #58 )
    COP [ApplyBgChange]
    COP [PlaySoundCh1] ( #0F )
    COP [StageBgChange] ( #59 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0159 )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]
---------------------------------------------

f_mtA2_actor_07E7F0_destroy {
    COP [Die]
}