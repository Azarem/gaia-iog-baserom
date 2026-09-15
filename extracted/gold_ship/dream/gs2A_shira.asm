?BANK 05

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!W12SEL                         2123
!WOBJSEL                        2125

---------------------------------------------

gs2A_shira [
  actor-def < #0B, #00, #10, {

  code_059457:
    COP [SpawnAfterFlags] ( @code_059637, #$3800 )
    LDA #$0040
    STA $00F6
    STA $00FA
    LDA #$0120
    STA $00FE
    SEP #$20
    LDA #$33
    STA $W12SEL
    LDA #$03
    STA $WOBJSEL
    REP #$20
    COP [SetOnInteract] ( &code_059484 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_059484 {
    COP [SetFlagByte] ( #0E )
    COP [PrintDialogString] ( &dialogstring_0594B8 )
    COP [DialogueOptions] ( #02, #01, &code_list_059491 )
}

code_list_059491 [
  &code_059497   ;00
  &code_059497   ;01
  &code_05949D   ;02
]

code_059497 {
    COP [PrintDialogString] ( &dialogstring_0595B4 )
    BRA loc_0594A1
}

code_05949D {
    COP [PrintDialogString] ( &dialogstring_0595E6 )

  loc_0594A1:
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #2D, #$00B0, #$0050, #03, #$1300 )
    RTL 
}

dialogstring_0594B8 `[PAU:50][TPL:A][TPL:0]Will: [N]Mother?! [FIN][TPL:2]Will's Mother, Shira: [N]Look in the sky. The [N]comet is so beautiful. [FIN]After years and years[N]the comet approaches[N]Earth, then recedes.[FIN]Some say it's an [N]unlucky star. Some [N]say it's a lucky star... [FIN]Will. What do you think? [N] Unlucky star [N] Lucky star `

dialogstring_0595B4 `[CLR]All right...[N]Then hope that the bad[N]luck doesn't come....[FIN][JMP:&dialogstring_0595E6+M]`

dialogstring_0595E6 `[CLR]All right...[N]Then hope that happiness[N]doesn't slip away....[FIN][::]Will. I am always [N]watching over you.[PAL:0][END]`

code_059637 {
    LDA #$7000
    TSB $joypadMaskStd
    RTL 
}