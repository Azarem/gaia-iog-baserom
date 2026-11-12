; Spirit at the Babel exterior (scene $E2): a solid NPC with the interact handler 'You were brought back to save Earth. I'll take you to the top floor.', which sets scratch $01. The main script waits for $01 and then locks the player ($CFFC), moves to the player, spawns the child code_099899, hands the player the script btE1_comet_soon.code_0997B7 (the ride), sets bit $0800 of the player's flags, rises while y is at least $90, waits 60 ticks (WaitByte #3B), moves to (0188,0110), kills the child, sets scratch $04 (read by the ride script) and unlocks. The actor tests no persistent flag.
---------------------------------------------

?INCLUDE 'btE1_comet_soon'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

btE2_brought_back [
  actor-def < #00, #00, #10, {

  code_0997CF:
    LDA #$0200
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_09985E )
    COP [WaitOnFlagByte] ( #01, #01 )
    LDA #$0001
    TSB $10
    LDA #$CFFC
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [SpawnBeforeFlags] ( @code_099899, #$2000 )
    LDY $playerActor
    LDA #$*btE1_comet_soon.code_0997B7
    STA $0002, Y
    LDA #$&btE1_comet_soon.code_0997B7
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_099827:
    COP [StageSpriteMoveY] ( #00, #08 )
    COP [AnimOnce]
    LDA $16
    CMP #$0090
    BCS loc_099827
    COP [WaitByte] ( #3B )
    LDA #$0188
    STA $moveXAlt, X
    LDA #$0110
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [KillPrev]
    COP [SetFlagByte] ( #04 )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #00, #0A, #04 )
    COP [AnimLoop]
    COP [SetEntryHere]
    RTL 
} >
]

code_09985E {
    COP [PrintDialogString] ( &dialogstring_099866 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_099866 `[DEF]You were brought back to [N]save Earth. I'll take [N]you to the top floor.[END]`

code_099899 {
    COP [SetEntryHere]
    PHX 
    LDX $24
    LDY $playerActor
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC #$0008
    STA $0016, Y
    PLX 
    RTL 
}