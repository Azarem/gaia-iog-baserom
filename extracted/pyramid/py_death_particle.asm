?INCLUDE 'table_0EE000'

---------------------------------------------

py_death_particle [
  actor-def < #AC, #AA, #09, {

  code_08B6F7:
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [Die]
} >
]