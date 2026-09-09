---------------------------------------------

ec0A_stair_maid [
  actor-def < #24, #00, #10, {

  code_04C7FF:
    COP [SetOnInteract] ( &code_04C808 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C808 {
    COP [BranchIfFlagByte] ( #21, #01, &code_04C813 )
    COP [PrintWideString] ( &widestring_04C818 )
    RTL 
}

code_04C813 {
    COP [PrintWideString] ( &widestring_04C85A )
    RTL 
}

widestring_04C818 `[DEF]So you're Will.[N]You were summoned by[N]King Edward?[FIN]Be careful when you[N]meet with him.[END]`

widestring_04C85A `[DEF]Are you going to take [N]Kara out of the castle?[FIN]Don't let the King find[N]you... Please take [N]care of the Princess.[END]`