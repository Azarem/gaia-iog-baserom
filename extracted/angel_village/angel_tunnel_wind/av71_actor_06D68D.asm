!extVelocityX                   0408
!cameraTargetX                  06BE
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

av71_actor_06D68D [
  actor-def < #00, #00, #30, {

  code_06D690:
    COP [SpawnAfterFlags] ( @code_06D6A0, #$2800 )
    COP [SetEntryContinue]
    LDA #$FFF7
    STA $extVelocityX
    RTL 
} >
]

code_06D6A0 {
    LDA $0036
    AND #$000F
    BEQ loc_06D6A9
    RTL 

  loc_06D6A9:
    COP [RngByte]
    AND #$0001
    BEQ loc_06D6B8
    COP [SpawnAfterFlags] ( @code_06D6C0, #$0B02 )
    RTL 

  loc_06D6B8:
    COP [SpawnAfterFlags] ( @code_06D6EF, #$0B02 )
    RTL 
}

code_06D6C0 {
    COP [StageSprAndHitbox] ( #1C )

  loc_06D6C3:
    LDA $cameraTargetX
    CLC 
    ADC #$0110
    STA $14
    COP [RngByte]
    STA $16
    AND #$0003
    CLC 
    ADC #$0005
    ASL 
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X

  loc_06D6E3:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $14
    BPL loc_06D6E3
    COP [Die]
}

code_06D6EF {
    COP [StageSprAndHitbox] ( #1D )
    BRA loc_06D6C3
}