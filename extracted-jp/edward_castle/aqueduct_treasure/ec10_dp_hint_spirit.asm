---------------------------------------------

h_ec10_dp_hint_spirit [
  actor-def < #04, #00, #10, {

  code_04D67F:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D69A )
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
} >
]

code_04D69A {
    COP [PrintDialogString] ( &dialogstring_04D69F )
    RTL 
}

dialogstring_04D69F `[DEF]敵をたおしたときに あらわれる[N]銀色にきらめく ヤミの玉.[FIN]これを 100コ 集めれば[N]いのちのもとが ーつふえる···[FIN]たとえ 敵にやられても[N]遠くはなれた場所まで もどることは[N]なくなるのだ···[END]`