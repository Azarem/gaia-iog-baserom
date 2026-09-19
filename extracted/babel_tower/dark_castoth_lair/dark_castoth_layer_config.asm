; BG layer configuration thinker for the Dark Castoth boss arena, slot #00.
; 
; Forces TM ($212C) to #$17, enabling BG1, BG2, BG3, and sprites on the main screen. Clears TS ($212D) to #$00, disabling all subscreen background layers. One-shot register setup ensuring the multi-layer boss room layout renders correctly; paired with sine_hdma_ending_wave and ambient palette bundles in the Castoth thinker set.
---------------------------------------------

!TM                             212C
!TS                             212D

---------------------------------------------

dark_castoth_layer_config [
  thinker-def < #04, #08, {

  code_00BF7A:
    SEP #$20
    LDA #$17
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    RTL 
} >
]