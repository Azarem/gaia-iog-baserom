; Diary-menu highlight-band thinker for scene $FA (Bank 00, 48049-48203; spawned through thinker_spawn_0CEB18, the scene-$FA slot of the scene thinker table).
; 
; Every frame it chooses HDMA tables for the PPU window-1 position registers WH0/WH1 ($2126/$2127; the operand #26 of COP QueueDma is that B-bus register, see hdma_channel_config) from three cursor words kept by sFA_diary_menu, where a negative value means 'none': $0D92 = slot cursor, $0D96 = copy-target slot, $0D98 = tab / settings-row cursor. DiaryMenuInit sets WOBJSEL = $22 (window 1 is the colour window) and CGWSEL = $82 (main screen black inside it), so each table lays a band over the rows under a cursor; the band appearance is decoded from the registers, not observed (OQ-I057-3).
; 
; === TABLES ===
; 
; Each dma-channel entry is one HDMA step: line count, WH0 (left), WH1 (right); the assembler appends the $00 terminator, so an array is 3n + 1 bytes and an empty array is a lone terminator (no band). WH0 = $FF with WH1 = $00 is an empty window (left > right), i.e. no band on those lines.
; - No part notes on diary_band_empty / diary_band_slot1 on purpose: the transforms.json rule for this block swaps those two labels with a regex that needs them adjacent, and a note line between them stops it matching (the ROM then loses a byte). diary_band_empty is the empty table (terminator only, no band); diary_band_slot1 is the slot-1 band.
; - Slot bands (31 lines tall, x = $10-$F0): diary_band_slot1 starts at line 79 (slot 1), diary_band_slot2 at line 111 (slot 2), diary_band_slot3 at line 143 (slot 3; two empty entries of $10 + $7F lines because one count cannot exceed $7F).
; - Tab / row bands (15 lines tall, x = $30-$D0): diary_band_tab0 at line 79, diary_band_tab1 at 95, diary_band_tab2 at 111, diary_band_tab3 at 127. diary_band_empty and diary_band_tab_empty are the empty tables.
; 
; === SELECTION ===
; 
; 1. Slot cursor $0D92 (first QueueDma): negative writes WH0/WH1 = $FF/$00 directly and queues the empty table; 0 / 1 / 2+ queue the slot-1 / slot-2 / slot-3 band. While a copy target is set ($0D96 >= 0) this band is only queued on odd frames (even frames queue the empty table), so the source row flickers at 30 Hz.
; 2. Target cursor $0D96 (second QueueDma): same mapping, always queued.
; 3. Tab cursor $0D98 (third QueueDma): negative = empty table, 0 / 1 / 2 / 3+ = the four narrow bands.
; Each COP QueueDma takes its own direct-table HDMA channel, so the three tables overlay each other on the same registers.
---------------------------------------------

!frameCounter                   0036
!WH0                            2126

---------------------------------------------

; Thinker definition: one QueueDma per cursor word per frame, then RTL (the thinker re-runs every frame).

diary_menu_window_dma [
  thinker-def < #04, #08, {

; Slot cursor band. D96 >= 0 and an even frame: queue the empty table (flicker); otherwise fall into loc_00BBBC.

  code_00BBB1:
    LDA $0D96             ; Target cursor set?
    BMI loc_00BBBC
    LDA $frameCounter     ; Odd frames only draw the slot band while a target is set (flicker)
    LSR 
    BCC loc_00BBC7

; Dispatch on the slot cursor $0D92; a negative cursor clears the window registers directly and queues the empty table.

  loc_00BBBC:
    LDA $0D92             ; Slot cursor
    BPL loc_00BBCF
    LDA #$00FF            ; No slot cursor: window registers WH0 = $FF, WH1 = $00 (empty window)
    STA $WH0

; Queue the empty table diary_band_empty (no band) and continue with the target cursor.

  loc_00BBC7:
    COP [QueueDma] ( @diary_band_empty, #26 ) ; Empty table: no band (#26 = WH0/WH1)
    BRA loc_00BBEC

; Slot cursor 0 -> diary_band_slot1 (band at line 79); other values continue the compare chain.

  loc_00BBCF:
    BNE loc_00BBD9
    COP [QueueDma] ( @diary_band_slot1, #26 )
    BRA loc_00BBEC

; Slot cursor 1 -> diary_band_slot2 (band at line 111).

  loc_00BBD9:
    DEC 
    BNE loc_00BBE4
    COP [QueueDma] ( @diary_band_slot2, #26 )
    BRA loc_00BBEC

; Slot cursor 2 or higher -> diary_band_slot3 (band at line 143).

  loc_00BBE4:
    COP [QueueDma] ( @diary_band_slot3, #26 )
    BRA loc_00BBEC

; Target cursor $0D96: negative clears the window registers directly and queues the empty table.

  loc_00BBEC:
    LDA $0D96             ; Target cursor
    BPL loc_00BBFF
    LDA #$00FF
    STA $WH0
    COP [QueueDma] ( @diary_band_empty, #26 )
    BRA loc_00BC1C

; Target cursor 0 -> diary_band_slot1.

  loc_00BBFF:
    BNE loc_00BC09
    COP [QueueDma] ( @diary_band_slot1, #26 )
    BRA loc_00BC1C

; Target cursor 1 -> diary_band_slot2.

  loc_00BC09:
    DEC 
    BNE loc_00BC14
    COP [QueueDma] ( @diary_band_slot2, #26 )
    BRA loc_00BC1C

; Target cursor 2 or higher -> diary_band_slot3.

  loc_00BC14:
    COP [QueueDma] ( @diary_band_slot3, #26 )
    BRA loc_00BC1C

; Tab / row cursor $0D98: negative -> empty table diary_band_tab_empty, then RTL.

  loc_00BC1C:
    LDA $0D98             ; Tab / row cursor
    BPL loc_00BC28
    COP [QueueDma] ( @diary_band_tab_empty, #26 )
    RTL 

; Tab 0 -> diary_band_tab0 (band at line 79), RTL.

  loc_00BC28:
    BNE loc_00BC31
    COP [QueueDma] ( @diary_band_tab0, #26 )
    RTL 

; Tab 1 -> diary_band_tab1 (band at line 95), RTL.

  loc_00BC31:
    DEC 
    BNE loc_00BC3B
    COP [QueueDma] ( @diary_band_tab1, #26 )
    RTL 

; Tab 2 -> diary_band_tab2 (band at line 111), RTL.

  loc_00BC3B:
    DEC 
    BNE loc_00BC45
    COP [QueueDma] ( @diary_band_tab2, #26 )
    RTL 

; Tab 3 or higher -> diary_band_tab3 (band at line 127), RTL.

  loc_00BC45:
    COP [QueueDma] ( @diary_band_tab3, #26 )
    RTL 
} >
]

diary_band_slot1 [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

diary_band_empty [
]

---------------------------------------------
; Slot-2 band: 111 empty lines, 31 lines of window x = $10-$F0, 96 empty lines.

diary_band_slot2 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

---------------------------------------------
; Slot-3 band: 143 empty lines (as $10 + $7F), 31 lines of window x = $10-$F0, 96 empty lines.

diary_band_slot3 [
  dma-channel < #10, #FF, #00 >   ;00
  dma-channel < #7F, #FF, #00 >   ;01
  dma-channel < #1F, #10, #F0 >   ;02
  dma-channel < #60, #FF, #00 >   ;03
]

---------------------------------------------
; Empty table (terminator only): no tab band.

diary_band_tab_empty [
]

---------------------------------------------
; Tab-0 band: 79 empty lines, 15 lines of window x = $30-$D0, 96 empty lines.

diary_band_tab0 [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

---------------------------------------------
; Tab-1 band: 95 empty lines, 15 lines of window x = $30-$D0, 96 empty lines.

diary_band_tab1 [
  dma-channel < #5F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

---------------------------------------------
; Tab-2 band: 111 empty lines, 15 lines of window x = $30-$D0, 96 empty lines.

diary_band_tab2 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

---------------------------------------------
; Tab-3 band: 127 empty lines, 15 lines of window x = $30-$D0, 96 empty lines.

diary_band_tab3 [
  dma-channel < #7F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]