?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec0E_lily [
  actor-def < #15, #00, #20, {

  code_09A918:
    LDA #$0008
    TSB $12
    COP [BranchIfFlagByte] ( #DE, #01, &code_09A99F )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_09A92B )
    RTL 
} >
]

code_09A92B {
    COP [SetFlagByte] ( #DE )
    COP [SpawnMarkedAfter] ( @code_09A9A1, #$0102 )
    LDA #$04B0
    STA $24

  code_09A93A:
    COP [DirToPlayer]
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_09A945 )
}

code_list_09A945 [
  &code_09A955   ;00
  &code_09A959   ;01
  &code_09A95F   ;02
  &code_09A963   ;03
  &code_09A969   ;04
  &code_09A96D   ;05
  &code_09A973   ;06
  &code_09A977   ;07
]

code_09A955 {
    DEC $16
    BRA loc_09A97D
}

code_09A959 {
    DEC $16
    INC $14
    BRA loc_09A97D
}

code_09A95F {
    INC $14
    BRA loc_09A97D
}

code_09A963 {
    INC $16
    INC $14
    BRA loc_09A97D
}

code_09A969 {
    INC $16
    BRA loc_09A97D
}

code_09A96D {
    INC $16
    DEC $14
    BRA loc_09A97D
}

code_09A973 {
    DEC $14
    BRA loc_09A97D
}

code_09A977 {
    DEC $16
    DEC $14
    BRA loc_09A97D

  loc_09A97D:
    DEC $24
    BEQ loc_09A986
    COP [SetEntryExitNow] ( @code_09A93A )

  loc_09A986:
    COP [PrintDialogString] ( &dialogstring_09AA1B )
    LDA #$0060
    STA $moveXAlt, X
    LDA #$0030
    STA $moveYAlt, X
    COP [StageMove] ( #00, #01, #FF )
    COP [TickMove]
}

code_09A99F {
    COP [Die]
}

code_09A9A1 {
    LDA #$0030
    TSB $12
    LDA #$&stats_01ABF0+190
    STA $statsPtr, X
    LDA $@stats_01ABF0+190
    AND #$00FF
    STA $currentHp, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #33 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X

  loc_09A9CE:
    COP [SetHitCallback] ( &code_09A9F5 )

  loc_09A9D2:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_09A9D2
    LDA $08
    STZ $08
    STA $26

  loc_09A9DE:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
    COP [SetEntryExit]
    DEC $26
    BPL loc_09A9DE
    BRA loc_09A9D2
}

code_09A9F5 {
    LDA #$00FF
    STA $currentHp, X
    COP [PrintDialogString] ( &dialogstring_09AA02 )
    BRA loc_09A9CE
}

dialogstring_09AA02 `[DEF][TPL:2]Hey! What are you doing!![PAL:0][END]`

dialogstring_09AA1B `[DEF][TPL:2]Come here, or the[N]demon will get you![PAL:0][END]`