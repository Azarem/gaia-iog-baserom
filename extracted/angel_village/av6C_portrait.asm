---------------------------------------------

av6C_portrait [
  actor-def < #17, #00, #10, {

  code_06D137:
    BRA loc_06D144
} >
]

av6C_portrait2 [
  actor-def < #17, #00, #10, {

  code_06D13C:
    COP [SetSpritePalette] ( #0C )
    BRA loc_06D144
} >
]

av6C_portrait3 [
  actor-def < #17, #00, #10, {

  loc_06D144:
    COP [AddPosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SetEntryContinue]
    RTL 
} >
]