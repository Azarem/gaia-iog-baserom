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