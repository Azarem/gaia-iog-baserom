; Falling orb hazard in the Pyramid trickle area (~93 lines).
; 
; Environmental trap: energy orbs fall from above in timed
; patterns. Player must dodge between falling orbs.
; Uses position timing with spawn intervals.
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'spriteset_enemies'

!playerActor                    09AA
!characterForm                  0AD4

---------------------------------------------

pyD4_falling_orb [
  actor-def < #00, #00, #30, {

  code_08C6ED:
    LDA $0E
    CLC 
    ADC #$0080
    STA $24
    LDA #$2000
    STA $0E
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #1B )
    COP [NudgePosition] ( #08, #00 )
    LDA $24
    JSL $@flag_helpers.TestFlagRaw
    BCC loc_08C711
    JMP $&code_08C76E

  loc_08C711:
    COP [SetEntryHere]
    PHX 
    LDX $playerActor
    LDA $7F0008, X
    AND #$00FF
    CMP #$0097
    BNE loc_08C72B
    LDA $0028, X
    CMP #$0001
    BEQ loc_08C72D

  loc_08C72B:
    PLX 
    RTL 

  loc_08C72D:
    PLX 
    LDA $characterForm
    CMP #$0001
    BEQ loc_08C737
    RTL 

  loc_08C737:
    COP [BranchIfPlayerNear] ( #0C, &code_08C73D )
    RTL 
} >
]

code_08C73D {
    LDA $24
    JSL $@flag_helpers.SetFlagRaw
    COP [WaitByte] ( #B3 )
    COP [RngByte]
    STA $08
    COP [SetEntryHereAndYield]
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [SetPriorityMax]
    COP [StageSpriteLoopMoveY] ( #1B, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [ClearPriorityMax]
    COP [StageSpriteMoveY] ( #1B, #35 )
    COP [AnimOnce]
}

code_08C76E {
    LDA #$3000
    TRB $10
    LDA #$0300
    TSB $10
    COP [SetPriorityMin]
    COP [ClearCollisionHere]
    COP [SetEntryHere]
    RTL 
}