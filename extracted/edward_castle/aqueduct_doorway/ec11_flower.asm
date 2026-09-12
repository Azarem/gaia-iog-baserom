---------------------------------------------

ec11_flower [
  actor-def < #3F, #00, #18, {

  code_09BC37:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #00, #02 )
    COP [SetOnInteract] ( &code_09BC4C )
    COP [SetEntryContinue]
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