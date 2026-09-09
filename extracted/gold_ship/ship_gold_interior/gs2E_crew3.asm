---------------------------------------------

gs2E_crew3 [
  actor-def < #15, #00, #10, {

  code_0589CD:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0589D6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0589D6 {
    COP [PrintWideString] ( &widestring_0589DB )
    RTL 
}

widestring_0589DB `[TPL:A]Why must[N]we flee? It is[N]our home.[END]`