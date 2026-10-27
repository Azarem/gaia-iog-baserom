---------------------------------------------

h_ec0A_prison_guard [
  actor-def < #1D, #00, #10, {

  code_04CC80:
    COP [BranchOnFlagByte] ( #21, #01, &code_04CC97 )
    COP [SetInteractHandler] ( &code_04CC99 )
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #01 )
    COP [NudgePosition] ( #00, #08 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04CC97 {
    COP [Die]
}

code_04CC99 {
    COP [PrintDialogString] ( &dialogstring_04CC9E )
    RTL 
}

dialogstring_04CC9E `[TPL:B]兵士:[N]この先は 地下のろうや.[N]ー般人が 立ち入る場所では[N]ない.[END]`