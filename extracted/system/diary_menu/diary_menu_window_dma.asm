; Diary-menu highlight-band thinker for scene $FA (Bank 00, 48049-48203; spawned through thinker_spawn_0CEB18, the scene-$FA slot of the scene thinker table).
; 
; Every frame it chooses HDMA tables for the PPU window-1 position registers WH0/WH1 ($2126/$2127; the operand #26 of COP QueueHdmaDirect is that B-bus register, see hdma_channel_config) from three cursor words kept by sFA_diary_menu, where a negative value means 'none': $0D92 = slot cursor, $0D96 = copy-target slot, $0D98 = tab / settings-row cursor. DiaryMenuInit sets WOBJSEL = $22 (window 1 is the colour window) and CGWSEL = $82 (main screen black inside it), so each table lays a band over the rows under a cursor; measured: inside a band the main screen is black and only the BG3 text shows (the sub screen is added by colour math); outside the band the map is unchanged.
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
; 1. Slot cursor $0D92 (first QueueHdmaDirect): negative writes WH0/WH1 = $FF/$00 directly and queues the empty table; 0 / 1 / 2+ queue the slot-1 / slot-2 / slot-3 band. While a copy target is set ($0D96 >= 0) this band is only queued on odd frames (even frames queue the empty table), so the source row flickers at 30 Hz (measured: the band is drawn on every second frame; consecutive frames differ in the band's 31 lines and frames two apart are identical).
; 2. Target cursor $0D96 (second QueueHdmaDirect): same mapping, always queued.
; 3. Tab cursor $0D98 (third QueueHdmaDirect): negative = empty table, 0 / 1 / 2 / 3+ = the four narrow bands.
; Each COP QueueHdmaDirect takes its own direct-table HDMA channel, so the three tables overlay each other on the same registers. The channels run in order on every scanline and the last write wins, so an empty entry of a later channel hides an earlier channel's band on its lines. Measured: with the tab cursor at 0 the slot-1 band is invisible (the tab-0 table covers lines 79-93 with its own band and then writes $FF / $00 for lines 94-189), while the slot-3 band is visible.
---------------------------------------------

!frameCounter                   0036
!WH0                            2126

---------------------------------------------

; Thinker definition: one QueueHdmaDirect per cursor word per frame, then RTL (the thinker re-runs every frame).

diary_menu_window_dma [
  thinker-def < #04, #08, {

; Slot cursor band. D96 >= 0 and an even frame: queue the empty table (flicker); otherwise fall into DiaryBandSlotDispatch.

  DiaryBandSlotCursorGate:
    LDA $0D96             ; Target cursor set?
    BMI DiaryBandSlotDispatch
    LDA $frameCounter     ; Odd frames only draw the slot band while a target is set (flicker)
    LSR 
    BCC DiaryBandSlotQueueEmpty

; Dispatch on the slot cursor $0D92; a negative cursor clears the window registers directly and queues the empty table.

  DiaryBandSlotDispatch:
    LDA $0D92             ; Slot cursor
    BPL DiaryBandSlotCursor0
    LDA #$00FF            ; No slot cursor: window registers WH0 = $FF, WH1 = $00 (empty window)
    STA $WH0

; Queue the empty table diary_band_empty (no band) and continue with the target cursor.

  DiaryBandSlotQueueEmpty:
    COP [QueueHdmaDirect] ( @diary_band_empty, #26 ) ; Empty table: no band (#26 = WH0/WH1)
    BRA DiaryBandTargetDispatch

; Slot cursor 0 -> diary_band_slot1 (band at line 79); other values continue the compare chain.

  DiaryBandSlotCursor0:
    BNE DiaryBandSlotCursor1
    COP [QueueHdmaDirect] ( @diary_band_slot1, #26 )
    BRA DiaryBandTargetDispatch

; Slot cursor 1 -> diary_band_slot2 (band at line 111).

  DiaryBandSlotCursor1:
    DEC 
    BNE DiaryBandSlotCursor2Plus
    COP [QueueHdmaDirect] ( @diary_band_slot2, #26 )
    BRA DiaryBandTargetDispatch

; Slot cursor 2 or higher -> diary_band_slot3 (band at line 143).

  DiaryBandSlotCursor2Plus:
    COP [QueueHdmaDirect] ( @diary_band_slot3, #26 )
    BRA DiaryBandTargetDispatch

; Target cursor $0D96: negative clears the window registers directly and queues the empty table.

  DiaryBandTargetDispatch:
    LDA $0D96             ; Target cursor
    BPL DiaryBandTargetCursor0
    LDA #$00FF
    STA $WH0
    COP [QueueHdmaDirect] ( @diary_band_empty, #26 )
    BRA DiaryBandTabDispatch

; Target cursor 0 -> diary_band_slot1.

  DiaryBandTargetCursor0:
    BNE DiaryBandTargetCursor1
    COP [QueueHdmaDirect] ( @diary_band_slot1, #26 )
    BRA DiaryBandTabDispatch

; Target cursor 1 -> diary_band_slot2.

  DiaryBandTargetCursor1:
    DEC 
    BNE DiaryBandTargetCursor2Plus
    COP [QueueHdmaDirect] ( @diary_band_slot2, #26 )
    BRA DiaryBandTabDispatch

; Target cursor 2 or higher -> diary_band_slot3.

  DiaryBandTargetCursor2Plus:
    COP [QueueHdmaDirect] ( @diary_band_slot3, #26 )
    BRA DiaryBandTabDispatch

; Tab / row cursor $0D98: negative -> empty table diary_band_tab_empty, then RTL.

  DiaryBandTabDispatch:
    LDA $0D98             ; Tab / row cursor
    BPL DiaryBandTab0Queue
    COP [QueueHdmaDirect] ( @diary_band_tab_empty, #26 )
    RTL 

; Tab 0 -> diary_band_tab0 (band at line 79), RTL.

  DiaryBandTab0Queue:
    BNE DiaryBandTab1Queue
    COP [QueueHdmaDirect] ( @diary_band_tab0, #26 )
    RTL 

; Tab 1 -> diary_band_tab1 (band at line 95), RTL.

  DiaryBandTab1Queue:
    DEC 
    BNE DiaryBandTab2Queue
    COP [QueueHdmaDirect] ( @diary_band_tab1, #26 )
    RTL 

; Tab 2 -> diary_band_tab2 (band at line 111), RTL.

  DiaryBandTab2Queue:
    DEC 
    BNE DiaryBandTab3PlusQueue
    COP [QueueHdmaDirect] ( @diary_band_tab2, #26 )
    RTL 

; Tab 3 or higher -> diary_band_tab3 (band at line 127), RTL.

  DiaryBandTab3PlusQueue:
    COP [QueueHdmaDirect] ( @diary_band_tab3, #26 )
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