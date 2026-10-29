; Inventory-screen BG3 vertical-scroll HDMA (Bank 00, 48016-48022). A HDMA-phase thinker (filter word $0804, so it runs right after ResetHdmaState every frame) that does nothing but bind one HDMA channel to a fixed 7-entry table. It is spawned by the inventory overlay scene $FF.
; 
; COP [QueueHdmaDirect] ( @inventory_bg3vofs_table, #12 ): the second operand is the B-bus register index, $12 = $2112 BG3VOFS (transfer mode 2, written twice for the low and high byte). It is not a byte count. QueueHdmaDirect goes through SetupHdmaChannel_Direct.
; 
; The table (inventory_bg3vofs_table, 21 bytes) is {count, low, high} per entry: lines 0-111 V = 0, then 48 lines V = 0, then four 12-line bands with V = $0B, $0F, $13, $17, then 64 lines V = $20. The line counts add to 272, more than a frame, so no terminator is needed. From line 160 down BG3's vertical scroll steps up from 0 to $20 (visual result not checked).
; 
; Earlier notes called this a '12-byte DMA table to VRAM'; that was wrong.
---------------------------------------------

---------------------------------------------

inventory_bg3_scroll_hdma [
  thinker-def < #04, #08, {

; Binds the BG3VOFS table and returns. Re-run every frame because ResetHdmaState clears the channel assignment.

  InventoryBg3HdmaEntry:
    COP [QueueHdmaDirect] ( @inventory_bg3vofs_table, #12 ) ; Bind a direct HDMA channel to the table at the first operand; #12 is B-bus register $2112 = BG3VOFS
    RTL                   ; Back to the thinker runner; the binding is repeated next frame
} >
]

---------------------------------------------
; Direct-mode HDMA table for BG3VOFS: seven {line count, scroll value low, scroll value high} entries (111+48 lines at 0, 12 lines each at $0B / $0F / $13 / $17, then 64 lines at $20). The line counts are shown in the data lines as the first operand.

inventory_bg3vofs_table [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #30, #00, #00 >   ;01
  dma-channel < #0C, #0B, #00 >   ;02
  dma-channel < #0C, #0F, #00 >   ;03
  dma-channel < #0C, #13, #00 >   ;04
  dma-channel < #0C, #17, #00 >   ;05
  dma-channel < #40, #20, #00 >   ;06
]