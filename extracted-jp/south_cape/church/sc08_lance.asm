---------------------------------------------

h_sc08_lance [
  actor-def < #03, #00, #10, {

  code_048C61:
    COP [SetOnInteract] ( &code_048C72 )
    COP [BranchIfFlagByte] ( #10, #00, &code_048C6D )
    COP [Die]
} >
]

code_048C6D {
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_048C72 {
    COP [PrintWideString] ( &widestring_048C77 )
    RTL 
}

widestring_048C77 `[TPL:B][TPL:4]ロブ:[N]じゃ 今日も いつもの[N]海岸のどうくつでなっ![PAL:0][END]`