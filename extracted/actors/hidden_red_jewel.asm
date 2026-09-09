?INCLUDE 'cop_handlers_script'
?INCLUDE 'table_0EE000'

---------------------------------------------

hidden_red_jewel [
  actor-def < #00, #00, #30, {

  code_00C672:
    COP [SetOnInteract] ( &code_00C681 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_00C681 {
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@cop_handlers_script.TestEventFlag_0200
    BCS loc_00C6A5
    COP [GiveItem] ( #01, &code_00C6A1 )
    COP [PrintWideString] ( &widestring_00C6A6 )
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@cop_handlers_script.SetEventFlag_0200
    RTL 
}

code_00C6A1 {
    COP [PrintWideString] ( &widestring_00C6BF )

  loc_00C6A5:
    RTL 
}

widestring_00C6A6 `[DLG:3,11][SIZ:D,3]You found a Red Jewel![END]`

widestring_00C6BF `[DLG:3,11][SIZ:D,3]You found a Jewel but[N]your inventory is full.[END]`