; Per-scene thinker spawn lists (Bank 0C, 845285-846683 = $0C:E5E5): a 256-word pointer table indexed by scene ID x 2 ($0646), followed by 70 lists of thinker-spawn records (204 records in all). SpawnSceneThinkers (thinker_execution) runs once per scene build: it reads scene_thinkers[$0646], allocates a thinker slot for every record up to the $FF terminator and calls InitThinkerFromSceneData. A zero pointer or a first byte with bit 7 set means no thinkers. The old note ('background AI thinkers: palette cyclers, HDMA effects, ambient handlers') was only half right: global_ambient_dispatcher, which 59 of the 70 lists contain, is the player palette and the talk interaction, not an ambient effect.
; 
; === RECORD (4 bytes, extraction: thinker-spawn < param, @code >) ===
; 
; | Byte | Field |
; |------|-------|
; | +0 | Spawn parameter: stored as animScratch+2 ($7F0002,X) of the new thinker. What it means is up to the code: the palette bundle ID for ambient_palette_cycler, the parallax_scroll_table index ($00-$24) for scanline_band_hdma_thinker, unused ($00) for most others |
; | +1..+3 | Long pointer to the thinker's code; its first word becomes the thinker's filter flags (animScratch2) and the entry point is code + 2 |
; 
; A list ends with a $FF byte (bit 7 of byte 0 is the test), which the extraction does not print.
; 
; === SHARING ===
; 
; - 70 of the 256 scenes use the bare list thinker_spawn_dispatcher_only (only global_ambient_dispatcher). Three more lists hold the same single record (0CE8E1 for scene $40, 0CE8EF and 0CE8F4 for scenes $4B and $4C).
; - 43 scenes point at thinker_spawn_0CE7EA+8: the table entry may point into the middle of another scene's list, so a scene starts at a later record. The offset is in hex and counts bytes (4 per record): +4 skips one record, +8 two. 0CE7EA holds ambient_palette_cycler ($3F), flag_gated_palette_cool, scanline_band_hdma_thinker ($02) and global_ambient_dispatcher, so +8 = scanline band $02 plus the dispatcher. Two scenes ($04, $07) enter it at +0 and 4 at +4. The other shifted entries: 0CE80C+4, 0CE843+4 (2), 0CE861+8 (4), 0CE87F+4, 0CE8A1+8, 0CE96F+8 (2), 0CE9E1+4 (8), 0CEA11+4 (6).
; - 67 of the 70 lists are reached from the table. Unreferenced: 0CE8E6 (scanline band $20 + dispatcher), 0CE9EA (palette bundles $01 and $32, dispatcher, scanline band $0F) and 0CEA45 (bundles $44 and $45 + dispatcher, a copy of 0CEA2F).
; - The dispatcher is the last record in most lists but the first in some (for example 0CE8C7, 0CE959, 0CE98D, 0CE99A, 0CE9A3, 0CE9AC); the credits list 0CEA5B has none.
; 
; === WHAT THE CODE FILES SAY ===
; 
; The block notes of ambient_palette_cycler, scanline_band_hdma_thinker and global_ambient_dispatcher describe the parameters. The 204 records are 59 ambient_palette_cycler, 59 global_ambient_dispatcher, 30 scanline_band_hdma_thinker and 56 spread over the other thinker code files. The list order is the spawn order. What each bundle or band looks like on screen was not traced.
; 
; Byte check: 1398 = 512 (256 pointers) + 204 x 4 (records) + 70 ($FF terminators). The ?INCLUDE list at the top names the 45 thinker code files the records point at.
---------------------------------------------

?BANK 0C

?INCLUDE 'ambient_palette_cycler'
?INCLUDE 'angel_tunnel_window_dma'
?INCLUDE 'babel_elevator_color_add'
?INCLUDE 'boot_logo_enix_palette_obj0'
?INCLUDE 'boot_logo_enix_palette_obj1'
?INCLUDE 'boot_logo_enix_palette_obj2'
?INCLUDE 'comet_lair_hdma_a'
?INCLUDE 'comet_lair_hdma_b'
?INCLUDE 'comet_lair_hdma_c_timed'
?INCLUDE 'crF7_credits_camera_pan'
?INCLUDE 'crF7_credits_dma_scroll'
?INCLUDE 'crF7_credits_hdma_flicker'
?INCLUDE 'dao_sine_hdma_slow'
?INCLUDE 'dao_window_mask'
?INCLUDE 'dark_castoth_layer_config'
?INCLUDE 'diary_menu_window_dma'
?INCLUDE 'dream_palette_loop'
?INCLUDE 'edward_castle_alarm_palette'
?INCLUDE 'ending_comet_dma_setup'
?INCLUDE 'ending_comet_sine_hdma'
?INCLUDE 'flag_gated_palette_cool'
?INCLUDE 'flag_gated_palette_warm'
?INCLUDE 'global_ambient_dispatcher'
?INCLUDE 'gold_ship_wreck_palette'
?INCLUDE 'hdma_circle_window_thinker'
?INCLUDE 'inventory_bg3_scroll_hdma'
?INCLUDE 'IrisCircleEffect'
?INCLUDE 'itory_village_fog'
?INCLUDE 'larai_cliff_scroll_wave'
?INCLUDE 'mode7_perspective'
?INCLUDE 'mu_tint_and_wave'
?INCLUDE 'native_village_sine_hdma'
?INCLUDE 'oneshot_coldata_r11g4b2'
?INCLUDE 'oneshot_coldata_warm_flash'
?INCLUDE 'palace_coffin_hdma_table'
?INCLUDE 'palace_fountain_palette'
?INCLUDE 'palace_scroll_brightness'
?INCLUDE 'palette_parent_child'
?INCLUDE 'scanline_band_hdma_thinker'
?INCLUDE 'sE7_space_bg_scroll'
?INCLUDE 'sE8_comet_display_config'
?INCLUDE 'sine_hdma_dual_channel'
?INCLUDE 'sine_hdma_ending_wave'
?INCLUDE 'sine_hdma_slow_wave'
?INCLUDE 'watermia_festival_palette'

---------------------------------------------

; 256 word pointers, index = scene ID. An entry may point into the middle of a list (the +4 / +8 suffix is the byte offset), see the block note.

scene_thinkers [
  &thinker_spawn_dispatcher_only   ;00
  &thinker_spawn_0CE80C+4   ;01
  &thinker_spawn_0CE7EA+8   ;02
  &thinker_spawn_0CE7EA+4   ;03
  &thinker_spawn_0CE7EA   ;04
  &thinker_spawn_0CE7EA+4   ;05
  &thinker_spawn_0CE7EA+4   ;06
  &thinker_spawn_0CE7EA   ;07
  &thinker_spawn_0CE7EA+4   ;08
  &thinker_spawn_dispatcher_only   ;09
  &thinker_spawn_0CE821   ;0A
  &thinker_spawn_dispatcher_only   ;0B
  &thinker_spawn_dispatcher_only   ;0C
  &thinker_spawn_0CE82E   ;0D
  &thinker_spawn_0CE82E   ;0E
  &thinker_spawn_0CE82E   ;0F
  &thinker_spawn_dispatcher_only   ;10
  &thinker_spawn_dispatcher_only   ;11
  &thinker_spawn_0CE82E   ;12
  &thinker_spawn_dispatcher_only   ;13
  &thinker_spawn_dispatcher_only   ;14
  &thinker_spawn_0CE843   ;15
  &thinker_spawn_0CE7EA+8   ;16
  &thinker_spawn_0CE7EA+8   ;17
  &thinker_spawn_0CE7EA+8   ;18
  &thinker_spawn_dispatcher_only   ;19
  &thinker_spawn_0CE843+4   ;1A
  &thinker_spawn_dispatcher_only   ;1B
  &thinker_spawn_0CE843+4   ;1C
  &thinker_spawn_0CE861   ;1D
  &thinker_spawn_dispatcher_only   ;1E
  &thinker_spawn_dispatcher_only   ;1F
  &thinker_spawn_0CE861+8   ;20
  &thinker_spawn_0CE8D4   ;21
  &thinker_spawn_0CE8D4   ;22
  &thinker_spawn_0CE850   ;23
  &thinker_spawn_dispatcher_only   ;24
  &thinker_spawn_0CE861+8   ;25
  &thinker_spawn_0CE861+8   ;26
  &thinker_spawn_0CE872   ;27
  &thinker_spawn_0CE861+8   ;28
  &thinker_spawn_0CE8C7   ;29
  &thinker_spawn_0CE7FB   ;2A
  &thinker_spawn_0CE87F   ;2B
  &thinker_spawn_0CE87F+4   ;2C
  &thinker_spawn_0CE8A1   ;2D
  &thinker_spawn_0CE8A1+8   ;2E
  &thinker_spawn_0CE890   ;2F
  &thinker_spawn_0CE80C   ;30
  &thinker_spawn_0CE7EA+8   ;31
  &thinker_spawn_0CE8BA   ;32
  &thinker_spawn_0CE7EA+8   ;33
  &thinker_spawn_0CE7EA+8   ;34
  &thinker_spawn_0CE7EA+8   ;35
  &thinker_spawn_0CE7EA+8   ;36
  &thinker_spawn_0CE7EA+8   ;37
  &thinker_spawn_0CE7EA+8   ;38
  &thinker_spawn_dispatcher_only   ;39
  &thinker_spawn_0CE7EA+8   ;3A
  &thinker_spawn_0CE7EA+8   ;3B
  &thinker_spawn_0CE7EA+8   ;3C
  &thinker_spawn_dispatcher_only   ;3D
  &thinker_spawn_0CE9E1+4   ;3E
  &thinker_spawn_0CE9E1+4   ;3F
  &thinker_spawn_0CE8E1   ;40
  &thinker_spawn_0CE9E1+4   ;41
  &thinker_spawn_0CE9E1   ;42
  &thinker_spawn_0CE9E1+4   ;43
  &thinker_spawn_0CE9E1+4   ;44
  &thinker_spawn_0CE9E1+4   ;45
  &thinker_spawn_0CE9E1+4   ;46
  &thinker_spawn_0CE9E1+4   ;47
  &thinker_spawn_dispatcher_only   ;48
  &thinker_spawn_0CE7EA+8   ;49
  &thinker_spawn_dispatcher_only   ;4A
  &thinker_spawn_0CE8EF   ;4B
  &thinker_spawn_0CE8F4   ;4C
  &thinker_spawn_0CE8F9   ;4D
  &thinker_spawn_0CE906   ;4E
  &thinker_spawn_0CE913   ;4F
  &thinker_spawn_0CE920   ;50
  &thinker_spawn_0CE92D   ;51
  &thinker_spawn_0CE93A   ;52
  &thinker_spawn_0CE947   ;53
  &thinker_spawn_0CE950   ;54
  &thinker_spawn_0CE959   ;55
  &thinker_spawn_0CE7EA+8   ;56
  &thinker_spawn_dispatcher_only   ;57
  &thinker_spawn_dispatcher_only   ;58
  &thinker_spawn_0CE962   ;59
  &thinker_spawn_0CE96F+8   ;5A
  &thinker_spawn_0CE96F+8   ;5B
  &thinker_spawn_0CE96F   ;5C
  &thinker_spawn_0CE984   ;5D
  &thinker_spawn_0CE7EA+8   ;5E
  &thinker_spawn_0CE98D   ;5F
  &thinker_spawn_0CE98D   ;60
  &thinker_spawn_0CE98D   ;61
  &thinker_spawn_0CE98D   ;62
  &thinker_spawn_dispatcher_only   ;63
  &thinker_spawn_0CE98D   ;64
  &thinker_spawn_0CE98D   ;65
  &thinker_spawn_dispatcher_only   ;66
  &thinker_spawn_0CE99A   ;67
  &thinker_spawn_0CEA11+4   ;68
  &thinker_spawn_dispatcher_only   ;69
  &thinker_spawn_0CEA11+4   ;6A
  &thinker_spawn_0CEA11   ;6B
  &thinker_spawn_0CEA11+4   ;6C
  &thinker_spawn_0CEA11+4   ;6D
  &thinker_spawn_dispatcher_only   ;6E
  &thinker_spawn_0CEA26   ;6F
  &thinker_spawn_0CEA11+4   ;70
  &thinker_spawn_dispatcher_only   ;71
  &thinker_spawn_dispatcher_only   ;72
  &thinker_spawn_0CEA11+4   ;73
  &thinker_spawn_0CE9A3   ;74
  &thinker_spawn_dispatcher_only   ;75
  &thinker_spawn_dispatcher_only   ;76
  &thinker_spawn_dispatcher_only   ;77
  &thinker_spawn_0CE9AC   ;78
  &thinker_spawn_0CE7EA+8   ;79
  &thinker_spawn_0CE7EA+8   ;7A
  &thinker_spawn_0CE7EA+8   ;7B
  &thinker_spawn_0CE7EA+8   ;7C
  &thinker_spawn_0CE7EA+8   ;7D
  &thinker_spawn_0CE7EA+8   ;7E
  &thinker_spawn_0CE9AC   ;7F
  &thinker_spawn_dispatcher_only   ;80
  &thinker_spawn_dispatcher_only   ;81
  &thinker_spawn_0CE9B5   ;82
  &thinker_spawn_0CE9B5   ;83
  &thinker_spawn_0CE9BE   ;84
  &thinker_spawn_0CE9CB   ;85
  &thinker_spawn_0CE9B5   ;86
  &thinker_spawn_0CE9B5   ;87
  &thinker_spawn_0CE9B5   ;88
  &thinker_spawn_dispatcher_only   ;89
  &thinker_spawn_0CE9D4   ;8A
  &thinker_spawn_0CE9B5   ;8B
  &thinker_spawn_0CEB2A   ;8C
  &thinker_spawn_dispatcher_only   ;8D
  &thinker_spawn_dispatcher_only   ;8E
  &thinker_spawn_dispatcher_only   ;8F
  &thinker_spawn_dispatcher_only   ;90
  &thinker_spawn_dispatcher_only   ;91
  &thinker_spawn_0CE7EA+8   ;92
  &thinker_spawn_0CE7EA+8   ;93
  &thinker_spawn_0CE7EA+8   ;94
  &thinker_spawn_0CE7EA+8   ;95
  &thinker_spawn_0CE7EA+8   ;96
  &thinker_spawn_0CE7EA+8   ;97
  &thinker_spawn_0CE7EA+8   ;98
  &thinker_spawn_0CE7EA+8   ;99
  &thinker_spawn_0CE7EA+8   ;9A
  &thinker_spawn_0CE7EA+8   ;9B
  &thinker_spawn_0CE7EA+8   ;9C
  &thinker_spawn_0CE7EA+8   ;9D
  &thinker_spawn_dispatcher_only   ;9E
  &thinker_spawn_0CE9FB   ;9F
  &thinker_spawn_0CE9FB   ;A0
  &thinker_spawn_0CE9FB   ;A1
  &thinker_spawn_0CE9FB   ;A2
  &thinker_spawn_0CE9FB   ;A3
  &thinker_spawn_0CE9FB   ;A4
  &thinker_spawn_0CE9FB   ;A5
  &thinker_spawn_0CE9FB   ;A6
  &thinker_spawn_0CE9FB   ;A7
  &thinker_spawn_0CE9FB   ;A8
  &thinker_spawn_0CE9FB   ;A9
  &thinker_spawn_dispatcher_only   ;AA
  &thinker_spawn_dispatcher_only   ;AB
  &thinker_spawn_0CEA08   ;AC
  &thinker_spawn_0CE7EA+8   ;AD
  &thinker_spawn_0CE7EA+8   ;AE
  &thinker_spawn_dispatcher_only   ;AF
  &thinker_spawn_dispatcher_only   ;B0
  &thinker_spawn_dispatcher_only   ;B1
  &thinker_spawn_dispatcher_only   ;B2
  &thinker_spawn_dispatcher_only   ;B3
  &thinker_spawn_dispatcher_only   ;B4
  &thinker_spawn_dispatcher_only   ;B5
  &thinker_spawn_dispatcher_only   ;B6
  &thinker_spawn_dispatcher_only   ;B7
  &thinker_spawn_dispatcher_only   ;B8
  &thinker_spawn_dispatcher_only   ;B9
  &thinker_spawn_dispatcher_only   ;BA
  &thinker_spawn_dispatcher_only   ;BB
  &thinker_spawn_dispatcher_only   ;BC
  &thinker_spawn_dispatcher_only   ;BD
  &thinker_spawn_dispatcher_only   ;BE
  &thinker_spawn_dispatcher_only   ;BF
  &thinker_spawn_dispatcher_only   ;C0
  &thinker_spawn_dispatcher_only   ;C1
  &thinker_spawn_dispatcher_only   ;C2
  &thinker_spawn_0CEA6C   ;C3
  &thinker_spawn_0CE7EA+8   ;C4
  &thinker_spawn_0CE7EA+8   ;C5
  &thinker_spawn_0CE7EA+8   ;C6
  &thinker_spawn_0CE7EA+8   ;C7
  &thinker_spawn_0CE7EA+8   ;C8
  &thinker_spawn_0CE7EA+8   ;C9
  &thinker_spawn_dispatcher_only   ;CA
  &thinker_spawn_dispatcher_only   ;CB
  &thinker_spawn_0CEA2F   ;CC
  &thinker_spawn_0CEA3C   ;CD
  &thinker_spawn_0CEA2F   ;CE
  &thinker_spawn_0CEA2F   ;CF
  &thinker_spawn_0CEA2F   ;D0
  &thinker_spawn_0CEA2F   ;D1
  &thinker_spawn_0CEA2F   ;D2
  &thinker_spawn_0CEA2F   ;D3
  &thinker_spawn_0CEA2F   ;D4
  &thinker_spawn_0CEA2F   ;D5
  &thinker_spawn_0CEA2F   ;D6
  &thinker_spawn_0CEA2F   ;D7
  &thinker_spawn_0CEA2F   ;D8
  &thinker_spawn_0CEA2F   ;D9
  &thinker_spawn_0CEA2F   ;DA
  &thinker_spawn_0CEA2F   ;DB
  &thinker_spawn_dispatcher_only   ;DC
  &thinker_spawn_0CEA52   ;DD
  &thinker_spawn_dispatcher_only   ;DE
  &thinker_spawn_0CEA81   ;DF
  &thinker_spawn_0CEA81   ;E0
  &thinker_spawn_0CEA8E   ;E1
  &thinker_spawn_dispatcher_only   ;E2
  &thinker_spawn_0CEA81   ;E3
  &thinker_spawn_dispatcher_only   ;E4
  &thinker_spawn_0CEA9B   ;E5
  &thinker_spawn_0CEAAC   ;E6
  &thinker_spawn_0CEAB5   ;E7
  &thinker_spawn_0CEABA   ;E8
  &thinker_spawn_0CEB07   ;E9
  &thinker_spawn_0CEB07   ;EA
  &thinker_spawn_0CEAAC   ;EB
  &thinker_spawn_0CEAAC   ;EC
  &thinker_spawn_0CEAAC   ;ED
  &thinker_spawn_0CEAAC   ;EE
  &thinker_spawn_dispatcher_only   ;EF
  &thinker_spawn_dispatcher_only   ;F0
  &thinker_spawn_dispatcher_only   ;F1
  &thinker_spawn_0CEAFA   ;F2
  &thinker_spawn_0CEAD3   ;F3
  &thinker_spawn_0CEAAC   ;F4
  &thinker_spawn_0CEAE0   ;F5
  &thinker_spawn_0CEAED   ;F6
  &thinker_spawn_0CEA5B   ;F7
  &thinker_spawn_dispatcher_only   ;F8
  &thinker_spawn_dispatcher_only   ;F9
  &thinker_spawn_0CEB18   ;FA
  &thinker_spawn_0CEB1D   ;FB
  &thinker_spawn_0CEB2F   ;FC
  &thinker_spawn_0CEB30   ;FD
  &thinker_spawn_0CEB3D   ;FE
  &thinker_spawn_0CEB46   ;FF
]

---------------------------------------------
; The bare list: only global_ambient_dispatcher. Used by 70 scenes.

thinker_spawn_dispatcher_only [
  thinker-spawn < #00, @global_ambient_dispatcher >
]

---------------------------------------------
; Shared default list: ambient_palette_cycler (bundle $3F), flag_gated_palette_cool, scanline_band_hdma_thinker (band $02), global_ambient_dispatcher. Entered at +0 by 2 scenes, at +4 by 4 and at +8 by 43.

thinker_spawn_0CE7EA [
  thinker-spawn < #3F, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @flag_gated_palette_cool >   ;01
  thinker-spawn < #02, @scanline_band_hdma_thinker >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CE7FB [
  thinker-spawn < #00, @dream_palette_loop >   ;00
  thinker-spawn < #02, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
  thinker-spawn < #00, @hdma_circle_window_thinker.circle_window_thinker_v2 >   ;03
]

thinker_spawn_0CE80C [
  thinker-spawn < #00, @oneshot_coldata_r11g4b2 >   ;00
  thinker-spawn < #01, @ambient_palette_cycler >   ;01
  thinker-spawn < #3F, @ambient_palette_cycler >   ;02
  thinker-spawn < #02, @flag_gated_palette_warm >   ;03
  thinker-spawn < #00, @global_ambient_dispatcher >   ;04
]

thinker_spawn_0CE821 [
  thinker-spawn < #00, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #05, @edward_castle_alarm_palette >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE82E [
  thinker-spawn < #00, @ambient_palette_cycler >   ;00
  thinker-spawn < #06, @ambient_palette_cycler >   ;01
  thinker-spawn < #07, @ambient_palette_cycler >   ;02
  thinker-spawn < #12, @ambient_palette_cycler >   ;03
  thinker-spawn < #00, @global_ambient_dispatcher >   ;04
]

thinker_spawn_0CE843 [
  thinker-spawn < #00, @itory_village_fog >   ;00
  thinker-spawn < #01, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE850 [
  thinker-spawn < #30, @ambient_palette_cycler >   ;00
  thinker-spawn < #31, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @oneshot_coldata_warm_flash >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CE861 [
  thinker-spawn < #0B, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #00, @larai_cliff_scroll_wave >   ;01
  thinker-spawn < #13, @ambient_palette_cycler >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CE872 [
  thinker-spawn < #00, @oneshot_coldata_warm_flash >   ;00
  thinker-spawn < #13, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE87F [
  thinker-spawn < #06, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #05, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @gold_ship_wreck_palette >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CE890 [
  thinker-spawn < #06, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #0E, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @gold_ship_wreck_palette >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CE8A1 [
  thinker-spawn < #07, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #06, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #08, @scanline_band_hdma_thinker >   ;02
  thinker-spawn < #05, @scanline_band_hdma_thinker >   ;03
  thinker-spawn < #00, @gold_ship_wreck_palette >   ;04
  thinker-spawn < #00, @global_ambient_dispatcher >   ;05
]

thinker_spawn_0CE8BA [
  thinker-spawn < #00, @sine_hdma_slow_wave >   ;00
  thinker-spawn < #49, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE8C7 [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #28, @ambient_palette_cycler >   ;01
  thinker-spawn < #0A, @scanline_band_hdma_thinker >   ;02
]

thinker_spawn_0CE8D4 [
  thinker-spawn < #30, @ambient_palette_cycler >   ;00
  thinker-spawn < #31, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE8E1 [
  thinker-spawn < #00, @global_ambient_dispatcher >
]

---------------------------------------------
; Unreferenced by the table: scanline_band_hdma_thinker band $20 and global_ambient_dispatcher (OQ-I072-3).

thinker_spawn_0CE8E6 [
  thinker-spawn < #20, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE8EF [
  thinker-spawn < #00, @global_ambient_dispatcher >
]

thinker_spawn_0CE8F4 [
  thinker-spawn < #00, @global_ambient_dispatcher >
]

thinker_spawn_0CE8F9 [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE906 [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE913 [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE920 [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE92D [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE93A [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE947 [
  thinker-spawn < #32, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE950 [
  thinker-spawn < #32, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE959 [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #3D, @ambient_palette_cycler >   ;01
]

thinker_spawn_0CE962 [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #1D, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE96F [
  thinker-spawn < #00, @palace_coffin_hdma_table >   ;00
  thinker-spawn < #1B, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
  thinker-spawn < #00, @sine_hdma_dual_channel >   ;03
  thinker-spawn < #00, @palace_scroll_brightness >   ;04
]

thinker_spawn_0CE984 [
  thinker-spawn < #00, @palace_fountain_palette >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE98D [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #00, @mu_tint_and_wave >   ;01
  thinker-spawn < #01, @ambient_palette_cycler >   ;02
]

thinker_spawn_0CE99A [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #00, @hdma_circle_window_thinker.circle_window_thinker_v2 >   ;01
]

thinker_spawn_0CE9A3 [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #00, @angel_tunnel_window_dma >   ;01
]

thinker_spawn_0CE9AC [
  thinker-spawn < #00, @global_ambient_dispatcher >   ;00
  thinker-spawn < #48, @watermia_festival_palette >   ;01
]

thinker_spawn_0CE9B5 [
  thinker-spawn < #1E, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE9BE [
  thinker-spawn < #1F, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #47, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE9CB [
  thinker-spawn < #21, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CE9D4 [
  thinker-spawn < #1F, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #4F, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CE9E1 [
  thinker-spawn < #6B, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

---------------------------------------------
; Unreferenced by the table: palette bundles $01 and $32, global_ambient_dispatcher and scanline band $0F (OQ-I072-3).

thinker_spawn_0CE9EA [
  thinker-spawn < #01, @ambient_palette_cycler >   ;00
  thinker-spawn < #32, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
  thinker-spawn < #0F, @scanline_band_hdma_thinker >   ;03
]

thinker_spawn_0CE9FB [
  thinker-spawn < #4D, @ambient_palette_cycler >   ;00
  thinker-spawn < #4E, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEA08 [
  thinker-spawn < #00, @native_village_sine_hdma >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CEA11 [
  thinker-spawn < #1C, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #3A, @ambient_palette_cycler >   ;01
  thinker-spawn < #3B, @ambient_palette_cycler >   ;02
  thinker-spawn < #3C, @ambient_palette_cycler >   ;03
  thinker-spawn < #00, @global_ambient_dispatcher >   ;04
]

thinker_spawn_0CEA26 [
  thinker-spawn < #00, @sine_hdma_dual_channel >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CEA2F [
  thinker-spawn < #44, @ambient_palette_cycler >   ;00
  thinker-spawn < #45, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEA3C [
  thinker-spawn < #68, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

---------------------------------------------
; Unreferenced by the table: a copy of thinker_spawn_0CEA2F (bundles $44 and $45 and the dispatcher) (OQ-I072-3).

thinker_spawn_0CEA45 [
  thinker-spawn < #44, @ambient_palette_cycler >   ;00
  thinker-spawn < #45, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEA52 [
  thinker-spawn < #5E, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CEA5B [
  thinker-spawn < #00, @crF7_credits_hdma_flicker >   ;00
  thinker-spawn < #00, @crF7_credits_dma_scroll >   ;01
  thinker-spawn < #00, @hdma_circle_window_thinker.circle_window_thinker_v1 >   ;02
  thinker-spawn < #00, @crF7_credits_camera_pan >   ;03
]

thinker_spawn_0CEA6C [
  thinker-spawn < #00, @dao_sine_hdma_slow >   ;00
  thinker-spawn < #20, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #01, @ambient_palette_cycler >   ;02
  thinker-spawn < #00, @dao_window_mask >   ;03
  thinker-spawn < #00, @global_ambient_dispatcher >   ;04
]

thinker_spawn_0CEA81 [
  thinker-spawn < #02, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #23, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEA8E [
  thinker-spawn < #23, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #00, @babel_elevator_color_add >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEA9B [
  thinker-spawn < #74, @ambient_palette_cycler >   ;00
  thinker-spawn < #00, @ending_comet_dma_setup >   ;01
  thinker-spawn < #00, @ending_comet_sine_hdma >   ;02
  thinker-spawn < #24, @scanline_band_hdma_thinker >   ;03
]

thinker_spawn_0CEAAC [
  thinker-spawn < #00, @sine_hdma_ending_wave >   ;00
  thinker-spawn < #00, @global_ambient_dispatcher >   ;01
]

thinker_spawn_0CEAB5 [
  thinker-spawn < #00, @sE7_space_bg_scroll >
]

thinker_spawn_0CEABA [
  thinker-spawn < #00, @sE8_comet_display_config >   ;00
  thinker-spawn < #71, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @ending_comet_dma_setup >   ;02
  thinker-spawn < #00, @comet_lair_hdma_a >   ;03
  thinker-spawn < #00, @comet_lair_hdma_b >   ;04
  thinker-spawn < #00, @comet_lair_hdma_c_timed >   ;05
]

thinker_spawn_0CEAD3 [
  thinker-spawn < #00, @sine_hdma_ending_wave >   ;00
  thinker-spawn < #3D, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEAE0 [
  thinker-spawn < #00, @sine_hdma_ending_wave >   ;00
  thinker-spawn < #79, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEAED [
  thinker-spawn < #00, @sine_hdma_ending_wave >   ;00
  thinker-spawn < #7B, @ambient_palette_cycler >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEAFA [
  thinker-spawn < #00, @dark_castoth_layer_config >   ;00
  thinker-spawn < #00, @sine_hdma_ending_wave >   ;01
  thinker-spawn < #00, @global_ambient_dispatcher >   ;02
]

thinker_spawn_0CEB07 [
  thinker-spawn < #00, @sine_hdma_slow_wave >   ;00
  thinker-spawn < #61, @ambient_palette_cycler >   ;01
  thinker-spawn < #7E, @ambient_palette_cycler >   ;02
  thinker-spawn < #00, @global_ambient_dispatcher >   ;03
]

thinker_spawn_0CEB18 [
  thinker-spawn < #00, @diary_menu_window_dma >
]

thinker_spawn_0CEB1D [
  thinker-spawn < #01, @boot_logo_enix_palette_obj0 >   ;00
  thinker-spawn < #02, @boot_logo_enix_palette_obj1 >   ;01
  thinker-spawn < #03, @boot_logo_enix_palette_obj2 >   ;02
]

thinker_spawn_0CEB2A [
  thinker-spawn < #00, @IrisCircleEffect >
]

thinker_spawn_0CEB2F [
]

thinker_spawn_0CEB30 [
  thinker-spawn < #03, @scanline_band_hdma_thinker >   ;00
  thinker-spawn < #03, @palette_parent_child >   ;01
  thinker-spawn < #3E, @ambient_palette_cycler >   ;02
]

thinker_spawn_0CEB3D [
  thinker-spawn < #00, @mode7_perspective.Mode7PerspectiveInit >   ;00
  thinker-spawn < #00, @IrisCircleEffect >   ;01
]

thinker_spawn_0CEB46 [
  thinker-spawn < #00, @inventory_bg3_scroll_hdma >   ;00
  thinker-spawn < #03, @scanline_band_hdma_thinker >   ;01
  thinker-spawn < #03, @palette_parent_child >   ;02
  thinker-spawn < #3E, @ambient_palette_cycler >   ;03
  thinker-spawn < #64, @ambient_palette_cycler >   ;04
]