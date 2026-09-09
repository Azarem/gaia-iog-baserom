---------------------------------------------

daC3_prisoner [
  actor-def < #0A, #00, #10, {

  code_08AC52:
    COP [SetOnInteract] ( &code_08AC8D )

  code_08AC56:
    COP [BranchOnPlayerX] ( #$0008, &code_08AC67, &code_08AC60, &code_08AC7A )
} >
]

code_08AC60 {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    BRA code_08AC56
}

code_08AC67 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_08AC72 )
    COP [SetEntryExitNow] ( @code_08AC56 )
}

code_08AC72 {
    COP [StageSpriteMoveX] ( #0E, #12 )
    COP [AnimOnce]
    BRA code_08AC56
}

code_08AC7A {
    COP [BranchIfSolidOffset] ( #03, #00, &code_08AC85 )
    COP [SetEntryExitNow] ( @code_08AC56 )
}

code_08AC85 {
    COP [StageSpriteMoveX] ( #0E, #11 )
    COP [AnimOnce]
    BRA code_08AC56
}

code_08AC8D {
    COP [PrintWideString] ( &widestring_08AC92 )
    RTL 
}

widestring_08AC92 `[DEF][TPL:0]I guess he didn't [N]understand what I said. [N]His eyes were [N]expressive...[PAL:0][END]`