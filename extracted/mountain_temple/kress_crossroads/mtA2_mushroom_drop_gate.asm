; Mushroom Drop gate of the Kress crossroads (scene $A2).
; 
; Dies at spawn when flag word $0159 is set. Otherwise it waits on WaitOnFlagByte ( #01, #01 ), the scratch flag that UseItem_MushroomWater raises when Will pours the item on the stem in tiles (14,08)-(16,09). It then locks the joypad ($EFFC), removes item #1A (Mushroom Drop) and plays sound #0F on channel 1 before each of the six BG changes #54-#59, sets $0159 and unlocks the joypad.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

mtA2_mushroom_drop_gate [
  actor-def < #00, #00, #30, {

  code_07E7F3:
    COP [BranchOnFlagWord] ( #$0159, #01, &f_mtA2_actor_07E7F0_destroy )
    COP [WaitOnFlagByte] ( #01, #01 )
    LDA #$EFFC
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
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]
---------------------------------------------

f_mtA2_actor_07E7F0_destroy {
    COP [Die]
}