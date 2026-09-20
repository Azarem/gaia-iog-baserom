; Herb pickup item in Freejia town.
; 
; Collectible item actor. When interacted: "You found the herbs!"
; If inventory is full: shows the full-inventory message.
; Standard item pickup pattern with flag tracking.
---------------------------------------------

---------------------------------------------

fr32_herb [
  actor-def < #26, #00, #10, {

  code_05CF23:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05CF31 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05CF31 {
    COP [BranchOnFlagByte] ( #53, #01, &code_05CF43 )
    COP [GiveItem] ( #06, &code_05CF44 )
    COP [SetFlagByte] ( #53 )
    COP [PrintDialogString] ( &dialogstring_05CF49 )
}

code_05CF43 {
    RTL 
}

code_05CF44 {
    COP [PrintDialogString] ( &dialogstring_05CF5B )
    RTL 
}

dialogstring_05CF49 `[DEF]You found the herbs![END]`

dialogstring_05CF5B `[DEF]You found the herbs, but[N]your inventory's full![END]`