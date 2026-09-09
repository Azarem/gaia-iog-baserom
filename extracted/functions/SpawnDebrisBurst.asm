?INCLUDE 'table_0EE000'

---------------------------------------------

SpawnDebrisBurst {
    COP [LoopInit] ( #08 )
    COP [WaitByte] ( #03 )
    COP [SpawnAfterFlags] ( @code_00C9C9, #$0302 )
    COP [LoopNext]
    COP [Die]
}

code_00C9C9 {
    COP [SetMetasprite] ( @table_0EE000 )
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