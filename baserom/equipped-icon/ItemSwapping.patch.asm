; Cycle the equipped item in the field using the two mapped actions.
; Consume the cycle inputs until release, like other one-press actions.
; The old Cycle B mask in joypadMaskStd also suppresses Cycle F.

!cycle_joypad_current           0656
!cycle_joypad_held              0658
!cycle_joypad_mask              065A

item_swapping_main:
  LDA $09EC
  BIT #$4000
  BNE item_swapping_end
  LDA $09AA
  BEQ item_swapping_end
  LDA $cycle_joypad_mask
  BIT #$0004
  BNE item_swapping_end
  LDA $cycle_joypad_current
  AND #$0006
  BEQ item_swapping_end
  TSB $cycle_joypad_held
  BIT #$0002
  BNE item_swapping_right

  LDY $0AC4
  BPL item_swap_left_begin
  LDY #$0010

item_swap_left_begin:
  LDA #$0000

item_swap_left_top:
  DEY
  BMI item_swap_store
  LDA $0AB4, Y
  AND #$00FF
  BEQ item_swap_left_top

item_swap_store:
  STY $0AC4
  STA $0AC6
  COP [07] ( #10 )
  PHX                      ;EquippedIcon clobbers X, hooks must keep X = actor id
  JSL @EquippedIcon
  PLX
  RTL


item_swapping_right:
  LDY $0AC4
  BPL item_swap_right_begin
  LDY #$FFFF

item_swap_right_begin:
  LDA #$0000

item_swap_right_top:
  INY
  CPY #$0010
  BCS item_swap_right_nothing
  LDA $0AB4, Y
  AND #$00FF
  BEQ item_swap_right_top
  BRA item_swap_store

item_swapping_end:
  RTL

item_swap_right_nothing:
  LDY #$FFFF
  BRA item_swap_store

----------------------------------------------------------------------
;Registration with the player input chain (registry: player_input_core.asm)
;Must stay at the END of this file

PlayerInputHooks+ {
  JSL $@item_swapping_main
}
