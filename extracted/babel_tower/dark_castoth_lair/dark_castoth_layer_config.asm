; Display layer config for the Dark Castoth rematch lair.
; 
; Technical setup for the Neo Castoth boss fight arena
; in the Tower of Babel. Configures BG layers for the
; recycled boss room.
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