
--------------------------------------

;Options menu setting (registry format: options_menu_core.asm)
;Storage: $0B3A bits 2-3. Temp (TBL switch) word: $0BE6

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

dialogstring_0BF538! `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`
dialogstring_0BF5AD! `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`

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
