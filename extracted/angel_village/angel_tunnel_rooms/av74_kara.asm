?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'oneshot_palette_flash_40'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!CGWSEL                         2130
!CGADSUB                        2131
!decompressedTilesets           7E4000
!tileStagingBuffer              7E7000

---------------------------------------------

av74_kara [
  actor-def < #16, #00, #10, {

  code_06D151:
    COP [BranchIfFlagByte] ( #8C, #01, &code_06D258 )
    COP [AddPosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SpawnAfterRelFlags] ( @code_06D251, #$0000, #$0010, #$3000 )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #14, &code_06D171 )
    RTL 
} >
]

code_06D171 {
    COP [SolidHighAbs] ( #0B, #0C )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #8A, #01 )
    LDA #$FFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$00
    STA $CGWSEL
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @oneshot_palette_flash_40.code_00B7F6 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TSB $10
    COP [SpawnThinker] ( @oneshot_palette_flash_40.code_00B7F6 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TSB $10
    COP [Decompress] ( @gfx_nazca_sprites, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_nazca_sprites, #00, #A0, #50 )
    COP [Decompress] ( @spm_nazca_sprites, $7E4000 )
    COP [SetTilePos] ( #0B, #10 )
    COP [SetSpritePriority] ( #20 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06D339 )
    LDA #$0003
    JSL $@InitPlayerScriptVariant
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_06D364 )
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06D3CC )
    COP [SetFlagByte] ( #8C )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #6A, #$01A0, #$00B0, #03, #$1200 )
    COP [SetEntryContinue]
    RTL 
}

code_06D251 {
    COP [SetOnInteract] ( &code_06D25A )
    COP [SetEntryContinue]
    RTL 
}

code_06D258 {
    COP [Die]
}

code_06D25A {
    COP [BranchIfFlagByte] ( #89, #00, &code_06D273 )
    COP [BranchIfFlagByte] ( #01, #01, &code_06D26B )
    COP [PrintDialogString] ( &dialogstring_06D278 )
    RTL 
}

code_06D26B {
    COP [PrintDialogString] ( &dialogstring_06D2A4 )
    COP [SetFlagByte] ( #8A )
    RTL 
}

code_06D273 {
    COP [PrintDialogString] ( &dialogstring_06D2FF )
    RTL 
}

dialogstring_06D278 `[TPL:A][TPL:0][SFX:10]Will: [N]If I don't spread [N]magic dust...[PAL:0][END]`

dialogstring_06D2A4 `[TPL:E][TPL:0][SFX:10]Will: [N]Kara - please return to [N]your original form.... [FIN][SFX:0]Will gently kisses the [N]picture of Kara...[PAL:0][END]`

dialogstring_06D2FF `[TPL:A][TPL:0][SFX:10]Will: Kara's picture. [N]She is contained [N]inside it....[PAL:0][END]`

dialogstring_06D339 `[TPL:A][TPL:1][SFX:1B]Kara: [N]Will....Sorry [N]for being so selfish.[FIN]`

dialogstring_06D364 `[TPL:A][CLR][TPL:0][SFX:10]Will: Kara!! [N]You make me so mad!! [FIN]You are not the only [N]person on this journey!  [FIN][TPL:1][SFX:1B]Kara: [N]............[PAL:0][END]`

dialogstring_06D3CC `[TPL:A][TPL:1][SFX:1B]Kara: [N]Whaaaaaah! [N]Sob....Sniff.... [FIN]I...Sob... I don't[N]know what I'm doing[N]myself...Sob...[FIN]When I was in the[N]castle....I could have[N]anything I wanted...[FIN]But I was a completely[N]different person[N]before this trip...[FIN][TPL:0][SFX:10]Will: Naturally! It's a [N]mistake to think you [N]can control everything!![FIN][TPL:1][SFX:1B]Kara: No! [FIN]When I'm far away, I feel [N]close to it.[FIN]When I'm close,[N]I feel far away. [N]I realize that now... [FIN]It's all right if you[N]don't understand...[FIN]I will never forget[N]what happened today.[PAL:0][END]`