; Slow horizontal ripple thinker (Bank 00): one sine-wave HDMA table feeding BG1HOFS, started and animated once the scene has finished loading.
; 
; Spawned by scene $32 (Freejia) and scenes $E9 / $EA (the mansion), spawn parameter $00 (unused). Dao has its own copy, dao_sine_hdma_slow. The old description ("8-step wave on channel $8800, 40-byte table, vertical distortion, Dao and ending-comet scenes") mixed up the operands:
;   - $7F0008,X = 8 is the wave AMPLITUDE (BuildSineHdmaTable multiplies the sine table by it).
;   - InitSineHdma ( #$8800, #40 ): $8800 is the WRAM table base ($7E8800), $40 = 64 is the wave period in scanlines per HDMA entry. Each of its four tables therefore has 256 / 64 = 4 repeat-mode entries (count $C0, 64 lines each) that all point at the same 64 data words at table + $0100.
;   - TickSineHdma ( #01, #02 ): #01 is the delay, so the phase advances once every 2 calls (every other frame); #02 is a byte offset into the camera scroll words (cameraTargetX / cameraTargetY + 2) that the table builder uses.
;   - BindSineHdma ( $7E8800, #0D ): #0D is the hdma_channel_config entry for register $210D, BG1HOFS (one register written twice), so the table makes BG1 scroll horizontally by a different amount on every scanline: a horizontal ripple, not a vertical distortion. Odd frames bind the table at +$0200 (double buffer).
; 
; Flow: the script initialises, then SetEntryHereAndYield sets the re-entry point to the flag test. Every following frame it tests event flag $FF: clear (the scene setup has not finished; scene_lifecycle clears the flag first and sets it again at the end) jumps back to the init label, which restores the amplitude, rebuilds the tables and resets the phase; set runs TickSineHdma and BindSineHdma and ends the frame with RTL, to resume at the flag test next frame.
---------------------------------------------

---------------------------------------------

; Thinker script: amplitude 8, InitSineHdma, yield; each later frame: wait for event flag $FF (re-initialise while it is clear), TickSineHdma, BindSineHdma, RTL.

sine_hdma_slow_wave [
  thinker-def < #04, #08, {

; Init label: set the amplitude ($7F0008,X = 8) and build the four sine tables at $7E8800 (period 64); reached on the first frame and again whenever the flag test finds event flag $FF clear.

  SineWaveInit:
    LDA #$0008            ; Amplitude 8 ...
    STA $7F0008, X        ; ... stored in the actor's amplitude field ($7F0008,X)
    COP [InitSineHdma] ( #$8800, #40 ) ; Table base $7E8800, wave period $40 = 64 scanlines (four tables of 4 repeat entries)
    COP [SetEntryHereAndYield] ; Yield; next frame the thinker resumes at the flag test below
    COP [BranchOnFlagByte] ( #FF, #00, &SineWaveInit ) ; Event flag $FF clear (scene setup not finished): back to the init label (amplitude, tables, phase 0)
    COP [TickSineHdma] ( #01, #02 ) ; Phase + 1 every 2nd call (delay #01); camera words at cameraTargetX/Y + 2 feed the table
    COP [BindSineHdma] ( $7E8800, #0D ) ; Bind the table at $7E8800 (+$0200 on odd frames) to config #0D: BG1HOFS ($210D)
    RTL                   ; End of this frame's turn; resumes at the flag test next frame
} >
]