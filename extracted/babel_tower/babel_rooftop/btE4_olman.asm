?INCLUDE 'spriteset_enemies'
?INCLUDE 'spriteset_npc_props'

!joypadMaskStd                  065A
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

btE4_olman [
  actor-def < #00, #00, #10, {

  code_098F95:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_099068 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterAbsFlags] ( @code_0991F4, #$00D8, #$00F0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_0992A0, #$0098, #$00E0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_099347, #$00B8, #$0160, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_0993F8, #$0148, #$0130, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterAbsFlags] ( @code_0994A0, #$0158, #$00E0, #$1000 )
    COP [PlaySoundCh1] ( #1D )
    LDA #$0800
    TSB $10
    COP [SetOnInteract] ( &code_099023 )

  code_099012:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099012 )
    COP [WaitByte] ( #1D )
    COP [ClearLowHere]
    COP [Die]
} >
]

code_099023 {
    COP [BranchIfFlagByte] ( #01, #00, &code_099041 )
    COP [BranchIfFlagByte] ( #02, #00, &code_099041 )
    COP [BranchIfFlagByte] ( #03, #00, &code_099041 )
    COP [BranchIfFlagByte] ( #04, #00, &code_099041 )
    COP [BranchIfFlagByte] ( #05, #01, &code_099050 )
}

code_099041 {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_099182 )
    LDA #$0800
    TSB $10
    RTL 
}

code_099050 {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_0991A9 )
    COP [SetFlagByte] ( #0F )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0800
    TSB $10
    RTL 
}

dialogstring_099068 `[TPL:F][TPL:4][DLY:0]Will's father: [N]The ancients worshipped [N]the comet as a spirit. [FIN]Those who bathed in [N]the comet's light were [N]given a strange power. [FIN]The comet is called a [N]spirit. But it's [N]an unwelcome spirit. [FIN]Evolving too fast[N]brings destruction...[FIN]As long as people[N]have evil hearts,[N]demons will be born.[FIN]Will, open your eyes [N]and look around. [END]`

dialogstring_099182 `[TPL:F][TPL:4]Will's father: I need [N]to talk to you.[PAL:0][END]`

dialogstring_0991A9 `[TPL:F][TPL:4][DLY:0]Will's father: At last [N]the time is near. [FIN]Everyone. [N]Give Will your power![PAL:0][END]`

code_0991F4 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099232 )

  code_09920E:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_09920E )
    COP [ClearLowHere]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_099232 {
    COP [PrintDialogString] ( &dialogstring_09923A )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_09923A `[DEF][TPL:5]Seth: Ah, Will. [N]It's been a long time. [FIN]Such a world. If I [N]could talk of this at [N]an academy I'd be [N]a great scholar.[PAL:0][END]`

code_0992A0 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0992E4 )

  code_0992BA:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_0992BA )
    COP [ClearLowHere]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_0992E4 {
    COP [PrintDialogString] ( &dialogstring_0992EC )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_0992EC `[DEF]Neil's father: [N]Neil... [N]What are you doing!! [FIN]I want him to make the[N]Rolek Company grow[N]bigger and bigger.[END]`

code_099347 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099385 )

  code_099361:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099361 )
    COP [ClearLowHere]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_099385 {
    COP [PrintDialogString] ( &dialogstring_09938D )
    COP [SetFlagByte] ( #03 )
    RTL 
}

dialogstring_09938D `[DEF]Neil's mother: Even if [N]I can see the real[N]world,[N]I can't touch it... [FIN]No matter how difficult[N]it may get,[N]I can't help you...[END]`

code_0993F8 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099436 )

  code_099412:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_099412 )
    COP [ClearLowHere]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_099436 {
    COP [PrintDialogString] ( &dialogstring_09943E )
    COP [SetFlagByte] ( #04 )
    RTL 
}

dialogstring_09943E `[DEF]Hamlet: [N]Oink oink!! [FIN][SFX:0][TPL:0]Will: [N]Of course. There's [N]no difference between [N]humans and animals...[PAL:0][END]`

code_0994A0 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0994DE )

  code_0994BA:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #0F, #00, &code_0994BA )
    COP [ClearLowHere]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #04, #01 )
    COP [Die]
}

code_0994DE {
    COP [PrintDialogString] ( &dialogstring_0994E6 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

dialogstring_0994E6 `[DEF]With my body gone, I [N]became forever young. [N]From the comet's light, [N]I gained immortality. [FIN]But is there meaning in [N]eternal life? I felt [N]more alive when I had [N]a terminal disease. [END]`