---------------------------------------------

daC3_sandy [
  actor-def < #02, #00, #10, {

  code_08A862:
    COP [SetOnInteract] ( &code_08A86B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A86B {
    COP [PrintWideString] ( &widestring_08A870 )
    RTL 
}

widestring_08A870 `[DEF]I got sand in my eyes. [N]It started to sting... [END]`