?INCLUDE 'sE6_gaia'
?INCLUDE 'sg55_viper_arena'
?INCLUDE 'visual_effect_pipeline'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraBoundsY                  06DC
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4

---------------------------------------------

sg55_mystic_statue [
  actor-def < #00, #00, #30, {

  code_0ACE37:
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0ACE3F
    RTL 

  loc_0ACE3F:
    COP [BranchIfFlagByte] ( #F9, #01, &code_0ACE81 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_0ACF0E )
    LDA #$0001
    STA $0AAC
    LDA #$0055
    STA $0B12
    LDA #$0010
    STA $0B08
    STA $0B0A
    LDA #$0008
    STA $0B0C
    STA $0B0E
    LDA #$2200
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    RTL 
} >
]

code_0ACE81 {
    COP [SpawnBeforeFlags] ( @visual_effect_pipeline.effect_subpixel_math, #$2800 )
    LDA #$0201
    STA $0014, Y
    LDA #$000C
    STA $0016, Y
    COP [SpawnBeforeFlags] ( @sg55_viper_arena.code_0AD034, #$2800 )
    COP [WaitByte] ( #3B )
    LDA $characterForm
    BEQ loc_0ACEC9
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_FreedanToWill
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_FreedanToWill
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_0ACEC9
    RTL 

  loc_0ACEC9:
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_0ACF4A )
    COP [LoopInit] ( #30 )
    LDA $cameraBoundsY
    INC 
    STA $cameraBoundsY
    COP [LoopNext]
    LDA #$0170
    STA $cameraBoundsY
    COP [SetSolidAbs] ( #07, #0C, #08 )
    COP [SetEntryContinue]
    LDA $playerYTile
    CMP #$0018
    BEQ loc_0ACEF2
    RTL 

  loc_0ACEF2:
    LDA #$0000
    STA $0AA6
    STA $0688
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_0ACF0E `[DEF][TPL:0]You have defeated the, [N]huge demon! [N]Look! A Mystic Statue!![PAL:0][END]`

dialogstring_0ACF4A `[DEF][TPL:0]A strange noise fills [N]the air around you. [N]From out of nowhere,[N]you hear Neil's voice![FIN][TPL:6]Neil: [N]Will! You're falling [N]to the ground!!!! [FIN]Grab the airplane, and[N]we'll fly out of here![PAL:0][END]`