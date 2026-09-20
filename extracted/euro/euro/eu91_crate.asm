; Crate object in Euro — interactable or obstacle.
; 
; Environmental object in the Euro streets. May contain
; a hidden item or serve as a pushable obstacle.
---------------------------------------------

---------------------------------------------

eu91_crate [
  actor-def < #24, #00, #10, {

  code_07C269:
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #01, #00 )
    COP [NudgePosition] ( #08, #00 )
    COP [SetEntryHere]
    RTL 
} >
]

eu91_crate2 [
  actor-def < #25, #00, #10, {

  code_07C279:
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #01, #00 )
    COP [NudgePosition] ( #08, #00 )
    COP [SetEntryHere]
    RTL 
} >
]