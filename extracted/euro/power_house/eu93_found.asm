; Power-up discovery in Euro's power house.
; 
; NPC: "You found it here. I understand your wishes. I'll give
; you the power at once." Grants an ability upgrade.
; "Well, go." — brief and direct power acquisition.
---------------------------------------------

!playerStr                      0ADE

---------------------------------------------

eu93_found [
  actor-def < #02, #00, #10, {

  code_07E50E:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07E517 )
    COP [SetEntryHere]
    RTL 
} >
]

code_07E517 {
    COP [BranchOnFlagByte] ( #A6, #01, &code_07E52C )
    COP [SetFlagByte] ( #A6 )
    COP [PrintDialogString] ( &dialogstring_07E531 )
    LDA $playerStr
    INC 
    STA $playerStr
    RTL 
}

code_07E52C {
    COP [PrintDialogString] ( &dialogstring_07E566 )
    RTL 
}

dialogstring_07E531 `[DEF]You found it here. I[N]understand your wishes.[N]I'll give you the power[N]at once.[END]`

dialogstring_07E566 `[DEF]Well, go.[END]`