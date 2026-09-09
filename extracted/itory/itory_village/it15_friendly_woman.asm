---------------------------------------------

it15_friendly_woman [
  actor-def < #0A, #00, #10, {

  code_04E025:
    COP [SetOnInteract] ( &code_04E02E )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04E02E {
    COP [PrintWideString] ( &widestring_04E033 )
    RTL 
}

widestring_04E033 `[DEF]There are no other[N]children Lilly's age[N]in the village. Please[N]become friends.[END]`