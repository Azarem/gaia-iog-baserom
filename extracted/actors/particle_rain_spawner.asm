; Particle rain spawner — spawns falling particle children at a decelerating rate.
; 
; The spawner starts with a 120-frame ($78) delay between spawns and decrements each cycle
; down to a minimum of 4 frames, creating an accelerating rain effect. Each child particle
; gets a random X position (RNG×2 + $C4), starts at Y=$FFE0 (above screen), and falls with
; randomized velocity (X: 4–10, Y: 3–9). Particles die when Y ≥ $200.
; Used for the ending credits particle rain.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; Spawner loop: starts at 120-frame delay, decelerates to minimum 4

particle_rain_spawner [
  actor-def < #00, #00, #38, {

  ParticleRainSpawnerLoop:
    LDA #$0078            ; Initial spawn delay = 120 frames
    STA $24

  loc_0BD2B3:
    LDA $24               ; Decelerate: decrement delay until min 4
    CMP #$0004
    BEQ loc_0BD2BC
    DEC $24

  loc_0BD2BC:
    LDA $24               ; Wait $24 frames via SetEntryExit
    STA $08
    COP [SetEntryHereAndYield]
    COP [SpawnAfterFlags] ( @ParticleRainChild, #$1802 ) ; Spawn falling particle child
    BRA loc_0BD2B3
} >
]

---------------------------------------------
; Individual falling particle — random X position, constant downward velocity

ParticleRainChild {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #02 )
    COP [SetSpritePriority] ( #30 )
    LDA #$FFE0            ; Start above screen (Y = -32)
    STA $16
    COP [RngByte]         ; Random X: RNG×2 + $C4
    PHA 
    ASL 
    CLC 
    ADC #$00C4
    STA $14
    PLA                   ; Velocity index: (RNG AND 3) × 2 + 4
    AND #$0003
    ASL 
    CLC 
    ADC #$0004
    STA $moveXAlt, X      ; X velocity: 4, 6, 8, or 10
    DEC 
    STA $moveYAlt, X      ; Y velocity: 3, 5, 7, or 9

  loc_0BD2F7:
    COP [ReloadMoveDurations] ; Apply velocity
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA $16               ; Die when Y ≥ $200 (off bottom of screen)
    CMP #$0200
    BCC loc_0BD2F7
    COP [Die]
}