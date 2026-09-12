?INCLUDE 'bt_actor_099B1C'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerSpeedNs                  09B4
!displayModeFlags               09EC

---------------------------------------------

btDF_crystal_ring [
  actor-def < #02, #00, #30, {

  code_099975:
    LDA #$0200
    TSB $12
    COP [SpawnAfterAbsFlags] ( @bt_actor_099B1C, #$076E, #$017C, #$0B00 )
    COP [SpawnAfterAbsFlags] ( @bt_actor_099B1C, #$076E, #$018C, #$0B00 )

  loc_099990:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #75, #17, #77, #19, &code_09999B )

  code_09999A:
    RTL 
} >
]

code_09999B {
    COP [BranchIfEquipped] ( #27, &code_09999A )
    COP [PlaySoundBoth] ( #$1D1D )
    LDA #$0006
    STA $playerSpeedNs
    COP [BranchIfNoItem] ( #27, &code_09999A )
    COP [BranchIfFlagByte] ( #01, #01, &code_0999BF )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0999CC, #$3802 )
}

code_0999BF {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #75, #17, #77, #19, &code_0999CB )
    BRA loc_099990
}

code_0999CB {
    RTL 
}

code_0999CC {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    COP [InitGravity] ( #02, #06, #00 )
    COP [StageForceMoveX] ( #12 )

  loc_0999F7:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0999F7
    LDA $08
    STZ $08
    STA $24

  loc_099A03:
    COP [TickGravity]
    CMP #$0000
    BMI loc_099A12
    COP [SetEntryExit]
    DEC $24
    BPL loc_099A03
    BRA loc_0999F7

  loc_099A12:
    COP [StageSpriteMoveXY] ( #02, #12, #45 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    LDA #$0001
    TSB $10
    COP [StageSpriteLoop] ( #02, #05 )
    COP [AnimLoop]
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_099A70 )
    LDA #$0800
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_099A49 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    RTL 
}

code_099A49 {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_099A91 )
    LDA #$0800
    TSB $10
    COP [GiveItem] ( #27, &code_099A6B )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_099AE4 )
    COP [Die]

  loc_099A6A:
    RTL 
}

code_099A6B {
    COP [PrintDialogString] ( &dialogstring_099AFE )
    RTL 
}

dialogstring_099A70 `[TPL:A][TPL:0]Something seemed to[N]fall from the Flute...[PAL:0][END]`

dialogstring_099A91 `[TPL:A][TPL:0]It's King Edward's[N]Crystal Ring!![FIN]I thought it was a[N]decoration, but it had[N]been hidden there...[PAL:0][FIN]`

dialogstring_099AE4 `[TPL:A][SFX:0][DLY:9]You have the[N]Crystal Ring![PAU:78][END]`

dialogstring_099AFE `[CLR][TPL:0]But your inventory[N]is full![PAL:0][END]`