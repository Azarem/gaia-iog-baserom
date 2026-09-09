?INCLUDE 'table_0EDA00'

---------------------------------------------

freejia_street_prop [
  actor-def < #07, #00, #10, {

  code_00C630:
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &code_00C65D )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C644:
    COP [BranchIfPlayerNear] ( #01, &code_00C64A )
    RTL 
} >
]

code_00C64A {
    COP [LoopInit] ( #08 )
    COP [BranchIfButton] ( #$0800, &code_00C658 )
    COP [SetEntryExitNow] ( @code_00C644 )
}

code_00C658 {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #01 )
}

code_00C65D {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}