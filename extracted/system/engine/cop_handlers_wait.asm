; COP wait handlers WaitByte ($DA) and WaitWord ($DB): frame-count delays for actor scripts (44225–44254, Bank 00).
; 
; Both load a frame count into the actor's waitCounter ($08), save the resume address (script cursor $0A/$0C → entryPtr $00/$02, i.e. the byte after the operand) and yield with RTL. The actor loop (RunActors_*, actor_execution.asm) runs DEC $08 once per actor tick and resumes the script at entryPtr when the result goes negative, so a count of N resumes N+1 ticks later (0 = next tick).
; 
; WaitByte reads a 1-byte count; WaitWord reads a 2-byte count (delays over 255 ticks) and jumps into WaitByte's shared tail, loc_00ACC9.
; 
; Contrast: JumpAfterDelay continues at a new script address after its delay, and SetEntryHereAndYield yields one tick with no count (both in cop_handlers_script_control).
---------------------------------------------

?BANK 00

---------------------------------------------

; COP $DA with a 1-byte operand (frame count): sleep the actor for N+1 ticks, then resume after the operand.
; 
; Reads the count (the 16-bit read also pulls in the next script byte, hence the AND), then falls into the shared tail loc_00ACC9, which stores it in waitCounter ($08), saves the resume address to entryPtr ($00/$02) and yields by discarding the COP stack frame and returning with RTL to the actor loop.

WaitByte {
    TYX 
    LDA [$0A]             ; 1-byte operand: frame count
    INC $0A
    AND #$00FF            ; Drop the following script byte picked up by the 16-bit read

  loc_00ACC9:
    STA $08               ; Shared tail: arm waitCounter; RunActors decrements it each tick and resumes when it goes negative
    LDA $0C               ; Resume bank → $02 (16-bit copy; $03 is padding)
    STA $02
    LDA $0A               ; Resume PC = first byte after the operand → $00
    STA $00
    PLA                   ; Yield: discard the 4-byte COP frame (P, PC, PBR) so RTL returns to the actor loop
    PLA 
    RTL 
}

---------------------------------------------
; COP $DB with a 2-byte operand (frame count): same wait as WaitByte for delays over 255 ticks.
; 
; Reads the 16-bit count and branches into WaitByte's shared tail (loc_00ACC9).

WaitWord {
    TYX 
    LDA [$0A]             ; 2-byte operand: frame count (up to 65535 ticks)
    INC $0A
    INC $0A
    BRA loc_00ACC9
}