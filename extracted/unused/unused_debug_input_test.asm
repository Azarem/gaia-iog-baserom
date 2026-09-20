; Unused debug actor for cycling through enemy spriteset frames.
; 
; Advances frame index $28 on each A-button press (0..$32), displaying
; one sprite from spriteset_enemies per frame. Debug sprite viewer.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!joypadCurrent                  0656
!joypadHeld                     0658

---------------------------------------------

unused_debug_input_test [
  actor-def < #00, #00, #03, {

  code_09BAE6:
    COP [SetMetasprite] ( @spriteset_enemies )
    LDA #$0000
    STA $28

  loc_09BAF0:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $joypadCurrent
    BIT #$0080
    BNE loc_09BAFD
    RTL 

  loc_09BAFD:
    LDA $28
    INC 
    CMP #$0033
    BCC loc_09BB08
    LDA #$0000

  loc_09BB08:
    STA $28
    STZ $2A
    LDA #$0080
    TSB $joypadHeld
    COP [SetEntryHereAndYield]
    BRA loc_09BAF0

  loc_09BB16:
    RTL 
} >
]