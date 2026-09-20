; Ambient bubble effect in the undersea tunnel.
; 
; Visual actor (~105 lines) that spawns floating bubble
; sprites at random positions. Creates the underwater
; atmosphere for the long tunnel passage. Uses RngByte
; for random bubble placement.
---------------------------------------------

!cameraTargetX                  06BE
!cameraTargetY                  06C2

---------------------------------------------

st68_ambient_bubbles [
  actor-def < #00, #00, #38, {

  code_06B93A:
    LDA #$1000
    TSB $12
    LDA $0036
    AND #$003F
    BEQ loc_06B948
    RTL 

  loc_06B948:
    COP [RngByte]
    AND #$0003
    BEQ loc_06B957
    COP [SpawnAfterFlags] ( @code_06B95F, #$0B02 )
    RTL 

  loc_06B957:
    COP [SpawnAfterFlags] ( @code_06B99E, #$0B02 )
    RTL 
} >
]

code_06B95F {
    JSR $&code_06B9E4
    COP [StageSpriteLoopMoveY] ( #35, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #35, #08, #05 )
    COP [AnimLoop]

  code_06B97E:
    COP [StageSpriteMoveY] ( #35, #07 )
    COP [AnimOnce]
    COP [BranchIfSolidHere] ( &code_06B97E )

  loc_06B988:
    COP [StageSpriteMoveY] ( #35, #07 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE loc_06B99C
    COP [RngByte]
    AND #$0007
    BNE loc_06B988

  loc_06B99C:
    COP [Die]
}

code_06B99E {
    JSR $&code_06B9E4
    COP [StageSpriteLoopMoveY] ( #34, #08, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #34, #08, #07 )
    COP [AnimLoop]

  code_06B9C4:
    COP [StageSpriteMoveY] ( #34, #0B )
    COP [AnimOnce]
    COP [BranchIfSolidHere] ( &code_06B9C4 )

  loc_06B9CE:
    COP [StageSpriteMoveY] ( #34, #0B )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE loc_06B9E2
    COP [RngByte]
    AND #$0007
    BNE loc_06B9CE

  loc_06B9E2:
    COP [Die]
}

code_06B9E4 {
    LDA $cameraTargetY
    STA $16
    COP [RngByte]
    CLC 
    ADC $cameraTargetX
    STA $14
    RTS 
}