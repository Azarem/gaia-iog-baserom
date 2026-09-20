; Moving lily pad in Watermia — small decorative platform.
; 
; Non-interactive floating pad on the water surface.
; Visual decoration for the canal areas.
---------------------------------------------

---------------------------------------------

wa78_lily_pad [
  actor-def < #1F, #01, #10, {

  code_079B7F:
    COP [NudgePosition] ( #08, #00 )
    COP [ClearCollisionHere]
    COP [SetEntryHere]
    RTL 
} >
]