---------------------------------------------

fr32_fragrance [
  actor-def < #13, #00, #10, {

  code_05BA0F:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BA18 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BA18 {
    COP [PrintDialogString] ( &dialogstring_05BA1D )
    RTL 
}

dialogstring_05BA1D `[DEF]The Freejia is the city[N]flower. Smells good,[N]doesn't it?[END]`