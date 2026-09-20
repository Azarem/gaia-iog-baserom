; Queen Edwina NPC in the castle.
; 
; Brief dialog directing Will to speak with King Edward.
---------------------------------------------

---------------------------------------------

ec0A_edwina [
  actor-def < #2B, #00, #18, {

  code_04C571:
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &code_04C588 )
    COP [WaitOnFlagByte] ( #0B, #01 )
    COP [SetFlagByte] ( #0C )
    COP [SetEntryHere]
    RTL 
} >
]

code_04C588 {
    COP [PrintDialogString] ( &dialogstring_04C58D )
    RTL 
}

dialogstring_04C58D `[DEF][TPL:3]Queen Edwina:[N]The King sent you the[N]letter. Talk to him.[PAL:0][END]`