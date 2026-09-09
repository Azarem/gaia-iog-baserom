!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!TM                             212C
!cgramPalette                   7F0A00

---------------------------------------------

h_sc06_monologue [
  actor-def < #00, #00, #30, {

  code_04A1F7:
    COP [BranchIfFlagByte] ( #1D, #01, &code_04A25D )
    COP [BranchIfFlagByte] ( #1C, #01, &code_04A247 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0008, #$0210, &code_04A20E )
    RTL 
} >
]

code_04A20E {
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$04
    STA $TM
    REP #$20
    LDA #$0000
    STA $cgramPalette
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_04A25F )
    COP [SetFlagByte] ( #1C )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #06, #$00A0, #$0078, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_04A247 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #1D )
    COP [PrintWideString] ( &widestring_04A310 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04A25D {
    COP [Die]
}

widestring_04A25F `[DLG:3,B][SIZ:D,3,0][TPL:0]テム: 結局 夕ごはんは[N]ホイップクリームの たっぷりのった[N]ミートパイだった···[FIN]ボクは ー切れしか食べなかったけど[N]ビルおじいちゃんは がんばって[N]三切れも 食べていた.[FIN]そして その夜 ボクは 夢を見た.[N]カレンと いっしょに[N]世界中を 旅している夢だった··[PAL:0][END]`

widestring_04A310 `[DLG:3,11][SIZ:D,3,0]そして よく朝.[N]たいへんな 出来事が 起ころうと[N]していた···[END]`