?INCLUDE 'ec_proximity_door_toggle'

---------------------------------------------

ir28_ceiling_trap_trigger [
  actor-def < #00, #00, #20, {

  code_09C6AC:
    COP [SetEntryContinue]

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
    COP [SetEntryExitNow] ( @code_09C6AE )
}

code_09C6E8 {
    COP [BranchIfFlagByte] ( #01, #01, &code_09C6DE )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$01A8, #$0130, #$2300 )
    BRA code_09C6DF
}

code_09C6FE {
    COP [BranchIfFlagByte] ( #02, #01, &code_09C6DE )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$01C8, #$01C0, #$2300 )
    BRA code_09C6DF
}

code_09C714 {
    COP [BranchIfFlagByte] ( #03, #01, &code_09C6DE )
    COP [SetFlagByte] ( #03 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2DB, #$00E8, #$0260, #$2300 )
    BRA code_09C6DF
}

code_09C72A {
    COP [BranchIfFlagByte] ( #04, #01, &code_09C6DE )
    COP [SetFlagByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$0220, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$0200, #$2300 )
    BRA code_09C6DF
}

code_09C74E {
    COP [BranchIfFlagByte] ( #05, #01, &code_09C6DE )
    COP [SetFlagByte] ( #05 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$01C0, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0088, #$01A0, #$2300 )
    JMP $&code_09C6DF
}

code_09C773 {
    COP [BranchIfFlagByte] ( #06, #01, &code_09C6DE )
    COP [SetFlagByte] ( #06 )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0128, #$0160, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_proximity_door_toggle.code_09C2E4, #$0128, #$0140, #$2300 )
    JMP $&code_09C6DF
}