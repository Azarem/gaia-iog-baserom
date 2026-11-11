; Block slot of the Incan Ruins entryway (scene $25), scene row at tile (0E,1C).
; 
; Spawns hidden (the third actor-def byte #23 sets $2000 in $10) and nudges its position by (08,00). With flag $2F (the Blue Block was fitted into the slot by UseItem_DiamondBlock_Place) set at spawn it runs code_09C3B3: it clears $2000 in $10, which shows the block, and idles. With $2F clear it waits with WaitOnFlagByte(#2F, #01), plays sound #2C on channel 2 and then runs the same show-block code.
---------------------------------------------

---------------------------------------------

ir25_block_slot [
  actor-def < #1D, #01, #23, {

  code_09C3A2:
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_09C3B3 )
    COP [WaitOnFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )
} >
]

code_09C3B3 {
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}