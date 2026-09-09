---------------------------------------------

e_it15_bill [
  actor-def < #2A, #00, #10, {

  code_04E746:
    COP [SetOnInteract] ( &code_04E773 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #47, #01, &code_04E76D )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04E76A )
    COP [ExitIfFlagByte] ( #3B, #01 )
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
} >
]

code_04E76A {
    COP [SetEntryContinue]
    RTL 
}

code_04E76D {
    COP [SetOnInteract] ( &code_04E778 )
    BRA code_04E76A
}

code_04E773 {
    COP [PrintWideString] ( &widestring_04E77D )
    RTL 
}

code_04E778 {
    COP [PrintWideString] ( &widestring_04E7B0 )
    RTL 
}

widestring_04E77D `[DEF][TPL:4]ビル:[N]さあさ,長老さまに 会うがいい.[N]きっと 何か 知っておられるから.[PAL:0][END]`

widestring_04E7B0 `[DEF][TPL:4]ビル: 長老さまは まだ[N]お元気だったかい?[FIN]ところで エドワード城の地下で[N]まものと たたかったとき[N]銀色にかがやく石を[N]ひろわなかったかい?[FIN]あの 石には[N]不思議な力が あってな[FIN]100 ためると 敵にやられても[N]すぐ近くの場所で ふと われに[N]かえるんだそうじゃ.[PAL:0][END]`