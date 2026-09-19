; Window masking thinker for Dao Village's framed viewport effect, paired with dao_sine_hdma_slow.
; 
; Each frame writes #$02 to W12SEL ($2123), configuring BG1/BG2 window mask select so BG2 participates in window clipping. Produces the vignette or framed-edge look that clips background layers at the screen borders. Fixed register write via SetEntryContinue — no palette cycling or HDMA.
---------------------------------------------

!W12SEL                         2123

---------------------------------------------

dao_window_mask [
  thinker-def < #00, #08, {

  code_00B7C0:
    COP [SetEntryContinue]
    SEP #$20
    LDA #$02
    STA $W12SEL
    REP #$20
    RTL 
} >
]