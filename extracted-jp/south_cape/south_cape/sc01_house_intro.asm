!joypadMaskStd                  065A

---------------------------------------------

h_sc01_house_intro [
  actor-def < #00, #00, #30, {

  code_04B899:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0208, #$00E0, &code_04B8D4 )
    COP [BranchIfPlayerAt] ( #$0208, #$00DF, &code_04B8D4 )
    COP [BranchIfPlayerAt] ( #$0208, #$00E8, &code_04B8F6 )
    COP [BranchIfPlayerAt] ( #$0128, #$0258, &code_04B904 )
    COP [BranchIfPlayerAt] ( #$0228, #$0218, &code_04B912 )
    COP [BranchIfPlayerAt] ( #$0218, #$0178, &code_04B912 )
    COP [BranchIfPlayerAt] ( #$0298, #$02C0, &code_04B920 )
    RTL 
} >
]

code_04B8D4 {
    COP [BranchIfFlagByte] ( #26, #01, &code_04B8E0 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04B8EB )
}

code_04B8E0 {
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    RTL 
}

code_04B8EB {
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    RTL 
}

code_04B8F6 {
    COP [BranchIfFlagByte] ( #12, #01, &code_04B903 )
    COP [SetFlagByte] ( #12 )
    COP [PrintWideString] ( &widestring_04B947 )
}

code_04B903 {
    RTL 
}

code_04B904 {
    COP [BranchIfFlagByte] ( #13, #01, &code_04B911 )
    COP [SetFlagByte] ( #13 )
    COP [PrintWideString] ( &widestring_04B986 )
}

code_04B911 {
    RTL 
}

code_04B912 {
    COP [BranchIfFlagByte] ( #14, #01, &code_04B91F )
    COP [SetFlagByte] ( #14 )
    COP [PrintWideString] ( &widestring_04B9BD )
}

code_04B91F {
    RTL 
}

code_04B920 {
    COP [BranchIfFlagByte] ( #17, #01, &code_04B942 )
    COP [BranchIfFlagByte] ( #16, #00, &code_04B942 )
    COP [SetFlagByte] ( #17 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04BA1F )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04B942 {
    COP [SetEntryExitNow] ( @code_04B899 )
}

widestring_04B947 `[TPL:10][TPL:0]ここは ぼくの家だ.[N][PAU:1E]祖母のローラが パイを燒いて[N]いるのか いいにおいが[N]ただよっている.[PAL:0][END]`

widestring_04B986 `[TPL:10][TPL:0]ここは 親友 ロブの家.[N][PAU:1E]彼は 体の弱い母親と[N]二人でくらしている.[PAL:0][END]`

widestring_04B9BD `[TPL:10][TPL:0]ここには 友人のエリックが[N]住んでいる.[FIN]この家は サウスケープで[N]ー番 大きい.[N][PAU:1E]お金持ちの家に 生まれた人を[N]ぼくは うらやましく思う···[PAL:0][END]`

widestring_04BA1F `[TPL:10][TPL:0]海岸のどうくつを出ると[N]あたりは すっかり 夕やみに[N]染まっていた.[PAL:0][END]`