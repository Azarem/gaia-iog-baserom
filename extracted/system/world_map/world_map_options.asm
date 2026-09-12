?BANK 03

---------------------------------------------

world_map_options [
  &code_03B44F   ;00
  &code_03B451   ;01
  &code_03B47D   ;02
  &code_03B4A8   ;03
  &code_03B4CC   ;04
  &code_03B4F0   ;05
  &code_03B51A   ;06
  &code_03B53F   ;07
  &code_03B563   ;08
  &code_03B587   ;09
  &code_03B5A1   ;0A
  &code_03B5C7   ;0B
  &code_03B5F2   ;0C
  &code_03B62A   ;0D
  &code_03B650   ;0E
  &code_03B697   ;0F
  &code_03B6BD   ;10
  &code_03B6F3   ;11
  &code_03B719   ;12
  &code_03B73F   ;13
  &code_03B778   ;14
  &code_03B7A5   ;15
  &code_03B7B5   ;16
  &code_03B7E2   ;17
  &code_03B81A   ;18
  &code_03B843   ;19
  &code_03B88C   ;1A
  &code_03B8D6   ;1B
  &code_03B8E6   ;1C
  &code_03B8EC   ;1D
  &code_03B8F2   ;1E
  &code_03B8F8   ;1F
  &code_03B8FE   ;20
  &code_03B904   ;21
  &code_03B90A   ;22
  &code_03B910   ;23
  &code_03B916   ;24
  &code_03B91C   ;25
  &code_03B922   ;26
]

code_03B44F {
    COP [RestoreSavedPtr]
}

code_03B451 {
    COP [PrintDialogString] ( &dialogstring_03B463 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B45D )

  loc_03B45B:
    COP [RestoreSavedPtr]
}

code_list_03B45D [
  &code_03B959   ;00
  &code_03B959   ;01
  &code_03B965   ;02
]

dialogstring_03B463 `[TPL:11][SFX:0] Quit [N] Edward's Castle `

code_03B47D {
    COP [PrintDialogString] ( &dialogstring_03B48F )
    COP [DialogueOptions] ( #02, #01, &code_list_03B489 )

  loc_03B487:
    COP [RestoreSavedPtr]
}

code_list_03B489 [
  &code_03B959   ;00
  &code_03B959   ;01
  &code_03B975   ;02
]

dialogstring_03B48F `[TPL:11][SFX:0] Quit [N] Itory Village `

code_03B4A8 {
    COP [PrintDialogString] ( &dialogstring_03B4BA )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4B4 )

  loc_03B4B2:
    COP [RestoreSavedPtr]
}

code_list_03B4B4 [
  &code_03B969   ;00
  &code_03B969   ;01
  &code_03B955   ;02
]

dialogstring_03B4BA `[TPL:11][SFX:0] Quit[N] South Cape`

code_03B4CC {
    COP [PrintDialogString] ( &dialogstring_03B4DE )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4D8 )

  loc_03B4D6:
    COP [RestoreSavedPtr]
}

code_list_03B4D8 [
  &code_03B979   ;00
  &code_03B979   ;01
  &code_03B985   ;02
]

dialogstring_03B4DE `[TPL:11][SFX:0] Quit[N] South Cape`

code_03B4F0 {
    COP [PrintDialogString] ( &dialogstring_03B502 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4FC )

  loc_03B4FA:
    COP [RestoreSavedPtr]
}

code_list_03B4FC [
  &code_03B9A9   ;00
  &code_03B9A9   ;01
  &code_03B995   ;02
]

dialogstring_03B502 `[TPL:11][SFX:0] Quit [N] Itory Village `

code_03B51A {
    COP [PrintDialogString] ( &dialogstring_03B52C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B526 )

  loc_03B524:
    COP [RestoreSavedPtr]
}

code_list_03B526 [
  &code_03B999   ;00
  &code_03B999   ;01
  &code_03B9A5   ;02
]

dialogstring_03B52C `[TPL:11][SFX:0] Quit[N] Inca Ruins`

code_03B53F {
    COP [PrintDialogString] ( &dialogstring_03B551 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B54B )

  loc_03B549:
    COP [RestoreSavedPtr]
}

code_list_03B54B [
  &code_03B9C9   ;00
  &code_03B9C9   ;01
  &code_03B9B5   ;02
]

dialogstring_03B551 `[TPL:11][SFX:0] Quit[N] Diamond Mine`

code_03B563 {
    COP [PrintDialogString] ( &dialogstring_03B575 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B56F )

  loc_03B56D:
    COP [RestoreSavedPtr]
}

code_list_03B56F [
  &code_03B9B9   ;00
  &code_03B9B9   ;01
  &code_03B9C5   ;02
]

dialogstring_03B575 `[TPL:11][SFX:0] Quit [N] Freejia `

code_03B587 {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B593 )

  loc_03B591:
    COP [RestoreSavedPtr]
}

code_list_03B593 [
  &code_03B9C9   ;00
  &code_03B9C9   ;01
]

dialogstring_03B597 `[TPL:11][SFX:0] Quit`

code_03B5A1 {
    COP [PrintDialogString] ( &dialogstring_03B5B3 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B5AD )

  loc_03B5AB:
    COP [RestoreSavedPtr]
}

code_list_03B5AD [
  &code_03B9E9   ;00
  &code_03B9E9   ;01
  &code_03B9D5   ;02
]

dialogstring_03B5B3 `[TPL:11][SFX:0] Quit[N] Watermia`

code_03B5C7 {
    COP [PrintDialogString] ( &dialogstring_03B5D9 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B5D3 )

  loc_03B5D1:
    COP [RestoreSavedPtr]
}

code_list_03B5D3 [
  &code_03B9D9   ;00
  &code_03B9D9   ;01
  &code_03B9E5   ;02
]

dialogstring_03B5D9 `[TPL:11][SFX:0] Quit[N] Angel Village`

code_03B5F2 {
    COP [PrintDialogString] ( &dialogstring_03B606 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B5FE )

  loc_03B5FC:
    COP [RestoreSavedPtr]
}

code_list_03B5FE [
  &code_03BA09   ;00
  &code_03BA09   ;01
  &code_03B9F5   ;02
  &code_03B9E5   ;03
]

dialogstring_03B606 `[TPL:11][SFX:0] Quit        Angel Village[N] Great Wall`

code_03B62A {
    COP [PrintDialogString] ( &dialogstring_03B63C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B636 )

  loc_03B634:
    COP [RestoreSavedPtr]
}

code_list_03B636 [
  &code_03B9F9   ;00
  &code_03B9F9   ;01
  &code_03BA05   ;02
]

dialogstring_03B63C `[TPL:11][SFX:0] Quit[N] Watermia`

code_03B650 {
    COP [PrintDialogString] ( &dialogstring_03B666 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B65C )

  loc_03B65A:
    COP [RestoreSavedPtr]
}

code_list_03B65C [
  &code_03BA09   ;00
  &code_03BA09   ;01
  &code_03B9F5   ;02
  &code_03B9E5   ;03
  &code_03BA15   ;04
]

dialogstring_03B666 `[TPL:11][SFX:0] Quit        Angel Village [N] Great Wall  Euro city `

code_03B697 {
    COP [PrintDialogString] ( &dialogstring_03B6A9 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B6A3 )

  loc_03B6A1:
    COP [RestoreSavedPtr]
}

code_list_03B6A3 [
  &code_03BA1F   ;00
  &code_03BA1F   ;01
  &code_03BA2B   ;02
]

dialogstring_03B6A9 `[TPL:11][SFX:0] Quit[N] Watermia`

code_03B6BD {
    COP [PrintDialogString] ( &dialogstring_03B6D1 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B6C9 )

  loc_03B6C7:
    COP [RestoreSavedPtr]
}

code_list_03B6C9 [
  &code_03BA1F   ;00
  &code_03BA1F   ;01
  &code_03BA2B   ;02
  &code_03BA41   ;03
]

dialogstring_03B6D1 `[TPL:11][SFX:0] Quit        Mt.Temple[N] Watermia`

code_03B6F3 {
    COP [PrintDialogString] ( &dialogstring_03B705 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B6FF )

  loc_03B6FD:
    COP [RestoreSavedPtr]
}

code_list_03B6FF [
  &code_03BA45   ;00
  &code_03BA45   ;01
  &code_03BA51   ;02
]

dialogstring_03B705 `[TPL:11][SFX:0] Quit [N] Euro city `

code_03B719 {
    COP [PrintDialogString] ( &dialogstring_03B72B )
    COP [DialogueOptions] ( #02, #01, &code_list_03B725 )

  loc_03B723:
    COP [RestoreSavedPtr]
}

code_list_03B725 [
  &code_03BA65   ;00
  &code_03BA65   ;01
  &code_03BA71   ;02
]

dialogstring_03B72B `[TPL:11][SFX:0] Quit [N] Euro city `

code_03B73F {
    COP [PrintDialogString] ( &dialogstring_03B753 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B74B )

  loc_03B749:
    COP [RestoreSavedPtr]
}

code_list_03B74B [
  &code_03BA65   ;00
  &code_03BA65   ;01
  &code_03BA71   ;02
  &code_03BA81   ;03
]

dialogstring_03B753 `[TPL:11][SFX:0] Quit        Ankor Wat [N] Euro city `

code_03B778 {
    COP [PrintDialogString] ( &dialogstring_03B78A )
    COP [DialogueOptions] ( #02, #01, &code_list_03B784 )

  loc_03B782:
    COP [RestoreSavedPtr]
}

code_list_03B784 [
  &code_03BA85   ;00
  &code_03BA85   ;01
  &code_03BA91   ;02
]

dialogstring_03B78A `[TPL:11][SFX:0] Quit [N] Natives' Village `

code_03B7A5 {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B7B1 )

  loc_03B7AF:
    COP [RestoreSavedPtr]
}

code_list_03B7B1 [
  &code_03B9E9   ;00
  &code_03B9E9   ;01
]

code_03B7B5 {
    COP [PrintDialogString] ( &dialogstring_03B7C7 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B7C1 )

  loc_03B7BF:
    COP [RestoreSavedPtr]
}

code_list_03B7C1 [
  &code_03BAC5   ;00
  &code_03BAC5   ;01
  &code_03BAA1   ;02
]

dialogstring_03B7C7 `[TPL:11][SFX:0] Quit [N] Natives' Village `

code_03B7E2 {
    COP [PrintDialogString] ( &dialogstring_03B7F6 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B7EE )

  loc_03B7EC:
    COP [RestoreSavedPtr]
}

code_list_03B7EE [
  &code_03BAC5   ;00
  &code_03BAC5   ;01
  &code_03BAA1   ;02
  &code_03BAB1   ;03
]

dialogstring_03B7F6 `[TPL:11][SFX:0] Quit        Pyramid [N] Natives' Village `

code_03B81A {
    COP [PrintDialogString] ( &dialogstring_03B82C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B826 )

  loc_03B824:
    COP [RestoreSavedPtr]
}

code_list_03B826 [
  &code_03BAB5   ;00
  &code_03BAB5   ;01
  &code_03BAD1   ;02
]

dialogstring_03B82C `[TPL:11][SFX:0] Quit[N] Dao Village`

code_03B843 {
    COP [PrintDialogString] ( &dialogstring_03B859 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B84F )

  loc_03B84D:
    COP [RestoreSavedPtr]
}

code_list_03B84F [
  &code_03BA65   ;00
  &code_03BA65   ;01
  &code_03BA71   ;02
  &code_03BA81   ;03
  &code_03BAC1   ;04
]

dialogstring_03B859 `[TPL:11][SFX:0] Quit        Ankor Wat [N] Euro city   Dao Village `

code_03B88C {
    COP [PrintDialogString] ( &dialogstring_03B8A2 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B898 )

  loc_03B896:
    COP [RestoreSavedPtr]
}

code_list_03B898 [
  &code_03BA1F   ;00
  &code_03BA1F   ;01
  &code_03BA2B   ;02
  &code_03BA41   ;03
  &code_03BA61   ;04
]

dialogstring_03B8A2 `[TPL:11][SFX:0] Quit        Mt.Temple [N] Watermia    Natives' Vil.`

code_03B8D6 {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B8E2 )

  loc_03B8E0:
    COP [RestoreSavedPtr]
}

code_list_03B8E2 [
  &code_03B959   ;00
  &code_03B959   ;01
]

code_03B8E6 {
    COP [PrintDialogString] ( &dialogstring_03B92B )
    COP [RestoreSavedPtr]
}

code_03B8EC {
    COP [PrintDialogString] ( &dialogstring_03B92E )
    COP [RestoreSavedPtr]
}

code_03B8F2 {
    COP [PrintDialogString] ( &dialogstring_03B931 )
    COP [RestoreSavedPtr]
}

code_03B8F8 {
    COP [PrintDialogString] ( &dialogstring_03B934 )
    COP [RestoreSavedPtr]
}

code_03B8FE {
    COP [PrintDialogString] ( &dialogstring_03B937 )
    COP [RestoreSavedPtr]
}

code_03B904 {
    COP [PrintDialogString] ( &dialogstring_03B93A )
    COP [RestoreSavedPtr]
}

code_03B90A {
    COP [PrintDialogString] ( &dialogstring_03B93D )
    COP [RestoreSavedPtr]
}

code_03B910 {
    COP [PrintDialogString] ( &dialogstring_03B940 )
    COP [RestoreSavedPtr]
}

code_03B916 {
    COP [PrintDialogString] ( &dialogstring_03B943 )
    COP [RestoreSavedPtr]
}

code_03B91C {
    COP [PrintDialogString] ( &dialogstring_03B946 )
    COP [RestoreSavedPtr]
}

code_03B922 {
    COP [PrintDialogString] ( &dialogstring_03B949 )
    COP [RestoreSavedPtr]

  loc_03B928:
    REP #$11
    DEX 
}

dialogstring_03B92B `[TPL:11]`

dialogstring_03B92E `[TPL:11]`

dialogstring_03B931 `[TPL:11]`

dialogstring_03B934 `[TPL:11]`

dialogstring_03B937 `[TPL:11]`

dialogstring_03B93A `[TPL:11]`

dialogstring_03B93D `[TPL:11]`

dialogstring_03B940 `[TPL:11]`

dialogstring_03B943 `[TPL:11]`

dialogstring_03B946 `[TPL:11]`

dialogstring_03B949 `[TPL:11]Nothing!![END]`

code_03B955 {
    COP [StageWorldMapMoveIds] ( #00, #02 )
}

code_03B959 {
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

code_03B965 {
    COP [StageWorldMapMoveIds] ( #00, #01 )
}

code_03B969 {
    COP [QueueMapChange] ( #0A, #$01F8, #$02C0, #00, #$3420 )
    COP [RestoreSavedPtr]
}

code_03B975 {
    COP [StageWorldMapMoveIds] ( #00, #03 )
}

code_03B979 {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

code_03B985 {
    COP [StageWorldMapMoveIds] ( #00, #04 )
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

code_03B995 {
    COP [StageWorldMapMoveIds] ( #00, #08 )
}

code_03B999 {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

code_03B9A5 {
    COP [StageWorldMapMoveIds] ( #00, #07 )
}

code_03B9A9 {
    COP [QueueMapChange] ( #1C, #$0068, #$01A0, #80, #$2200 )
    COP [RestoreSavedPtr]
}

code_03B9B5 {
    COP [StageWorldMapMoveIds] ( #00, #0A )
}

code_03B9B9 {
    COP [QueueMapChange] ( #3E, #$00A8, #$03D0, #80, #$4200 )
    COP [RestoreSavedPtr]
}

code_03B9C5 {
    COP [StageWorldMapMoveIds] ( #00, #0B )
}

code_03B9C9 {
    COP [QueueMapChange] ( #32, #$0130, #$0350, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B9D5 {
    COP [StageWorldMapMoveIds] ( #00, #11 )
}

code_03B9D9 {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03B9E5 {
    COP [StageWorldMapMoveIds] ( #00, #12 )
}

code_03B9E9 {
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    COP [RestoreSavedPtr]
}

code_03B9F5 {
    COP [StageWorldMapMoveIds] ( #00, #13 )
}

code_03B9F9 {
    COP [QueueMapChange] ( #82, #$0020, #$0090, #87, #$1800 )
    COP [RestoreSavedPtr]
}

code_03BA05 {
    COP [StageWorldMapMoveIds] ( #00, #14 )
}

code_03BA09 {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03BA15 {
    LDA #$0007
    STA $0D60
    COP [StageWorldMapMoveIds] ( #00, #15 )
}

code_03BA1F {
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03BA2B {
    LDA #$0007
    STA $0D60
    COP [StageWorldMapMoveIds] ( #00, #16 )
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

code_03BA41 {
    COP [StageWorldMapMoveIds] ( #00, #17 )
}

code_03BA45 {
    COP [QueueMapChange] ( #A0, #$02C8, #$01B0, #86, #$2300 )
    COP [RestoreSavedPtr]
}

code_03BA51 {
    COP [StageWorldMapMoveIds] ( #00, #18 )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03BA61 {
    COP [StageWorldMapMoveIds] ( #00, #19 )
}

code_03BA65 {
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03BA71 {
    COP [StageWorldMapMoveIds] ( #00, #1A )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

code_03BA81 {
    COP [StageWorldMapMoveIds] ( #00, #1B )
}

code_03BA85 {
    COP [QueueMapChange] ( #B0, #$01F8, #$04C0, #80, #$5400 )
    COP [RestoreSavedPtr]
}

code_03BA91 {
    COP [StageWorldMapMoveIds] ( #00, #1C )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03BAA1 {
    COP [StageWorldMapMoveIds] ( #00, #20 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

code_03BAB1 {
    COP [StageWorldMapMoveIds] ( #00, #1E )
}

code_03BAB5 {
    COP [QueueMapChange] ( #CC, #$0010, #$00D0, #87, #$4400 )
    COP [RestoreSavedPtr]
}

code_03BAC1 {
    COP [StageWorldMapMoveIds] ( #00, #1D )
}

code_03BAC5 {
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}

code_03BAD1 {
    COP [StageWorldMapMoveIds] ( #00, #1F )
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}