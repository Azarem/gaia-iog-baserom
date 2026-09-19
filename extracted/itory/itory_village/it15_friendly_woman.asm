; Itory Village NPC about Lily's loneliness.
; 
; Dialog asking Will to befriend Lily since there are no other
; children her age in the village.
---------------------------------------------

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
    COP [PrintDialogString] ( &dialogstring_04E033 )
    RTL 
}

dialogstring_04E033 `[DEF]There are no other[N]children Lilly's age[N]in the village. Please[N]become friends.[END]`