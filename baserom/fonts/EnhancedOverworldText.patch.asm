
----------------------------------------------
?INCLUDE 'sFE_proc_03A940'
----------------------------------------------
;Set default colors for world map (enhances font profile)

Mode7InitEntry! {
    SEP #$20
    LDA #$80
    STA $M7SEL
    REP #$20
    LDA #$7FFF
    STA $7F0B22
    LDA #$53DE
    STA $7F0B24
    LDA #$01B1
    STA $7F0B26
    LDA $0D54
    STA $00CA
    SEC 
    SBC #$0080
    ORA #$8000
    STA $06C6
    LDA $0D56
    STA $00CC
    SEC 
    SBC #$0070
    ORA #$8000
    STA $06CA
    STZ $00B6
    STZ $00BC
    LDA #$0400
    STA $00B8
}
