; Altar in the Euro dark chapel — hidden passage clue.
; 
; Interactive object. Will: "What? The wind is blowing from
; behind the statue... Look?" Reveals a secret passage in
; the chapel. Important exploration discovery.
---------------------------------------------

---------------------------------------------

eu9D_altar [
  actor-def < #00, #00, #30, {

  code_07E570:
    COP [SetOnInteract] ( &code_07E5A1 )

  code_07E574:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_07E58C )
    COP [BranchIfPlayerInAbsTiles] ( #0F, #07, #10, #09, &code_07E588 )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_07E588 {
    COP [SetFlagByte] ( #00 )
    RTL 
}

code_07E58C {
    COP [PlaySoundBoth] ( #$0101 )
    COP [StageBgChange] ( #69 )
    COP [ApplyBgChange]
    COP [SetOnInteract] ( #$0000 )
    COP [ClearFlagByte] ( #01 )
    COP [SetEntryExitNow] ( @code_07E574 )
}

code_07E5A1 {
    COP [PrintDialogString] ( &dialogstring_07E5BE )
    COP [DialogueOptions] ( #02, #01, &code_list_07E5AB )
}

code_list_07E5AB [
  &code_07E5B1   ;00
  &code_07E5B6   ;01
  &code_07E5B1   ;02
]

code_07E5B1 {
    COP [PrintDialogString] ( &dialogstring_07E602 )
    RTL 
}

code_07E5B6 {
    COP [PrintDialogString] ( &dialogstring_07E602 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_07E5BE `[DEF][TPL:0]Will: What? [N]The wind is blowing from [N]behind the statue... [FIN]Look?[N] Yes[N] No`

dialogstring_07E602 `[CLD]`