?INCLUDE 'sE6_gaia'
?INCLUDE 'table_0EDA00'

!joypadMaskStd                  065A
!musicParentActor               06F2
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4

---------------------------------------------

pyCD_jackal [
  actor-def < #0B, #00, #30, {

  code_08B821:
    COP [SetFlagByte] ( #0E )
    COP [ExitIfFlagByte] ( #C2, #01 )
    COP [ExitIfFlagByte] ( #C3, #01 )
    COP [ExitIfFlagByte] ( #C4, #01 )
    COP [ExitIfFlagByte] ( #C5, #01 )
    COP [ExitIfFlagByte] ( #C6, #01 )
    COP [ExitIfFlagByte] ( #C7, #01 )
    COP [BranchIfFlagByte] ( #BB, #01, &code_08B9EC )
    COP [ClearFlagByte] ( #0E )
    COP [SetFlagByte] ( #0F )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #05, #09, #0A, #0B, &code_08B853 )
    RTL 
} >
]

code_08B853 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SolidHighAbs] ( #06, #0C )
    COP [SolidHighAbs] ( #07, #0C )
    COP [SolidHighAbs] ( #08, #0C )
    COP [SolidHighAbs] ( #09, #09 )
    COP [SolidHighAbs] ( #09, #0A )
    COP [PrintDialogString] ( &dialogstring_08BA11 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #03, #09, #04, #0D, &code_08B893 )
    COP [BranchIfButton] ( #$0501, &code_08B88E )
    RTL 
}

code_08B88E {
    COP [PrintDialogString] ( &dialogstring_08BA36 )
    RTL 
}

code_08B893 {
    COP [ClearLowAbs] ( #06, #0C )
    COP [ClearLowAbs] ( #07, #0C )
    COP [ClearLowAbs] ( #08, #0C )
    COP [ClearLowAbs] ( #09, #09 )
    COP [ClearLowAbs] ( #09, #0A )
    COP [SolidHighAbs] ( #05, #09 )
    COP [SolidHighAbs] ( #05, #0A )
    COP [PrintDialogString] ( &dialogstring_08BA5A )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #0E, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08BA7D )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_08BC55 )
    LDA $characterForm
    BEQ loc_08B921
    CMP #$0001
    BEQ loc_08B90C
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F3B1
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F3B1
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags
    BRA loc_08B921

  loc_08B90C:
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F37D
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F37D
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags

  loc_08B921:
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$000F
    STA $musicParentActor
    COP [SetFlagByte] ( #0E )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #03, #01, &code_08B956 )
    COP [BranchIfFlagByte] ( #0D, #01, &code_08B950 )
    LDY $playerActor
    LDA $0014, Y
    CMP #$0048
    BEQ loc_08B94A
    RTL 

  loc_08B94A:
    COP [BranchIfButton] ( #$0101, &code_08B951 )
}

code_08B950 {
    RTL 
}

code_08B951 {
    COP [PrintDialogString] ( &dialogstring_08BCBC )
    RTL 
}

code_08B956 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearFlagByte] ( #0E )
    COP [WaitByte] ( #1D )
    COP [LoopInit] ( #0C )
    COP [SpawnAfterFlags] ( @code_08B7E8, #$0B02 )
    COP [WaitByte] ( #09 )
    COP [LoopNext]
    LDA #$0800
    TSB $10
    COP [StageSprAndHitbox] ( #13 )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterFlags] ( @code_08BA04, #$2000 )
    COP [SetFlagByte] ( #04 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveX] ( #13, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteMoveX] ( #14, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #16, #B4 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteMoveX] ( #17, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteMoveX] ( #18, #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [StageSpriteLoop] ( #19, #40 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #78 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #11 )
    COP [WaitByte] ( #B3 )
    COP [ClearLowAbs] ( #05, #09 )
    COP [ClearLowAbs] ( #05, #0A )
    COP [SetFlagByte] ( #06 )
    COP [SetFlagByte] ( #BB )
    COP [ClearFlagByte] ( #0F )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_08B9EC {
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #09, #0B )
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_08BA04 {
    COP [PrintDialogString] ( &dialogstring_08BCF2 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_08BD16 )
    COP [Die]
}

dialogstring_08BA11 `[TPL:9][TPL:4][DLY:0]Walk to the left[N]without a sound!![PAL:0][END]`

dialogstring_08BA36 `[TPL:9][TPL:4]It says to walk to[N]the left!![PAL:0][END]`

dialogstring_08BA5A `[TPL:9][TPL:4]There, that's good.[N]Don't move!![PAL:0][END]`

dialogstring_08BA7D `[TPL:A][TPL:4][DLY:0]Jackal: [N]I know the whole [N]story of your adventure. [FIN]I heard about an[N]ancient bio-technology[N]using a comet's light. [FIN]I didn't know it was you.[FIN]With the power to change[N]body shape, you could[N]get anything.[FIN]People would bow [N]at your feet.[FIN]It's only natural that[N]King Edward would [N]trick you into this...[FIN][TPL:1]Kara: [N]My father!!? [FIN][TPL:4]Jackal: [N]Yes! After all, that's [N]the way kings are. [FIN]He would do anything to[N]get the power.[FIN]He might even be more [N]evil than a mercenary [N]like me. Heh heh. [FIN][TPL:1]Kara: [N]Stop it! [FIN][TPL:4]Jackal: [N]Either way, if I make [N]money, it's fine. [FIN]Come with me to[N]Edward Castle.[PAL:0][END]`

dialogstring_08BC55 `[TPL:A][TPL:0]A voice whispers [N]in Will's head... [FIN][DLY:0]Will... Play the [N]Flute....Will....[PAL:0][END]`

dialogstring_08BC9F `[TPL:A][TPL:4]Jackal: [N]Give up...? [N][PAL:0][END]`

dialogstring_08BCBC `[TPL:A][TPL:4]Jackal: [N]If you come any closer, [N]I'll use this knife...[PAL:0][END]`

dialogstring_08BCF2 `[TPL:9][TPL:4][DLY:0]Jackal: [N]Wa-a-a-a-ah!!!![PAU:3C][PAL:0][CLD]`

dialogstring_08BD16 `[TPL:8][TPL:4][DLY:4]Kara...Kara...[PAU:78][PAL:0][CLD]`
---------------------------------------------

code_08B7E8 {
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0020
    CLC 
    ADC $16
    STA $16
}

code_08B804 {
    COP [PlaySoundBoth] ( #$0505 )
    COP [AddPosition] ( #00, #FC )
    COP [StageSpriteLoop] ( #11, #02 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #04 )
    COP [StageSpriteLoop] ( #12, #10 )
    COP [AnimLoop]
    COP [Die]
}