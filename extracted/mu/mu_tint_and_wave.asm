; Combined color tint and dual-channel sine HDMA for Mu continent rooms.
; 
; Selects green COLDATA tint (#$2A/#$44) or alternate tint (#$28/#$41) based on flag #7B, writing directly to COLDATA ($2132) each frame. Then runs sine HDMA with counter #$0001, amplitude 8 at $7E8800, tick speed #03, binding $7E8800 to channel #0D and $7E8C00 to channel #0E. Produces the eerie green Mu atmosphere with simultaneous background scroll oscillation on BG1 and BG2.
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