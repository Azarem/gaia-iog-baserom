; ==============================================================================
; Text Speed option - dialogue per-character delay from options menu
; ==============================================================================
; Cinematic (2, new-game default): unpaced text waits one frame normally and
;   zero frames while Run is held. Normal (0) keeps unpaced text instant.
;   Both preserve authored delays and apply Fast timing while Run is held.
; Instant (1) skips all character delays. Legacy value 3 falls back to
;   Normal, matching the options registry's out-of-range handling.
; Vanilla behavior: WaitNFrames_PerChar waited frames from script delay $007E only.
; Hooks (overrides): DialogStringRenderer.WaitNFrames_PerChar (calls TextSpeedAdjust
;   then falls through to loc_03E7C2 or skips wait at loc_03E7D4).
; Adds: TextSpeedAdjust (JSL from hook); OptionSettingPreset- record; strings.
; Depends on: options_menu_core registry.
; State: Packed $0B3A bits 0-1; temp $0BE2; reads $007E, $065E joypadRemapped (held actions before page input is consumed).
; Hazards: TextSpeedAdjust preserves X/Y; hook uses SEP #$20 around JSL.
; ==============================================================================

!joypadRemapped                 065E
!text_speed_setting             0B3A
!text_speed_delay               007E

---------------------------------------------
; Options menu strings. The value row shows the choice picked through the temp
; word at $0BE2 (TBL index), and the description appears while the cursor is on
; the setting.

TextSpeedChoices [
  &text_speed_normal
  &text_speed_instant
  &text_speed_cinematic
]

text_speed_cinematic |Cinematic|
text_speed_normal    |Normal|
text_speed_instant   |Instant|

optstr_text_speed |[PAL:0]Text Speed[N] [PAL:14][TBL:@TextSpeedChoices,BE2][PAL:0]|
optstr_text_speed_desc |[PAL:0][POS:96,5]Cinematic adds pace.[DBL]Hold Run for faster[DBL]paced text.|


---------------------------------------------
; Entry: M = 8-bit
; Exit:  A = frames to wait per character (0 = instant), Z set accordingly
;        (the flags reflect the last operation before RTL)
; Preserves X, Y.

TextSpeedAdjust {
    LDA $text_speed_setting
    AND #$03
    CMP #$01
    BEQ tsa_instant
    CMP #$02
    BNE tsa_script

    LDA $text_speed_delay
    BNE tsa_script
    LDA $joypadRemapped
    BIT #$40
    BNE tsa_instant
    LDA #$01                ; Unspecified Cinematic delay: one frame
    RTL

  tsa_script:
    LDA $joypadRemapped
    BIT #$40
    BEQ tsa_normal
    LDA $text_speed_delay
    INC                     ; Preserve the original 8-bit Fast calculation
    LSR
    RTL

  tsa_normal:
    LDA $text_speed_delay
    RTL

  tsa_instant:
    LDA #$00
    RTL
}

---------------------------------------------
; Hook: WaitNFrames_PerChar normally loads the delay straight from $007E.
; The replacement asks TextSpeedAdjust for the effective delay instead. Zero
; skips the wait entirely; non-zero falls through to the original wait loop
; (loc_03E7C2) which is left untouched.

DialogStringRenderer.WaitNFrames_PerChar! {
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
  #$0003                   ;+10 count
  #$0000                   ;+12 load   (packed bits)
  #$0000                   ;+14 change
  #$0000                   ;+16 commit (packed bits)
]
