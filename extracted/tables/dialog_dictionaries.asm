; Dual text compression dictionaries for dialog strings. Dictionary A ($D6 code, 256 common words) and Dictionary B ($D7 code, 256 extended words) provide ~512 compressed word slots for the dialog text system.
---------------------------------------------

---------------------------------------------

; First dialog text dictionary — pointer table of commonly used words/phrases for text compression. Control code $D6 DictionaryA reads a 1-byte index and recursively renders the string. Contains the most frequently used words (the, you, have, etc.). Part of IOG's dual-dictionary compression giving ~512 compressed word slots.

dialog_dictionary_a [
  &dialogstring_01EDA8   ;00
  &dialogstring_01EDB0   ;01
  &dialogstring_01EDB7   ;02
  &dialogstring_01EDBE   ;03
  &dialogstring_01EDC4   ;04
  &dialogstring_01EDCB   ;05
  &dialogstring_01EDD2   ;06
  &dialogstring_01EDD9   ;07
  &dialogstring_01EDE2   ;08
  &dialogstring_01EDE8   ;09
  &dialogstring_01EDEE   ;0A
  &dialogstring_01EDF8   ;0B
  &dialogstring_01EE00   ;0C
  &dialogstring_01EE06   ;0D
  &dialogstring_01EE0D   ;0E
  &dialogstring_01EE16   ;0F
  &dialogstring_01EE21   ;10
  &dialogstring_01EE28   ;11
  &dialogstring_01EE30   ;12
  &dialogstring_01EE36   ;13
  &dialogstring_01EE3E   ;14
  &dialogstring_01EE45   ;15
  &dialogstring_01EE50   ;16
  &dialogstring_01EE57   ;17
  &dialogstring_01EE60   ;18
  &dialogstring_01EE67   ;19
  &dialogstring_01EE6D   ;1A
  &dialogstring_01EE76   ;1B
  &dialogstring_01EE82   ;1C
  &dialogstring_01EE88   ;1D
  &dialogstring_01EE8E   ;1E
  &dialogstring_01EE94   ;1F
  &dialogstring_01EE9A   ;20
  &dialogstring_01EEA0   ;21
  &dialogstring_01EEA8   ;22
  &dialogstring_01EEB0   ;23
  &dialogstring_01EEB9   ;24
  &dialogstring_01EEBF   ;25
  &dialogstring_01EEC6   ;26
  &dialogstring_01EECC   ;27
  &dialogstring_01EED2   ;28
  &dialogstring_01EEDA   ;29
  &dialogstring_01EEE3   ;2A
  &dialogstring_01EEEB   ;2B
  &dialogstring_01EEF2   ;2C
  &dialogstring_01EEF9   ;2D
  &dialogstring_01EF01   ;2E
  &dialogstring_01EF08   ;2F
  &dialogstring_01EF11   ;30
  &dialogstring_01EF18   ;31
  &dialogstring_01EF1E   ;32
  &dialogstring_01EF24   ;33
  &dialogstring_01EF2E   ;34
  &dialogstring_01EF36   ;35
  &dialogstring_01EF3F   ;36
  &dialogstring_01EF46   ;37
  &dialogstring_01EF4E   ;38
  &dialogstring_01EF54   ;39
  &dialogstring_01EF5A   ;3A
  &dialogstring_01EF60   ;3B
  &dialogstring_01EF68   ;3C
  &dialogstring_01EF70   ;3D
  &dialogstring_01EF78   ;3E
  &dialogstring_01EF80   ;3F
  &dialogstring_01EF89   ;40
  &dialogstring_01EF97   ;41
  &dialogstring_01EF9E   ;42
  &dialogstring_01EFA4   ;43
  &dialogstring_01EFAA   ;44
  &dialogstring_01EFB1   ;45
  &dialogstring_01EFBB   ;46
  &dialogstring_01EFC4   ;47
  &dialogstring_01EFCB   ;48
  &dialogstring_01EFD3   ;49
  &dialogstring_01EFDC   ;4A
  &dialogstring_01EFE7   ;4B
  &dialogstring_01EFF2   ;4C
  &dialogstring_01EFFC   ;4D
  &dialogstring_01F005   ;4E
  &dialogstring_01F00B   ;4F
  &dialogstring_01F012   ;50
  &dialogstring_01F01B   ;51
  &dialogstring_01F023   ;52
  &dialogstring_01F02A   ;53
  &dialogstring_01F032   ;54
  &dialogstring_01F039   ;55
  &dialogstring_01F03F   ;56
  &dialogstring_01F045   ;57
  &dialogstring_01F04B   ;58
  &dialogstring_01F052   ;59
  &dialogstring_01F058   ;5A
  &dialogstring_01F05F   ;5B
  &dialogstring_01F065   ;5C
  &dialogstring_01F06C   ;5D
  &dialogstring_01F075   ;5E
  &dialogstring_01F07C   ;5F
  &dialogstring_01F085   ;60
  &dialogstring_01F08F   ;61
  &dialogstring_01F095   ;62
  &dialogstring_01F09B   ;63
  &dialogstring_01F0A2   ;64
  &dialogstring_01F0AA   ;65
  &dialogstring_01F0B1   ;66
  &dialogstring_01F0B9   ;67
  &dialogstring_01F0C1   ;68
  &dialogstring_01F0C7   ;69
  &dialogstring_01F0CF   ;6A
  &dialogstring_01F0D5   ;6B
  &dialogstring_01F0DC   ;6C
  &dialogstring_01F0E6   ;6D
  &dialogstring_01F0EE   ;6E
  &dialogstring_01F0F7   ;6F
  &dialogstring_01F100   ;70
  &dialogstring_01F106   ;71
  &dialogstring_01F10E   ;72
  &dialogstring_01F114   ;73
  &dialogstring_01F11A   ;74
  &dialogstring_01F122   ;75
  &dialogstring_01F12B   ;76
  &dialogstring_01F136   ;77
  &dialogstring_01F13D   ;78
  &dialogstring_01F144   ;79
  &dialogstring_01F14A   ;7A
  &dialogstring_01F151   ;7B
  &dialogstring_01F158   ;7C
  &dialogstring_01F161   ;7D
  &dialogstring_01F16B   ;7E
  &dialogstring_01F17A   ;7F
  &dialogstring_01F183   ;80
  &dialogstring_01F189   ;81
  &dialogstring_01F191   ;82
  &dialogstring_01F198   ;83
  &dialogstring_01F1A0   ;84
  &dialogstring_01F1A9   ;85
  &dialogstring_01F1B2   ;86
  &dialogstring_01F1BD   ;87
  &dialogstring_01F1C5   ;88
  &dialogstring_01F1CE   ;89
  &dialogstring_01F1D8   ;8A
  &dialogstring_01F1E2   ;8B
  &dialogstring_01F1EE   ;8C
  &dialogstring_01F1F7   ;8D
  &dialogstring_01F200   ;8E
  &dialogstring_01F206   ;8F
  &dialogstring_01F20D   ;90
  &dialogstring_01F213   ;91
  &dialogstring_01F219   ;92
  &dialogstring_01F223   ;93
  &dialogstring_01F22A   ;94
  &dialogstring_01F230   ;95
  &dialogstring_01F237   ;96
  &dialogstring_01F23F   ;97
  &dialogstring_01F245   ;98
  &dialogstring_01F24B   ;99
  &dialogstring_01F252   ;9A
  &dialogstring_01F259   ;9B
  &dialogstring_01F25F   ;9C
  &dialogstring_01F265   ;9D
  &dialogstring_01F26F   ;9E
  &dialogstring_01F27B   ;9F
  &dialogstring_01F281   ;A0
  &dialogstring_01F28C   ;A1
  &dialogstring_01F292   ;A2
  &dialogstring_01F29A   ;A3
  &dialogstring_01F2A0   ;A4
  &dialogstring_01F2A6   ;A5
  &dialogstring_01F2AC   ;A6
  &dialogstring_01F2B2   ;A7
  &dialogstring_01F2BA   ;A8
  &dialogstring_01F2C1   ;A9
  &dialogstring_01F2C7   ;AA
  &dialogstring_01F2CE   ;AB
  &dialogstring_01F2D7   ;AC
  &dialogstring_01F2DE   ;AD
  &dialogstring_01F2E5   ;AE
  &dialogstring_01F2EB   ;AF
  &dialogstring_01F2F1   ;B0
  &dialogstring_01F2F7   ;B1
  &dialogstring_01F2FF   ;B2
  &dialogstring_01F305   ;B3
  &dialogstring_01F30B   ;B4
  &dialogstring_01F313   ;B5
  &dialogstring_01F319   ;B6
  &dialogstring_01F31F   ;B7
  &dialogstring_01F325   ;B8
  &dialogstring_01F32D   ;B9
  &dialogstring_01F336   ;BA
  &dialogstring_01F33C   ;BB
  &dialogstring_01F343   ;BC
  &dialogstring_01F349   ;BD
  &dialogstring_01F350   ;BE
  &dialogstring_01F356   ;BF
  &dialogstring_01F35F   ;C0
  &dialogstring_01F369   ;C1
  &dialogstring_01F371   ;C2
  &dialogstring_01F378   ;C3
  &dialogstring_01F382   ;C4
  &dialogstring_01F38B   ;C5
  &dialogstring_01F393   ;C6
  &dialogstring_01F39F   ;C7
  &dialogstring_01F3A8   ;C8
  &dialogstring_01F3B3   ;C9
  &dialogstring_01F3BB   ;CA
  &dialogstring_01F3C3   ;CB
  &dialogstring_01F3CC   ;CC
  &dialogstring_01F3D3   ;CD
  &dialogstring_01F3D9   ;CE
  &dialogstring_01F3DF   ;CF
  &dialogstring_01F3E8   ;D0
  &dialogstring_01F3EE   ;D1
  &dialogstring_01F3F4   ;D2
  &dialogstring_01F3FD   ;D3
  &dialogstring_01F404   ;D4
  &dialogstring_01F40A   ;D5
  &dialogstring_01F412   ;D6
  &dialogstring_01F418   ;D7
  &dialogstring_01F41E   ;D8
  &dialogstring_01F427   ;D9
  &dialogstring_01F42E   ;DA
  &dialogstring_01F435   ;DB
  &dialogstring_01F43E   ;DC
  &dialogstring_01F447   ;DD
  &dialogstring_01F44E   ;DE
  &dialogstring_01F458   ;DF
  &dialogstring_01F45E   ;E0
  &dialogstring_01F466   ;E1
  &dialogstring_01F46D   ;E2
  &dialogstring_01F473   ;E3
  &dialogstring_01F47A   ;E4
  &dialogstring_01F481   ;E5
  &dialogstring_01F489   ;E6
  &dialogstring_01F48F   ;E7
  &dialogstring_01F495   ;E8
  &dialogstring_01F49E   ;E9
  &dialogstring_01F4AA   ;EA
  &dialogstring_01F4B1   ;EB
  &dialogstring_01F4BD   ;EC
  &dialogstring_01F4C6   ;ED
  &dialogstring_01F4CC   ;EE
  &dialogstring_01F4D3   ;EF
  &dialogstring_01F4D9   ;F0
  &dialogstring_01F4DF   ;F1
  &dialogstring_01F4E5   ;F2
  &dialogstring_01F4EB   ;F3
  &dialogstring_01F4F2   ;F4
  &dialogstring_01F4F9   ;F5
  &dialogstring_01F500   ;F6
  &dialogstring_01F506   ;F7
  &dialogstring_01F50C   ;F8
  &dialogstring_01F515   ;F9
  &dialogstring_01F51D   ;FA
  &dialogstring_01F524   ;FB
  &dialogstring_01F52E   ;FC
  &dialogstring_01F536   ;FD
  &dialogstring_01F53F   ;FE
  &dialogstring_01F545   ;FF
]

dialogstring_01EDA8 `Attack `

dialogstring_01EDB0 `Angel `

dialogstring_01EDB7 `After `

dialogstring_01EDBE `Aura `

dialogstring_01EDC4 `Ankor `

dialogstring_01EDCB `Black `

dialogstring_01EDD2 `Bill: `

dialogstring_01EDD9 `Crystal `

dialogstring_01EDE2 `City `

dialogstring_01EDE8 `Come `

dialogstring_01EDEE `Condor's `

dialogstring_01EDF8 `Change `

dialogstring_01EE00 `Dark `

dialogstring_01EE06 `Don't `

dialogstring_01EE0D `Diamond `

dialogstring_01EE16 `Drifting, `

dialogstring_01EE21 `Eric: `

dialogstring_01EE28 `Edward `

dialogstring_01EE30 `Even `

dialogstring_01EE36 `Elder: `

dialogstring_01EE3E `Earth `

dialogstring_01EE45 `Freedan's `

dialogstring_01EE50 `Great `

dialogstring_01EE57 `Grandma `

dialogstring_01EE60 `Good. `

dialogstring_01EE67 `Gold `

dialogstring_01EE6D `Grandpa `

dialogstring_01EE76 `Hieroglyph `

dialogstring_01EE82 `Hey, `

dialogstring_01EE88 `It's `

dialogstring_01EE8E `Inca `

dialogstring_01EE94 `I'll `

dialogstring_01EE9A `I've `

dialogstring_01EEA0 `Itorie `

dialogstring_01EEA8 `Jewels `

dialogstring_01EEB0 `Jewels! `

dialogstring_01EEB9 `Just `

dialogstring_01EEBF `Kara: `

dialogstring_01EEC6 `Kara `

dialogstring_01EECC `King `

dialogstring_01EED2 `Knight `

dialogstring_01EEDA `Karen's `

dialogstring_01EEE3 `Lilly: `

dialogstring_01EEEB `Let's `

dialogstring_01EEF2 `Lilly `

dialogstring_01EEF9 `Lola's `

dialogstring_01EF01 `Lola: `

dialogstring_01EF08 `Mystery `

dialogstring_01EF11 `Maybe `

dialogstring_01EF18 `Moon `

dialogstring_01EF1E `Man: `

dialogstring_01EF24 `Morris's `

dialogstring_01EF2E `Melody `

dialogstring_01EF36 `Morris: `

dialogstring_01EF3F `Neil: `

dialogstring_01EF46 `Neil's `

dialogstring_01EF4E `Only `

dialogstring_01EF54 `Once `

dialogstring_01EF5A `Oink `

dialogstring_01EF60 `Please `

dialogstring_01EF68 `Psycho `

dialogstring_01EF70 `People `

dialogstring_01EF78 `Prayer `

dialogstring_01EF80 `Pyramid `

dialogstring_01EF89 `Purification `

dialogstring_01EF97 `Plate `

dialogstring_01EF9E `Quit `

dialogstring_01EFA4 `Rob: `

dialogstring_01EFAA `Rolek `

dialogstring_01EFB1 `Soldier: `

dialogstring_01EFBB `Strange `

dialogstring_01EFC4 `South `

dialogstring_01EFCB `Statue `

dialogstring_01EFD3 `Somehow `

dialogstring_01EFDC `Sometimes `

dialogstring_01EFE7 `Something `

dialogstring_01EFF2 `Shadow's `

dialogstring_01EFFC `Someone `

dialogstring_01F005 `This `

dialogstring_01F00B `Will: `

dialogstring_01F012 `There's `

dialogstring_01F01B `Will's `

dialogstring_01F023 `There `

dialogstring_01F02A `That's `

dialogstring_01F032 `Tower `

dialogstring_01F039 `They `

dialogstring_01F03F `Then `

dialogstring_01F045 `Trip `

dialogstring_01F04B `Thank `

dialogstring_01F052 `Take `

dialogstring_01F058 `Will. `

dialogstring_01F05F `That `

dialogstring_01F065 `Will, `

dialogstring_01F06C `They're `

dialogstring_01F075 `These `

dialogstring_01F07C `Vampire `

dialogstring_01F085 `Village. `

dialogstring_01F08F `When `

dialogstring_01F095 `What `

dialogstring_01F09B `Well, `

dialogstring_01F0A2 `What's `

dialogstring_01F0AA `Where `

dialogstring_01F0B1 `Woman: `

dialogstring_01F0B9 `You've `

dialogstring_01F0C1 `Your `

dialogstring_01F0C7 `You're `

dialogstring_01F0CF `Yes, `

dialogstring_01F0D5 `about `

dialogstring_01F0DC `anything `

dialogstring_01F0E6 `around `

dialogstring_01F0EE `another `

dialogstring_01F0F7 `ancient `

dialogstring_01F100 `been `

dialogstring_01F106 `become `

dialogstring_01F10E `body `

dialogstring_01F114 `back `

dialogstring_01F11A `before `

dialogstring_01F122 `brought `

dialogstring_01F12B `beautiful `

dialogstring_01F136 `being `

dialogstring_01F13D `can't `

dialogstring_01F144 `come `

dialogstring_01F14A `could `

dialogstring_01F151 `comet `

dialogstring_01F158 `company `

dialogstring_01F161 `children `

dialogstring_01F16B `constellation `

dialogstring_01F17A `changed `

dialogstring_01F183 `came `

dialogstring_01F189 `coming `

dialogstring_01F191 `don't `

dialogstring_01F198 `didn't `

dialogstring_01F1A0 `doesn't `

dialogstring_01F1A9 `distant `

dialogstring_01F1B2 `different `

dialogstring_01F1BD `demons `

dialogstring_01F1C5 `destroy `

dialogstring_01F1CE `everyone `

dialogstring_01F1D8 `explorer `

dialogstring_01F1E2 `everyone's `

dialogstring_01F1EE `enemies `

dialogstring_01F1F7 `exposed `

dialogstring_01F200 `from `

dialogstring_01F206 `found `

dialogstring_01F20D `find `

dialogstring_01F213 `feel `

dialogstring_01F219 `father's `

dialogstring_01F223 `going `

dialogstring_01F22A `good `

dialogstring_01F230 `great `

dialogstring_01F237 `ground `

dialogstring_01F23F `give `

dialogstring_01F245 `have `

dialogstring_01F24B `heard `

dialogstring_01F252 `human `

dialogstring_01F259 `hear `

dialogstring_01F25F `huge `

dialogstring_01F265 `happened `

dialogstring_01F26F `hieroglyph `

dialogstring_01F27B `it's `

dialogstring_01F281 `inventory `

dialogstring_01F28C `into `

dialogstring_01F292 `inside `

dialogstring_01F29A `just `

dialogstring_01F2A0 `know `

dialogstring_01F2A6 `like `

dialogstring_01F2AC `long `

dialogstring_01F2B2 `little `

dialogstring_01F2BA `light `

dialogstring_01F2C1 `look `

dialogstring_01F2C7 `looks `

dialogstring_01F2CE `looking `

dialogstring_01F2D7 `leave `

dialogstring_01F2DE `labor `

dialogstring_01F2E5 `left `

dialogstring_01F2EB `live `

dialogstring_01F2F1 `life `

dialogstring_01F2F7 `living `

dialogstring_01F2FF `must `

dialogstring_01F305 `made `

dialogstring_01F30B `melody `

dialogstring_01F313 `move `

dialogstring_01F319 `many `

dialogstring_01F31F `more `

dialogstring_01F325 `matter `

dialogstring_01F32D `nothing `

dialogstring_01F336 `need `

dialogstring_01F33C `never `

dialogstring_01F343 `next `

dialogstring_01F349 `other `

dialogstring_01F350 `over `

dialogstring_01F356 `outside `

dialogstring_01F35F `original `

dialogstring_01F369 `people `

dialogstring_01F371 `power `

dialogstring_01F378 `present. `

dialogstring_01F382 `playing `

dialogstring_01F38B `raised `

dialogstring_01F393 `right-hand `

dialogstring_01F39F `strange `

dialogstring_01F3A8 `something `

dialogstring_01F3B3 `statue `

dialogstring_01F3BB `should `

dialogstring_01F3C3 `started `

dialogstring_01F3CC `seems `

dialogstring_01F3D3 `same `

dialogstring_01F3D9 `such `

dialogstring_01F3DF `someone `

dialogstring_01F3E8 `some `

dialogstring_01F3EE `save `

dialogstring_01F3F4 `statues `

dialogstring_01F3FD `still `

dialogstring_01F404 `said `

dialogstring_01F40A `stands `

dialogstring_01F412 `this `

dialogstring_01F418 `that `

dialogstring_01F41E `thought `

dialogstring_01F427 `there `

dialogstring_01F42E `think `

dialogstring_01F435 `there's `

dialogstring_01F43E `through `

dialogstring_01F447 `tried `

dialogstring_01F44E `terrible `

dialogstring_01F458 `time `

dialogstring_01F45E `things `

dialogstring_01F466 `their `

dialogstring_01F46D `town `

dialogstring_01F473 `thing `

dialogstring_01F47A `these `

dialogstring_01F481 `temple `

dialogstring_01F489 `them `

dialogstring_01F48F `take `

dialogstring_01F495 `turned, `

dialogstring_01F49E `understand `

dialogstring_01F4AA `under `

dialogstring_01F4B1 `underwater `

dialogstring_01F4BD `village `

dialogstring_01F4C6 `very `

dialogstring_01F4CC `voice `

dialogstring_01F4D3 `will `

dialogstring_01F4D9 `with `

dialogstring_01F4DF `want `

dialogstring_01F4E5 `were `

dialogstring_01F4EB `would `

dialogstring_01F4F2 `where `

dialogstring_01F4F9 `world `

dialogstring_01F500 `when `

dialogstring_01F506 `what `

dialogstring_01F50C `without `

dialogstring_01F515 `wonder `

dialogstring_01F51D `won't `

dialogstring_01F524 `wouldn't `

dialogstring_01F52E `wanted `

dialogstring_01F536 `waiting `

dialogstring_01F53F `your `

dialogstring_01F545 `you're `
---------------------------------------------

; Second dialog text dictionary — extended word list for less frequently used words and longer phrases. Triggered by control code $D7 DictionaryB. Functions identically to dictionary A but covers the second 256-word bank.

dialog_dictionary_b [
  &dialogstring_01F6DD   ;00
  &dialogstring_01F6E3   ;01
  &dialogstring_01F6EE   ;02
  &dialogstring_01F6F6   ;03
  &dialogstring_01F6FF   ;04
  &dialogstring_01F705   ;05
  &dialogstring_01F70D   ;06
  &dialogstring_01F718   ;07
  &dialogstring_01F720   ;08
  &dialogstring_01F728   ;09
  &dialogstring_01F733   ;0A
  &dialogstring_01F73A   ;0B
  &dialogstring_01F743   ;0C
  &dialogstring_01F74B   ;0D
  &dialogstring_01F756   ;0E
  &dialogstring_01F75E   ;0F
  &dialogstring_01F765   ;10
  &dialogstring_01F770   ;11
  &dialogstring_01F776   ;12
  &dialogstring_01F77D   ;13
  &dialogstring_01F785   ;14
  &dialogstring_01F78B   ;15
  &dialogstring_01F791   ;16
  &dialogstring_01F79A   ;17
  &dialogstring_01F7A4   ;18
  &dialogstring_01F7AD   ;19
  &dialogstring_01F7B4   ;1A
  &dialogstring_01F7BD   ;1B
  &dialogstring_01F7C3   ;1C
  &dialogstring_01F7CA   ;1D
  &dialogstring_01F7D2   ;1E
  &dialogstring_01F7DC   ;1F
  &dialogstring_01F7E4   ;20
  &dialogstring_01F7EA   ;21
  &dialogstring_01F7F2   ;22
  &dialogstring_01F7FC   ;23
  &dialogstring_01F802   ;24
  &dialogstring_01F809   ;25
  &dialogstring_01F810   ;26
  &dialogstring_01F818   ;27
  &dialogstring_01F81E   ;28
  &dialogstring_01F829   ;29
  &dialogstring_01F830   ;2A
  &dialogstring_01F83A   ;2B
  &dialogstring_01F844   ;2C
  &dialogstring_01F84B   ;2D
  &dialogstring_01F854   ;2E
  &dialogstring_01F85C   ;2F
  &dialogstring_01F867   ;30
  &dialogstring_01F870   ;31
  &dialogstring_01F876   ;32
  &dialogstring_01F87F   ;33
  &dialogstring_01F886   ;34
  &dialogstring_01F88D   ;35
  &dialogstring_01F894   ;36
  &dialogstring_01F89C   ;37
  &dialogstring_01F8A2   ;38
  &dialogstring_01F8A8   ;39
  &dialogstring_01F8AF   ;3A
  &dialogstring_01F8B8   ;3B
  &dialogstring_01F8BE   ;3C
  &dialogstring_01F8C4   ;3D
  &dialogstring_01F8CA   ;3E
  &dialogstring_01F8D1   ;3F
  &dialogstring_01F8D8   ;40
  &dialogstring_01F8DE   ;41
  &dialogstring_01F8E5   ;42
  &dialogstring_01F8EB   ;43
  &dialogstring_01F8F6   ;44
  &dialogstring_01F8FE   ;45
  &dialogstring_01F90B   ;46
  &dialogstring_01F914   ;47
  &dialogstring_01F91C   ;48
  &dialogstring_01F922   ;49
  &dialogstring_01F92D   ;4A
  &dialogstring_01F938   ;4B
  &dialogstring_01F940   ;4C
  &dialogstring_01F94A   ;4D
  &dialogstring_01F950   ;4E
  &dialogstring_01F957   ;4F
  &dialogstring_01F960   ;50
  &dialogstring_01F968   ;51
  &dialogstring_01F970   ;52
  &dialogstring_01F978   ;53
  &dialogstring_01F980   ;54
  &dialogstring_01F988   ;55
  &dialogstring_01F991   ;56
  &dialogstring_01F99D   ;57
  &dialogstring_01F9A3   ;58
  &dialogstring_01F9A9   ;59
  &dialogstring_01F9B4   ;5A
  &dialogstring_01F9C1   ;5B
  &dialogstring_01F9CD   ;5C
  &dialogstring_01F9D3   ;5D
  &dialogstring_01F9D9   ;5E
  &dialogstring_01F9E3   ;5F
  &dialogstring_01F9EE   ;60
  &dialogstring_01F9F4   ;61
  &dialogstring_01F9FB   ;62
  &dialogstring_01FA01   ;63
  &dialogstring_01FA0B   ;64
  &dialogstring_01FA15   ;65
  &dialogstring_01FA1C   ;66
  &dialogstring_01FA25   ;67
  &dialogstring_01FA2D   ;68
  &dialogstring_01FA35   ;69
  &dialogstring_01FA3D   ;6A
  &dialogstring_01FA45   ;6B
  &dialogstring_01FA4B   ;6C
  &dialogstring_01FA51   ;6D
  &dialogstring_01FA57   ;6E
  &dialogstring_01FA5E   ;6F
  &dialogstring_01FA66   ;70
  &dialogstring_01FA6D   ;71
  &dialogstring_01FA73   ;72
  &dialogstring_01FA79   ;73
  &dialogstring_01FA7F   ;74
  &dialogstring_01FA86   ;75
  &dialogstring_01FA8D   ;76
  &dialogstring_01FA99   ;77
  &dialogstring_01FAA1   ;78
  &dialogstring_01FAAC   ;79
  &dialogstring_01FAB2   ;7A
  &dialogstring_01FAB8   ;7B
  &dialogstring_01FAC3   ;7C
  &dialogstring_01FAC9   ;7D
  &dialogstring_01FAD0   ;7E
  &dialogstring_01FAD9   ;7F
  &dialogstring_01FAE1   ;80
  &dialogstring_01FAE9   ;81
  &dialogstring_01FAEF   ;82
  &dialogstring_01FAFA   ;83
  &dialogstring_01FB05   ;84
  &dialogstring_01FB0B   ;85
  &dialogstring_01FB13   ;86
  &dialogstring_01FB1E   ;87
  &dialogstring_01FB24   ;88
  &dialogstring_01FB2A   ;89
  &dialogstring_01FB30   ;8A
  &dialogstring_01FB37   ;8B
  &dialogstring_01FB3F   ;8C
  &dialogstring_01FB4A   ;8D
  &dialogstring_01FB55   ;8E
  &dialogstring_01FB5D   ;8F
  &dialogstring_01FB67   ;90
  &dialogstring_01FB6E   ;91
  &dialogstring_01FB76   ;92
  &dialogstring_01FB7E   ;93
  &dialogstring_01FB86   ;94
  &dialogstring_01FB8D   ;95
  &dialogstring_01FB95   ;96
  &dialogstring_01FB9F   ;97
  &dialogstring_01FBA8   ;98
  &dialogstring_01FBAF   ;99
  &dialogstring_01FBB7   ;9A
  &dialogstring_01FBBF   ;9B
  &dialogstring_01FBC5   ;9C
  &dialogstring_01FBCB   ;9D
  &dialogstring_01FBD2   ;9E
  &dialogstring_01FBD8   ;9F
  &dialogstring_01FBE3   ;A0
  &dialogstring_01FBEB   ;A1
  &dialogstring_01FBF3   ;A2
  &dialogstring_01FBFD   ;A3
  &dialogstring_01FC04   ;A4
  &dialogstring_01FC0B   ;A5
  &dialogstring_01FC16   ;A6
  &dialogstring_01FC1C   ;A7
  &dialogstring_01FC22   ;A8
  &dialogstring_01FC2D   ;A9
  &dialogstring_01FC38   ;AA
  &dialogstring_01FC3F   ;AB
  &dialogstring_01FC45   ;AC
  &dialogstring_01FC4B   ;AD
  &dialogstring_01FC51   ;AE
  &dialogstring_01FC5E   ;AF
  &dialogstring_01FC65   ;B0
  &dialogstring_01FC6E   ;B1
  &dialogstring_01FC7A   ;B2
  &dialogstring_01FC82   ;B3
  &dialogstring_01FC8A   ;B4
  &dialogstring_01FC95   ;B5
  &dialogstring_01FC9B   ;B6
  &dialogstring_01FCA1   ;B7
  &dialogstring_01FCA7   ;B8
  &dialogstring_01FCB2   ;B9
  &dialogstring_01FCB8   ;BA
  &dialogstring_01FCC3   ;BB
  &dialogstring_01FCC9   ;BC
  &dialogstring_01FCD0   ;BD
  &dialogstring_01FCDA   ;BE
  &dialogstring_01FCE3   ;BF
  &dialogstring_01FCEA   ;C0
  &dialogstring_01FCF1   ;C1
  &dialogstring_01FCF7   ;C2
  &dialogstring_01FD01   ;C3
  &dialogstring_01FD0A   ;C4
  &dialogstring_01FD11   ;C5
  &dialogstring_01FD17   ;C6
  &dialogstring_01FD1E   ;C7
]

dialogstring_01F6DD `1994 `

dialogstring_01F6E3 `Actually, `

dialogstring_01F6EE `Button `

dialogstring_01F6F6 `Buttons `

dialogstring_01F6FF `Back `

dialogstring_01F705 `Child: `

dialogstring_01F70D `Defeating `

dialogstring_01F718 `Didn't `

dialogstring_01F720 `Desert `

dialogstring_01F728 `Erasquez: `

dialogstring_01F733 `Elder `

dialogstring_01F73A `Earth's `

dialogstring_01F743 `Eric's `

dialogstring_01F74B `Everybody `

dialogstring_01F756 `Flute: `

dialogstring_01F75E `First `

dialogstring_01F765 `Firebird, `

dialogstring_01F770 `From `

dialogstring_01F776 `Gaia, `

dialogstring_01F77D `Gorgon `

dialogstring_01F785 `Have `

dialogstring_01F78B `Hey! `

dialogstring_01F791 `Istar's `

dialogstring_01F79A `Ishtar's `

dialogstring_01F7A4 `Lilly's `

dialogstring_01F7AD `Larai `

dialogstring_01F7B4 `Looking `

dialogstring_01F7BD `Main `

dialogstring_01F7C3 `Man's `

dialogstring_01F7CA `Memory `

dialogstring_01F7D2 `Mountain `

dialogstring_01F7DC `Morris `

dialogstring_01F7E4 `Many `

dialogstring_01F7EA `Native `

dialogstring_01F7F2 `Native's `

dialogstring_01F7FC `Neil `

dialogstring_01F802 `Naska `

dialogstring_01F809 `Power `

dialogstring_01F810 `Prison `

dialogstring_01F818 `Play `

dialogstring_01F81E `Panther's `

dialogstring_01F829 `Rob's `

dialogstring_01F830 `Recently `

dialogstring_01F83A `Restores `

dialogstring_01F844 `Right `

dialogstring_01F84B `Russian `

dialogstring_01F854 `Rofsky `

dialogstring_01F85C `Rearrange `

dialogstring_01F867 `Special `

dialogstring_01F870 `Spin `

dialogstring_01F876 `Seaside `

dialogstring_01F87F `She's `

dialogstring_01F886 `Shall `

dialogstring_01F88D `Sorry `

dialogstring_01F894 `Select `

dialogstring_01F89C `Show `

dialogstring_01F8A2 `Soon `

dialogstring_01F8A8 `Will! `

dialogstring_01F8AF `Will... `

dialogstring_01F8B8 `Tell `

dialogstring_01F8BE `Uses `

dialogstring_01F8C4 `Wind `

dialogstring_01F8CA `We'll `

dialogstring_01F8D1 `We're `

dialogstring_01F8D8 `With `

dialogstring_01F8DE `We've `

dialogstring_01F8E5 `Wait `

dialogstring_01F8EB `Watermia. `

dialogstring_01F8F6 `always `

dialogstring_01F8FE `approaching `

dialogstring_01F90B `animals `

dialogstring_01F914 `almost `

dialogstring_01F91C `also `

dialogstring_01F922 `anything. `

dialogstring_01F92D `abolition `

dialogstring_01F938 `breath `

dialogstring_01F940 `birthday `

dialogstring_01F94A `best `

dialogstring_01F950 `bring `

dialogstring_01F957 `bouquet `

dialogstring_01F960 `better `

dialogstring_01F968 `behind `

dialogstring_01F970 `change `

dialogstring_01F978 `castle `

dialogstring_01F980 `called `

dialogstring_01F988 `comet's `

dialogstring_01F991 `condition. `

dialogstring_01F99D `care `

dialogstring_01F9A3 `door `

dialogstring_01F9A9 `destroyed `

dialogstring_01F9B4 `disappeared `

dialogstring_01F9C1 `discovered `

dialogstring_01F9CD `dark `

dialogstring_01F9D3 `ever `

dialogstring_01F9D9 `elevator `

dialogstring_01F9E3 `explorer. `

dialogstring_01F9EE `eyes `

dialogstring_01F9F4 `first `

dialogstring_01F9FB `fish `

dialogstring_01FA01 `followed `

dialogstring_01FA0B `fountain `

dialogstring_01FA15 `floor `

dialogstring_01FA1C `finally `

dialogstring_01FA25 `father `

dialogstring_01FA2D `flower `

dialogstring_01FA35 `forced `

dialogstring_01FA3D `forget `

dialogstring_01FA45 `fate `

dialogstring_01FA4B `girl `

dialogstring_01FA51 `gets `

dialogstring_01FA57 `guess `

dialogstring_01FA5E `girl's `

dialogstring_01FA66 `house `

dialogstring_01FA6D `hope `

dialogstring_01FA73 `home `

dialogstring_01FA79 `here `

dialogstring_01FA7F `here. `

dialogstring_01FA86 `home! `

dialogstring_01FA8D `happen.... `

dialogstring_01FA99 `houses `

dialogstring_01FAA1 `inventing `

dialogstring_01FAAC `last `

dialogstring_01FAB2 `lost `

dialogstring_01FAB8 `language. `

dialogstring_01FAC3 `list `

dialogstring_01FAC9 `life. `

dialogstring_01FAD0 `laborer `

dialogstring_01FAD9 `letter `

dialogstring_01FAE1 `looked `

dialogstring_01FAE9 `lose `

dialogstring_01FAEF `left-hand `

dialogstring_01FAFA `mushrooms `

dialogstring_01FB05 `make `

dialogstring_01FB0B `mother `

dialogstring_01FB13 `merchants `

dialogstring_01FB1E `meet `

dialogstring_01FB24 `most `

dialogstring_01FB2A `only `

dialogstring_01FB30 `ocean `

dialogstring_01FB37 `opened `

dialogstring_01FB3F `outskirts `

dialogstring_01FB4A `president `

dialogstring_01FB55 `please `

dialogstring_01FB5D `probably `

dialogstring_01FB67 `place `

dialogstring_01FB6E `prison `

dialogstring_01FB76 `pretty `

dialogstring_01FB7E `palace `

dialogstring_01FB86 `right `

dialogstring_01FB8D `really `

dialogstring_01FB95 `returned `

dialogstring_01FB9F `running `

dialogstring_01FBA8 `ruins `

dialogstring_01FBAF `right. `

dialogstring_01FBB7 `ruins, `

dialogstring_01FBBF `road `

dialogstring_01FBC5 `rest `

dialogstring_01FBCB `stone `

dialogstring_01FBD2 `seem `

dialogstring_01FBD8 `scattered `

dialogstring_01FBE3 `seemed `

dialogstring_01FBEB `softly `

dialogstring_01FBF3 `soldiers `

dialogstring_01FBFD `shape `

dialogstring_01FC04 `since `

dialogstring_01FC0B `surprised `

dialogstring_01FC16 `sure `

dialogstring_01FC1C `seen `

dialogstring_01FC22 `shouldn't `

dialogstring_01FC2D `somewhere `

dialogstring_01FC38 `times `

dialogstring_01FC3F `they `

dialogstring_01FC45 `talk `

dialogstring_01FC4B `tell `

dialogstring_01FC51 `townspeople `

dialogstring_01FC5E `taken `

dialogstring_01FC65 `they're `

dialogstring_01FC6E `travelling `

dialogstring_01FC7A `trying `

dialogstring_01FC82 `turned `

dialogstring_01FC8A `temporary `

dialogstring_01FC95 `than `

dialogstring_01FC9B `then `

dialogstring_01FCA1 `too, `

dialogstring_01FCA7 `thousands `

dialogstring_01FCB2 `turn `

dialogstring_01FCB8 `treasure, `

dialogstring_01FCC3 `used `

dialogstring_01FCC9 `until `

dialogstring_01FCD0 `village. `

dialogstring_01FCDA `vampire `

dialogstring_01FCE3 `while `

dialogstring_01FCEA `water `

dialogstring_01FCF1 `went `

dialogstring_01FCF7 `wondered `

dialogstring_01FD01 `written `

dialogstring_01FD0A `woman `

dialogstring_01FD11 `wind `

dialogstring_01FD17 `years `

dialogstring_01FD1E `you. `