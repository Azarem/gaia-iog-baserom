; Dark Space portal at the Pyramid main entrance (scene $CC).
; 
; The actor word $0E (the spawn attribute shifted right once) is an event flag offset: the actor yields until flag $0100 + $0E is set, then spawns dark_space.DarkSpacePortalInit with config $2B00 and stores 3 in the child's $24 (1 when $0E is $72). Its only placement (scene_actors row $CC#06, attribute $E7) gives $0E = $73; that flag is set when the Mystic Ball at row $CC#05 is defeated (its death-action index is $73), so the portal appears after that kill.
---------------------------------------------

?INCLUDE 'dark_space'
?INCLUDE 'flag_helpers'

---------------------------------------------

pyCC_dark_space_portal [
  actor-def < #00, #00, #23, {

  code_08B66B:
    LDA $0E
    JSL $@flag_helpers.TestFlag_0100
    BCS loc_08B67E
    COP [SetEntryHere]
    LDA $0E
    JSL $@flag_helpers.TestFlag_0100
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