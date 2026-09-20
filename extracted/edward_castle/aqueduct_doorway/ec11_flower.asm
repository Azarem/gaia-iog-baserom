; Flower NPC in the aqueduct doorway.
; 
; Tells Will to play the Flute melody. Part of the melody-gated
; progression system.
---------------------------------------------

---------------------------------------------

ec11_flower [
  actor-def < #3F, #00, #18, {

  code_09BC37:
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #00, #02 )
    COP [SetInteractHandler] ( &code_09BC4C )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #3F )
    COP [AnimOnce]
    RTL 
} >
]

code_09BC4C {
    COP [PrintDialogString] ( &dialogstring_09BC51 )
    RTL 
}

dialogstring_09BC51 `[DEF]Flower in the corner:[N]Try playing the Flute...[N]Play the melody...[END]`