---------------------------------------------

ec0B_ball [
  actor-def < #00, #00, #10, {

  code_04DBDC:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DBE8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DBE8 {
    COP [PrintWideString] ( &widestring_04DBF1 )
    COP [SetFlagByte] ( #04 )
    COP [Die]
}

widestring_04DBF1 `[TPL:E][TPL:0]Will: Someone was [N]chained to this ball...[PAL:0][END]`