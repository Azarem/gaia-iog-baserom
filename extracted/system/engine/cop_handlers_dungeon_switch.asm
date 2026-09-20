?BANK 00

?INCLUDE 'flag_helpers'

!enemyNum                       7F0022

---------------------------------------------

; COP #D8 with no script operands. Reads enemyNum ($7F0022) as a WRAM flag index and calls SetWramFlag when non-zero, recording a dungeon enemy kill.

SetDungeonKillFlag {
    TYX 
    LDA $enemyNum, X      ; SetDungeonKillFlag: enemyNum indexes WRAM kill bitfield
    AND #$00FF            ; Mask to byte
    BEQ loc_00AC8F        ; Zero → no enemy to record, skip
    JSR $&flag_helpers.SetWramFlag ; SetWramFlag: mark enemy kill in dungeon bitfield

  loc_00AC8F:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D9 with one word (WRAM address) and one Address (case table base). Reads a byte from the WRAM address, doubles it for a word index, and jumps into the case table in the script bank.

SwitchCase {
    LDA [$0A]             ; Read WRAM address word (switch variable source)
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X          ; Read byte at WRAM address → case index
    AND #$00FF
    ASL                   ; SwitchCase: table index ×2 for word-aligned jump table
    STA $0000
    PHB 
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
    PLB 
    TYX 
    STA $02, S
    RTI 
}