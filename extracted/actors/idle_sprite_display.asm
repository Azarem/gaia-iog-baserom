?INCLUDE 'table_0EE000'

!chatPtr                        7F000A

---------------------------------------------

idle_sprite_display [
  actor-def < #00, #20, #00, {

  code_08FD02:
    LDA #$0085
    STA $chatPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
} >
]