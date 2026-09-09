---------------------------------------------

kara_09BBB7 [
  actor-def < #00, #00, #20, {

  code_09BBBA:
    LDA #$0800
    TSB $10
    LDA #$1000
    TSB $12
    COP [SpawnAfterFlags] ( @code_09BBCE, #$2000 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09BBCE {
    COP [WaitByte] ( #03 )
    LDA #$0078
    STA $24

  code_09BBD6:
    COP [WriteApuIo0] ( #00 )
    COP [PrintWideString] ( &widestring_09BBF7 )
    COP [StartMusic] ( #02 )
    COP [WaitByte] ( #3B )
    COP [WriteApuIo0] ( #00 )
    COP [PrintWideString] ( &widestring_09BBF7 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #3B )
    COP [BranchIfButton] ( #$0080, &code_09BBD6 )
    RTL 
}

widestring_09BBF7 `[DLG:3,6][SIZ:D,3][TPL:1]Kara: It's terrible! [N]Leave me alone! How [N]far will you go?![PAL:0][END]`