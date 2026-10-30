; Angkor Wat outer north (scene $B3): one-shot trigger that changes the map and then makes the player jump (LedgeJumpEntry).
; 
; Spawned once, by scene_B3_actors. The actor dies at once when flag word $016E is set. Otherwise it waits (SetEntryHere) until the player stands in the tile box (6A, 0C)-(6F, 0D), then: ORs $CFFC into joypadMaskStd 20 times (LoopStart #14), plays the sound pair #$0F0F, applies BG change #6E (StageBgChange / ApplyBgChange), sets flag word $016E, writes player_character.LedgeJumpEntry into the player actor (address at +$00, bank byte at +$02, $08 and $2A zeroed), sets playerFlags $0800 and dies.
; 
; The jump starts because this script writes LedgeJumpEntry, not because of a type $08 cell. BG change #6E was not decoded. Mesen2 (scene $B3, player poked into the tile box): within 10 frames the player's entry word became LedgeJumpEntry (animation $18, playerFlags $0800) and the fall ended at x 1400, y 112 after starting from x 1736, y 204 (not traced further); a before / after diff of the collision map and the layer-0 tilemap showed no changed cell, so what the BG change draws is unknown. The earlier names and notes (awB3_vine_reveal, 'grows vines', 'draw the vine tiles', 'ladder trigger') were guesses.
---------------------------------------------

?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

awB3_ledge_jump_trigger [
  actor-def < #00, #00, #30, {

  code_0898DD:
    COP [BranchOnFlagWord] ( #$016E, #01, &code_089928 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #6A, #0C, #6F, #0D, &code_0898EF )
    RTL 
} >
]

code_0898EF {
    COP [LoopStart] ( #14 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [LoopEnd]
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #6E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$016E )
    LDY $playerActor
    SEP #$20
    LDA #$^player_character.LedgeJumpEntry
    STA $0002, Y
    REP #$20
    LDA #$&player_character.LedgeJumpEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $playerFlags
}

code_089928 {
    COP [Die]
}