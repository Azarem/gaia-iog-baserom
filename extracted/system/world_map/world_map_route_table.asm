; World map travel routes — movement step sequences for the trips of WorldMapController (241015–242132, Bank 03).
; 
; Pure data block: a pointer table of 38 entries ($00–$25; $00 aliases $01) to 37 route arrays. The arrays are named route_<id>_<origin>_to_<destination> (route_unused_<id> for $0E, $0F, $10, $23, $24 and $25, which nothing stages). The full trip list and the menu that stages each route are in the world_map_options block note.
; 
; === DATA FORMAT ===
; 
; A step is four bytes, shown by the extraction as `route-step < xDeltaIndex, yDeltaIndex, rotationDeltaIndex, ticks >`:
;   - Byte 0: index into move_chain_table for the X velocity chain ($00CA); 0 = still
;   - Byte 1: index for the Y chain ($00CC); 0 = still
;   - Byte 2: index for the rotation chain ($00BC); 0 = still
;   - Byte 3: tick count n; the step runs n + 1 ticks
; Every array is 4n + 1 bytes: a hidden $FF ends it ($FE, subroutine, is never used). The indices used are 1 (+1 per tick), 2 (-1), $11 (alternating +1, 0) and $12 (alternating -1, 0) for X and Y, and 1 (+1) or 2 (-1) for rotation; a step never mixes rotation with movement, so a route turns the map and runs straight in one of eight directions.
---------------------------------------------

---------------------------------------------

world_map_route_table [
  &route_01_south_cape_to_edward_castle   ;00
  &route_01_south_cape_to_edward_castle   ;01
  &route_02_edward_castle_to_south_cape   ;02
  &route_03_south_cape_to_itory   ;03
  &route_04_itory_to_south_cape   ;04
  &route_05_itory_to_moon_tribe_camp   ;05
  &route_06_moon_tribe_camp_to_inca_ruins   ;06
  &route_07_itory_to_inca_ruins   ;07
  &route_08_inca_ruins_to_itory   ;08
  &route_09_diamond_coast_to_freejia   ;09
  &route_0A_freejia_to_diamond_mine   ;0A
  &route_0B_diamond_mine_to_freejia   ;0B
  &route_0C_freejia_hotel_to_neil_cottage   ;0C
  &route_0D_neil_cottage_to_nazca_painting   ;0D
  &route_unused_0E   ;0E
  &route_unused_0F   ;0F
  &route_unused_10   ;10
  &route_11_angel_village_to_watermia   ;11
  &route_12_watermia_to_angel_village   ;12
  &route_13_watermia_to_great_wall   ;13
  &route_14_great_wall_to_watermia   ;14
  &route_15_watermia_to_euro   ;15
  &route_16_euro_to_watermia   ;16
  &route_17_euro_to_mt_temple   ;17
  &route_18_mt_temple_to_euro   ;18
  &route_19_euro_to_natives_village   ;19
  &route_1A_natives_village_to_euro   ;1A
  &route_1B_natives_village_to_angkor_wat   ;1B
  &route_1C_angkor_wat_to_natives_village   ;1C
  &route_1D_natives_village_to_dao   ;1D
  &route_1E_dao_to_pyramid   ;1E
  &route_1F_pyramid_to_dao   ;1F
  &route_20_dao_to_natives_village   ;20
  &route_21_dao_to_over_babel   ;21
  &route_22_watermia_to_south_cape   ;22
  &route_unused_23   ;23
  &route_unused_24   ;24
  &route_unused_25   ;25
]

route_01_south_cape_to_edward_castle [
  route-step < #00, #02, #00, #30 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #02, #00, #30 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_02_edward_castle_to_south_cape [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #30 >   ;01
  route-step < #00, #00, #01, #80 >   ;02
  route-step < #00, #01, #00, #70 >   ;03
  route-step < #00, #00, #02, #80 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
]

route_03_south_cape_to_itory [
  route-step < #00, #02, #00, #A0 >   ;00
  route-step < #00, #00, #01, #20 >   ;01
  route-step < #12, #02, #00, #20 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #00, #02, #00, #30 >   ;04
]

route_04_itory_to_south_cape [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #10 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #E0 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #7B >   ;06
]

route_05_itory_to_moon_tribe_camp [
  route-step < #00, #02, #00, #20 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_06_moon_tribe_camp_to_inca_ruins [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #10 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #01, #00, #30 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #01, #00, #00, #70 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
  route-step < #00, #02, #00, #10 >   ;08
]

route_07_itory_to_inca_ruins [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #20 >   ;01
  route-step < #00, #00, #02, #40 >   ;02
  route-step < #01, #00, #00, #50 >   ;03
  route-step < #00, #00, #01, #80 >   ;04
  route-step < #00, #02, #00, #10 >   ;05
]

route_08_inca_ruins_to_itory [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #20 >   ;01
  route-step < #02, #11, #00, #40 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #02, #00, #00, #30 >   ;04
  route-step < #00, #00, #01, #80 >   ;05
  route-step < #00, #01, #00, #10 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_09_diamond_coast_to_freejia [
  route-step < #00, #02, #00, #80 >
]

route_0A_freejia_to_diamond_mine [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #30 >   ;01
  route-step < #00, #00, #02, #20 >   ;02
  route-step < #01, #11, #00, #A0 >   ;03
  route-step < #00, #00, #02, #20 >   ;04
  route-step < #01, #01, #00, #10 >   ;05
  route-step < #00, #00, #01, #C0 >   ;06
]

route_0B_diamond_mine_to_freejia [
  route-step < #00, #00, #01, #40 >   ;00
  route-step < #02, #02, #00, #10 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #02, #12, #00, #A0 >   ;03
  route-step < #00, #00, #01, #20 >   ;04
  route-step < #02, #00, #00, #30 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_0C_freejia_hotel_to_neil_cottage [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #00, #02, #00, #50 >   ;03
]

route_0D_neil_cottage_to_nazca_painting [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #20 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #00, #00, #30 >   ;04
  route-step < #00, #00, #02, #20 >   ;05
  route-step < #01, #11, #00, #40 >   ;06
  route-step < #00, #00, #01, #20 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_unused_0E [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #01, #00, #50 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #00, #00, #60 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #02, #00, #10 >   ;06
]

route_unused_0F [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #70 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #01, #02, #00, #40 >   ;03
  route-step < #00, #00, #01, #40 >   ;04
]

route_unused_10 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #60 >   ;01
  route-step < #11, #01, #00, #A0 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #00, #01, #00, #40 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_11_angel_village_to_watermia [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #20 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #01, #00, #30 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #02, #00, #00, #10 >   ;06
  route-step < #00, #00, #02, #40 >   ;07
  route-step < #02, #02, #00, #20 >   ;08
  route-step < #00, #00, #01, #40 >   ;09
  route-step < #02, #00, #00, #50 >   ;0A
  route-step < #00, #00, #01, #80 >   ;0B
  route-step < #00, #01, #00, #10 >   ;0C
  route-step < #00, #00, #01, #80 >   ;0D
  route-step < #00, #00, #01, #80 >   ;0E
]

route_12_watermia_to_angel_village [
  route-step < #00, #02, #00, #10 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #01, #00, #00, #60 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #02, #00, #30 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #01, #00, #00, #20 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_13_watermia_to_great_wall [
  route-step < #00, #02, #00, #50 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
]

route_14_great_wall_to_watermia [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #50 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_15_watermia_to_euro [
  route-step < #00, #00, #01, #40 >   ;00
  route-step < #02, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #02, #12, #00, #80 >   ;03
  route-step < #00, #00, #01, #20 >   ;04
  route-step < #02, #00, #00, #60 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
  route-step < #00, #02, #00, #10 >   ;07
]

route_16_euro_to_watermia [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #40 >   ;01
  route-step < #00, #00, #02, #20 >   ;02
  route-step < #01, #11, #00, #A0 >   ;03
  route-step < #00, #00, #02, #20 >   ;04
  route-step < #01, #01, #00, #20 >   ;05
  route-step < #00, #00, #01, #40 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_17_euro_to_mt_temple [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #30 >   ;01
  route-step < #01, #02, #00, #08 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #00, #02, #00, #40 >   ;04
  route-step < #00, #02, #00, #08 >   ;05
]

route_18_mt_temple_to_euro [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #40 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #01, #00, #40 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_19_euro_to_natives_village [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #02, #01, #00, #70 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #02, #00, #00, #20 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_1A_natives_village_to_euro [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #01, #02, #00, #70 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #01, #00, #00, #20 >   ;05
  route-step < #00, #00, #01, #80 >   ;06
]

route_1B_natives_village_to_angkor_wat [
  route-step < #00, #00, #02, #20 >   ;00
  route-step < #11, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #00, #02, #00, #30 >   ;03
]

route_1C_angkor_wat_to_natives_village [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #50 >   ;02
  route-step < #00, #00, #02, #80 >   ;03
  route-step < #02, #00, #00, #10 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
]

route_1D_natives_village_to_dao [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #40 >   ;01
  route-step < #00, #00, #02, #40 >   ;02
  route-step < #02, #02, #00, #50 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #00, #02, #00, #40 >   ;05
]

route_1E_dao_to_pyramid [
  route-step < #00, #02, #00, #30 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #20 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_1F_pyramid_to_dao [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #60 >   ;02
  route-step < #00, #00, #01, #80 >   ;03
  route-step < #01, #00, #00, #20 >   ;04
  route-step < #00, #00, #01, #80 >   ;05
]

route_20_dao_to_natives_village [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #80 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #01, #00, #10 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #01, #00, #00, #80 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_21_dao_to_over_babel [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #60 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #00, #00, #90 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #01, #01, #00, #80 >   ;06
  route-step < #00, #00, #01, #40 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_22_watermia_to_south_cape [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #A0 >   ;02
  route-step < #00, #01, #00, #C0 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #02, #01, #00, #A0 >   ;05
  route-step < #00, #00, #02, #40 >   ;06
  route-step < #02, #00, #00, #A0 >   ;07
  route-step < #02, #00, #00, #C0 >   ;08
  route-step < #00, #00, #02, #80 >   ;09
]

route_unused_23 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #A0 >   ;01
  route-step < #01, #00, #00, #C0 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #02, #00, #A0 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #00, #02, #00, #A0 >   ;06
  route-step < #00, #02, #00, #C0 >   ;07
]

route_unused_24 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #80 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #A0 >   ;04
  route-step < #00, #01, #00, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
  route-step < #00, #00, #02, #80 >   ;07
]

route_unused_25 [
  route-step < #00, #02, #00, #A0 >   ;00
  route-step < #00, #02, #00, #80 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #02, #02, #00, #80 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
]