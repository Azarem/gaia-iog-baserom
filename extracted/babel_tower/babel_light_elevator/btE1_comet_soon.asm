; Comet arrival warning in the light elevator area.
; 
; Extended NPC (~133 lines): "The comet will soon be entering
; Earth's orbit. We must go to the top of the Tower of Babel..."
; Urgent story exposition driving the player toward the
; final confrontation.
---------------------------------------------

?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!decompressedTilesets           7E4000
!tileStagingBuffer              7E7000
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

btE1_comet_soon [
  actor-def < #00, #00, #10, {

  code_099637:
    COP [BranchIfPlayerAt] ( #$0180, #$07A0, &code_099641 )
    COP [Die]
} >
]

code_099641 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [Decompress] ( @gfx_vampires, $7E7000 )
    COP [AdhocVramDma] ( $7E7000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7E7800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7E8000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7E8800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_vampires, #10, #B0, #40 )
    COP [Decompress] ( @spm_vampires, $7E4000 )
    LDA #$DFF0
    TRB $joypadMaskStd
    STZ $0676
    STZ $0685
    COP [SetFlagByte] ( #0F )
    LDA #$0200
    TSB $12
    COP [StageSprAndHitbox] ( #00 )
    LDA #$0158
    STA $moveXAlt, X
    LDA #$07A0
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099746 )
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [SpawnBeforeFlags] ( @code_09979D, #$2000 )
    LDY $playerActor
    LDA #$*code_0997B7
    STA $0002, Y
    LDA #$&code_0997B7
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_0996FA:
    COP [StageSpriteMoveY] ( #01, #08 )
    COP [AnimOnce]
    LDA $16
    CMP #$00E0
    BCS loc_0996FA
    LDA $14
    STA $moveXAlt, X
    LDA #$0080
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #02 )
    COP [WaitByte] ( #3B )
    LDA #$0178
    STA $moveXAlt, X
    LDA #$00A0
    STA $moveYAlt, X
    COP [MoveToward] ( #01, #01 )
    COP [WaitByte] ( #31 )
    COP [SetFlagByte] ( #04 )
    COP [KillPrev]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveXY] ( #01, #0A, #02, #04 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_099746 {
    COP [PrintDialogString] ( &dialogstring_09974E )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_09974E `[DEF]The comet will soon be[N]entering Earth's orbit.[N]We must go to the top of[N]the Tower of Babel...[END]`

code_09979D {
    COP [SetEntryContinue]
    PHX 
    LDX $24
    LDY $playerActor
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    CLC 
    ADC #$000A
    STA $0016, Y
    PLX 
    RTL 
}

code_0997B7 {
    COP [SetSpritePriority] ( #30 )
    COP [StagePlayerSprite] ( #19 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #04, #00, &code_0997B7 )
    COP [SetSpritePriority] ( #20 )
    JML $@player_character.PlayerIdleEntry
}