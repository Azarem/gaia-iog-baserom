; Light elevator mechanism in the Tower of Babel (~90 lines).
; 
; Automated elevator that carries the player upward using
; a beam of light. Handles player attachment, vertical
; movement, and the visual light shaft effect. Unique
; transport mechanic for the tower.
---------------------------------------------

?INCLUDE 'py_death_particle'

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

btE1_light_elevator [
  actor-def < #00, #00, #30, {

  code_099589:
    COP [BranchIfPlayerAt] ( #$0180, #$07A0, &code_099625 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #7B, #0A, #7D, &code_09959C )
    RTL 
} >
]

code_09959C {
    COP [SpawnThinker] ( @code_099618 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitWord] ( #$00EF )
    COP [SetFlagByte] ( #00 )
    COP [WaitWord] ( #$0167 )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterFlags] ( @py_death_particle, #$1002 )
    COP [SetEntryHereAndYield]
    LDY $playerActor
    LDA $000E, Y
    EOR #$2000
    STA $000E, Y
    LDA $0014, Y
    CLC 
    ADC #$0190
    STA $0014, Y
    COP [SetEntryHere]
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC #$0004
    STA $0016, Y
    CMP #$00B0
    BCC loc_0995E9
    RTL 

  loc_0995E9:
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC #$0190
    STA $0014, Y
    COP [SpawnAfterFlags] ( @py_death_particle, #$1002 )
    COP [WaitByte] ( #0F )
    LDY $playerActor
    LDA $000E, Y
    EOR #$2000
    STA $000E, Y
    COP [WaitByte] ( #07 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}

code_099618 {
    COP [PaletteStart] ( #6D )
    COP [PaletteStep]
    COP [SetEntryHere]
    COP [PaletteStart] ( #6F )
    COP [PaletteStep]
    RTL 
}

code_099625 {
    COP [SpawnThinker] ( @code_09962C )
    COP [Die]
}

code_09962C {
    COP [SetEntryHere]
    COP [PaletteStart] ( #6E )
    COP [PaletteStep]
    RTL 
}