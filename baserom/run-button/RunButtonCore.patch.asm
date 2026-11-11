; ==============================================================================
; Run Button core - movement sprint from options setting
; ==============================================================================
; What it does: Each frame via PlayerInputHooks chain, sets run state $09B2/$09B4
;   when D-pad held and gates match Run/Walk/Auto mode from options ($0B3A).
; Vanilla behavior: Sprint required Run button (joypad bit $0040) plus direction;
;   no Walk/Auto modes.
; Hooks (overrides): PlayerInputHooks+ chain insert (patch-local hook list).
; Adds: run_button_main and direction helpers (JSL from hook).
; Depends on: PlayerInput.patch PlayerInputHooks anchor; joypadCurrent $0656.
; State: $0B3A bits 2-3; player motion $09AA/$09B2/$09B4/$09B8; playerFlags
;   $09AE bits 11-13 ($0800/$1000/$2000) skip sprint when set.
; Hazards: RTL subroutines; reads joypad after remapping (action bit $0040 = Run).
; ==============================================================================

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
