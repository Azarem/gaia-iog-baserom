?INCLUDE 'table_0EE000'

---------------------------------------------

na49_camera [
  actor-def < #00, #00, #30, {

  code_05E53D:
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_05E54E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E54E {
    COP [PrintWideString] ( &widestring_05E55C )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    RTL 
}

widestring_05E55C `[TPL:B][TPL:6]That's a camera. It will[N]burn a copy of a scene[N]onto printing paper.[FIN]The problem is that it[N]takes almost 30 minutes.[FIN]Scenery doesn't move,[N]but to photograph a[N]person means they can't[N]move for 30 minutes.[FIN]When I used it, the [N]eyes turned bright red [N]like a rabbit's.[PAL:0][END]`