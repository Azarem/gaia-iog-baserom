?INCLUDE 'cop_handlers_actors'
?INCLUDE 'dark_space_palette'
?INCLUDE 'player_character'
?INCLUDE 'save_system'
?INCLUDE 'table_0EE000'

!sceneNext                      0642
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!damageFlashTimer               0B22
!APUIO1                         2141
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sE6_gaia [
  actor-def < #00, #00, #23, {

  code_08D7AB:
    COP [SpawnAfterFlags] ( @code_08F687, #$2800 )
    COP [SpawnAfterAbsFlags] ( @e_actor_09A090, #$0080, #$0040, #$1800 )
    COP [SpawnAfterAbsFlags] ( @code_09A096, #$0080, #$0058, #$1800 )
    LDA $0AAC
    CMP #$0004
    BCC loc_08D7D3
    LDA #$0000

  loc_08D7D3:
    STA $0AB2
    STZ $0AAC
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D7E2 )
} >
]

code_list_08D7E2 [
  &code_08D856   ;00
  &code_08D87C   ;01
  &code_08D9CC   ;02
  &code_08DA7D   ;03
]
---------------------------------------------

func_08D7EA {
    LDA #$FFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [PlaySoundBoth] ( #$0C0C )
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    LDA $0B12
    STA $sceneNext
    LDA $0B08
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064C
    LDA $0B0C
    INC 
    INC 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064E
    LDA #$0003
    STA $0650
    LDA $0B10
    STA $0652
    STZ $0AAC
    LDA #$0101
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [SetEntryContinue]
    RTL 
}

code_08D856 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D862 )
    BRA loc_08D863
}

code_08D862 {
    RTL 

  loc_08D863:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D876 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08D876 {
    COP [CallScript] ( &code_08DAF0 )
    BRA code_08D856
}

code_08D87C {
    LDA $characterForm
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D888 )
}

code_list_08D888 [
  &code_08D88E   ;00
  &code_08D8FA   ;01
  &code_08D966   ;02
]

code_08D88E {
    COP [StageBgChange] ( #88 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchIfFlagByte] ( #B4, #00, &code_08D8A8 )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

code_08D8A8 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D8C4 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D8C4 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D8C4 )
    BRA loc_08D8C5
}

code_08D8C4 {
    RTL 

  loc_08D8C5:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D8E8 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D8EE )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D8F4 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08D8E8 {
    COP [CallScript] ( &code_08DAF0 )
    BRA code_08D8A8
}

code_08D8EE {
    COP [CallScript] ( &code_08F088 )
    BRA code_08D8A8
}

code_08D8F4 {
    COP [CallScript] ( &func_08F3EA )
    BRA code_08D8A8
}

code_08D8FA {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchIfFlagByte] ( #B4, #00, &code_08D914 )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

code_08D914 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D930 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D930 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D930 )
    BRA loc_08D931
}

code_08D930 {
    RTL 

  loc_08D931:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D954 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D95A )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D960 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08D954 {
    COP [CallScript] ( &code_08DAF0 )
    BRA code_08D914
}

code_08D95A {
    COP [CallScript] ( &func_08F2DF )
    BRA code_08D914
}

code_08D960 {
    COP [CallScript] ( &func_08F3EA )
    BRA code_08D914
}

code_08D966 {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8D )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]

  loc_08D97A:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D996 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D996 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D996 )
    BRA loc_08D997
}

code_08D996 {
    RTL 

  loc_08D997:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08D9BA )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08D9C0 )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08D9C6 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08D9BA {
    COP [CallScript] ( &code_08DAF0 )
    BRA loc_08D97A
}

code_08D9C0 {
    COP [CallScript] ( &func_08F2DF )
    BRA loc_08D97A
}

code_08D9C6 {
    COP [CallScript] ( &code_08F088 )
    BRA loc_08D97A
}

code_08D9CC {
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    PHX 
    LDX #$0000

  loc_08D9D5:
    LDA $@binary_08EB5A, X
    BEQ loc_08DA44
    AND #$00FF
    CMP $0B12
    BEQ loc_08D9E7
    INX 
    INX 
    BRA loc_08D9D5

  loc_08D9E7:
    LDA $@binary_08EB5A+1, X
    AND #$00FF
    PLX 
    AND #$000F
    BEQ loc_08DA1C
    COP [StageBgChange] ( #86 )
    COP [ApplyBgChange]
    LDA #$0000
    STA $orbitAngle, X
    COP [SpawnLastRel] ( @func_08E9D4, #00, #00, #$3800 )
    LDA #$0040
    STA $0014, Y
    LDA #$006D
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08DA45

  loc_08DA1C:
    COP [StageBgChange] ( #8B )
    COP [ApplyBgChange]
    LDA #$0001
    STA $orbitAngle, X
    COP [SpawnLastRel] ( @func_08E9D4, #00, #00, #$3800 )
    LDA #$0040
    STA $0014, Y
    LDA #$0054
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08DA45

  loc_08DA44:
    PLX 

  loc_08DA45:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08DA51 )
    BRA loc_08DA52
}

code_08DA51 {
    RTL 

  loc_08DA52:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08DA65 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08DA65 {
    COP [CallScript] ( &code_08DAF0 )
    BRA loc_08DA45

  loc_08DA6B:
    LDA $orbitAngle, X
    BNE loc_08DA77
    COP [CallScript] ( &func_08F2DF )
    BRA loc_08DA45

  loc_08DA77:
    COP [CallScript] ( &code_08F088 )
    BRA loc_08DA45
}

code_08DA7D {
    LDA #$0001
    STA $0AAC
    JMP $&code_08D87C
}

code_08DA86 {
    COP [StageBgChange] ( #8B )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #89 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [SpawnLastRel] ( @func_08EF32, #00, #00, #$3800 )
    LDA #$00C0
    STA $0014, Y
    LDA #$0078
    STA $0016, Y
    LDA $06
    STA $0026, Y

  loc_08DAB4:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08DAC8 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08DAC8 )
    BRA loc_08DAC9
}

code_08DAC8 {
    RTL 

  loc_08DAC9:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &code_08DAE4 )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08DAEA )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &func_08D7EA )
    RTL 
}

code_08DAE4 {
    COP [CallScript] ( &code_08DAF0 )
    BRA loc_08DAB4
}

code_08DAEA {
    COP [CallScript] ( &func_08F3EA )
    BRA loc_08DAB4
}

code_08DAF0 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    LDY $06
    LDA #$FFFF
    STA $0024, Y
    COP [BranchIfFlagByte] ( #DC, #01, &code_08DB14 )
    COP [SetFlagByte] ( #DC )
    COP [PrintDialogString] ( &dialogstring_08DD0B )
}

code_08DB14 {
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08DB37
    COP [PrintDialogString] ( &dialogstring_08DE4D )
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$0028
    STA $damageFlashTimer
    COP [SetEntryContinue]
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08DB37
    RTL 

  loc_08DB37:
    PHX 
    LDX #$0000

  loc_08DB3B:
    LDA $@binary_08DE72, X
    AND #$00FF
    BEQ loc_08DB9A
    CMP $0B12
    BEQ loc_08DB4C
    INX 
    BRA loc_08DB3B

  loc_08DB4C:
    STX $0000
    PLX 
    COP [SwitchCase] ( #$0000, &code_list_08DB56 )
}

code_list_08DB56 [
  &code_08DC25   ;00
  &code_08DC28   ;01
  &code_08DC2F   ;02
  &code_08DC36   ;03
  &code_08DC3D   ;04
  &code_08DC40   ;05
  &code_08DC43   ;06
  &code_08DC46   ;07
  &code_08DC49   ;08
  &code_08DC4C   ;09
  &code_08DC53   ;0A
  &code_08DC56   ;0B
  &code_08DC59   ;0C
  &code_08DC5C   ;0D
  &code_08DC5F   ;0E
  &code_08DC62   ;0F
  &code_08DC69   ;10
  &code_08DC70   ;11
  &code_08DC73   ;12
  &code_08DC76   ;13
  &code_08DC79   ;14
  &code_08DC80   ;15
  &code_08DC83   ;16
  &code_08DC86   ;17
  &code_08DC89   ;18
  &code_08DC90   ;19
  &code_08DC93   ;1A
  &code_08DC96   ;1B
  &code_08DC9D   ;1C
  &code_08DCA4   ;1D
  &code_08DCA7   ;1E
  &code_08DCFA   ;1F
  &code_08DCFD   ;20
  &code_08DD04   ;21
]
---------------------------------------------

loc_08DB9A {
    PLX 

  code_08DB9B:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDCB )
    COP [DialogueOptions] ( #02, #02, &code_list_08DBAB )
}

code_list_08DBAB [
  &code_08DBDA   ;00
  &code_08DBB1   ;01
  &code_08DBDA   ;02
]

code_08DBB1 {
    LDA $0D8C
    JSL $@save_system.SaveGameState_Scene
    COP [PlaySoundCh1] ( #29 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDFE )
    COP [DialogueOptions] ( #02, #01, &code_list_08DBD4 )
}

code_list_08DBD4 [
  &code_08DBE8   ;00
  &code_08DBDA   ;01
  &code_08DBE8   ;02
]

code_08DBDA {
    COP [PrintDialogString] ( &dialogstring_08DE43 )
    LDY $06
    LDA #$0000
    STA $0024, Y
    COP [RestoreSavedPtr]
}

code_08DBE8 {
    COP [PrintDialogString] ( &dialogstring_08DE32 )
    LDY $06
    LDA #$0000
    STA $0024, Y
    LDA #$FFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #0E )
    COP [SetEntryContinue]
    RTL 
}

code_08DC25 {
    JMP $&code_08DB9B
}

code_08DC28 {
    COP [PrintDialogString] ( &dialogstring_08DED3 )
    JMP $&code_08DB9B
}

code_08DC2F {
    COP [PrintDialogString] ( &dialogstring_08DF80 )
    JMP $&code_08DB9B
}

code_08DC36 {
    COP [PrintDialogString] ( &dialogstring_08DFEE )
    JMP $&code_08DB9B
}

code_08DC3D {
    JMP $&code_08DB9B
}

code_08DC40 {
    JMP $&code_08DB9B
}

code_08DC43 {
    JMP $&code_08DB9B
}

code_08DC46 {
    JMP $&code_08DB9B
}

code_08DC49 {
    JMP $&code_08DB9B
}

code_08DC4C {
    COP [PrintDialogString] ( &dialogstring_08E1EE )
    JMP $&code_08DB9B
}

code_08DC53 {
    JMP $&code_08DB9B
}

code_08DC56 {
    JMP $&code_08DB9B
}

code_08DC59 {
    JMP $&code_08DB9B
}

code_08DC5C {
    JMP $&code_08DB9B
}

code_08DC5F {
    JMP $&code_08DB9B
}

code_08DC62 {
    COP [PrintDialogString] ( &dialogstring_08E2F8 )
    JMP $&code_08DB9B
}

code_08DC69 {
    COP [PrintDialogString] ( &dialogstring_08E3A7 )
    JMP $&code_08DB9B
}

code_08DC70 {
    JMP $&code_08DB9B
}

code_08DC73 {
    JMP $&code_08DB9B
}

code_08DC76 {
    JMP $&code_08DB9B
}

code_08DC79 {
    COP [PrintDialogString] ( &dialogstring_08E428 )
    JMP $&code_08DB9B
}

code_08DC80 {
    JMP $&code_08DB9B
}

code_08DC83 {
    JMP $&code_08DB9B
}

code_08DC86 {
    JMP $&code_08DB9B
}

code_08DC89 {
    COP [PrintDialogString] ( &dialogstring_08E4A4 )
    JMP $&code_08DB9B
}

code_08DC90 {
    JMP $&code_08DB9B
}

code_08DC93 {
    JMP $&code_08DB9B
}

code_08DC96 {
    COP [PrintDialogString] ( &dialogstring_08E540 )
    JMP $&code_08DB9B
}

code_08DC9D {
    COP [PrintDialogString] ( &dialogstring_08E58B )
    JMP $&code_08DB9B
}

code_08DCA4 {
    JMP $&code_08DB9B
}

code_08DCA7 {
    LDA $0AAC
    BNE loc_08DCAF
    JMP $&code_08DB9B

  loc_08DCAF:
    COP [BranchIfNoItem] ( #24, &code_08DCEC )
    COP [GiveItem] ( #24, &code_08DCF3 )
    COP [PrintDialogString] ( &dialogstring_08E66C )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08E7E7 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08DCDF
    RTL 

  loc_08DCDF:
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&code_08DB9B
}

code_08DCEC {
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&code_08DB9B
}

code_08DCF3 {
    COP [PrintDialogString] ( &dialogstring_08E800 )
    JMP $&code_08DB9B
}

code_08DCFA {
    JMP $&code_08DB9B
}

code_08DCFD {
    COP [PrintDialogString] ( &dialogstring_08E853 )
    JMP $&code_08DB9B
}

code_08DD04 {
    COP [PrintDialogString] ( &dialogstring_08E98A )
    JMP $&code_08DB9B
}
---------------------------------------------

dialogstring_08DD0B `[DEF]I am Gaia, the source of[N]all life. I will help[N]you on your journey.[FIN]Only one with the Dark[N]Power can see this[N]space. You are the[N]chosen one.[FIN]In the dark space you[N]can record a travel[N]journal. Stop there[N]before you depart.[FIN]`

dialogstring_08DDCB `[DEF][CLR]Record what's happened[N]so far?[N] Record[N] Don't record`

dialogstring_08DDFE `[CLR]Finished recording...[FIN]Continue your journey?[N] Yes[N] No`

dialogstring_08DE32 `[CLR]Then rest a while.[END]`

dialogstring_08DE43 `[CLR]Then go.[END]`

dialogstring_08DE4D `[DEF][CLR]It looks like you're[N]hurt. Close your eyes.[FIN]`
---------------------------------------------

binary_08DE72 #010B151E2628343D40424C5154565A60626C7C858699A1A3A7ACB6B8BBC3CCE0E3120000
---------------------------------------------

dialogstring_08DE96 `[DEF][CLR]I am Gaia, the source of[N]all life. I'll give you[N]some advice.[FIN]`

dialogstring_08DEC6 `[DEF][CLR]Hint Test[FIN]`

dialogstring_08DED3 `[PRT:@sE6_gaia.dialogstring_08DE96]When you defeat all the [N]enemies in an area, you [N]will get a jewel that [N]increases your abilities.[FIN]Push the Start Button[N]to see the locations of[N]your enemies.[FIN]Find the demons [N]and defeat them. [FIN]`

dialogstring_08DF80 `[PRT:@sE6_gaia.dialogstring_08DE96]Will's power - the [N]Psycho Dash. It can [N]destroy obstacles. [FIN]Always be alert. If you[N]find a suspicious place,[N]try to destroy it.[FIN]`

dialogstring_08DFEE `[PRT:@sE6_gaia.dialogstring_08DE96]Then you will fight[N]a huge enemy.[FIN]When he suffers damage, [N]rays of light will shoot [N]from his head. [FIN]If you suffer damage[N]hide behind him.[FIN]`

dialogstring_08E066 `[PRT:@sE6_gaia.dialogstring_08DE96]The door to the Gold[N]Ship is in a place paved[N]with gold tiles.[FIN]Listen to the melody [N]of the Incan spirit. [FIN]`

dialogstring_08E0C7 `[PRT:@sE6_gaia.dialogstring_08DE96]To defeat an enemy you[N]can't touch, think about[N]what happened under[N]Edward Castle.[FIN]`

dialogstring_08E109 `[PRT:@sE6_gaia.dialogstring_08DE96]The wall where the wind[N]blows...it's easy to[N]break through where[N]the stones are cracked.[FIN]If you can't find it, [N]listen for the only place [N]where the sound is[N]different. [FIN]`

dialogstring_08E19C `[PRT:@sE6_gaia.dialogstring_08DE96]The keys are on a grate[N]in the floor of the[N]mine. Find the laborer[N]who has them.[FIN]`

dialogstring_08E1EE `[PRT:@sE6_gaia.dialogstring_08DE96]Freedan's power - The[N]Dark Friar can defeat[N]enemies in places a[N]sword can't reach.[FIN]When you've defeated[N]all the enemies[N]the road will open up.[FIN]`

dialogstring_08E261 `[PRT:@sE6_gaia.dialogstring_08DE96]Take away the obstacle[N]in front, and the back[N]appears. Remove the[N]blocking pillar.[FIN]`

dialogstring_08E2B9 `[PRT:@sE6_gaia.dialogstring_08DE96]The switch on the floor [N]cannot be activated [N]by your weight. [FIN]`

dialogstring_08E2F8 `[PRT:@sE6_gaia.dialogstring_08DE96]When you started this [N]journey,  Mu began [N]to rise from the sea. [FIN]Sea water still covers [N]land in many places [N]on the continent. [FIN]When the water is gone [N]you will discover [N]the location of [N]Rama, King of Mu. [FIN]`

dialogstring_08E3A7 `[PRT:@sE6_gaia.dialogstring_08DE96]Will's power is the [N]Psycho Slider. Pass [N]through narrow corridors [N]using this power. [FIN]Be careful not to[N]overlook the cracks[N]in the cliff.[FIN]`

dialogstring_08E428 `[PRT:@sE6_gaia.dialogstring_08DE96]Will's power is the [N]Spin Dash. Use this to [N]climb hills and jump. [FIN]There are many hills at[N]the Great Wall of China.[N]Try everything.[FIN]`

dialogstring_08E4A4 `[PRT:@sE6_gaia.dialogstring_08DE96]Freedan's power is [N]the Aura Barrier. It [N]puts a layer of Aura [N]around his body. [FIN]Enemies at the mountain [N]temple are strong.If [N]you use this power, your [N]battles will be easier. [FIN]`

dialogstring_08E540 `[PRT:@sE6_gaia.dialogstring_08DE96]Freedan's Power is the [N]Earthquaker.[FIN]When he uses it,[N]his enemy can't move[N]for a long time.[FIN]`

dialogstring_08E58B `[DEF][CLR]This is the temple at[N]Ankor Wat.[FIN]It stands quietly in [N]the jungle and hides [N]its form when people [N]come near... [FIN]On this top floor you[N]will understand why you[N]made the journey.[FIN]`

dialogstring_08E615 `[PRT:@sE6_gaia.dialogstring_08DE96]The Pyramid is divided [N]into six blocks. [FIN]Use the Dark Power [N]previously obtained, in[N]each area. [FIN]`

dialogstring_08E66C `[DEF][CLR]I am Gaia, the source of[N]life. The Dark Power has[N]become strong in the[N]temple at Ankor Wat.[FIN]If you stand before the [N]right-hand statue, you [N]can change into Shadow, [N]the ultimate warrior.  [FIN]Then I think I will[N]grant you one item.[FIN]`

dialogstring_08E722 `[DEF][CLR]The Aura is Shadow's [N]mind. When he holds it [N]up, his body becomes [N]like water. [FIN]Only a small part of the[N]Pyramid is above ground.[N]Most of it is below[N]the surface.[FIN]You should change into[N]the Shadow and advance[N]into the underground.[FIN]`

dialogstring_08E7E7 `[DEF][CLR][DLY:9]You have the Aura![PAU:78][DLY:1][FIN]`

dialogstring_08E800 `[DEF][CLR]I am Gaia, the source of[N]life. I think I'll give[N]you one item.[FIN]Cut down on your[N]inventory and come back.[FIN]`

dialogstring_08E853 `[DEF][CLR]The comet draws near.[N]The time for your last[N]battle approaches.[FIN]This is the last time I[N]will talk to you like[N]this in this place.[FIN]With your rejuvenated [N]power, defeat the comet,[N]Dark Gaia and become [N]the Dark Knight. [FIN]Shadow's greatest power,[N]the Firebird, will arise[N]when you're one with [N]the Light Knight.[FIN]Only you can restore the [N]Earth to its original [N]condition. I'm putting [N]all my faith in you... [FIN]`

dialogstring_08E98A `[PRT:@sE6_gaia.dialogstring_08DE96]Your shape is only[N]temporary. Try standing[N]in front of the statue[N]next to you.[FIN]`
---------------------------------------------

func_08E9D4 {
    PHX 
    LDX #$0000
    LDY #$0000

  loc_08E9DB:
    LDA $@binary_08EB5A, X
    BEQ loc_08E9EE
    AND #$00FF
    CMP $0B12
    BEQ loc_08E9F1
    INX 
    INX 
    INY 
    BRA loc_08E9DB

  loc_08E9EE:
    PLX 
    COP [Die]

  loc_08E9F1:
    LDA $@binary_08EB5A+1, X
    AND #$00FF
    STA $24
    AND $abilityBitmask
    BNE loc_08E9EE
    TYA 
    STA $0AAC
    PLX 
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &code_08EA1B )
    RTL 
}

code_08EA1B {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    JSR $&sub_08EB2F
    CMP #$0000
    BEQ loc_08EA78
    LDA $characterForm
    BEQ loc_08EA58
    CMP #$0002
    BEQ loc_08EA38
    BRA loc_08EA9B

  loc_08EA38:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F2A3
    STA $0002, Y
    REP #$20
    LDA #$&func_08F2A3
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    BRA loc_08EA9B

  loc_08EA58:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F26E
    STA $0002, Y
    REP #$20
    LDA #$&func_08F26E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    BRA loc_08EA9B

  loc_08EA78:
    LDA $characterForm
    BEQ loc_08EA9B
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F37D
    STA $0002, Y
    REP #$20
    LDA #$&func_08F37D
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_08EA9B:
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_08EAAA
    RTL 

  loc_08EAAA:
    COP [LoopInit] ( #08 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
    LDA $24
    ORA $abilityBitmask
    STA $abilityBitmask
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08EB68 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08EB0D
    RTL 

  loc_08EB0D:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08EB85 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [Die]
}
---------------------------------------------

sub_08EB2F {
    PHX 
    LDX #$0000

  loc_08EB33:
    LDA $@binary_08EB5A, X
    BEQ loc_08EB57
    AND #$00FF
    CMP $0B12
    BEQ loc_08EB45
    INX 
    INX 
    BRA loc_08EB33

  loc_08EB45:
    LDA $@binary_08EB5A+1, X
    AND #$00FF
    PLX 
    AND #$00F0
    BNE loc_08EB53
    RTS 

  loc_08EB53:
    LDA #$0001
    RTS 

  loc_08EB57:
    PLX 
    SEC 
    RTS 
}
---------------------------------------------

binary_08EB5A #1501620286044210A720B8400000
---------------------------------------------

dialogstring_08EB68 `[DEF][DLY:9][ADR:&sE6_gaia.table_08EB8F,AAC][N]can now be used![PAU:78][FIN]`

dialogstring_08EB85 `[DEF][CLR][DLY:2][ADR:&sE6_gaia.table_08EBD3,AAC][END]`
---------------------------------------------

table_08EB8F [
  &dialogstring_08EB9B   ;00
  &dialogstring_08EBA2   ;01
  &dialogstring_08EBAB   ;02
  &dialogstring_08EBB2   ;03
  &dialogstring_08EBBA   ;04
  &dialogstring_08EBC7   ;05
]

dialogstring_08EB9B `Psycho Dash`

dialogstring_08EBA2 `Psycho Slider`

dialogstring_08EBAB `Spin Dash`

dialogstring_08EBB2 `Dark Friar`

dialogstring_08EBBA `Aura Barrier`

dialogstring_08EBC7 `Earthquaker`
---------------------------------------------

table_08EBD3 [
  &dialogstring_08EBDF   ;00
  &dialogstring_08EC66   ;01
  &dialogstring_08ECEA   ;02
  &dialogstring_08ED6D   ;03
  &dialogstring_08EDF2   ;04
  &dialogstring_08EE8B   ;05
]

dialogstring_08EBDF `Only young Will can use [N]the Psycho Dash. [FIN]You can smash walls[N]and obstacles by hurling[N]yourself against them.[FIN]Use the Attack Button [N]to save energy. `

dialogstring_08EC66 `Only young Will can use [N]the Psycho Slider. [FIN]You can now use the[N]Sliding Attack to pass[N]through small[N]passageways.[FIN]Push the Attack Button [N]when running. `

dialogstring_08ECEA `Only young Will can use [N]the Spin Dash. [FIN]Spin your body to[N]send enemies flying,[N]and use the recoil[N]to climb hills.[FIN]Use the Attack and LR [N]Buttons for power. `

dialogstring_08ED6D `The Dark Friar is a dark[N]power that only the Dark[N]Knight, Freedan,[N]can use.[FIN]Use the Aura Power to [N]scorch a distant enemy. [N]Use the Attack Button [N]to save energy. `

dialogstring_08EDF2 `The Aura Barrier is a [N]Dark Power that can only [N]be used by the Dark  [N]Knight, Freedan. [FIN]Use the power of[N]the Aura to put a[N]barrier around you.[FIN]Use the Attack and LR [N]Buttons for power. `

dialogstring_08EE8B `The Earthquaker is a[N]Dark Power that can only[N]be used by Freedan,[N]the Dark Knight.[FIN]This causes earthquakes.[N]The enemy won't be able[N]to move for a long time.[FIN]Push the Attack Button [N]when jumping down. `
---------------------------------------------

func_08EF32 {
    COP [BranchIfNoItem] ( #24, &code_08EFC7 )
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10

  code_08EF3F:
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08EF4E )
    RTL 
}

code_08EF4E {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    COP [GiveItem] ( #24, &code_08EFC9 )
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_08EFEF )
    COP [WaitByte] ( #03 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08EFAD
    RTL 

  loc_08EFAD:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08F003 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    LDA #$FFF0
    TRB $joypadMaskStd
}

code_08EFC7 {
    COP [Die]
}

code_08EFC9 {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_08F060 )
    LDA #$0800
    TSB $10
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &code_08EFEE )
    JMP $&code_08EF3F
}

code_08EFEE {
    RTL 
}

dialogstring_08EFEF `[DEF][DLY:9]You have the Aura![FIN]`

dialogstring_08F003 `[DEF][CLR][DLY:2]Only Shadow can use[N]the Aura.[FIN]When you hold this up [N]Shadow's body will turn [N]to water and he can flow [N]underground. [END]`

dialogstring_08F060 `[DEF]Your inventory is full. [N]Store things somewhere [N]and return here. [END]`

code_08F088 {
    LDA $characterForm
    CMP #$0001
    BEQ loc_08F0CA
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [BranchIfFlagByte] ( #F7, #01, &code_08F0CC )
    COP [SetFlagByte] ( #F7 )
    COP [PrintDialogString] ( &dialogstring_08F157 )
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F235
    STA $0002, Y
    REP #$20
    LDA #$&func_08F235
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_08F0CA:
    COP [RestoreSavedPtr]
}

code_08F0CC {
    COP [PrintDialogString] ( &dialogstring_08F12B )
    COP [DialogueOptions] ( #02, #02, &code_list_08F0D6 )
}

code_list_08F0D6 [
  &code_08F125   ;00
  &code_08F0DC   ;01
  &code_08F125   ;02
]

code_08F0DC {
    COP [PrintDialogString] ( &dialogstring_08F155 )
    LDA $characterForm
    BNE loc_08F105
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F26E
    STA $0002, Y
    REP #$20
    LDA #$&func_08F26E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

  loc_08F105:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F2A3
    STA $0002, Y
    REP #$20
    LDA #$&func_08F2A3
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

code_08F125 {
    COP [PrintDialogString] ( &dialogstring_08F155 )
    COP [RestoreSavedPtr]
}

dialogstring_08F12B `[TPL:B]Change into the Dark [N]Knight, Freedan? [N] Yes [N] No `

dialogstring_08F155 `[CLD]`

dialogstring_08F157 `[TPL:B][CLR][TPL:0]Will hears a voice [N]in his head. [FIN][TPL:4]Will. [N]I've been waiting a long [N]time for you to come. [FIN]I am Freedan.[N]I am eternal.[FIN]Let me help you on [N]your journey. As time [N]goes by, you'll come to [N]understand my nature.... [FIN][PAL:0]Will gradually loses [N]consciousness... [N][END]`
---------------------------------------------

func_08F235 {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    COP [SpawnThinkerParam] ( #0C, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteLoop] ( #08, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$0001
    STA $characterForm
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F26E {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #0C, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    LDA #$0001
    STA $characterForm
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F2A3 {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0001
    STA $characterForm
    COP [SetEntryExit]
    COP [SpawnThinkerParam] ( #0C, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F2DF {
    LDA $characterForm
    BNE loc_08F2E6
    COP [RestoreSavedPtr]

  loc_08F2E6:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08F357 )
    COP [DialogueOptions] ( #02, #01, &code_list_08F2FF )
}

code_list_08F2FF [
  &code_08F351   ;00
  &code_08F305   ;01
  &code_08F351   ;02
]

code_08F305 {
    COP [PrintDialogString] ( &dialogstring_08F37B )
    LDA $characterForm
    CMP #$0001
    BNE loc_08F331
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F37D
    STA $0002, Y
    REP #$20
    LDA #$&func_08F37D
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

  loc_08F331:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F3B1
    STA $0002, Y
    REP #$20
    LDA #$&func_08F3B1
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

code_08F351 {
    COP [PrintDialogString] ( &dialogstring_08F37B )
    COP [RestoreSavedPtr]
}

dialogstring_08F357 `[TPL:B]Return to young Will? [N] Yes [N] No `

dialogstring_08F37B `[CLD]`
---------------------------------------------

func_08F37D {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    STZ $characterForm
    COP [SetEntryExit]
    COP [SpawnThinkerParam] ( #0B, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F3B1 {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    STZ $characterForm
    COP [SetEntryExit]
    COP [SpawnThinkerParam] ( #0B, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F3EA {
    COP [BranchIfFlagByte] ( #B4, #00, &code_08F41B )
    LDA $characterForm
    CMP #$0002
    BEQ code_08F41B
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [BranchIfFlagByte] ( #DD, #01, &code_08F41D )
    COP [SetFlagByte] ( #DD )
    COP [PrintDialogString] ( &dialogstring_08F4B1 )
    LDA $characterForm
    BEQ loc_08F436
    BRA loc_08F456
}

code_08F41B {
    COP [RestoreSavedPtr]
}

code_08F41D {
    COP [PrintDialogString] ( &dialogstring_08F47C )
    COP [DialogueOptions] ( #02, #02, &code_list_08F427 )
}

code_list_08F427 [
  &code_08F476   ;00
  &code_08F42D   ;01
  &code_08F476   ;02
]

code_08F42D {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    LDA $characterForm
    BNE loc_08F456

  loc_08F436:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F5F9
    STA $0002, Y
    REP #$20
    LDA #$&func_08F5F9
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

  loc_08F456:
    LDY $playerActor
    SEP #$20
    LDA #$^func_08F63C
    STA $0002, Y
    REP #$20
    LDA #$&func_08F63C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

code_08F476 {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    COP [RestoreSavedPtr]
}

dialogstring_08F47C `[TPL:B]Change to the ultimate[N]Dark warrior, Shadow? [N] Yes [N] No `

dialogstring_08F4AF `[CLD]`

dialogstring_08F4B1 `[TPL:B]A voice echoes inside[N]his head.[FIN][TPL:4]I've been waiting for[N]you to come.[FIN]I am made from the light[N]of a comet. The ultimate[N]warrior, Shadow.[FIN]My body has no shape.[N]This body appears only[N]when the human[N]consciousness evolves.[FIN]The comet that now [N]approaches Earth is [N]also a consciousness [N]without form. [FIN]My body is the only[N]thing that can confront[N]the comet and[N]bring it to an end.[FIN]Well, close your eyes...[PAL:0][END]`
---------------------------------------------

func_08F5F9 {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @dark_space_palette.DarkSpacePaletteInit, #00, #00, #$2800 )
    LDA #$0002
    STA $characterForm
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

func_08F63C {
    COP [SetPlayerBodySprite] ( #05 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @dark_space_palette.DarkSpacePaletteInit, #00, #00, #$2800 )
    LDA #$0002
    STA $characterForm
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JSR $&sub_08F6D3
    RTL 
}
---------------------------------------------

actor_08F67F [
  actor-def < #02, #00, #28, {

  code_08F682:
    LDA #$1000
    TSB $12
} >
]

code_08F687 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$000F
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SpawnAfterFlags] ( @code_08F69C, #$1B02 )
    BRA code_08F687
}

code_08F69C {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$0000
    STA $16
    COP [RngByte]
    ASL 
    STA $14
    AND #$0003
    ASL 
    CLC 
    ADC #$0004
    STA $moveXAlt, X
    DEC 
    STA $moveYAlt, X

  loc_08F6C4:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $16
    CMP #$00FF
    BCC loc_08F6C4
    COP [Die]
}
---------------------------------------------

sub_08F6D3 {
    PHX 
    LDX $playerActor
    LDA #$*player_character.PlayerIdleEntry
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    LDA $0010, X
    AND #$FDFF
    ORA #$0008
    STA $0010, X
    LDA #$0F00
    TRB $joypadMaskStd
    LDA #$0800
    TRB $playerFlags
    PLX 
    RTS 
}
---------------------------------------------

e_actor_09A090 {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    RTL 
}

code_09A096 {
    COP [StageSprAndHitbox] ( #01 )
    LDA #$0000
    STA $24

  loc_09A09E:
    COP [SetEntryContinue]
    LDA $24
    BNE loc_09A0A5
    RTL 

  loc_09A0A5:
    LDA $sfxQueueCh1
    BNE loc_09A0AB
    RTL 

  loc_09A0AB:
    COP [RngByte]
    AND #$0003
    DEC 
    BEQ loc_09A0C1
    DEC 
    BEQ loc_09A0CC
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A09E

  loc_09A0C1:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A09E

  loc_09A0CC:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A09E
}