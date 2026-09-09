!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A

---------------------------------------------

sp58_actor_068380 [
  actor-def < #05, #00, #18, {

  code_068383:
    LDA $0AA6
    CMP #$0001
    BNE loc_0683C0
    BRA loc_0683B4
} >
]

sp58_monologue [
  actor-def < #05, #00, #18, {

  code_068390:
    LDA $0AA6
    CMP #$0001
    BNE loc_0683C0
    COP [SpawnAfterFlags] ( @code_0683C2, #$2000 )
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0001
    STA $002E, Y

  loc_0683B4:
    COP [AddPosition] ( #00, #B0 )

  loc_0683B8:
    COP [StageSpriteMoveY] ( #05, #13 )
    COP [AnimOnce]
    BRA loc_0683B8

  loc_0683C0:
    COP [Die]
} >
]

code_0683C2 {
    COP [WaitByte] ( #EF )
    COP [WaitByte] ( #EF )
    COP [PrintWideString] ( &widestring_0683EB )
    COP [WaitByte] ( #77 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    STA $0688
    COP [QueueMapChange] ( #5A, #$0090, #$0070, #83, #$1400 )
    COP [SetEntryContinue]
    RTL 
}

widestring_0683EB `[TPL:B][TPL:0]Will: We got out of [N]the airplane in the [N]nick of time... [FIN]Neil's a good inventor, [N]but it seems there's [N]always something missing [N]in his inventions..... [FIN]I guess nobody's [N]perfect, including [N]Neil.[PAL:0][END]`