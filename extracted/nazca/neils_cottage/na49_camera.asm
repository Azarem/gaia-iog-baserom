; Camera object in Neil's cottage — invention description.
; 
; Interactive object: "That's a camera. It will burn a copy of a
; scene onto printing paper. The problem is that it takes too
; long." Shows Neil's invention progress. Early photography
; concept in the game's pseudo-historical setting.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

na49_camera [
  actor-def < #00, #00, #30, {

  code_05E53D:
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_05E54E )
    COP [SetEntryHere]
    RTL 
} >
]

code_05E54E {
    COP [PrintDialogString] ( &dialogstring_05E55C )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    RTL 
}

dialogstring_05E55C `[TPL:B][TPL:6]That's a camera. It will[N]burn a copy of a scene[N]onto printing paper.[FIN]The problem is that it[N]takes almost 30 minutes.[FIN]Scenery doesn't move,[N]but to photograph a[N]person means they can't[N]move for 30 minutes.[FIN]When I used it, the [N]eyes turned bright red [N]like a rabbit's.[PAL:0][END]`