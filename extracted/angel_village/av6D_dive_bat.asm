; Dive Bat enemy in the Angel Village tunnels.
; 
; Flying enemy that hangs from the ceiling, then swoops down
; toward the player when in range. Quick strike-and-return
; pattern. Common tunnel enemy alongside Steelbones.
---------------------------------------------

?INCLUDE 'EnemyDefeatDispatch'

!playerXPos                     09A2
!playerYPos                     09A4
!moveScratch2                   7F002E

---------------------------------------------

av6D_dive_bat [
  actor-def < #0F, #00, #00, {

  code_0AEEA2:
    COP [SetDeathCallback] ( @code_0AEF2E )
    LDA #$2000
    TSB $12
    COP [OrExtraFlags] ( #$0020 )
    BRA loc_0AEEB6

  loc_0AEEB2:
    COP [BranchIfOffCamera] ( &code_0AEEE3 )

  loc_0AEEB6:
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $16
    STA $26
    LDA $playerYPos
    SEC 
    SBC $16
    BPL loc_0AEECB
    RTL 

  loc_0AEECB:
    CMP #$0100
    BCC loc_0AEED1
    RTL 

  loc_0AEED1:
    LDA $playerXPos
    SEC 
    SBC $14
    BPL loc_0AEEDD
    EOR #$FFFF
    INC 

  loc_0AEEDD:
    CMP #$0040
    BCC code_0AEEE3
    RTL 
} >
]

code_0AEEE3 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AEEED, &code_0AEEED, &code_0AEEF2 )
}

code_0AEEED {
    COP [StageSprAndHitbox] ( #11 )
    BRA loc_0AEEFA
}

code_0AEEF2 {
    COP [StageSprAndHitbox] ( #91 )
    LDA #$4000
    TSB $12

  loc_0AEEFA:
    COP [InitGravity] ( #04, #09, #00 )

  loc_0AEEFF:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    COP [TickGravity]
    COP [StageMoveX] ( #02 )
    LDA $16
    CMP $26
    BCC loc_0AEF1A
    DEC $24
    BMI loc_0AEEFF
    RTL 

  loc_0AEF1A:
    LDA #$4000
    TRB $12
    STZ $2C
    LDA #$0000
    STA $moveScratch2, X
    LDA $26
    STA $16
    BRA loc_0AEEB2
}

code_0AEF2E {
    COP [JumpFar] ( @EnemyDefeatDispatch )
}