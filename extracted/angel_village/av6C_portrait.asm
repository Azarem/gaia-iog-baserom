; Portrait interactive object in the Angel Village rooms.
; 
; Examinable painting on the wall. When interacted with,
; may reveal hidden content or provide visual detail about
; the Angel Tribe's history.
---------------------------------------------

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
    COP [NudgePosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SetEntryHere]
    RTL 
} >
]