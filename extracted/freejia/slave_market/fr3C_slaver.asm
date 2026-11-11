; Slave market guard (scene $3C).
; 
; Solid guard with a talk handler: prints 'Hey, boy! Kids can't come here! Go home! Go home! Or did you come to get a laborer?' with a Yes/No choice. No (or cancel) prints 'Go home! Go home!'. Yes prints 'I like your courage! I don't know what you'd do here, but have a look around.' and sets scratch flag $01; the main script then clears its solid mark, steps aside (StageSpriteMoveX) and shows frame #1A. No story flag is tested.
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