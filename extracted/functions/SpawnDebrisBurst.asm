; Breakable-wall debris effect that loops 8 times, spawning child actors with random ±16 pixel offsets, debris sprite frame #01, and crumbling sound #$0F.
; 
; Each child animates once and dies. Spawned when breakable walls are destroyed (Diamond Mine passage, Great Wall switch room). Standard destructible-wall particle burst.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

SpawnDebrisBurst {
    COP [LoopStart] ( #08 ) ; SpawnDebrisBurst entry — particle burst actor at range boundary
    COP [WaitByte] ( #03 )
    COP [SpawnAfterFlags] ( @DebrisBurstParticle, #$0302 )
    COP [LoopEnd]
    COP [Die]
}

DebrisBurstParticle {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    COP [SetSpritePriority] ( #30 )
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0010
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0010
    CLC 
    ADC $16
    STA $16
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}