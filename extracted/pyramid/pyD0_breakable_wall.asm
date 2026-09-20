; Breakable wall segments in the Pyramid — destroyable barriers.
; 
; Multi-instance destructible walls (~136 lines). Each wall
; section has HP and breaks when hit enough times, spawning
; debris and applying a BG change to remove the wall tiles.
; Used extensively in the Pyramid's maze-like corridors.
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
    LDA #$^player_character.ClimbVineEntry
    STA $0002, Y
    REP #$20
    LDA #$&player_character.ClimbVineEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
}

code_08B666 {
    COP [Die]
}