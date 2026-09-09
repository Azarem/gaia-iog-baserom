?BANK 03

---------------------------------------------

overworld_options [
  &code_03B165   ;00
  &code_03B167   ;01
  &code_03B18D   ;02
  &code_03B1B6   ;03
  &code_03B1DB   ;04
  &code_03B200   ;05
  &code_03B229   ;06
  &code_03B252   ;07
  &code_03B27B   ;08
  &code_03B2A4   ;09
  &code_03B2BD   ;0A
  &code_03B2EA   ;0B
  &code_03B30F   ;0C
  &code_03B344   ;0D
  &code_03B369   ;0E
  &code_03B3AE   ;0F
  &code_03B3D3   ;10
  &code_03B406   ;11
  &code_03B42E   ;12
  &code_03B456   ;13
  &code_03B48F   ;14
  &code_03B4B7   ;15
  &code_03B4C7   ;16
  &code_03B4EF   ;17
  &code_03B525   ;18
  &code_03B54C   ;19
  &code_03B593   ;1A
  &code_03B5D5   ;1B
  &code_03B5E5   ;1C
  &code_03B5EB   ;1D
  &code_03B5F1   ;1E
  &code_03B5F7   ;1F
  &code_03B5FD   ;20
  &code_03B603   ;21
  &code_03B609   ;22
  &code_03B60F   ;23
  &code_03B615   ;24
  &code_03B61B   ;25
  &code_03B621   ;26
]

code_03B165 {
    COP [RestoreSavedPtr]
}

code_03B167 {
    COP [PrintWideString] ( &widestring_03B179 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B173 )

  loc_03B171:
    COP [RestoreSavedPtr]
}

code_list_03B173 [
  &code_03B655   ;00
  &code_03B655   ;01
  &code_03B661   ;02
]

widestring_03B179 `[TPL:11][SFX:0] やめる[N] エドワード城`

code_03B18D {
    COP [PrintWideString] ( &widestring_03B19F )
    COP [DialogueOptions] ( #02, #01, &code_list_03B199 )

  loc_03B197:
    COP [RestoreSavedPtr]
}

code_list_03B199 [
  &code_03B655   ;00
  &code_03B655   ;01
  &code_03B671   ;02
]

widestring_03B19F `[TPL:11][SFX:0] やめる[N] イトリー族の村`

widestring_03B1B5 ``

code_03B1B6 {
    COP [PrintWideString] ( &widestring_03B1C8 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B1C2 )

  loc_03B1C0:
    COP [RestoreSavedPtr]
}

code_list_03B1C2 [
  &code_03B665   ;00
  &code_03B665   ;01
  &code_03B651   ;02
]

widestring_03B1C8 `[TPL:11][SFX:0] やめる[N] サウスケープ`

code_03B1DB {
    COP [PrintWideString] ( &widestring_03B1ED )
    COP [DialogueOptions] ( #02, #01, &code_list_03B1E7 )

  loc_03B1E5:
    COP [RestoreSavedPtr]
}

code_list_03B1E7 [
  &code_03B675   ;00
  &code_03B675   ;01
  &code_03B681   ;02
]

widestring_03B1ED `[TPL:11][SFX:0] やめる[N] サウスケープ`

code_03B200 {
    COP [PrintWideString] ( &widestring_03B212 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B20C )

  loc_03B20A:
    COP [RestoreSavedPtr]
}

code_list_03B20C [
  &code_03B6A5   ;00
  &code_03B6A5   ;01
  &code_03B691   ;02
]

widestring_03B212 `[TPL:11][SFX:0] やめる[N] イトリー族の村`

widestring_03B228 ``

code_03B229 {
    COP [PrintWideString] ( &widestring_03B23B )
    COP [DialogueOptions] ( #02, #01, &code_list_03B235 )

  loc_03B233:
    COP [RestoreSavedPtr]
}

code_list_03B235 [
  &code_03B695   ;00
  &code_03B695   ;01
  &code_03B6A1   ;02
]

widestring_03B23B `[TPL:11][SFX:0] やめる[N] インカのイセキ`

widestring_03B251 ``

code_03B252 {
    COP [PrintWideString] ( &widestring_03B264 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B25E )

  loc_03B25C:
    COP [RestoreSavedPtr]
}

code_list_03B25E [
  &code_03B6C5   ;00
  &code_03B6C5   ;01
  &code_03B6B1   ;02
]

widestring_03B264 `[TPL:11][SFX:0] やめる[N] ダイヤモンド鉱山`

code_03B27B {
    COP [PrintWideString] ( &widestring_03B28D )
    COP [DialogueOptions] ( #02, #01, &code_list_03B287 )

  loc_03B285:
    COP [RestoreSavedPtr]
}

code_list_03B287 [
  &code_03B6B5   ;00
  &code_03B6B5   ;01
  &code_03B6C1   ;02
]

widestring_03B28D `[TPL:11][SFX:0] やめる[N] 花の都フリージア`

code_03B2A4 {
    COP [PrintWideString] ( &widestring_03B2B4 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B2B0 )

  loc_03B2AE:
    COP [RestoreSavedPtr]
}

code_list_03B2B0 [
  &code_03B6C5   ;00
  &code_03B6C5   ;01
]

widestring_03B2B4 `[TPL:11][SFX:0] やめる`

code_03B2BD {
    COP [PrintWideString] ( &widestring_03B2CF )
    COP [DialogueOptions] ( #02, #01, &code_list_03B2C9 )

  loc_03B2C7:
    COP [RestoreSavedPtr]
}

code_list_03B2C9 [
  &code_03B6E5   ;00
  &code_03B6E5   ;01
  &code_03B6D1   ;02
]

widestring_03B2CF `[TPL:11][SFX:0] やめる[N] 水上都市ウォ-タミア`

code_03B2EA {
    COP [PrintWideString] ( &widestring_03B2FC )
    COP [DialogueOptions] ( #02, #01, &code_list_03B2F6 )

  loc_03B2F4:
    COP [RestoreSavedPtr]
}

code_list_03B2F6 [
  &code_03B6D5   ;00
  &code_03B6D5   ;01
  &code_03B6E1   ;02
]

widestring_03B2FC `[TPL:11][SFX:0] やめる[N] だ天使の町`

code_03B30F {
    COP [PrintWideString] ( &widestring_03B323 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B31B )

  loc_03B319:
    COP [RestoreSavedPtr]
}

code_list_03B31B [
  &code_03B705   ;00
  &code_03B705   ;01
  &code_03B6F1   ;02
  &code_03B6E1   ;03
]

widestring_03B323 `[TPL:11][SFX:0] やめる     だ天使の町[N] 万里の長城`

code_03B344 {
    COP [PrintWideString] ( &widestring_03B356 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B350 )

  loc_03B34E:
    COP [RestoreSavedPtr]
}

code_list_03B350 [
  &code_03B6F5   ;00
  &code_03B6F5   ;01
  &code_03B701   ;02
]

widestring_03B356 `[TPL:11][SFX:0] やめる[N] ウォ-タミア`

code_03B369 {
    COP [PrintWideString] ( &widestring_03B37F )
    COP [DialogueOptions] ( #42, #01, &code_list_03B375 )

  loc_03B373:
    COP [RestoreSavedPtr]
}

code_list_03B375 [
  &code_03B705   ;00
  &code_03B705   ;01
  &code_03B6F1   ;02
  &code_03B6E1   ;03
  &code_03B711   ;04
]

widestring_03B37F `[TPL:11][SFX:0] やめる     だ天使の町[N] 万里の長城   大都市エウロ`

code_03B3AE {
    COP [PrintWideString] ( &widestring_03B3C0 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B3BA )

  loc_03B3B8:
    COP [RestoreSavedPtr]
}

code_list_03B3BA [
  &code_03B71B   ;00
  &code_03B71B   ;01
  &code_03B727   ;02
]

widestring_03B3C0 `[TPL:11][SFX:0] やめる[N] ウォ-タミア`

code_03B3D3 {
    COP [PrintWideString] ( &widestring_03B3E7 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B3DF )

  loc_03B3DD:
    COP [RestoreSavedPtr]
}

code_list_03B3DF [
  &code_03B71B   ;00
  &code_03B71B   ;01
  &code_03B727   ;02
  &code_03B73D   ;03
]

widestring_03B3E7 `[TPL:11][SFX:0] やめる     山の聖域[N] ウォ-タミア`

code_03B406 {
    COP [PrintWideString] ( &widestring_03B418 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B412 )

  loc_03B410:
    COP [RestoreSavedPtr]
}

code_list_03B412 [
  &code_03B741   ;00
  &code_03B741   ;01
  &code_03B74D   ;02
]

widestring_03B418 `[TPL:11][SFX:0] やめる[N] 大都市エウロ`

code_03B42E {
    COP [PrintWideString] ( &widestring_03B440 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B43A )

  loc_03B438:
    COP [RestoreSavedPtr]
}

code_list_03B43A [
  &code_03B761   ;00
  &code_03B761   ;01
  &code_03B76D   ;02
]

widestring_03B440 `[TPL:11][SFX:0] やめる[N] 大都市エウロ`

code_03B456 {
    COP [PrintWideString] ( &widestring_03B46A )
    COP [DialogueOptions] ( #32, #01, &code_list_03B462 )

  loc_03B460:
    COP [RestoreSavedPtr]
}

code_list_03B462 [
  &code_03B761   ;00
  &code_03B761   ;01
  &code_03B76D   ;02
  &code_03B77D   ;03
]

widestring_03B46A `[TPL:11][SFX:0] やめる     アンコールワット[N] 大都市エウロ`

code_03B48F {
    COP [PrintWideString] ( &widestring_03B4A1 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B49B )

  loc_03B499:
    COP [RestoreSavedPtr]
}

code_list_03B49B [
  &code_03B781   ;00
  &code_03B781   ;01
  &code_03B78D   ;02
]

widestring_03B4A1 `[TPL:11][SFX:0] やめる[N] 原住民の村落`

code_03B4B7 {
    COP [PrintWideString] ( &widestring_03B2B4 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B4C3 )

  loc_03B4C1:
    COP [RestoreSavedPtr]
}

code_list_03B4C3 [
  &code_03B6E5   ;00
  &code_03B6E5   ;01
]

code_03B4C7 {
    COP [PrintWideString] ( &widestring_03B4D9 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4D3 )

  loc_03B4D1:
    COP [RestoreSavedPtr]
}

code_list_03B4D3 [
  &code_03B7C1   ;00
  &code_03B7C1   ;01
  &code_03B79D   ;02
]

widestring_03B4D9 `[TPL:11][SFX:0] やめる[N] 原住民の村落`

code_03B4EF {
    COP [PrintWideString] ( &widestring_03B503 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B4FB )

  loc_03B4F9:
    COP [RestoreSavedPtr]
}

code_list_03B4FB [
  &code_03B7C1   ;00
  &code_03B7C1   ;01
  &code_03B79D   ;02
  &code_03B7AD   ;03
]

widestring_03B503 `[TPL:11][SFX:0] やめる     ピラミッド[N] 原住民の村落`

code_03B525 {
    COP [PrintWideString] ( &widestring_03B537 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B531 )

  loc_03B52F:
    COP [RestoreSavedPtr]
}

code_list_03B531 [
  &code_03B7B1   ;00
  &code_03B7B1   ;01
  &code_03B7CD   ;02
]

widestring_03B537 `[TPL:11][SFX:0] やめる[N] さばくの町ダオ`

code_03B54C {
    COP [PrintWideString] ( &widestring_03B562 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B558 )

  loc_03B556:
    COP [RestoreSavedPtr]
}

code_list_03B558 [
  &code_03B761   ;00
  &code_03B761   ;01
  &code_03B76D   ;02
  &code_03B77D   ;03
  &code_03B7BD   ;04
]

widestring_03B562 `[TPL:11][SFX:0] やめる     アンコールワット[N] 大都市エウロ  さばくの町ダオ`

code_03B593 {
    COP [PrintWideString] ( &widestring_03B5A9 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B59F )

  loc_03B59D:
    COP [RestoreSavedPtr]
}

code_list_03B59F [
  &code_03B71B   ;00
  &code_03B71B   ;01
  &code_03B727   ;02
  &code_03B73D   ;03
  &code_03B75D   ;04
]

widestring_03B5A9 `[TPL:11][SFX:0] やめる     山の聖域[N] ウォ-タミア  原住民の村落`

code_03B5D5 {
    COP [PrintWideString] ( &widestring_03B2B4 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B5E1 )

  loc_03B5DF:
    COP [RestoreSavedPtr]
}

code_list_03B5E1 [
  &code_03B655   ;00
  &code_03B655   ;01
]

code_03B5E5 {
    COP [PrintWideString] ( &widestring_03B62A )
    COP [RestoreSavedPtr]
}

code_03B5EB {
    COP [PrintWideString] ( &widestring_03B62D )
    COP [RestoreSavedPtr]
}

code_03B5F1 {
    COP [PrintWideString] ( &widestring_03B630 )
    COP [RestoreSavedPtr]
}

code_03B5F7 {
    COP [PrintWideString] ( &widestring_03B633 )
    COP [RestoreSavedPtr]
}

code_03B5FD {
    COP [PrintWideString] ( &widestring_03B636 )
    COP [RestoreSavedPtr]
}

code_03B603 {
    COP [PrintWideString] ( &widestring_03B639 )
    COP [RestoreSavedPtr]
}

code_03B609 {
    COP [PrintWideString] ( &widestring_03B63C )
    COP [RestoreSavedPtr]
}

code_03B60F {
    COP [PrintWideString] ( &widestring_03B63F )
    COP [RestoreSavedPtr]
}

code_03B615 {
    COP [PrintWideString] ( &widestring_03B642 )
    COP [RestoreSavedPtr]
}

code_03B61B {
    COP [PrintWideString] ( &widestring_03B645 )
    COP [RestoreSavedPtr]
}

code_03B621 {
    COP [PrintWideString] ( &widestring_03B648 )
    COP [RestoreSavedPtr]

  loc_03B627:
    REP #$11
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    CPY $11C2
    EOR $4F0A, Y
    BIT $7D7D, X
    CPY #$6702
    BRK #$02
}

code_03B655 {
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

code_03B661 {
    COP [StageWorldMapMoveIds] ( #00, #01 )
}

code_03B665 {
    COP [QueueMapChange] ( #0A, #$01F8, #$02C0, #00, #$3420 )
    COP [RestoreSavedPtr]
}

code_03B671 {
    COP [StageWorldMapMoveIds] ( #00, #03 )
}

code_03B675 {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

code_03B681 {
    COP [StageWorldMapMoveIds] ( #00, #04 )
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

code_03B691 {
    COP [StageWorldMapMoveIds] ( #00, #08 )
}

code_03B695 {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

code_03B6A1 {
    COP [StageWorldMapMoveIds] ( #00, #07 )
}

code_03B6A5 {
    COP [QueueMapChange] ( #1C, #$0068, #$01A0, #80, #$2200 )
    COP [RestoreSavedPtr]
}

code_03B6B1 {
    COP [StageWorldMapMoveIds] ( #00, #0A )
}

code_03B6B5 {
    COP [QueueMapChange] ( #3E, #$00A8, #$03D0, #80, #$4200 )
    COP [RestoreSavedPtr]
}

code_03B6C1 {
    COP [StageWorldMapMoveIds] ( #00, #0B )
}

code_03B6C5 {
    COP [QueueMapChange] ( #32, #$0130, #$0350, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B6D1 {
    COP [StageWorldMapMoveIds] ( #00, #11 )
}

code_03B6D5 {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B6E1 {
    COP [StageWorldMapMoveIds] ( #00, #12 )
}

code_03B6E5 {
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    COP [RestoreSavedPtr]
}

code_03B6F1 {
    COP [StageWorldMapMoveIds] ( #00, #13 )
}

code_03B6F5 {
    COP [QueueMapChange] ( #82, #$0020, #$0090, #87, #$1800 )
    COP [RestoreSavedPtr]
}

code_03B701 {
    COP [StageWorldMapMoveIds] ( #00, #14 )
}

code_03B705 {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B711 {
    LDA #$0007
    STA $0D60
    COP [StageWorldMapMoveIds] ( #00, #15 )
}

code_03B71B {
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03B727 {
    LDA #$0007
    STA $0D60
    COP [StageWorldMapMoveIds] ( #00, #16 )
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B73D {
    COP [StageWorldMapMoveIds] ( #00, #17 )
}

code_03B741 {
    COP [QueueMapChange] ( #A0, #$02C8, #$01B0, #86, #$2300 )
    COP [RestoreSavedPtr]
}

code_03B74D {
    COP [StageWorldMapMoveIds] ( #00, #18 )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03B75D {
    COP [StageWorldMapMoveIds] ( #00, #19 )
}

code_03B761 {
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03B76D {
    COP [StageWorldMapMoveIds] ( #00, #1A )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03B77D {
    COP [StageWorldMapMoveIds] ( #00, #1B )
}

code_03B781 {
    COP [QueueMapChange] ( #B0, #$01F8, #$04C0, #80, #$5400 )
    COP [RestoreSavedPtr]
}

code_03B78D {
    COP [StageWorldMapMoveIds] ( #00, #1C )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03B79D {
    COP [StageWorldMapMoveIds] ( #00, #20 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03B7AD {
    COP [StageWorldMapMoveIds] ( #00, #1E )
}

code_03B7B1 {
    COP [QueueMapChange] ( #CC, #$0010, #$00D0, #87, #$4400 )
    COP [RestoreSavedPtr]
}

code_03B7BD {
    COP [StageWorldMapMoveIds] ( #00, #1D )
}

code_03B7C1 {
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}

code_03B7CD {
    COP [StageWorldMapMoveIds] ( #00, #1F )
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}