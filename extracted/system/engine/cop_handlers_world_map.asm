?BANK 00

---------------------------------------------

; COP #65 world-map relocation stager taking two word and two byte operands: destination pixel X, pixel Y, destination scene/area ID, and companion byte. Writes WRAM staging fields consumed by the world-map transition system. Does not warp immediately. Used by party-member NPC scripts across Dao, Itory, Watermia, and Freejia.

StageWorldMapMove {
    TYX 
    LDA [$0A]             ; Read destination X pixel position (word)
    INC $0A
    INC $0A
    STA $0D52             ; Store to world-map staging $0D52 (destination X)
    LDA [$0A]             ; Read destination Y pixel position (word)
    INC $0A
    INC $0A
    STA $0D56             ; Store to $0D56 (destination Y)
    LDA [$0A]             ; Read scene/area ID byte
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E (area identifier)
    LDA [$0A]             ; Read companion byte
    INC $0A
    AND #$00FF
    STA $0D5A             ; Store to $0D5A (companion/party member index)
    STZ $0D58             ; Clear $0D58 (choice ID = none for direct relocation)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #66 with two word operands (destination X, Y) plus one byte (choice ID). Writes staging fields $0D52, $0D56, and $0D58 for the world-map transition system without warping immediately.

StageWorldMapChoice {
    TYX 
    LDA [$0A]             ; Read destination X (word)
    INC $0A
    INC $0A
    STA $0D52             ; Store to world-map staging $0D52
    LDA [$0A]             ; Read destination Y (word)
    INC $0A
    INC $0A
    STA $0D56             ; Store to $0D56
    LDA [$0A]             ; Read choice ID byte
    INC $0A
    AND #$00FF
    STA $0D58             ; Store to $0D58 (world-map choice selection)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #67 with two byte operands (scene/area ID, companion byte). Writes $0D5E and $0D5A for world-map relocation staging consumed by the transition system.

StageWorldMapMoveIds {
    TYX 
    LDA [$0A]             ; Read scene/area ID byte
    INC $0A
    AND #$00FF
    STA $0D5E             ; Store to $0D5E
    LDA [$0A]             ; Read companion byte
    INC $0A
    AND #$00FF
    STA $0D5A             ; Store to $0D5A
    LDA $0A
    STA $02, S
    RTI 
}