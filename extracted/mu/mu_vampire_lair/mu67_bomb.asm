; Bomb defusal puzzle in the vampire lair — red or blue wire.
; 
; Interactive puzzle (~185 lines): "There's a red wire and a blue
; wire sticking out of the bomb... Cut which wire?" Player
; must choose the correct wire. Wrong choice has consequences.
; "The red wire is cut!" is the success path. Part of the
; tense vampire lair rescue sequence.
---------------------------------------------

?INCLUDE 'oam_digit_compose'
?INCLUDE 'sE6_gaia'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!playerHp                       0ACE
!characterForm                  0AD4
!orbitAngle                     7F0010

---------------------------------------------

mu67_bomb [
  actor-def < #24, #00, #10, {

  code_06A413:
    COP [SpawnMarkedAfterAbs] ( @code_06A69E, #$0080, #$00F0, #$2B00 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06A4C9 )

  loc_06A431:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    LDA $0AEC
    BNE loc_06A431
    LDA $characterForm
    BEQ loc_06A466
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
    BEQ loc_06A466
    RTL 

  loc_06A466:
    COP [StageBgChange] ( #46 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #47 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0146 )
    COP [SetFlagWord] ( #$0147 )

  code_06A478:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_06A478 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    COP [PlaySoundBoth] ( #$2C2C )
    COP [SetOnInteract] ( #$0000 )
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #3C )
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    LDA #$2000
    TSB $10
    COP [LoopNext]
    COP [AddPosition] ( #F8, #00 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #01, #00 )
    COP [PrintDialogString] ( &dialogstring_06A57F )
    COP [SetFlagByte] ( #03 )
    COP [StageBgChange] ( #93 )
    COP [ApplyBgChange]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_06A4C9 {
    COP [PrintDialogString] ( &dialogstring_06A4E9 )
    COP [DialogueOptions] ( #02, #01, &code_list_06A4D3 )
}

code_list_06A4D3 [
  &code_06A4D9   ;00
  &code_06A4D9   ;01
  &code_06A4E1   ;02
]

code_06A4D9 {
    COP [PrintDialogString] ( &dialogstring_06A54E )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_06A4E1 {
    COP [PrintDialogString] ( &dialogstring_06A566 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_06A4E9 `[TPL:E][TPL:0]There's a red wire and[N]a blue wire sticking[N]out of the bomb...[FIN]Cut which one?[N] Red one[N] Blue one`

dialogstring_06A54E `[CLR]The red wire is cut![PAL:0][END]`

dialogstring_06A566 `[CLR]The blue wire is cut![PAL:0][END]`

dialogstring_06A57F `[PAU:28][TPL:A][TPL:0]Will: The bomb [N]has been defused... [FIN][TPL:3]Erik: [N]Saved... [FIN][TPL:2]Lilly speaks from[N]his pocket.[FIN]Lilly: Sorry, Will... [N]There was nothing [N]I could do... [FIN]My legs gave out from[N]fear. I couldn't move or[N]make a sound.[FIN]Up to now I thought I[N]was strong, but in a[N]crisis...[FIN]..............[N]Sorry for staying in[N]your pocket for so long.[PAL:0][END]`

code_06A69E {
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetSpritePalette] ( #02 )
    LDA #$0140
    STA $26
    LDA #$0000
    STA $orbitAngle, X

  code_06A6B1:
    COP [BranchIfFlagByte] ( #01, #01, &code_06A6F5 )
    COP [LoopInit] ( #3C )
    LDA $26
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopNext]
    COP [BranchIfFlagByte] ( #01, #01, &code_06A6F5 )
    LDA $displayModeFlags
    BIT #$2000
    BEQ loc_06A6D7
    LDA $26
    BRA loc_06A6E9

  loc_06A6D7:
    COP [PlaySoundCh1] ( #10 )
    SED 
    LDA $26
    SEC 
    SBC #$0001
    STA $26
    CLD 
    BPL loc_06A6E9
    JMP $&code_06A6F7

  loc_06A6E9:
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [SetEntryExitNow] ( @code_06A6B1 )
}

code_06A6F5 {
    COP [Die]
}

code_06A6F7 {
    LDA $0AEC
    BEQ loc_06A712
    COP [WriteApuIo0] ( #7F )
    STZ $0688
    COP [PlaySoundBoth] ( #$1515 )
    SEP #$20
    LDA #$00
    STA $playerHp
    REP #$20
    COP [SetEntryContinue]
    RTL 

  loc_06A712:
    COP [PrintDialogString] ( &dialogstring_06A719 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_06A719 `[DEF][TPL:0]...........[FIN]It was a dud.[N]I'm saved...[PAL:0][END]`