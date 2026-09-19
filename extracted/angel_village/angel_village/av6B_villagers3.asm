?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

av6B_villagers3 [
  actor-def < #0A, #00, #10, {

  code_06CBB2:
    LDA $0E
    AND #$0030
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $28
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_06CBD3 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_06CBD3 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06CBDE )
}

code_list_06CBDE [
  &code_06CBE4   ;00
  &code_06CBE9   ;01
  &code_06CBE4   ;02
]

code_06CBE4 {
    COP [PrintDialogString] ( &dialogstring_06CBEE )
    RTL 
}

code_06CBE9 {
    COP [PrintDialogString] ( &dialogstring_06CC22 )
    RTL 
}

dialogstring_06CBEE `[TPL:A]It's been said that [N]we are the form into [N]which humans evolve. [END]`

dialogstring_06CC22 `[TPL:B]I'll show you the way to[N]the studio. Remember it.[FIN]Go with the wind. [FIN]If you look at which [N]way the torch flame [N]bends,[N]you'll understand.[FIN]Down the dark street,[N]through where the wind[N]blows, to where you can[N]hear the waterfall.[FIN]Then look for the place[N]where the sound of the[N]waterfall is loud.[FIN]Ishtar's studio is[N]in front. Be careful.[END]`