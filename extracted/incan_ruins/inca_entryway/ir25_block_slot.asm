; Block slot receiver in the Inca entryway — detects placed block.
; 
; Positioned at (+8,0). Checks flag $2F — if not yet set, waits for
; the block to be pushed into position. When triggered, plays SFX
; #2C. After flag $2F is set, hides display ($2000 TRB) and idles.
---------------------------------------------

---------------------------------------------

ir25_block_slot [
  actor-def < #1D, #01, #23, {

  code_09C3A2:
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #2F, #01, &code_09C3B3 )
    COP [ExitIfFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )
} >
]

code_09C3B3 {
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}