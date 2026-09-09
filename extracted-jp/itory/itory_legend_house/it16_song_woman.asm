---------------------------------------------

h_it16_song_woman [
  actor-def < #0A, #00, #10, {

  code_04D8BD:
    COP [SetOnInteract] ( &code_04D8C6 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D8C6 {
    COP [PrintWideString] ( &widestring_04D8CB )
    RTL 
}

widestring_04D8CB `[DEF]かつて この地に 住んでいた[N]インカ人たちは 文字というものを[N]もたない 民族だったわ.[FIN]彼らの いいつたえは[N]音という形で のこっているの.[FIN]なにげない メロディにも[N]ちゃんと 意味があるってことね.[END]`