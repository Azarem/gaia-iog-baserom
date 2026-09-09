---------------------------------------------

h_sc01_sprint_man [
  actor-def < #02, #00, #10, {

  code_0490C4:
    COP [SetOnInteract] ( &code_0490CD )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0490CD {
    COP [PrintWideString] ( &widestring_0490D2 )
    RTL 
}

widestring_0490D2 `[DEF]なかなか 速そうな 足をしてるな.[N]走るときは 進行方向の ボタンを[N]グッ グーッと 2回 おすんだぜ.[END]`