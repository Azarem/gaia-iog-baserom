; Mu underwater visual effects — tint and HDMA wave.
; 
; Thinker of the Mu scenes $5F, $60, $61, $62, $64 and $65 (not the prayer room $63, the altar room $66 or the vampire lair $67). While scene setup flag $FF is clear it writes the COLDATA colour pair every frame: #$2A and #$44, or #$28 and #$41 when flag $7B (Statue of Hope on the west pedestal) is set. It then starts a sine HDMA (InitSineHdma) and, once $FF is set, ticks the wave and binds the two wave tables $7E8800 and $7E8C00 each frame.
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

mu_tint_and_wave [
  thinker-def < #04, #08, {

  code_00BDCF:
    COP [BranchOnFlagByte] ( #7B, #01, &MuTintAndWaveInit )
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
    COP [SetEntryHereAndYield]
    COP [BranchOnFlagByte] ( #FF, #00, &code_00BDCF )
    COP [TickSineHdma] ( #03, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    COP [BindSineHdma] ( $7E8C00, #0E )
    RTL 
}