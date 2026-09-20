; Interactive door actor using metasprite table.
; 
; Stands solid with frame #01 until the player approaches, then waits for A-button press to play sound #$0E, animate to open frame #00, and clear low collision. Used in multiple town scenes (South Cape, Freejia, and others via scene_actors). Standard reusable town door behavior.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

town_door [
  actor-def < #01, #00, #10, {

; Door initialization: set closed sprite (frame #01), mark solid, then check if player is already nearby (skip to open idle if so). Falls through to WaitWhileOffscreen → TownDoorProximityCheck loop.

  TownDoorInit:
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #01 ) ; Closed door frame
    COP [AnimOnce]
    COP [MarkSolidHere]   ; Mark high collision tile at door position
    COP [BranchIfPlayerNear] ( #01, &TownDoorOpenIdle ) ; Already nearby → skip to open
    COP [WaitWhileOffscreen] ( #0A ) ; Wait until onscreen before proximity polling

; Per-frame proximity check: branches to interact loop when player is within range, otherwise returns to wait for next frame.

  TownDoorProximityCheck:
    COP [BranchIfPlayerNear] ( #01, &TownDoorInteractLoop )
    RTL 
} >
]

---------------------------------------------
; 8-frame A-button hold loop. If the button is pressed, branches to open animation. If the player walks away (loop expires), returns to proximity check.

TownDoorInteractLoop {
    COP [LoopStart] ( #08 ) ; 8 frames to hold A before door opens
    COP [BranchIfPressed] ( #$0800, &TownDoorOpenAnim ) ; A button → open
    COP [JumpNextFrame] ( @TownDoorProximityCheck ) ; Not pressed → back to proximity poll
}

---------------------------------------------
; Play door open sound then fall through to TownDoorOpenIdle.

TownDoorOpenAnim {
    COP [LoopEnd]
    COP [PlaySoundCh2] ( #0E ) ; Door open SFX
}

---------------------------------------------
; Clear collision tile and display open door frame. Stays in idle loop forever (door cannot close once opened).

TownDoorOpenIdle {
    COP [ClearSolidHere]  ; Remove solid collision at door position
    COP [StageSpriteFrame] ( #00 ) ; Open door frame
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}