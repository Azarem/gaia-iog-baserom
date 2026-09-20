; Cave-in trigger in the mine main area — collapses tunnel on 4th laborer.
; 
; Checks flag word $0121 each frame. When RAM $0A01 reaches 4 (four
; laborers freed), sets the flag, applies BG change #21 to redraw
; the collapsed tunnel entrance, and plays rumble SFX #0E on both
; channels. After triggering, marks self for death.
---------------------------------------------

?BANK 05

---------------------------------------------

dm3F_mine_collapse_trigger [
  actor-def < #00, #00, #30, {

  code_05D069:
    COP [BranchOnFlagWord] ( #$0121, #01, &code_05D08B )
    COP [SetEntryHere]
    LDA $0A01
    AND #$00FF
    CMP #$0004
    BEQ loc_05D07E
    RTL 

  loc_05D07E:
    COP [SetFlagWord] ( #$0121 )
    COP [StageBgChange] ( #21 )
    COP [ApplyBgChange]
    COP [PlaySoundBoth] ( #$0E0E )
} >
]

code_05D08B {
    COP [MarkDeath]
    RTL 
}