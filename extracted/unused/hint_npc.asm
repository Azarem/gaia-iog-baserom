!sfxQueueCh1                    06F8

---------------------------------------------

hint_npc1 [
  actor-def < #05, #00, #30, {

  code_09A0DA:
    LDA $0E
    STA $26
    LDA #$2000
    STA $0E
    BRA loc_09A0F9
} >
]
---------------------------------------------

hint_npc2 [
  actor-def < #05, #00, #30, {

  code_09A0E8:
    LDA $0E
    STA $26
    LDA #$2000
    STA $0E
    COP [StageSprAndHitbox] ( #85 )
    LDA #$0002
    TSB $12

  loc_09A0F9:
    COP [AddPosition] ( #F8, #00 )
    COP [SpawnAfterRelFlags] ( @code_09A38D, #$0000, #$FFD0, #$1800 )
    COP [SpawnAfterRelFlags] ( @code_09A3A0, #$0000, #$FFD0, #$1800 )
    COP [AddPosition] ( #F8, #01 )
    COP [SetOnInteract] ( &code_09A123 )
    LDA #$0000
    STA $24
    COP [SetEntryContinue]
    RTL 
} >
]

code_09A123 {
    LDA #$FFFF
    STA $24
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_09A133 )
}

code_list_09A133 [
  &code_09A149   ;00
  &code_09A14F   ;01
  &code_09A155   ;02
  &code_09A15B   ;03
  &code_09A161   ;04
  &code_09A167   ;05
  &code_09A16D   ;06
  &code_09A173   ;07
]
---------------------------------------------

code_09A143 {
    LDA #$0000
    STA $24
    RTL 
}

code_09A149 {
    COP [PrintWideString] ( &widestring_09A179 )
    BRA code_09A143
}

code_09A14F {
    COP [PrintWideString] ( &widestring_09A17B )
    BRA code_09A143
}

code_09A155 {
    COP [PrintWideString] ( &widestring_09A1F0 )
    BRA code_09A143
}

code_09A15B {
    COP [PrintWideString] ( &widestring_09A240 )
    BRA code_09A143
}

code_09A161 {
    COP [PrintWideString] ( &widestring_09A28A )
    BRA code_09A143
}

code_09A167 {
    COP [PrintWideString] ( &widestring_09A2CB )
    BRA code_09A143
}

code_09A16D {
    COP [PrintWideString] ( &widestring_09A319 )
    BRA code_09A143
}

code_09A173 {
    COP [PrintWideString] ( &widestring_09A355 )
    BRA code_09A143
}

widestring_09A179 `[DEF][END]`

widestring_09A17B `[DEF]Defeat the enemies[N]in a certain area to get[N]an increase in attack [N]power and a jewel.[FIN]You must defeat all of[N]the demons...[END]`

widestring_09A1F0 `[DEF]Jewels will appear if [N]you defeat an enemy. [N]If you can't reach them [N]use the Flute's power. [END]`

widestring_09A240 `[DEF]You need DP to use the[N]Dark Power...[FIN]Your DP increases as you[N]collect Dark Jewels...[END]`

widestring_09A28A `[DEF]You need to jump to[N]continue, but you must[N]stop once in a while...[END]`

widestring_09A2CB `[DEF]There are many cracks in [N]the Pyramid. He who [N]looks down on the block [N]floor will sink...[END]`

widestring_09A319 `[DEF]This is a fight to the[N]finish. Act before you[N]are acted upon...[END]`

widestring_09A355 `[DEF]The stalks are connected[N]by the power of the[N]water droplets...[END]`

code_09A38D {
    COP [StageSprAndHitbox] ( #05 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
}

code_09A3A0 {
    COP [StageSprAndHitbox] ( #07 )

  loc_09A3A3:
    COP [SetEntryContinue]
    LDY $24
    LDA $0024, Y
    BNE loc_09A3AD
    RTL 

  loc_09A3AD:
    LDA $sfxQueueCh1
    BNE loc_09A3B3
    RTL 

  loc_09A3B3:
    COP [RngByte]
    AND #$0003
    DEC 
    BEQ loc_09A3C9
    DEC 
    BEQ loc_09A3D4
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A3A3

  loc_09A3C9:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A3A3

  loc_09A3D4:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_09A3A3
}