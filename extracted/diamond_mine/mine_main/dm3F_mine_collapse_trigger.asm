; Cave-in trigger in the mine main chamber — collapses the tunnel entrance on the 4th switch hit.
; 
; Dies at once when flag word $0121 is set. Otherwise it checks each frame whether the hit counter byte $0A01 (written by dm3F_switch) equals 4. On the frame it does, it sets $0121, applies BG change #21 to redraw the collapsed tunnel entrance and plays rumble sound #0E on both channels; the actor then marks itself for death.
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