?INCLUDE 'InitPlayerScriptVariant'

!sceneCurrent                   0644
!joypadMaskStd                  065A

---------------------------------------------

btDE_monologue [
  actor-def < #00, #00, #30, {

  code_0998B6:
    LDA $sceneCurrent
    CMP #$00DE
    BEQ loc_0998C6
    CMP #$00DF
    BEQ loc_0998E4
    COP [SetEntryContinue]
    RTL 

  loc_0998C6:
    COP [BranchIfFlagByte] ( #D2, #01, &code_0998E2 )
    COP [SetFlagByte] ( #D2 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_099914 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_0998E2 {
    COP [Die]

  loc_0998E4:
    COP [BranchIfFlagByte] ( #D3, #01, &code_099912 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #3F, #19, #40, #1D, &code_0998F5 )
    RTL 
}

code_0998F5 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    LDA #$0001
    JSL $@InitPlayerScriptVariant
    COP [SetFlagByte] ( #D3 )
    COP [PrintDialogString] ( &dialogstring_099952 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_099912 {
    COP [Die]
}

dialogstring_099914 `[TPL:A][TPL:0]The Tower of Babel was[N]deathly quiet. Time[N]stood still...[END]`

dialogstring_099952 `[TPL:9][TPL:0]The Flute I had was[N]discovered here.[END]`