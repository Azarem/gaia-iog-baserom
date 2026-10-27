; Music ID → SPC data ROM location mapping (bank 01). 30 entries of 3-byte long pointers (addr_lo, addr_hi, bank) to compressed BGM track data. Indexed 1-based: music ID n selects entry n-1 (hdma_dma_spc.asm reads `music_pointer_array-3 + 3n`), so ID $00 never indexes the table. Used by LoadMusicFromTransitionState for ID-driven music loads.
---------------------------------------------

?BANK 01

---------------------------------------------

; 30 long-pointer entries covering 27 distinct BGM tracks (bgm_lively_city appears 4 times, at entries $00, $01, $0C, $16). Entry index = music ID - 1, so entry $1B (bgm_lively_city_by_the_sea) is music ID $1C, which matches the `music < #1C, ... @bgm_lively_city_by_the_sea >` scene records. The repeated lively_city entries sit at IDs $01, $02, $0D and $17; IDs $0D/$17 look like placeholders for unused IDs (inferred). The no-music track is entry $1A (ID $1B). Referenced by hdma_dma_spc.asm: LoadMusicFromTransitionState computes musicTransitionState x 3, reads the entry at `table-3 + index` into $46/$47 and the `srcCacheMusic` shadow ($0687/$0688), then calls SpcBlockTransfer.

music_pointer_array [
  @bgm_lively_city   ;00
  @bgm_lively_city   ;01
  @bgm_blessing_of_nature   ;02
  @bgm_ominous_whispers   ;03
  @bgm_royal_anthem   ;04
  @bgm_descent_into_darkness   ;05
  @bgm_awakening_the_wind   ;06
  @bgm_secret_of_nazca   ;07
  @bgm_legendary_sunken_continent   ;08
  @bgm_golden_road   ;09
  @bgm_unexplored_temple   ;0A
  @bgm_great_pyramid   ;0B
  @bgm_lively_city   ;0C
  @bgm_longing_for_the_past   ;0D
  @bgm_guardians   ;0E
  @bgm_threat_of_dark_gaia   ;0F
  @bgm_deep_sadness   ;10
  @bgm_beautiful_world   ;11
  @bgm_bittersweet_victory   ;12
  @bgm_rebirth   ;13
  @bgm_drifting_endlessly   ;14
  @bgm_space_beyond_time   ;15
  @bgm_lively_city   ;16
  @bgm_important_item   ;17
  @bgm_lolas_melody   ;18
  @bgm_lost_incan_melody   ;19
  @bgm_no_music   ;1A
  @bgm_lively_city_by_the_sea   ;1B
  @bgm_waterfall   ;1C
  @bgm_melody_of_memories   ;1D
]