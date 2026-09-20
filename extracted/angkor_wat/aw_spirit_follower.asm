; Spirit follower companion in Angkor Wat (~97 lines).
; 
; Spirit entity that follows the player through the temple.
; Floats behind Will and provides ambient company during
; the dungeon exploration. Uses smooth follow mechanics
; to track player movement.
---------------------------------------------

?BANK 0B

?INCLUDE 'smooth_follow'

!playerActor                    09AA
!chatPtr                        7F000A
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!retPtr2                        7F001E

---------------------------------------------

aw_spirit_follower {
    LDA $24
    STA $7F100C, X
    LDA $14
    SEC 
    SBC #$0020
    BRA loc_0BBF03
}

code_0BBEF7 {
    LDA $24
    STA $7F100C, X
    LDA $14
    CLC 
    ADC #$0020

  loc_0BBF03:
    STA $moveXAlt, X
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $moveXAlt, X
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #17, #01 )
    LDA #$8017
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @smooth_follow.InitFollowAndChase, #$2000 )
    TYA 
    STA $orbitDiameter, X
    LDA $playerActor
    STA $0024, Y
    COP [SetEntryExit]

  loc_0BBF45:
    LDA $orbitDiameter, X
    TAY 
    LDA $playerActor
    STA $0024, Y
    COP [CallScript] ( &code_0BBF64 )
    LDA $orbitDiameter, X
    TAY 
    LDA $26
    STA $0024, Y
    COP [CallScript] ( &code_0BBF64 )
    BRA loc_0BBF45
}

code_0BBF64 {
    LDA #$&loc_0BBF75
    STA $retPtr2, X
    COP [RngByte]
    AND #$0001
    INC 
    STA $loopCounter, X

  loc_0BBF75:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BBF75
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryExit]
    DEC $24
    BMI loc_0BBF88
    RTL 

  loc_0BBF88:
    COP [LoopNext]
    COP [RestoreSavedPtr]
}