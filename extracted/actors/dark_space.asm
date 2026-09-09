?INCLUDE 'table_0EE000'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!displayModeFlags               09EC

---------------------------------------------

dark_space [
  actor-def < #24, #00, #0B, {

  code_08D69E:
    LDA $0E
    STA $24
    LDA #$3000
    STA $0E
    BRA code_08D6B5
} >
]

dark_space2 [
  actor-def < #24, #00, #0B, {

  code_08D6AC:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
} >
]

code_08D6B5 {
    LDA #$0004
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #24 )
    COP [SolidHighHere]
    LDA #$2000
    TRB $10
    LDA #$0B00
    TSB $10
    COP [OrActorFlags] ( #$0200 )
    COP [SpawnAfterFlags] ( @code_08D713, #$2300 )
    LDA $24
    STA $0024, Y

  loc_08D6DE:
    COP [StageSprAndHitbox] ( #24 )

  loc_08D6E1:
    COP [BranchIfPlayerNear] ( #05, &code_08D6EE )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D6E1
}

code_08D6EE {
    LDA $10
    BIT #$4000
    BNE loc_08D6F5

  loc_08D6F5:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #20 )

  loc_08D6FD:
    COP [BranchIfPlayerNear] ( #05, &code_08D704 )
    BRA loc_08D70C
}

code_08D704 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D6FD

  loc_08D70C:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    BRA loc_08D6DE
}

code_08D713 {
    COP [SetEntryContinue]
    NOP 
    NOP 
    LDA $displayModeFlags
    BIT #$0080
    BEQ loc_08D720
    RTL 

  loc_08D720:
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #01, &code_08D729 )
    RTL 
}

code_08D729 {
    COP [BranchIfButton] ( #$0801, &code_08D730 )
    RTL 
}

code_08D730 {
    LDA #$CFF0
    TSB $joypadMaskStd
    PHX 
    LDX $playerActor
    LDA $0010, X
    ORA #$2000
    STA $0010, X
    LDA $0014, X
    STA $14
    LDA $0016, X
    STA $16
    PLX 
    COP [PlaySoundBoth] ( #$0C0C )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    PHX 
    LDX $playerActor
    LDY $04
    LDA $0014, Y
    STA $0014, X
    SEC 
    SBC #$0008
    STA $playerXPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $0016, Y
    STA $0016, X
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    PLX 
    LDA #$0101
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    LDA #$0200
    TSB $layerPriorityFlag
    LDA $24
    STA $0AAC
    COP [SetEntryContinue]
    RTL 
}