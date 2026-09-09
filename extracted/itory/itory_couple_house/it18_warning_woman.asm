---------------------------------------------

it18_warning_woman [
  actor-def < #0C, #00, #10, {

  code_04DE73:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04DE7C )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DE7C {
    COP [PrintWideString] ( &widestring_04DE81 )
    RTL 
}

widestring_04DE81 `[TPL:A]The ruins are an ancient[N]tomb. Why can't you[N]leave them alone?[END]`