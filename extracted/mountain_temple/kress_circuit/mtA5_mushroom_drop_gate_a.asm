; Mushroom Drop gate A of the Kress circuit (scene $A5).
; 
; Dies at spawn when flag word $015F is set. Otherwise it waits on WaitOnFlagByte ( #01, #01 ), raised by UseItem_MushroomWater at stem A (tiles (2E,12)-(30,13)). It then locks the joypad, removes item #1A and plays sound #0F on channel 1 before each of the six BG changes #5A-#5F, sets $015F, unlocks the joypad and dies.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

mtA5_mushroom_drop_gate_a [
  actor-def < #00, #00, #30, {

  code_07E846:
    COP [BranchOnFlagWord] ( #$015F, #01, &f_mtA5_actor_07E843_destroy )
    COP [WaitOnFlagByte] ( #01, #01 )
    LDA #$EFFC
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
    LDA #$EFFC
    TRB $joypadMaskStd
    COP [Die]
} >
]
---------------------------------------------

f_mtA5_actor_07E843_destroy {
    COP [Die]
}