; South Cape house narration actor.
; 
; Displays a text box describing the house Will is entering. Uses
; flag checks to determine which house and shows the appropriate
; narration.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

sc01_house_intro [
  actor-def < #00, #00, #30, {

  code_04BC68:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0208, #$00E0, &code_04BC9B )
    COP [BranchIfPlayerAt] ( #$0208, #$00DF, &code_04BC9B )
    COP [BranchIfPlayerAt] ( #$0128, #$0258, &code_04BCD8 )
    COP [BranchIfPlayerAt] ( #$0228, #$0218, &code_04BCE6 )
    COP [BranchIfPlayerAt] ( #$0218, #$0178, &code_04BCE6 )
    COP [BranchIfPlayerAt] ( #$0298, #$02C0, &code_04BCF4 )
    RTL 
} >
]

code_04BC9B {
    COP [BranchIfFlagByte] ( #26, #01, &code_04BCA7 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04BCBF )
}

code_04BCA7 {
    COP [BranchIfFlagByte] ( #12, #01, &code_04BCB4 )
    COP [SetFlagByte] ( #12 )
    COP [PrintDialogString] ( &dialogstring_04BD1B )
}

code_04BCB4 {
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    RTL 
}

code_04BCBF {
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    RTL 
}

code_04BCCA {
    COP [BranchIfFlagByte] ( #12, #01, &code_04BCD7 )
    COP [SetFlagByte] ( #12 )
    COP [PrintDialogString] ( &dialogstring_04BD1B )
}

code_04BCD7 {
    RTL 
}

code_04BCD8 {
    COP [BranchIfFlagByte] ( #13, #01, &code_04BCE5 )
    COP [SetFlagByte] ( #13 )
    COP [PrintDialogString] ( &dialogstring_04BD5F )
}

code_04BCE5 {
    RTL 
}

code_04BCE6 {
    COP [BranchIfFlagByte] ( #14, #01, &code_04BCF3 )
    COP [SetFlagByte] ( #14 )
    COP [PrintDialogString] ( &dialogstring_04BD9B )
}

code_04BCF3 {
    RTL 
}

code_04BCF4 {
    COP [BranchIfFlagByte] ( #17, #01, &code_04BD16 )
    COP [BranchIfFlagByte] ( #16, #00, &code_04BD16 )
    COP [SetFlagByte] ( #17 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04BE05 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04BD16 {
    COP [SetEntryExitNow] ( @code_04BC68 )
}

dialogstring_04BD1B `[TPL:10][TPL:0]This is my house.[N]The pie that [N]Grandma Lola is making[N]smells really great.[PAL:0][END]`

dialogstring_04BD5F `[TPL:10][TPL:0]This is Lance's house.[N]He lives here with his[N]frail mother.[PAL:0][END]`

dialogstring_04BD9B `[TPL:10][TPL:0]My friend Erik [N]lives here.[FIN]This is the biggest[N]house in South Cape.[N]Will envied people born[N]to rich families...[PAL:0][END]`

dialogstring_04BE05 `[TPL:10][TPL:0]It was already [N]dark by the time Will [N]left the cave.[PAL:0][END]`