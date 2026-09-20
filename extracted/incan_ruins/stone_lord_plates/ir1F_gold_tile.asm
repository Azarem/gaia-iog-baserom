; Gold floor tile puzzle — detects player/actor stepping on the tile.
; 
; Part of a 4-tile puzzle: checks both player proximity (1 tile)
; and 4 other actor slots (actors #02-#05, 1 tile each) using
; BranchIfActorNear. When any valid entity steps on, sets a flag
; via cop_handlers_flags.SetFlagRaw using $0E as the flag index.
; When empty, clears the flag. The companion ir1F_plate_gate_opener
; checks when all 4 flags ($001E) are set to open the gate.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'

---------------------------------------------

ir1F_gold_tile [
  actor-def < #00, #00, #23, {

  code_09C3BE:
    COP [BranchIfFlagByte] ( #3C, #01, &code_09C40E )
    COP [AddPosition] ( #08, #08 )

  code_09C3C8:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_09C3EE )
    COP [BranchIfActorNear] ( #02, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #03, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #04, #01, &code_09C407 )
    COP [BranchIfActorNear] ( #05, #01, &code_09C407 )
    LDA $0E
    JSL $@cop_handlers_flags.ClearFlagRaw
    RTL 
} >
]

code_09C3EE {
    COP [BranchIfFlagByte] ( #0F, #01, &code_09C3FB )
    COP [PrintDialogString] ( &dialogstring_09C410 )
    COP [SetFlagByte] ( #0F )
}

code_09C3FB {
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_09C407 )
    COP [SetEntryExitNow] ( @code_09C3C8 )
}

code_09C407 {
    LDA $0E
    JSL $@cop_handlers_flags.SetFlagRaw
    RTL 
}

code_09C40E {
    COP [Die]
}

dialogstring_09C410 `[DEF]Stepping on a gold [N]tile emits a sound. [FIN]There are[N]four gold tiles. [FIN]Stand on each of the[N]four tiles at the same[N]time. [END]`