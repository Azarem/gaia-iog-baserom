?INCLUDE 'table_0EE000'

---------------------------------------------

na49_tank [
  actor-def < #00, #00, #30, {

  code_05E308:
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05E319 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E319 {
    COP [PrintWideString] ( &widestring_05E327 )
    LDA $0AA6
    ORA #$0001
    STA $0AA6
    RTL 
}

widestring_05E327 `[TPL:B][TPL:6]Neil: [N]That's an oxygen tank. [N]There's air inside. [FIN]With this you can [N]breathe underwater, but [N]there's only one minute's [N]worth of air inside. [FIN]Compressing the air [N]would let you stay [N]underwater longer, but [N]I don't know how to do it.[PAL:0][END]`