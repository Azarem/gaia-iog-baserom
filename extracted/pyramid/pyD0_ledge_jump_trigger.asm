; Pyramid scenes $D0 (Meltdown A) and $D1 (Meltdown B), one placement each: a one-shot trigger that starts a ledge jump (LedgeJumpEntry). The old name and note (breakable wall, hit points, debris, 'used extensively in the maze-like corridors') do not match the code: there is no HP counter, no hit test, no spawn, and only these two scenes place it.
; 
; The actor's $0E word (copied to $26) picks the variant: 0 uses flag word $0170 and BG change #70, anything else flag word $0171 and BG change #71. The actor dies at once when its flag word is set.
; 
; Gate (every pass): the player's body spriteset bank byte ($7F0008 + player slot) must be $95 (Will) or $8E (Freedan) and the player's animation index ($28) must be $1C, which LedgeJumpLand stages on a ledge-jump landing (the pose $1C is also staged by other player code); then BranchIfPlayerNear #01 decides whether the gate opens.
; 
; First pass ($24 = 0): sets $24 = 1, converts the actor's $14 / $16 to tile coordinates (the pixel values are saved in orbitAngle / orbitDiameter and restored), and draws metatiles #E8 and #E9 side by side with DrawMetatileHere at (tile X, tile Y - 1) and (tile X + 1, tile Y - 1). Measured in Mesen2 in scene $D0: the two cells (38, 20) and (39, 20), just north of the actor at tile (38, 21), change from collision type $00 to $0E (solid).
; 
; Second pass ($24 is 1, entered after the player has left the near zone and lands again): plays sound #15, applies BG change #70 / #71 (55 tilemap words changed in scene $D0), sets the flag word, clears actor flag $0008 and sets $0200 in the player's $10, writes player_character.LedgeJumpEntry into the player actor (address +$00, bank byte +$02, $08 and $2A zeroed) and dies. In Mesen2 the player's entry word became LedgeJumpEntry (animation $18, actor flags $8700) and the player fell; a narrow brick strip appeared in the dark pit south of the player.
; 
; Only the forced sequence was tested (the animation index was poked to $1C next to the actor): how the player reaches the gate in normal play, and what the two metatiles are meant to look like, was not watched. The jump starts because this script writes LedgeJumpEntry, with no type $08 cell involved (same as awB3_ledge_jump_trigger).
---------------------------------------------

?INCLUDE 'player_character'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

pyD0_ledge_jump_trigger [
  actor-def < #00, #00, #30, {

  code_08B595:
    LDA #$0000
    STA $24
    LDA $0E
    STA $26
    BEQ loc_08B5A9
    COP [BranchOnFlagWord] ( #$0171, #01, &code_08B666 )
    BRA loc_08B5B0

  loc_08B5A9:
    COP [BranchOnFlagWord] ( #$0170, #01, &code_08B666 )

  loc_08B5B0:
    COP [SetEntryHere]
    PHX 
    LDX $playerActor
    LDA $7F0008, X
    AND #$00FF
    CMP #$0095
    BEQ loc_08B5C7
    CMP #$008E
    BNE loc_08B5CF

  loc_08B5C7:
    LDA $0028, X
    CMP #$001C
    BEQ loc_08B5D1

  loc_08B5CF:
    PLX 
    RTL 

  loc_08B5D1:
    PLX 
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #01, &code_08B5DA )
    RTL 
} >
]

code_08B5DA {
    LDA $24
    BNE loc_08B617
    INC $24
    LDA $14
    STA $orbitAngle, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $14
    LDA $16
    STA $orbitDiameter, X
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    STA $16
    COP [DrawMetatileHere] ( #E8 )
    INC $14
    COP [DrawMetatileHere] ( #E9 )
    LDA $orbitAngle, X
    STA $14
    LDA $orbitDiameter, X
    STA $16
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #01, &code_08B616 )
    BRA loc_08B5B0
}

code_08B616 {
    RTL 

  loc_08B617:
    COP [PlaySoundCh1] ( #15 )
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08B625 )
}

code_list_08B625 [
  &code_08B629   ;00
  &code_08B634   ;01
]

code_08B629 {
    COP [StageBgChange] ( #70 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0170 )
    BRA loc_08B63F
}

code_08B634 {
    COP [StageBgChange] ( #71 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0171 )
    BRA loc_08B63F

  loc_08B63F:
    LDY $playerActor
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$^player_character.LedgeJumpEntry
    STA $0002, Y
    REP #$20
    LDA #$&player_character.LedgeJumpEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
}

code_08B666 {
    COP [Die]
}