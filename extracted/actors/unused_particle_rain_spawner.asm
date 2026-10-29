; Particle rain spawner (Bank 0B, 774827-774918): a looping actor that spawns falling particle children at an increasing rate, plus the child (UnusedRainDropChild). It is NOT used: no spawn table, script or thinker references unused_particle_rain_spawner anywhere in extracted/. actor-def <#00,#00,#38>.
; 
; === SPAWNER ===
; 
; $24 starts at $78. Each cycle: if $24 is not 4, decrement it; store $24 in the wait counter $08; SetEntryHereAndYield; spawn a child. The wait counter resumes the actor after N + 1 ticks (see WaitByte), so the intervals are 120, 119, 118 ... 5 ticks and then 5 ticks forever. The spawn rate therefore RISES with time (the delay between spawns shrinks). The ramp takes 7,250 ticks (about 2 minutes) to reach the steady rate (computed from the code, not run).
; COP SpawnAfterFlags ( @UnusedRainDropChild, #$1802 ) writes $1802 into the child's flags word $10; CopyActorState copies the spawner's position, anim index and pointers.
; 
; === CHILD ===
; 
; SetMetasprite points the child at spriteset_pickups_effects and StageSprAndHitbox #02 shows animation list 2 (sprite_set_0EE0A6: 7 frames, hold 2 each, so one pass is 21 ticks). Priority operand $30 sets OAM priority bits $3000 (frontmost). Start: Y = $FFE0 (-32), X = RNG * 2 + $C4, i.e. $C4-$2C2 in steps of 2. The same random byte also picks the speed: index = (RNG AND 3) * 2 + 4.
; The values stored in moveXAlt / moveYAlt are MOVEMENT INDICES into move_chain_table, not velocities. Odd indices are +n, even indices are -n pixels per frame (index 3 = +2, 4 = -2, 5 = +3, 6 = -3 ...). The child therefore moves X by -2, -3, -4 or -5 and Y by +2, +3, +4 or +5 per frame (index X = 4/6/8/10 pairs with Y = 3/5/7/9, equal magnitudes): it falls DIAGONALLY down and to the left at 45 degrees, not straight down.
; ReloadMoveChains re-arms the two delta chains; AnimOnce zeroes $2C / $2E when its list ends, which is why the loop reloads them after every pass. The death test (Y >= $0200, unsigned) runs only when an animation pass has ended, i.e. every 21 ticks, not every frame. A particle whose Y were still negative at that moment would be read as a huge unsigned value and die; at 21 ticks the slowest particle (+2 per frame from -32) is at +10, so by the numbers all of them survive the first check (computed from the code, not run).
; 
; The particles start above the screen and FALL.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; Actor entry. Unreferenced. Loops forever spawning UnusedRainDropChild; the delay between spawns shrinks from 120 to 5 ticks.

unused_particle_rain_spawner [
  actor-def < #00, #00, #38, {

; Initial spawn delay: $24 := $78.

  UnusedRainSpawnerLoop:
    LDA #$0078            ; Initial delay: 120 ticks, kept in $24
    STA $24

; Cycle start: shorten the delay by one tick unless it is already 4.

  loc_0BD2B3:
    LDA $24
    CMP #$0004            ; Floor of 4: the wait is $24 + 1, so the steady rate is one child per 5 ticks
    BEQ loc_0BD2BC
    DEC $24               ; One tick shorter each cycle, so the spawn rate rises

; Wait $24 + 1 ticks (SetEntryHereAndYield with $08 armed), then spawn one child and loop.

  loc_0BD2BC:
    LDA $24               ; Wait $24 + 1 ticks: arm $08, then SetEntryHereAndYield
    STA $08
    COP [SetEntryHereAndYield]
    COP [SpawnAfterFlags] ( @UnusedRainDropChild, #$1802 ) ; Spawn a raindrop child with flags word $1802
    BRA loc_0BD2B3
} >
]

---------------------------------------------
; One raindrop: random X above the screen, random speed index; falls diagonally down-left and dies when Y reaches $0200 at the end of an animation pass.

UnusedRainDropChild {
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSprAndHitbox] ( #02 )
    COP [SetSpritePriority] ( #30 ) ; OAM priority 3 (operand $30 = bits $3000)
    LDA #$FFE0            ; Start 32 px above the screen: Y = $FFE0
    STA $16
    COP [RngByte]         ; Random byte: X = RNG * 2 + $C4 ($C4-$2C2, steps of 2); the same byte also picks the speed
    PHA 
    ASL 
    CLC 
    ADC #$00C4
    STA $14
    PLA 
    AND #$0003            ; Speed index = (RNG AND 3) * 2 + 4 = 4, 6, 8 or 10 into move_chain_table
    ASL 
    CLC 
    ADC #$0004
    STA $moveXAlt, X      ; X movement index (even = negative): -2, -3, -4 or -5 px per frame
    DEC 
    STA $moveYAlt, X      ; Y index = X index - 1 (odd = positive): +2, +3, +4 or +5 px per frame; equal magnitudes make the fall diagonal

; Per-pass loop: re-arm the movement chains, play the animation list once, then test Y.

  loc_0BD2F7:
    COP [ReloadMoveChains] ; Re-arm both delta chains (AnimOnce zeroes $2C / $2E at the end of each pass)
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA $16
    CMP #$0200            ; Unsigned compare: the death test runs only after each animation pass (every 21 ticks)
    BCC loc_0BD2F7
    COP [Die]
}