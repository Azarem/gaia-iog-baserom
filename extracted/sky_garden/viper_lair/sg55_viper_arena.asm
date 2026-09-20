; Viper boss arena setup and boundary management.
; 
; Configures the arena boundaries, falling tile triggers,
; and environmental hazards for the Viper boss fight.
; Manages the floor tiles that crumble during the battle
; and the arena edge collision walls.
---------------------------------------------

?INCLUDE 'gs2B_wreck_wave_motion'
?INCLUDE 'visual_effect_pipeline'

!bg1ScrollH                     068A
!bg2ScrollH                     068E
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!moveScratch2                   7F002E

---------------------------------------------

sg55_viper_arena {
    COP [SpawnBeforeFlags] ( @visual_effect_pipeline.effect_subpixel_math, #$2800 )
    LDA #$0201
    STA $0014, Y
    LDA #$0000
    STA $0016, Y
    LDA $24
    STA $orbitAngle, X
    COP [WaitByte] ( #02 )
    COP [InitGravity] ( #00, #09, #00 )
    COP [SetEntryHereAndYield]
    COP [TickGravity]
    LDA $moveScratch2, X
    LDY $04
    STA $0016, Y
    CMP #$000C
    BCS code_0AD034
    RTL 
}

code_0AD034 {
    COP [SpawnAfterFlags] ( @gs2B_wreck_wave_motion.code_05F859, #$2B00 )
    COP [LoopStart] ( #04 )
    COP [RngByte]
    COP [SpawnAfterFlags] ( @code_0AD07A, #$0B01 )
    LDA $0410
    AND #$0033
    STA $08
    COP [LoopEnd]
    COP [SpawnAfterFlags] ( @code_0AD060, #$0B02 )
    COP [RngByte]
    AND #$0070
    STA $08
    RTL 
}

code_0AD060 {
    JSR $&code_0AD0A5
    INC 
    INC 
    ASL 
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #30 )

  loc_0AD06D:
    COP [ReloadMoveDurations]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0AD06D
    COP [Die]
}

code_0AD07A {
    JSR $&code_0AD0A5
    ASL 
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #20 )
    LDA $0036
    LSR 
    BCS loc_0AD098

  loc_0AD08B:
    COP [ReloadMoveDurations]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0AD08B
    COP [Die]

  loc_0AD098:
    COP [ReloadMoveDurations]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0AD098
    COP [Die]
}

code_0AD0A5 {
    LDA #$0000
    STA $moveXAlt, X
    LDA $bg2ScrollH
    CLC 
    ADC #$00FF
    STA $16
    LDA $bg1ScrollH
    CLC 
    ADC #$0080
    STA $14
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $14
    STA $14
    LDA $0410
    AND #$0003
    BNE loc_0AD0D4
    LDA #$0003

  loc_0AD0D4:
    RTS 
}