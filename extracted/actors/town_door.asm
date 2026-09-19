; Interactive door actor using metasprite table.
; 
; Stands solid with frame #01 until the player approaches, then waits for A-button press to play sound #$0E, animate to open frame #00, and clear low collision. Used in multiple town scenes (South Cape, Freejia, and others via scene_actors). Standard reusable town door behavior.
---------------------------------------------

?INCLUDE 'table_0EDA00'

---------------------------------------------

town_door [
  actor-def < #01, #00, #10, {

  code_00C5F6:
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &TownDoorOpenIdle )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C60A:
    COP [BranchIfPlayerNear] ( #01, &TownDoorInteractLoop )
    RTL 
} >
]

TownDoorInteractLoop {
    COP [LoopInit] ( #08 ) ; Town door: 8-frame A-button hold loop before open sound and ClearLowHere
    COP [BranchIfButton] ( #$0800, &TownDoorOpenAnim )
    COP [SetEntryExitNow] ( @code_00C60A )
}

TownDoorOpenAnim {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #0E )
}

TownDoorOpenIdle {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}