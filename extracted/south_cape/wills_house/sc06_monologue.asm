!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!TM                             212C
!cgramPalette                   7F0A00

---------------------------------------------

sc06_monologue [
  actor-def < #00, #00, #30, {

  code_04A464:
    COP [BranchIfFlagByte] ( #1D, #01, &code_04A4CA )
    COP [BranchIfFlagByte] ( #1C, #01, &code_04A4B4 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0008, #$0210, &code_04A47B )
    RTL 
} >
]

code_04A47B {
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$04
    STA $TM
    REP #$20
    LDA #$0000
    STA $cgramPalette
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_04A4CC )
    COP [SetFlagByte] ( #1C )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #06, #$00A0, #$0078, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_04A4B4 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04A582 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04A4CA {
    COP [Die]
}

dialogstring_04A4CC `[DLG:3,B][SIZ:D,3][TPL:0]Will: We sat down to[N]a feast of snail pie...[N]with whipped cream![FIN]I only got one piece,[N]but Grandpa Bill ate[N]half the pie.[FIN]That night Will dreamed[N]that Kara and he took a[N]trip around the world...[PAL:0][END]`

dialogstring_04A582 `[DLG:3,11][SIZ:D,3]And the next morning[N]something began to[N]happen...[END]`