; Kara in the undersea tunnel — complains about conditions.
; 
; Extended NPC (~152 lines). "I want a steak! And a salad!
; My skin has gone dry from eating nothing but mushrooms."
; Multi-phase dialog showing Kara's frustration during the
; long tunnel journey. Character development through humor.
---------------------------------------------

?INCLUDE 'camera_drift'
?INCLUDE 'flag_helpers'

!gfxCacheIdxB                   064A

---------------------------------------------

st68_kara [
  actor-def < #1C, #00, #10, {

  code_06AF32:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AF3E )
} >
]

code_list_06AF3E [
  &code_06AF44   ;00
  &code_06AF81   ;01
  &code_06AF83   ;02
]

code_06AF44 {
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #1E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_06B064 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06B0BC )
    COP [SetFlagByte] ( #04 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_06AF81 {
    COP [Die]
}

code_06AF83 {
    COP [SetTilePos] ( #15, #1B )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [WaitByte] ( #3B )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #59 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #1B, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06B10B )
    COP [CallNear] ( &code_06B00C )
    COP [WaitByte] ( #3B )
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_06B13C )
    COP [WaitByte] ( #59 )
    COP [CallNear] ( &code_06B03C )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_06B195 )
    COP [WaitByte] ( #3B )
    COP [CallNear] ( &code_06B03C )
    COP [PrintDialogString] ( &dialogstring_06B250 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06B3EC )
    JSL $@flag_helpers.ClearAllWramFlags
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    COP [SetEntryHere]
    RTL 
}

code_06B00C {
    COP [WaitByte] ( #27 )
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2800 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #3B )
    COP [LoopStart] ( #02 )
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopShip, #$2800 )
    LDA #$FFFF
    STA $0024, Y
    COP [WaitByte] ( #17 )
    COP [LoopEnd]
    COP [RestoreSavedPtr]
}

code_06B03C {
    COP [LoopStart] ( #02 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #09 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #09 )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh1] ( #1E )
    COP [LoopEnd]
    COP [RestoreSavedPtr]
}

code_06B064 {
    COP [PrintDialogString] ( &dialogstring_06B069 )
    RTL 
}

dialogstring_06B069 `[TPL:A][TPL:1]Kara: [N]I want a steak! [N]And a salad! [FIN]My skin has gone dry [N]from eating [N]weird food...[PAL:0][END]`

dialogstring_06B0BC `[TPL:A][TPL:1]Kara: Oh, no! [N]Will found more [N]mushrooms... [FIN][TPL:2]Lilly: It's better[N]than starving.[N]Well, let's eat.[PAL:0][END]`

dialogstring_06B10B `[TPL:A][TPL:1]Kara: Wait. [N]I hear it again!! [N]What is that sound...? [PAL:0][END]`

dialogstring_06B13C `[TPL:A][TPL:3]Erik: [N]Maybe it's Riverson...? [FIN][TPL:1][DLY:0]Kara: [N]Oh, no! We've [N]got to run!! [FIN][TPL:2]Lilly:[N]Run?[N]Run where?![PAL:0][END]`

dialogstring_06B195 `[TPL:A][TPL:6]Neil: [N]Quiet, everyone! [N]This vibrating sound... [FIN]It's Morse Code...[FIN]It's a signal ships use[N]to talk to each other.[FIN]The length of the[N]sound indicates letters.[FIN]Let's see if I can[N]decode it...Wait...[PAL:0][END]`

dialogstring_06B250 `[TPL:A][TPL:5][DLY:5]This is Seth... [FIN][TPL:4][DLY:0]Lance: [N]Seth?!! [FIN][TPL:2][DLY:0]Lilly:[N]Shh. Quiet![N][PAU:3C][DLY:0]Neil continues. [FIN][TPL:5][DLY:5]I was swallowed by[N]Riverson...[FIN]When I came to, the form[N]of my body had changed[N]to Riverson's.[FIN]This Riverson is a[N]creature who lives in[N]the ocean.[FIN]I don't know[N]if it's human or not.[FIN]He said that evolution[N]is being affected[N]by the light of a comet.[FIN]I wanted to continue[N]the journey with you,[N]but not in this body.[FIN]You must figure [N]out this riddle of the [N]comet and the ruins...[PAL:0][END]`

dialogstring_06B3EC `[TPL:A][TPL:6]Neil: I don't [N]hear anything now... [FIN][TPL:1]Kara: [N]Seth.... [N]I'm scared..... [FIN][TPL:4]Lance: This guy [N]must have studied [N]Morse code. [FIN]Seth, too, did a [N]good thing. [FIN][TPL:3]Erik: [N]But Seth didn't have [N]a human form!! [FIN][TPL:6]Neil: [N]No, Erik. Don't [N]jump to conclusions. [FIN]Only humans think[N]that human shape is[N]the best one.[FIN]Well, [N]cheer up. Let's go![PAL:0][END]`