---------------------------------------------

sc04_eriks_father [
  actor-def < #03, #00, #10, {

  code_048FE1:
    COP [SetOnInteract] ( &code_048FEA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048FEA {
    COP [PrintWideString] ( &widestring_048FEF )
    RTL 
}

widestring_048FEF `[DEF]Erik's father:[N]Everyone is jealous[N]of this big house...[FIN]It's nothing.[N]We moved to this town[N]before anyone else.[END]`