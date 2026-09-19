?INCLUDE 'table_0EE000'

!joypadCurrent                  0656
!joypadHeld                     0658

---------------------------------------------

unused_debug_input_test [
  actor-def < #00, #00, #03, {

  code_09BAE6:
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$0000
    STA $28

  loc_09BAF0:
    COP [SetEntryContinue]
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
    COP [SetEntryExit]
    BRA loc_09BAF0

  loc_09BB16:
    RTL 
} >
]