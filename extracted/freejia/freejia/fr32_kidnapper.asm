?INCLUDE 'EnemyInitBasic'
?INCLUDE 'table_0EDA00'

!joypadMaskStd                  065A
!playerFlags                    09AE
!currentHp                      7F0026

---------------------------------------------

fr32_kidnapper [
  actor-def < #1A, #00, #10, {

  code_05B371:
    COP [BranchIfFlagByte] ( #67, #01, &code_05B39F )
    COP [SolidHighAbs] ( #04, #0D )
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #08, #02 )
    COP [WaitWhileOffscreen] ( #08 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0E, #0B, #12, &code_05B38E )
    RTL 
} >
]

code_05B38E {
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [SpawnAfterAbsFlags] ( @code_05B3A1, #$0048, #$00E0, #$1000 )
}

code_05B39F {
    COP [Die]
}

code_05B3A1 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [SetSpritePriority] ( #20 )
    COP [SetOnInteract] ( &code_05B40B )
    COP [PlaySoundCh2] ( #0E )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #67, #01 )
    PHX 
    LDX #$0000

  loc_05B3C4:
    LDA $@pal_southcape_sprites+E0, X
    STA $7F0BE0, X
    INX 
    INX 
    CPX #$0020
    BNE loc_05B3C4
    PLX 
    LDA #$2000
    TSB $joypadMaskStd
    LDA #$0008
    TRB $playerFlags
    JSL $@EnemyInitBasic
    LDA #$0005
    STA $currentHp, X
    LDA #$1000
    TRB $10
    LDA #$0100
    TSB $10
    COP [OrActorFlags] ( #$0008 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #0E, #08, #12, &code_05B404 )
    RTL 
}

code_05B404 {
    COP [PrintDialogString] ( &dialogstring_05B55F )
    COP [SetEntryContinue]
    RTL 
}

code_05B40B {
    COP [BranchIfFlagByte] ( #66, #01, &code_05B416 )
    COP [PrintDialogString] ( &dialogstring_05B42E )
    RTL 
}

code_05B416 {
    COP [PrintDialogString] ( &dialogstring_05B45E )
    COP [SetFlagByte] ( #67 )
    COP [SolidHighAbs] ( #08, #0E )
    COP [SolidHighAbs] ( #08, #0F )
    COP [SolidHighAbs] ( #08, #10 )
    COP [SolidHighAbs] ( #08, #11 )
    RTL 
}

dialogstring_05B42E `[DEF]Man's voice: If you[N]don't want to lose[N]your lives, go home!![END]`

dialogstring_05B45E `[DEF]Man's voice: If you[N]don't want to lose[N]your lives, go home!![FIN][TPL:0]Will: [N]Is a man called [N]Erik there? [FIN][PAL:0]Man's voice:[N]I've never heard of[N]such a name. Why[N]do you ask?[FIN][TPL:3]Will? Is that Will's [N]voice? Save me... [PAL:0][PAU:B4]Bonk![FIN]Man's voice: Shhhh...[N]Hey, boy, be quiet...![FIN][TPL:0]Will: (I'll break [N]down the door..) [N][PAL:0][END]`

dialogstring_05B55F `[DEF][TPL:0]Will: [N]If I don't save Erik...[PAL:0][END]`