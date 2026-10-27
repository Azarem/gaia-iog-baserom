; World-map staging COP handlers (40274–40380, Bank 00).
; 
; Three COP commands that fill the world-map state block (see WorldMapController: $0D52–$0D6F) and return; they never change scene themselves. Storing a nonzero X in worldMapStagedX ($0D52) arms the world-map transition: CheckSceneTransition then sends the game to scene $FE and ExecuteSceneTransition moves $0D52 to worldMapPlayerX ($0D54).
; 
; - StageWorldMapMove (COP #65): player start X/Y and a route ID to play automatically (13 NPC departure scripts in towns).
; - StageWorldMapChoice (COP #66): player start X/Y and a selection ID for the route-choice dispatch (overworld_exit, 27 sites).
; - StageWorldMapMoveIds (COP #67): route ID only, used by the world_map_options route handlers (24 sites).
; 
; All handlers return by writing the next script address into the COP stack frame ($02,S) and RTI.
---------------------------------------------

?BANK 00

!worldMapStagedX                0D52
!worldMapPlayerY                0D56
!worldMapChoiceId               0D58
!worldMapRouteId                0D5A

---------------------------------------------

; COP #65 with two word and two byte operands: world-map start X, start Y (pixels), a byte stored to $0D5E (0 in every shipped script; no reader found), and a route ID stored to worldMapRouteId ($0D5A, index into world_map_routes). Clears worldMapChoiceId so the route plays directly instead of opening a selection. Does not warp immediately. Used by NPC scripts in Dao, Itory, Watermia, Freejia, Edward Castle, Euro, Nazca, Native Village, South Cape and Angel Village.

StageWorldMapMove {
    TYX 
    LDA [$0A]             ; Read start X pixel position (word)
    INC $0A
    INC $0A
    STA $worldMapStagedX  ; Staged start X (nonzero arms the world-map transition)
    LDA [$0A]             ; Read start Y pixel position (word)
    INC $0A
    INC $0A
    STA $worldMapPlayerY  ; Start Y
    LDA [$0A]             ; Read first byte operand (always 0 in shipped scripts)
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E (no reader found)
    LDA [$0A]             ; Read route ID byte
    INC $0A
    AND #$00FF
    STA $worldMapRouteId  ; Route ID → worldMapRouteId (index into world_map_routes)
    STZ $worldMapChoiceId ; Clear the choice ID: no selection, play the route directly
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #66 with two word operands (start X, Y in pixels) plus one byte (selection ID, 1–$1B in overworld_exit). Writes worldMapStagedX ($0D52), worldMapPlayerY ($0D56) and worldMapChoiceId ($0D58); WorldMapController dispatches a nonzero choice ID through world_map_options. Does not warp immediately.

StageWorldMapChoice {
    TYX 
    LDA [$0A]             ; Read destination X (word)
    INC $0A
    INC $0A
    STA $worldMapStagedX  ; Store to world-map staging $0D52
    LDA [$0A]             ; Read destination Y (word)
    INC $0A
    INC $0A
    STA $worldMapPlayerY  ; Store to $0D56
    LDA [$0A]             ; Read choice ID byte
    INC $0A
    AND #$00FF
    STA $worldMapChoiceId ; Store to $0D58 (world-map choice selection)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #67 with two byte operands: a byte stored to $0D5E (always 0 in shipped scripts; no reader found) and a route ID stored to worldMapRouteId ($0D5A). Used by the world_map_options handlers after the player picks a destination.

StageWorldMapMoveIds {
    TYX 
    LDA [$0A]             ; Read scene/area ID byte
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E
    LDA [$0A]             ; Read route ID byte
    INC $0A
    AND #$00FF
    STA $worldMapRouteId  ; Store to $0D5A
    LDA $0A
    STA $02, S
    RTI 
}