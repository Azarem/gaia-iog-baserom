; Bonfire in the Native Village — central gathering fire.
; 
; Animated fire sprite. No dialog. Central visual element
; of the village that the NPCs gather around.
---------------------------------------------

---------------------------------------------

nvAC_bonfire [
  actor-def < #31, #00, #18, {

  code_088C54:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088C6B )
    LDA #$1000
    TSB $12
    COP [StageSprAndHitbox] ( #31 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_088C6B {
    COP [Die]
}