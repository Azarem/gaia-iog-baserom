; Fellow prisoner in the castle prison (scene $0B, tile (02,14)); the label says 'guard' but the dialog ('I don't need anyone's help... I can get out by myself...') is a prisoner's.
; 
; At spawn it replays the unlocked-door state of the Prison Key doors: flag $42 set: ClearTypeAbs (09,17); flag $43 set: ClearTypeAbs (14,17) (no code sets $43). Then it marks itself solid, installs the talk handler and writes the player's attribute word ($0E) every frame: $3000 while Will is inside tiles (0D,12)-(11,14), $2000 elsewhere.
---------------------------------------------

!playerActor                    09AA

---------------------------------------------

ec0B_guard [
  actor-def < #1B, #00, #10, {

  code_04DC1C:
    COP [BranchOnFlagByte] ( #42, #00, &code_04DC26 )
    COP [ClearTypeAbs] ( #09, #17 )
} >
]

code_04DC26 {
    COP [BranchOnFlagByte] ( #43, #00, &code_04DC30 )
    COP [ClearTypeAbs] ( #14, #17 )
}

code_04DC30 {
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04DC59 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0D, #12, #11, #14, &code_04DC4F )
    LDY $playerActor
    LDA #$2000
    STA $000E, Y
    RTL 
}

code_04DC4F {
    LDY $playerActor
    LDA #$3000
    STA $000E, Y
    RTL 
}

code_04DC59 {
    COP [PrintDialogString] ( &dialogstring_04DC5E )
    RTL 
}

dialogstring_04DC5E `[TPL:E]I don't need anyone's[N]help... I can[N]get out by myself...[END]`