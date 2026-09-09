!joypadMaskStd                  065A

---------------------------------------------

h_ec0A_edward [
  actor-def < #2A, #00, #10, {

  code_04BF49:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04BF6A )
    COP [ExitIfFlagByte] ( #05, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #0A )
    COP [PrintWideString] ( &widestring_04C0D5 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04BF6A {
    COP [PrintWideString] ( &widestring_04BF8C )
    COP [DialogueOptions] ( #02, #02, &code_list_04BF74 )
}

code_list_04BF74 [
  &code_04BF7A   ;00
  &code_04BF80   ;01
  &code_04BF7A   ;02
]

code_04BF7A {
    COP [PrintWideString] ( &widestring_04C058 )
    BRA loc_04BF84
}

code_04BF80 {
    COP [PrintWideString] ( &widestring_04BFE8 )

  loc_04BF84:
    COP [PrintWideString] ( &widestring_04C07E )
    COP [SetFlagByte] ( #05 )
    RTL 
}

widestring_04BF8C `[TPL:F][TPL:4]エドワード国王:[N]お前が テムと申すか?[N]さえない 身なりを しておるな.[FIN]さて さっそくだが[N]水しょうの指輪は もってきたか?[N][PAL:0] はい[N] いいえ`

widestring_04BFE8 `[CLR][TPL:4]よかろう.[N]なかなか 素直な子じゃな.[N]さあ 指輪を 出すがよい.[FIN][TPL:0]テム:[N]·············[FIN][TPL:4]エドワード国王: む?[N][PAU:14][DLY:0]お前は 今 わしに うそを[N]ついたなっ!?[FIN]`

widestring_04C058 `[CLR][TPL:4][DLY:0]よくも まあ ぬけぬけと[N]そんなことが 言えたものだなっ!![FIN]`

widestring_04C07E `[CLR][TPL:4][DLY:1]まあ そんなことだろうと思ったわ![N]さあ. 兵士ども![N]こいつを ろうやへ ブチこめえっ![FIN]そして テムの家へゆき[N]指輪を さがしだすのじゃ![END]`

widestring_04C0D5 `[PAU:1E][TPL:8][PAL:0]兵士: はっ! ただいま![PAU:28][CLD]`