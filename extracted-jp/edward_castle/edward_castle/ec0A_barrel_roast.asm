?INCLUDE 'chunk_008000'

---------------------------------------------

h_ec0A_barrel_roast [
  actor-def < #00, #00, #30, {

  code_04CBB8:
    COP [AddPosition] ( #08, #01 )
    COP [BranchIfFlagByte] ( #46, #01, &code_04CBE1 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_04CBDC )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #22, #37, #26, #3D, &code_04CBD5 )
    RTL 
} >
]

code_04CBD5 {
    COP [PrintWideString] ( &widestring_04CBF6 )
    COP [SetEntryContinue]
    RTL 
}

code_04CBDC {
    COP [GiveItem] ( #0A, &code_04CBF2 )
}

code_04CBE1 {
    COP [SetFlagByte] ( #46 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_04CC24 )
    COP [Die]
}

code_04CBF2 {
    JML $@chunk_008000.code_00CAD3
}

widestring_04CBF6 `[TPL:A][TPL:1]カレン:[N]たしか このあたりの タルに[N]食べ物が 入っているの.[PAL:0][END]`

widestring_04CC24 `[DEF][SFX:0][DLY:9]骨つきのくんせい肉を 手に入れた![PAU:FF][FIN][DLY:1][TPL:1]カレン:[N]これで 準備 オッケー![N]さあ 兵隊さんに 見つからない[N]うちに いきましょ![PAL:0][END]`