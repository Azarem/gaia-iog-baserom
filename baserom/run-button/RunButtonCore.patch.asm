; Auto-Run movement
;
; Off: PlayerInputHooks calls run_button_main. Holding the mapped Run action
; ($0040) and a direction starts a native sprint as soon as movement permits.
; On: PlayerMoveWriteBack calls auto_run_tick after collision resolution.
; Each frame with directional input and actual displacement earns 1 point,
; or 8 with Run held. At 120 points, set native run speed on the selected axis.
; A perpendicular turn keeps progress and redirects an active auto-run.
; A direct reversal clears progress and ends an active auto-run; the new
; direction earns its first 1 or 8 points on that same movement tick.
; No input or no displacement clears progress. Controller spawn and hit-stun
; also clear it. $0BFC holds progress and $0BFE holds the previous direction.
; The per-slot option is $0B3A bit 2 (clear = On, set = Off).

?INCLUDE 'player_move_controller'

!run_button_setting             0B3A
; Transient words after the journal save block, before the actor list at $0C00.
!run_progress                   0BFC
!run_direction                  0BFE
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
  BIT #$0004
  BEQ run_button_end    ; Auto-Run On is handled after collision resolution.
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

auto_run_tick {
    LDA $run_button_setting
    BIT #$0004
    BNE auto_reset
    LDA $09AE
    BIT #$3A00
    BNE auto_reset
    LDA $joypadCurrent
    AND #$0F00
    BEQ auto_reset
    LDA $0022
    CMP $14
    BNE auto_direction
    LDA $0026
    CMP $16
    BNE auto_direction
  auto_reset:
    STZ $run_progress
    RTL

  auto_direction:
    ; Opposites differ in bit zero. Match the manual mode's D-pad priority.
    LDA $joypadCurrent
    BIT #$0100
    BNE auto_east
    BIT #$0200
    BNE auto_west
    BIT #$0400
    BNE auto_south
    LDA #$0003
    BRA auto_compare
  auto_east:
    LDA #$0000
    BRA auto_compare
  auto_west:
    LDA #$0001
    BRA auto_compare
  auto_south:
    LDA #$0002
  auto_compare:
    PHA
    EOR $run_direction
    CMP #$0001
    BNE auto_count
    LDA $run_progress
    CMP #$0078
    BNE auto_restart
    STZ $09B2
    STZ $09B4
    STZ $09B8
  auto_restart:
    STZ $run_progress
  auto_count:
    PLA
    STA $run_direction
    LDA $run_progress
    CMP #$0078
    BCS auto_apply
    INC
    PHA
    LDA $joypadCurrent
    BIT #$0040
    BEQ auto_slow
    PLA
    CLC
    ADC #$0007
    BRA auto_store
  auto_slow:
    PLA
  auto_store:
    STA $run_progress
    CMP #$0078
    BCC auto_done
  auto_apply:
    LDA #$0078
    STA $run_progress
    LDA $run_direction
    LSR
    LDA #$0003
    BCC auto_positive
    LDA #$FFFD
  auto_positive:
    PHA
    LDA $run_direction
    BIT #$0002
    BNE auto_vertical
    PLA
    STZ $09B4
    STA $09B2
    BRA auto_brake
  auto_vertical:
    PLA
    STZ $09B2
    STA $09B4
  auto_brake:
    STZ $09B8
  auto_done:
    RTL
}

--------------------------------------
PlayerInputHooks+ {
    JSL $@run_button_main
}

player_move_controller.PlayerMoveController! {
    STZ $run_progress
    LDA $14               ; Runs once, at spawn (above SetEntryHere): local X x 4 = sub-pixels (2 fractional bits)
    ASL
    ASL
    STA $14
    LDA $16
    ASL
    ASL
    STA $16
    COP [SetEntryHere]    ; Resume point: every frame from here on
    PHX
    LDX $playerActor
    LDA $0010, X
    BIT #$0080            ; Bit $0080 = the iframe counter is running (hit-stun or recovery)
    BEQ player_move_controller.PlayerMoveNotStunned
    LDA $iframeCounter, X
    BMI player_move_controller.PlayerMoveNotStunned ; Negative = recovery after a hit: movement continues
    STZ $run_progress
    PLX                   ; Zero or positive counter = hit-stun: restore X and skip the frame (the stunned player cannot move)
    RTL
}
player_move_controller.PlayerMoveWriteBack! {
    JSL $@auto_run_tick
    LDY $playerActor
    LDA $0022             ; Write-back: the final X / Y (sub-pixels) become the local position; >> 2 goes to the player actor's pixel position
    STA $14
    LSR
    LSR
    STA $0014, Y
    LDA $0026
    STA $16
    LSR
    LSR
    STA $0016, Y
    LDA $0010, Y          ; Copy bit $0004 (solid contact this tick) from this actor's $10 into the player's: clear it in the player's flags first ...
    AND #$FFFB
    PHA
    LDA $10
    AND #$0004
    ORA $01, S
    STA $0010, Y
    PLA
    RTL
}
