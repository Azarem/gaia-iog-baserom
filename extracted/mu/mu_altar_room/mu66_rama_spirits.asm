?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'
?INCLUDE 'spriteset_npc_props'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!eventFlags                     0A00
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

mu66_rama_spirits [
  actor-def < #00, #00, #30, {

  code_069E3F:
    COP [BranchIfFlagWord] ( #$0139, #01, &code_069F1D )
    COP [AddPosition] ( #08, #02 )
    COP [SetOnInteract] ( &code_069F1F )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$00B8, #$0080, #$1000 )
    LDA #$0000
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$0148, #$00A0, #$1000 )
    LDA #$0001
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$0188, #$00E0, #$1000 )
    LDA #$0002
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$0138, #$0120, #$1000 )
    LDA #$0003
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$00D8, #$0100, #$1000 )
    LDA #$0004
    STA $0024, Y
    COP [SpawnMarkedAfterAbs] ( @code_06A01E, #$0078, #$0140, #$1000 )
    LDA #$0005
    STA $0024, Y
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$80
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @oneshot_palette_flash_18.code_00B7CE )
    COP [WaitByte] ( #7F )
    COP [StageBgChange] ( #39 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0139 )
    COP [SpawnThinker] ( @oneshot_palette_flash_19.code_00B7D8 )
    COP [WaitByte] ( #7F )
    LDA #$0002
    STA $0AAC
    LDA #$0066
    STA $0B12
    LDA #$000F
    STA $0B08
    STA $0B0A
    LDA #$0007
    STA $0B0C
    STA $0B0E
    LDA #$2200
    STA $0B10
    LDA #$0104
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
} >
]

code_069F1D {
    COP [Die]
}

code_069F1F {
    LDA $eventFlags
    AND #$00FF
    CMP #$00FE
    BEQ loc_069F3D
    COP [BranchIfFlagByte] ( #01, #01, &code_069F38 )
    COP [PrintDialogString] ( &dialogstring_069F45 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_069F38 {
    COP [PrintDialogString] ( &dialogstring_069FBE )
    RTL 

  loc_069F3D:
    COP [PrintDialogString] ( &dialogstring_069FE3 )
    COP [SetFlagByte] ( #0F )
    RTL 
}

dialogstring_069F45 `[DEF]I am Rama, King of Mu.[N]My body passed on[N]long ago, but my[N]spirit lives on.[FIN]If you look closely, [N]You can probably see [N]wandering spirits. [END]`

dialogstring_069FBE `[DEF]Hear the words of[N]spirits awakened.[END]`

dialogstring_069FE3 `[DEF]The underwater tunnel[N]dug by man is inside.[FIN]Please take this [N]Mystic Statue. [END]`

code_06A01E {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SetOnInteract] ( &code_06A05F )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
}

code_06A05F {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06A06A )
}

code_list_06A06A [
  &code_06A076   ;00
  &code_06A07E   ;01
  &code_06A086   ;02
  &code_06A08E   ;03
  &code_06A096   ;04
  &code_06A09E   ;05
]

code_06A076 {
    COP [PrintDialogString] ( &dialogstring_06A0A6 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_06A07E {
    COP [PrintDialogString] ( &dialogstring_06A0EC )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_06A086 {
    COP [PrintDialogString] ( &dialogstring_06A154 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_06A08E {
    COP [PrintDialogString] ( &dialogstring_06A19E )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_06A096 {
    COP [PrintDialogString] ( &dialogstring_06A1C9 )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_06A09E {
    COP [PrintDialogString] ( &dialogstring_06A26D )
    COP [SetFlagByte] ( #07 )
    RTL 
}

dialogstring_06A0A6 `[DEF]Once a single ray of [N]light came from the sky. [N]People thought it was [N]the light of the spirits.[END]`

dialogstring_06A0EC `[DEF]One year after that our[N]bodies began to change.[FIN]One got very thin,[N]one turned to stone,[N]one's body melted[N]like water...[END]`

dialogstring_06A154 `[DEF]Family and friends [N]turned to monsters [N]before our eyes. We [N]fought back the tears...[END]`

dialogstring_06A19E `[DEF]Many saw no point in [N]living if this thing [N]continued...[END]`

dialogstring_06A1C9 `[DEF]Some couldn't take it, [N]and thought we should [N]flee from here. [FIN]But Mu is an island. We[N]didn't know if we'd find[N]another place to live...[FIN]There were no materials[N]for a boat. It would[N]sink if made of stone...[END]`

dialogstring_06A26D `[DEF]They started building an[N]undersea tunnel. They[N]dug on, not knowing how[N]long it would take...[END]`