; Blaster enemy — ranged Pyramid defender.
; 
; Stationary enemy that fires projectiles at the player
; when in range. Uses directional aiming with BranchOnPlayer*
; to target shots. Standard Pyramid corridor enemy.
---------------------------------------------

?INCLUDE 'smooth_follow_child'
?INCLUDE 'spriteset_enemies'

!playerActor                    09AA
!loopCounter                    7F0014

---------------------------------------------

pyCC_blaster [
  actor-def < #1B, #00, #00, {

  code_0BC79B:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0BC807 )

  loc_0BC7A4:
    COP [WaitWhileOffscreen] ( #0D )
    COP [WaitByte] ( #77 )
    COP [BranchOnPlayerX] ( #$0000, &code_0BC7B4, &code_0BC7B4, &code_0BC7C1 )
} >
]

code_0BC7B4 {
    COP [SpawnAfterRelFlags] ( @code_0BC7CE, #$FFF4, #$FFF0, #$0200 )
    BRA loc_0BC7A4
}

code_0BC7C1 {
    COP [SpawnAfterRelFlags] ( @code_0BC7CE, #$000C, #$FFF0, #$0200 )
    BRA loc_0BC7A4
}

code_0BC7CE {
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [AddPosition] ( #00, #02 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [AddPosition] ( #00, #FA )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $playerActor
    STA $24
    LDA #$0008
    STA $0028, X
    LDA #$0001
    STA $loopCounter, X
    SEP #$20
    LDA #$^smooth_follow_child
    PHA 
    REP #$20
    LDA #$&smooth_follow_child-1
    PHA 
    RTL 
}

code_0BC807 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC811, &code_0BC811, &code_0BC816 )
}

code_0BC811 {
    COP [StageSprAndHitbox] ( #1A )
    BRA loc_0BC819
}

code_0BC816 {
    COP [StageSprAndHitbox] ( #9A )

  loc_0BC819:
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]

  loc_0BC82A:
    COP [WaitWhileOffscreen] ( #0D )
    COP [BranchOnPlayerX] ( #$0000, &code_0BC837, &code_0BC837, &code_0BC84A )
}

code_0BC837 {
    COP [SpawnAfterRelFlags] ( @code_0BC85D, #$FFF4, #$FFF0, #$0200 )
    COP [StageSpriteLoop] ( #1A, #04 )
    COP [AnimLoop]
    BRA loc_0BC82A
}

code_0BC84A {
    COP [SpawnAfterRelFlags] ( @code_0BC85D, #$000C, #$FFF0, #$0200 )
    COP [StageSpriteLoop] ( #9A, #04 )
    COP [AnimLoop]
    BRA loc_0BC82A
}

code_0BC85D {
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [AddPosition] ( #00, #02 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [AddPosition] ( #00, #FA )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA $playerActor
    STA $24
    LDA #$0003
    STA $0028, X
    LDA #$0003
    STA $loopCounter, X
    SEP #$20
    LDA #$^smooth_follow_child
    PHA 
    REP #$20
    LDA #$&smooth_follow_child-1
    PHA 
    RTL 
}