; Decorative street props in Freejia — animated scenery objects.
; 
; Multi-instance prop actor (44 lines). Spawns visual elements
; like market stalls or decorations. No dialog or interaction.
; Pure scene dressing for the Freejia town map.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

freejia_street_prop [
  actor-def < #07, #00, #10, {

  code_00C630:
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &FreejiaPropHiddenState )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C644:
    COP [BranchIfPlayerNear] ( #01, &FreejiaPropInteractLoop )
    RTL 
} >
]

FreejiaPropInteractLoop {
    COP [LoopInit] ( #08 )
    COP [BranchIfButton] ( #$0800, &FreejiaPropToggleAnim )
    COP [SetEntryExitNow] ( @code_00C644 )
}

FreejiaPropToggleAnim {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #01 )
}

FreejiaPropHiddenState {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}