!animScratch                    7F0000
!retPtr1                        7F0004
!animScratch2                   7F000E
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

TrailFollowerSprA {
    COP [StageSprAndHitbox] ( #05 )
    BRA loc_02BDFE
}

TrailFollowerSprB {
    COP [StageSprAndHitbox] ( #06 )

  loc_02BDFE:
    JSR $&TrailPositionInit

  loc_02BE01:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02BE01
    LDA $08
    STZ $08
    STA $26

  loc_02BE0D:
    COP [SetEntryExit]
    LDY $04
    JSR $&TrailPositionCascade
    DEC $26
    BPL loc_02BE0D
    BRA loc_02BE01
}

TrailPositionCascade {
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $animScratch, X
    LDA $animScratch2, X
    STA $animScratch+2, X
    LDA $0014, Y
    STA $animScratch2, X
    LDA $moveXAlt, X
    STA $16
    LDA $moveYAlt, X
    STA $moveXAlt, X
    LDA $retPtr1, X
    STA $moveYAlt, X
    LDA $0016, Y
    STA $retPtr1, X
    RTS 
}

TrailPositionInit {
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X
    LDA $16
    STA $moveXAlt, X
    STA $moveYAlt, X
    STA $retPtr1, X
    RTS 
}