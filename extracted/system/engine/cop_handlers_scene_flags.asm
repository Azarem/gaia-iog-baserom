; COP handlers for the persistent event-flag bitfield — set, clear, branch and wait (43841–44037, Bank 00).
; 
; Eight COP opcodes ($CC–$D3, copdef ids 204–211) operate on the 2048-bit eventFlags field at $0A00 through flag_helpers (SetEventFlag, ClearEventFlag, TestEventFlag). Every opcode comes in a Byte form (flag index 0–$FF, one operand byte) and a Word form (index 0–$7FF, two operand bytes). Script usage in the extracted code (COP [..] sites): SetFlagByte 475, SetFlagWord 62, ClearFlagByte 71, ClearFlagWord 22, BranchOnFlagByte 630, BranchOnFlagWord 40, WaitOnFlagByte 384, WaitOnFlagWord 9.
; 
; === SENSE BYTE ===
; 
; Branch and Wait take a sense byte after the flag index: 0 means 'act when the flag is clear', nonzero means 'act when the flag is set'. BranchOnFlag then reads a &Code word (the branch target within the script bank); WaitOnFlag has no target.
; 
; === SHARED TAILS ===
; 
; The Byte forms of Branch and Wait read their flag index, call TestEventFlag and then jump into the sense-byte tail that sits inside the Word form (BranchOnFlagByte uses loc_00AB9A / loc_00ABA5, WaitOnFlagByte uses loc_00ABE9 / loc_00ABF4). Those labels belong to the Word handlers' bodies, and the Byte forms reach them with relative branches, so the forms must stay within branch range of each other.
; 
; === RETURN CONVENTIONS ===
; 
; Set, Clear and Branch finish by storing the advanced operand pointer ($0A) over the return address ($02,S) and RTI. WaitOnFlag first stores the address of its own COP opcode (operand pointer − 2) in the actor's re-entry word ($00); while the flag does not match it yields with PLA PLA RTL, so the same COP re-runs next frame.
---------------------------------------------

?BANK 00

?INCLUDE 'flag_helpers'

---------------------------------------------

; COP #CC with one byte operand (flag index). Calls SetEventFlag to OR the corresponding bit in the eventFlags ($0A00) bitfield.

SetFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.SetEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CD with one word operand (flag index). Calls SetEventFlag with the 16-bit flag number.

SetFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&flag_helpers.SetEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CE with one byte operand. Calls ClearEventFlag on the byte flag index.

ClearFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.ClearEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CF with one word operand. Calls ClearEventFlag on the word flag index.

ClearFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&flag_helpers.ClearEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D0 with one byte (flag), one byte (sense), and one &Code operand. Tests the flag via TestEventFlag; the sense byte selects branch-on-set vs branch-on-clear, jumping to the &Code offset when the condition matches.

BranchOnFlagByte {
    TYX 
    LDA [$0A]             ; Byte flag index (0–$FF)
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.TestEventFlag ; Carry = flag state; both branches below jump into BranchOnFlagWord's sense-byte tail
    BCS loc_00ABA5
    BCC loc_00AB9A
}

---------------------------------------------
; COP #D1 with one word (flag), one byte (sense), and one &Code operand. Word-indexed variant of BranchOnFlagByte with the same sense-controlled conditional branch.

BranchOnFlagWord {
    TYX 
    LDA [$0A]             ; Word flag index (0–$7FF)
    INC $0A
    INC $0A
    JSR $&flag_helpers.TestEventFlag ; Carry = flag state; set → loc_00ABA5, clear → fall into loc_00AB9A
    BCS loc_00ABA5

  loc_00AB9A:
    LDA [$0A]             ; Flag clear path: sense byte 0 = branch, nonzero = skip
    INC $0A
    AND #$00FF
    BNE loc_00ABB7
    BRA loc_00ABAE

  loc_00ABA5:
    LDA [$0A]             ; Flag set path: sense byte nonzero = branch, 0 = skip
    INC $0A
    AND #$00FF
    BEQ loc_00ABB7

  loc_00ABAE:
    LDA [$0A]             ; Sense condition met: read &Code branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_00ABB7:
    LDA [$0A]             ; Condition not met: step over the &Code operand (the load itself is not needed) and continue
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D2 with one byte (flag) and one byte (sense). Saves a rewind entry PC, then yields RTL each frame until TestEventFlag matches the requested sense (set or clear).

WaitOnFlagByte {
    TYX 
    LDA $0A               ; Re-entry word ($00) = address of this COP opcode ($0A − 2), so the COP re-runs each frame until the flag matches
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read byte flag index
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.TestEventFlag ; Carry = flag state; both branches jump into WaitOnFlagWord's sense-byte tail
    BCS loc_00ABF4
    BCC loc_00ABE9
}

---------------------------------------------
; COP #D3 with one word (flag) and one byte (sense). Word-indexed variant of WaitOnFlagByte with the same yield-until-match behavior.

WaitOnFlagWord {
    TYX 
    LDA $0A               ; Re-entry word ($00) = address of this COP opcode ($0A − 2)
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read word flag index
    INC $0A
    INC $0A
    JSR $&flag_helpers.TestEventFlag ; Carry = flag state; set → loc_00ABF4, clear → fall into loc_00ABE9
    BCS loc_00ABF4

  loc_00ABE9:
    LDA [$0A]             ; Flag clear path: sense byte 0 = condition met (continue), nonzero = keep waiting
    INC $0A
    AND #$00FF
    BEQ loc_00AC00        ; Sense 0 and flag clear: condition met → loc_00AC00 (resume after operands)
    BRA loc_00ABFD

  loc_00ABF4:
    LDA [$0A]             ; Flag set path: sense byte nonzero = condition met, 0 = keep waiting
    INC $0A
    AND #$00FF
    BNE loc_00AC00

  loc_00ABFD:
    PLA                   ; Not met: drop the COP frame (PLA PLA) and RTL to the actor loop; $00 makes the COP re-run next frame
    PLA 
    RTL 

  loc_00AC00:
    LDA $0A
    STA $02, S
    RTI 
}