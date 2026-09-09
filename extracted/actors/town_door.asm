?INCLUDE 'table_0EDA00'

---------------------------------------------

town_door [
  actor-def < #01, #00, #10, {

  code_00C5F6:
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &code_00C623 )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C60A:
    COP [BranchIfPlayerNear] ( #01, &code_00C610 )
    RTL 
} >
]

code_00C610 {
    COP [LoopInit] ( #08 )
    COP [BranchIfButton] ( #$0800, &code_00C61E )
    COP [SetEntryExitNow] ( @code_00C60A )
}

code_00C61E {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #0E )
}

code_00C623 {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}