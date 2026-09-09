---------------------------------------------

h_sc05_seths_father [
  actor-def < #05, #00, #10, {

  code_04903C:
    COP [SetOnInteract] ( &code_049045 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_049045 {
    COP [PrintWideString] ( &widestring_04904A )
    RTL 
}

widestring_04904A `[TPL:B]モリスの父:[N]けっ.[N]おれが かせいだ金で[N]酒を飲んで 何が悪いってんだ![END]`