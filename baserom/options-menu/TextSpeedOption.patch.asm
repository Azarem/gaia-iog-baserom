; =============================================================================
; Text Speed — applies the options-menu setting to the dialogue typing delay
; =============================================================================
;
; Registered with the options menu (registry format: options_menu_core.asm).
;
; Setting storage: $0B3A bits 0-1 (Run Button uses bits 2-3, Auto-Jewels bit 4)
; Temp (TBL switch) word: $0BE2
;   0 Normal       keep the script's per-character delay ($007E)
;   1 Fast         halve the delay (rounded up)
;   2 Instant      no delay
;   3 Run-Instant  normal speed, but instant while the run button is held

!joypadCurrent                  0656
!text_speed_setting             0B3A
!text_speed_delay               007E

---------------------------------------------
; Options menu strings. The value row shows the choice picked through the temp
; word at $0BE2 (TBL index), and the description appears while the cursor is on
; the setting.

TextSpeedChoices [
  &text_speed_normal
  &text_speed_fast
  &text_speed_instant
  &text_speed_runinstant
]

text_speed_normal     |Normal|
text_speed_fast       |Fast|
text_speed_instant    |Instant|
text_speed_runinstant |Run Instant|

optstr_text_speed |[PAL:0]Text Speed[N] [PAL:14][TBL:@TextSpeedChoices,BE2][PAL:0]|
optstr_text_speed_desc |[PAL:0][POS:96,5]Dialogue text speed.[DBL]Run Instant: instant[DBL]while Run is held.|


---------------------------------------------
; Entry: M = 8-bit
; Exit:  A = frames to wait per character (0 = instant), Z set accordingly
;        (the flags reflect the last operation before RTL)
; Preserves X, Y.

TextSpeedAdjust {
    LDA $text_speed_delay
    BEQ tsa_return          ; script already wants instant text
    PHA
    LDA $text_speed_setting
    AND #$03
    BEQ tsa_normal
    CMP #$02
    BEQ tsa_instant
    BCS tsa_run

    ; 1 = Fast
    PLA
    INC
    LSR
    RTL

  tsa_run:
    LDA $joypadCurrent
    AND #$40
    BEQ tsa_normal

  tsa_instant:
    PLA
    LDA #$00
    RTL

  tsa_normal:
    PLA

  tsa_return:
    RTL
}

---------------------------------------------
; Hook: WaitNFrames_PerChar normally loads the delay straight from $007E.
; The replacement asks TextSpeedAdjust for the effective delay instead. Zero
; skips the wait entirely; non-zero falls through to the original wait loop
; (loc_03E7C2) which is left untouched.

WaitNFrames_PerChar! {
    PHP
    SEP #$20
    JSL $@TextSpeedAdjust
    BEQ loc_03E7D4
}

---------------------------------------------
; Registration (must stay after the override above, see options_menu_core.asm)

OptionSettingPreset- [
  @optstr_text_speed       ;+00 render
  @optstr_text_speed_desc  ;+03 desc
  #$0BE2                   ;+06 temp
  #$0B3A                   ;+08 store
  #$0000                   ;+0A shift
  #$0003                   ;+0C mask
  #$0000                   ;+0E xor
  #$0004                   ;+10 count
  #$0000                   ;+12 load   (packed bits)
  #$0000                   ;+14 change
  #$0000                   ;+16 commit (packed bits)
]
