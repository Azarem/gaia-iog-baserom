; Bed of the Gold Ship (scene $2E) — trigger of the Shira dream.
; 
; The actor is solid with a talk handler: flag $4E clear or $4F clear gives 'Looking around the ship? ... rest in this bed'; $4E, $4F and $F8 all set gives 'try to get some rest'; $4E and $4F set with $F8 clear gives the first line again. The script waits for $4E and $4F, sets musicRoomGroup to 2 and then tests $F8 each frame (set by the Mystic Statue ceremony of scene $FD). With $F8 set it tests each frame whether Will stands on tiles (0B,04)-(0C,06). Then it sets the joypad lock ($CFFC), prints 'I fell into a deep sleep...', holds Will in player_transition_handlers.PlayerPoseHold 8 pixels higher, waits 60 ticks (WaitByte #3B), sets $4D, sets musicRoomGroup to 0 and queues scene $2A (the dream with gs2A_shira). No form change is made in this file.
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
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [LoopEnd]
    COP [PrintDialogString] ( &dialogstring_0586CC )
    LDY $playerActor
    LDA #$*player_transition_handlers.PlayerPoseHold
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerPoseHold
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