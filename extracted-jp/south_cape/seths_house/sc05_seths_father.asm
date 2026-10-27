---------------------------------------------

h_sc05_seths_father [
  actor-def < #05, #00, #10, {

  code_04903C:
    COP [SetInteractHandler] ( &code_049045 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_049045 {
    COP [PrintDialogString] ( &dialogstring_04904A )
    RTL 
}

dialogstring_04904A `[TPL:B]モリスの父:[N]けっ.[N]おれが かせいだ金で[N]酒を飲んで 何が悪いってんだ![END]`