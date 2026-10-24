
;Options menu setting: bits 2-3 = Run Button mode (0 Run, 1 Walk, 2 Auto)
!run_button_setting             0B3A

---------------------------------

run_button_main:
  LDA $09AA
  BEQ run_button_end    ;Skip if player has no actor
  LDA $09B2
  BNE run_button_end    ;Skip if running already
  LDA $09B4
  BNE run_button_end    ;Skip if running already
  LDA $09AE
  BIT #$3800
  BNE run_button_end    ;Skip if in a stance, on a slope or script/ability locked
  LDA $run_button_setting
  AND #$000C
  BEQ run_mode_hold     ;Run: sprint while the run button is held
  CMP #$0008
  BEQ run_button_dirs   ;Auto: always sprint, the run button has no effect
  LDA $joypadCurrent    ;Walk: sprint unless the run button is held
  BIT #$0040
  BNE run_button_end
  BRA run_button_dirs

run_mode_hold:
  LDA $joypadCurrent
  BIT #$0040
  BEQ run_button_end    ;Skip if not pressing run

run_button_dirs:
  LDA $joypadCurrent
  XBA
  LSR
  BCS run_button_e
  LSR
  BCS run_button_w
  LSR
  BCS run_button_s
  LSR
  BCS run_button_n

  ;Skip if not pressing a direction
run_button_end:
  RTL        
  
run_button_n:
  LDA #$FFFD
  BRA run_store_ns

run_button_s:
  LDA #$0003

run_store_ns:
  STA $09B4
  STZ $09B8  ;Reset brake counter
  RTL
  
run_button_w:
  LDA #$FFFD
  BRA run_store_ew

run_button_e:
  LDA #$0003

run_store_ew:
  STA $09B2
  STZ $09B8  ;Reset brake counter
  RTL

--------------------------------------------------

PlayerInputHooks+ {
    JSL $@run_button_main
}
