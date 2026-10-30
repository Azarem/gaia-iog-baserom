; Pyramid scenes $D0 and $D1 (one placement each): one-shot trigger that draws two metatiles, applies a BG change and then makes the player jump (LedgeJumpEntry). The old note (hit points, debris, 'used extensively in the maze-like corridors') does not match the code: there is no HP counter, no hit test and no spawn, and only two scenes place it. The block name (breakable wall) is probably wrong as well and was not changed because the purpose of the trigger was not established.
; 
; The actor's $0E word (copied to $26) picks the variant: 0 uses flag word $0170 and BG change #70, anything else flag word $0171 and BG change #71. The actor dies at once when its flag word is set. Otherwise each pass first requires the player's $7F0008 byte to be $95 or $8E and the player's animation index ($28) to be $1C; what those values mean was not traced ($1C is the landing pose of a ledge jump, LedgeJumpLand, and other player code stages it too). Then BranchIfPlayerNear #01 leads to the action code. The first pass through it (the actor's $24 is 0) sets $24 = 1, converts the actor's $14 / $16 to tile coordinates (saved in orbitAngle / orbitDiameter, restored afterwards) and draws metatiles #E8 and #E9 side by side with DrawMetatileHere. A later pass ($24 nonzero) plays sound #15, applies the BG change, sets the flag word, clears actor flag $0008 and sets $0200 in the player's $10, writes player_character.LedgeJumpEntry into the player actor (address +$00, bank byte +$02, $08 and $2A zeroed) and dies.
; 
; As in awB3_ledge_jump_trigger, the jump starts because this script writes LedgeJumpEntry, with no type $08 cell involved.
---------------------------------------------

?INCLUDE 'player_character'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

pyD0_breakable_wall [
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