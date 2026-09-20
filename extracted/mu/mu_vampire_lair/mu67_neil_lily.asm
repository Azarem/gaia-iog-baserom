; Neil and Lilly in the vampire lair — reunion after the battle.
; 
; Two-character NPC (~95 lines). Neil: "Will! Are you OK?!"
; Lance: "Will! I don't see Lilly." Lilly reassures: "Sorry
; I worried you. Will was protecting me, so I was OK."
; Multi-speaker dialog sequence after the vampire defeat.
---------------------------------------------

!joypadMaskStd                  065A
!playerActor                    09AA
!decompressedTilesets           7E4000
!tileStagingBuffer              7E7000
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

mu67_neil [
  actor-def < #13, #00, #30, {

  code_06A748:
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #01, #19, #0F, #1B, &code_06A757 )
    RTL 
} >
]

code_06A757 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #04 )
    COP [Decompress] ( @gfx_nazca_sprites, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_nazca_sprites, #00, #A0, #50 )
    COP [Decompress] ( @spm_nazca_sprites, $7E4000 )
    COP [SetFlagByte] ( #88 )
    COP [StartMusic] ( #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #17, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #45 )
    COP [PrintDialogString] ( &dialogstring_06A7C7 )
    COP [SpawnAfterFlags] ( @e_mu67_lily, #$1002 )
    COP [SetEntryHere]
    RTL 
}

dialogstring_06A7C7 `[TPL:A][TPL:6]Neil: [N]Will! Are you OK?! [FIN][TPL:4]Lance: Will! [N]I don't see Lilly. [N]Has something happened? [FIN][TPL:2]Lilly:[N]I'm here.[PAL:0][END]`
---------------------------------------------

e_mu67_lily {
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveY] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$00A8
    STA $moveXAlt, X
    LDA #$01B0
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    COP [StageSpriteLoop] ( #33, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06AA4C )
    COP [SetFlagByte] ( #05 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06AA89 )
    COP [SetFlagByte] ( #06 )
    COP [SetEntryHere]
    RTL 
}

dialogstring_06AA4C `[TPL:A][TPL:2]Lilly: Sorry I worried [N]you. Will was protecting [N]me, so I was OK.[PAL:0][END]`

dialogstring_06AA89 `[TPL:A][TPL:6]Neil: Well, Will [N]seems to have really [N]grown up.[PAL:0][END]`