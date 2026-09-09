---------------------------------------------

fr32_herb [
  actor-def < #26, #00, #10, {

  code_05CF23:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05CF31 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CF31 {
    COP [BranchIfFlagByte] ( #53, #01, &code_05CF43 )
    COP [GiveItem] ( #06, &code_05CF44 )
    COP [SetFlagByte] ( #53 )
    COP [PrintWideString] ( &widestring_05CF49 )
}

code_05CF43 {
    RTL 
}

code_05CF44 {
    COP [PrintWideString] ( &widestring_05CF5B )
    RTL 
}

widestring_05CF49 `[DEF]You found the herbs![END]`

widestring_05CF5B `[DEF]You found the herbs, but[N]your inventory's full![END]`