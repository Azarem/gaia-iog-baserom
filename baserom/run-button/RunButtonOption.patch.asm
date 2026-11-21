; Auto-Run option and diary control legends
;
; Registers Auto-Run in the inventory Options menu. The journal stores the
; choice in $0B3A bit 2: clear = On (new-game default), set = Off. The menu
; uses $0BE6 as its temporary selection word. The Run action stays remappable.
; On: 120 walking frames start a run. Each frame with Run held counts as 8
; (15 frames from rest). Sideways turns preserve progress; reversals reset it.
; Off: hold Run and a direction to sprint immediately.
; RunButtonCore.patch.asm implements movement. The two diary string overrides
; below label Sprint in the opening menu's control legends.

RunButtonChoices [
  &auto_run_on
  &auto_run_off
]
auto_run_on  |On|
auto_run_off |Off|

optstr_run_button |[PAL:0]Auto-Run[N] [PAL:14][TBL:@RunButtonChoices,BE6][PAL:0]|
optstr_run_button_desc |[PAL:0][POS:96,5]Walk to build speed.[DBL]Hold Run to start[DBL]running sooner.|
sFA_diary_menu.dialogstring_0BF538! `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`
sFA_diary_menu.dialogstring_0BF5AD! `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N][LU2:2]Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item Menu[N][SKP:5]   :Sprint`

--------------------------------------
;Registration of the Auto-Run setting (must stay after the overrides above)

OptionSettingPreset- [
  @optstr_run_button       ;+00 render
  @optstr_run_button_desc  ;+03 desc
  #$0BE6                   ;+06 temp
  #$0B3A                   ;+08 store
  #$0002                   ;+0A shift
  #$0001                   ;+0C mask
  #$0000                   ;+0E xor
  #$0002                   ;+10 count
  #$0000                   ;+12 load   (packed bits)
  #$0000                   ;+14 change
  #$0000                   ;+16 commit (packed bits)
]
