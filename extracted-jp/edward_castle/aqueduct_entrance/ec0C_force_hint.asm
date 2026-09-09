!joypadMaskStd                  065A
!playerMaxHp                    0ACA

---------------------------------------------

h_ec0C_force_hint [
  actor-def < #00, #00, #20, {

  code_04D615:
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04D63B
    COP [SetEntryContinue]
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04D628
    RTL 

  loc_04D628:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #27 )
    COP [PrintWideString] ( &widestring_04D63D )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_04D63B:
    COP [Die]
} >
]

widestring_04D63D `[DEF][TPL:0]テム: そうか···[N]自分のいる地域の敵を 全部たおすと[N]この宝石が あらわれるんだな···[PAL:0][END]`