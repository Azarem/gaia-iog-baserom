; Buried tile discovery at Nazca — the ground painting puzzle.
; 
; Key story event (~128 lines). "There's a tile buried in the
; sand... When Will's Flute touched it, there was a rumbling
; sound." Neil: "Will! Don't look yet! You don't know what's
; in there!!" The Flute reveals a buried tile that is part
; of the Nazca ground painting discovery. Triggers the
; Sky Garden revelation sequence.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!COLDATA                        2132
!orbitAngle                     7F0010

---------------------------------------------

na4B_buried_tile [
  actor-def < #00, #00, #30, {

  code_05E64A:
    COP [SpawnAfterFlags] ( @code_05E7D0, #$2000 )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05E6AD )
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    LDA #$00E0
    STA $orbitAngle, X
    COP [LoopInit] ( #08 )
    LDA $orbitAngle, X
    SEP #$20
    STA $COLDATA
    REP #$20
    INC 
    STA $orbitAngle, X
    COP [WaitByte] ( #1F )
    COP [LoopNext]
    COP [PrintDialogString] ( &dialogstring_05E753 )
    COP [SetFlagByte] ( #0C )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_05E7A6, #$0300 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_05E774 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #4C, #$0168, #$0040, #83, #$2200 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E6AD {
    COP [BranchIfFlagByte] ( #0B, #00, &code_05E6BB )
    COP [PrintDialogString] ( &dialogstring_05E6C0 )
    COP [SetFlagByte] ( #0F )
    RTL 
}

code_05E6BB {
    COP [PrintDialogString] ( &dialogstring_05E721 )
    RTL 
}

dialogstring_05E6C0 `[DEF][TPL:0][DLY:0]There's a tile buried[N]in the sand...[FIN]When Will's Flute [N]touched it, there [N]was a rumbling sound![PAL:0][END]`

dialogstring_05E721 `[DEF][TPL:6]Neil: Will! Don't [N]look yet! You don't [N]know what's in there!![PAL:0][END]`

dialogstring_05E753 `[DEF][TPL:3][DLY:0]Erik: [N]Hey! Something huge [N]is coming down!![PAL:0][END]`

dialogstring_05E774 `[TPL:E][TPL:1][DLY:0]Kara: [N]Will! Will! [N]Wi-i-i-i-i-i-l-l-l-l! [PAL:0][PAU:28][CLD]`

code_05E7A6 {
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$0C0C )
    COP [SetFlagByte] ( #0D )
    COP [SetEntryContinue]
    RTL 
}

code_05E7D0 {
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0014, Y
    CMP #$0008
    BEQ loc_05E7F0
    CMP #$03F8
    BEQ loc_05E7F7
    LDA $0016, Y
    CMP #$0020
    BEQ loc_05E7FE
    CMP #$0400
    BEQ loc_05E805
    RTL 

  loc_05E7F0:
    COP [BranchIfButton] ( #$0200, &code_05E80C )
    RTL 

  loc_05E7F7:
    COP [BranchIfButton] ( #$0100, &code_05E80C )
    RTL 

  loc_05E7FE:
    COP [BranchIfButton] ( #$0800, &code_05E80C )
    RTL 

  loc_05E805:
    COP [BranchIfButton] ( #$0400, &code_05E80C )
    RTL 
}

code_05E80C {
    COP [PrintDialogString] ( &dialogstring_05E811 )
    RTL 
}

dialogstring_05E811 `[DEF][TPL:0]Will: [N]Nazca is huge, so [N]don't go too far....[PAL:0][END]`