; Pre-computed movement delta curves. 85 pointers to delta-node linked lists encoding velocity curves (acceleration ramps, arcs, linear motion). Used by world map travel, forced walk, hit stagger, and camera systems. Largest table in bank 1 (~5 KB).
---------------------------------------------

?BANK 01

---------------------------------------------

; Largest table in bank 1 (~5 KB). Contains 85 pointers ($00–$54) to pre-computed movement delta sequences as delta-node linked lists. Each delta-node: { Word value, &delta-node next }. Value = signed 16-bit per-frame movement delta. Self-referencing next = hold constant. Simple entries ($00–$11) are single constants; complex entries ($12+) trace velocity curves (acceleration ramps, arcs, deceleration). Used by WorldMapController (travel animation), forced_walk/hit_stagger (knockback), and camera scrolling.

movement_delta_table [
  &delta_node_01B130   ;00
  &delta_node_01B134   ;01
  &delta_node_01B138   ;02
  &delta_node_01B13C   ;03
  &delta_node_01B140   ;04
  &delta_node_01B144   ;05
  &delta_node_01B148   ;06
  &delta_node_01B14C   ;07
  &delta_node_01B150   ;08
  &delta_node_01B154   ;09
  &delta_node_01B158   ;0A
  &delta_node_01B15C   ;0B
  &delta_node_01B160   ;0C
  &delta_node_01B164   ;0D
  &delta_node_01B168   ;0E
  &delta_node_01B16C   ;0F
  &delta_node_01B170   ;10
  &delta_node_01B174   ;11
  &delta_node_01B17C   ;12
  &delta_node_01B184   ;13
  &delta_node_01B194   ;14
  &delta_node_01B1A4   ;15
  &delta_node_01B1E8   ;16
  &delta_node_01B1F8   ;17
  &delta_node_01B208   ;18
  &delta_node_01B288   ;19
  &delta_node_01B2CC   ;1A
  &delta_node_01B328   ;1B
  &delta_node_01B358   ;1C
  &delta_node_01B3B4   ;1D
  &delta_node_01B3CC   ;1E
  &delta_node_01B3E4   ;1F
  &delta_node_01B3E8   ;20
  &delta_node_01B3EC   ;21
  &delta_node_01B4D0   ;22
  &delta_node_01B50C   ;23
  &delta_node_01B548   ;24
  &delta_node_01B568   ;25
  &delta_node_01B588   ;26
  &delta_node_01B608   ;27
  &delta_node_01B668   ;28
  &delta_node_01B6C8   ;29
  &delta_node_01B6F0   ;2A
  &delta_node_01B718   ;2B
  &delta_node_01B740   ;2C
  &delta_node_01B768   ;2D
  &delta_node_01B7BC   ;2E
  &delta_node_01B810   ;2F
  &delta_node_01B864   ;30
  &delta_node_01B8B8   ;31
  &delta_node_01B8F8   ;32
  &delta_node_01B938   ;33
  &delta_node_01B978   ;34
  &delta_node_01B9B8   ;35
  &delta_node_01B9F8   ;36
  &delta_node_01BA64   ;37
  &delta_node_01BA68   ;38
  &delta_node_01BAA8   ;39
  &delta_node_01BAE8   ;3A
  &delta_node_01BB28   ;3B
  &delta_node_01BB78   ;3C
  &delta_node_01BB88   ;3D
  &delta_node_01BC1C   ;3E
  &delta_node_01BC78   ;3F
  &delta_node_01BC84   ;40
  &delta_node_01BCC8   ;41
  &delta_node_01BD0C   ;42
  &delta_node_01BD50   ;43
  &delta_node_01BD94   ;44
  &delta_node_01BDD4   ;45
  &delta_node_01BE00   ;46
  &delta_node_01BE78   ;47
  &delta_node_01BE9C   ;48
  &delta_node_01BEF0   ;49
  &delta_node_01BF44   ;4A
  &delta_node_01BF88   ;4B
  &delta_node_01BFE0   ;4C
  &delta_node_01C08C   ;4D
  &delta_node_01C110   ;4E
  &delta_node_01C194   ;4F
  &delta_node_01C1F8   ;50
  &delta_node_01C25C   ;51
  &delta_node_01C270   ;52
  &delta_node_01C284   ;53
  &delta_node_01C304   ;54
]

delta_node_01B130 [
  delta-node < #$0000, #$0000 >
]

delta_node_01B134 [
  delta-node < #$0001, &delta_node_01B134 >
]

delta_node_01B138 [
  delta-node < #$FFFF, &delta_node_01B138 >
]

delta_node_01B13C [
  delta-node < #$0002, &delta_node_01B13C >
]

delta_node_01B140 [
  delta-node < #$FFFE, &delta_node_01B140 >
]

delta_node_01B144 [
  delta-node < #$0003, &delta_node_01B144 >
]

delta_node_01B148 [
  delta-node < #$FFFD, &delta_node_01B148 >
]

delta_node_01B14C [
  delta-node < #$0004, &delta_node_01B14C >
]

delta_node_01B150 [
  delta-node < #$FFFC, &delta_node_01B150 >
]

delta_node_01B154 [
  delta-node < #$0005, &delta_node_01B154 >
]

delta_node_01B158 [
  delta-node < #$FFFB, &delta_node_01B158 >
]

delta_node_01B15C [
  delta-node < #$0006, &delta_node_01B15C >
]

delta_node_01B160 [
  delta-node < #$FFFA, &delta_node_01B160 >
]

delta_node_01B164 [
  delta-node < #$0007, &delta_node_01B164 >
]

delta_node_01B168 [
  delta-node < #$FFF9, &delta_node_01B168 >
]

delta_node_01B16C [
  delta-node < #$0008, &delta_node_01B16C >
]

delta_node_01B170 [
  delta-node < #$FFF8, &delta_node_01B170 >
]

delta_node_01B174 [
  delta-node < #$0001, &delta_node_01B178 >
]

delta_node_01B178 [
  delta-node < #$0000, &delta_node_01B174 >
]

delta_node_01B17C [
  delta-node < #$FFFF, &delta_node_01B180 >
]

delta_node_01B180 [
  delta-node < #$0000, &delta_node_01B17C >
]

delta_node_01B184 [
  delta-node < #$0001, &delta_node_01B188 >
]

delta_node_01B188 [
  delta-node < #$0000, &delta_node_01B18C >
]

delta_node_01B18C [
  delta-node < #$0000, &delta_node_01B190 >
]

delta_node_01B190 [
  delta-node < #$0000, &delta_node_01B184 >
]

delta_node_01B194 [
  delta-node < #$FFFF, &delta_node_01B198 >
]

delta_node_01B198 [
  delta-node < #$0000, &delta_node_01B19C >
]

delta_node_01B19C [
  delta-node < #$0000, &delta_node_01B1A0 >
]

delta_node_01B1A0 [
  delta-node < #$0000, &delta_node_01B194 >
]

delta_node_01B1A4 [
  delta-node < #$FFFC, &delta_node_01B1A8 >
]

delta_node_01B1A8 [
  delta-node < #$FFFC, &delta_node_01B1AC >
]

delta_node_01B1AC [
  delta-node < #$FFFE, &delta_node_01B1B0 >
]

delta_node_01B1B0 [
  delta-node < #$FFFE, &delta_node_01B1B4 >
]

delta_node_01B1B4 [
  delta-node < #$FFFF, &delta_node_01B1B8 >
]

delta_node_01B1B8 [
  delta-node < #$FFFF, &delta_node_01B1BC >
]

delta_node_01B1BC [
  delta-node < #$0000, &delta_node_01B1C0 >
]

delta_node_01B1C0 [
  delta-node < #$0000, &delta_node_01B1C4 >
]

delta_node_01B1C4 [
  delta-node < #$0000, &delta_node_01B1C8 >
]

delta_node_01B1C8 [
  delta-node < #$0000, &delta_node_01B1CC >
]

delta_node_01B1CC [
  delta-node < #$0001, &delta_node_01B1D0 >
]

delta_node_01B1D0 [
  delta-node < #$0001, &delta_node_01B1D4 >
]

delta_node_01B1D4 [
  delta-node < #$0002, &delta_node_01B1D8 >
]

delta_node_01B1D8 [
  delta-node < #$0002, &delta_node_01B1DC >
]

delta_node_01B1DC [
  delta-node < #$0004, &delta_node_01B1E0 >
]

delta_node_01B1E0 [
  delta-node < #$0004, &delta_node_01B1E4 >
]

delta_node_01B1E4 [
  delta-node < #$0000, &delta_node_01B1E4 >
]

delta_node_01B1E8 [
  delta-node < #$0001, &delta_node_01B1EC >
]

delta_node_01B1EC [
  delta-node < #$0001, &delta_node_01B1F0 >
]

delta_node_01B1F0 [
  delta-node < #$0001, &delta_node_01B1F4 >
]

delta_node_01B1F4 [
  delta-node < #$0001, &delta_node_01B1E8 >
]

delta_node_01B1F8 [
  delta-node < #$FFFF, &delta_node_01B1FC >
]

delta_node_01B1FC [
  delta-node < #$FFFF, &delta_node_01B200 >
]

delta_node_01B200 [
  delta-node < #$FFFF, &delta_node_01B204 >
]

delta_node_01B204 [
  delta-node < #$FFFF, &delta_node_01B1F8 >
]

delta_node_01B208 [
  delta-node < #$0000, &delta_node_01B20C >
]

delta_node_01B20C [
  delta-node < #$0000, &delta_node_01B210 >
]

delta_node_01B210 [
  delta-node < #$0000, &delta_node_01B214 >
]

delta_node_01B214 [
  delta-node < #$0000, &delta_node_01B218 >
]

delta_node_01B218 [
  delta-node < #$0000, &delta_node_01B21C >
]

delta_node_01B21C [
  delta-node < #$0000, &delta_node_01B220 >
]

delta_node_01B220 [
  delta-node < #$0000, &delta_node_01B224 >
]

delta_node_01B224 [
  delta-node < #$0000, &delta_node_01B228 >
]

delta_node_01B228 [
  delta-node < #$0000, &delta_node_01B22C >
]

delta_node_01B22C [
  delta-node < #$0000, &delta_node_01B230 >
]

delta_node_01B230 [
  delta-node < #$FFFE, &delta_node_01B234 >
]

delta_node_01B234 [
  delta-node < #$FFFE, &delta_node_01B238 >
]

delta_node_01B238 [
  delta-node < #$FFFE, &delta_node_01B23C >
]

delta_node_01B23C [
  delta-node < #$FFFF, &delta_node_01B240 >
]

delta_node_01B240 [
  delta-node < #$FFFF, &delta_node_01B244 >
]

delta_node_01B244 [
  delta-node < #$FFFF, &delta_node_01B248 >
]

delta_node_01B248 [
  delta-node < #$FFFF, &delta_node_01B24C >
]

delta_node_01B24C [
  delta-node < #$0000, &delta_node_01B250 >
]

delta_node_01B250 [
  delta-node < #$0000, &delta_node_01B254 >
]

delta_node_01B254 [
  delta-node < #$0000, &delta_node_01B258 >
]

delta_node_01B258 [
  delta-node < #$0000, &delta_node_01B25C >
]

delta_node_01B25C [
  delta-node < #$0000, &delta_node_01B260 >
]

delta_node_01B260 [
  delta-node < #$0000, &delta_node_01B264 >
]

delta_node_01B264 [
  delta-node < #$0000, &delta_node_01B268 >
]

delta_node_01B268 [
  delta-node < #$0000, &delta_node_01B26C >
]

delta_node_01B26C [
  delta-node < #$0001, &delta_node_01B270 >
]

delta_node_01B270 [
  delta-node < #$0001, &delta_node_01B274 >
]

delta_node_01B274 [
  delta-node < #$0001, &delta_node_01B278 >
]

delta_node_01B278 [
  delta-node < #$0001, &delta_node_01B27C >
]

delta_node_01B27C [
  delta-node < #$0002, &delta_node_01B280 >
]

delta_node_01B280 [
  delta-node < #$0002, &delta_node_01B284 >
]

delta_node_01B284 [
  delta-node < #$0002, &delta_node_01B208 >
]

delta_node_01B288 [
  delta-node < #$0000, &delta_node_01B28C >
]

delta_node_01B28C [
  delta-node < #$0000, &delta_node_01B290 >
]

delta_node_01B290 [
  delta-node < #$0000, &delta_node_01B294 >
]

delta_node_01B294 [
  delta-node < #$0000, &delta_node_01B298 >
]

delta_node_01B298 [
  delta-node < #$0001, &delta_node_01B29C >
]

delta_node_01B29C [
  delta-node < #$0000, &delta_node_01B2A0 >
]

delta_node_01B2A0 [
  delta-node < #$0000, &delta_node_01B2A4 >
]

delta_node_01B2A4 [
  delta-node < #$0001, &delta_node_01B2A8 >
]

delta_node_01B2A8 [
  delta-node < #$0000, &delta_node_01B2AC >
]

delta_node_01B2AC [
  delta-node < #$0000, &delta_node_01B2B0 >
]

delta_node_01B2B0 [
  delta-node < #$0002, &delta_node_01B2B4 >
]

delta_node_01B2B4 [
  delta-node < #$0000, &delta_node_01B2B8 >
]

delta_node_01B2B8 [
  delta-node < #$0000, &delta_node_01B2BC >
]

delta_node_01B2BC [
  delta-node < #$0001, &delta_node_01B2C0 >
]

delta_node_01B2C0 [
  delta-node < #$0001, &delta_node_01B2C4 >
]

delta_node_01B2C4 [
  delta-node < #$0001, &delta_node_01B2C8 >
]

delta_node_01B2C8 [
  delta-node < #$0001, &delta_node_01B2B4 >
]

delta_node_01B2CC [
  delta-node < #$0001, &delta_node_01B2D0 >
]

delta_node_01B2D0 [
  delta-node < #$0001, &delta_node_01B2D4 >
]

delta_node_01B2D4 [
  delta-node < #$0001, &delta_node_01B2D8 >
]

delta_node_01B2D8 [
  delta-node < #$0001, &delta_node_01B2DC >
]

delta_node_01B2DC [
  delta-node < #$0000, &delta_node_01B2E0 >
]

delta_node_01B2E0 [
  delta-node < #$0000, &delta_node_01B2E4 >
]

delta_node_01B2E4 [
  delta-node < #$0001, &delta_node_01B2E8 >
]

delta_node_01B2E8 [
  delta-node < #$0001, &delta_node_01B2EC >
]

delta_node_01B2EC [
  delta-node < #$0001, &delta_node_01B2F0 >
]

delta_node_01B2F0 [
  delta-node < #$0001, &delta_node_01B2F4 >
]

delta_node_01B2F4 [
  delta-node < #$0000, &delta_node_01B2F8 >
]

delta_node_01B2F8 [
  delta-node < #$0000, &delta_node_01B2FC >
]

delta_node_01B2FC [
  delta-node < #$0001, &delta_node_01B300 >
]

delta_node_01B300 [
  delta-node < #$0001, &delta_node_01B304 >
]

delta_node_01B304 [
  delta-node < #$0001, &delta_node_01B308 >
]

delta_node_01B308 [
  delta-node < #$0001, &delta_node_01B30C >
]

delta_node_01B30C [
  delta-node < #$0000, &delta_node_01B310 >
]

delta_node_01B310 [
  delta-node < #$0000, &delta_node_01B314 >
]

delta_node_01B314 [
  delta-node < #$0001, &delta_node_01B318 >
]

delta_node_01B318 [
  delta-node < #$0001, &delta_node_01B31C >
]

delta_node_01B31C [
  delta-node < #$0001, &delta_node_01B320 >
]

delta_node_01B320 [
  delta-node < #$0001, &delta_node_01B324 >
]

delta_node_01B324 [
  delta-node < #$0000, &delta_node_01B324 >
]

delta_node_01B328 [
  delta-node < #$0000, &delta_node_01B32C >
]

delta_node_01B32C [
  delta-node < #$0000, &delta_node_01B330 >
]

delta_node_01B330 [
  delta-node < #$0000, &delta_node_01B334 >
]

delta_node_01B334 [
  delta-node < #$0000, &delta_node_01B338 >
]

delta_node_01B338 [
  delta-node < #$0000, &delta_node_01B33C >
]

delta_node_01B33C [
  delta-node < #$0000, &delta_node_01B340 >
]

delta_node_01B340 [
  delta-node < #$0000, &delta_node_01B344 >
]

delta_node_01B344 [
  delta-node < #$0000, &delta_node_01B348 >
]

delta_node_01B348 [
  delta-node < #$FFFF, &delta_node_01B34C >
]

delta_node_01B34C [
  delta-node < #$FFFF, &delta_node_01B350 >
]

delta_node_01B350 [
  delta-node < #$FFFF, &delta_node_01B354 >
]

delta_node_01B354 [
  delta-node < #$FFFF, &delta_node_01B340 >
]

delta_node_01B358 [
  delta-node < #$FFFF, &delta_node_01B35C >
]

delta_node_01B35C [
  delta-node < #$FFFF, &delta_node_01B360 >
]

delta_node_01B360 [
  delta-node < #$FFFF, &delta_node_01B364 >
]

delta_node_01B364 [
  delta-node < #$FFFF, &delta_node_01B368 >
]

delta_node_01B368 [
  delta-node < #$0000, &delta_node_01B36C >
]

delta_node_01B36C [
  delta-node < #$0000, &delta_node_01B370 >
]

delta_node_01B370 [
  delta-node < #$FFFF, &delta_node_01B374 >
]

delta_node_01B374 [
  delta-node < #$FFFF, &delta_node_01B378 >
]

delta_node_01B378 [
  delta-node < #$FFFF, &delta_node_01B37C >
]

delta_node_01B37C [
  delta-node < #$FFFF, &delta_node_01B380 >
]

delta_node_01B380 [
  delta-node < #$0000, &delta_node_01B384 >
]

delta_node_01B384 [
  delta-node < #$0000, &delta_node_01B388 >
]

delta_node_01B388 [
  delta-node < #$FFFF, &delta_node_01B38C >
]

delta_node_01B38C [
  delta-node < #$FFFF, &delta_node_01B390 >
]

delta_node_01B390 [
  delta-node < #$FFFF, &delta_node_01B394 >
]

delta_node_01B394 [
  delta-node < #$FFFF, &delta_node_01B398 >
]

delta_node_01B398 [
  delta-node < #$0000, &delta_node_01B39C >
]

delta_node_01B39C [
  delta-node < #$0000, &delta_node_01B3A0 >
]

delta_node_01B3A0 [
  delta-node < #$FFFF, &delta_node_01B3A4 >
]

delta_node_01B3A4 [
  delta-node < #$FFFF, &delta_node_01B3A8 >
]

delta_node_01B3A8 [
  delta-node < #$FFFF, &delta_node_01B3AC >
]

delta_node_01B3AC [
  delta-node < #$FFFF, &delta_node_01B3B0 >
]

delta_node_01B3B0 [
  delta-node < #$0000, &delta_node_01B3B0 >
]

delta_node_01B3B4 [
  delta-node < #$0002, &delta_node_01B3B8 >
]

delta_node_01B3B8 [
  delta-node < #$0002, &delta_node_01B3BC >
]

delta_node_01B3BC [
  delta-node < #$0002, &delta_node_01B3C0 >
]

delta_node_01B3C0 [
  delta-node < #$0002, &delta_node_01B3C4 >
]

delta_node_01B3C4 [
  delta-node < #$0000, &delta_node_01B3C8 >
]

delta_node_01B3C8 [
  delta-node < #$0000, &delta_node_01B3B4 >
]

delta_node_01B3CC [
  delta-node < #$FFFE, &delta_node_01B3D0 >
]

delta_node_01B3D0 [
  delta-node < #$FFFE, &delta_node_01B3D4 >
]

delta_node_01B3D4 [
  delta-node < #$FFFE, &delta_node_01B3D8 >
]

delta_node_01B3D8 [
  delta-node < #$FFFE, &delta_node_01B3DC >
]

delta_node_01B3DC [
  delta-node < #$0000, &delta_node_01B3E0 >
]

delta_node_01B3E0 [
  delta-node < #$0000, &delta_node_01B3CC >
]

delta_node_01B3E4 [
  delta-node < #$0000, &delta_node_01B3E4 >
]

delta_node_01B3E8 [
  delta-node < #$0000, &delta_node_01B3E8 >
]

delta_node_01B3EC [
  delta-node < #$FFFE, &delta_node_01B3F0 >
]

delta_node_01B3F0 [
  delta-node < #$FFFE, &delta_node_01B3F4 >
]

delta_node_01B3F4 [
  delta-node < #$FFFF, &delta_node_01B3F8 >
]

delta_node_01B3F8 [
  delta-node < #$FFFF, &delta_node_01B3FC >
]

delta_node_01B3FC [
  delta-node < #$0000, &delta_node_01B400 >
]

delta_node_01B400 [
  delta-node < #$0000, &delta_node_01B404 >
]

delta_node_01B404 [
  delta-node < #$0000, &delta_node_01B408 >
]

delta_node_01B408 [
  delta-node < #$0000, &delta_node_01B40C >
]

delta_node_01B40C [
  delta-node < #$0001, &delta_node_01B410 >
]

delta_node_01B410 [
  delta-node < #$0001, &delta_node_01B414 >
]

delta_node_01B414 [
  delta-node < #$0001, &delta_node_01B418 >
]

delta_node_01B418 [
  delta-node < #$0001, &delta_node_01B41C >
]

delta_node_01B41C [
  delta-node < #$0001, &delta_node_01B420 >
]

delta_node_01B420 [
  delta-node < #$0001, &delta_node_01B424 >
]

delta_node_01B424 [
  delta-node < #$0001, &delta_node_01B428 >
]

delta_node_01B428 [
  delta-node < #$0001, &delta_node_01B42C >
]

delta_node_01B42C [
  delta-node < #$0002, &delta_node_01B430 >
]

delta_node_01B430 [
  delta-node < #$0002, &delta_node_01B434 >
]

delta_node_01B434 [
  delta-node < #$0002, &delta_node_01B438 >
]

delta_node_01B438 [
  delta-node < #$0002, &delta_node_01B43C >
]

delta_node_01B43C [
  delta-node < #$0003, &delta_node_01B440 >
]

delta_node_01B440 [
  delta-node < #$0003, &delta_node_01B444 >
]

delta_node_01B444 [
  delta-node < #$0003, &delta_node_01B448 >
]

delta_node_01B448 [
  delta-node < #$0003, &delta_node_01B44C >
]

delta_node_01B44C [
  delta-node < #$0004, &delta_node_01B450 >
]

delta_node_01B450 [
  delta-node < #$0004, &delta_node_01B454 >
]

delta_node_01B454 [
  delta-node < #$0004, &delta_node_01B458 >
]

delta_node_01B458 [
  delta-node < #$0004, &delta_node_01B45C >
]

delta_node_01B45C [
  delta-node < #$FFFE, &delta_node_01B460 >
]

delta_node_01B460 [
  delta-node < #$FFFE, &delta_node_01B464 >
]

delta_node_01B464 [
  delta-node < #$FFFF, &delta_node_01B468 >
]

delta_node_01B468 [
  delta-node < #$FFFF, &delta_node_01B46C >
]

delta_node_01B46C [
  delta-node < #$0000, &delta_node_01B470 >
]

delta_node_01B470 [
  delta-node < #$0000, &delta_node_01B474 >
]

delta_node_01B474 [
  delta-node < #$0000, &delta_node_01B478 >
]

delta_node_01B478 [
  delta-node < #$0000, &delta_node_01B47C >
]

delta_node_01B47C [
  delta-node < #$0001, &delta_node_01B480 >
]

delta_node_01B480 [
  delta-node < #$0001, &delta_node_01B484 >
]

delta_node_01B484 [
  delta-node < #$0001, &delta_node_01B488 >
]

delta_node_01B488 [
  delta-node < #$0001, &delta_node_01B48C >
]

delta_node_01B48C [
  delta-node < #$0002, &delta_node_01B490 >
]

delta_node_01B490 [
  delta-node < #$0002, &delta_node_01B494 >
]

delta_node_01B494 [
  delta-node < #$0002, &delta_node_01B498 >
]

delta_node_01B498 [
  delta-node < #$0002, &delta_node_01B49C >
]

delta_node_01B49C [
  delta-node < #$0004, &delta_node_01B4A0 >
]

delta_node_01B4A0 [
  delta-node < #$0004, &delta_node_01B4A4 >
]

delta_node_01B4A4 [
  delta-node < #$0004, &delta_node_01B4A8 >
]

delta_node_01B4A8 [
  delta-node < #$0004, &delta_node_01B4AC >
]

delta_node_01B4AC [
  delta-node < #$FFFF, &delta_node_01B4B0 >
]

delta_node_01B4B0 [
  delta-node < #$FFFF, &delta_node_01B4B4 >
]

delta_node_01B4B4 [
  delta-node < #$0000, &delta_node_01B4B8 >
]

delta_node_01B4B8 [
  delta-node < #$0000, &delta_node_01B4BC >
]

delta_node_01B4BC [
  delta-node < #$0001, &delta_node_01B4C0 >
]

delta_node_01B4C0 [
  delta-node < #$0001, &delta_node_01B4C4 >
]

delta_node_01B4C4 [
  delta-node < #$0002, &delta_node_01B4C8 >
]

delta_node_01B4C8 [
  delta-node < #$0002, &delta_node_01B4CC >
]

delta_node_01B4CC [
  delta-node < #$0000, &delta_node_01B4CC >
]

delta_node_01B4D0 [
  delta-node < #$0004, &delta_node_01B4D4 >
]

delta_node_01B4D4 [
  delta-node < #$0004, &delta_node_01B4D8 >
]

delta_node_01B4D8 [
  delta-node < #$0005, &delta_node_01B4DC >
]

delta_node_01B4DC [
  delta-node < #$0005, &delta_node_01B4E0 >
]

delta_node_01B4E0 [
  delta-node < #$0005, &delta_node_01B4E4 >
]

delta_node_01B4E4 [
  delta-node < #$0005, &delta_node_01B4E8 >
]

delta_node_01B4E8 [
  delta-node < #$0004, &delta_node_01B4EC >
]

delta_node_01B4EC [
  delta-node < #$0004, &delta_node_01B4F0 >
]

delta_node_01B4F0 [
  delta-node < #$0003, &delta_node_01B4F4 >
]

delta_node_01B4F4 [
  delta-node < #$0003, &delta_node_01B4F8 >
]

delta_node_01B4F8 [
  delta-node < #$0002, &delta_node_01B4FC >
]

delta_node_01B4FC [
  delta-node < #$0002, &delta_node_01B500 >
]

delta_node_01B500 [
  delta-node < #$0001, &delta_node_01B504 >
]

delta_node_01B504 [
  delta-node < #$0001, &delta_node_01B508 >
]

delta_node_01B508 [
  delta-node < #$0000, &delta_node_01B508 >
]

delta_node_01B50C [
  delta-node < #$0003, &delta_node_01B510 >
]

delta_node_01B510 [
  delta-node < #$0003, &delta_node_01B514 >
]

delta_node_01B514 [
  delta-node < #$0004, &delta_node_01B518 >
]

delta_node_01B518 [
  delta-node < #$0004, &delta_node_01B51C >
]

delta_node_01B51C [
  delta-node < #$0003, &delta_node_01B520 >
]

delta_node_01B520 [
  delta-node < #$0003, &delta_node_01B524 >
]

delta_node_01B524 [
  delta-node < #$0002, &delta_node_01B528 >
]

delta_node_01B528 [
  delta-node < #$0002, &delta_node_01B52C >
]

delta_node_01B52C [
  delta-node < #$0002, &delta_node_01B530 >
]

delta_node_01B530 [
  delta-node < #$0002, &delta_node_01B534 >
]

delta_node_01B534 [
  delta-node < #$0001, &delta_node_01B538 >
]

delta_node_01B538 [
  delta-node < #$0001, &delta_node_01B53C >
]

delta_node_01B53C [
  delta-node < #$0001, &delta_node_01B540 >
]

delta_node_01B540 [
  delta-node < #$0001, &delta_node_01B544 >
]

delta_node_01B544 [
  delta-node < #$0000, &delta_node_01B544 >
]

delta_node_01B548 [
  delta-node < #$0000, &delta_node_01B54C >
]

delta_node_01B54C [
  delta-node < #$0000, &delta_node_01B550 >
]

delta_node_01B550 [
  delta-node < #$0000, &delta_node_01B554 >
]

delta_node_01B554 [
  delta-node < #$0001, &delta_node_01B558 >
]

delta_node_01B558 [
  delta-node < #$0001, &delta_node_01B55C >
]

delta_node_01B55C [
  delta-node < #$0001, &delta_node_01B560 >
]

delta_node_01B560 [
  delta-node < #$0001, &delta_node_01B564 >
]

delta_node_01B564 [
  delta-node < #$0001, &delta_node_01B548 >
]

delta_node_01B568 [
  delta-node < #$0000, &delta_node_01B56C >
]

delta_node_01B56C [
  delta-node < #$0000, &delta_node_01B570 >
]

delta_node_01B570 [
  delta-node < #$0000, &delta_node_01B574 >
]

delta_node_01B574 [
  delta-node < #$FFFF, &delta_node_01B578 >
]

delta_node_01B578 [
  delta-node < #$FFFF, &delta_node_01B57C >
]

delta_node_01B57C [
  delta-node < #$FFFF, &delta_node_01B580 >
]

delta_node_01B580 [
  delta-node < #$FFFF, &delta_node_01B584 >
]

delta_node_01B584 [
  delta-node < #$FFFF, &delta_node_01B568 >
]

delta_node_01B588 [
  delta-node < #$FFFF, &delta_node_01B58C >
]

delta_node_01B58C [
  delta-node < #$FFFF, &delta_node_01B590 >
]

delta_node_01B590 [
  delta-node < #$FFFF, &delta_node_01B594 >
]

delta_node_01B594 [
  delta-node < #$FFFF, &delta_node_01B598 >
]

delta_node_01B598 [
  delta-node < #$FFFF, &delta_node_01B59C >
]

delta_node_01B59C [
  delta-node < #$FFFE, &delta_node_01B5A0 >
]

delta_node_01B5A0 [
  delta-node < #$FFFE, &delta_node_01B5A4 >
]

delta_node_01B5A4 [
  delta-node < #$FFFE, &delta_node_01B5A8 >
]

delta_node_01B5A8 [
  delta-node < #$0001, &delta_node_01B5AC >
]

delta_node_01B5AC [
  delta-node < #$0001, &delta_node_01B5B0 >
]

delta_node_01B5B0 [
  delta-node < #$0001, &delta_node_01B5B4 >
]

delta_node_01B5B4 [
  delta-node < #$0001, &delta_node_01B5B8 >
]

delta_node_01B5B8 [
  delta-node < #$0001, &delta_node_01B5BC >
]

delta_node_01B5BC [
  delta-node < #$0002, &delta_node_01B5C0 >
]

delta_node_01B5C0 [
  delta-node < #$0002, &delta_node_01B5C4 >
]

delta_node_01B5C4 [
  delta-node < #$0002, &delta_node_01B5C8 >
]

delta_node_01B5C8 [
  delta-node < #$0001, &delta_node_01B5CC >
]

delta_node_01B5CC [
  delta-node < #$0001, &delta_node_01B5D0 >
]

delta_node_01B5D0 [
  delta-node < #$0001, &delta_node_01B5D4 >
]

delta_node_01B5D4 [
  delta-node < #$0001, &delta_node_01B5D8 >
]

delta_node_01B5D8 [
  delta-node < #$0001, &delta_node_01B5DC >
]

delta_node_01B5DC [
  delta-node < #$0002, &delta_node_01B5E0 >
]

delta_node_01B5E0 [
  delta-node < #$0002, &delta_node_01B5E4 >
]

delta_node_01B5E4 [
  delta-node < #$0002, &delta_node_01B5E8 >
]

delta_node_01B5E8 [
  delta-node < #$FFFF, &delta_node_01B5EC >
]

delta_node_01B5EC [
  delta-node < #$FFFF, &delta_node_01B5F0 >
]

delta_node_01B5F0 [
  delta-node < #$FFFF, &delta_node_01B5F4 >
]

delta_node_01B5F4 [
  delta-node < #$FFFF, &delta_node_01B5F8 >
]

delta_node_01B5F8 [
  delta-node < #$FFFF, &delta_node_01B5FC >
]

delta_node_01B5FC [
  delta-node < #$FFFE, &delta_node_01B600 >
]

delta_node_01B600 [
  delta-node < #$FFFE, &delta_node_01B604 >
]

delta_node_01B604 [
  delta-node < #$FFFE, &delta_node_01B588 >
]

delta_node_01B608 [
  delta-node < #$FFFF, &delta_node_01B60C >
]

delta_node_01B60C [
  delta-node < #$FFFF, &delta_node_01B610 >
]

delta_node_01B610 [
  delta-node < #$FFFF, &delta_node_01B614 >
]

delta_node_01B614 [
  delta-node < #$FFFF, &delta_node_01B618 >
]

delta_node_01B618 [
  delta-node < #$FFFF, &delta_node_01B61C >
]

delta_node_01B61C [
  delta-node < #$FFFF, &delta_node_01B620 >
]

delta_node_01B620 [
  delta-node < #$FFFF, &delta_node_01B624 >
]

delta_node_01B624 [
  delta-node < #$FFFF, &delta_node_01B628 >
]

delta_node_01B628 [
  delta-node < #$FFFF, &delta_node_01B62C >
]

delta_node_01B62C [
  delta-node < #$FFFF, &delta_node_01B630 >
]

delta_node_01B630 [
  delta-node < #$FFFF, &delta_node_01B634 >
]

delta_node_01B634 [
  delta-node < #$0000, &delta_node_01B638 >
]

delta_node_01B638 [
  delta-node < #$0000, &delta_node_01B63C >
]

delta_node_01B63C [
  delta-node < #$0000, &delta_node_01B640 >
]

delta_node_01B640 [
  delta-node < #$0000, &delta_node_01B644 >
]

delta_node_01B644 [
  delta-node < #$0000, &delta_node_01B648 >
]

delta_node_01B648 [
  delta-node < #$0000, &delta_node_01B64C >
]

delta_node_01B64C [
  delta-node < #$0000, &delta_node_01B650 >
]

delta_node_01B650 [
  delta-node < #$0000, &delta_node_01B654 >
]

delta_node_01B654 [
  delta-node < #$FFFF, &delta_node_01B658 >
]

delta_node_01B658 [
  delta-node < #$FFFF, &delta_node_01B65C >
]

delta_node_01B65C [
  delta-node < #$FFFF, &delta_node_01B660 >
]

delta_node_01B660 [
  delta-node < #$FFFF, &delta_node_01B664 >
]

delta_node_01B664 [
  delta-node < #$FFFF, &delta_node_01B664 >
]

delta_node_01B668 [
  delta-node < #$0001, &delta_node_01B66C >
]

delta_node_01B66C [
  delta-node < #$0001, &delta_node_01B670 >
]

delta_node_01B670 [
  delta-node < #$0001, &delta_node_01B674 >
]

delta_node_01B674 [
  delta-node < #$0001, &delta_node_01B678 >
]

delta_node_01B678 [
  delta-node < #$0001, &delta_node_01B67C >
]

delta_node_01B67C [
  delta-node < #$0001, &delta_node_01B680 >
]

delta_node_01B680 [
  delta-node < #$0001, &delta_node_01B684 >
]

delta_node_01B684 [
  delta-node < #$0001, &delta_node_01B688 >
]

delta_node_01B688 [
  delta-node < #$0001, &delta_node_01B68C >
]

delta_node_01B68C [
  delta-node < #$0001, &delta_node_01B690 >
]

delta_node_01B690 [
  delta-node < #$0001, &delta_node_01B694 >
]

delta_node_01B694 [
  delta-node < #$0000, &delta_node_01B698 >
]

delta_node_01B698 [
  delta-node < #$0000, &delta_node_01B69C >
]

delta_node_01B69C [
  delta-node < #$0000, &delta_node_01B6A0 >
]

delta_node_01B6A0 [
  delta-node < #$0000, &delta_node_01B6A4 >
]

delta_node_01B6A4 [
  delta-node < #$0000, &delta_node_01B6A8 >
]

delta_node_01B6A8 [
  delta-node < #$0000, &delta_node_01B6AC >
]

delta_node_01B6AC [
  delta-node < #$0000, &delta_node_01B6B0 >
]

delta_node_01B6B0 [
  delta-node < #$0000, &delta_node_01B6B4 >
]

delta_node_01B6B4 [
  delta-node < #$0001, &delta_node_01B6B8 >
]

delta_node_01B6B8 [
  delta-node < #$0001, &delta_node_01B6BC >
]

delta_node_01B6BC [
  delta-node < #$0001, &delta_node_01B6C0 >
]

delta_node_01B6C0 [
  delta-node < #$0001, &delta_node_01B6C4 >
]

delta_node_01B6C4 [
  delta-node < #$0001, &delta_node_01B6C4 >
]

delta_node_01B6C8 [
  delta-node < #$FFFF, &delta_node_01B6CC >
]

delta_node_01B6CC [
  delta-node < #$FFFF, &delta_node_01B6D0 >
]

delta_node_01B6D0 [
  delta-node < #$FFFF, &delta_node_01B6D4 >
]

delta_node_01B6D4 [
  delta-node < #$FFFE, &delta_node_01B6D8 >
]

delta_node_01B6D8 [
  delta-node < #$FFFE, &delta_node_01B6DC >
]

delta_node_01B6DC [
  delta-node < #$FFFE, &delta_node_01B6E0 >
]

delta_node_01B6E0 [
  delta-node < #$FFFD, &delta_node_01B6E4 >
]

delta_node_01B6E4 [
  delta-node < #$FFFD, &delta_node_01B6E8 >
]

delta_node_01B6E8 [
  delta-node < #$FFFD, &delta_node_01B6EC >
]

delta_node_01B6EC [
  delta-node < #$FFFC, &delta_node_01B6EC >
]

delta_node_01B6F0 [
  delta-node < #$FFFD, &delta_node_01B6F4 >
]

delta_node_01B6F4 [
  delta-node < #$FFFD, &delta_node_01B6F8 >
]

delta_node_01B6F8 [
  delta-node < #$FFFD, &delta_node_01B6FC >
]

delta_node_01B6FC [
  delta-node < #$FFFE, &delta_node_01B700 >
]

delta_node_01B700 [
  delta-node < #$FFFE, &delta_node_01B704 >
]

delta_node_01B704 [
  delta-node < #$FFFE, &delta_node_01B708 >
]

delta_node_01B708 [
  delta-node < #$FFFF, &delta_node_01B70C >
]

delta_node_01B70C [
  delta-node < #$FFFF, &delta_node_01B710 >
]

delta_node_01B710 [
  delta-node < #$FFFF, &delta_node_01B714 >
]

delta_node_01B714 [
  delta-node < #$0000, &delta_node_01B714 >
]

delta_node_01B718 [
  delta-node < #$0001, &delta_node_01B71C >
]

delta_node_01B71C [
  delta-node < #$0001, &delta_node_01B720 >
]

delta_node_01B720 [
  delta-node < #$0001, &delta_node_01B724 >
]

delta_node_01B724 [
  delta-node < #$0002, &delta_node_01B728 >
]

delta_node_01B728 [
  delta-node < #$0002, &delta_node_01B72C >
]

delta_node_01B72C [
  delta-node < #$0002, &delta_node_01B730 >
]

delta_node_01B730 [
  delta-node < #$0003, &delta_node_01B734 >
]

delta_node_01B734 [
  delta-node < #$0003, &delta_node_01B738 >
]

delta_node_01B738 [
  delta-node < #$0003, &delta_node_01B73C >
]

delta_node_01B73C [
  delta-node < #$0004, &delta_node_01B73C >
]

delta_node_01B740 [
  delta-node < #$0003, &delta_node_01B744 >
]

delta_node_01B744 [
  delta-node < #$0003, &delta_node_01B748 >
]

delta_node_01B748 [
  delta-node < #$0003, &delta_node_01B74C >
]

delta_node_01B74C [
  delta-node < #$0002, &delta_node_01B750 >
]

delta_node_01B750 [
  delta-node < #$0002, &delta_node_01B754 >
]

delta_node_01B754 [
  delta-node < #$0002, &delta_node_01B758 >
]

delta_node_01B758 [
  delta-node < #$0001, &delta_node_01B75C >
]

delta_node_01B75C [
  delta-node < #$0001, &delta_node_01B760 >
]

delta_node_01B760 [
  delta-node < #$0001, &delta_node_01B764 >
]

delta_node_01B764 [
  delta-node < #$0000, &delta_node_01B764 >
]

delta_node_01B768 [
  delta-node < #$0001, &delta_node_01B76C >
]

delta_node_01B76C [
  delta-node < #$0001, &delta_node_01B770 >
]

delta_node_01B770 [
  delta-node < #$0001, &delta_node_01B774 >
]

delta_node_01B774 [
  delta-node < #$0002, &delta_node_01B778 >
]

delta_node_01B778 [
  delta-node < #$0002, &delta_node_01B77C >
]

delta_node_01B77C [
  delta-node < #$0002, &delta_node_01B780 >
]

delta_node_01B780 [
  delta-node < #$0003, &delta_node_01B784 >
]

delta_node_01B784 [
  delta-node < #$0003, &delta_node_01B788 >
]

delta_node_01B788 [
  delta-node < #$0003, &delta_node_01B78C >
]

delta_node_01B78C [
  delta-node < #$0005, &delta_node_01B790 >
]

delta_node_01B790 [
  delta-node < #$0005, &delta_node_01B794 >
]

delta_node_01B794 [
  delta-node < #$0005, &delta_node_01B798 >
]

delta_node_01B798 [
  delta-node < #$0003, &delta_node_01B79C >
]

delta_node_01B79C [
  delta-node < #$0003, &delta_node_01B7A0 >
]

delta_node_01B7A0 [
  delta-node < #$0003, &delta_node_01B7A4 >
]

delta_node_01B7A4 [
  delta-node < #$0002, &delta_node_01B7A8 >
]

delta_node_01B7A8 [
  delta-node < #$0002, &delta_node_01B7AC >
]

delta_node_01B7AC [
  delta-node < #$0002, &delta_node_01B7B0 >
]

delta_node_01B7B0 [
  delta-node < #$0001, &delta_node_01B7B4 >
]

delta_node_01B7B4 [
  delta-node < #$0001, &delta_node_01B7B8 >
]

delta_node_01B7B8 [
  delta-node < #$0001, &delta_node_01B768 >
]

delta_node_01B7BC [
  delta-node < #$FFFF, &delta_node_01B7C0 >
]

delta_node_01B7C0 [
  delta-node < #$FFFF, &delta_node_01B7C4 >
]

delta_node_01B7C4 [
  delta-node < #$FFFF, &delta_node_01B7C8 >
]

delta_node_01B7C8 [
  delta-node < #$FFFE, &delta_node_01B7CC >
]

delta_node_01B7CC [
  delta-node < #$FFFE, &delta_node_01B7D0 >
]

delta_node_01B7D0 [
  delta-node < #$FFFE, &delta_node_01B7D4 >
]

delta_node_01B7D4 [
  delta-node < #$FFFD, &delta_node_01B7D8 >
]

delta_node_01B7D8 [
  delta-node < #$FFFD, &delta_node_01B7DC >
]

delta_node_01B7DC [
  delta-node < #$FFFD, &delta_node_01B7E0 >
]

delta_node_01B7E0 [
  delta-node < #$FFFB, &delta_node_01B7E4 >
]

delta_node_01B7E4 [
  delta-node < #$FFFB, &delta_node_01B7E8 >
]

delta_node_01B7E8 [
  delta-node < #$FFFB, &delta_node_01B7EC >
]

delta_node_01B7EC [
  delta-node < #$FFFD, &delta_node_01B7F0 >
]

delta_node_01B7F0 [
  delta-node < #$FFFD, &delta_node_01B7F4 >
]

delta_node_01B7F4 [
  delta-node < #$FFFD, &delta_node_01B7F8 >
]

delta_node_01B7F8 [
  delta-node < #$FFFE, &delta_node_01B7FC >
]

delta_node_01B7FC [
  delta-node < #$FFFE, &delta_node_01B800 >
]

delta_node_01B800 [
  delta-node < #$FFFE, &delta_node_01B804 >
]

delta_node_01B804 [
  delta-node < #$FFFF, &delta_node_01B808 >
]

delta_node_01B808 [
  delta-node < #$FFFF, &delta_node_01B80C >
]

delta_node_01B80C [
  delta-node < #$FFFF, &delta_node_01B7BC >
]

delta_node_01B810 [
  delta-node < #$FFFD, &delta_node_01B814 >
]

delta_node_01B814 [
  delta-node < #$FFFD, &delta_node_01B818 >
]

delta_node_01B818 [
  delta-node < #$FFFD, &delta_node_01B81C >
]

delta_node_01B81C [
  delta-node < #$FFFE, &delta_node_01B820 >
]

delta_node_01B820 [
  delta-node < #$FFFE, &delta_node_01B824 >
]

delta_node_01B824 [
  delta-node < #$FFFE, &delta_node_01B828 >
]

delta_node_01B828 [
  delta-node < #$FFFF, &delta_node_01B82C >
]

delta_node_01B82C [
  delta-node < #$FFFF, &delta_node_01B830 >
]

delta_node_01B830 [
  delta-node < #$FFFF, &delta_node_01B834 >
]

delta_node_01B834 [
  delta-node < #$0000, &delta_node_01B838 >
]

delta_node_01B838 [
  delta-node < #$0000, &delta_node_01B83C >
]

delta_node_01B83C [
  delta-node < #$0000, &delta_node_01B840 >
]

delta_node_01B840 [
  delta-node < #$0001, &delta_node_01B844 >
]

delta_node_01B844 [
  delta-node < #$0001, &delta_node_01B848 >
]

delta_node_01B848 [
  delta-node < #$0001, &delta_node_01B84C >
]

delta_node_01B84C [
  delta-node < #$0002, &delta_node_01B850 >
]

delta_node_01B850 [
  delta-node < #$0002, &delta_node_01B854 >
]

delta_node_01B854 [
  delta-node < #$0002, &delta_node_01B858 >
]

delta_node_01B858 [
  delta-node < #$0003, &delta_node_01B85C >
]

delta_node_01B85C [
  delta-node < #$0003, &delta_node_01B860 >
]

delta_node_01B860 [
  delta-node < #$0003, &delta_node_01B810 >
]

delta_node_01B864 [
  delta-node < #$0003, &delta_node_01B868 >
]

delta_node_01B868 [
  delta-node < #$0003, &delta_node_01B86C >
]

delta_node_01B86C [
  delta-node < #$0003, &delta_node_01B870 >
]

delta_node_01B870 [
  delta-node < #$0002, &delta_node_01B874 >
]

delta_node_01B874 [
  delta-node < #$0002, &delta_node_01B878 >
]

delta_node_01B878 [
  delta-node < #$0002, &delta_node_01B87C >
]

delta_node_01B87C [
  delta-node < #$0001, &delta_node_01B880 >
]

delta_node_01B880 [
  delta-node < #$0001, &delta_node_01B884 >
]

delta_node_01B884 [
  delta-node < #$0001, &delta_node_01B888 >
]

delta_node_01B888 [
  delta-node < #$0000, &delta_node_01B88C >
]

delta_node_01B88C [
  delta-node < #$0000, &delta_node_01B890 >
]

delta_node_01B890 [
  delta-node < #$0000, &delta_node_01B894 >
]

delta_node_01B894 [
  delta-node < #$FFFF, &delta_node_01B898 >
]

delta_node_01B898 [
  delta-node < #$FFFF, &delta_node_01B89C >
]

delta_node_01B89C [
  delta-node < #$FFFF, &delta_node_01B8A0 >
]

delta_node_01B8A0 [
  delta-node < #$FFFE, &delta_node_01B8A4 >
]

delta_node_01B8A4 [
  delta-node < #$FFFE, &delta_node_01B8A8 >
]

delta_node_01B8A8 [
  delta-node < #$FFFE, &delta_node_01B8AC >
]

delta_node_01B8AC [
  delta-node < #$FFFD, &delta_node_01B8B0 >
]

delta_node_01B8B0 [
  delta-node < #$FFFD, &delta_node_01B8B4 >
]

delta_node_01B8B4 [
  delta-node < #$FFFD, &delta_node_01B864 >
]

delta_node_01B8B8 [
  delta-node < #$FFFA, &delta_node_01B8BC >
]

delta_node_01B8BC [
  delta-node < #$FFFA, &delta_node_01B8C0 >
]

delta_node_01B8C0 [
  delta-node < #$FFFC, &delta_node_01B8C4 >
]

delta_node_01B8C4 [
  delta-node < #$FFFC, &delta_node_01B8C8 >
]

delta_node_01B8C8 [
  delta-node < #$FFFE, &delta_node_01B8CC >
]

delta_node_01B8CC [
  delta-node < #$FFFE, &delta_node_01B8D0 >
]

delta_node_01B8D0 [
  delta-node < #$0000, &delta_node_01B8D4 >
]

delta_node_01B8D4 [
  delta-node < #$0000, &delta_node_01B8D8 >
]

delta_node_01B8D8 [
  delta-node < #$0000, &delta_node_01B8DC >
]

delta_node_01B8DC [
  delta-node < #$0000, &delta_node_01B8E0 >
]

delta_node_01B8E0 [
  delta-node < #$0002, &delta_node_01B8E4 >
]

delta_node_01B8E4 [
  delta-node < #$0002, &delta_node_01B8E8 >
]

delta_node_01B8E8 [
  delta-node < #$0004, &delta_node_01B8EC >
]

delta_node_01B8EC [
  delta-node < #$0004, &delta_node_01B8F0 >
]

delta_node_01B8F0 [
  delta-node < #$0006, &delta_node_01B8F4 >
]

delta_node_01B8F4 [
  delta-node < #$0006, &delta_node_01B8B8 >
]

delta_node_01B8F8 [
  delta-node < #$0007, &delta_node_01B8FC >
]

delta_node_01B8FC [
  delta-node < #$0007, &delta_node_01B900 >
]

delta_node_01B900 [
  delta-node < #$0006, &delta_node_01B904 >
]

delta_node_01B904 [
  delta-node < #$0006, &delta_node_01B908 >
]

delta_node_01B908 [
  delta-node < #$0005, &delta_node_01B90C >
]

delta_node_01B90C [
  delta-node < #$0005, &delta_node_01B910 >
]

delta_node_01B910 [
  delta-node < #$0005, &delta_node_01B914 >
]

delta_node_01B914 [
  delta-node < #$0005, &delta_node_01B918 >
]

delta_node_01B918 [
  delta-node < #$0004, &delta_node_01B91C >
]

delta_node_01B91C [
  delta-node < #$0004, &delta_node_01B920 >
]

delta_node_01B920 [
  delta-node < #$0003, &delta_node_01B924 >
]

delta_node_01B924 [
  delta-node < #$0003, &delta_node_01B928 >
]

delta_node_01B928 [
  delta-node < #$0002, &delta_node_01B92C >
]

delta_node_01B92C [
  delta-node < #$0002, &delta_node_01B930 >
]

delta_node_01B930 [
  delta-node < #$0000, &delta_node_01B934 >
]

delta_node_01B934 [
  delta-node < #$0000, &delta_node_01B8F8 >
]

delta_node_01B938 [
  delta-node < #$0000, &delta_node_01B93C >
]

delta_node_01B93C [
  delta-node < #$0000, &delta_node_01B940 >
]

delta_node_01B940 [
  delta-node < #$FFFE, &delta_node_01B944 >
]

delta_node_01B944 [
  delta-node < #$FFFE, &delta_node_01B948 >
]

delta_node_01B948 [
  delta-node < #$FFFD, &delta_node_01B94C >
]

delta_node_01B94C [
  delta-node < #$FFFD, &delta_node_01B950 >
]

delta_node_01B950 [
  delta-node < #$FFFC, &delta_node_01B954 >
]

delta_node_01B954 [
  delta-node < #$FFFC, &delta_node_01B958 >
]

delta_node_01B958 [
  delta-node < #$FFFB, &delta_node_01B95C >
]

delta_node_01B95C [
  delta-node < #$FFFB, &delta_node_01B960 >
]

delta_node_01B960 [
  delta-node < #$FFFB, &delta_node_01B964 >
]

delta_node_01B964 [
  delta-node < #$FFFB, &delta_node_01B968 >
]

delta_node_01B968 [
  delta-node < #$FFFA, &delta_node_01B96C >
]

delta_node_01B96C [
  delta-node < #$FFFA, &delta_node_01B970 >
]

delta_node_01B970 [
  delta-node < #$FFF9, &delta_node_01B974 >
]

delta_node_01B974 [
  delta-node < #$FFF9, &delta_node_01B938 >
]

delta_node_01B978 [
  delta-node < #$FFFA, &delta_node_01B97C >
]

delta_node_01B97C [
  delta-node < #$FFFA, &delta_node_01B980 >
]

delta_node_01B980 [
  delta-node < #$FFFC, &delta_node_01B984 >
]

delta_node_01B984 [
  delta-node < #$FFFC, &delta_node_01B988 >
]

delta_node_01B988 [
  delta-node < #$FFFE, &delta_node_01B98C >
]

delta_node_01B98C [
  delta-node < #$FFFE, &delta_node_01B990 >
]

delta_node_01B990 [
  delta-node < #$0000, &delta_node_01B994 >
]

delta_node_01B994 [
  delta-node < #$0000, &delta_node_01B998 >
]

delta_node_01B998 [
  delta-node < #$0000, &delta_node_01B99C >
]

delta_node_01B99C [
  delta-node < #$0000, &delta_node_01B9A0 >
]

delta_node_01B9A0 [
  delta-node < #$0002, &delta_node_01B9A4 >
]

delta_node_01B9A4 [
  delta-node < #$0002, &delta_node_01B9A8 >
]

delta_node_01B9A8 [
  delta-node < #$0004, &delta_node_01B9AC >
]

delta_node_01B9AC [
  delta-node < #$0004, &delta_node_01B9B0 >
]

delta_node_01B9B0 [
  delta-node < #$0006, &delta_node_01B9B4 >
]

delta_node_01B9B4 [
  delta-node < #$0006, &delta_node_01B978 >
]

delta_node_01B9B8 [
  delta-node < #$FFFC, &delta_node_01B9BC >
]

delta_node_01B9BC [
  delta-node < #$FFFD, &delta_node_01B9C0 >
]

delta_node_01B9C0 [
  delta-node < #$FFFE, &delta_node_01B9C4 >
]

delta_node_01B9C4 [
  delta-node < #$FFFF, &delta_node_01B9C8 >
]

delta_node_01B9C8 [
  delta-node < #$0000, &delta_node_01B9CC >
]

delta_node_01B9CC [
  delta-node < #$0000, &delta_node_01B9D0 >
]

delta_node_01B9D0 [
  delta-node < #$0001, &delta_node_01B9D4 >
]

delta_node_01B9D4 [
  delta-node < #$0002, &delta_node_01B9D8 >
]

delta_node_01B9D8 [
  delta-node < #$0003, &delta_node_01B9DC >
]

delta_node_01B9DC [
  delta-node < #$0004, &delta_node_01B9E0 >
]

delta_node_01B9E0 [
  delta-node < #$FFFE, &delta_node_01B9E4 >
]

delta_node_01B9E4 [
  delta-node < #$FFFF, &delta_node_01B9E8 >
]

delta_node_01B9E8 [
  delta-node < #$0000, &delta_node_01B9EC >
]

delta_node_01B9EC [
  delta-node < #$0001, &delta_node_01B9F0 >
]

delta_node_01B9F0 [
  delta-node < #$0002, &delta_node_01B9F4 >
]

delta_node_01B9F4 [
  delta-node < #$0000, &delta_node_01B9F4 >
]

delta_node_01B9F8 [
  delta-node < #$0000, &delta_node_01B9FC >
]

delta_node_01B9FC [
  delta-node < #$0000, &delta_node_01BA00 >
]

delta_node_01BA00 [
  delta-node < #$0000, &delta_node_01BA04 >
]

delta_node_01BA04 [
  delta-node < #$0000, &delta_node_01BA08 >
]

delta_node_01BA08 [
  delta-node < #$0000, &delta_node_01BA0C >
]

delta_node_01BA0C [
  delta-node < #$0000, &delta_node_01BA10 >
]

delta_node_01BA10 [
  delta-node < #$0000, &delta_node_01BA14 >
]

delta_node_01BA14 [
  delta-node < #$0000, &delta_node_01BA18 >
]

delta_node_01BA18 [
  delta-node < #$0004, &delta_node_01BA1C >
]

delta_node_01BA1C [
  delta-node < #$0004, &delta_node_01BA20 >
]

delta_node_01BA20 [
  delta-node < #$0007, &delta_node_01BA24 >
]

delta_node_01BA24 [
  delta-node < #$0007, &delta_node_01BA28 >
]

delta_node_01BA28 [
  delta-node < #$0009, &delta_node_01BA2C >
]

delta_node_01BA2C [
  delta-node < #$0009, &delta_node_01BA30 >
]

delta_node_01BA30 [
  delta-node < #$000C, &delta_node_01BA34 >
]

delta_node_01BA34 [
  delta-node < #$000C, &delta_node_01BA38 >
]

delta_node_01BA38 [
  delta-node < #$0000, &delta_node_01BA3C >
]

delta_node_01BA3C [
  delta-node < #$0000, &delta_node_01BA40 >
]

delta_node_01BA40 [
  delta-node < #$FFF8, &delta_node_01BA44 >
]

delta_node_01BA44 [
  delta-node < #$FFF8, &delta_node_01BA48 >
]

delta_node_01BA48 [
  delta-node < #$FFF8, &delta_node_01BA4C >
]

delta_node_01BA4C [
  delta-node < #$FFF8, &delta_node_01BA50 >
]

delta_node_01BA50 [
  delta-node < #$FFF8, &delta_node_01BA54 >
]

delta_node_01BA54 [
  delta-node < #$FFF8, &delta_node_01BA58 >
]

delta_node_01BA58 [
  delta-node < #$FFF8, &delta_node_01BA5C >
]

delta_node_01BA5C [
  delta-node < #$FFF8, &delta_node_01BA60 >
]

delta_node_01BA60 [
  delta-node < #$0000, &delta_node_01BA60 >
]

delta_node_01BA64 [
  delta-node < #$0000, &delta_node_01BA64 >
]

delta_node_01BA68 [
  delta-node < #$FFFC, &delta_node_01BA6C >
]

delta_node_01BA6C [
  delta-node < #$FFFC, &delta_node_01BA70 >
]

delta_node_01BA70 [
  delta-node < #$FFFD, &delta_node_01BA74 >
]

delta_node_01BA74 [
  delta-node < #$FFFD, &delta_node_01BA78 >
]

delta_node_01BA78 [
  delta-node < #$FFFE, &delta_node_01BA7C >
]

delta_node_01BA7C [
  delta-node < #$FFFE, &delta_node_01BA80 >
]

delta_node_01BA80 [
  delta-node < #$FFFF, &delta_node_01BA84 >
]

delta_node_01BA84 [
  delta-node < #$0000, &delta_node_01BA88 >
]

delta_node_01BA88 [
  delta-node < #$0000, &delta_node_01BA8C >
]

delta_node_01BA8C [
  delta-node < #$0001, &delta_node_01BA90 >
]

delta_node_01BA90 [
  delta-node < #$0002, &delta_node_01BA94 >
]

delta_node_01BA94 [
  delta-node < #$0002, &delta_node_01BA98 >
]

delta_node_01BA98 [
  delta-node < #$0003, &delta_node_01BA9C >
]

delta_node_01BA9C [
  delta-node < #$0003, &delta_node_01BAA0 >
]

delta_node_01BAA0 [
  delta-node < #$0004, &delta_node_01BAA4 >
]

delta_node_01BAA4 [
  delta-node < #$0004, &delta_node_01BAA4 >
]

delta_node_01BAA8 [
  delta-node < #$FFFA, &delta_node_01BAAC >
]

delta_node_01BAAC [
  delta-node < #$FFFA, &delta_node_01BAB0 >
]

delta_node_01BAB0 [
  delta-node < #$FFFA, &delta_node_01BAB4 >
]

delta_node_01BAB4 [
  delta-node < #$FFFB, &delta_node_01BAB8 >
]

delta_node_01BAB8 [
  delta-node < #$FFFB, &delta_node_01BABC >
]

delta_node_01BABC [
  delta-node < #$FFFC, &delta_node_01BAC0 >
]

delta_node_01BAC0 [
  delta-node < #$FFFD, &delta_node_01BAC4 >
]

delta_node_01BAC4 [
  delta-node < #$FFFE, &delta_node_01BAC8 >
]

delta_node_01BAC8 [
  delta-node < #$FFFF, &delta_node_01BACC >
]

delta_node_01BACC [
  delta-node < #$0000, &delta_node_01BAD0 >
]

delta_node_01BAD0 [
  delta-node < #$0000, &delta_node_01BAD4 >
]

delta_node_01BAD4 [
  delta-node < #$0000, &delta_node_01BAD8 >
]

delta_node_01BAD8 [
  delta-node < #$0000, &delta_node_01BADC >
]

delta_node_01BADC [
  delta-node < #$0001, &delta_node_01BAE0 >
]

delta_node_01BAE0 [
  delta-node < #$0002, &delta_node_01BAE4 >
]

delta_node_01BAE4 [
  delta-node < #$0003, &delta_node_01BAE4 >
]

delta_node_01BAE8 [
  delta-node < #$FFFD, &delta_node_01BAEC >
]

delta_node_01BAEC [
  delta-node < #$FFFE, &delta_node_01BAF0 >
]

delta_node_01BAF0 [
  delta-node < #$FFFF, &delta_node_01BAF4 >
]

delta_node_01BAF4 [
  delta-node < #$0000, &delta_node_01BAF8 >
]

delta_node_01BAF8 [
  delta-node < #$0000, &delta_node_01BAFC >
]

delta_node_01BAFC [
  delta-node < #$0000, &delta_node_01BB00 >
]

delta_node_01BB00 [
  delta-node < #$0000, &delta_node_01BB04 >
]

delta_node_01BB04 [
  delta-node < #$0001, &delta_node_01BB08 >
]

delta_node_01BB08 [
  delta-node < #$0002, &delta_node_01BB0C >
]

delta_node_01BB0C [
  delta-node < #$0003, &delta_node_01BB10 >
]

delta_node_01BB10 [
  delta-node < #$0004, &delta_node_01BB14 >
]

delta_node_01BB14 [
  delta-node < #$0005, &delta_node_01BB18 >
]

delta_node_01BB18 [
  delta-node < #$0005, &delta_node_01BB1C >
]

delta_node_01BB1C [
  delta-node < #$0006, &delta_node_01BB20 >
]

delta_node_01BB20 [
  delta-node < #$0006, &delta_node_01BB24 >
]

delta_node_01BB24 [
  delta-node < #$0006, &delta_node_01BB24 >
]

delta_node_01BB28 [
  delta-node < #$FFFF, &delta_node_01BB2C >
]

delta_node_01BB2C [
  delta-node < #$0000, &delta_node_01BB30 >
]

delta_node_01BB30 [
  delta-node < #$FFFF, &delta_node_01BB34 >
]

delta_node_01BB34 [
  delta-node < #$0000, &delta_node_01BB38 >
]

delta_node_01BB38 [
  delta-node < #$0000, &delta_node_01BB3C >
]

delta_node_01BB3C [
  delta-node < #$0000, &delta_node_01BB40 >
]

delta_node_01BB40 [
  delta-node < #$0001, &delta_node_01BB44 >
]

delta_node_01BB44 [
  delta-node < #$0000, &delta_node_01BB48 >
]

delta_node_01BB48 [
  delta-node < #$0001, &delta_node_01BB4C >
]

delta_node_01BB4C [
  delta-node < #$0000, &delta_node_01BB50 >
]

delta_node_01BB50 [
  delta-node < #$0001, &delta_node_01BB54 >
]

delta_node_01BB54 [
  delta-node < #$0000, &delta_node_01BB58 >
]

delta_node_01BB58 [
  delta-node < #$0001, &delta_node_01BB5C >
]

delta_node_01BB5C [
  delta-node < #$0000, &delta_node_01BB60 >
]

delta_node_01BB60 [
  delta-node < #$0000, &delta_node_01BB64 >
]

delta_node_01BB64 [
  delta-node < #$0000, &delta_node_01BB68 >
]

delta_node_01BB68 [
  delta-node < #$FFFF, &delta_node_01BB6C >
]

delta_node_01BB6C [
  delta-node < #$0000, &delta_node_01BB70 >
]

delta_node_01BB70 [
  delta-node < #$FFFF, &delta_node_01BB74 >
]

delta_node_01BB74 [
  delta-node < #$0000, &delta_node_01BB74 >
]

delta_node_01BB78 [
  delta-node < #$0008, &delta_node_01BB7C >
]

delta_node_01BB7C [
  delta-node < #$0000, &delta_node_01BB80 >
]

delta_node_01BB80 [
  delta-node < #$0000, &delta_node_01BB84 >
]

delta_node_01BB84 [
  delta-node < #$0000, &delta_node_01BB78 >
]

delta_node_01BB88 [
  delta-node < #$0004, &delta_node_01BB8C >
]

delta_node_01BB8C [
  delta-node < #$0000, &delta_node_01BB90 >
]

delta_node_01BB90 [
  delta-node < #$0000, &delta_node_01BB94 >
]

delta_node_01BB94 [
  delta-node < #$0000, &delta_node_01BB98 >
]

delta_node_01BB98 [
  delta-node < #$0000, &delta_node_01BB9C >
]

delta_node_01BB9C [
  delta-node < #$0000, &delta_node_01BBA0 >
]

delta_node_01BBA0 [
  delta-node < #$0004, &delta_node_01BBA4 >
]

delta_node_01BBA4 [
  delta-node < #$0000, &delta_node_01BBA8 >
]

delta_node_01BBA8 [
  delta-node < #$0000, &delta_node_01BBAC >
]

delta_node_01BBAC [
  delta-node < #$0000, &delta_node_01BBB0 >
]

delta_node_01BBB0 [
  delta-node < #$0000, &delta_node_01BBB4 >
]

delta_node_01BBB4 [
  delta-node < #$0005, &delta_node_01BBB8 >
]

delta_node_01BBB8 [
  delta-node < #$0000, &delta_node_01BBBC >
]

delta_node_01BBBC [
  delta-node < #$0000, &delta_node_01BBC0 >
]

delta_node_01BBC0 [
  delta-node < #$0000, &delta_node_01BBC4 >
]

delta_node_01BBC4 [
  delta-node < #$0004, &delta_node_01BBC8 >
]

delta_node_01BBC8 [
  delta-node < #$0000, &delta_node_01BBCC >
]

delta_node_01BBCC [
  delta-node < #$0000, &delta_node_01BBD0 >
]

delta_node_01BBD0 [
  delta-node < #$0000, &delta_node_01BBD4 >
]

delta_node_01BBD4 [
  delta-node < #$0000, &delta_node_01BBD8 >
]

delta_node_01BBD8 [
  delta-node < #$0002, &delta_node_01BBDC >
]

delta_node_01BBDC [
  delta-node < #$0000, &delta_node_01BBE0 >
]

delta_node_01BBE0 [
  delta-node < #$0000, &delta_node_01BBE4 >
]

delta_node_01BBE4 [
  delta-node < #$0000, &delta_node_01BBE8 >
]

delta_node_01BBE8 [
  delta-node < #$0000, &delta_node_01BBEC >
]

delta_node_01BBEC [
  delta-node < #$0004, &delta_node_01BBF0 >
]

delta_node_01BBF0 [
  delta-node < #$0000, &delta_node_01BBF4 >
]

delta_node_01BBF4 [
  delta-node < #$0000, &delta_node_01BBF8 >
]

delta_node_01BBF8 [
  delta-node < #$0000, &delta_node_01BBFC >
]

delta_node_01BBFC [
  delta-node < #$0000, &delta_node_01BC00 >
]

delta_node_01BC00 [
  delta-node < #$0005, &delta_node_01BC04 >
]

delta_node_01BC04 [
  delta-node < #$0000, &delta_node_01BC08 >
]

delta_node_01BC08 [
  delta-node < #$0000, &delta_node_01BC0C >
]

delta_node_01BC0C [
  delta-node < #$0000, &delta_node_01BC10 >
]

delta_node_01BC10 [
  delta-node < #$0000, &delta_node_01BC14 >
]

delta_node_01BC14 [
  delta-node < #$0004, &delta_node_01BC18 >
]

delta_node_01BC18 [
  delta-node < #$0000, &delta_node_01BC18 >
]

delta_node_01BC1C [
  delta-node < #$0004, &delta_node_01BC20 >
]

delta_node_01BC20 [
  delta-node < #$0000, &delta_node_01BC24 >
]

delta_node_01BC24 [
  delta-node < #$0000, &delta_node_01BC28 >
]

delta_node_01BC28 [
  delta-node < #$0004, &delta_node_01BC2C >
]

delta_node_01BC2C [
  delta-node < #$0000, &delta_node_01BC30 >
]

delta_node_01BC30 [
  delta-node < #$0000, &delta_node_01BC34 >
]

delta_node_01BC34 [
  delta-node < #$0005, &delta_node_01BC38 >
]

delta_node_01BC38 [
  delta-node < #$0000, &delta_node_01BC3C >
]

delta_node_01BC3C [
  delta-node < #$0000, &delta_node_01BC40 >
]

delta_node_01BC40 [
  delta-node < #$0004, &delta_node_01BC44 >
]

delta_node_01BC44 [
  delta-node < #$0000, &delta_node_01BC48 >
]

delta_node_01BC48 [
  delta-node < #$0000, &delta_node_01BC4C >
]

delta_node_01BC4C [
  delta-node < #$0002, &delta_node_01BC50 >
]

delta_node_01BC50 [
  delta-node < #$0000, &delta_node_01BC54 >
]

delta_node_01BC54 [
  delta-node < #$0000, &delta_node_01BC58 >
]

delta_node_01BC58 [
  delta-node < #$0004, &delta_node_01BC5C >
]

delta_node_01BC5C [
  delta-node < #$0000, &delta_node_01BC60 >
]

delta_node_01BC60 [
  delta-node < #$0000, &delta_node_01BC64 >
]

delta_node_01BC64 [
  delta-node < #$0005, &delta_node_01BC68 >
]

delta_node_01BC68 [
  delta-node < #$0000, &delta_node_01BC6C >
]

delta_node_01BC6C [
  delta-node < #$0000, &delta_node_01BC70 >
]

delta_node_01BC70 [
  delta-node < #$0004, &delta_node_01BC74 >
]

delta_node_01BC74 [
  delta-node < #$0000, &delta_node_01BC74 >
]

delta_node_01BC78 [
  delta-node < #$0008, &delta_node_01BC7C >
]

delta_node_01BC7C [
  delta-node < #$0000, &delta_node_01BC80 >
]

delta_node_01BC80 [
  delta-node < #$0000, &delta_node_01BC78 >
]

delta_node_01BC84 [
  delta-node < #$FFFD, &delta_node_01BC88 >
]

delta_node_01BC88 [
  delta-node < #$FFFD, &delta_node_01BC8C >
]

delta_node_01BC8C [
  delta-node < #$FFFD, &delta_node_01BC90 >
]

delta_node_01BC90 [
  delta-node < #$FFFD, &delta_node_01BC94 >
]

delta_node_01BC94 [
  delta-node < #$FFFD, &delta_node_01BC98 >
]

delta_node_01BC98 [
  delta-node < #$FFFD, &delta_node_01BC9C >
]

delta_node_01BC9C [
  delta-node < #$FFFD, &delta_node_01BCA0 >
]

delta_node_01BCA0 [
  delta-node < #$FFFD, &delta_node_01BCA4 >
]

delta_node_01BCA4 [
  delta-node < #$0001, &delta_node_01BCA8 >
]

delta_node_01BCA8 [
  delta-node < #$0001, &delta_node_01BCAC >
]

delta_node_01BCAC [
  delta-node < #$0001, &delta_node_01BCB0 >
]

delta_node_01BCB0 [
  delta-node < #$0001, &delta_node_01BCB4 >
]

delta_node_01BCB4 [
  delta-node < #$0001, &delta_node_01BCB8 >
]

delta_node_01BCB8 [
  delta-node < #$0001, &delta_node_01BCBC >
]

delta_node_01BCBC [
  delta-node < #$0001, &delta_node_01BCC0 >
]

delta_node_01BCC0 [
  delta-node < #$0001, &delta_node_01BCC4 >
]

delta_node_01BCC4 [
  delta-node < #$0000, &delta_node_01BCC4 >
]

delta_node_01BCC8 [
  delta-node < #$FFFF, &delta_node_01BCCC >
]

delta_node_01BCCC [
  delta-node < #$FFFF, &delta_node_01BCD0 >
]

delta_node_01BCD0 [
  delta-node < #$FFFF, &delta_node_01BCD4 >
]

delta_node_01BCD4 [
  delta-node < #$FFFF, &delta_node_01BCD8 >
]

delta_node_01BCD8 [
  delta-node < #$FFFF, &delta_node_01BCDC >
]

delta_node_01BCDC [
  delta-node < #$FFFF, &delta_node_01BCE0 >
]

delta_node_01BCE0 [
  delta-node < #$FFFF, &delta_node_01BCE4 >
]

delta_node_01BCE4 [
  delta-node < #$FFFF, &delta_node_01BCE8 >
]

delta_node_01BCE8 [
  delta-node < #$0003, &delta_node_01BCEC >
]

delta_node_01BCEC [
  delta-node < #$0003, &delta_node_01BCF0 >
]

delta_node_01BCF0 [
  delta-node < #$0003, &delta_node_01BCF4 >
]

delta_node_01BCF4 [
  delta-node < #$0003, &delta_node_01BCF8 >
]

delta_node_01BCF8 [
  delta-node < #$0003, &delta_node_01BCFC >
]

delta_node_01BCFC [
  delta-node < #$0003, &delta_node_01BD00 >
]

delta_node_01BD00 [
  delta-node < #$0003, &delta_node_01BD04 >
]

delta_node_01BD04 [
  delta-node < #$0003, &delta_node_01BD08 >
]

delta_node_01BD08 [
  delta-node < #$0000, &delta_node_01BD08 >
]

delta_node_01BD0C [
  delta-node < #$0001, &delta_node_01BD10 >
]

delta_node_01BD10 [
  delta-node < #$0001, &delta_node_01BD14 >
]

delta_node_01BD14 [
  delta-node < #$0001, &delta_node_01BD18 >
]

delta_node_01BD18 [
  delta-node < #$0001, &delta_node_01BD1C >
]

delta_node_01BD1C [
  delta-node < #$0001, &delta_node_01BD20 >
]

delta_node_01BD20 [
  delta-node < #$0001, &delta_node_01BD24 >
]

delta_node_01BD24 [
  delta-node < #$0001, &delta_node_01BD28 >
]

delta_node_01BD28 [
  delta-node < #$0001, &delta_node_01BD2C >
]

delta_node_01BD2C [
  delta-node < #$0001, &delta_node_01BD30 >
]

delta_node_01BD30 [
  delta-node < #$0001, &delta_node_01BD34 >
]

delta_node_01BD34 [
  delta-node < #$0001, &delta_node_01BD38 >
]

delta_node_01BD38 [
  delta-node < #$0001, &delta_node_01BD3C >
]

delta_node_01BD3C [
  delta-node < #$0001, &delta_node_01BD40 >
]

delta_node_01BD40 [
  delta-node < #$0001, &delta_node_01BD44 >
]

delta_node_01BD44 [
  delta-node < #$0001, &delta_node_01BD48 >
]

delta_node_01BD48 [
  delta-node < #$0001, &delta_node_01BD4C >
]

delta_node_01BD4C [
  delta-node < #$0000, &delta_node_01BD4C >
]

delta_node_01BD50 [
  delta-node < #$FFFF, &delta_node_01BD54 >
]

delta_node_01BD54 [
  delta-node < #$FFFF, &delta_node_01BD58 >
]

delta_node_01BD58 [
  delta-node < #$FFFF, &delta_node_01BD5C >
]

delta_node_01BD5C [
  delta-node < #$FFFF, &delta_node_01BD60 >
]

delta_node_01BD60 [
  delta-node < #$FFFF, &delta_node_01BD64 >
]

delta_node_01BD64 [
  delta-node < #$FFFF, &delta_node_01BD68 >
]

delta_node_01BD68 [
  delta-node < #$FFFF, &delta_node_01BD6C >
]

delta_node_01BD6C [
  delta-node < #$FFFF, &delta_node_01BD70 >
]

delta_node_01BD70 [
  delta-node < #$0001, &delta_node_01BD74 >
]

delta_node_01BD74 [
  delta-node < #$0001, &delta_node_01BD78 >
]

delta_node_01BD78 [
  delta-node < #$0001, &delta_node_01BD7C >
]

delta_node_01BD7C [
  delta-node < #$0001, &delta_node_01BD80 >
]

delta_node_01BD80 [
  delta-node < #$0001, &delta_node_01BD84 >
]

delta_node_01BD84 [
  delta-node < #$0001, &delta_node_01BD88 >
]

delta_node_01BD88 [
  delta-node < #$0001, &delta_node_01BD8C >
]

delta_node_01BD8C [
  delta-node < #$0001, &delta_node_01BD90 >
]

delta_node_01BD90 [
  delta-node < #$0000, &delta_node_01BD90 >
]

delta_node_01BD94 [
  delta-node < #$0006, &delta_node_01BD98 >
]

delta_node_01BD98 [
  delta-node < #$0006, &delta_node_01BD9C >
]

delta_node_01BD9C [
  delta-node < #$0006, &delta_node_01BDA0 >
]

delta_node_01BDA0 [
  delta-node < #$0006, &delta_node_01BDA4 >
]

delta_node_01BDA4 [
  delta-node < #$0006, &delta_node_01BDA8 >
]

delta_node_01BDA8 [
  delta-node < #$0005, &delta_node_01BDAC >
]

delta_node_01BDAC [
  delta-node < #$0005, &delta_node_01BDB0 >
]

delta_node_01BDB0 [
  delta-node < #$0005, &delta_node_01BDB4 >
]

delta_node_01BDB4 [
  delta-node < #$0005, &delta_node_01BDB8 >
]

delta_node_01BDB8 [
  delta-node < #$0004, &delta_node_01BDBC >
]

delta_node_01BDBC [
  delta-node < #$0004, &delta_node_01BDC0 >
]

delta_node_01BDC0 [
  delta-node < #$0004, &delta_node_01BDC4 >
]

delta_node_01BDC4 [
  delta-node < #$0003, &delta_node_01BDC8 >
]

delta_node_01BDC8 [
  delta-node < #$0003, &delta_node_01BDCC >
]

delta_node_01BDCC [
  delta-node < #$0002, &delta_node_01BDD0 >
]

delta_node_01BDD0 [
  delta-node < #$0001, &delta_node_01BDD0 >
]

delta_node_01BDD4 [
  delta-node < #$FFFE, &delta_node_01BDD8 >
]

delta_node_01BDD8 [
  delta-node < #$FFFE, &delta_node_01BDDC >
]

delta_node_01BDDC [
  delta-node < #$FFFF, &delta_node_01BDE0 >
]

delta_node_01BDE0 [
  delta-node < #$FFFF, &delta_node_01BDE4 >
]

delta_node_01BDE4 [
  delta-node < #$0000, &delta_node_01BDE8 >
]

delta_node_01BDE8 [
  delta-node < #$0000, &delta_node_01BDEC >
]

delta_node_01BDEC [
  delta-node < #$0001, &delta_node_01BDF0 >
]

delta_node_01BDF0 [
  delta-node < #$0001, &delta_node_01BDF4 >
]

delta_node_01BDF4 [
  delta-node < #$0002, &delta_node_01BDF8 >
]

delta_node_01BDF8 [
  delta-node < #$0002, &delta_node_01BDFC >
]

delta_node_01BDFC [
  delta-node < #$0000, &delta_node_01BDFC >
]

delta_node_01BE00 [
  delta-node < #$0000, &delta_node_01BE04 >
]

delta_node_01BE04 [
  delta-node < #$0000, &delta_node_01BE08 >
]

delta_node_01BE08 [
  delta-node < #$0000, &delta_node_01BE0C >
]

delta_node_01BE0C [
  delta-node < #$0000, &delta_node_01BE10 >
]

delta_node_01BE10 [
  delta-node < #$0000, &delta_node_01BE14 >
]

delta_node_01BE14 [
  delta-node < #$0000, &delta_node_01BE18 >
]

delta_node_01BE18 [
  delta-node < #$0003, &delta_node_01BE1C >
]

delta_node_01BE1C [
  delta-node < #$0003, &delta_node_01BE20 >
]

delta_node_01BE20 [
  delta-node < #$0003, &delta_node_01BE24 >
]

delta_node_01BE24 [
  delta-node < #$0003, &delta_node_01BE28 >
]

delta_node_01BE28 [
  delta-node < #$0003, &delta_node_01BE2C >
]

delta_node_01BE2C [
  delta-node < #$0003, &delta_node_01BE30 >
]

delta_node_01BE30 [
  delta-node < #$0003, &delta_node_01BE34 >
]

delta_node_01BE34 [
  delta-node < #$0003, &delta_node_01BE38 >
]

delta_node_01BE38 [
  delta-node < #$0003, &delta_node_01BE3C >
]

delta_node_01BE3C [
  delta-node < #$0003, &delta_node_01BE40 >
]

delta_node_01BE40 [
  delta-node < #$0003, &delta_node_01BE44 >
]

delta_node_01BE44 [
  delta-node < #$0003, &delta_node_01BE48 >
]

delta_node_01BE48 [
  delta-node < #$0003, &delta_node_01BE4C >
]

delta_node_01BE4C [
  delta-node < #$0003, &delta_node_01BE50 >
]

delta_node_01BE50 [
  delta-node < #$0003, &delta_node_01BE54 >
]

delta_node_01BE54 [
  delta-node < #$0003, &delta_node_01BE58 >
]

delta_node_01BE58 [
  delta-node < #$0003, &delta_node_01BE5C >
]

delta_node_01BE5C [
  delta-node < #$0003, &delta_node_01BE60 >
]

delta_node_01BE60 [
  delta-node < #$0003, &delta_node_01BE64 >
]

delta_node_01BE64 [
  delta-node < #$0001, &delta_node_01BE68 >
]

delta_node_01BE68 [
  delta-node < #$0001, &delta_node_01BE6C >
]

delta_node_01BE6C [
  delta-node < #$0001, &delta_node_01BE70 >
]

delta_node_01BE70 [
  delta-node < #$0001, &delta_node_01BE74 >
]

delta_node_01BE74 [
  delta-node < #$0000, &delta_node_01BE74 >
]

delta_node_01BE78 [
  delta-node < #$0001, &delta_node_01BE7C >
]

delta_node_01BE7C [
  delta-node < #$0000, &delta_node_01BE80 >
]

delta_node_01BE80 [
  delta-node < #$0001, &delta_node_01BE84 >
]

delta_node_01BE84 [
  delta-node < #$0000, &delta_node_01BE88 >
]

delta_node_01BE88 [
  delta-node < #$0001, &delta_node_01BE8C >
]

delta_node_01BE8C [
  delta-node < #$0000, &delta_node_01BE90 >
]

delta_node_01BE90 [
  delta-node < #$0001, &delta_node_01BE94 >
]

delta_node_01BE94 [
  delta-node < #$0000, &delta_node_01BE98 >
]

delta_node_01BE98 [
  delta-node < #$0000, &delta_node_01BE98 >
]

delta_node_01BE9C [
  delta-node < #$0001, &delta_node_01BEA0 >
]

delta_node_01BEA0 [
  delta-node < #$0001, &delta_node_01BEA4 >
]

delta_node_01BEA4 [
  delta-node < #$0001, &delta_node_01BEA8 >
]

delta_node_01BEA8 [
  delta-node < #$0001, &delta_node_01BEAC >
]

delta_node_01BEAC [
  delta-node < #$0002, &delta_node_01BEB0 >
]

delta_node_01BEB0 [
  delta-node < #$0002, &delta_node_01BEB4 >
]

delta_node_01BEB4 [
  delta-node < #$0002, &delta_node_01BEB8 >
]

delta_node_01BEB8 [
  delta-node < #$0002, &delta_node_01BEBC >
]

delta_node_01BEBC [
  delta-node < #$0003, &delta_node_01BEC0 >
]

delta_node_01BEC0 [
  delta-node < #$0003, &delta_node_01BEC4 >
]

delta_node_01BEC4 [
  delta-node < #$0003, &delta_node_01BEC8 >
]

delta_node_01BEC8 [
  delta-node < #$0003, &delta_node_01BECC >
]

delta_node_01BECC [
  delta-node < #$0002, &delta_node_01BED0 >
]

delta_node_01BED0 [
  delta-node < #$0002, &delta_node_01BED4 >
]

delta_node_01BED4 [
  delta-node < #$0002, &delta_node_01BED8 >
]

delta_node_01BED8 [
  delta-node < #$0002, &delta_node_01BEDC >
]

delta_node_01BEDC [
  delta-node < #$0002, &delta_node_01BEE0 >
]

delta_node_01BEE0 [
  delta-node < #$0002, &delta_node_01BEE4 >
]

delta_node_01BEE4 [
  delta-node < #$0002, &delta_node_01BEE8 >
]

delta_node_01BEE8 [
  delta-node < #$0002, &delta_node_01BEEC >
]

delta_node_01BEEC [
  delta-node < #$0000, &delta_node_01BEEC >
]

delta_node_01BEF0 [
  delta-node < #$FFFD, &delta_node_01BEF4 >
]

delta_node_01BEF4 [
  delta-node < #$FFFD, &delta_node_01BEF8 >
]

delta_node_01BEF8 [
  delta-node < #$FFFD, &delta_node_01BEFC >
]

delta_node_01BEFC [
  delta-node < #$FFFD, &delta_node_01BF00 >
]

delta_node_01BF00 [
  delta-node < #$FFFF, &delta_node_01BF04 >
]

delta_node_01BF04 [
  delta-node < #$FFFF, &delta_node_01BF08 >
]

delta_node_01BF08 [
  delta-node < #$FFFF, &delta_node_01BF0C >
]

delta_node_01BF0C [
  delta-node < #$FFFF, &delta_node_01BF10 >
]

delta_node_01BF10 [
  delta-node < #$FFFF, &delta_node_01BF14 >
]

delta_node_01BF14 [
  delta-node < #$FFFF, &delta_node_01BF18 >
]

delta_node_01BF18 [
  delta-node < #$FFFF, &delta_node_01BF1C >
]

delta_node_01BF1C [
  delta-node < #$FFFF, &delta_node_01BF20 >
]

delta_node_01BF20 [
  delta-node < #$0003, &delta_node_01BF24 >
]

delta_node_01BF24 [
  delta-node < #$0003, &delta_node_01BF28 >
]

delta_node_01BF28 [
  delta-node < #$0003, &delta_node_01BF2C >
]

delta_node_01BF2C [
  delta-node < #$0003, &delta_node_01BF30 >
]

delta_node_01BF30 [
  delta-node < #$0002, &delta_node_01BF34 >
]

delta_node_01BF34 [
  delta-node < #$0002, &delta_node_01BF38 >
]

delta_node_01BF38 [
  delta-node < #$0002, &delta_node_01BF3C >
]

delta_node_01BF3C [
  delta-node < #$0002, &delta_node_01BF40 >
]

delta_node_01BF40 [
  delta-node < #$0000, &delta_node_01BF40 >
]

delta_node_01BF44 [
  delta-node < #$FFFE, &delta_node_01BF48 >
]

delta_node_01BF48 [
  delta-node < #$FFFF, &delta_node_01BF4C >
]

delta_node_01BF4C [
  delta-node < #$0000, &delta_node_01BF50 >
]

delta_node_01BF50 [
  delta-node < #$0001, &delta_node_01BF54 >
]

delta_node_01BF54 [
  delta-node < #$0002, &delta_node_01BF58 >
]

delta_node_01BF58 [
  delta-node < #$0000, &delta_node_01BF5C >
]

delta_node_01BF5C [
  delta-node < #$FFFF, &delta_node_01BF60 >
]

delta_node_01BF60 [
  delta-node < #$0001, &delta_node_01BF64 >
]

delta_node_01BF64 [
  delta-node < #$0000, &delta_node_01BF68 >
]

delta_node_01BF68 [
  delta-node < #$0000, &delta_node_01BF6C >
]

delta_node_01BF6C [
  delta-node < #$FFFF, &delta_node_01BF70 >
]

delta_node_01BF70 [
  delta-node < #$0001, &delta_node_01BF74 >
]

delta_node_01BF74 [
  delta-node < #$0000, &delta_node_01BF78 >
]

delta_node_01BF78 [
  delta-node < #$FFFF, &delta_node_01BF7C >
]

delta_node_01BF7C [
  delta-node < #$0001, &delta_node_01BF80 >
]

delta_node_01BF80 [
  delta-node < #$0000, &delta_node_01BF84 >
]

delta_node_01BF84 [
  delta-node < #$0000, &delta_node_01BF84 >
]

delta_node_01BF88 [
  delta-node < #$0000, &delta_node_01BF8C >
]

delta_node_01BF8C [
  delta-node < #$0000, &delta_node_01BF90 >
]

delta_node_01BF90 [
  delta-node < #$0002, &delta_node_01BF94 >
]

delta_node_01BF94 [
  delta-node < #$0002, &delta_node_01BF98 >
]

delta_node_01BF98 [
  delta-node < #$0002, &delta_node_01BF9C >
]

delta_node_01BF9C [
  delta-node < #$0002, &delta_node_01BFA0 >
]

delta_node_01BFA0 [
  delta-node < #$0002, &delta_node_01BFA4 >
]

delta_node_01BFA4 [
  delta-node < #$0002, &delta_node_01BFA8 >
]

delta_node_01BFA8 [
  delta-node < #$0002, &delta_node_01BFAC >
]

delta_node_01BFAC [
  delta-node < #$0001, &delta_node_01BFB0 >
]

delta_node_01BFB0 [
  delta-node < #$0001, &delta_node_01BFB4 >
]

delta_node_01BFB4 [
  delta-node < #$0001, &delta_node_01BFB8 >
]

delta_node_01BFB8 [
  delta-node < #$0001, &delta_node_01BFBC >
]

delta_node_01BFBC [
  delta-node < #$0002, &delta_node_01BFC0 >
]

delta_node_01BFC0 [
  delta-node < #$0002, &delta_node_01BFC4 >
]

delta_node_01BFC4 [
  delta-node < #$0002, &delta_node_01BFC8 >
]

delta_node_01BFC8 [
  delta-node < #$0002, &delta_node_01BFCC >
]

delta_node_01BFCC [
  delta-node < #$0002, &delta_node_01BFD0 >
]

delta_node_01BFD0 [
  delta-node < #$0002, &delta_node_01BFD4 >
]

delta_node_01BFD4 [
  delta-node < #$0001, &delta_node_01BFD8 >
]

delta_node_01BFD8 [
  delta-node < #$0001, &delta_node_01BFDC >
]

delta_node_01BFDC [
  delta-node < #$0000, &delta_node_01BFDC >
]

delta_node_01BFE0 [
  delta-node < #$0000, &delta_node_01BFE4 >
]

delta_node_01BFE4 [
  delta-node < #$0000, &delta_node_01BFE8 >
]

delta_node_01BFE8 [
  delta-node < #$FFFD, &delta_node_01BFEC >
]

delta_node_01BFEC [
  delta-node < #$FFFD, &delta_node_01BFF0 >
]

delta_node_01BFF0 [
  delta-node < #$FFFD, &delta_node_01BFF4 >
]

delta_node_01BFF4 [
  delta-node < #$FFFD, &delta_node_01BFF8 >
]

delta_node_01BFF8 [
  delta-node < #$FFFD, &delta_node_01BFFC >
]

delta_node_01BFFC [
  delta-node < #$FFFD, &delta_node_01C000 >
]

delta_node_01C000 [
  delta-node < #$FFFD, &delta_node_01C004 >
]

delta_node_01C004 [
  delta-node < #$FFFD, &delta_node_01C008 >
]

delta_node_01C008 [
  delta-node < #$FFFD, &delta_node_01C00C >
]

delta_node_01C00C [
  delta-node < #$FFFD, &delta_node_01C010 >
]

delta_node_01C010 [
  delta-node < #$FFFD, &delta_node_01C014 >
]

delta_node_01C014 [
  delta-node < #$FFFD, &delta_node_01C018 >
]

delta_node_01C018 [
  delta-node < #$FFFD, &delta_node_01C01C >
]

delta_node_01C01C [
  delta-node < #$FFFD, &delta_node_01C020 >
]

delta_node_01C020 [
  delta-node < #$FFFD, &delta_node_01C024 >
]

delta_node_01C024 [
  delta-node < #$FFFD, &delta_node_01C028 >
]

delta_node_01C028 [
  delta-node < #$FFFD, &delta_node_01C02C >
]

delta_node_01C02C [
  delta-node < #$FFFD, &delta_node_01C030 >
]

delta_node_01C030 [
  delta-node < #$FFFD, &delta_node_01C034 >
]

delta_node_01C034 [
  delta-node < #$FFFD, &delta_node_01C038 >
]

delta_node_01C038 [
  delta-node < #$FFFD, &delta_node_01C03C >
]

delta_node_01C03C [
  delta-node < #$FFFD, &delta_node_01C040 >
]

delta_node_01C040 [
  delta-node < #$FFFD, &delta_node_01C044 >
]

delta_node_01C044 [
  delta-node < #$FFFD, &delta_node_01C048 >
]

delta_node_01C048 [
  delta-node < #$FFFD, &delta_node_01C04C >
]

delta_node_01C04C [
  delta-node < #$FFFD, &delta_node_01C050 >
]

delta_node_01C050 [
  delta-node < #$FFFE, &delta_node_01C054 >
]

delta_node_01C054 [
  delta-node < #$FFFE, &delta_node_01C058 >
]

delta_node_01C058 [
  delta-node < #$FFFE, &delta_node_01C05C >
]

delta_node_01C05C [
  delta-node < #$FFFE, &delta_node_01C060 >
]

delta_node_01C060 [
  delta-node < #$FFFE, &delta_node_01C064 >
]

delta_node_01C064 [
  delta-node < #$FFFE, &delta_node_01C068 >
]

delta_node_01C068 [
  delta-node < #$FFFF, &delta_node_01C06C >
]

delta_node_01C06C [
  delta-node < #$FFFF, &delta_node_01C070 >
]

delta_node_01C070 [
  delta-node < #$FFFF, &delta_node_01C074 >
]

delta_node_01C074 [
  delta-node < #$FFFF, &delta_node_01C078 >
]

delta_node_01C078 [
  delta-node < #$FFFF, &delta_node_01C07C >
]

delta_node_01C07C [
  delta-node < #$FFFF, &delta_node_01C080 >
]

delta_node_01C080 [
  delta-node < #$FFFF, &delta_node_01C084 >
]

delta_node_01C084 [
  delta-node < #$FFFF, &delta_node_01C088 >
]

delta_node_01C088 [
  delta-node < #$0000, &delta_node_01C088 >
]

delta_node_01C08C [
  delta-node < #$0000, &delta_node_01C090 >
]

delta_node_01C090 [
  delta-node < #$0000, &delta_node_01C094 >
]

delta_node_01C094 [
  delta-node < #$0002, &delta_node_01C098 >
]

delta_node_01C098 [
  delta-node < #$0002, &delta_node_01C09C >
]

delta_node_01C09C [
  delta-node < #$0002, &delta_node_01C0A0 >
]

delta_node_01C0A0 [
  delta-node < #$0002, &delta_node_01C0A4 >
]

delta_node_01C0A4 [
  delta-node < #$0002, &delta_node_01C0A8 >
]

delta_node_01C0A8 [
  delta-node < #$0002, &delta_node_01C0AC >
]

delta_node_01C0AC [
  delta-node < #$0002, &delta_node_01C0B0 >
]

delta_node_01C0B0 [
  delta-node < #$0002, &delta_node_01C0B4 >
]

delta_node_01C0B4 [
  delta-node < #$0002, &delta_node_01C0B8 >
]

delta_node_01C0B8 [
  delta-node < #$0002, &delta_node_01C0BC >
]

delta_node_01C0BC [
  delta-node < #$0002, &delta_node_01C0C0 >
]

delta_node_01C0C0 [
  delta-node < #$0002, &delta_node_01C0C4 >
]

delta_node_01C0C4 [
  delta-node < #$0002, &delta_node_01C0C8 >
]

delta_node_01C0C8 [
  delta-node < #$0002, &delta_node_01C0CC >
]

delta_node_01C0CC [
  delta-node < #$0002, &delta_node_01C0D0 >
]

delta_node_01C0D0 [
  delta-node < #$0002, &delta_node_01C0D4 >
]

delta_node_01C0D4 [
  delta-node < #$0002, &delta_node_01C0D8 >
]

delta_node_01C0D8 [
  delta-node < #$0002, &delta_node_01C0DC >
]

delta_node_01C0DC [
  delta-node < #$0002, &delta_node_01C0E0 >
]

delta_node_01C0E0 [
  delta-node < #$0002, &delta_node_01C0E4 >
]

delta_node_01C0E4 [
  delta-node < #$0002, &delta_node_01C0E8 >
]

delta_node_01C0E8 [
  delta-node < #$0002, &delta_node_01C0EC >
]

delta_node_01C0EC [
  delta-node < #$0001, &delta_node_01C0F0 >
]

delta_node_01C0F0 [
  delta-node < #$0001, &delta_node_01C0F4 >
]

delta_node_01C0F4 [
  delta-node < #$0001, &delta_node_01C0F8 >
]

delta_node_01C0F8 [
  delta-node < #$0001, &delta_node_01C0FC >
]

delta_node_01C0FC [
  delta-node < #$0001, &delta_node_01C100 >
]

delta_node_01C100 [
  delta-node < #$0001, &delta_node_01C104 >
]

delta_node_01C104 [
  delta-node < #$0002, &delta_node_01C108 >
]

delta_node_01C108 [
  delta-node < #$0002, &delta_node_01C10C >
]

delta_node_01C10C [
  delta-node < #$0000, &delta_node_01C10C >
]

delta_node_01C110 [
  delta-node < #$0000, &delta_node_01C114 >
]

delta_node_01C114 [
  delta-node < #$0000, &delta_node_01C118 >
]

delta_node_01C118 [
  delta-node < #$0000, &delta_node_01C11C >
]

delta_node_01C11C [
  delta-node < #$0000, &delta_node_01C120 >
]

delta_node_01C120 [
  delta-node < #$FFFF, &delta_node_01C124 >
]

delta_node_01C124 [
  delta-node < #$FFFF, &delta_node_01C128 >
]

delta_node_01C128 [
  delta-node < #$FFFE, &delta_node_01C12C >
]

delta_node_01C12C [
  delta-node < #$FFFE, &delta_node_01C130 >
]

delta_node_01C130 [
  delta-node < #$FFFD, &delta_node_01C134 >
]

delta_node_01C134 [
  delta-node < #$FFFD, &delta_node_01C138 >
]

delta_node_01C138 [
  delta-node < #$FFFC, &delta_node_01C13C >
]

delta_node_01C13C [
  delta-node < #$FFFC, &delta_node_01C140 >
]

delta_node_01C140 [
  delta-node < #$0000, &delta_node_01C144 >
]

delta_node_01C144 [
  delta-node < #$0000, &delta_node_01C148 >
]

delta_node_01C148 [
  delta-node < #$0001, &delta_node_01C14C >
]

delta_node_01C14C [
  delta-node < #$0001, &delta_node_01C150 >
]

delta_node_01C150 [
  delta-node < #$0002, &delta_node_01C154 >
]

delta_node_01C154 [
  delta-node < #$0002, &delta_node_01C158 >
]

delta_node_01C158 [
  delta-node < #$0003, &delta_node_01C15C >
]

delta_node_01C15C [
  delta-node < #$0003, &delta_node_01C160 >
]

delta_node_01C160 [
  delta-node < #$0004, &delta_node_01C164 >
]

delta_node_01C164 [
  delta-node < #$0004, &delta_node_01C168 >
]

delta_node_01C168 [
  delta-node < #$0006, &delta_node_01C16C >
]

delta_node_01C16C [
  delta-node < #$0006, &delta_node_01C170 >
]

delta_node_01C170 [
  delta-node < #$FFFE, &delta_node_01C174 >
]

delta_node_01C174 [
  delta-node < #$FFFE, &delta_node_01C178 >
]

delta_node_01C178 [
  delta-node < #$0006, &delta_node_01C17C >
]

delta_node_01C17C [
  delta-node < #$0006, &delta_node_01C180 >
]

delta_node_01C180 [
  delta-node < #$FFFE, &delta_node_01C184 >
]

delta_node_01C184 [
  delta-node < #$FFFE, &delta_node_01C188 >
]

delta_node_01C188 [
  delta-node < #$0006, &delta_node_01C18C >
]

delta_node_01C18C [
  delta-node < #$0006, &delta_node_01C190 >
]

delta_node_01C190 [
  delta-node < #$0000, &delta_node_01C190 >
]

delta_node_01C194 [
  delta-node < #$FFFC, &delta_node_01C198 >
]

delta_node_01C198 [
  delta-node < #$FFFC, &delta_node_01C19C >
]

delta_node_01C19C [
  delta-node < #$FFFC, &delta_node_01C1A0 >
]

delta_node_01C1A0 [
  delta-node < #$FFFC, &delta_node_01C1A4 >
]

delta_node_01C1A4 [
  delta-node < #$FFFC, &delta_node_01C1A8 >
]

delta_node_01C1A8 [
  delta-node < #$FFFC, &delta_node_01C1AC >
]

delta_node_01C1AC [
  delta-node < #$FFFC, &delta_node_01C1B0 >
]

delta_node_01C1B0 [
  delta-node < #$FFFC, &delta_node_01C1B4 >
]

delta_node_01C1B4 [
  delta-node < #$0006, &delta_node_01C1B8 >
]

delta_node_01C1B8 [
  delta-node < #$0006, &delta_node_01C1BC >
]

delta_node_01C1BC [
  delta-node < #$0006, &delta_node_01C1C0 >
]

delta_node_01C1C0 [
  delta-node < #$0006, &delta_node_01C1C4 >
]

delta_node_01C1C4 [
  delta-node < #$0006, &delta_node_01C1C8 >
]

delta_node_01C1C8 [
  delta-node < #$0006, &delta_node_01C1CC >
]

delta_node_01C1CC [
  delta-node < #$0006, &delta_node_01C1D0 >
]

delta_node_01C1D0 [
  delta-node < #$0006, &delta_node_01C1D4 >
]

delta_node_01C1D4 [
  delta-node < #$0006, &delta_node_01C1D8 >
]

delta_node_01C1D8 [
  delta-node < #$0006, &delta_node_01C1DC >
]

delta_node_01C1DC [
  delta-node < #$0006, &delta_node_01C1E0 >
]

delta_node_01C1E0 [
  delta-node < #$0006, &delta_node_01C1E4 >
]

delta_node_01C1E4 [
  delta-node < #$0006, &delta_node_01C1E8 >
]

delta_node_01C1E8 [
  delta-node < #$0006, &delta_node_01C1EC >
]

delta_node_01C1EC [
  delta-node < #$0006, &delta_node_01C1F0 >
]

delta_node_01C1F0 [
  delta-node < #$0006, &delta_node_01C1F4 >
]

delta_node_01C1F4 [
  delta-node < #$0000, &delta_node_01C1F4 >
]

delta_node_01C1F8 [
  delta-node < #$FFFE, &delta_node_01C1FC >
]

delta_node_01C1FC [
  delta-node < #$FFFE, &delta_node_01C200 >
]

delta_node_01C200 [
  delta-node < #$FFFE, &delta_node_01C204 >
]

delta_node_01C204 [
  delta-node < #$FFFD, &delta_node_01C208 >
]

delta_node_01C208 [
  delta-node < #$FFFD, &delta_node_01C20C >
]

delta_node_01C20C [
  delta-node < #$FFFD, &delta_node_01C210 >
]

delta_node_01C210 [
  delta-node < #$FFFD, &delta_node_01C214 >
]

delta_node_01C214 [
  delta-node < #$FFFC, &delta_node_01C218 >
]

delta_node_01C218 [
  delta-node < #$FFFC, &delta_node_01C21C >
]

delta_node_01C21C [
  delta-node < #$FFFB, &delta_node_01C220 >
]

delta_node_01C220 [
  delta-node < #$FFFB, &delta_node_01C224 >
]

delta_node_01C224 [
  delta-node < #$FFFB, &delta_node_01C228 >
]

delta_node_01C228 [
  delta-node < #$FFFB, &delta_node_01C22C >
]

delta_node_01C22C [
  delta-node < #$FFFB, &delta_node_01C230 >
]

delta_node_01C230 [
  delta-node < #$FFFA, &delta_node_01C234 >
]

delta_node_01C234 [
  delta-node < #$FFFA, &delta_node_01C238 >
]

delta_node_01C238 [
  delta-node < #$FFFA, &delta_node_01C23C >
]

delta_node_01C23C [
  delta-node < #$FFF9, &delta_node_01C240 >
]

delta_node_01C240 [
  delta-node < #$FFF9, &delta_node_01C244 >
]

delta_node_01C244 [
  delta-node < #$0006, &delta_node_01C248 >
]

delta_node_01C248 [
  delta-node < #$0006, &delta_node_01C24C >
]

delta_node_01C24C [
  delta-node < #$0005, &delta_node_01C250 >
]

delta_node_01C250 [
  delta-node < #$0001, &delta_node_01C254 >
]

delta_node_01C254 [
  delta-node < #$0001, &delta_node_01C258 >
]

delta_node_01C258 [
  delta-node < #$0000, &delta_node_01C258 >
]

delta_node_01C25C [
  delta-node < #$0000, &delta_node_01C260 >
]

delta_node_01C260 [
  delta-node < #$0000, &delta_node_01C264 >
]

delta_node_01C264 [
  delta-node < #$0000, &delta_node_01C268 >
]

delta_node_01C268 [
  delta-node < #$0000, &delta_node_01C26C >
]

delta_node_01C26C [
  delta-node < #$0001, &delta_node_01C26C >
]

delta_node_01C270 [
  delta-node < #$0000, &delta_node_01C274 >
]

delta_node_01C274 [
  delta-node < #$0000, &delta_node_01C278 >
]

delta_node_01C278 [
  delta-node < #$0000, &delta_node_01C27C >
]

delta_node_01C27C [
  delta-node < #$0000, &delta_node_01C280 >
]

delta_node_01C280 [
  delta-node < #$FFFF, &delta_node_01C280 >
]

delta_node_01C284 [
  delta-node < #$0000, &delta_node_01C288 >
]

delta_node_01C288 [
  delta-node < #$0000, &delta_node_01C28C >
]

delta_node_01C28C [
  delta-node < #$0000, &delta_node_01C290 >
]

delta_node_01C290 [
  delta-node < #$0000, &delta_node_01C294 >
]

delta_node_01C294 [
  delta-node < #$0000, &delta_node_01C298 >
]

delta_node_01C298 [
  delta-node < #$0000, &delta_node_01C29C >
]

delta_node_01C29C [
  delta-node < #$0000, &delta_node_01C2A0 >
]

delta_node_01C2A0 [
  delta-node < #$0000, &delta_node_01C2A4 >
]

delta_node_01C2A4 [
  delta-node < #$0000, &delta_node_01C2A8 >
]

delta_node_01C2A8 [
  delta-node < #$0000, &delta_node_01C2AC >
]

delta_node_01C2AC [
  delta-node < #$0000, &delta_node_01C2B0 >
]

delta_node_01C2B0 [
  delta-node < #$0000, &delta_node_01C2B4 >
]

delta_node_01C2B4 [
  delta-node < #$0000, &delta_node_01C2B8 >
]

delta_node_01C2B8 [
  delta-node < #$0000, &delta_node_01C2BC >
]

delta_node_01C2BC [
  delta-node < #$0000, &delta_node_01C2C0 >
]

delta_node_01C2C0 [
  delta-node < #$0000, &delta_node_01C2C4 >
]

delta_node_01C2C4 [
  delta-node < #$FFFF, &delta_node_01C2C8 >
]

delta_node_01C2C8 [
  delta-node < #$FFFF, &delta_node_01C2CC >
]

delta_node_01C2CC [
  delta-node < #$FFFF, &delta_node_01C2D0 >
]

delta_node_01C2D0 [
  delta-node < #$FFFF, &delta_node_01C2D4 >
]

delta_node_01C2D4 [
  delta-node < #$FFFF, &delta_node_01C2D8 >
]

delta_node_01C2D8 [
  delta-node < #$FFFF, &delta_node_01C2DC >
]

delta_node_01C2DC [
  delta-node < #$FFFF, &delta_node_01C2E0 >
]

delta_node_01C2E0 [
  delta-node < #$FFFF, &delta_node_01C2E4 >
]

delta_node_01C2E4 [
  delta-node < #$FFFF, &delta_node_01C2E8 >
]

delta_node_01C2E8 [
  delta-node < #$FFFF, &delta_node_01C2EC >
]

delta_node_01C2EC [
  delta-node < #$FFFF, &delta_node_01C2F0 >
]

delta_node_01C2F0 [
  delta-node < #$FFFF, &delta_node_01C2F4 >
]

delta_node_01C2F4 [
  delta-node < #$FFFF, &delta_node_01C2F8 >
]

delta_node_01C2F8 [
  delta-node < #$FFFF, &delta_node_01C2FC >
]

delta_node_01C2FC [
  delta-node < #$FFFF, &delta_node_01C300 >
]

delta_node_01C300 [
  delta-node < #$FFFF, &delta_node_01C284 >
]

delta_node_01C304 [
  delta-node < #$0000, &delta_node_01C308 >
]

delta_node_01C308 [
  delta-node < #$0000, &delta_node_01C30C >
]

delta_node_01C30C [
  delta-node < #$0000, &delta_node_01C310 >
]

delta_node_01C310 [
  delta-node < #$0000, &delta_node_01C314 >
]

delta_node_01C314 [
  delta-node < #$0000, &delta_node_01C318 >
]

delta_node_01C318 [
  delta-node < #$0000, &delta_node_01C31C >
]

delta_node_01C31C [
  delta-node < #$0000, &delta_node_01C320 >
]

delta_node_01C320 [
  delta-node < #$0000, &delta_node_01C324 >
]

delta_node_01C324 [
  delta-node < #$0000, &delta_node_01C328 >
]

delta_node_01C328 [
  delta-node < #$0000, &delta_node_01C32C >
]

delta_node_01C32C [
  delta-node < #$0000, &delta_node_01C330 >
]

delta_node_01C330 [
  delta-node < #$0000, &delta_node_01C334 >
]

delta_node_01C334 [
  delta-node < #$0000, &delta_node_01C338 >
]

delta_node_01C338 [
  delta-node < #$0000, &delta_node_01C33C >
]

delta_node_01C33C [
  delta-node < #$0000, &delta_node_01C340 >
]

delta_node_01C340 [
  delta-node < #$0000, &delta_node_01C344 >
]

delta_node_01C344 [
  delta-node < #$FFFC, &delta_node_01C348 >
]

delta_node_01C348 [
  delta-node < #$FFFC, &delta_node_01C34C >
]

delta_node_01C34C [
  delta-node < #$FFFE, &delta_node_01C350 >
]

delta_node_01C350 [
  delta-node < #$FFFE, &delta_node_01C354 >
]

delta_node_01C354 [
  delta-node < #$FFFF, &delta_node_01C358 >
]

delta_node_01C358 [
  delta-node < #$FFFF, &delta_node_01C35C >
]

delta_node_01C35C [
  delta-node < #$0000, &delta_node_01C360 >
]

delta_node_01C360 [
  delta-node < #$0000, &delta_node_01C364 >
]

delta_node_01C364 [
  delta-node < #$0000, &delta_node_01C368 >
]

delta_node_01C368 [
  delta-node < #$0000, &delta_node_01C36C >
]

delta_node_01C36C [
  delta-node < #$0001, &delta_node_01C370 >
]

delta_node_01C370 [
  delta-node < #$0001, &delta_node_01C374 >
]

delta_node_01C374 [
  delta-node < #$0002, &delta_node_01C378 >
]

delta_node_01C378 [
  delta-node < #$0002, &delta_node_01C37C >
]

delta_node_01C37C [
  delta-node < #$0004, &delta_node_01C380 >
]

delta_node_01C380 [
  delta-node < #$0004, &delta_node_01C304 >
]