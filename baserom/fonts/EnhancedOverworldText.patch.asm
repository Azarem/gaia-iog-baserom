; ==============================================================================
; World map Mode 7 init - overworld text palette profile
; ==============================================================================
; What it does: On scene $FE Mode 7 thinker init, sets $7F0B22-$7F0B26 to the
;   enhanced font gradient instead of all $FFFF and keeps camera math unchanged.
; Vanilla behavior: Mode7InitEntry clears $7F0B22/$7F0B24 to $FFFF only.
; Hooks (overrides): mode7_perspective Mode7InitEntry (world map thinker).
; Depends on: sFE_proc_03A940 include (world map scene block).
; State: $00CA/$00CC centre, $06C6/$06CA scroll override, $7F0B22-$7F0B26 colors.
; Hazards/notes: Runs at thinker entry; M7SEL $80 unchanged from vanilla.
; ==============================================================================

----------------------------------------------
?INCLUDE 'sFE_proc_03A940'
----------------------------------------------

mode7_perspective.Mode7InitEntry! {
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
