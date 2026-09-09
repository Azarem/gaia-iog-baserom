---------------------------------------------

h_ec0A_stair_maid [
  actor-def < #24, #00, #10, {

  code_04C356:
    COP [SetOnInteract] ( &code_04C35F )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C35F {
    COP [BranchIfFlagByte] ( #21, #01, &code_04C36A )
    COP [PrintWideString] ( &widestring_04C36F )
    RTL 
}

code_04C36A {
    COP [PrintWideString] ( &widestring_04C3B3 )
    RTL 
}

widestring_04C36F `[DEF]あなた テムさんね.[N]エドワード国王に よびだされたん[N]でしょ?[FIN]何だか 国王はいらついてるの.[N]気をつけてね.[END]`

widestring_04C3B3 `[DEF]カレンさまをつれて お城を[N]ぬけ出すんでしょ?[FIN]王樣に 見つからないように···[N]そして おひめさまを 守って[N]あげてね.[END]`