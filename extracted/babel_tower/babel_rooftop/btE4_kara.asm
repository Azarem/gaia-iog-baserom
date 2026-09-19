?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'sE6_gaia'
?INCLUDE 'spriteset_enemies'
?INCLUDE 'spriteset_npc_props'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerActor                    09AA
!playerFlags                    09AE
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

btE4_kara [
  actor-def < #1B, #00, #10, {

  code_098D1B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_098DEA )
    COP [ExitIfFlagByte] ( #0E, #01 )
    COP [SetOnInteract] ( #$0000 )
    JSL $@GetPlayerFacingDirection
    EOR #$0001
    CLC 
    ADC #$001A
    STA $28
    STZ $2A
    COP [SpawnAfterFlags] ( @code_098F01, #$1802 )
    COP [SpawnAfterFlags] ( @code_098F0A, #$1802 )
    COP [SpawnAfterFlags] ( @code_098F13, #$1802 )
    COP [SpawnAfterFlags] ( @code_098F1C, #$1802 )
    COP [SpawnAfterFlags] ( @code_098F25, #$1802 )
    COP [SpawnAfterFlags] ( @code_098F2E, #$1802 )
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_WillToShadow
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_WillToShadow
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #1A, #01 )
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_098DA2
    RTL 

  loc_098DA2:
    COP [PrintDialogString] ( &dialogstring_098EB8 )
    COP [SetFlagByte] ( #0A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    LDY $playerActor
    LDA #$*code_098F7E
    STA $0002, Y
    LDA #$&code_098F7E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitWord] ( #$00EF )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E7, #$0050, #$0090, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_098DEA {
    COP [BranchIfFlagByte] ( #0F, #01, &code_098DF5 )
    COP [PrintDialogString] ( &dialogstring_098DFD )
    RTL 
}

code_098DF5 {
    COP [PrintDialogString] ( &dialogstring_098E17 )
    COP [SetFlagByte] ( #0E )
    RTL 
}

dialogstring_098DFD `[DEF][TPL:1]Kara: [N].................[PAL:0][END]`

dialogstring_098E17 `[DEF][TPL:0][DLY:0]When Will and Kara [N]joined and became one [N]with the Light Knight, a [N]great power was born... [FIN]The Knights were brought [N]forth. The Dark Knight's [N]ultimate power, the [N]Firebird, was released![PAL:0][END]`

dialogstring_098EB8 `[TPL:D][TPL:4][DLY:0]Your battle will change[N]the fate of humanity.[FIN]Now you must go[N]to the comet!![PAL:0][END]`

code_098F01 {
    LDA #$0000
    STA $orbitAngle, X
    BRA loc_098F35
}

code_098F0A {
    LDA #$002A
    STA $orbitAngle, X
    BRA loc_098F35
}

code_098F13 {
    LDA #$0054
    STA $orbitAngle, X
    BRA loc_098F35
}

code_098F1C {
    LDA #$0080
    STA $orbitAngle, X
    BRA loc_098F35
}

code_098F25 {
    LDA #$00AA
    STA $orbitAngle, X
    BRA loc_098F35
}

code_098F2E {
    LDA #$00D4
    STA $orbitAngle, X

  loc_098F35:
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #0A )
    LDA #$0001
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $playerActor
    STA $24
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$0080
    BEQ loc_098F6B
    INC 
    STA $orbitDiameter, X

  loc_098F6B:
    COP [BranchIfFlagByte] ( #0A, #01, &code_098F72 )
    RTL 
}

code_098F72 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [Die]
}

code_098F7E {
    LDA #$0008
    TRB $10
    COP [StagePlayerSprite] ( #1C )
    COP [AnimOnce]
    COP [ToggleVFlip]

  loc_098F8A:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    BRA loc_098F8A
}