; Idle animated NPC B in Freejia — ambient town resident.
; 
; Non-interactable NPC with looping idle animation. No dialog.
---------------------------------------------

---------------------------------------------

fr32_idle_npc_b [
  actor-def < #11, #00, #10, {

  code_05B360:
    COP [SetSpritePriority] ( #10 )
    COP [NudgePosition] ( #02, #05 )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHere]
    RTL 
} >
]