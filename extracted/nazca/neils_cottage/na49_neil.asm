; Neil at his cottage — reunion and expedition planning.
; 
; Major NPC (~135 lines). "It's open, come in. Will: Neil.
; It's me. Will from South Cape." Neil: "Oh! Will! You've
; gotten strong! Are all of these people your friends?"
; The reunion at Neil's cottage. Leads to planning the
; Nazca expedition and eventually the Sky Garden trip.
---------------------------------------------

?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

na49_neil [
  actor-def < #13, #00, #10, {

  code_05D89D:
    COP [SpawnAfterFlags] ( @code_05DCED, #$2000 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05D96F )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA #$0098
    STA $0014, Y
    LDA #$0100
    STA $0016, Y
    COP [WaitByte] ( #1D )
    COP [LoopStart] ( #02 )
    COP [PlaySoundBoth] ( #$0505 )
    COP [WaitByte] ( #13 )
    COP [LoopEnd]
    COP [PrintDialogString] ( &dialogstring_05D984 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [WaitByte] ( #1D )
    LDY $playerActor
    LDA #$*code_05D942
    STA $0002, Y
    LDA #$&code_05D942
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y
    LDA #$0800
    TSB $playerFlags
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #01 )
    COP [WaitOnFlagByte] ( #01, #00 )
    COP [StageSpriteLoop] ( #15, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #3C )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05D9C1 )
    COP [SetFlagByte] ( #02 )
    COP [WaitOnFlagByte] ( #02, #00 )
    COP [PrintDialogString] ( &dialogstring_05DA04 )
    COP [SetFlagByte] ( #03 )
    COP [WaitOnFlagByte] ( #03, #00 )
    COP [PrintDialogString] ( &dialogstring_05DAC7 )
    LDA #$0000
    STA $0AA6
    COP [SetFlagByte] ( #05 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
} >
]

code_05D942 {
    COP [LoopStart] ( #03 )
    COP [StagePlayerMoveY] ( #09, #02 )
    COP [AnimOnce]
    COP [LoopEnd]
    LDY $playerActor
    LDA #$*player_character.PlayerIdleEntry
    STA $0002, Y
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y
    RTL 
}

code_05D96F {
    LDA $0AA6
    CMP #$000F
    BEQ loc_05D97C
    COP [PrintDialogString] ( &dialogstring_05DB1C )
    RTL 

  loc_05D97C:
    COP [PrintDialogString] ( &dialogstring_05DB9C )
    COP [SetFlagByte] ( #06 )
    RTL 
}

dialogstring_05D984 `[PAU:1E][TPL:A][TPL:6]Neil: [N]It's open, come in. [FIN][TPL:0]Will: [N]Neil. It's me. [N]Will from South Cape.[END]`

dialogstring_05D9C1 `[TPL:A][TPL:6]Neil: [N]Oh! Will! [N]You've gotten strong! [FIN]Are all of these people[N]your friends?[END]`

dialogstring_05DA04 `[TPL:B][TPL:6]Neil: Hey, hey. [N]Both of you talk [N]pretty  harshly. [FIN]When you're wrapped up [N]in inventing something, [N]you don't care [N]about your appearance. [FIN]I don't think the smell [N]is that bad. Not enough [N]to hate me for it. [FIN]I've only been wearing[N]these socks for a month.[END]`

dialogstring_05DAC7 `[TPL:A][TPL:6]Neil: [N]I've heard enough [N]about my socks. [FIN]Make yourself at home. [N]You're Will's friends. [N]Welcome. [END]`

dialogstring_05DB1C `[TPL:A][TPL:6]Neil: It's been about [N]two years since we [N]last met, hasn't it? [FIN]I've invented lots of[N]things since then.[FIN]The four inventions in[N]this room are my[N]best work. Have a look.[END]`

dialogstring_05DB9C `[TPL:B][TPL:6]Tell me why you came[N]to see me.[FIN][TPL:0]Will tells Neil about [N]hearing his father's[N]voice, and visiting [FIN]the world's ruins in [N]his search to [N]find the Mystic Statues. [FIN][TPL:6]Neil: [N]Heh heh. [N]Interesting. [FIN]I, too, have some[N]interest in ruins.[FIN]The ruins Will talked [N]about are scattered over [N]the world, but they have [N]something in common. [FIN]Drawing a line among[N]the ruins makes a shape[N]that looks like the[N]constellation of Cygnus.[END]`

code_05DCED {
    COP [SetEntryHere]
    LDA $playerYPos
    CMP #$00D0
    BEQ loc_05DCF8
    RTL 

  loc_05DCF8:
    COP [BranchIfPressed] ( #$0400, &code_05DCFF )
    RTL 
}

code_05DCFF {
    COP [PrintDialogString] ( &dialogstring_05DD04 )
    RTL 
}

dialogstring_05DD04 `[TPL:A][TPL:6]Neil: Will, where are you [N]going in such a hurry? [N]Stay a while.[PAL:0][END]`