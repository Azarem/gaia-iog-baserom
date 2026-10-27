---------------------------------------------

h_sc08_lance [
  actor-def < #03, #00, #10, {

  code_048C61:
    COP [SetInteractHandler] ( &code_048C72 )
    COP [BranchOnFlagByte] ( #10, #00, &code_048C6D )
    COP [Die]
} >
]

code_048C6D {
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_048C72 {
    COP [PrintDialogString] ( &dialogstring_048C77 )
    RTL 
}

dialogstring_048C77 `[TPL:B][TPL:4]ロブ:[N]じゃ 今日も いつもの[N]海岸のどうくつでなっ![PAL:0][END]`