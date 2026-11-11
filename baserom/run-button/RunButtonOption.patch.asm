; ==============================================================================
; Run Button option - menu strings and diary text updates
; ==============================================================================
; What it does: Registers Run/Walk/Auto in the options menu; rewrites diary
;   Change Options / Start Journey dialog lines to describe sprint remapping.
; Vanilla behavior: Diary strings listed Attack/Talk, Item palette, unused row;
;   run mode was fixed in engine (Y = sprint in default Type-1 layout).
; Hooks (overrides): sFA_diary_menu.dialogstring_0BF538 / dialogstring_0BF5AD.
; Adds: OptionSettingPreset- record (packed $0B3A bits 2-3, temp $0BE6).
; Depends on: options_menu_core registry; RunButtonCore.patch for gameplay effect.
; State: $0B3A bits 2-3 (0 Run, 1 Walk, 2 Auto); temp word $0BE6.
; Hazards: Strings only in this file; logic lives in run_button_main (bank 02).
; ==============================================================================

--------------------------------------

RunButtonChoices [
  &run_button_run
  &run_button_walk
  &run_button_auto
]

run_button_run  |Run|
run_button_walk |Walk|
run_button_auto |Auto|

optstr_run_button |[PAL:0]Run Button[N] [PAL:14][TBL:@RunButtonChoices,BE6][PAL:0]|
optstr_run_button_desc |[PAL:0][POS:96,5]Run: hold to run.[DBL]Walk: hold to walk.[DBL]Auto: always run.|

--------------------------------------

sFA_diary_menu.dialogstring_0BF538! `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`
sFA_diary_menu.dialogstring_0BF5AD! `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`

--------------------------------------
;Registration of the Run Button setting (must stay after the overrides above)

OptionSettingPreset- [
  @optstr_run_button       ;+00 render
  @optstr_run_button_desc  ;+03 desc
  #$0BE6                   ;+06 temp
  #$0B3A                   ;+08 store
  #$0002                   ;+0A shift
  #$0003                   ;+0C mask
  #$0000                   ;+0E xor
  #$0003                   ;+10 count
  #$0000                   ;+12 load   (packed bits)
  #$0000                   ;+14 change
  #$0000                   ;+16 commit (packed bits)
]
