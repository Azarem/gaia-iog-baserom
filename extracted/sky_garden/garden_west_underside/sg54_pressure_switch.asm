; Knight-armor plate on the garden west underside (scene $54).
; 
; Dies at spawn when flag word $012F is set. Otherwise it tests each frame whether scene actor #3 (the pushable sg4F_knight_armor4, spawned at tile (3A,2F)) stands at pixel ($0348,$02E0), the tile of the plate itself. When it does it applies BG change #2F, sets $012F and dies. The latch is permanent; nothing resets it when the armor is pushed away.
---------------------------------------------

---------------------------------------------

sg54_pressure_switch [
  actor-def < #00, #00, #20, {

  code_05F74C:
    COP [BranchOnFlagWord] ( #$012F, #01, &code_05F768 )
    COP [SetEntryHere]
    COP [BranchIfActorAt] ( #03, #$0348, #$02E0, &code_05F75F )
    RTL 
} >
]

code_05F75F {
    COP [StageBgChange] ( #2F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$012F )
}

code_05F768 {
    COP [Die]

  loc_05F76A:
    RTL 
}