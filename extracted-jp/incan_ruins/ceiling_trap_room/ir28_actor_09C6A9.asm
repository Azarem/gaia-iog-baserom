?INCLUDE 'ec_actor_04FCFB'

---------------------------------------------

h_ir28_actor_09C6A9 [
  actor-def < #00, #00, #20, {

  code_0582AE:
    COP [SetEntryContinue]
} >
]

code_0582B0 {
    COP [BranchIfPlayerInAbsTiles] ( #1A, #0C, #1C, #0E, &chunk_058000.code_0582EA )
    COP [BranchIfPlayerInAbsTiles] ( #1A, #16, #1C, #18, &chunk_058000.code_058300 )
    COP [BranchIfPlayerInAbsTiles] ( #12, #24, #14, #26, &chunk_058000.code_058316 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #24, #0A, #26, &chunk_058000.code_05832C )
    COP [BranchIfPlayerInAbsTiles] ( #10, #1C, #12, #1E, &chunk_058000.code_058350 )
    COP [BranchIfPlayerInAbsTiles] ( #12, #16, #14, #18, &chunk_058000.code_058375 )
}

code_0582E0 {
    RTL 
}

code_0582E1 {
    COP [PlaySoundBoth] ( #$2C2C )
    COP [SetEntryExitNow] ( @chunk_058000.code_0582B0 )
}

code_0582EA {
    COP [BranchIfFlagByte] ( #01, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #01 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$01A8, #$0130, #$2300 )
    BRA chunk_058000.code_0582E1
}

code_058300 {
    COP [BranchIfFlagByte] ( #02, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$01C8, #$01C0, #$2300 )
    BRA chunk_058000.code_0582E1
}

code_058316 {
    COP [BranchIfFlagByte] ( #03, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #03 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD06, #$00E8, #$0260, #$2300 )
    BRA chunk_058000.code_0582E1
}

code_05832C {
    COP [BranchIfFlagByte] ( #04, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #04 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$0220, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$0200, #$2300 )
    BRA chunk_058000.code_0582E1
}

code_058350 {
    COP [BranchIfFlagByte] ( #05, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #05 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$01C0, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0088, #$01A0, #$2300 )
    JMP $&chunk_058000.code_0582E1
}

code_058375 {
    COP [BranchIfFlagByte] ( #06, #01, &chunk_058000.code_0582E0 )
    COP [SetFlagByte] ( #06 )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0128, #$0160, #$2300 )
    COP [WaitByte] ( #0E )
    COP [SpawnAfterAbsFlags] ( @ec_actor_04FCFB.code_04FD0F, #$0128, #$0140, #$2300 )
    JMP $&chunk_058000.code_0582E1
}