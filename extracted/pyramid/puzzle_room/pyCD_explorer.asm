---------------------------------------------

pyCD_explorer [
  actor-def < #1F, #00, #10, {

  code_08C200:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08C254 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C2, #01, &code_08C250 )
    COP [BranchIfFlagByte] ( #C3, #01, &code_08C250 )
    COP [BranchIfFlagByte] ( #C4, #01, &code_08C250 )
    COP [BranchIfFlagByte] ( #C5, #01, &code_08C250 )
    COP [BranchIfFlagByte] ( #C6, #01, &code_08C250 )
    COP [BranchIfFlagByte] ( #C7, #01, &code_08C250 )
    COP [BranchIfNoItem] ( #1E, &code_08C250 )
    COP [BranchIfNoItem] ( #1F, &code_08C250 )
    COP [BranchIfNoItem] ( #20, &code_08C250 )
    COP [BranchIfNoItem] ( #21, &code_08C250 )
    COP [BranchIfNoItem] ( #22, &code_08C250 )
    COP [BranchIfNoItem] ( #23, &code_08C250 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08C250 {
    COP [ClearLowHere]
    COP [Die]
}

code_08C254 {
    COP [PrintWideString] ( &widestring_08C259 )
    RTL 
}

widestring_08C259 `[DEF]Explorer: There are[N]traps scattered around[N]to prevent entry.[FIN]There's a booby trap in[N]this room that responds[N]to sound.....So[N]don't make any noise...[END]`