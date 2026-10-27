; Dungeon kill-tracking and switch-case COP handlers (44162–44225, Bank 00).
; 
; - SetDungeonKillFlag (COP #D8): records the current enemy's defeat in the wramFlags bitfield ($0A80). That field is cleared only on world map entry, by two scripts and on game over, so a kill can outlive the room (OQ-67).
; - SwitchCase (COP #D9): computed jump through a word table in the script bank.
; 
; Both handlers return to the script by storing the next script address in the saved COP stack frame ($02,S) and executing RTI.
---------------------------------------------

?BANK 00

?INCLUDE 'flag_helpers'

!enemyNum                       7F0022

---------------------------------------------

; COP #D8 with no script operands. Reads the actor's enemyNum ($7F:0022,X — the dungeon enemy number used for kill tracking) as a flag index and, when its low byte is non-zero, calls SetWramFlag to set that bit in the wramFlags bitfield ($0A80), recording the kill (cleared only as described in flag_helpers, OQ-67). Index 0 is ignored.

SetDungeonKillFlag {
    TYX                   ; X = actor slot (CopDispatch left it in Y)
    LDA $enemyNum, X      ; Load this actor's enemyNum ($7F:0022,X) — kill-flag index
    AND #$00FF            ; Mask to byte
    BEQ loc_00AC8F        ; Zero → no enemy number, skip
    JSR $&flag_helpers.SetWramFlag ; Set bit enemyNum in the wramFlags bitfield ($0A80)

  loc_00AC8F:
    LDA $0A               ; Script pointer (this COP has no operands)
    STA $02, S            ; Store into the COP return frame — RTI resumes the script there
    RTI 
}

---------------------------------------------
; COP #D9 with two word operands: a low-WRAM address holding the switch variable, and the base (in the script bank) of a table of word script addresses. Reads the byte at the WRAM address, doubles it, fetches the word at base + 2×value (DBR temporarily set to the script bank cached in $0C) and makes it the new script address. There is no range check — a value past the end of the table reads whatever follows it. The doubled index is kept in scratch word $0000, so a script that uses $0000 itself as the variable has it overwritten.

SwitchCase {
    LDA [$0A]             ; Read WRAM address word (switch variable source)
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X          ; Read byte at WRAM address → case index
    AND #$00FF
    ASL                   ; SwitchCase: table index ×2 for word-aligned jump table
    STA $0000             ; Keep doubled index in scratch $0000
    PHB                   ; Save DBR
    SEP #$20
    LDA $0C               ; Switch DBR to script bank for table data reads
    PHA 
    PLB 
    REP #$20
    LDA [$0A]             ; Read case table base address from script
    INC $0A
    INC $0A
    CLC 
    ADC $0000             ; Add case base + scaled index for switch target address
    TAX 
    LDA $0000, X          ; Read target script address from table entry
    PLB                   ; Restore DBR
    TYX                   ; X = actor slot again
    STA $02, S            ; Overwrite the COP return address with the case target — RTI performs the jump
    RTI 
}