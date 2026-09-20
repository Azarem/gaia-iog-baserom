; Mu underwater visual effects — tint and HDMA wave.
; 
; Thinker/actor that applies the underwater visual atmosphere:
; green-blue color tint via COLDATA and a wavy HDMA effect
; to simulate looking through water. Active in all Mu
; dungeon rooms.
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

mu_tint_and_wave [
  thinker-def < #04, #08, {

  code_00BDCF:
    COP [BranchIfFlagByte] ( #7B, #01, &MuTintAndWaveInit )
    SEP #$20
    LDA #$2A
    STA $COLDATA
    LDA #$44
    STA $COLDATA
    REP #$20
    BRA loc_00BDF3
} >
]

MuTintAndWaveInit {
    SEP #$20              ; MuTintAndWaveInit: select green COLDATA #$2A/#$44 or #$28/#$41 by flag #7B
    LDA #$28
    STA $COLDATA
    LDA #$41
    STA $COLDATA
    REP #$20

  loc_00BDF3:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BDCF )
    COP [TickSineHdma] ( #03, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    COP [BindSineHdma] ( $7E8C00, #0E )
    RTL 
}