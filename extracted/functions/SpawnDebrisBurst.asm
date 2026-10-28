; Breakable-wall debris effect: a one-shot actor that spawns 8 child particle actors and dies. Each pass waits WaitByte(3) (the runner skips 3 passes, so 4 frames) and spawns DebrisBurstParticle with COP SpawnAfterFlags, initial $10 flags $0302; LoopEnd yields once more per pass, so one particle appears every 5 frames and the burst lasts about 40 frames (static reading, UNVERIFIED-RUNTIME).
; 
; DebrisBurstParticle: spriteset_pickups_effects metasprite, palette 0, priority #30. CopyActorState gives it the burst actor's position; $14 / $16 then get two independent RNG offsets of -16 .. +15 px (RngByte AND $1F, minus $10). It plays sound #$0F on both channels (PlaySoundBoth #$0F0F, so all eight particles play the crumble sound), stages sprite frame #01, runs AnimOnce and dies. Flags $0302: bit $0200 is part of the combat_collision skip masks (OQ-I030-2); $0100 and $0002 are undecoded.
; 
; Spawn sites (4): dm3D_breakable_wall (Diamond Mine, flags $2000), gw83_switch (Great Wall, $2000), it19_breakable_wall (Itory cave, SpawnAfterAbsFlags at (152, 96), $2000) and dm40_trapped_slave (Diamond Mine, $3000). The older header named only the first two. docs/code/bank00/functions-camera-motion.md describes the routine as an LDX #8 / JSR random / DEX loop with offsets of +-$10 .. +-$30 pixels; the code is a COP LoopStart / LoopEnd script and the offsets are -16 .. +15 px.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

---------------------------------------------

; Burst actor: LoopStart #08, then per pass WaitByte #03, SpawnAfterFlags DebrisBurstParticle with $10 = $0302, LoopEnd (yields while the counter is nonzero); after the eighth pass it dies. One particle every 5 frames (4 wait + 1 LoopEnd yield).

SpawnDebrisBurst {
    COP [LoopStart] ( #08 ) ; Eight passes, one particle per pass
    COP [WaitByte] ( #03 ) ; WaitByte(3): the runner skips 3 passes, so 4 frames before each spawn (LoopEnd adds one yield: one particle per 5 frames)
    COP [SpawnAfterFlags] ( @DebrisBurstParticle, #$0302 ) ; Spawn DebrisBurstParticle after this actor with $10 = $0302 (CopyActorState gives it this actor's position)
    COP [LoopEnd]         ; LoopEnd: counter - 1; nonzero yields and resumes at the WaitByte, zero continues
    COP [Die]             ; All eight spawned: this actor ends (the particles live on)
}

---------------------------------------------
; One debris particle: spriteset_pickups_effects metasprite, palette 0, priority #30; X and Y each move by an independent random -16 .. +15 px from the inherited burst position; plays sound #$0F on both channels, shows frame #01 once (AnimOnce) and dies.

DebrisBurstParticle {
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Particle metasprite: spriteset_pickups_effects (the frame is staged below)
    COP [SetSpritePalette] ( #00 )
    COP [SetSpritePriority] ( #30 )
    COP [RngByte]         ; RngByte: A = random byte
    AND #$001F            ; 0..31
    SEC 
    SBC #$0010            ; Offset -16 .. +15 px
    CLC 
    ADC $14               ; Add to posX ($14): X scatter around the burst actor
    STA $14
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0010
    CLC 
    ADC $16               ; Add to posY ($16): Y scatter (independent RngByte)
    STA $16
    COP [PlaySoundBoth] ( #$0F0F ) ; PlaySoundBoth #$0F0F: sound #$0F on both channels (each of the 8 particles plays it)
    COP [StageSpriteFrame] ( #01 ) ; Debris sprite frame #01
    COP [AnimOnce]        ; Play the frame animation once
    COP [Die]
}