?BANK 00

?INCLUDE 'flag_helpers'

---------------------------------------------

; COP #CC with one byte operand (flag index). Calls SetEventFlag to OR the corresponding bit in the eventFlags ($0A00) bitfield.

SetFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.SetEventFlag ; SetFlagByte: call SetEventFlag with byte-indexed flag
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
    JSR $&flag_helpers.SetEventFlag ; SetFlagWord: call SetEventFlag with word flag index
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
    JSR $&flag_helpers.ClearEventFlag ; ClearFlagByte: call ClearEventFlag on byte flag
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
    JSR $&flag_helpers.ClearEventFlag ; ClearFlagWord: call ClearEventFlag on word flag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D0 with one byte (flag), one byte (sense), and one &Code operand. Tests the flag via TestEventFlag; the sense byte selects branch-on-set vs branch-on-clear, jumping to the &Code offset when the condition matches.

BranchOnFlagByte {
    TYX 
    LDA [$0A]             ; BranchOnFlagByte: read byte flag index
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.TestEventFlag ; Test flag state via TestEventFlag
    BCS loc_00ABA5
    BCC loc_00AB9A
}

---------------------------------------------
; COP #D1 with one word (flag), one byte (sense), and one &Code operand. Word-indexed variant of BranchOnFlagByte with the same sense-controlled conditional branch.

BranchOnFlagWord {
    TYX 
    LDA [$0A]             ; BranchOnFlagWord: read word flag index
    INC $0A
    INC $0A
    JSR $&flag_helpers.TestEventFlag ; Test flag; BCS/BCC dispatch to sense-byte check below
    BCS loc_00ABA5

  loc_00AB9A:
    LDA [$0A]             ; Sense=0 branches when flag clear; sense≠0 branches when flag set
    INC $0A
    AND #$00FF
    BNE loc_00ABB7
    BRA loc_00ABAE

  loc_00ABA5:
    LDA [$0A]             ; Flag set path: read sense byte
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
    LDA [$0A]             ; Sense not met: skip &Code operand and continue
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
    LDA $0A               ; Rewind entry 2 bytes before $0A to re-execute this COP handler each frame
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read byte flag index
    INC $0A
    AND #$00FF
    JSR $&flag_helpers.TestEventFlag ; TestEventFlag: carry reflects flag state
    BCS loc_00ABF4
    BCC loc_00ABE9
}

---------------------------------------------
; COP #D3 with one word (flag) and one byte (sense). Word-indexed variant of WaitOnFlagByte with the same yield-until-match behavior.

WaitOnFlagWord {
    TYX 
    LDA $0A               ; WaitOnFlagWord: save rewind PC
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read word flag index
    INC $0A
    INC $0A
    JSR $&flag_helpers.TestEventFlag ; TestEventFlag for word flag
    BCS loc_00ABF4

  loc_00ABE9:
    LDA [$0A]             ; Check sense byte for yield decision
    INC $0A
    AND #$00FF
    BEQ loc_00AC00        ; Sense matched: advance past operand and RTI (flag condition satisfied)
    BRA loc_00ABFD

  loc_00ABF4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00AC00

  loc_00ABFD:
    PLA                   ; Sense not matched: yield RTL (recheck next frame)
    PLA 
    RTL 

  loc_00AC00:
    LDA $0A
    STA $02, S
    RTI 
}