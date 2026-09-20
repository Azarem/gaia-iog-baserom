; Female townspeople group 1 in Euro — mentions Rofsky and Erasquez.
; 
; Multi-NPC (~106 lines). "This is where the world-famous
; Rofsky and the violinist Erasquez live." Establishes
; Euro's cultural figures and their significance.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

eu91_women1 [
  actor-def < #0A, #00, #10, {

  code_07C754:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$002A
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    JSL $@ActorDisplayModeSwap
    COP [SetInteractHandler] ( &code_07C776 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_07C776 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C781 )
}

code_list_07C781 [
  &code_07C787   ;00
  &code_07C78C   ;01
  &code_07C7A6   ;02
]

code_07C787 {
    COP [PrintDialogString] ( &dialogstring_07C7BA )
    RTL 
}

code_07C78C {
    COP [PrintDialogString] ( &dialogstring_07C836 )
    COP [DialogueOptions] ( #02, #02, &code_list_07C796 )
}

code_list_07C796 [
  &code_07C79C   ;00
  &code_07C7A1   ;01
  &code_07C79C   ;02
]

code_07C79C {
    COP [PrintDialogString] ( &dialogstring_07C8D5 )
    RTL 
}

code_07C7A1 {
    COP [PrintDialogString] ( &dialogstring_07C860 )
    RTL 
}

code_07C7A6 {
    COP [PrintDialogString] ( &dialogstring_07C8EC )
    RTL 
}

code_07C7AB {
    COP [PrintDialogString] ( &dialogstring_07C924 )
    RTL 
}

code_07C7B0 {
    COP [PrintDialogString] ( &dialogstring_07C926 )
    RTL 
}

code_07C7B5 {
    COP [PrintDialogString] ( &dialogstring_07C928 )
    RTL 
}

dialogstring_07C7BA `[DEF]This is where the [N]world-famous, Rofsky,[N]and the violinist, [N]Erasquez, live. [FIN]They are always arguing.[N]Geniuses can be[N]so peculiar.[END]`

dialogstring_07C836 `[DEF]Believe in fortune-[N]telling? [N] Yes [N] No `

dialogstring_07C860 `[CLR]Mmmm.[N]The future looks dark[N]and uncertain.[FIN]A huge comet will enter[N]Earth's orbit. Mankind[N]will become extinct.[FIN]There will be nothing[N]but despair!![END]`

dialogstring_07C8D5 `[CLR]Oh. [N]That's too bad. [END]`

dialogstring_07C8EC `[DEF][SFX:10]I hear there are people[N]in this town who can[N]increase your strength.[END]`

dialogstring_07C924 `[DEF][END]`

dialogstring_07C926 `[DEF][END]`

dialogstring_07C928 `[DEF][END]`