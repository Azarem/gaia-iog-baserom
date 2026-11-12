; Kara as the follower of Will in the Tower of Babel (placed in scenes $DE, $DF, $E0, $E1 and $E3). It dies at load when $D4 (Kara follows Will) is clear. In scene $E0 with $0178 set (the Neo Fanger fight was won) it clears $D4, locks the player, waits 30 ticks (WaitByte #1D), prints 'Kara's not here... Where did she go...?', unlocks and dies. Otherwise it spawns EscortFollowPathTracker at the player's position, follows the player and spawns the effect sprite code_09870C each time bit $2000 of the player's field $0E changes state.
; 
; $D4 is set by btDF_kara (scene $DF) and by btE3_kara (scene $E3).
---------------------------------------------

?INCLUDE 'EscortFollowPathTracker'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'spriteset_pickups_effects'

!sceneCurrent                   0644
!joypadMaskStd                  065A
!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

btDE_kara_missing [
  actor-def < #1A, #00, #0B, {

  code_098623:
    COP [BranchOnFlagByte] ( #D4, #00, &btDE_kara_missing_destroy )
    LDA $sceneCurrent
    CMP #$00E0
    BNE code_09865A
    COP [BranchOnFlagWord] ( #$0178, #00, &code_09865A )
    COP [ClearFlagByte] ( #D4 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0986E1 )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_09865A {
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SpawnAfterFlags] ( @EscortFollowPathTracker, #$2800 )
    PHX 
    TYX 
    JSL $@GetPlayerFacingDirection
    EOR #$0001
    INC 
    STA $orbitAngle, X
    CMP #$0001
    BEQ loc_098687
    COP [NudgePosition] ( #00, #F0 )
    BRA loc_09868B

  loc_098687:
    COP [NudgePosition] ( #00, #10 )

  loc_09868B:
    LDA #$001A
    STA $orbitDiameter, X
    PLX 
    COP [SetEntryHere]
    COP [AnimOnce]

  loc_098697:
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDY $playerActor
    LDA $000E, Y
    BIT #$2000
    BEQ loc_0986A9
    RTL 

  loc_0986A9:
    LDA #$2000
    TSB $10
    COP [SpawnListAppend] ( @code_09870C, #00, #00, #$1002 )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDY $playerActor
    LDA $000E, Y
    BIT #$2000
    BNE loc_0986C9
    RTL 

  loc_0986C9:
    COP [WaitByte] ( #07 )
    COP [SpawnListAppend] ( @code_09870C, #00, #00, #$1002 )
    COP [WaitByte] ( #0F )
    LDA #$2000
    TRB $10
    BRA loc_098697
}

btDE_kara_missing_destroy {
    COP [Die]
}

dialogstring_0986E1 `[TPL:A][TPL:0]Kara's not here... [N]Where did she go...?[PAL:0][END]`

code_09870C {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [Die]
}