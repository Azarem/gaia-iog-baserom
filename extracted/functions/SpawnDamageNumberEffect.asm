; Floating damage-number actor (Bank 00, 56500-56579). One spawn is one 16-frame effect: it draws the damage value as digit sprites above the victim and lets them rise one pixel per frame while following the victim's own movement. The old name (SpawnAttackTrailEffect, 'attack trail') and the old text ('ghost copies interpolated between the previous and current position', '16 frames at position then 16 drifting upward', 'when the player or enemies take damage') do not describe it: there is one 16-iteration loop and no ghost copies.
; 
; === SPAWN ===
; 
; Two sites in combat_collision: COP SpawnListAppend ( @SpawnDamageNumberEffect, #00, #00, flags ) in PlayerAttackHitTest with flags $2F00, and in ApplyHitDamageToVictim_DamagePath with flags $2B00 (that path then ORs $1000 into the child's $12). The fourth operand is the flags word stored into the child's $10, not a priority. Both sites run with the victim as the current actor, so CopyActorState gives the child the victim's X and Y and stores the victim's slot in the child's $24. The caller then writes the packed BCD damage from FormatDamageDigits into the child's $28.
; No child is spawned when the victim's $12 bit $0020 (boss) is set or when the damage is 1000 or more (FormatDamageDigits returns carry). No other spawn site exists in extracted/.
; 
; === BODY ===
; 
; 1. $0E := $3200: the attribute word ORed into every digit tile (OAM high byte $32 = priority 3, palette 1).
; 2. $16 -= $10: start 16 pixels above the victim.
; 3. Y := $24 (the victim); remember its X and Y in $20 and $22.
; 4. 16 iterations (LoopStart #10 = 16): add the victim's X movement since last frame to $14, add its Y movement minus 1 to $16 (so the digits rise one pixel per frame), refresh $20/$22, copy $28 to the absolute scratch word $0000 and call ComposeDigitSprites. ComposeDigitSprites puts the first digit at $14 - 12 and appends one 6-byte entry per digit to the compose buffer at $7F3100. LoopEnd yields every iteration, so the digits are re-emitted every frame; then Die.
; 
; The scratch word is written with the absolute address $0000 on purpose: it is not the actor's own $00/$01 re-entry address.
; 
; === HAZARD ===
; 
; The loop re-reads the victim's position through $24 every frame and never checks that the slot still holds the same actor. If the victim died and its slot were reused within the 16 frames, the number would follow whatever occupies the slot (analysis only, not run; OQ-I041-5).
; 
; DamageNumberShort_unused is an unreferenced variant of this routine.
---------------------------------------------

?INCLUDE 'oam_digit_compose'

---------------------------------------------

; Entry of the child actor created by SpawnListAppend. $24 = victim slot, $28 = packed BCD damage (written by the caller after the spawn), $14/$16 = victim position at spawn.

SpawnDamageNumberEffect {
    LDA #$3200            ; Digit attribute word (OAM high byte $32 = priority 3, palette 1); ComposeDigitSprites reads it from $0E
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF0            ; Start 16 pixels above the victim
    STA $16
    LDY $24               ; Y := victim slot ($24, set by CopyActorState); remember its X and Y in $20 / $22 (previous position)
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    COP [LoopStart] ( #10 ) ; 16 frames
    LDY $24
    LDA $0014, Y          ; Add the victim's X movement since last frame to our X: follow it horizontally
    SEC 
    SBC $20
    CLC 
    ADC $14
    STA $14
    LDA $0016, Y          ; Add the victim's Y movement, minus 1: the digits rise one pixel per frame
    SEC 
    SBC $22
    CLC 
    ADC $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $0014, Y          ; Previous X / Y for the next frame
    STA $20
    LDA $0016, Y
    STA $22
    LDA $28               ; Packed BCD damage into absolute $0000, the scratch word ComposeDigitSprites reads (not the actor's $00 re-entry address)
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites ; Append this frame's digit sprites to the compose buffer at $7F3100
    COP [LoopEnd]         ; Yield one frame; repeat until 16 frames are done
    COP [Die]
}