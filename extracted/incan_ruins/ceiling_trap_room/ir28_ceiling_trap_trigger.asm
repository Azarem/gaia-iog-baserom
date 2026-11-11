; Ceiling trap controller of scene $28 (Incan Ruins ceiling trap room).
; 
; Invisible actor that polls six BranchIfPlayerInAbsTiles rectangles every frame: (1A,0C)-(1C,0E), (1A,16)-(1C,18), (12,24)-(14,26), (08,24)-(0A,26), (10,1C)-(12,1E) and (12,16)-(14,18). Each rectangle has its own latch, scratch flag $01-$06 (set on entry and zeroed at every scene load, so a zone fires once per visit). A zone that fires spawns falling-tile helpers of ec_proximity_door_toggle at absolute pixel positions with SpawnAfterAbsFlags: zones 1-3 spawn one code_09C2DB helper each ((01A8,0130), (01C8,01C0), (00E8,0260)); zones 4-6 spawn two code_09C2E4 helpers each, with a WaitByte #0E between them ((0088,0220) and (0088,0200), (0088,01C0) and (0088,01A0), (0128,0160) and (0128,0140)). code_09C2DB marks the landing tile solid and code_09C2E4 clears its collision. After every zone check the actor plays sound $2C2C and polls again.
---------------------------------------------

?INCLUDE 'ec_proximity_door_toggle'

---------------------------------------------

ir28_ceiling_trap_trigger [
  actor-def < #00, #00, #20, {

  code_09C6AC:
    COP [SetEntryHere]

  code_09C6AE:
    COP [BranchIfPlayerInAbsTiles] ( #1A, #0C, #1C, #0E, &code_09C6E8 )
    COP [BranchIfPlayerInAbsTiles] ( #1A, #16, #1C, #18, &code_09C6FE )
    COP [BranchIfPlayerInAbsTiles] ( #12, #24, #14, #26, &code_09C714 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #24, #0A, #26, &code_09C72A )
    COP [BranchIfPlayerInAbsTiles] ( #10, #1C, #12, #1E, &code_09C74E )
    COP [BranchIfPlayerInAbsTiles] ( #12, #16, #14, #18, &code_09C773 )

  code_09C6DE:
    RTL 
} >
]

code_09C6DF {
    COP [PlaySoundBoth] ( #$2C2C )
    COP [JumpNextFrame] ( @code_09C6AE )
}

code_09C6E8 {
    COP [BranchOnFlagByte] ( #01, #01, &code_09C6DE )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$01A8, #$0130, #$2300 )
    BRA code_09C6DF
}

code_09C6FE {
    COP [BranchOnFlagByte] ( #02, #01, &code_09C6DE )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$01C8, #$01C0, #$2300 )
    BRA code_09C6DF
}

code_09C714 {
    COP [BranchOnFlagByte] ( #03, #01, &code_09C6DE )
    COP [SetFlagByte] ( #03 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$00E8, #$0260, #$2300 )
    BRA code_09C6DF
}

code_09C72A {
    COP [BranchOnFlagByte] ( #04, #01, &code_09C6DE )
    COP [SetFlagByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$0220, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$0200, #$2300 )
    BRA code_09C6DF
}

code_09C74E {
    COP [BranchOnFlagByte] ( #05, #01, &code_09C6DE )
    COP [SetFlagByte] ( #05 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$01C0, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$01A0, #$2300 )
    JMP $&code_09C6DF
}

code_09C773 {
    COP [BranchOnFlagByte] ( #06, #01, &code_09C6DE )
    COP [SetFlagByte] ( #06 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0128, #$0160, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0128, #$0140, #$2300 )
    JMP $&code_09C6DF
}