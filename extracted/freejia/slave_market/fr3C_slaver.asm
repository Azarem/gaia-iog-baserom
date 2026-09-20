; Slave market guard — alternates between threatening and inviting.
; 
; Multi-state NPC (~52 lines). Initially: "Hey, boy! Kids can't
; come here! Go home!" Later: "I like your courage! I don't know
; what you'd do here, but have a look around." Controls access
; to the market area and shifts tone with story progression.
---------------------------------------------

---------------------------------------------

fr3C_slaver [
  actor-def < #1A, #00, #10, {

  code_05C157:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05C173 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05C173 {
    COP [PrintDialogString] ( &dialogstring_05C190 )
    COP [DialogueOptions] ( #02, #02, &code_list_05C17D )
}

code_list_05C17D [
  &code_05C183   ;00
  &code_05C188   ;01
  &code_05C183   ;02
]

code_05C183 {
    COP [PrintDialogString] ( &dialogstring_05C21F )
    RTL 
}

code_05C188 {
    COP [PrintDialogString] ( &dialogstring_05C1E2 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05C190 `[TPL:B]Hey, boy![N]Kids can't come here![N]Go home! Go home![FIN]Or did you come to [N]get a laborer? [N] Yes [N] No `

dialogstring_05C1E2 `[CLR]I like your courage! [N]I don't know what [N]you'd do here, but have [N]a look around. [END]`

dialogstring_05C21F `[CLR]Go home! Go home![END]`