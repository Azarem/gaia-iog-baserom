; Dark Space portal at the Pyramid main entrance.
; 
; Hidden Dark Space access point near the Pyramid entrance.
; Standard Dark Space spawn with flag checks for visibility.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'dark_space'

---------------------------------------------

pyCC_dark_space_portal [
  actor-def < #00, #00, #23, {

  code_08B66B:
    LDA $0E
    JSL $@cop_handlers_flags.TestFlag_0100
    BCS loc_08B67E
    COP [SetEntryContinue]
    LDA $0E
    JSL $@cop_handlers_flags.TestFlag_0100
    BCS loc_08B67E
    RTL 

  loc_08B67E:
    COP [SpawnAfterFlags] ( @dark_space.DarkSpacePortalInit, #$2B00 )
    LDA #$2000
    STA $000E, Y
    LDA $0E
    CMP #$0072
    BEQ loc_08B69A
    LDA #$0003
    STA $0024, Y
    BRA loc_08B6A0

  loc_08B69A:
    LDA #$0001
    STA $0024, Y

  loc_08B6A0:
    COP [Die]
} >
]