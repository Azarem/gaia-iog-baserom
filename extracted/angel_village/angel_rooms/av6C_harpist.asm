; Harpist NPC in the Angel Village rooms — ambient musician.
; 
; Decorative NPC playing a harp with looping animation.
; No interaction dialog. Provides atmosphere for the
; village's musical culture.
---------------------------------------------

---------------------------------------------

av6C_harpist [
  actor-def < #18, #00, #10, {

  code_06D127:
    LDA #$0200
    TSB $12
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]