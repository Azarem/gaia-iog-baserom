; Null ambient actor for South Cape chimney smoke.
; 
; Single actor-def with immediate RTL. Smoke effect is likely handled
; by the scene tilemap animation rather than this actor.
---------------------------------------------

---------------------------------------------

sc01_smoke [
  actor-def < #01, #00, #03, {

  code_048003:
    RTL 
} >
]