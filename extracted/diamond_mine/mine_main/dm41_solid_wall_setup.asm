---------------------------------------------

dm41_solid_wall_setup [
  actor-def < #00, #00, #30, {

  code_05D6F6:
    COP [DrawMetatileAbs] ( #26, #01, #05 )
    COP [DrawMetatileAbs] ( #22, #01, #05 )
    COP [SolidHighAbs] ( #26, #01 )
    COP [SolidHighAbs] ( #22, #01 )
    COP [Die]
} >
]