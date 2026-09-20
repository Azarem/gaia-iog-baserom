; Plate gate opener — opens passage when all 4 gold tiles are activated.
; 
; Checks flag $3C. Each frame, reads eventFlags AND $001E — when
; all 4 tile bits are set (result = $001E), plays chime SFX ($0F0F),
; applies BG change #08 to open the gate, sets flag word $0108
; and flag $3C. Once opened, stays open permanently.
---------------------------------------------

!eventFlags                     0A00

---------------------------------------------

ir1F_plate_gate_opener [
  actor-def < #00, #00, #23, {

  code_09C48C:
    COP [BranchOnFlagByte] ( #3C, #01, &code_09C4B0 )
    COP [SetEntryHere]
    LDA $eventFlags
    AND #$001E
    CMP #$001E
    BEQ loc_09C4A0
    RTL 

  loc_09C4A0:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #08 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0108 )
    COP [SetFlagByte] ( #3C )
} >
]

code_09C4B0 {
    COP [Die]
}