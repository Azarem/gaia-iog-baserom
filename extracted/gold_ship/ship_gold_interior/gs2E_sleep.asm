; Sleep event in the freed ship — triggers the dream and Freedan form.
; 
; Interactable bed/rest point. If flags $4E and $4F are not set,
; offers to sleep. Sets musicRoomGroup to 2 for the dream music.
; Checks flag $F8 for the dream state. When sleeping, triggers
; the Shira dream scene (gs2A_shira) and manages the Freedan
; form transition via player_transition_handlers.
---------------------------------------------

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
    COP [SetInteractHandler] ( &code_0586AE )
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #4E, #01 )
    COP [WaitOnFlagByte] ( #4F, #01 )
    COP [WaitByte] ( #01 )
    LDA #$0002
    STA $musicRoomGroup
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #F8, #01, &code_05864F )
    RTL 
} >
]

code_05864F {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #04, #0C, #06, &code_05865A )
    RTL 
}

code_05865A {
    COP [LoopStart] ( #1E )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [LoopEnd]
    COP [PrintDialogString] ( &dialogstring_0586CC )
    LDY $playerActor
    LDA #$*player_transition_handlers.PlayerFreedanRevealIdle
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerFreedanRevealIdle
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
    COP [BranchOnFlagByte] ( #4E, #00, &code_0586C7 )
    COP [BranchOnFlagByte] ( #4F, #00, &code_0586C7 )
    COP [BranchOnFlagByte] ( #F8, #01, &code_0586C2 )
    BRA code_0586C7
}

code_0586C2 {
    COP [PrintDialogString] ( &dialogstring_058759 )
    RTL 
}

code_0586C7 {
    COP [PrintDialogString] ( &dialogstring_05870A )
    RTL 
}

dialogstring_0586CC `[DEF][TPL:0]Will: I fell into a [N]deep sleep, and was [N]pulled inside a dream.[PAL:0][END]`

dialogstring_05870A `[DEF]Oh, King.[N]Looking around the ship?[FIN]But I expect you're[N]tired. Look around,[N]then rest in this bed.[END]`

dialogstring_058759 `[DEF]I'm sorry that it's so[N]shabby, but please try[N]to get some rest.[END]`