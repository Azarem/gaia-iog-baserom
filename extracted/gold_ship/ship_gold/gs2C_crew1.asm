---------------------------------------------

gs2C_crew1 [
  actor-def < #02, #00, #10, {

  code_058252:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05825B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05825B {
    COP [PrintWideString] ( &widestring_058260 )
    RTL 
}

widestring_058260 `[DEF]King! You're safe![N]Now we can set sail.[END]`