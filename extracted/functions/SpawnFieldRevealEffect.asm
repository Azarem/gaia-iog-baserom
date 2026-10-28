; Room-reveal effect (Bank 00, 56818-57107): after the enemy that guards a hidden room part is defeated, a glowing sprite rises from the corpse, flies to the centre of the revealed region, flashes, scatters ten sparkles and swaps the background tiles (StageBgChangeFromDeathIdx + ApplyBgChange). Three actor bodies live in this file: SpawnFieldRevealEffect, field_reveal_scatter (which falls through into field_reveal_flash) and field_reveal_flash.
; 
; === SPAWN ===
; 
; SpawnListAppend ( SpawnFieldRevealEffect, #00, #00, #$0342 ) in StandardEnemyDefeatHandler (56375), EnemyDefeatDispatch_CountKill (697548), pyCC_mystic_ball (771970) and awB1_wall_walker (770414). The spawner copies its deathActionIdx ($7F0024, the event-block index of its scene record) into the child; EnemyDefeatDispatch_CountKill guards the spawn with event flag $0100 + index so each reveal fires once.
; 
; === TARGET ===
; 
; event_block_table is indexed by deathActionIdx x 8. The bytes used are +3 width, +4 height, +5 dstX and +6 dstY (event-block-def, tile units). The flight target is the centre of the destination rectangle in pixels: moveXAlt = (2 x dstX + width) x 8, moveYAlt = (2 x dstY + height) x 8. orbitAngle := width / 2 and orbitDiameter := height / 2 are passed to the scatter particles as their range tier.
; 
; === SEQUENCE ===
; 
; Flags $0342, palette 0, anim $29: three rising passes (Y chains $02, $12, $14), a two-pass hover loop, sprite priority $30, then StageMove to the target at 4 px per frame (TickMove). On arrival: a field_reveal_flash child, a 2-tick wait (WaitByte #01), $10 |= $2000, then ten field_reveal_scatter children (one every 5 ticks: WaitByte #03 is 4 ticks and LoopEnd yields once more; each gets the half-width and half-height), then StageBgChangeFromDeathIdx (SFX $0F on both channels, stages the swap), ApplyBgChange and Die. Each child gets $12 |= $1000 (the display / overlay-active qualifier, which CopyActorState clears).
; 
; The old header named an 'Incan Ruins wind trap' as a user (the four callers above are the real ones) and called +3 / +5 the 'target X tile' and 'X size'; they are the width and dstX.
---------------------------------------------

?INCLUDE 'event_block_table'
?INCLUDE 'spriteset_pickups_effects'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!deathActionIdx                 7F0024

---------------------------------------------

; Main actor of the reveal: rise, fly to the centre of the event-block rectangle, flash, ten scatter sparkles, background swap, Die. See the block note.

SpawnFieldRevealEffect {
    COP [SetSpritePalette] ( #00 )
    LDA #$0342            ; $10 := $0342 (the word the spawner passes)
    STA $10
    LDA #$6000
    TRB $12               ; Clear the ForceDir bits ($6000 of $12)
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteMoveY] ( #29, #02 ) ; Rise: anim $29 with Y chain $02, then $12, then $14 (three passes)
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #14 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #29, #02 ) ; Hover: anim $29 repeated for 2 passes
    COP [AnimLoop]
    COP [SetSpritePriority] ( #30 )
    LDA $deathActionIdx, X ; Compute event_block_table offset: index * 8
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $&event_block_table+3, Y ; +3 = width (tiles)
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitAngle, X    ; orbitAngle := width / 2 (handed to the sparkles as $20)
    LDA $&event_block_table+5, Y ; +5 = dstX; target X = (2 x dstX + width) x 8 = centre of the region
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveXAlt, X      ; moveXAlt := centre X in pixels
    LDA $&event_block_table+4, Y ; +4 = height (tiles)
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitDiameter, X ; orbitDiameter := height / 2 (handed to the sparkles as $22)
    LDA $&event_block_table+6, Y ; +6 = dstY; target Y = (2 x dstY + height) x 8
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveYAlt, X      ; moveYAlt := centre Y in pixels
    COP [StageMove] ( #29, #04, #FF ) ; Fly to moveXAlt / moveYAlt at 4 px per frame (third operand $FF = no tick cap)
    COP [TickMove]
    COP [SpawnAfterFlags] ( @field_reveal_flash, #$0302 ) ; Flash child at the arrival point (flags $0302)
    LDA $0012, Y          ; Child $12 |= $1000: it also runs in the display-filtered modes (the spawn clears it)
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #01 ) ; WaitByte #01 = 2 ticks
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
    COP [WaitByte] ( #03 ) ; WaitByte #03 = 4 ticks, and LoopEnd yields once more: one scatter child every 5 ticks
    COP [LoopEnd]
    COP [StageBgChangeFromDeathIdx] ; Stage the background swap for event block deathActionIdx (SFX $0F on both channels)
    COP [ApplyBgChange]   ; Run the swap: render frames and queue the tiles to VRAM
    COP [Die]
}

---------------------------------------------
; Scatter sparkle (child of SpawnFieldRevealEffect): offsets its own position by a random amount per axis. $20 = half-width and $22 = half-height in tiles. X magnitude: $20 >= 4 gives 0-63 px, 2-3 gives 0-31, 0-1 gives 0-15. Y: $22 >= 3 gives 0-63, 2 gives 0-31, 0-1 gives 0-15 (the Y thresholds differ from the X ones). The random byte is shifted right once and the carry is the sign (set = negative).
; There is no Die at the end: the code runs on into field_reveal_flash, so every sparkle also plays SFX $06 on both channels, shows frame $25 and then dies.

field_reveal_scatter {
    COP [RngByte]         ; Random X offset
    LDY $20               ; $20 = half-width in tiles (range tier)
    CPY #$0004
    BCS FieldRevealScatterXTier2 ; Tier 4+: wide ±$3F
    CPY #$0002
    BCS FieldRevealScatterXTier0 ; Tier 2-3: medium ±$1F
    LSR                   ; Tier 0-1: narrow ±$0F
    AND #$000F
    BRA FieldRevealScatterXSet

; X range tier 4 or more: magnitude 0-63 px.

  FieldRevealScatterXTier2:
    LSR 
    AND #$003F
    BRA FieldRevealScatterXSet

; X range tier 2-3: magnitude 0-31 px.

  FieldRevealScatterXTier0:
    LSR 
    AND #$001F

; Apply the sign (carry from the LSR: set = negative) and add to X.

  FieldRevealScatterXSet:
    BCC FieldRevealScatterYStart ; Carry from LSR: negate for ± spread
    EOR #$FFFF
    INC 

; Random Y offset: tiers from $22 (>= 3, 2, below).

  FieldRevealScatterYStart:
    CLC 
    ADC $14               ; Apply X offset
    STA $14
    COP [RngByte]         ; Random Y offset (same tier logic)
    LDY $22               ; $22 = half-height in tiles (range tier)
    CPY #$0003            ; Y thresholds differ from X: 3 or more wide, 2 medium
    BCS FieldRevealScatterYTier2
    CPY #$0002
    BEQ FieldRevealScatterYTier0
    LSR 
    AND #$000F
    BRA FieldRevealScatterYSet

; Y range tier 3 or more: magnitude 0-63 px.

  FieldRevealScatterYTier2:
    LSR 
    AND #$003F
    BRA FieldRevealScatterYSet

; Y range tier 2: magnitude 0-31 px.

  FieldRevealScatterYTier0:
    LSR 
    AND #$001F

; Apply the sign (carry from the LSR) to the Y offset.

  FieldRevealScatterYSet:
    BCC FieldRevealScatterDone
    EOR #$FFFF
    INC 

; Add the Y offset; the sparkle continues into field_reveal_flash.

  FieldRevealScatterDone:
    CLC 
    ADC $16               ; Apply Y offset
    STA $16
}

---------------------------------------------
; Flash: SFX $06 on both channels, frame $25 once, Die. Spawned once at the arrival point by SpawnFieldRevealEffect and also the tail of every scatter sparkle.

field_reveal_flash {
    COP [PlaySoundBoth] ( #$0606 ) ; SFX $06 on both channels
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [Die]
}