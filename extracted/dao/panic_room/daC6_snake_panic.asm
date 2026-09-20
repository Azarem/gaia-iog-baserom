; Snake Panic mini-game controller in Dao (~223 lines).
; 
; Interactive mini-game: "Play the game with the snakes? Yes/No"
; Player navigates between moving snakes to reach the goal.
; Includes game setup, snake movement patterns, collision
; detection, win/lose outcomes, and reward dialog.
; "Too bad. Come back if you change your mind."
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!playerFlags                    09AE
!jewelsCollected                0AB0
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

daC6_snake_panic [
  actor-def < #1F, #00, #10, {

  code_08AE4C:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @code_08B0D4, #$FFD0, #$0010, #$0300 )
    COP [SpawnAfterRelFlags] ( @code_08B0D4, #$0000, #$0010, #$0300 )
    COP [SpawnAfterRelFlags] ( @code_08B0D4, #$0030, #$0010, #$0300 )
    COP [SolidHighHere]
    COP [ClearFlagByte] ( #04 )
    COP [SetOnInteract] ( &code_08AEA4 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_08AECA )
    COP [SpawnAfterFlags] ( @code_08AFB4, #$2000 )
    COP [ClearFlagByte] ( #03 )

  loc_08AE8D:
    COP [BranchIfFlagByte] ( #04, #01, &code_08AE99 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_08AE8D
} >
]

code_08AE99 {
    COP [SetOnInteract] ( &code_08AECF )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_08AEA4 {
    COP [PrintDialogString] ( &dialogstring_08AED4 )
    COP [DialogueOptions] ( #02, #02, &code_list_08AEAE )
}

code_list_08AEAE [
  &code_08AEB4   ;00
  &code_08AEB9   ;01
  &code_08AEB4   ;02
]

code_08AEB4 {
    COP [PrintDialogString] ( &dialogstring_08AEF7 )
    RTL 
}

code_08AEB9 {
    COP [PrintDialogString] ( &dialogstring_08AF16 )
    COP [SetFlagByte] ( #01 )
    STZ $0AAC
    LDA #$0008
    TRB $playerFlags
    RTL 
}

code_08AECA {
    COP [PrintDialogString] ( &dialogstring_08AF94 )
    RTL 
}

code_08AECF {
    COP [PrintDialogString] ( &dialogstring_08B0B3 )
    RTL 
}

dialogstring_08AED4 `[DEF]Play the game[N]with the snakes?[N] Yes[N] No`

dialogstring_08AEF7 `[CLR]Too bad. Come back if[N]you change your mind.[END]`

dialogstring_08AF16 `[CLR]The rules are simple. [N]Hit as many snakes as [N]you can in one minute. [FIN]Hit whatever pot[N]you like! That's the[N]start of the game!![END]`

dialogstring_08AF94 `[DEF]Hey, hey. There's[N]plenty of them.[END]`

code_08AFB4 {
    COP [ExitIfFlagByte] ( #02, #01 )
    PHX 
    LDX #$0000

  loc_08AFBC:
    STZ $0410, X
    INX 
    INX 
    CPX #$0010
    BNE loc_08AFBC
    PLX 
    LDA #$0055
    STA $041E
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    COP [RngByte]
    STZ $24
    COP [SetEntryContinue]
    LDA $24
    CMP #$0E10
    BEQ loc_08AFED
    INC $24
    RTL 

  loc_08AFED:
    COP [BranchIfFlagByte] ( #E7, #01, &code_08AFFB )
    LDA $0AAC
    CMP #$0051
    BCS loc_08B010
}

code_08AFFB {
    COP [PrintDialogString] ( &dialogstring_08B025 )

  loc_08AFFF:
    COP [ClearFlagByte] ( #01 )
    COP [ClearFlagByte] ( #02 )
    COP [SetFlagByte] ( #03 )
    LDA #$0008
    TSB $playerFlags
    COP [Die]

  loc_08B010:
    COP [SetFlagByte] ( #E7 )
    COP [PrintDialogString] ( &dialogstring_08B052 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0002
    STA $jewelsCollected
    CLD 
    BRA loc_08AFFF
}

dialogstring_08B025 `[TPL:A][DLY:2]OK! Stop![N]You've hit [BCD:3,AAC] snakes.[N]Try again![END]`

dialogstring_08B052 `[TPL:A][DLY:2]Wow [BCD:3,AAC] snakes. Very[N]good![FIN]For your prize, I'll give [N]you two Red Jewels. [FIN]I'll send them to[N]the Jeweler.[END]`

dialogstring_08B0B3 `[TPL:A]You've hit [BCD:3,AAC] snakes.[N]Try again![END]`

code_08B0D4 {
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SolidHighHere]

  loc_08B0E2:
    COP [StageSprAndHitbox] ( #24 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$0200
    TRB $10
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_08B0FD )
    COP [ExitIfFlagByte] ( #02, #01 )
}

code_08B0FD {
    COP [SetFlagByte] ( #02 )
    COP [SetHitCallback] ( &code_08B138 )

  loc_08B104:
    COP [BranchIfFlagByte] ( #03, #01, &code_08B133 )
    LDA #$00FF
    STA $currentHp, X
    COP [RngByte]
    AND #$000F
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_08B127:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0200
    TSB $10
    BRA loc_08B104
}

code_08B133 {
    COP [SetFlagByte] ( #04 )
    BRA loc_08B0E2
}

code_08B138 {
    COP [PlaySoundCh1] ( #0D )
    SED 
    LDA $0AAC
    CLC 
    ADC #$0001
    STA $0AAC
    CLD 
    LDA #$0200
    TSB $10
    COP [SetHitCallback] ( &code_08B138 )
    BRA loc_08B127
}