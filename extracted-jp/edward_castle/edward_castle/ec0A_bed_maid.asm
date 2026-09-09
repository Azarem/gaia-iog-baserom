---------------------------------------------

h_ec0A_bed_maid [
  actor-def < #25, #00, #10, {

  code_04C313:
    COP [SetOnInteract] ( &code_04C31C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C31C {
    COP [PrintWideString] ( &widestring_04C321 )
    RTL 
}

widestring_04C321 `[DEF]近ごろ 殺し屋が やとわれたの.[N]国王は いったい 何を[N]考えているのかしら···[END]`