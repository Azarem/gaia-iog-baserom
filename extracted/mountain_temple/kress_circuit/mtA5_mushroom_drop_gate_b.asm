; Mushroom Drop gate B of the Kress circuit (scene $A5).
; 
; Dies at spawn when flag word $0167 is set. Otherwise it waits on WaitOnFlagByte ( #02, #01 ), raised by UseItem_MushroomWater at stem B (tiles (28,24)-(2A,25)). It then locks the joypad, removes item #1A and plays sound #0F on channel 1 before each BG change of the sequence #60, #61, #61, #62-#67, sets $0167, unlocks the joypad and dies.
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