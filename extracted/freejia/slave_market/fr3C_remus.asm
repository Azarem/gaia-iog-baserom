---------------------------------------------

fr3C_remus [
  actor-def < #28, #00, #10, {

  code_05BFAD:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05BFC1 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BFD4 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BFC1 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BFD9 )
    COP [SetEntryContinue]
    RTL 
}

code_05BFD4 {
    COP [PrintWideString] ( &widestring_05BFDE )
    RTL 
}

code_05BFD9 {
    COP [PrintWideString] ( &widestring_05C059 )
    RTL 
}

widestring_05BFDE `[DEF][TPL:5]I am Remus. Our game[N]disappeared and we had[N]nothing to eat.[FIN]We had no choice but[N]to become laborers.[FIN]We didn't know where we [N]would be taken or what [N]would happen...[PAL:0][END]`

widestring_05C059 `[DEF]How can things like[N]this happen?[END]`