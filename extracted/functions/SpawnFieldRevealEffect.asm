; Dungeon room-clear reveal cutscene effect.
; 
; Animates a rising sprite sequence, moves toward target coordinates from
; event_block_table via deathActionIdx, spawns flash and scatter particle
; children, waits, then calls StageBgChangeFromDeathIdx to swap the room
; background. Used after defeating enemies that unlock a field reveal
; (Pyramid mystic ball, Angkor wall walker, Incan Ruins wind trap).
; The visual centerpiece of the "room cleared" transformation.
---------------------------------------------

?INCLUDE 'event_block_table'
?INCLUDE 'spriteset_enemies'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!deathActionIdx                 7F0024

---------------------------------------------

SpawnFieldRevealEffect {
    COP [SetSpritePalette] ( #00 )
    LDA #$0342            ; Status: visible + field reveal flags
    STA $10
    LDA #$6000
    TRB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteMoveY] ( #29, #02 ) ; Rising animation: 3 sprite frames ascending
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #14 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #29, #02 ) ; Looping hover animation
    COP [AnimLoop]
    COP [SetSpritePriority] ( #30 )
    LDA $deathActionIdx, X ; Compute event_block_table offset: index * 8
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $&event_block_table+3, Y ; Read target X tile from event entry
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitAngle, X    ; Half-width for scatter particle range
    LDA $&event_block_table+5, Y ; Read X size, compute pixel target: (tile + size*2) * 8
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveXAlt, X      ; Target X pixel position
    LDA $&event_block_table+4, Y ; Read target Y tile
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitDiameter, X ; Half-height for scatter range
    LDA $&event_block_table+6, Y ; Read Y size, same formula
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveYAlt, X      ; Target Y pixel position
    COP [StageMove] ( #29, #04, #FF ) ; Move toward target at speed 4
    COP [TickMove]
    COP [SpawnAfterFlags] ( @field_reveal_flash, #$0302 ) ; Flash VFX at arrival
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #01 )
    LDA #$2000
    TSB $10
    COP [LoopStart] ( #0A ) ; Spawn 10 scatter particles
    COP [SpawnAfterFlags] ( @field_reveal_scatter, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $orbitAngle, X    ; Pass scatter range to child
    AND #$00FF
    STA $0020, Y
    LDA $orbitDiameter, X
    AND #$00FF
    STA $0022, Y
    COP [WaitByte] ( #03 )
    COP [LoopEnd]
    COP [StageBgChangeFromDeathIdx] ; Apply tile change from event table
    COP [ApplyBgChange]
    COP [Die]
}

---------------------------------------------
; Scatter particle: randomizes position using range from parent ($20=X range, $22=Y range).
; Range tiers: 0-1 = ±$0F, 2-3 = ±$1F, 4+ = ±$3F pixels. LSR+carry sets sign (50/50 ±).

field_reveal_scatter {
    COP [RngByte]         ; Random X offset
    LDY $20               ; X range tier from parent
    CPY #$0004
    BCS loc_00DECC        ; Tier 4+: wide ±$3F
    CPY #$0002
    BCS loc_00DED2        ; Tier 2-3: medium ±$1F
    LSR                   ; Tier 0-1: narrow ±$0F
    AND #$000F
    BRA loc_00DED6

  loc_00DECC:
    LSR 
    AND #$003F
    BRA loc_00DED6

  loc_00DED2:
    LSR 
    AND #$001F

  loc_00DED6:
    BCC loc_00DEDC        ; Carry from LSR: negate for ± spread
    EOR #$FFFF
    INC 

  loc_00DEDC:
    CLC 
    ADC $14               ; Apply X offset
    STA $14
    COP [RngByte]         ; Random Y offset (same tier logic)
    LDY $22
    CPY #$0003
    BCS loc_00DEF5
    CPY #$0002
    BEQ loc_00DEFB
    LSR 
    AND #$000F
    BRA loc_00DEFF

  loc_00DEF5:
    LSR 
    AND #$003F
    BRA loc_00DEFF

  loc_00DEFB:
    LSR 
    AND #$001F

  loc_00DEFF:
    BCC loc_00DF05
    EOR #$FFFF
    INC 

  loc_00DF05:
    CLC 
    ADC $16               ; Apply Y offset
    STA $16
}

---------------------------------------------
; Flash effect: plays reveal SFX and animates one flash sprite frame, then dies.

field_reveal_flash {
    COP [PlaySoundBoth] ( #$0606 ) ; Reveal chime SFX
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [Die]
}