; Stone coffin puzzle in the Seaside Palace — Lilly investigates.
; 
; Extended coffin interaction (~151 lines). Will: "The coffins
; are lined up..." Lilly speaks from pocket: "Isn't there a
; hole in the coffin? I could get in through there."
; Lilly enters to investigate, finding items or clues.
; Multi-step puzzle with dialog progression.
---------------------------------------------

?INCLUDE 'music_actors'
?INCLUDE 'spriteset_enemies'

!joypadMaskStd                  065A
!playerActor                    09AA
!displayModeFlags               09EC
!APUIO1                         2141
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sp5C_stone_coffin [
  actor-def < #00, #02, #30, {

  code_0691AF:
    COP [BranchIfFlagWord] ( #$013B, #01, &code_069291 )
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_0692CF )

  code_0691BE:
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @spriteset_enemies )
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveX] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$02C0
    STA $moveXAlt, X
    LDA #$009C
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3B )
    COP [StageBgChange] ( #3B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$013B )
    COP [WaitByte] ( #3B )
    LDA #$02C0
    STA $14
    LDA #$00A0
    STA $16
    LDA #$2000
    TRB $10
    JSL $@music_actors.IsMusicPlaying
    BCS loc_069297
    COP [GiveItem] ( #11, &code_069293 )
    COP [PrintDialogString] ( &dialogstring_069377 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_06939E )
    COP [WaitByte] ( #03 )
    COP [SetEntryContinue]
    LDA #$CFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_06925B
    RTL 

  loc_06925B:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_069291 {
    COP [Die]
}

code_069293 {
    COP [PrintDialogString] ( &dialogstring_0693B7 )

  loc_069297:
    COP [ClearFlagWord] ( #$013B )
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetTilePos] ( #2B, #0A )
    JMP $&code_0691BE
}

code_0692CF {
    COP [BranchIfFlagByte] ( #6F, #01, &code_0692DA )
    COP [PrintDialogString] ( &dialogstring_0692E2 )
    RTL 
}

code_0692DA {
    COP [PrintDialogString] ( &dialogstring_06930A )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_0692E2 `[DEF][TPL:0]Will: The coffins are [N]lined up...[PAL:0][END]`

dialogstring_06930A `[DEF][TPL:2]Lilly speaks from[N]his pocket.[FIN][TPL:2]Lilly:[N]Isn't there a hole in[N]the coffin?[FIN]I could get in through [N]the hole. I better [N]have a look.[PAL:0][END]`

dialogstring_069377 `[DEF][TPL:2]Lilly:[N]I found a strange stone[N]inside this coffin.[PAL:0][FIN]`

dialogstring_06939E `[CLR][SFX:0][DLY:9]You've found the [N]Purification Stone![PAU:78][END]`

dialogstring_0693B7 `[DEF][TPL:2]Lilly:[N]I found a strange stone[N]inside this coffin.[FIN]But your inventory[N]is full...[PAL:0][END]`