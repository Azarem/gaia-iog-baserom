?INCLUDE 'table_0EE000'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

particle_rain_spawner [
  actor-def < #00, #00, #38, {

  code_0BD2AE:
    LDA #$0078
    STA $24

  loc_0BD2B3:
    LDA $24
    CMP #$0004
    BEQ loc_0BD2BC
    DEC $24

  loc_0BD2BC:
    LDA $24
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_0BD2CB, #$1802 )
    BRA loc_0BD2B3
} >
]

code_0BD2CB {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    COP [SetSpritePriority] ( #30 )
    LDA #$FFE0
    STA $16
    COP [RngByte]
    PHA 
    ASL 
    CLC 
    ADC #$00C4
    STA $14
    PLA 
    AND #$0003
    ASL 
    CLC 
    ADC #$0004
    STA $moveXAlt, X
    DEC 
    STA $moveYAlt, X

  loc_0BD2F7:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $16
    CMP #$0200
    BCC loc_0BD2F7
    COP [Die]
}