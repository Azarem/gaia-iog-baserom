---------------------------------------------

dm44_cell_door [
  actor-def < #35, #01, #30, {

  code_05D52B:
    COP [AddPosition] ( #08, #00 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D54B )
    COP [ExitIfFlagByte] ( #5B, #01 )
    COP [ExitIfFlagByte] ( #5C, #01 )
    COP [StageBgChange] ( #7A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$017A )
    COP [Die]
} >
]

code_05D54B {
    COP [BranchIfNoItem] ( #0B, &code_05D552 )
    BRA loc_05D557
}

code_05D552 {
    COP [BranchIfNoItem] ( #0C, &code_05D56D )

  loc_05D557:
    COP [BranchIfFlagByte] ( #5B, #01, &code_05D568 )
    COP [BranchIfFlagByte] ( #5C, #01, &code_05D568 )
    COP [PrintDialogString] ( &dialogstring_05D593 )
    RTL 
}

code_05D568 {
    COP [PrintDialogString] ( &dialogstring_05D5AC )
    RTL 
}

code_05D56D {
    COP [PrintDialogString] ( &dialogstring_05D5D1 )
    COP [DialogueOptions] ( #02, #02, &code_list_05D577 )
}

code_list_05D577 [
  &code_05D57D   ;00
  &code_05D582   ;01
  &code_05D57D   ;02
]

code_05D57D {
    COP [PrintDialogString] ( &dialogstring_05D5FD )
    RTL 
}

code_05D582 {
    COP [PrintDialogString] ( &dialogstring_05D5FF )
    COP [RemoveItem] ( #0B )
    COP [RemoveItem] ( #0C )
    COP [SetFlagByte] ( #5B )
    COP [SetFlagByte] ( #5C )
    RTL 
}

dialogstring_05D593 `[DEF]There are two keyholes.[END]`

dialogstring_05D5AC `[DEF]Without both keys, [N]the door won't open...[END]`

dialogstring_05D5D1 `[DEF]I have both keys...[N]Put in the keys?[N] Yes[N] No`

dialogstring_05D5FD `[CLD]`

dialogstring_05D5FF `[CLR]The key turns with[N]a strange sound.[END]`