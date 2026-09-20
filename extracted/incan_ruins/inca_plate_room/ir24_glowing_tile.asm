; Glowing floor tile puzzle in the Inca plate room — timed step counter.
; 
; Checks flag word $0112. Starts a 600-frame countdown (orbitAngle =
; $0258). Each frame checks if the player is standing in a specific
; tile rectangle (14,17 to 17,1A). While player is on the tile, the
; counter decrements. When it reaches 0, plays chime SFX ($0F0F)
; and completes the puzzle step.
---------------------------------------------

!orbitAngle                     7F0010

---------------------------------------------

ir24_glowing_tile [
  actor-def < #00, #00, #23, {

  code_09C671:
    COP [BranchIfFlagWord] ( #$0112, #01, &code_09C6A7 )

  code_09C678:
    LDA #$0258
    STA $orbitAngle, X
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #14, #17, #17, #1A, &code_09C68E )
    COP [SetEntryExitNow] ( @code_09C678 )
} >
]

code_09C68E {
    LDA $orbitAngle, X
    DEC 
    BEQ loc_09C69A
    STA $orbitAngle, X
    RTL 

  loc_09C69A:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #12 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0112 )
}

code_09C6A7 {
    COP [Die]
}