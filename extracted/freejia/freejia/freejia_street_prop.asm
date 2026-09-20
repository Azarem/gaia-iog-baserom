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
    COP [MarkSolidHere]
    COP [BranchIfPlayerNear] ( #01, &FreejiaPropHiddenState )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C644:
    COP [BranchIfPlayerNear] ( #01, &FreejiaPropInteractLoop )
    RTL 
} >
]

FreejiaPropInteractLoop {
    COP [LoopStart] ( #08 )
    COP [BranchIfPressed] ( #$0800, &FreejiaPropToggleAnim )
    COP [JumpNextFrame] ( @code_00C644 )
}

FreejiaPropToggleAnim {
    COP [LoopEnd]
    COP [PlaySoundCh2] ( #01 )
}

FreejiaPropHiddenState {
    COP [ClearSolidHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}