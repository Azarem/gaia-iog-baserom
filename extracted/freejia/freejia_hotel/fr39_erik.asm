!gfxCacheIdxB                   064A

---------------------------------------------

fr39_erik [
  actor-def < #0C, #00, #10, {

  code_05CB33:
    COP [BranchIfFlagByte] ( #65, #00, &code_05CB42 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CB4B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CB42 {
    COP [Die]

  loc_05CB44:
    COP [SetOnInteract] ( &code_05CB56 )
    COP [SetEntryContinue]
    RTL 
}

code_05CB4B {
    COP [BranchIfFlagByte] ( #68, #01, &code_05CB56 )
    COP [PrintWideString] ( &widestring_05CB93 )
    RTL 
}

code_05CB56 {
    COP [PrintWideString] ( &widestring_05CBF7 )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0003
    STA $0D66
    LDA #$0004
    STA $0D68
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0254, #$02D4, #00, #0C )
    COP [QueueMapChange] ( #49, #$0050, #$00D0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

widestring_05CB93 `[TPL:A][TPL:3]Erik: It is good to be [N]among friends again. [N]If only I wasn't so sad.[FIN]My tears have[N]all been cried...[PAL:0][END]`

widestring_05CBF7 `[TPL:B][TPL:3]Erik: Well, there's an [N]eccentric inventor in [N]the woods nearby. [N]Shall we go? [FIN]I think his name [N]is Neil... [FIN][TPL:0]Will: [N]Did you say Neil!!! [FIN]That's the same name as[N]my lost cousin!![FIN]My cousin Neil, the [N]inventor, flew in the [N]sky in a thing [N]called an airplane. [FIN][PAL:0]So Will and his group went[N]to the inventor's house.[END]`