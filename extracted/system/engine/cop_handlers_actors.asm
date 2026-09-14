?BANK 00

?INCLUDE 'actor_execution'
?INCLUDE 'body_table'
?INCLUDE 'cop_handlers_collision'
?INCLUDE 'DialogStringRenderer'
?INCLUDE 'event_blocks'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'movement_delta_table'
?INCLUDE 'music_actors'
?INCLUDE 'sprite_composition'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!playerActor                    09AA
!playerFlags                    09AE
!playerWallType                 09B0
!displayModeFlags               09EC
!characterForm                  0AD4
!activeActorCount               0DBC
!APUIO0                         2140
!APUIO1                         2141
!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010
!free101C                       7F101C
!chainDamage                    7F101E

---------------------------------------------

StartMusic {
    TYX 
    PHX 
    JSR $&AllocateActorAfter
    TYX 
    LDA #$&hdma_dma_spc.SpcTransferMusicData
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcTransferMusicData
    STA $0002, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    LDA $0010, X
    AND #$EFFF
    STA $0010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

FadeThenStartMusic {
    TYX 
    PHX 
    JSR $&AllocateActorAfter
    TYX 
    LDA #$&hdma_dma_spc.SpcCheckMusicReady
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcCheckMusicReady
    STA $0002, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    LDA $0010, X
    AND #$EFFF
    STA $0010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

PlaySoundCh2 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh2
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

PlaySoundCh1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

PlaySoundBoth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $sfxQueueCh1
    LDA $0A
    STA $02, S
    RTI 
}

WriteApuIo1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

WriteApuIo0 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO0
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

MusicAndText {
    TYX 
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    BCS loc_008836
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&CopyActorState
    LDA #$&music_actors.MusicPlaybackActor
    STA $0000, Y
    LDA #$*music_actors.MusicPlaybackActor
    STA $0002, Y
    LDA #$1000
    STA $0012, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0026, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0020, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0022, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_008836:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    PHP 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    JSL $@system_core.UpdateFrameRender
    REP #$20
    JSL $@DialogStringRenderer
    PLA 
    STA $joypadMaskStd
    PLB 
    PLP 
    LDA #$0080
    TRB $displayModeFlags
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

StageBgChange {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00931F:
    JSL $@event_blocks.LookupEventBlock
    LDA $0A
    STA $02, S
    RTI 
}

ApplyBgChange {
    TYX 
    SEP #$20
    JSL $@system_core.UpdateFrameRender
    JSL $@system_core.UpdateFrameDialogue
    REP #$20

  loc_009335:
    JSL $@event_blocks.AnimateEventBlock
    BCS loc_009345
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    BRA loc_009335

  loc_009345:
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

StageBgChangeFromDeathIdx {
    TYX 
    LDA $deathActionIdx, X
    PHA 
    LDA #$0F0F
    STA $sfxQueueCh1
    PLA 
    BRA loc_00931F
}

PaletteRestart {
    TYX 
    BRA loc_009370
}

PaletteStart {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_009370:
    STZ $0E
    JSL $@hdma_dma_spc.LoadPaletteBundle
    JSL $@hdma_dma_spc.DecompressGfxToVram
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

PaletteStartLoop {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    STZ $000E, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $retPtr1, X
    JSL $@hdma_dma_spc.LoadPaletteBundle
    JSL $@hdma_dma_spc.DecompressGfxToVram
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

PaletteStep {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0093BD
    JSL $@hdma_dma_spc.LoadPaletteBundle
    BCC loc_0093C7
    LDA $0A
    STA $02, S
    RTI 

  loc_0093BD:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $08

  loc_0093C7:
    JSL $@hdma_dma_spc.DecompressGfxToVram
    PLA 
    PLA 
    RTL 
}

PaletteStepLoop {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0093EE

  loc_0093D6:
    JSL $@hdma_dma_spc.LoadPaletteBundle
    BCC loc_0093F9
    LDA $retPtr1, X
    DEC 
    BEQ loc_0093E9
    STA $retPtr1, X
    BRA loc_0093D6

  loc_0093E9:
    LDA $0A
    STA $02, S
    RTI 

  loc_0093EE:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $0008, X

  loc_0093F9:
    JSL $@hdma_dma_spc.DecompressGfxToVram
    PLA 
    PLA 
    RTL 
}

SpawnThinkerParam {
    PHY 
    JSR $&AllocateSpecialActor
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_009410:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, X
    TXY 
    LDA $01, S
    TAX 
    LDA $animScratch2, X
    TYX 
    STA $animScratch2, X
    LDA #$0000
    STA $000E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

SpawnThinker {
    PHY 
    JSR $&AllocateSpecialActor
    TYX 
    BRA loc_009410
}

KillThinker {
    TYX 
    LDY $0004, X
    BNE loc_009459
    LDY $0006, X
    STY $005A
    BEQ loc_00946D
    LDA #$0000
    STA $0004, Y
    BRA loc_00946D

  loc_009459:
    LDA $0006, X
    STA $0006, Y
    BNE loc_009466
    STY $005C
    BRA loc_00946D

  loc_009466:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_00946D:
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    DEC $0052
    DEC $0052
    REP #$20
    TXA 
    STA [$52]
    PLD 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

BranchIfPlayerInRelTiles {
    PHY 
    LDX $playerActor
    LDY #$0000
    LDA [$0A]
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_009580
    ORA #$FF00

  loc_009580:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_00959A
    ORA #$FF00

  loc_00959A:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095B4
    ORA #$FF00

  loc_0095B4:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCC loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095CE
    ORA #$FF00

  loc_0095CE:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCC loc_0095E0
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_0095E0:
    PLX 
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

BranchIfPlayerInAbsTiles {
    PHY 
    LDX $playerActor
    LDY #$0000
    LDA $0016, X
    SEC 
    SBC #$0008
    STA $0000
    LDA [$0A]
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCC loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCC loc_00963D
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_00963D:
    PLX 
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

CopyPosToPrev {
    TYX 
    LDY $04
    BRA loc_00964F
}

CopyPosToNext {
    TYX 
    LDY $06

  loc_00964F:
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

GetPlayerFacing {
    TYX 
    LDA $0A
    STA $02, S
    JSL $@GetPlayerFacingDirection
    RTI 
}

BranchIfBodyNe {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $characterForm
    BNE loc_00967C
    LDA $0A
    INC 
    INC 
    STA $02, S
    RTI 

  loc_00967C:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}
---------------------------------------------

ResetSpriteState {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $24
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

AdvanceSpriteAnim {
    TYX 
    LDA $00B2
    BEQ loc_0099FE
    PLA 
    PLA 
    RTL 

  loc_0099FE:
    PHB 
    LDA $24
    STA $00B0
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $28
    ASL 
    CLC 
    ADC $spritesetPtr, X
    TAY 
    LDA $2A
    INC $2A
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_009A5F
    STA $08
    LDA $0002, Y
    TAY 
    LDA $0012, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $animScratch, X
    STA $00AC
    LDA $animScratch+2, X
    STA $00AE
    LDA #$0020
    STA $00B2
    LDA $000D, Y
    AND #$00FF
    BEQ loc_009A5B
    LDA #$0080
    STA $00B2

  loc_009A5B:
    PLB 
    PLA 
    PLA 
    RTL 

  loc_009A5F:
    STZ $2A
    PLB 
    LDA $0A
    STA $02, S
    RTI 
}

SetDeathCallback {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDeathCallback, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F1006, X
    LDA $0A
    STA $02, S
    RTI 
}

SetHitCallback {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onHitCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

SetDodgeCallback {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDodgeCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

SetCollideCallback {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onCollideCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

SetCustomCallback {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $scratch1010+6, X
    LDA $0A
    STA $02, S
    RTI 
}

OrExtraFlags {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    ORA $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

AndExtraFlags {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    AND $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

SetLinkedEntryPtr {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDY $06
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A
    STA $02, S
    RTI 
}

StageSpr {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprX {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprXY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprLoop {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprLoopX {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprLoopY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StageSprLoopXY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

ProcessAnimFlag {
    STZ $2A
    CMP #$00FF
    BNE loc_009F67
    RTS 

  loc_009F67:
    BIT #$0080
    BEQ loc_009F7F
    AND #$FF7F
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_009F79
    RTS 

  loc_009F79:
    LDA #$4000
    TSB $0E
    RTS 

  loc_009F7F:
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_009F89
    RTS 

  loc_009F89:
    LDA #$4000
    TRB $0E
    RTS 
}

SetMetasprite {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $spritesetPtr, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F0008, X
    LDA $0A
    STA $02, S
    RTI 
}

AnimOnce {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FBD
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_009FBD:
    PLA 
    PLA 
    RTL 
}

AnimLoop {
    TYX 

  loc_009FC1:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FDB
    LDA $sprTimer, X
    DEC 
    STA $sprTimer, X
    BNE loc_009FC1
    STZ $2C
    STZ $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_009FDB:
    PLA 
    PLA 
    RTL 
}

AnimOneFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FEC
    LDA #$0000
    STA $2C
    STA $2E

  loc_009FEC:
    LDA $0A
    STA $02, S
    RTI 
}

WaitForAnimFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A00B
    LDA #$0000
    STA $2C
    STA $2E
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 

  loc_00A00B:
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $2A
    BEQ loc_00A019
    PLA 
    PLA 
    RTL 

  loc_00A019:
    LDA $0A
    STA $02, S
    RTI 
}

StageSprAndHitbox {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    JSL $@sprite_composition.UpdateActorAnimation
    STZ $2A
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

SetPlayerSpriteDirect {
    TYX 
    SEP #$20
    LDA [$0A]
    STA $0AC8
    ASL 
    CLC 
    ADC [$0A]
    ASL 
    REP #$20
    AND #$00FF
    STA $animScratch2, X
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TSB $playerFlags
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

StagePlayerSpr {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StagePlayerSprX {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StagePlayerSprY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StagePlayerSprXY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

RunPlayerAnim {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A116
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_00A116:
    PLA 
    PLA 
    RTL 
}

StagePlayerSprWall {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $playerWallType
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

StagePlayerSprFromDP {
    TYX 
    LDA $0000
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&SetActorBody
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

WallAnimHere {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A1A4
    LDA $16
    BIT #$000F
    BNE loc_00A19E
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_collision.TileCollisionQuery
    AND #$00FF
    BIT #$00F0
    BNE loc_00A1A9
    CMP #$000F
    BEQ loc_00A1A9
    CMP $playerWallType
    BNE loc_00A1A4

  loc_00A19E:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A1B2

  loc_00A1A4:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1A9:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A1A4

  loc_00A1B2:
    PLA 
    PLA 
    RTL 
}

WallAnimNorth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A1EF
    LDA $16
    BIT #$000F
    BNE loc_00A1E9
    SEC 
    SBC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_collision.TileCollisionQuery
    AND #$00FF
    BIT #$00F0
    BNE loc_00A1F4
    CMP #$000F
    BEQ loc_00A1F4
    CMP $playerWallType
    BNE loc_00A1EF

  loc_00A1E9:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A1FD

  loc_00A1EF:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1F4:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A1EF

  loc_00A1FD:
    PLA 
    PLA 
    RTL 
}

WallAnimSouth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A23A
    LDA $16
    BIT #$000F
    BNE loc_00A234
    CLC 
    ADC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_collision.TileCollisionQuery
    AND #$00FF
    BIT #$00F0
    BNE loc_00A23F
    CMP #$000F
    BEQ loc_00A23F
    CMP $playerWallType
    BNE loc_00A23A

  loc_00A234:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A248

  loc_00A23A:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A23F:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A23A

  loc_00A248:
    PLA 
    PLA 
    RTL 
}

SpawnBefore {
    TYX 
    JSR $&AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnBeforeFlags {
    TYX 
    JSR $&AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfter {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterFlags {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterOffset {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterOffsetFlags {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterAbs {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterAbsFlags {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

SpawnBeforeMarked {
    TYX 
    JSR $&AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterMarked {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterAbsMarked {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

SpawnAfterOffsetMarked {
    TYX 
    JSR $&AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A466
    ORA #$FF00

  loc_00A466:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A47C
    ORA #$FF00

  loc_00A47C:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

SpawnListAppend {
    PHY 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    BCS loc_00A50A
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&CopyActorState
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A4DF
    ORA #$FF00

  loc_00A4DF:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A4F5
    ORA #$FF00

  loc_00A4F5:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A50A:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

SpawnListAppendSpr {
    PHY 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    BCS loc_00A5AE
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&CopyActorState
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0028, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A583
    ORA #$FF00

  loc_00A583:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A599
    ORA #$FF00

  loc_00A599:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A5AE:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

MarkDeath {
    TYX 
    PHD 
    LDA $12
    BIT #$0040
    BEQ loc_00A5EC
    PEA $&code_00A5EF-1
    BRA loc_00A60E

  loc_00A5EC:
    JSR $&UnlinkActor
}

code_00A5EF {
    PLA 
    TAX 
    TCD 
    LDA $0A
    STA $02, S
    RTI 
}

Die {
    TYX 
    PHD 
    LDA $12
    BIT #$0040
    BEQ loc_00A605
    PEA $&DieNow_UnlinkChildren-1
    BRA loc_00A60E

  loc_00A605:
    JSR $&UnlinkActor
}

DieNow_UnlinkChildren {
    PLA 
    TAX 
    TCD 
    PLA 
    PLA 
    RTL 

  loc_00A60E:
    STX $0000
    LDA $0004, X
    TAX 
    BEQ loc_00A626

  loc_00A617:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A626
    LDA $0004, X
    TAX 
    BNE loc_00A617

  loc_00A626:
    STX $0002
    LDX $0000
    LDA $0006, X
    TAX 
    BEQ loc_00A641

  loc_00A632:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A641
    LDA $0006, X
    TAX 
    BNE loc_00A632

  loc_00A641:
    STX $0004
    LDX $0002
    BNE loc_00A64F
    LDX $0056
    JSR $&ReturnActorSlot

  loc_00A64F:
    LDA $0006, X
    CMP $0004
    BEQ loc_00A65D
    TAX 
    JSR $&ReturnActorSlot
    BRA loc_00A64F

  loc_00A65D:
    LDA $0002
    BNE loc_00A675
    LDX $0004
    STX $0056
    STZ $0004, X
    LDA $03, S
    TAX 
    TCD 
    LDA $0004
    STA $06
    RTS 

  loc_00A675:
    LDA $0004
    BNE loc_00A68A
    LDX $0002
    STX $0058
    STZ $0006, X
    LDA $03, S
    TAX 
    TCD 
    STZ $06
    RTS 

  loc_00A68A:
    LDY $0004
    LDA $0002
    STA $0004, Y
    TAX 
    TYA 
    STA $0006, X
    TAY 
    LDA $03, S
    TAX 
    TCD 
    TYA 
    STA $06
    RTS 
}

KillPrev {
    PHY 
    LDA $04
    TCD 
    TAX 
    JSR $&UnlinkActor
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

KillNext {
    PHY 
    LDA $06
    TCD 
    TAX 
    JSR $&UnlinkActor
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

StageMoveX {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA $0A
    STA $02, S
    RTI 
}

StageMoveY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

StageMoveXY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

ForceDirSW {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A727
    LDA #$4000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A727:
    LDA #$4000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

ForceDirNE {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A745
    LDA #$2000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A745:
    LDA #$2000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

ForceDirBoth {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A763
    LDA #$6000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A763:
    LDA #$6000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

ApplyMoveToChild {
    PHY 
    LDX $0058
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $002C, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $002E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

ReloadMoveDurations {
    TYX 
    LDA $moveXAlt, X
    JSR $&AnimFrameLookup
    STA $002C, X
    LDA $moveYAlt, X
    JSR $&AnimFrameLookup
    STA $002E, X
    LDA $0A
    STA $02, S
    RTI 
}

SetPriorityMax {
    TYX 
    LDA #$0002
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

SetPriorityMin {
    TYX 
    LDA #$0001
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

ClearPriorityMax {
    TYX 
    LDA #$0002
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

ClearPriorityMin {
    TYX 
    LDA #$0001
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

SetOamPriority {
    TYX 
    LDA #$3000
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

SetOamPalette {
    TYX 
    LDA #$0E00
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

ToggleHMirror {
    TYX 
    LDA $0E
    EOR #$4000
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

ToggleVMirror {
    TYX 
    LDA $0E
    EOR #$8000
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

ClearHMirror {
    TYX 
    LDA #$4000
    TRB $0E
    LDA $0A
    STA $02, S
    RTI 
}

SetHMirror {
    TYX 
    LDA #$4000
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

NudgePosition {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A849
    ORA #$FF00

  loc_00A849:
    CLC 
    ADC $14
    STA $14
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A85D
    ORA #$FF00

  loc_00A85D:
    CLC 
    ADC $16
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

UnlinkActor {
    LDY $0004, X
    BNE loc_00AF55
    LDY $0006, X
    STY $0056
    BEQ loc_00AF69
    LDA #$0000
    STA $0004, Y
    BRA loc_00AF69

  loc_00AF55:
    LDA $0006, X
    STA $0006, Y
    BNE loc_00AF62
    STY $0058
    BRA loc_00AF69

  loc_00AF62:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_00AF69:
    JSR $&ReturnActorSlot
    RTS 
}

SetActorBody {
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TRB $playerFlags
    RTS 
}
---------------------------------------------

AnimFrameLookup {
    ASL 
    TAY 
    LDA $&movement_delta_table, Y
    RTS 
}

AllocateActorBefore {
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    PLD 
    BCS loc_00B188
    TXA 
    STA $0006, Y
    LDA $04
    STA $0004, Y
    TYA 
    STA $04
    PHX 
    LDX $0004, Y
    BNE loc_00B180
    STY $0056
    BRA loc_00B184

  loc_00B180:
    TYA 
    STA $0006, X

  loc_00B184:
    PLX 
    JSR $&CopyActorState

  loc_00B188:
    RTS 
}

AllocateActorAfter {
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    PLD 
    BCS loc_00B1B4
    TXA 
    STA $0004, Y
    LDA $06
    STA $0006, Y
    TYA 
    STA $06
    PHX 
    LDX $0006, Y
    BEQ loc_00B1AD
    TYA 
    STA $0004, X
    BRA loc_00B1B0

  loc_00B1AD:
    STY $0058

  loc_00B1B0:
    PLX 
    JSR $&CopyActorState

  loc_00B1B4:
    RTS 
}

ReturnActorSlot {
    LDA #$0000
    TCD 
    SEP #$20
    DEC $004E
    DEC $004E
    DEC $activeActorCount
    REP #$20
    TXA 
    STA [$4E]
    TCD 
    RTS 
}

MarkChildActor {
    LDA $parentId, X
    BNE loc_00B1D2
    TDC 

  loc_00B1D2:
    TYX 
    STA $parentId, X
    TDC 
    TAX 
    RTS 
}

CopyActorState {
    PHX 
    LDA $0E
    STA $000E, Y
    LDA $10
    ORA #$2000
    AND #$F7FC
    STA $0010, Y
    LDA $12
    AND #$EFFF
    STA $0012, Y
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $28
    STA $0028, Y
    LDA $2A
    STA $002A, Y
    TXA 
    STA $0024, Y
    LDA $statsPtr, X
    PHA 
    LDA $metaspritePtr, X
    PHA 
    LDA $spritesetPtr, X
    PHA 
    LDA $7F0008, X
    TYX 
    STA $7F0008, X
    PLA 
    STA $spritesetPtr, X
    PLA 
    STA $metaspritePtr, X
    PLA 
    STA $statsPtr, X
    LDA #$0000
    STA $parentId, X
    STA $002C, X
    STA $002E, X
    STA $moveScratch1, X
    STA $moveScratch2, X
    STA $0008, X
    STA $chatPtr, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_00B279
    LDA #$0000
    STA $extendedFlags, X
    STA $onHitCallback, X
    STA $onDodgeCallback, X
    STA $onDeathCallback, X
    STA $onCollideCallback, X
    STA $scratch1010+6, X
    STA $free101C, X
    STA $chainDamage, X

  loc_00B279:
    PLX 
    RTS 
}

AllocateSpecialActor {
    PHD 
    LDA #$0000
    TCD 
    JSL $@actor_execution.ThinkerPoolAlloc
    BCS loc_00B29D
    LDX $005C
    TXA 
    STA $0004, Y
    LDA #$0000
    STA $0008, Y
    STA $0006, Y
    TYA 
    STA $0006, X
    STY $005C

  loc_00B29D:
    PLD 
    RTS 
}
---------------------------------------------

ActorPoolAllocator {
    LDA ($4E)
    BMI loc_00B514
    TAY 
    LDA #$0000
    STA ($4E)
    INC $4E
    INC $4E
    INC $activeActorCount
    CLC 
    RTL 

  loc_00B514:
    LDY #$1FC0
    SEC 
    RTL 
}

PaletteResetAndKillThinker {
    COP [PaletteRestart]
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}