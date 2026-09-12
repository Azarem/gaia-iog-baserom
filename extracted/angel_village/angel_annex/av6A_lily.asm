---------------------------------------------

av6A_lily [
  actor-def < #23, #00, #10, {

  code_06C291:
    COP [BranchIfFlagByte] ( #8D, #01, &av6A_lily_destroy )
    COP [BranchIfFlagByte] ( #8C, #01, &code_06C2A6 )
    COP [SetOnInteract] ( &code_06C2B8 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06C2A6 {
    COP [SetTilePos] ( #1A, #0E )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06C2B3 )
    COP [SetEntryContinue]
    RTL 
}

code_06C2B3 {
    COP [PrintDialogString] ( &dialogstring_06C2F8 )
    RTL 
}

code_06C2B8 {
    COP [PrintDialogString] ( &dialogstring_06C2BD )
    RTL 
}

dialogstring_06C2BD `[TPL:A][TPL:2]Lilly: Why do angels [N]live in such a dark [N]place? Feels so gloomy.[PAL:0][END]`

dialogstring_06C2F8 `[TPL:A][TPL:2]Lilly: [N]Kara looks a  [N]little strange... [FIN]Has something happened [N]to Kara? My intuition [N]is usually good.[PAL:0][END]`
---------------------------------------------

av6A_lily_destroy {
    COP [Die]
}