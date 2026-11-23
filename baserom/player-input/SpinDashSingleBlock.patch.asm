; Spin Dash still needs fresh guard presses after Cycle F replaces Block2.
?INCLUDE 'attack_ability_system'

attack_ability_system.SpinDashChargeTick! {
    LDA $joypadCurrent
    AND #$0020
    BEQ spin_dash_charge_idle
    TSB $joypadHeld
    DEC $26

  spin_dash_charge_idle:
    RTS
}
