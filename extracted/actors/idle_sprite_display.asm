; Idle sprite display actor — sets chatPtr to $0085, assigns the shared metasprite table,
; then loops showing sprite frame #06. Used as a simple static NPC/decoration sprite.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!chatPtr                        7F000A

---------------------------------------------

idle_sprite_display [
  actor-def < #00, #20, #00, {

  IdleSpriteDisplayInit:
    LDA #$0085            ; Dialog bank pointer (unused for display-only)
    STA $chatPtr, X
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #06 ) ; Static idle frame
    COP [AnimOnce]
    RTL 
} >
]