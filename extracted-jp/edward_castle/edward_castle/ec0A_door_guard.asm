---------------------------------------------

h_ec0A_door_guard [
  actor-def < #1C, #00, #10, {

  code_04C150:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04C159 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C159 {
    COP [PrintDialogString] ( &dialogstring_04C15E )
    RTL 
}

dialogstring_04C15E `[DEF]兵士:[N]テムさん ですね.[N]お待ちしておりました.[N]さあ エドワード国王のところへ.[END]`