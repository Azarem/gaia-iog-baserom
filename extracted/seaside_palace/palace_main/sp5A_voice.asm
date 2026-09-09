---------------------------------------------

sp5A_voice [
  actor-def < #00, #00, #30, {

  code_069538:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #70, #01, &code_069568 )
    COP [BranchIfPlayerInAbsTiles] ( #37, #28, #38, #29, &code_069569 )
    COP [BranchIfPlayerInAbsTiles] ( #0E, #38, #0F, #39, &code_069577 )
    COP [BranchIfPlayerInAbsTiles] ( #2B, #59, #2C, #5A, &code_069585 )
    COP [BranchIfPlayerInAbsTiles] ( #36, #07, #3B, #0B, &code_069593 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #18, #0B, #1A, &code_0695A1 )
} >
]

code_069568 {
    RTL 
}

code_069569 {
    COP [BranchIfFlagByte] ( #71, #01, &code_069568 )
    COP [SetFlagByte] ( #71 )
    COP [PrintWideString] ( &widestring_0695AF )
    RTL 
}

code_069577 {
    COP [BranchIfFlagByte] ( #72, #01, &code_069568 )
    COP [SetFlagByte] ( #72 )
    COP [PrintWideString] ( &widestring_069612 )
    RTL 
}

code_069585 {
    COP [BranchIfFlagByte] ( #73, #01, &code_069568 )
    COP [SetFlagByte] ( #73 )
    COP [PrintWideString] ( &widestring_069672 )
    RTL 
}

code_069593 {
    COP [BranchIfFlagByte] ( #83, #01, &code_069568 )
    COP [SetFlagByte] ( #83 )
    COP [PrintWideString] ( &widestring_0696A5 )
    RTL 
}

code_0695A1 {
    COP [BranchIfFlagByte] ( #84, #01, &code_069568 )
    COP [SetFlagByte] ( #84 )
    COP [PrintWideString] ( &widestring_0696D5 )
    RTL 
}

widestring_0695AF `[TPL:A][TPL:0][PRT:@sp5A_voice.widestring_069705][PAL:0]Strange Voice: [N]This is the Palace of [N]Vampires... [FIN]The fountain in [N]this palace produces [N]demons continuously... [END]`

widestring_069612 `[TPL:A][TPL:0][PRT:@sp5A_voice.widestring_069705][PAL:0]Strange Voice: In the [N]basement of the castle [N]is a strange fountain. [FIN]The stone is there...[N]Hurry! Hurry![END]`

widestring_069672 `[TPL:A][TPL:0][PRT:@sp5A_voice.widestring_069705][PAL:0]Strange Voice: The[N]Purification Stone...[N]in the castle...[END]`

widestring_0696A5 `[TPL:A][TPL:0]Will: What? A sign of [N]life from the [N]right-hand room...[PAL:0][END]`

widestring_0696D5 `[TPL:A][TPL:0]Will: What? A sign of [N]life from the [N]left-hand room...[PAL:0][END]`

widestring_069705 `Will: What? I can  [N]hear a soft voice [N]from somewhere... [FIN]`