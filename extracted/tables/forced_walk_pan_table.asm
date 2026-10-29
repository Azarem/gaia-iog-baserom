; Camera pan step lists of the forced-walk warps (Bank 01, 108894-109277): 16 word pointers ($00-$0F) to 16 lists that set the speed profile of the camera pan during a forced walk.
; 
; === WHO READS IT ===
; 
; An extended warp entry (ExecuteForcedWalkWarp) keeps the list number in the low nibble of its byte 6 (scrollStepTableBase), the direction in bits 4/5/7. The four ForcedWalk* actors in forced_walk look up forced_walk_pan_table[index] and store the pointer in scrollStepTableBase; the CameraPan* handler of the walk direction then calls CameraScrollStepLookup once per pan call.
; 
; === LIST FORMAT ===
; 
; A list is a run of little-endian words, ended by a word whose high byte is 0 (always $0000 here). For each word: low byte = delay D, high byte = step S. CameraPan* adds the low nibble of S pixels to the camera target on the call that loads the word and on each of the next D calls, so a word moves the camera S x (D + 1) pixels. The pan ends when the list ends or when the camera target reaches the camera bounds, whichever comes first.
; 
; All 16 lists have the same shape: an ease-in of 4 calls each at 1, 2, 4, 6 px (then 8, 10 in the longer ones), a long cruise word, and the mirror ease-out. Only the cruise length changes, which sets the pan distance. The totals are all multiples of 16 pixels (one map block), so every pan covers whole blocks. Each list part note gives its profile and total; the table is 32 bytes, the lists 352 bytes (20 bytes for 12 of them, 28 bytes for the 4 with the longer ramp: $01, $05, $0A, $0F).
; 
; | Index | Cruise | Total | Index | Cruise | Total |
; |-------|--------|-------|-------|--------|-------|
; | $00 | 8 px x 19 | 256 | $08 | 8 px x 29 | 336 |
; | $01 | 12 px x 22 | 512 | $09 | 8 px x 31 | 352 |
; | $02 | 8 px x 17 | 240 | $0A | 12 px x 42 | 752 |
; | $03 | 8 px x 21 | 272 | $0B | 8 px x 35 | 384 |
; | $04 | 8 px x 23 | 288 | $0C | 8 px x 47 | 480 |
; | $05 | 12 px x 86 | 1280 | $0D | 8 px x 49 | 496 |
; | $06 | 8 px x 25 | 304 | $0E | 8 px x 53 | 528 |
; | $07 | 8 px x 27 | 320 | $0F | 12 px x 42 | 784 |
; 
; Not traced: which warp uses which list.
---------------------------------------------

?BANK 01

---------------------------------------------

; 16 pointers to the pan step lists, indexed by the low nibble of byte 6 of an extended warp entry (index x 2 in forced_walk). Format and totals: see the block note.

forced_walk_pan_table [
  &forced_walk_pan_00   ;00
  &forced_walk_pan_01   ;01
  &forced_walk_pan_02   ;02
  &forced_walk_pan_03   ;03
  &forced_walk_pan_04   ;04
  &forced_walk_pan_05   ;05
  &forced_walk_pan_06   ;06
  &forced_walk_pan_07   ;07
  &forced_walk_pan_08   ;08
  &forced_walk_pan_09   ;09
  &forced_walk_pan_0A   ;0A
  &forced_walk_pan_0B   ;0B
  &forced_walk_pan_0C   ;0C
  &forced_walk_pan_0D   ;0D
  &forced_walk_pan_0E   ;0E
  &forced_walk_pan_0F   ;0F
]

---------------------------------------------
; Index $00: 1, 2, 4, 6 px ease-in, 8 px x 19 calls, ease-out 6, 4, 2, 1. Total 256 px.

forced_walk_pan_00 #0301030203040306120803060304030203010000

---------------------------------------------
; Index $01: ease-in 1, 2, 4, 6, 8, 10 px, 12 px x 22 calls, ease-out 10, 8, 6, 4, 2, 1. Total 512 px.

forced_walk_pan_01 #03010302030403060308030A150C030A030803060304030203010000

---------------------------------------------
; Index $02: 1, 2, 4, 6 ease-in, 8 px x 17, ease-out. Total 240 px.

forced_walk_pan_02 #0301030203040306100803060304030203010000

---------------------------------------------
; Index $03: 1, 2, 4, 6 ease-in, 8 px x 21, ease-out. Total 272 px.

forced_walk_pan_03 #0301030203040306140803060304030203010000

---------------------------------------------
; Index $04: 1, 2, 4, 6 ease-in, 8 px x 23, ease-out. Total 288 px.

forced_walk_pan_04 #0301030203040306160803060304030203010000

---------------------------------------------
; Index $05: ease-in 1, 2, 4, 6, 8, 10 px, 12 px x 86 calls, ease-out. Total 1280 px, the longest pan.

forced_walk_pan_05 #03010302030403060308030A550C030A030803060304030203010000

---------------------------------------------
; Index $06: 1, 2, 4, 6 ease-in, 8 px x 25, ease-out. Total 304 px.

forced_walk_pan_06 #0301030203040306180803060304030203010000

---------------------------------------------
; Index $07: 1, 2, 4, 6 ease-in, 8 px x 27, ease-out. Total 320 px.

forced_walk_pan_07 #03010302030403061A0803060304030203010000

---------------------------------------------
; Index $08: 1, 2, 4, 6 ease-in, 8 px x 29, ease-out. Total 336 px.

forced_walk_pan_08 #03010302030403061C0803060304030203010000

---------------------------------------------
; Index $09: 1, 2, 4, 6 ease-in, 8 px x 31, ease-out. Total 352 px.

forced_walk_pan_09 #03010302030403061E0803060304030203010000

---------------------------------------------
; Index $0A: ease-in 1, 2, 4, 6, 8, 10 px, 12 px x 42 calls, ease-out. Total 752 px.

forced_walk_pan_0A #03010302030403060308030A290C030A030803060304030203010000

---------------------------------------------
; Index $0B: 1, 2, 4, 6 ease-in, 8 px x 35, ease-out. Total 384 px.

forced_walk_pan_0B #0301030203040306220803060304030203010000

---------------------------------------------
; Index $0C: 1, 2, 4, 6 ease-in, 8 px x 47, ease-out. Total 480 px.

forced_walk_pan_0C #03010302030403062E0803060304030203010000

---------------------------------------------
; Index $0D: 1, 2, 4, 6 ease-in, 8 px x 49, ease-out. Total 496 px.

forced_walk_pan_0D #0301030203040306300803060304030203010000

---------------------------------------------
; Index $0E: 1, 2, 4, 6 ease-in, 8 px x 53, ease-out. Total 528 px.

forced_walk_pan_0E #0301030203040306340803060304030203010000

---------------------------------------------
; Index $0F: 1, 2, 4, 6 ease-in, 8 px x 6, 10 px x 4, 12 px x 42, then 10 px x 4, 8 px x 6, 6, 4, 2, 1. Total 784 px.

forced_walk_pan_0F #03010302030403060508030A290C030A050803060304030203010000