---------------------------------------------

sg4C_spirit1 [
  actor-def < #3C, #00, #10, {

  code_05F359:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F36C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F36C {
    COP [PrintWideString] ( &widestring_05F371 )
    RTL 
}

widestring_05F371 `[DEF]Moon Tribe:[N]We meet again. Ku ku ku.[N]You're a strong boy[N]to have come this far.[END]`

sg4C_spirit2 [
  actor-def < #3C, #00, #10, {

  code_05F3B1:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F3C4 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F3C4 {
    COP [PrintWideString] ( &widestring_05F3C9 )
    RTL 
}

widestring_05F3C9 `[DEF]Moon Tribe: This Sky[N]Garden is our mode[N]of transportation.[FIN]There are four Crystal [N]Balls in four locations.[N]Find each one in [N]clockwise order... [END]`

sg4C_spirit3 [
  actor-def < #3C, #00, #10, {

  code_05F456:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F469 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F469 {
    COP [PrintWideString] ( &widestring_05F46E )
    RTL 
}

widestring_05F46E `[DEF]Moon Tribe: Drop off the [N]cliff at the front and [N]back to find the [N]up-side down world... [END]`