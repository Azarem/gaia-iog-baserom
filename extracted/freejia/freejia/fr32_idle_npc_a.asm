; Idle animated NPC A in Freejia — ambient town resident.
; 
; Non-interactable NPC with looping idle animation for
; town atmosphere. No dialog.
---------------------------------------------

---------------------------------------------

fr32_idle_npc_a [
  actor-def < #08, #00, #10, {

  code_05B32F:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #FE, #05 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    RTL 
} >
]