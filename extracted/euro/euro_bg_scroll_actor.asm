; Background scroll controller for Euro town.
; 
; Technical actor that manages parallax background scrolling
; in the Euro town map. Provides the visual depth effect.
---------------------------------------------

---------------------------------------------

euro_bg_scroll_actor [
  actor-def < #02, #00, #10, {

  code_07D08F:
    COP [AddPosition] ( #00, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryContinue]
    RTL 
} >
]