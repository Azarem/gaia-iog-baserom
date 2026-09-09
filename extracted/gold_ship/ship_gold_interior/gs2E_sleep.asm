?INCLUDE 'player_transition_handlers'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!musicRoomGroup                 06F6
!playerActor                    09AA

---------------------------------------------

gs2E_sleep [
  actor-def < #0A, #00, #10, {

  code_05862F:
    COP [SetOnInteract] ( &code_0586AE )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #4E, #01 )
    COP [ExitIfFlagByte] ( #4F, #01 )
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #F8, #01, &code_05864F )
    RTL 
} >
]

code_05864F {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #04, #0C, #06, &code_05865A )
    RTL 
}

code_05865A {
    COP [LoopInit] ( #1E )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [PrintWideString] ( &widestring_0586CC )
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C45E
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C45E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $0016, Y
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #4D )
    LDA #$0000
    STA $musicRoomGroup
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #2A, #$00A0, #$0070, #03, #$1100 )
    RTL 
}

code_0586AE {
    COP [BranchIfFlagByte] ( #4E, #00, &code_0586C7 )
    COP [BranchIfFlagByte] ( #4F, #00, &code_0586C7 )
    COP [BranchIfFlagByte] ( #F8, #01, &code_0586C2 )
    BRA code_0586C7
}

code_0586C2 {
    COP [PrintWideString] ( &widestring_058759 )
    RTL 
}

code_0586C7 {
    COP [PrintWideString] ( &widestring_05870A )
    RTL 
}

widestring_0586CC `[DEF][TPL:0]Will: I fell into a [N]deep sleep, and was [N]pulled inside a dream.[PAL:0][END]`

widestring_05870A `[DEF]Oh, King.[N]Looking around the ship?[FIN]But I expect you're[N]tired. Look around,[N]then rest in this bed.[END]`

widestring_058759 `[DEF]I'm sorry that it's so[N]shabby, but please try[N]to get some rest.[END]`