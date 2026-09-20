; Mummy Queen spirit summon attack (~109 lines).
; 
; Spirit projectile that emerges from the queen and flies
; toward the player. Passes through walls. Used in the
; queen's later phases as a harder-to-dodge attack type.
---------------------------------------------

?BANK 0B

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'aw_spirit_follower'
?INCLUDE 'mummy_queen_angle_table'
?INCLUDE 'smooth_follow'

!playerActor                    09AA
!animScratch                    7F0000
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!scratch1010                    7F1010

---------------------------------------------

pyDD_queen_spirit_attack {
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    COP [StageSprAndHitbox] ( #0E )

  loc_0BABBE:
    COP [WaitByte] ( #03 )
    COP [PlaySoundCh1] ( #26 )
    LDY $24
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BABBE
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDY $24
    LDA $0026, Y
    AND #$0007
    PHX 
    TAX 
    INC 
    STA $0026, Y
    LDA $@mummy_queen_angle_table, X
    PLX 
    AND #$00FF
    STA $orbitAngle, X
    LDA #$000A
    STA $orbitDiameter, X
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    LDA #$0000
    STA $animScratch, X

  loc_0BAC07:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAC07
    LDA $08
    STA $26
    STZ $08
    LDA $animScratch, X
    CMP #$0006
    BCS loc_0BAC2D
    INC 
    STA $animScratch, X

  loc_0BAC21:
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3
    COP [SetEntryExit]
    DEC $26
    BPL loc_0BAC21
    BRA loc_0BAC07

  loc_0BAC2D:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA $24
    STA $26
    COP [SpawnMarkedAfter] ( @smooth_follow.InitFollowAndChase, #$2000 )
    TYA 
    STA $orbitDiameter, X
    LDA #$800E
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    LDA $playerActor
    STA $0024, Y
    COP [SetEntryExit]

  loc_0BAC58:
    LDA $orbitDiameter, X
    TAY 
    LDA $playerActor
    STA $0024, Y
    COP [CallScript] ( &aw_spirit_follower.code_0BBF64 )
    LDA $orbitDiameter, X
    TAY 
    PHX 
    LDX $26
    LDA $scratch1010+6, X
    PLX 
    STA $0024, Y
    COP [CallScript] ( &aw_spirit_follower.code_0BBF64 )
    BRA loc_0BAC58
}