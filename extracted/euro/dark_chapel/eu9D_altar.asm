; Altar of the Euro dark chapel (scene $9D): a hidden passage behind the statue.
; 
; Invisible actor with one polling loop and an interact handler. The loop first tests scratch $01; if it is clear it sets scratch $00 while the player stands in tiles (0F,07)-(10,09) and clears it outside (the player's idle code reads scratch $00 to pick the alternate sprite set). The handler prints 'What? The wind is blowing from behind the statue... Look?' with rows Yes/No; both rows clear the dialog box and Yes also sets scratch $01. On its next pass the loop plays sound $0101, applies BgChange #69 (the passage), removes the interact handler, clears $01 and continues. No persistent flag records the opening.
---------------------------------------------

---------------------------------------------

eu9D_altar [
  actor-def < #00, #00, #30, {

  code_07E570:
    COP [SetInteractHandler] ( &code_07E5A1 )

  code_07E574:
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #01, #01, &code_07E58C )
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
    COP [SetInteractHandler] ( #$0000 )
    COP [ClearFlagByte] ( #01 )
    COP [JumpNextFrame] ( @code_07E574 )
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