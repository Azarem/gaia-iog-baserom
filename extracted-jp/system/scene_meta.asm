?BANK 0D

?INCLUDE 'palette_bundles'

---------------------------------------------

scene_meta [
  scene-meta < #$0000, [
    display-mode < #00 >   ;00
    bitmap < #00, #10, #00, @gfx_fonts, #02 >   ;01
    palette < #00, #80, #80, @pal_southcape_sprites >   ;02
  ] >   ;00
  scene-meta < #$0001, [
    display-mode < #03 >   ;00
    music < #1C, #00, @bgm_lively_city_by_the_sea >   ;01
    bitmap < #00, #10, #00, @gfx_southcape, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_southcape >   ;04
    tileset < #00, #20, #00, #01, @set_southcape >   ;05
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;06
    tilemap < #01, @map_sc01 >   ;07
    tilemap < #02, @map_sc01_effect >   ;08
    label < #3E >   ;09
    bitmap < #00, #10, #10, @gfx_southcape_sprites, #01 >   ;0A
    palette < #20, #80, #A0, @pal_southcape_sprites >   ;0B
    spritemap < #$17F4, #00, @spm_southcape_sprites >   ;0C
  ] >   ;01
  scene-meta < #$0002, [
    display-mode < #05 >   ;00
    music < #1C, #00, @bgm_lively_city_by_the_sea >   ;01
    tilemap < #01, @map_sc02 >   ;02
    bitmap < #00, #10, #00, @gfx_cave, #00 >   ;03
    palette < #00, #70, #10, @pal_cave >   ;04
    tileset < #00, #20, #00, #01, @set_cave >   ;05
    label < #03 >   ;06
    bitmap < #00, #10, #10, @gfx_sc02_main_characters, #01 >   ;07
    palette < #00, #60, #A0, @pal_sc02_main_characters >   ;08
    spritemap < #$1463, #00, @spm_sc02_main_characters >   ;09
  ] >   ;02
  scene-meta < #$0003, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    tilemap < #01, @map_sc03 >   ;02
    tilemap < #02, @map_southcape_interior_effect >   ;03
    palette < #00, #70, #10, @pal_southcape_interior_2 >   ;04
    label < #01 >   ;05
    bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >   ;06
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;07
    tileset < #00, #20, #00, #01, @set_southcape_interior >   ;08
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;09
    jump < #3E >   ;0A
  ] >   ;03
  scene-meta < #$0004, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    palette < #00, #70, #10, @pal_southcape_interior_2 >   ;02
    tilemap < #01, @map_sc04 >   ;03
    tilemap < #02, @map_sc04_effect >   ;04
    jump < #01 >   ;05
  ] >   ;04
  scene-meta < #$0005, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    palette < #00, #70, #10, @pal_southcape_interior >   ;02
    tilemap < #01, @map_sc05 >   ;03
    tilemap < #02, @map_southcape_interior_effect >   ;04
    jump < #01 >   ;05
  ] >   ;05
  scene-meta < #$0006, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    music < #1B, #01, @bgm_no_music >   ;02
    palette < #00, #70, #10, @pal_southcape_interior_3 >   ;03
    tilemap < #01, @map_sc06 >   ;04
    tilemap < #02, @map_sc06_effect >   ;05
    branch < #4C, #01 >   ;06
    branch < #21, #23 >   ;07
    label < #07 >   ;08
    bitmap < #00, #10, #10, @gfx_sc06_castle_actors, #01 >   ;09
    palette < #00, #60, #A0, @pal_sc06_castle_actors >   ;0A
    spritemap < #$1279, #00, @spm_sc06_castle_actors >   ;0B
    jump < #24 >   ;0C
    label < #23 >   ;0D
    bitmap < #00, #10, #10, @gfx_sc02_main_characters, #01 >   ;0E
    palette < #00, #60, #A0, @pal_sc02_main_characters >   ;0F
    spritemap < #$1463, #00, @spm_sc02_main_characters >   ;10
    label < #24 >   ;11
    bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >   ;12
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;13
    tileset < #00, #20, #00, #01, @set_southcape_interior >   ;14
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;15
  ] >   ;06
  scene-meta < #$0007, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    palette < #00, #70, #10, @pal_southcape_interior >   ;02
    tilemap < #01, @map_sc07 >   ;03
    tilemap < #02, @map_southcape_interior_effect >   ;04
    jump < #01 >   ;05
  ] >   ;07
  scene-meta < #$0008, [
    display-mode < #01 >   ;00
    music < #1D, #00, @bgm_lively_city_by_the_sea >   ;01
    bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_southcape_interior_2 >   ;04
    tileset < #00, #20, #00, #01, @set_southcape_interior >   ;05
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;06
    tilemap < #01, @map_sc08 >   ;07
    tilemap < #02, @map_sc08_effect >   ;08
    jump < #03 >   ;09
  ] >   ;08
  scene-meta < #$000A, [
    display-mode < #02 >   ;00
    music < #05, #00, @bgm_royal_anthem >   ;01
    bitmap < #00, #20, #00, @gfx_castle, #00 >   ;02
    palette < #00, #70, #10, @pal_castle >   ;03
    tileset < #00, #20, #00, #01, @set_castle >   ;04
    tileset < #00, #20, #00, #02, @set_castle_effect >   ;05
    tilemap < #01, @map_ec0A >   ;06
    tilemap < #02, @map_ec0A_effect >   ;07
    bitmap < #00, #10, #10, @gfx_castle_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_castle_sprites >   ;09
    spritemap < #$12D9, #00, @spm_castle_sprites >   ;0A
  ] >   ;09
  scene-meta < #$000B, [
    display-mode < #06 >   ;00
    music < #1B, #00, @bgm_no_music >   ;01
    bitmap < #00, #10, #00, @gfx_prison, #00 >   ;02
    palette < #00, #70, #10, @pal_prison >   ;03
    tileset < #00, #20, #00, #01, @set_prison >   ;04
    tilemap < #01, @map_ec0B >   ;05
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;07
    tilemap < #02, @map_ec0B_effect >   ;08
    bitmap < #00, #10, #10, @gfx_sc06_castle_actors, #01 >   ;09
    palette < #00, #60, #A0, @pal_sc06_castle_actors >   ;0A
    spritemap < #$1279, #00, @spm_sc06_castle_actors >   ;0B
  ] >   ;0A
  scene-meta < #$000C, [
    display-mode < #05 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec0C >   ;02
    label < #02 >   ;03
    bitmap < #00, #10, #10, @gfx_prison_enemies, #01 >   ;04
    palette < #00, #60, #A0, @pal_prison_enemies >   ;05
    spritemap < #$21D0, #00, @spm_prison_enemies >   ;06
    label < #30 >   ;07
    bitmap < #00, #10, #00, @gfx_prison, #00 >   ;08
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;09
    palette < #00, #70, #10, @pal_prison_2 >   ;0A
    tileset < #00, #20, #00, #01, @set_prison >   ;0B
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;0C
  ] >   ;0B
  scene-meta < #$000D, [
    display-mode < #03 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec0D >   ;02
    tilemap < #02, @map_ec0D_effect >   ;03
    jump < #02 >   ;04
  ] >   ;0C
  scene-meta < #$000E, [
    display-mode < #03 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec0E >   ;02
    tilemap < #02, @map_sc0E_effect >   ;03
    jump < #02 >   ;04
  ] >   ;0D
  scene-meta < #$000F, [
    display-mode < #03 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec0F >   ;02
    tilemap < #02, @map_ec0F_effect >   ;03
    jump < #02 >   ;04
  ] >   ;0E
  scene-meta < #$0010, [
    display-mode < #05 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec10 >   ;02
    bitmap < #00, #10, #10, @gfx_darkspace_sprites, #01 >   ;03
    palette < #00, #60, #90, @pal_darkspace_sprites >   ;04
    spritemap < #$0579, #00, @spm_darkspace_sprites >   ;05
    jump < #30 >   ;06
  ] >   ;0F
  scene-meta < #$0011, [
    display-mode < #0B >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec11 >   ;02
    jump < #02 >   ;03
  ] >   ;10
  scene-meta < #$0012, [
    display-mode < #03 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_ec12 >   ;02
    tilemap < #02, @map_ec12_effect >   ;03
    jump < #02 >   ;04
  ] >   ;11
  scene-meta < #$0013, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_prison, #00 >   ;02
    palette < #00, #70, #10, @pal_prison >   ;03
    tileset < #00, #20, #00, #01, @set_prison >   ;04
    tilemap < #01, @map_ec13 >   ;05
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;07
    tilemap < #02, @map_ec12_effect >   ;08
    jump < #03 >   ;09
  ] >   ;12
  scene-meta < #$0014, [
    display-mode < #00 >
  ] >   ;13
  scene-meta < #$0015, [
    display-mode < #04 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    tilemap < #01, @map_it15 >   ;02
    tilemap < #02, @map_itory_effect >   ;03
    bitmap < #00, #10, #00, @gfx_itory, #00 >   ;04
    bitmap < #00, #10, #10, @gfx_itory_effect, #00 >   ;05
    palette < #00, #70, #10, @pal_itory >   ;06
    tileset < #00, #20, #00, #01, @set_itory >   ;07
    tileset < #00, #20, #00, #02, @set_itory_effect >   ;08
    label < #04 >   ;09
    bitmap < #00, #10, #10, @gfx_itory_sprites, #01 >   ;0A
    palette < #00, #60, #A0, @pal_itory_sprites >   ;0B
    spritemap < #$14DB, #00, @spm_itory_sprites >   ;0C
  ] >   ;14
  scene-meta < #$0016, [
    display-mode < #01 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    tilemap < #01, @map_it16 >   ;02
    tilemap < #02, @map_itory_interior_effect >   ;03
    label < #08 >   ;04
    bitmap < #00, #10, #00, @gfx_itory_interior, #00 >   ;05
    bitmap < #00, #10, #10, @gfx_itory_effect, #00 >   ;06
    palette < #00, #70, #10, @pal_itory_interior >   ;07
    tileset < #00, #20, #00, #01, @set_itory_interior >   ;08
    tileset < #00, #20, #00, #02, @set_itory_effect >   ;09
    jump < #04 >   ;0A
  ] >   ;15
  scene-meta < #$0017, [
    display-mode < #01 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    tilemap < #01, @map_it17 >   ;02
    tilemap < #02, @map_itory_interior_effect >   ;03
    jump < #08 >   ;04
  ] >   ;16
  scene-meta < #$0018, [
    display-mode < #01 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    tilemap < #01, @map_it18 >   ;02
    tilemap < #02, @map_it18_effect >   ;03
    jump < #08 >   ;04
  ] >   ;17
  scene-meta < #$0019, [
    display-mode < #05 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_cave, #00 >   ;02
    palette < #00, #70, #10, @pal_cave >   ;03
    tileset < #00, #20, #00, #01, @set_cave >   ;04
    tilemap < #01, @map_it19 >   ;05
    jump < #04 >   ;06
  ] >   ;18
  scene-meta < #$001A, [
    display-mode < #04 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_itory, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_itory_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_itory >   ;04
    tileset < #00, #20, #00, #01, @set_itory >   ;05
    tileset < #00, #20, #00, #02, @set_itory_effect >   ;06
    tilemap < #01, @map_it1A >   ;07
    tilemap < #02, @map_itory_effect >   ;08
    jump < #04 >   ;09
  ] >   ;19
  scene-meta < #$001B, [
    display-mode < #05 >   ;00
    music < #04, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_cave, #00 >   ;02
    palette < #00, #70, #10, @pal_cave >   ;03
    tileset < #00, #20, #00, #01, @set_cave >   ;04
    tilemap < #01, @map_it1B >   ;05
    jump < #05 >   ;06
  ] >   ;1A
  scene-meta < #$001C, [
    display-mode < #04 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_itory, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_itory_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_itory >   ;04
    tileset < #00, #20, #00, #01, @set_itory >   ;05
    tileset < #00, #20, #00, #02, @set_itory_effect >   ;06
    tilemap < #01, @map_ir1C_main >   ;07
    tilemap < #02, @map_itory_effect >   ;08
    jump < #04 >   ;09
  ] >   ;1B
  scene-meta < #$001D, [
    display-mode < #0F >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #20, #00, @gfx_cliff, #00 >   ;02
    palette < #00, #70, #10, @pal_cliff >   ;03
    tileset < #00, #20, #00, #01, @set_cliff >   ;04
    tilemap < #01, @map_ir1D >   ;05
    tileset < #00, #20, #00, #02, @set_cliff_effect >   ;06
    tilemap < #02, @map_ir1D_effect >   ;07
    label < #05 >   ;08
    bitmap < #00, #10, #10, @gfx_cliff_enemies, #01 >   ;09
    palette < #00, #60, #A0, @pal_cliff_enemies >   ;0A
    spritemap < #$0F2A, #00, @spm_cliff_enemies >   ;0B
  ] >   ;1C
  scene-meta < #$001E, [
    display-mode < #18 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #20, #00, @gfx_cliff, #00 >   ;02
    palette < #00, #70, #10, @pal_cliff >   ;03
    tileset < #00, #20, #00, #01, @set_cliff >   ;04
    tilemap < #01, @map_ir1E >   ;05
    tileset < #00, #20, #00, #02, @set_cliff_effect >   ;06
    tilemap < #02, @map_ir1E_effect >   ;07
    jump < #05 >   ;08
  ] >   ;1D
  scene-meta < #$001F, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir1F >   ;05
    label < #06 >   ;06
    bitmap < #00, #10, #10, @gfx_ruins_enemies, #01 >   ;07
    palette < #00, #60, #A0, @pal_ruins_enemies >   ;08
    spritemap < #$2336, #00, @spm_ruins_enemies >   ;09
  ] >   ;1E
  scene-meta < #$0020, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir20 >   ;05
    jump < #05 >   ;06
  ] >   ;1F
  scene-meta < #$0021, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir21 >   ;05
    jump < #06 >   ;06
  ] >   ;20
  scene-meta < #$0022, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir22 >   ;05
    jump < #06 >   ;06
  ] >   ;21
  scene-meta < #$0023, [
    display-mode < #0A >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_ruins, #00 >   ;03
    palette < #00, #70, #10, @pal_ruins >   ;04
    tileset < #00, #20, #00, #01, @set_ruins >   ;05
    tileset < #00, #20, #00, #02, @set_ruins >   ;06
    tilemap < #01, @map_ir23 >   ;07
    tilemap < #02, @map_ir21 >   ;08
    jump < #06 >   ;09
  ] >   ;22
  scene-meta < #$0024, [
    display-mode < #11 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_ruins, #00 >   ;03
    palette < #00, #70, #10, @pal_ruins >   ;04
    tileset < #00, #20, #00, #01, @set_ruins >   ;05
    tileset < #00, #20, #00, #02, @set_ruins >   ;06
    tilemap < #01, @map_ir24 >   ;07
    tilemap < #02, @map_ir24_effect >   ;08
    jump < #06 >   ;09
  ] >   ;23
  scene-meta < #$0025, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir25 >   ;05
    jump < #05 >   ;06
  ] >   ;24
  scene-meta < #$0026, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir26 >   ;05
    jump < #05 >   ;06
  ] >   ;25
  scene-meta < #$0027, [
    display-mode < #0A >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_ruins, #00 >   ;03
    palette < #00, #70, #10, @pal_ruins >   ;04
    tileset < #00, #20, #00, #01, @set_ruins >   ;05
    tileset < #00, #20, #00, #02, @set_ruins >   ;06
    tilemap < #01, @map_ir27 >   ;07
    tilemap < #02, @map_ir26 >   ;08
    jump < #05 >   ;09
  ] >   ;26
  scene-meta < #$0028, [
    display-mode < #08 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    palette < #00, #70, #10, @pal_ruins >   ;03
    tileset < #00, #20, #00, #01, @set_ruins >   ;04
    tilemap < #01, @map_ir28 >   ;05
    jump < #05 >   ;06
  ] >   ;27
  scene-meta < #$0029, [
    display-mode < #07 >   ;00
    music < #07, #00, @bgm_awakening_the_wind >   ;01
    bitmap < #00, #10, #00, @gfx_ruins, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_ruins, #00 >   ;03
    palette < #20, #70, #30, @pal_ruins >   ;04
    tileset < #00, #20, #00, #01, @set_ruins >   ;05
    tileset < #00, #20, #00, #02, @set_ruins >   ;06
    tilemap < #01, @map_ir29 >   ;07
    tilemap < #02, @map_ir29_effect >   ;08
    palette < #00, #60, #A0, @pal_castoth >   ;09
    label < #39 >   ;0A
    bitmap < #00, #10, #10, @gfx_castoth, #01 >   ;0B
    spritemap < #$1941, #00, @spm_castoth >   ;0C
  ] >   ;28
  scene-meta < #$002A, [
    display-mode < #01 >   ;00
    music < #11, #00, @bgm_deep_sadness >   ;01
    bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_southcape_interior >   ;04
    tileset < #00, #20, #00, #01, @set_southcape_interior >   ;05
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;06
    tilemap < #01, @map_sc06 >   ;07
    tilemap < #02, @map_sc06_effect >   ;08
    jump < #04 >   ;09
  ] >   ;29
  scene-meta < #$002B, [
    display-mode < #0D >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    music < #06, #01, @bgm_descent_into_darkness >   ;02
    music < #03, #02, @bgm_blessing_of_nature >   ;03
    label < #0B >   ;04
    bitmap < #00, #20, #00, @gfx_shipwreck, #00 >   ;05
    palette < #00, #70, #10, @pal_shipwreck >   ;06
    tileset < #00, #20, #00, #01, @set_shipwreck >   ;07
    tilemap < #01, @map_gs2B >   ;08
    tileset < #00, #20, #00, #02, @set_goldship_effect >   ;09
    tilemap < #02, @map_goldship_effect >   ;0A
    jump < #03 >   ;0B
  ] >   ;2A
  scene-meta < #$002C, [
    display-mode < #0D >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    music < #06, #01, @bgm_descent_into_darkness >   ;02
    music < #03, #02, @bgm_blessing_of_nature >   ;03
    bitmap < #00, #20, #00, @gfx_goldship, #00 >   ;04
    palette < #00, #70, #10, @pal_goldship >   ;05
    tileset < #00, #20, #00, #01, @set_goldship >   ;06
    tilemap < #01, @map_gs2C >   ;07
    tileset < #00, #20, #00, #02, @set_goldship_effect >   ;08
    tilemap < #02, @map_goldship_effect >   ;09
    label < #3F >   ;0A
    bitmap < #00, #10, #10, @gfx_goldship_sprites, #01 >   ;0B
    palette < #00, #60, #A0, @pal_goldship_sprites >   ;0C
    spritemap < #$0A91, #00, @spm_goldship_sprites >   ;0D
  ] >   ;2B
  scene-meta < #$002D, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    music < #06, #01, @bgm_descent_into_darkness >   ;02
    music < #03, #02, @bgm_blessing_of_nature >   ;03
    bitmap < #00, #20, #00, @gfx_shipwreck, #00 >   ;04
    palette < #00, #70, #10, @pal_shipwreck_interior >   ;05
    tileset < #00, #20, #00, #01, @set_goldship_interior >   ;06
    tilemap < #01, @map_gs2D >   ;07
    tileset < #00, #20, #00, #02, @set_goldship_effect >   ;08
    tilemap < #02, @map_goldship_effect >   ;09
    jump < #03 >   ;0A
  ] >   ;2C
  scene-meta < #$002E, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    music < #06, #01, @bgm_descent_into_darkness >   ;02
    music < #03, #02, @bgm_blessing_of_nature >   ;03
    bitmap < #00, #20, #00, @gfx_goldship, #00 >   ;04
    palette < #00, #70, #10, @pal_goldship_interior >   ;05
    tileset < #00, #20, #00, #01, @set_goldship_interior >   ;06
    tilemap < #01, @map_gs2E >   ;07
    tileset < #00, #20, #00, #02, @set_goldship_effect >   ;08
    tilemap < #02, @map_goldship_effect >   ;09
    jump < #3F >   ;0A
  ] >   ;2D
  scene-meta < #$002F, [
    display-mode < #0D >   ;00
    music < #15, #00, @bgm_drifting_endlessly >   ;01
    bitmap < #00, #20, #00, @gfx_adrift, #00 >   ;02
    palette < #00, #70, #10, @pal_adrift >   ;03
    tileset < #00, #20, #00, #01, @set_adrift >   ;04
    tilemap < #01, @map_gs2F >   ;05
    tileset < #00, #20, #00, #02, @set_adrift >   ;06
    tilemap < #02, @map_gs2F_effect >   ;07
    jump < #04 >   ;08
  ] >   ;2E
  scene-meta < #$0030, [
    display-mode < #06 >   ;00
    music < #1B, #00, @bgm_no_music >   ;01
    bitmap < #00, #10, #00, @gfx_southcape, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_southcape >   ;04
    tileset < #00, #20, #00, #01, @set_southcape >   ;05
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;06
    tilemap < #01, @map_fr30 >   ;07
    tilemap < #02, @map_fr30_effect >   ;08
    jump < #04 >   ;09
  ] >   ;2F
  scene-meta < #$0031, [
    display-mode < #01 >   ;00
    music < #1B, #00, @bgm_no_music >   ;01
    palette < #00, #70, #10, @pal_southcape_interior >   ;02
    tileset < #00, #20, #00, #01, @set_southcape_interior >   ;03
    tileset < #00, #20, #00, #02, @set_southcape_effect >   ;04
    tilemap < #01, @map_fr31 >   ;05
    tilemap < #02, @map_southcape_interior_effect >   ;06
    bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >   ;07
    bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >   ;08
    jump < #0C >   ;09
  ] >   ;30
  scene-meta < #$0032, [
    display-mode < #0E >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_freejia, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_freejia, #00 >   ;03
    palette < #00, #70, #10, @pal_freejia >   ;04
    tileset < #00, #20, #00, #01, @set_freejia >   ;05
    tilemap < #01, @map_fr32 >   ;06
    tileset < #00, #20, #00, #02, @set_freejia_effect >   ;07
    tilemap < #02, @map_fr32_effect >   ;08
    label < #0C >   ;09
    bitmap < #00, #10, #10, @gfx_freejia_sprites, #01 >   ;0A
    palette < #00, #60, #A0, @pal_freejia_sprites >   ;0B
    spritemap < #$124C, #00, @spm_freejia_sprites >   ;0C
  ] >   ;31
  scene-meta < #$0033, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_freejia_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_house_interior_dark >   ;04
    tileset < #00, #20, #00, #01, @set_freejia_interior >   ;05
    tileset < #00, #20, #00, #02, @set_freejia_interior >   ;06
    tilemap < #01, @map_fr33 >   ;07
    tilemap < #02, @map_fr33_effect >   ;08
    jump < #03 >   ;09
  ] >   ;32
  scene-meta < #$0034, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr34 >   ;02
    tilemap < #02, @map_fr34_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_dark >   ;04
    label < #1C >   ;05
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;06
    bitmap < #00, #10, #10, @gfx_freejia_effect, #00 >   ;07
    tileset < #00, #20, #00, #01, @set_freejia_interior >   ;08
    tileset < #00, #20, #00, #02, @set_freejia_interior >   ;09
    jump < #0C >   ;0A
  ] >   ;33
  scene-meta < #$0035, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr35 >   ;02
    tilemap < #02, @map_fr35_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_dark >   ;04
    jump < #1C >   ;05
  ] >   ;34
  scene-meta < #$0036, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr36 >   ;02
    tilemap < #02, @map_fr36_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_light >   ;04
    jump < #1C >   ;05
  ] >   ;35
  scene-meta < #$0037, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr37 >   ;02
    tilemap < #02, @map_fr37_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_light >   ;04
    jump < #1C >   ;05
  ] >   ;36
  scene-meta < #$0038, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr38 >   ;02
    tilemap < #02, @map_fr38_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_light >   ;04
    jump < #1C >   ;05
  ] >   ;37
  scene-meta < #$0039, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_freejia_effect, #00 >   ;03
    tileset < #00, #20, #00, #01, @set_freejia_interior >   ;04
    tileset < #00, #20, #00, #02, @set_freejia_interior >   ;05
    palette < #00, #70, #10, @pal_house_interior_light >   ;06
    tilemap < #01, @map_fr39 >   ;07
    tilemap < #02, @map_fr39_effect >   ;08
    jump < #03 >   ;09
  ] >   ;38
  scene-meta < #$003A, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr3A >   ;02
    tilemap < #02, @map_fr3A_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_light >   ;04
    jump < #1C >   ;05
  ] >   ;39
  scene-meta < #$003B, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_fr3B >   ;02
    tilemap < #02, @map_fr3B_effect >   ;03
    palette < #00, #70, #10, @pal_house_interior_light >   ;04
    jump < #1C >   ;05
  ] >   ;3A
  scene-meta < #$003C, [
    display-mode < #05 >   ;00
    music < #06, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_cave, #00 >   ;02
    palette < #00, #70, #10, @pal_cave_dark >   ;03
    tileset < #00, #20, #00, #01, @set_cave >   ;04
    tilemap < #01, @map_fr3C >   ;05
    jump < #0C >   ;06
  ] >   ;3B
  scene-meta < #$003D, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_mine, #00 >   ;02
    palette < #00, #70, #10, @pal_mine >   ;03
    tileset < #00, #20, #00, #01, @set_mine >   ;04
    tilemap < #01, @map_dm3D >   ;05
    jump < #0E >   ;06
  ] >   ;3C
  scene-meta < #$003E, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm3E >   ;02
    label < #10 >   ;03
    bitmap < #00, #10, #00, @gfx_mine, #00 >   ;04
    palette < #00, #70, #10, @pal_mine >   ;05
    tileset < #00, #20, #00, #01, @set_mine >   ;06
    label < #0E >   ;07
    bitmap < #00, #10, #10, @gfx_mine_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_mine_sprites >   ;09
    spritemap < #$2930, #00, @spm_mine_sprites >   ;0A
  ] >   ;3D
  scene-meta < #$003F, [
    display-mode < #05 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm3F >   ;02
    jump < #10 >   ;03
  ] >   ;3E
  scene-meta < #$0040, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm40 >   ;02
    jump < #10 >   ;03
  ] >   ;3F
  scene-meta < #$0041, [
    display-mode < #00 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_mine, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_mine, #00 >   ;03
    palette < #00, #70, #10, @pal_mine >   ;04
    tileset < #00, #20, #00, #03, @set_mine >   ;05
    tilemap < #01, @map_dm41 >   ;06
    tilemap < #02, @map_dm43 >   ;07
    jump < #0E >   ;08
  ] >   ;40
  scene-meta < #$0042, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm42 >   ;02
    jump < #10 >   ;03
  ] >   ;41
  scene-meta < #$0043, [
    display-mode < #0A >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_mine, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_mine, #00 >   ;03
    palette < #00, #70, #10, @pal_mine >   ;04
    tileset < #00, #20, #00, #03, @set_mine >   ;05
    tilemap < #01, @map_dm43 >   ;06
    tilemap < #02, @map_dm41 >   ;07
    jump < #0E >   ;08
  ] >   ;42
  scene-meta < #$0044, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm44 >   ;02
    jump < #10 >   ;03
  ] >   ;43
  scene-meta < #$0045, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm45 >   ;02
    jump < #10 >   ;03
  ] >   ;44
  scene-meta < #$0046, [
    display-mode < #08 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    tilemap < #01, @map_dm46 >   ;02
    jump < #10 >   ;03
  ] >   ;45
  scene-meta < #$0047, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_mine, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_mine, #00 >   ;03
    palette < #00, #70, #10, @pal_mine >   ;04
    tileset < #00, #20, #00, #01, @set_mine >   ;05
    tilemap < #01, @map_dm47 >   ;06
    jump < #0C >   ;07
  ] >   ;46
  scene-meta < #$0049, [
    display-mode < #1F >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_freejia_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior >   ;05
    tilemap < #01, @map_neilscottage >   ;06
    tilemap < #02, @map_neilscottage_effect >   ;07
    label < #22 >   ;08
    bitmap < #00, #10, #10, @gfx_nazca_sprites, #01 >   ;09
    palette < #00, #60, #A0, @pal_nazca_sprites >   ;0A
    spritemap < #$1507, #00, @spm_nazca_sprites >   ;0B
  ] >   ;47
  scene-meta < #$004B, [
    display-mode < #13 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_cave, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_cave, #00 >   ;03
    palette < #00, #70, #10, @pal_cave_nazca >   ;04
    tileset < #00, #20, #00, #03, @set_cave >   ;05
    tilemap < #01, @map_nazca >   ;06
    tilemap < #02, @map_nazca_effect >   ;07
    jump < #22 >   ;08
  ] >   ;48
  scene-meta < #$004C, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_main >   ;05
    tileset < #00, #20, #00, #02, @set_garden_effect >   ;06
    tilemap < #02, @map_garden_effect >   ;07
    label < #0D >   ;08
    bitmap < #00, #10, #10, @gfx_garden_enemies, #01 >   ;09
    palette < #00, #60, #A0, @pal_garden_enemies >   ;0A
    spritemap < #$1D54, #00, @spm_garden_enemies >   ;0B
  ] >   ;49
  scene-meta < #$004D, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_east >   ;05
    tileset < #00, #20, #00, #02, @set_garden_effect >   ;06
    tilemap < #02, @map_garden_effect >   ;07
    jump < #0D >   ;08
  ] >   ;4A
  scene-meta < #$004E, [
    display-mode < #10 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_underside >   ;03
    tileset < #00, #20, #00, #01, @set_garden_underside >   ;04
    tilemap < #01, @map_garden_east_underside >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_garden_underside_effect >   ;07
    label < #0F >   ;08
    bitmap < #00, #10, #10, @gfx_garden_enemies, #01 >   ;09
    palette < #00, #60, #A0, @pal_garden_enemies_alt >   ;0A
    spritemap < #$1D54, #00, @spm_garden_enemies >   ;0B
  ] >   ;4B
  scene-meta < #$004F, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_southeast >   ;05
    tileset < #00, #20, #00, #02, @set_garden_effect >   ;06
    tilemap < #02, @map_garden_effect >   ;07
    jump < #0D >   ;08
  ] >   ;4C
  scene-meta < #$0050, [
    display-mode < #10 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_underside >   ;03
    tileset < #00, #20, #00, #01, @set_garden_underside >   ;04
    tilemap < #01, @map_garden_southeast_underside >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_garden_underside_effect >   ;07
    jump < #0F >   ;08
  ] >   ;4D
  scene-meta < #$0051, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_southwest >   ;05
    tileset < #00, #20, #00, #02, @set_garden_effect >   ;06
    tilemap < #02, @map_garden_effect >   ;07
    jump < #0D >   ;08
  ] >   ;4E
  scene-meta < #$0052, [
    display-mode < #10 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_underside >   ;03
    tileset < #00, #20, #00, #01, @set_garden_underside >   ;04
    tilemap < #01, @map_garden_southwest_underside >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_garden_underside_effect >   ;07
    jump < #0F >   ;08
  ] >   ;4F
  scene-meta < #$0053, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_west >   ;05
    tileset < #00, #20, #00, #02, @set_garden_effect >   ;06
    tilemap < #02, @map_garden_effect >   ;07
    jump < #0D >   ;08
  ] >   ;50
  scene-meta < #$0054, [
    display-mode < #12 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_underside >   ;03
    tileset < #00, #20, #00, #01, @set_garden_underside >   ;04
    tilemap < #01, @map_garden_west_underside >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_garden_underside_effect >   ;07
    jump < #0F >   ;08
  ] >   ;51
  scene-meta < #$0055, [
    display-mode < #17 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_clouds >   ;03
    tileset < #00, #20, #00, #01, @set_garden >   ;04
    tilemap < #01, @map_garden_viper >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_clouds >   ;07
    palette < #00, #60, #A0, @pal_viper >   ;08
    label < #3A >   ;09
    bitmap < #00, #10, #10, @gfx_viper, #01 >   ;0A
    spritemap < #$15DE, #00, @spm_viper >   ;0B
  ] >   ;52
  scene-meta < #$0056, [
    display-mode < #18 >   ;00
    music < #08, #00, @bgm_secret_of_nazca >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace_garden >   ;04
    tileset < #00, #20, #00, #01, @set_palace_mu >   ;05
    tilemap < #01, @map_sg56 >   ;06
    bitmap < #00, #10, #10, @gfx_garden_enemies, #01 >   ;07
    palette < #00, #60, #A0, @pal_garden_enemies_alt >   ;08
    spritemap < #$1D54, #00, @spm_garden_enemies >   ;09
  ] >   ;53
  scene-meta < #$0058, [
    display-mode < #17 >   ;00
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;01
    palette < #00, #70, #10, @pal_garden_clouds >   ;02
    tileset < #00, #20, #00, #01, @set_garden_underside_effect >   ;03
    tilemap < #01, @map_clouds >   ;04
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;05
    tilemap < #02, @map_clouds >   ;06
    label < #38 >   ;07
    bitmap < #00, #10, #10, @gfx_descent_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_descent_sprites >   ;09
    spritemap < #$0642, #00, @spm_descent_sprites >   ;0A
  ] >   ;54
  scene-meta < #$0059, [
    display-mode < #19 >   ;00
    palette < #00, #70, #10, @pal_southcape >   ;01
    tileset < #00, #20, #00, #01, @set_southcape_effect >   ;02
    bitmap < #00, #10, #00, @gfx_southcape_effect, #00 >   ;03
    tilemap < #01, @map_sg59 >   ;04
    jump < #38 >   ;05
  ] >   ;55
  scene-meta < #$005A, [
    display-mode < #15 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace >   ;04
    tileset < #00, #20, #00, #01, @set_palace >   ;05
    tilemap < #01, @map_palace_main >   ;06
    tileset < #00, #20, #00, #02, @set_palace_effect >   ;07
    tilemap < #02, @map_palace_effect >   ;08
    branch < #70, #0C >   ;09
    bitmap < #00, #10, #10, @gfx_prison_enemies, #01 >   ;0A
    palette < #00, #60, #A0, @pal_prison_enemies >   ;0B
    spritemap < #$21D0, #00, @spm_prison_enemies >   ;0C
  ] >   ;56
  scene-meta < #$005B, [
    display-mode < #15 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace >   ;04
    tileset < #00, #20, #00, #01, @set_palace >   ;05
    tilemap < #01, @map_palace_rooms >   ;06
    tileset < #00, #20, #00, #02, @set_palace_effect >   ;07
    tilemap < #02, @map_palace_effect >   ;08
    jump < #22 >   ;09
  ] >   ;57
  scene-meta < #$005C, [
    display-mode < #15 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace_coffins >   ;04
    tileset < #00, #20, #00, #01, @set_palace >   ;05
    tilemap < #01, @map_palace_coffins >   ;06
    tileset < #00, #20, #00, #02, @set_palace_effect >   ;07
    tilemap < #02, @map_palace_coffins_effect >   ;08
    branch < #70, #0C >   ;09
    jump < #18 >   ;0A
    label < #15 >   ;0B
  ] >   ;58
  scene-meta < #$005D, [
    display-mode < #15 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_fountain, #00 >   ;03
    palette < #00, #70, #10, @pal_palace_fountain >   ;04
    tileset < #00, #20, #00, #01, @set_palace_fountain >   ;05
    tilemap < #01, @map_fountain >   ;06
    tileset < #00, #20, #00, #02, @set_palace_fountain >   ;07
    tilemap < #02, @map_fountain_effect >   ;08
    jump < #18 >   ;09
  ] >   ;59
  scene-meta < #$005E, [
    display-mode < #18 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace_mu >   ;04
    tileset < #00, #20, #00, #01, @set_palace_mu >   ;05
    tilemap < #01, @map_palace_passage >   ;06
  ] >   ;5A
  scene-meta < #$005F, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_entrance >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    branch < #7B, #16 >   ;08
    tilemap < #02, @map_mu_entrance_effect >   ;09
    jump < #18 >   ;0A
    label < #16 >   ;0B
    tilemap < #02, @map_mu_entrance_effect_half >   ;0C
    jump < #18 >   ;0D
    label < #17 >   ;0E
    tilemap < #02, @map_mu_drained_effect >   ;0F
    label < #18 >   ;10
    bitmap < #00, #10, #10, @gfx_credits_actors2, #01 >   ;11
    palette < #00, #60, #A0, @pal_mu_enemies >   ;12
    spritemap < #$1C16, #00, @spm_mu_enemies >   ;13
  ] >   ;5B
  scene-meta < #$0060, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_east >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    branch < #7B, #19 >   ;08
    tilemap < #02, @map_mu_east_effect >   ;09
    jump < #18 >   ;0A
    label < #19 >   ;0B
    tilemap < #02, @map_mu_east_effect_half >   ;0C
    jump < #18 >   ;0D
  ] >   ;5C
  scene-meta < #$0061, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_south >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    branch < #7B, #1A >   ;08
    tilemap < #02, @map_mu_south_effect >   ;09
    jump < #18 >   ;0A
    label < #1A >   ;0B
    tilemap < #02, @map_mu_south_effect_half >   ;0C
    jump < #18 >   ;0D
  ] >   ;5D
  scene-meta < #$0062, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_west >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    branch < #7B, #1B >   ;08
    tilemap < #02, @map_mu_west_effect >   ;09
    jump < #18 >   ;0A
    label < #1B >   ;0B
    tilemap < #02, @map_mu_west_effect_half >   ;0C
    jump < #18 >   ;0D
  ] >   ;5E
  scene-meta < #$0063, [
    display-mode < #18 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_palace, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_palace_effect, #00 >   ;03
    palette < #00, #70, #10, @pal_palace_mu >   ;04
    tileset < #00, #20, #00, #01, @set_palace_mu >   ;05
    tilemap < #01, @map_mu_prayer >   ;06
    jump < #18 >   ;07
  ] >   ;5F
  scene-meta < #$0064, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_connector >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    label < #1D >   ;08
    tilemap < #02, @map_mu_connector_effect_half >   ;09
    jump < #18 >   ;0A
  ] >   ;60
  scene-meta < #$0065, [
    display-mode < #14 >   ;00
    music < #09, #00, @bgm_legendary_sunken_continent >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_maze >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    branch < #7E, #17 >   ;07
    label < #1E >   ;08
    tilemap < #02, @map_mu_maze_effect_half >   ;09
    jump < #18 >   ;0A
  ] >   ;61
  scene-meta < #$0066, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_altar >   ;05
    jump < #18 >   ;06
  ] >   ;62
  scene-meta < #$0067, [
    display-mode < #14 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_mu, #00 >   ;02
    palette < #00, #70, #10, @pal_mu >   ;03
    tileset < #00, #20, #00, #01, @set_mu >   ;04
    tilemap < #01, @map_mu_vampires >   ;05
    tileset < #00, #20, #00, #02, @set_mu_effect >   ;06
    tilemap < #02, @map_mu_vampires_effect >   ;07
    branch < #88, #22 >   ;08
    palette < #00, #60, #A0, @pal_vampires >   ;09
    label < #3B >   ;0A
    bitmap < #00, #10, #10, @gfx_vampires, #01 >   ;0B
    spritemap < #$15C0, #00, @spm_vampires >   ;0C
  ] >   ;63
  scene-meta < #$0068, [
    display-mode < #16 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_angel_tunnel >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_angel_tunnel_effect >   ;07
    jump < #22 >   ;08
  ] >   ;64
  scene-meta < #$0069, [
    display-mode < #18 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel_entrance >   ;03
    tileset < #00, #20, #00, #01, @set_angel_entrance >   ;04
    tilemap < #01, @map_angel_entrance >   ;05
    jump < #22 >   ;06
  ] >   ;65
  scene-meta < #$006A, [
    display-mode < #1C >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_angel_annex >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_angel_annex_effect >   ;07
    jump < #22 >   ;08
  ] >   ;66
  scene-meta < #$006B, [
    display-mode < #16 >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_angel_village >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_angel_village_effect >   ;07
    label < #25 >   ;08
    bitmap < #00, #10, #10, @gfx_angel_sprites, #01 >   ;09
    palette < #00, #60, #A0, @pal_angel_sprites >   ;0A
    spritemap < #$0A43, #00, @spm_angel_sprites >   ;0B
  ] >   ;67
  scene-meta < #$006C, [
    display-mode < #1C >   ;00
    music < #03, #00, @bgm_blessing_of_nature >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_angel_rooms >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_angel_rooms_effect >   ;07
    jump < #25 >   ;08
  ] >   ;68
  scene-meta < #$006D, [
    display-mode < #16 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_entrance >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_tunnel_entrance_effect >   ;07
    label < #1F >   ;08
    palette < #00, #60, #A0, @pal_tunnel_enemies >   ;09
    label < #20 >   ;0A
    bitmap < #00, #10, #10, @gfx_tunnel_enemies, #01 >   ;0B
    spritemap < #$0F7F, #00, @spm_tunnel_enemies >   ;0C
  ] >   ;69
  scene-meta < #$006E, [
    display-mode < #18 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_draco >   ;05
    jump < #1F >   ;06
  ] >   ;6A
  scene-meta < #$006F, [
    display-mode < #1B >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_dark >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_tunnel_dark_effect >   ;07
    palette < #00, #10, #C0, @pal_tunnel_enemies_dark >   ;08
    jump < #20 >   ;09
  ] >   ;6B
  scene-meta < #$0070, [
    display-mode < #16 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_river >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_tunnel_river_effect >   ;07
    jump < #1F >   ;08
  ] >   ;6C
  scene-meta < #$0071, [
    display-mode < #18 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_windy >   ;05
    jump < #1F >   ;06
  ] >   ;6D
  scene-meta < #$0072, [
    display-mode < #18 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_statues >   ;05
    jump < #1F >   ;06
  ] >   ;6E
  scene-meta < #$0073, [
    display-mode < #16 >   ;00
    music < #1D, #00, @bgm_waterfall >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_waterfall >   ;05
    tileset < #00, #20, #00, #02, @set_angel_effect >   ;06
    tilemap < #02, @map_tunnel_waterfall_effect >   ;07
    jump < #1F >   ;08
  ] >   ;6F
  scene-meta < #$0074, [
    display-mode < #18 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_rooms >   ;05
    jump < #25 >   ;06
  ] >   ;70
  scene-meta < #$0075, [
    display-mode < #18 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_angel, #00 >   ;02
    palette < #00, #70, #10, @pal_angel >   ;03
    tileset < #00, #20, #00, #01, @set_angel >   ;04
    tilemap < #01, @map_tunnel_test >   ;05
    jump < #25 >   ;06
  ] >   ;71
  scene-meta < #$0078, [
    display-mode < #1A >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_watermia, #00 >   ;02
    branch < #96, #2A >   ;03
    palette < #00, #70, #10, @pal_watermia >   ;04
    jump < #2B >   ;05
    label < #2A >   ;06
    palette < #00, #70, #10, @pal_watermia_dark >   ;07
    label < #2B >   ;08
    tileset < #00, #20, #00, #03, @set_watermia >   ;09
    tilemap < #01, @map_watermia >   ;0A
    bitmap < #00, #10, #10, @gfx_watermia, #00 >   ;0B
    tilemap < #02, @map_watermia_effect >   ;0C
    label < #26 >   ;0D
    bitmap < #00, #10, #10, @gfx_watermia_sprites, #01 >   ;0E
    palette < #00, #60, #A0, @pal_watermia_sprites >   ;0F
    spritemap < #$178A, #00, @spm_watermia_sprites >   ;10
  ] >   ;72
  scene-meta < #$0079, [
    display-mode < #01 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;05
    tilemap < #01, @map_watermia_lukes >   ;06
    tilemap < #02, @map_watermia_lukes_effect >   ;07
    jump < #22 >   ;08
  ] >   ;73
  scene-meta < #$007A, [
    display-mode < #01 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;05
    tilemap < #01, @map_watermia_interior >   ;06
    tilemap < #02, @map_watermia_interior_effect >   ;07
    bitmap < #00, #10, #10, @gfx_watermia_lances_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_watermia_lances_sprites >   ;09
    spritemap < #$0A9B, #00, @spm_watermia_lances_sprites >   ;0A
  ] >   ;74
  scene-meta < #$007B, [
    display-mode < #01 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;05
    tilemap < #01, @map_watermia_gambling >   ;06
    tilemap < #02, @map_watermia_gambling_effect >   ;07
    jump < #26 >   ;08
  ] >   ;75
  scene-meta < #$007C, [
    display-mode < #01 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;05
    tilemap < #01, @map_watermia_interior >   ;06
    tilemap < #02, @map_watermia_interior_effect >   ;07
    jump < #26 >   ;08
  ] >   ;76
  scene-meta < #$007D, [
    display-mode < #01 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;05
    tilemap < #01, @map_watermia_interior >   ;06
    tilemap < #02, @map_watermia_interior_effect >   ;07
    jump < #26 >   ;08
  ] >   ;77
  scene-meta < #$007E, [
    display-mode < #01 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_hut_interior, #00 >   ;03
    palette < #00, #70, #10, @pal_hut_interior_watermia >   ;04
    tileset < #00, #20, #00, #01, @set_hut_interior_watermia >   ;05
    tileset < #00, #20, #00, #02, @set_hut_interior_watermia >   ;06
    tilemap < #01, @map_watermia_interior >   ;07
    tilemap < #02, @map_watermia_interior_effect >   ;08
    jump < #26 >   ;09
  ] >   ;78
  scene-meta < #$007F, [
    display-mode < #1A >   ;00
    music < #15, #00, @bgm_drifting_endlessly >   ;01
    bitmap < #00, #10, #00, @gfx_watermia, #00 >   ;02
    palette < #00, #70, #10, @pal_watermia >   ;03
    tileset < #00, #20, #00, #03, @set_watermia >   ;04
    tilemap < #01, @map_watermia >   ;05
    bitmap < #00, #10, #10, @gfx_watermia, #00 >   ;06
    tilemap < #02, @map_watermia_effect >   ;07
    jump < #22 >   ;08
  ] >   ;79
  scene-meta < #$0082, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall >   ;04
    tilemap < #01, @map_greatwall_entrance >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect >   ;07
    label < #27 >   ;08
    bitmap < #00, #10, #10, @gfx_greatwall_sprites, #01 >   ;09
    palette < #00, #60, #A0, @pal_greatwall_sprites >   ;0A
    spritemap < #$16FF, #00, @spm_greatwall_sprites >   ;0B
  ] >   ;7A
  scene-meta < #$0083, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall_alt >   ;04
    tilemap < #01, @map_greatwall_dive >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect_alt >   ;07
    jump < #27 >   ;08
  ] >   ;7B
  scene-meta < #$0085, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall >   ;04
    tilemap < #01, @map_greatwall_rampway >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_rampway_effect >   ;07
    jump < #27 >   ;08
  ] >   ;7C
  scene-meta < #$0086, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall_alt >   ;04
    tilemap < #01, @map_greatwall_pit >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect_alt >   ;07
    jump < #27 >   ;08
  ] >   ;7D
  scene-meta < #$0087, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall_alt >   ;04
    tilemap < #01, @map_greatwall_switchback >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect >   ;07
    jump < #27 >   ;08
  ] >   ;7E
  scene-meta < #$0088, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall_alt >   ;04
    tilemap < #01, @map_greatwall_tomb >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect_alt >   ;07
    jump < #27 >   ;08
  ] >   ;7F
  scene-meta < #$0089, [
    display-mode < #08 >   ;00
    bitmap < #00, #10, #00, @gfx_ending_newbabel, #00 >   ;01
    palette < #00, #80, #00, @pal_ending_newbabel >   ;02
    tileset < #00, #20, #00, #01, @set_ending_newbabel >   ;03
    tilemap < #01, @map_ending_newbabel >   ;04
  ] >   ;80
  scene-meta < #$008A, [
    display-mode < #21 >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall >   ;04
    tilemap < #01, @map_greatwall_fanger >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_fanger_effect >   ;07
    palette < #00, #60, #A0, @pal_sandfanger >   ;08
    label < #3C >   ;09
    bitmap < #00, #10, #10, @gfx_sandfanger, #01 >   ;0A
    spritemap < #$0EC0, #00, @spm_sandfanger >   ;0B
  ] >   ;81
  scene-meta < #$008B, [
    display-mode < #1D >   ;00
    music < #0A, #00, @bgm_golden_road >   ;01
    bitmap < #00, #20, #00, @gfx_greatwall, #00 >   ;02
    palette < #00, #70, #10, @pal_greatwall >   ;03
    tileset < #00, #20, #00, #01, @set_greatwall >   ;04
    tilemap < #01, @map_greatwall_inner >   ;05
    tileset < #00, #20, #00, #02, @set_greatwall_effect >   ;06
    tilemap < #02, @map_greatwall_effect >   ;07
    jump < #22 >   ;08
  ] >   ;82
  scene-meta < #$008C, [
    display-mode < #19 >   ;00
    tileset < #00, #20, #00, #01, @set_prologue_prophecy >   ;01
    bitmap < #00, #10, #00, @gfx_prologue_prophecy, #00 >   ;02
    palette < #00, #80, #00, @pal_prologue_prophecy >   ;03
    branch < #F4, #36 >   ;04
    tilemap < #01, @map_prologue_prophecy >   ;05
    jump < #37 >   ;06
    label < #36 >   ;07
    tilemap < #01, @map_prologue_prophecy_2 >   ;08
    label < #37 >   ;09
    bitmap < #00, #10, #10, @gfx_prologue_prophecy_sprites, #01 >   ;0A
    palette < #00, #80, #80, @pal_prologue_prophecy_sprites >   ;0B
    spritemap < #$034E, #00, @spm_prologue_prophecy_sprites >   ;0C
  ] >   ;83
  scene-meta < #$008D, [
    display-mode < #19 >   ;00
    tileset < #00, #20, #00, #01, @set_prologue_legends >   ;01
    bitmap < #00, #10, #00, @gfx_prologue_legends, #00 >   ;02
    palette < #00, #80, #00, @pal_prologue_legends >   ;03
    tilemap < #01, @map_prologue_legends >   ;04
  ] >   ;84
  scene-meta < #$008E, [
    display-mode < #2A >   ;00
    bitmap < #00, #10, #00, @gfx_prologue_missing, #00 >   ;01
    bitmap < #00, #10, #10, @gfx_prologue_missing_effect, #00 >   ;02
    palette < #00, #80, #00, @pal_prologue_missing >   ;03
    tileset < #00, #20, #00, #01, @set_prologue_missing >   ;04
    tileset < #00, #20, #00, #02, @set_prologue_missing_effect >   ;05
    tilemap < #01, @map_prologue_missing >   ;06
    tilemap < #02, @map_prologue_missing_effect >   ;07
    jump < #37 >   ;08
  ] >   ;85
  scene-meta < #$008F, [
    display-mode < #2B >   ;00
    bitmap < #00, #10, #00, @gfx_prologue_mishap, #00 >   ;01
    palette < #00, #80, #00, @pal_prologue_mishap >   ;02
    tileset < #00, #20, #00, #01, @set_prologue_mishap >   ;03
    tilemap < #01, @map_prologue_mishap >   ;04
  ] >   ;86
  scene-meta < #$0090, [
    display-mode < #1D >   ;00
    bitmap < #00, #20, #00, @gfx_ending_world, #00 >   ;01
    palette < #00, #80, #00, @pal_ending_world >   ;02
    tileset < #00, #20, #00, #01, @set_ending_world >   ;03
    tileset < #00, #20, #00, #02, @set_ending_world_effect >   ;04
    tilemap < #01, @map_ending_world >   ;05
    tilemap < #02, @map_ending_world_effect >   ;06
  ] >   ;87
  scene-meta < #$0091, [
    display-mode < #1A >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #20, #00, @gfx_euro, #00 >   ;02
    palette < #00, #70, #10, @palette_1E5013 >   ;03
    tileset < #00, #20, #00, #01, @set_euro >   ;04
    tilemap < #01, @map_euro >   ;05
    tileset < #00, #20, #00, #02, @set_euro_effect >   ;06
    tilemap < #02, @map_euro_effect >   ;07
    bitmap < #00, #10, #10, @gfx_euro_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_euro_sprites >   ;09
    spritemap < #$09C0, #00, @spm_euro_sprites >   ;0A
  ] >   ;88
  scene-meta < #$0092, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_house_interior_euro >   ;03
    tileset < #00, #20, #00, #03, @set_house_interior_euro >   ;04
    tilemap < #01, @map_euro_geezers >   ;05
    tilemap < #02, @map_euro_geezers_effect >   ;06
    bitmap < #00, #10, #10, @gfx_euro_geezers_sprites, #01 >   ;07
    palette < #00, #60, #A0, @pal_euro_geezers_sprites >   ;08
    spritemap < #$0D07, #00, @spm_euro_geezers_sprites >   ;09
  ] >   ;89
  scene-meta < #$0093, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_house >   ;02
    tilemap < #02, @map_euro_house_effect >   ;03
    label < #28 >   ;04
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;05
    palette < #00, #70, #10, @pal_house_interior_euro >   ;06
    tileset < #00, #20, #00, #03, @set_house_interior_euro >   ;07
    bitmap < #00, #10, #10, @gfx_euro_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_euro_sprites >   ;09
    spritemap < #$09C0, #00, @spm_euro_sprites >   ;0A
  ] >   ;8A
  scene-meta < #$0094, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_double >   ;02
    tilemap < #02, @map_euro_double_effect >   ;03
    jump < #28 >   ;04
  ] >   ;8B
  scene-meta < #$0095, [
    display-mode < #1F >   ;00
    music < #05, #00, @bgm_royal_anthem >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_house_interior_euro >   ;03
    tileset < #00, #20, #00, #03, @set_house_interior_euro >   ;04
    tilemap < #01, @map_euro_rolek >   ;05
    tilemap < #02, @map_euro_rolek_effect >   ;06
    bitmap < #00, #10, #10, @gfx_euro_geezers_sprites, #01 >   ;07
    palette < #00, #60, #A0, @pal_euro_geezers_sprites >   ;08
    spritemap < #$0D07, #00, @spm_euro_geezers_sprites >   ;09
  ] >   ;8C
  scene-meta < #$0096, [
    display-mode < #1F >   ;00
    music < #05, #00, @bgm_royal_anthem >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_house_interior_euro >   ;03
    tileset < #00, #20, #00, #03, @set_house_interior_euro >   ;04
    tilemap < #01, @map_euro_guestroom >   ;05
    tilemap < #02, @map_euro_guestroom_effect >   ;06
    jump < #22 >   ;07
  ] >   ;8D
  scene-meta < #$0097, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_market >   ;02
    tilemap < #02, @map_euro_market_effect >   ;03
    jump < #28 >   ;04
  ] >   ;8E
  scene-meta < #$0098, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_geezers >   ;02
    tilemap < #02, @map_euro_geezers_effect >   ;03
    jump < #28 >   ;04
  ] >   ;8F
  scene-meta < #$0099, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #20, #00, @gfx_euro, #00 >   ;02
    tilemap < #01, @map_euro_double >   ;03
    tilemap < #02, @map_euro_double_effect >   ;04
    jump < #28 >   ;05
  ] >   ;90
  scene-meta < #$009A, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_house_interior_euro >   ;03
    tileset < #00, #20, #00, #03, @set_house_interior_euro >   ;04
    tilemap < #01, @map_euro_house >   ;05
    tilemap < #02, @map_euro_house_effect >   ;06
    jump < #3E >   ;07
  ] >   ;91
  scene-meta < #$009B, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_house >   ;02
    tilemap < #02, @map_euro_house_effect >   ;03
    jump < #28 >   ;04
  ] >   ;92
  scene-meta < #$009C, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    tilemap < #01, @map_euro_house >   ;02
    tilemap < #02, @map_euro_house_effect >   ;03
    jump < #28 >   ;04
  ] >   ;93
  scene-meta < #$009D, [
    display-mode < #1F >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_house_interior_euro >   ;03
    tileset < #00, #20, #00, #03, @set_euro_chapel >   ;04
    tilemap < #01, @map_euro_chapel >   ;05
    tilemap < #02, @map_euro_chapel_effect >   ;06
    bitmap < #00, #10, #10, @gfx_freejia_sprites, #01 >   ;07
    palette < #00, #60, #A0, @pal_freejia_sprites >   ;08
    spritemap < #$124C, #00, @spm_freejia_sprites >   ;09
  ] >   ;94
  scene-meta < #$00A0, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_entrance >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    label < #29 >   ;08
    bitmap < #00, #10, #10, @gfx_kress_sprites, #01 >   ;09
    palette < #00, #60, #A0, @pal_kress_sprites >   ;0A
    spritemap < #$0E70, #00, @spm_kress_sprites >   ;0B
  ] >   ;95
  scene-meta < #$00A1, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_twist >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;96
  scene-meta < #$00A2, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_crossroad >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;97
  scene-meta < #$00A3, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_gauntlet >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;98
  scene-meta < #$00A4, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_loop >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;99
  scene-meta < #$00A5, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_vines >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;9A
  scene-meta < #$00A6, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_mushrooms >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;9B
  scene-meta < #$00A7, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_maze >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;9C
  scene-meta < #$00A8, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_detour >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;9D
  scene-meta < #$00A9, [
    display-mode < #20 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_kress, #00 >   ;02
    palette < #00, #70, #10, @pal_kress >   ;03
    tileset < #00, #20, #00, #01, @set_kress >   ;04
    tilemap < #01, @map_kress_summit >   ;05
    tileset < #00, #20, #00, #02, @set_kress_effect >   ;06
    tilemap < #02, @map_kress_effect >   ;07
    jump < #29 >   ;08
  ] >   ;9E
  scene-meta < #$00AC, [
    display-mode < #1A >   ;00
    branch < #B3, #32 >   ;01
    music < #04, #00, @bgm_ominous_whispers >   ;02
    jump < #33 >   ;03
    label < #32 >   ;04
    music < #03, #00, @bgm_blessing_of_nature >   ;05
    label < #33 >   ;06
    bitmap < #00, #10, #00, @gfx_village, #00 >   ;07
    bitmap < #00, #10, #10, @gfx_village, #00 >   ;08
    palette < #00, #70, #10, @pal_village >   ;09
    tileset < #00, #20, #00, #03, @set_village >   ;0A
    tilemap < #01, @map_village >   ;0B
    tilemap < #02, @map_village_effect >   ;0C
    label < #2F >   ;0D
    bitmap < #00, #10, #10, @gfx_village_sprites, #01 >   ;0E
    palette < #00, #60, #A0, @pal_village_sprites >   ;0F
    spritemap < #$105B, #00, @spm_village_sprites >   ;10
  ] >   ;9F
  scene-meta < #$00AD, [
    display-mode < #1F >   ;00
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;01
    palette < #00, #70, #10, @pal_hut_interior_native >   ;02
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;03
    tilemap < #01, @map_village_hut >   ;04
    tilemap < #02, @map_village_hut_effect >   ;05
    jump < #2F >   ;06
  ] >   ;A0
  scene-meta < #$00AE, [
    display-mode < #1F >   ;00
    bitmap < #00, #10, #00, @gfx_hut_interior, #00 >   ;01
    palette < #00, #70, #10, @pal_hut_interior_native >   ;02
    tileset < #00, #20, #00, #03, @set_hut_interior_watermia >   ;03
    tilemap < #01, @map_village_hut >   ;04
    tilemap < #02, @map_village_hut_effect >   ;05
    jump < #2F >   ;06
  ] >   ;A1
  scene-meta < #$00B0, [
    display-mode < #2C >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_angkor_exterior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_exterior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_exterior >   ;04
    tilemap < #01, @map_angkor_entrance >   ;05
    tileset < #00, #20, #00, #02, @set_angkor_exterior_effect >   ;06
    tilemap < #02, @map_angkor_entrance_effect >   ;07
    label < #2E >   ;08
    bitmap < #00, #10, #10, @gfx_angkor_outer_sprites, #01 >   ;09
    palette < #00, #70, #90, @pal_angkor_outer_sprites >   ;0A
    spritemap < #$14D5, #00, @spm_angkor_outer_sprites >   ;0B
  ] >   ;A2
  scene-meta < #$00B1, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_outer_gate >   ;05
    label < #2C >   ;06
    bitmap < #00, #10, #10, @gfx_angkor_interior_sprites, #01 >   ;07
    palette < #00, #70, #90, @pal_angkor_interior_sprites >   ;08
    spritemap < #$1057, #00, @spm_angkor_interior_sprites >   ;09
  ] >   ;A3
  scene-meta < #$00B2, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_outer_east >   ;05
    jump < #2C >   ;06
  ] >   ;A4
  scene-meta < #$00B3, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_outer_north >   ;05
    jump < #2C >   ;06
  ] >   ;A5
  scene-meta < #$00B4, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_snakepit >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_snakepit >   ;05
    jump < #2C >   ;06
  ] >   ;A6
  scene-meta < #$00B5, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_outer_west >   ;05
    jump < #2C >   ;06
  ] >   ;A7
  scene-meta < #$00B6, [
    display-mode < #2C >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #20, #00, @gfx_angkor_exterior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_exterior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_exterior >   ;04
    tilemap < #01, @map_angkor_outer_courtyard >   ;05
    tileset < #00, #20, #00, #02, @set_angkor_exterior_effect >   ;06
    tilemap < #02, @map_angkor_outer_courtyard_effect >   ;07
    jump < #2E >   ;08
  ] >   ;A8
  scene-meta < #$00B7, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_inner_gate >   ;05
    jump < #2C >   ;06
  ] >   ;A9
  scene-meta < #$00B8, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_inner_east >   ;05
    jump < #2C >   ;06
  ] >   ;AA
  scene-meta < #$00B9, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_inner_west >   ;05
    jump < #2C >   ;06
  ] >   ;AB
  scene-meta < #$00BA, [
    display-mode < #2C >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #20, #00, @gfx_angkor_exterior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_exterior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_exterior >   ;04
    tilemap < #01, @map_angkor_inner_courtyard >   ;05
    tileset < #00, #20, #00, #02, @set_angkor_exterior_effect >   ;06
    tilemap < #02, @map_angkor_inner_courtyard_effect >   ;07
    jump < #2E >   ;08
  ] >   ;AC
  scene-meta < #$00BB, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_shrine_main >   ;05
    jump < #2C >   ;06
  ] >   ;AD
  scene-meta < #$00BC, [
    display-mode < #24 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_shrine_crystal >   ;05
    jump < #2C >   ;06
  ] >   ;AE
  scene-meta < #$00BD, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_shrine_dejavu >   ;05
    jump < #2C >   ;06
  ] >   ;AF
  scene-meta < #$00BE, [
    display-mode < #08 >   ;00
    music < #0B, #00, @bgm_unexplored_temple >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_shrine_upper >   ;05
    jump < #2C >   ;06
  ] >   ;B0
  scene-meta < #$00BF, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_angkor_interior, #00 >   ;02
    palette < #00, #70, #10, @pal_angkor_interior >   ;03
    tileset < #00, #20, #00, #01, @set_angkor_interior >   ;04
    tilemap < #01, @map_angkor_shrine_pinnacle >   ;05
    jump < #2D >   ;06
  ] >   ;B1
  scene-meta < #$00C0, [
    display-mode < #19 >   ;00
    music < #11, #00, @bgm_deep_sadness >   ;01
    tileset < #00, #20, #00, #01, @set_angkor_vision >   ;02
    bitmap < #00, #10, #00, @gfx_angkor_vision, #00 >   ;03
    palette < #00, #70, #10, @pal_angkor_vision >   ;04
    tilemap < #01, @map_angkor_vision >   ;05
  ] >   ;B2
  scene-meta < #$00C3, [
    display-mode < #23 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;02
    palette < #00, #70, #10, @pal_dao >   ;03
    tileset < #00, #20, #00, #01, @set_dao >   ;04
    tileset < #00, #20, #00, #02, @set_dao >   ;05
    tilemap < #01, @map_dao >   ;06
    tilemap < #02, @map_dao_effect >   ;07
    label < #2D >   ;08
    bitmap < #00, #10, #10, @gfx_dao_sprites, #01 >   ;09
    palette < #00, #60, #90, @pal_dao_sprites >   ;0A
    spritemap < #$0E9E, #00, @spm_dao_sprites >   ;0B
  ] >   ;B3
  scene-meta < #$00C4, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_hotel >   ;06
    tilemap < #02, @map_dao_hotel_effect >   ;07
    jump < #22 >   ;08
  ] >   ;B4
  scene-meta < #$00C5, [
    display-mode < #1F >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_sweatshop >   ;06
    tilemap < #02, @map_dao_sweatshop_effect >   ;07
    jump < #2D >   ;08
  ] >   ;B5
  scene-meta < #$00C6, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_snakes >   ;06
    tilemap < #02, @map_dao_snakes_effect >   ;07
    jump < #2D >   ;08
  ] >   ;B6
  scene-meta < #$00C7, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_explorers >   ;06
    tilemap < #02, @map_dao_explorers_effect >   ;07
    jump < #2D >   ;08
  ] >   ;B7
  scene-meta < #$00C8, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_dorm >   ;06
    tilemap < #02, @map_dao_dorm_effect >   ;07
    jump < #22 >   ;08
  ] >   ;B8
  scene-meta < #$00C9, [
    display-mode < #1F >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #10, #00, @gfx_house_interior, #00 >   ;02
    bitmap < #00, #10, #10, @gfx_dao, #00 >   ;03
    palette < #00, #70, #10, @pal_dao_interior >   ;04
    tileset < #00, #20, #00, #03, @set_dao_interior >   ;05
    tilemap < #01, @map_dao_indecision >   ;06
    tilemap < #02, @map_dao_indecision_effect >   ;07
    jump < #2D >   ;08
  ] >   ;B9
  scene-meta < #$00CC, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_fluid >   ;04
    tilemap < #01, @map_pyramid_main >   ;05
    label < #31 >   ;06
    bitmap < #00, #10, #10, @gfx_pyramid_sprites, #01 >   ;07
    palette < #00, #60, #90, @pal_pyramid_sprites >   ;08
    spritemap < #$13FB, #00, @spm_pyramid_sprites >   ;09
  ] >   ;BA
  scene-meta < #$00CD, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid_puzzle >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_room >   ;04
    tilemap < #01, @map_pyramid_puzzle >   ;05
    bitmap < #00, #10, #10, @gfx_pyramid_puzzle_sprites, #01 >   ;06
    palette < #00, #60, #90, @pal_pyramid_puzzle_sprites >   ;07
    spritemap < #$0E15, #00, @spm_pyramid_puzzle_sprites >   ;08
  ] >   ;BB
  scene-meta < #$00CE, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_alt >   ;04
    tilemap < #01, @map_pyramid_ramptastic_a >   ;05
    jump < #31 >   ;06
  ] >   ;BC
  scene-meta < #$00CF, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_alt >   ;04
    tilemap < #01, @map_pyramid_ramptastic_b >   ;05
    jump < #31 >   ;06
  ] >   ;BD
  scene-meta < #$00D0, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_fluid >   ;04
    tilemap < #01, @map_pyramid_meltdown_a >   ;05
    jump < #31 >   ;06
  ] >   ;BE
  scene-meta < #$00D1, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_fluid >   ;04
    tilemap < #01, @map_pyramid_meltdown_b >   ;05
    jump < #31 >   ;06
  ] >   ;BF
  scene-meta < #$00D2, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_alt >   ;04
    tilemap < #01, @map_pyramid_focus_a >   ;05
    jump < #31 >   ;06
  ] >   ;C0
  scene-meta < #$00D3, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_alt >   ;04
    tilemap < #01, @map_pyramid_focus_b >   ;05
    jump < #31 >   ;06
  ] >   ;C1
  scene-meta < #$00D4, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_fluid >   ;04
    tilemap < #01, @map_pyramid_trickle_a >   ;05
    jump < #31 >   ;06
  ] >   ;C2
  scene-meta < #$00D5, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_fluid >   ;04
    tilemap < #01, @map_pyramid_trickle_b >   ;05
    jump < #31 >   ;06
  ] >   ;C3
  scene-meta < #$00D6, [
    display-mode < #26 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid >   ;04
    tileset < #00, #20, #00, #02, @set_pyramid >   ;05
    tilemap < #01, @map_pyramid_vader_a >   ;06
    tilemap < #02, @map_pyramid_vader_a_effect >   ;07
    jump < #31 >   ;08
  ] >   ;C4
  scene-meta < #$00D7, [
    display-mode < #28 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid >   ;04
    tileset < #00, #20, #00, #02, @set_pyramid >   ;05
    tilemap < #01, @map_pyramid_vader_b >   ;06
    tilemap < #02, @map_pyramid_vader_b_effect >   ;07
    jump < #31 >   ;08
  ] >   ;C5
  scene-meta < #$00D8, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid >   ;04
    tilemap < #01, @map_pyramid_dangerslide_a >   ;05
    jump < #31 >   ;06
  ] >   ;C6
  scene-meta < #$00D9, [
    display-mode < #26 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid >   ;04
    tileset < #00, #20, #00, #02, @set_pyramid >   ;05
    tilemap < #01, @map_pyramid_dangerslide_b >   ;06
    tilemap < #02, @map_pyramid_dangerslide_b_effect >   ;07
    jump < #31 >   ;08
  ] >   ;C7
  scene-meta < #$00DA, [
    display-mode < #08 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_room >   ;04
    tilemap < #01, @map_pyramid_hieroglyphs >   ;05
    jump < #31 >   ;06
  ] >   ;C8
  scene-meta < #$00DB, [
    display-mode < #26 >   ;00
    music < #0C, #00, @bgm_great_pyramid >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid >   ;04
    tileset < #00, #20, #00, #02, @set_pyramid >   ;05
    tilemap < #01, @map_pyramid_dangerslide_c >   ;06
    tilemap < #02, @map_pyramid_dangerslide_c_effect >   ;07
    jump < #31 >   ;08
  ] >   ;C9
  scene-meta < #$00DC, [
    display-mode < #17 >   ;00
    music < #02, #00, @bgm_lively_city >   ;01
    bitmap < #00, #20, #00, @gfx_garden, #00 >   ;02
    palette < #00, #70, #10, @pal_garden_clouds >   ;03
    tileset < #00, #20, #00, #01, @set_garden_underside_effect >   ;04
    tilemap < #01, @map_clouds >   ;05
    tileset < #00, #20, #00, #02, @set_garden_underside_effect >   ;06
    tilemap < #02, @map_clouds >   ;07
    jump < #38 >   ;08
  ] >   ;CA
  scene-meta < #$00DD, [
    display-mode < #08 >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #20, #00, @gfx_pyramid, #00 >   ;02
    palette < #00, #70, #10, @pal_pyramid >   ;03
    tileset < #00, #20, #00, #01, @set_pyramid_queen >   ;04
    tilemap < #01, @map_pyramid_queen >   ;05
    palette < #00, #60, #A0, @pal_mummyqueen >   ;06
    label < #3D >   ;07
    bitmap < #00, #10, #10, @gfx_mummyqueen, #01 >   ;08
    spritemap < #$2017, #00, @spm_mummyqueen >   ;09
  ] >   ;CB
  scene-meta < #$00DE, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tileset < #00, #20, #00, #02, @set_babel >   ;05
    tilemap < #01, @map_babel_entrance >   ;06
    tilemap < #02, @map_babel_entrance_effect >   ;07
    jump < #22 >   ;08
  ] >   ;CC
  scene-meta < #$00DF, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tileset < #00, #20, #00, #02, @set_babel >   ;05
    tilemap < #01, @map_babel_lower >   ;06
    tilemap < #02, @map_babel_floors_effect >   ;07
    jump < #22 >   ;08
  ] >   ;CD
  scene-meta < #$00E0, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tileset < #00, #20, #00, #02, @set_babel >   ;05
    tilemap < #01, @map_babel_middle >   ;06
    tilemap < #02, @map_babel_floors_effect >   ;07
    jump < #22 >   ;08
  ] >   ;CE
  scene-meta < #$00E1, [
    display-mode < #1E >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tileset < #00, #20, #00, #02, @set_babel >   ;05
    tilemap < #01, @map_babel_elevator >   ;06
    tilemap < #02, @map_babel_elevator_effect >   ;07
    jump < #22 >   ;08
  ] >   ;CF
  scene-meta < #$00E2, [
    display-mode < #08 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tilemap < #01, @map_babel_exterior >   ;05
    bitmap < #00, #10, #10, @gfx_viper, #01 >   ;06
    palette < #00, #60, #A0, @pal_viper >   ;07
    spritemap < #$15DE, #00, @spm_viper >   ;08
  ] >   ;D0
  scene-meta < #$00E3, [
    display-mode < #02 >   ;00
    music < #04, #00, @bgm_ominous_whispers >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel >   ;03
    tileset < #00, #20, #00, #01, @set_babel_upper >   ;04
    tilemap < #01, @map_babel_upper >   ;05
    tileset < #00, #20, #00, #02, @set_babel_upper >   ;06
    tilemap < #02, @map_babel_floors_effect >   ;07
    jump < #22 >   ;08
  ] >   ;D1
  scene-meta < #$00E4, [
    display-mode < #15 >   ;00
    music < #0E, #00, @bgm_longing_for_the_past >   ;01
    bitmap < #00, #20, #00, @gfx_babel, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_rooftop >   ;03
    tileset < #00, #20, #00, #01, @set_babel >   ;04
    tilemap < #01, @map_babel_rooftop >   ;05
    tileset < #00, #20, #00, #02, @set_babel_rooftop_effect >   ;06
    tilemap < #02, @map_babel_rooftop_effect >   ;07
    jump < #22 >   ;08
  ] >   ;D2
  scene-meta < #$00E5, [
    display-mode < #25 >   ;00
    music < #0E, #00, @bgm_longing_for_the_past >   ;01
    bitmap < #00, #20, #00, @gfx_title, #00 >   ;02
    palette < #00, #80, #00, @pal_title >   ;03
    tileset < #00, #20, #00, #03, @set_title >   ;04
    tilemap < #01, @map_ending_comet >   ;05
    tilemap < #02, @map_ending_comet_effect >   ;06
    jump < #22 >   ;07
  ] >   ;D3
  scene-meta < #$00E6, [
    display-mode < #0C >   ;00
    music < #16, #00, @bgm_space_beyond_time >   ;01
    tilemap < #01, @map_darkspace >   ;02
    label < #09 >   ;03
    bitmap < #00, #10, #00, @gfx_darkspace, #00 >   ;04
    bitmap < #00, #10, #10, @gfx_darkspace, #00 >   ;05
    palette < #00, #70, #10, @pal_darkspace >   ;06
    tileset < #00, #20, #00, #01, @set_darkspace >   ;07
    tileset < #00, #20, #00, #02, @set_darkspace_effect >   ;08
    tilemap < #02, @map_darkspace_effect >   ;09
    bitmap < #00, #10, #10, @gfx_darkspace_sprites, #01 >   ;0A
    palette < #00, #70, #90, @pal_darkspace_sprites >   ;0B
    spritemap < #$0579, #00, @spm_darkspace_sprites >   ;0C
  ] >   ;D4
  scene-meta < #$00E7, [
    display-mode < #0C >   ;00
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;01
    palette < #00, #70, #10, @pal_babel_spaceflight >   ;02
    tileset < #00, #20, #00, #01, @set_babel_darklair_effect >   ;03
    tilemap < #01, @map_babel_spaceflight >   ;04
    bitmap < #00, #10, #10, @gfx_babel_spaceflight_sprites, #01 >   ;05
    palette < #00, #70, #90, @pal_babel_spaceflight_sprites >   ;06
    spritemap < #$00E0, #00, @spm_babel_spaceflight_sprites >   ;07
  ] >   ;D5
  scene-meta < #$00E8, [
    display-mode < #0D >   ;00
    bitmap < #00, #20, #00, @palette_bundles.gfx_18AB6D, #00 >   ;01
    palette < #00, #70, #10, @palette_1E6193 >   ;02
    tileset < #00, #20, #00, #03, @set_161705 >   ;03
    tilemap < #01, @map_1E1213 >   ;04
    tilemap < #02, @map_1F2CE6 >   ;05
    bitmap < #00, #10, #10, @gfx_0D2D78, #01 >   ;06
    palette < #00, #70, #90, @palette_1E6273 >   ;07
    spritemap < #$0D7F, #00, @sprite_1607B0 >   ;08
  ] >   ;D6
  scene-meta < #$00E9, [
    display-mode < #22 >   ;00
    music < #06, #00, @bgm_descent_into_darkness >   ;01
    bitmap < #00, #20, #00, @gfx_credits_actors3, #00 >   ;02
    palette < #00, #70, #10, @pal_mansion >   ;03
    tileset < #00, #20, #00, #01, @set_mansion >   ;04
    tileset < #00, #20, #00, #02, @set_mansion_effect >   ;05
    tilemap < #01, @map_mansion >   ;06
    tilemap < #02, @map_mansion_effect >   ;07
    bitmap < #00, #10, #10, @gfx_mine_sprites, #01 >   ;08
    palette < #00, #60, #A0, @pal_mine_sprites_alt >   ;09
    spritemap < #$2930, #00, @spm_mine_sprites >   ;0A
  ] >   ;D7
  scene-meta < #$00EA, [
    display-mode < #22 >   ;00
    bitmap < #00, #20, #00, @gfx_credits_actors3, #00 >   ;01
    palette < #00, #70, #10, @pal_mansion >   ;02
    tileset < #00, #20, #00, #01, @set_mansion >   ;03
    tileset < #00, #20, #00, #02, @set_mansion_effect >   ;04
    tilemap < #01, @map_mansion_solidarm >   ;05
    tilemap < #02, @map_mansion_effect >   ;06
    bitmap < #00, #10, #10, @gfx_solidarm, #01 >   ;07
    palette < #00, #60, #90, @pal_solidarm >   ;08
    spritemap < #$1F8D, #00, @spm_solidarm >   ;09
  ] >   ;D8
  scene-meta < #$00F0, [
    display-mode < #01 >   ;00
    bitmap < #00, #10, #00, @gfx_fonts, #02 >   ;01
    music < #00, #00, @bgm_restart >   ;02
    music < #1B, #00, @bgm_no_music >   ;03
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;04
    palette < #00, #70, #10, @pal_ending_class >   ;05
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;06
    tilemap < #01, @map_ending_class >   ;07
    bitmap < #00, #10, #10, @gfx_ending_class_sprites, #01 >   ;08
    palette < #00, #80, #80, @pal_ending_class_sprites >   ;09
    spritemap < #$0B62, #00, @spm_ending_class_sprites >   ;0A
  ] >   ;D9
  scene-meta < #$00F2, [
    display-mode < #0C >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_darklair >   ;03
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;04
    tilemap < #01, @map_babel_castoth >   ;05
    bitmap < #00, #10, #10, @gfx_ending_combined, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_babel_darklair_effect >   ;07
    tilemap < #02, @map_babel_darklair_effect >   ;08
    palette < #00, #60, #A0, @pal_castoth_dark >   ;09
    jump < #39 >   ;0A
  ] >   ;DA
  scene-meta < #$00F3, [
    display-mode < #0C >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_darklair >   ;03
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;04
    tilemap < #01, @map_babel_viper >   ;05
    bitmap < #00, #10, #10, @gfx_ending_combined, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_babel_darklair_effect >   ;07
    tilemap < #02, @map_babel_darklair_effect >   ;08
    palette < #00, #60, #A0, @pal_viper_dark >   ;09
    jump < #3A >   ;0A
  ] >   ;DB
  scene-meta < #$00F4, [
    display-mode < #0C >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_darklair >   ;03
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;04
    tilemap < #01, @map_babel_vampires >   ;05
    bitmap < #00, #10, #10, @gfx_ending_combined, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_babel_darklair_effect >   ;07
    tilemap < #02, @map_babel_darklair_effect >   ;08
    palette < #00, #60, #A0, @pal_vampires_dark >   ;09
    jump < #3B >   ;0A
  ] >   ;DC
  scene-meta < #$00F5, [
    display-mode < #0C >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_darklair >   ;03
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;04
    tilemap < #01, @map_babel_sandfanger >   ;05
    bitmap < #00, #10, #10, @gfx_ending_combined, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_babel_darklair_effect >   ;07
    tilemap < #02, @map_babel_darklair_effect >   ;08
    palette < #00, #60, #A0, @pal_sandfanger_dark >   ;09
    jump < #3C >   ;0A
  ] >   ;DD
  scene-meta < #$00F6, [
    display-mode < #0C >   ;00
    music < #0F, #00, @bgm_guardians >   ;01
    bitmap < #00, #10, #00, @gfx_ending_combined, #00 >   ;02
    palette < #00, #70, #10, @pal_babel_darklair >   ;03
    tileset < #00, #20, #00, #01, @set_babel_darklair >   ;04
    tilemap < #01, @map_babel_mummyqueen >   ;05
    bitmap < #00, #10, #10, @gfx_ending_combined, #00 >   ;06
    tileset < #00, #20, #00, #02, @set_babel_darklair_effect >   ;07
    tilemap < #02, @map_babel_darklair_effect >   ;08
    palette < #00, #60, #A0, @pal_mummyqueen_dark >   ;09
    jump < #3D >   ;0A
  ] >   ;DE
  scene-meta < #$00F7, [
    display-mode < #22 >   ;00
    music < #1B, #00, @bgm_no_music >   ;01
    bitmap < #00, #10, #00, @gfx_credits_font, #02 >   ;02
    palette < #00, #30, #00, @palette_1F7AA1 >   ;03
    bitmap < #00, #10, #00, @gfx_ending_credits, #01 >   ;04
    spritemap < #$142A, #00, @spm_ending_credits_sprites >   ;05
  ] >   ;DF
  scene-meta < #$00F9, [
    display-mode < #00 >   ;00
    music < #13, #00, @bgm_bittersweet_victory >   ;01
    music < #17, #00, @bgm_1E125C >   ;02
    music < #18, #00, @bgm_important_item >   ;03
    music < #19, #00, @bgm_lolas_melody >   ;04
    music < #1A, #00, @bgm_lost_incan_melody >   ;05
    music < #1E, #00, @bgm_melody_of_memories >   ;06
    music < #14, #00, @bgm_rebirth >   ;07
    music < #10, #00, @bgm_threat_of_dark_gaia >   ;08
    bitmap < #00, #20, #00, @gfx_inventory_sprites, #01 >   ;09
    bitmap < #00, #10, #10, @binary_1EEDBB, #01 >   ;0A
    bitmap < #00, #10, #10, @binary_0D44DB, #01 >   ;0B
    palette < #00, #40, #90, @palette_1F6FF5 >   ;0C
    palette < #00, #70, #90, @palette_1F2060 >   ;0D
    palette < #00, #70, #90, @palette_1F2140 >   ;0E
    palette < #00, #70, #90, @palette_1F2220 >   ;0F
    spritemap < #$08FC, #00, @palette_1B4166 >   ;10
  ] >   ;E0
  scene-meta < #$00FA, [
    display-mode < #08 >   ;00
    music < #00, #00, @bgm_restart >   ;01
    music < #12, #00, @bgm_beautiful_world >   ;02
    bitmap < #00, #10, #00, @gfx_overworld_tiles, #00 >   ;03
    palette < #00, #70, #10, @pal_overworld_tiles >   ;04
    tileset < #00, #20, #00, #01, @set_overworld >   ;05
    tilemap < #01, @map_overworld_main >   ;06
    palette < #00, #80, #80, @pal_southcape_sprites >   ;07
  ] >   ;E1
  scene-meta < #$00FB, [
    display-mode < #00 >   ;00
    bitmap < #00, #10, #10, @gfx_boot_logos, #01 >   ;01
    palette < #00, #30, #80, @pal_boot_logos >   ;02
    spritemap < #$00BD, #00, @spm_boot_logos >   ;03
  ] >   ;E2
  scene-meta < #$00FC, [
    display-mode < #25 >   ;00
    music < #14, #00, @bgm_illusion_of_gaia >   ;01
    bitmap < #00, #20, #00, @gfx_title, #00 >   ;02
    palette < #00, #80, #00, @pal_title >   ;03
    tileset < #00, #20, #00, #03, @set_title >   ;04
    tilemap < #01, @map_title >   ;05
    tilemap < #02, @map_title_effect >   ;06
    bitmap < #00, #10, #10, @gfx_title_actors, #01 >   ;07
    palette < #00, #60, #A0, @pal_title_actors >   ;08
    spritemap < #$0254, #00, @spm_title_actors >   ;09
  ] >   ;E3
  scene-meta < #$00FD, [
    display-mode < #00 >   ;00
    music < #1B, #00, @bgm_no_music >   ;01
    bitmap < #10, #20, #10, @gfx_inventory_sprites, #01 >   ;02
    palette < #00, #70, #80, @pal_inventory_sprites >   ;03
    jump < #11 >   ;04
  ] >   ;E4
  scene-meta < #$00FE, [
    display-mode < #19 >   ;00
    music < #12, #00, @bgm_beautiful_world >   ;01
    tileset < #00, #20, #00, #01, @set_overworld >   ;02
    bitmap < #00, #10, #00, @gfx_overworld_tiles, #00 >   ;03
    tilemap < #01, @map_overworld_main >   ;04
    palette < #00, #70, #10, @pal_overworld_tiles >   ;05
    bitmap < #00, #10, #10, @gfx_overworld_font, #01 >   ;06
    palette < #00, #70, #90, @pal_overworld_sprites >   ;07
    spritemap < #$1238, #00, @spm_overworld_sprites >   ;08
  ] >   ;E5
  scene-meta < #$00FF, [
    display-mode < #00 >   ;00
    bitmap < #00, #20, #00, @gfx_inventory_sprites, #01 >   ;01
    palette < #00, #80, #80, @pal_inventory_sprites >   ;02
    label < #11 >   ;03
    palette < #00, #70, #10, @pal_inventory_bg >   ;04
    bitmap < #00, #10, #00, @gfx_inventory_bg, #00 >   ;05
    char-tiles < #80, @dmap_inventory_bg >   ;06
  ] >   ;E6
]