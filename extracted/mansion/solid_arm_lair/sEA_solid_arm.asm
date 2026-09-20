; Solid Arm boss fight — Jeweler Gem's true form (~356 lines).
; 
; Optional boss: "Welcome to my home. The Jeweler Gem is a
; temporary form. The true form is called Solid Arm." Multi-phase
; boss with extending arm attacks and area sweeps. After defeat:
; "I was defeated again... Blazer was strong, but you are
; stronger." Rewards completion of the Red Jewel collection
; quest. References the game's predecessor, Soul Blazer.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'smooth_follow'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraBoundsY                  06DC
!playerYPos                     09A4
!playerActor                    09AA
!TM                             212C
!CGADSUB                        2131
!chatPtr                        7F000A
!animScratch2                   7F000E
!loopCounter                    7F0014
!statsPtr                       7F0020
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

sEA_solid_arm [
  actor-def < #00, #00, #00, {

  code_08F70C:
    LDA #$0011
    TSB $12
    LDA #$0100
    STA $cameraBoundsY
    COP [SpawnBeforeFlags] ( @code_08F9F2, #$2000 )
    LDA #$*binary_08F9EA
    AND #$00FF
    STA $0AF6
    LDA #$&binary_08F9EA
    STA $0AF4
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #13 )
    COP [PlaySoundCh1] ( #0E )
    COP [StageBgChange] ( #9C )
    COP [ApplyBgChange]
    COP [BranchOnFlagByte] ( #E8, #01, &code_08F754 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitWord] ( #$0120 )
    COP [SetFlagByte] ( #E8 )
    COP [PrintDialogString] ( &dialogstring_08FA31 )
} >
]

code_08F754 {
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #31 )
    LDA #$EFF0
    TRB $joypadMaskStd

  loc_08F763:
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]

  code_08F768:
    LDA $playerYPos
    CMP #$0070
    BCS loc_08F773
    JMP $&code_08F83E

  loc_08F773:
    COP [BranchOnPlayerX] ( #$0010, &code_08F7AA, &code_08F77D, &code_08F7AA )
}

code_08F77D {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08F8B4, #$0000, #$FFE8, #$0200 )
    COP [SpawnAfterOffsetFlags] ( @code_08F8E6, #$0000, #$FFE8, #$0200 )
    COP [SpawnAfterOffsetFlags] ( @code_08F900, #$0000, #$FFE8, #$0200 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    BRA loc_08F763
}

code_08F7AA {
    COP [BranchOnPlayerX] ( #$0050, &code_08F7B4, &code_08F822, &code_08F7B4 )
}

code_08F7B4 {
    COP [BranchOnPlayerX] ( #$0070, &code_08F822, &code_08F7BE, &code_08F822 )
}

code_08F7BE {
    COP [BranchOnPlayerX] ( #$0000, &code_08F7C8, &code_08F7F5, &code_08F7F5 )
}

code_08F7C8 {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08F937, #$FFF0, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08F937, #$FFF0, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F7F5 {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08F957, #$0010, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterOffsetFlags] ( @code_08F957, #$0010, #$FFE6, #$0200 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F822 {
    COP [BranchOnPlayerX] ( #$0000, &code_08F82C, &code_08F835, &code_08F835 )
}

code_08F82C {
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F835 {
    COP [StageSpriteMoveX] ( #05, #11 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F83E {
    COP [BranchOnPlayerX] ( #$0040, &code_08F8A2, &code_08F848, &code_08F8AB )
}

code_08F848 {
    COP [BranchOnPlayerX] ( #$0000, &code_08F852, &code_08F87A, &code_08F87A )
}

code_08F852 {
    COP [PlaySoundCh1] ( #02 )
    LDA #$0010
    TSB $10
    LDA #$&enemy_stats_table+180
    STA $statsPtr, X
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$&enemy_stats_table+17C
    STA $statsPtr, X
    LDA #$0010
    TRB $10
    JMP $&code_08F768
}

code_08F87A {
    COP [PlaySoundCh1] ( #02 )
    LDA #$0010
    TSB $10
    LDA #$&enemy_stats_table+180
    STA $statsPtr, X
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA #$&enemy_stats_table+17C
    STA $statsPtr, X
    LDA #$0010
    TRB $10
    JMP $&code_08F768
}

code_08F8A2 {
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F8AB {
    COP [StageSpriteMoveX] ( #06, #01 )
    COP [AnimOnce]
    JMP $&code_08F768
}

code_08F8B4 {
    COP [OrExtraFlags] ( #$0010 )
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #04, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #02, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #04, #07 )
    COP [AnimLoop]
    LDA #$0008
    STA $26
    JMP $&code_08F977
}

code_08F8E6 {
    COP [OrExtraFlags] ( #$0010 )
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #0C, #07 )
    COP [AnimLoop]
    COP [Die]
}

code_08F900 {
    COP [OrExtraFlags] ( #$0010 )
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #05, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #03, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #13, #01, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #13, #07 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #13, #04, #07 )
    COP [AnimLoop]
    LDA #$0008
    STA $26
    BRA code_08F977
}

code_08F937 {
    COP [OrExtraFlags] ( #$0010 )
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #13, #05, #06, #05 )
    COP [AnimLoop]
    LDA #$000A
    STA $26
    BRA code_08F977
}

code_08F957 {
    COP [OrExtraFlags] ( #$0010 )
    COP [SetPriorityMax]
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveXY] ( #13, #05, #05, #05 )
    COP [AnimLoop]
    LDA #$0006
    STA $26
    BRA code_08F977
}

code_08F977 {
    COP [SpawnAfterMarked] ( @smooth_follow.CopySiblingFollowState, #$2000 )
    LDA #$8013
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $playerActor
    STA $0024, Y
    PHX 
    TYX 
    LDA $26
    STA $animScratch2, X
    PLX 
    COP [StageSpriteLoop] ( #13, #03 )
    COP [AnimLoop]
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $7F100E, X
    LDA $0000
    STA $7F100C, X
    COP [KillNext]
    COP [StageSprAndHitbox] ( #13 )

  loc_08F9C0:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryHere]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_08F9E1
    RTL 

  loc_08F9E1:
    LDA $10
    BIT #$4000
    BEQ loc_08F9C0
    COP [Die]
}

binary_08F9EA #E978039000000044

code_08F9F2 {
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$21
    STA $CGADSUB
    REP #$20
    LDA $0AEC
    BEQ loc_08FA06
    RTL 

  loc_08FA06:
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitWord] ( #$0120 )
    COP [PrintDialogString] ( &dialogstring_08FBC8 )
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$0280, #$01A0, #80, #$2310 )
    COP [Die]
}

dialogstring_08FA31 `[DEF]Welcome to my home.[FIN]The Jeweler Gem is a[N]temporary form. The[N]true form is called[N]Solid Arm.[FIN]Long ago the Blazer [N]came down from the sky, [N]and I was put to sleep [N]for a long, long time... [FIN]My power is contained in[N]Red Jewels scattered[N]around the world[FIN]I've tried many things[N]to bring about my[N]own resurrection.[FIN]It is I who manipulated[N]the labor trade.[FIN]I tried using forced[N]labor to find them,[N]but it didn't restore[N]my power fast enough.[FIN]I'm sorry, but I will[N]have to defeat you too![END]`

dialogstring_08FBC8 `[DEF]A quiet voice is heard.[FIN][DLY:4]I was defeated again...[FIN]Blazer was strong, [N]but you are stronger... [FIN]Danger approaches[N]this planet. You should[N]hurry to the[N]Tower of Babel...[END]`