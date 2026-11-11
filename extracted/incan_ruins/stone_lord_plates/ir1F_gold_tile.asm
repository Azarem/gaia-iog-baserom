; Gold floor tile of the four-plate puzzle in scene $1F. Four copies; the spawn parameter bytes #03, #05, #07 and #09 give the actor word $0E = 1, 2, 3, 4.
; 
; With flag $3C set at spawn it dies. Otherwise it nudges its position by (08,08) and tests every frame BranchIfPlayerNear(#01) and BranchIfActorNear(slot, #01) for the actors in slots #02-#05 of the scene's actor list (the four stone lords), each with radius 1. When nothing stands on the tile it calls flag_helpers.ClearFlagRaw with A = $0E; when something does it calls flag_helpers.SetFlagRaw with A = $0E, so each tile owns scratch flag $01-$04. The first time the player steps on a tile in a visit it prints 'Stepping on a gold tile emits a sound. There are four gold tiles. Stand on each of the four tiles at the same time.' (latched by scratch flag $0F). ir1F_plate_gate_opener reads eventFlags AND $001E (bits 1-4) to see that all four tiles are occupied.
---------------------------------------------

?INCLUDE 'flag_helpers'

---------------------------------------------

ir1F_gold_tile [
  actor-def < #00, #00, #23, {

  code_09C3BE:
    COP [BranchOnFlagByte] ( #3C, #01, &code_09C40E )
    COP [NudgePosition] ( #08, #08 )

  code_09C3C8:
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #01, &code_09C3EE )
    COP [BranchIfActorNear] ( #02, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #03, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #04, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #05, #01, &code_09C407 )
    LDA $0E
    JSL $@flag_helpers.ClearFlagRaw
    RTL 
} >
]

code_09C3EE {
    COP [BranchOnFlagByte] ( #0F, #01, &code_09C3FB )
    COP [PrintDialogString] ( &dialogstring_09C410 )
    COP [SetFlagByte] ( #0F )
}

code_09C3FB {
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #01, &code_09C407 )
    COP [JumpNextFrame] ( @code_09C3C8 )
}

code_09C407 {
    LDA $0E
    JSL $@flag_helpers.SetFlagRaw
    RTL 
}

code_09C40E {
    COP [Die]
}

dialogstring_09C410 `[DEF]Stepping on a gold [N]tile emits a sound. [FIN]There are[N]four gold tiles. [FIN]Stand on each of the[N]four tiles at the same[N]time. [END]`