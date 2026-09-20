; Hidden Dark Space portal in the collapsed tunnel (map $40).
; 
; Checks event flag $0132 — if not set, waits and rechecks each frame.
; Once the flag is set (tunnel cleared), spawns a Dark Space portal
; with config $2B00 (type=1, displayMode=$2000) and despawns self.
---------------------------------------------

?BANK 05

?INCLUDE 'dark_space'

---------------------------------------------

dm40_hidden_dark_space [
  actor-def < #24, #00, #20, {

  code_05D621:
    COP [BranchOnFlagWord] ( #$0132, #01, &code_05D62D )
    COP [WaitOnFlagWord] ( #$0132, #01 )
} >
]

code_05D62D {
    COP [SpawnAfterFlags] ( @dark_space.DarkSpacePortalInit, #$2B00 )
    LDA #$0001
    STA $0024, Y
    LDA #$2000
    STA $000E, Y
    COP [Die]
}