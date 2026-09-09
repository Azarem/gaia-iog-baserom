---------------------------------------------

h_ec0A_prison_guard [
  actor-def < #1D, #00, #10, {

  code_04CC80:
    COP [BranchIfFlagByte] ( #21, #01, &code_04CC97 )
    COP [SetOnInteract] ( &code_04CC99 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #01 )
    COP [AddPosition] ( #00, #08 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04CC97 {
    COP [Die]
}

code_04CC99 {
    COP [PrintWideString] ( &widestring_04CC9E )
    RTL 
}

widestring_04CC9E `[TPL:B]兵士:[N]この先は 地下のろうや.[N]ー般人が 立ち入る場所では[N]ない.[END]`