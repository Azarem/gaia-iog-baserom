?INCLUDE 'player_transition_handlers'

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

dc31_rescuer [
  actor-def < #04, #00, #18, {

  code_05AB5F:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05ABC1 )
    COP [BranchIfFlagByte] ( #56, #01, &code_05ABBE )
    COP [BranchIfFlagByte] ( #76, #01, &code_05ABBE )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C45E
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C45E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [WaitByte] ( #95 )
    COP [PrintDialogString] ( &dialogstring_05ABC6 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoop] ( #03, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05AEA3 )
    COP [SetFlagByte] ( #76 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05ABBE {
    COP [SetEntryContinue]
    RTL 
}

code_05ABC1 {
    COP [PrintDialogString] ( &dialogstring_05ABC6+M )
    RTL 
}

dialogstring_05ABC6 `[TPL:A][TPL:6]Man's voice:[N]You can wake him[N]up now.[FIN]He'll be fine if he[N]takes Vitamin C.[FIN]It's scurvy, a disease[N]caused by a long-term[N]lack of vitamin C.[FIN][TPL:1]Kara: [N]Hmmmm... [FIN][TPL:6]Columbus's crew[N]contracted it once.[N]Nothing to worry about.[FIN]When it gets worse, the [N]blood gets bad and the [N]skin turns black. [FIN]The gums bleed, and the[N]body starts decaying...[FIN][TPL:1]Kara: Stop! I don't [N]want to listen to [N]such talk!! [FIN][TPL:6]Man:[N]Ha ha ha.[N]I'm glad you're OK.[FIN][TPL:1]Kara: [N]But you know best. [N]Thank you. [FIN][::][TPL:B][TPL:6]You should thank [N]the dog outside, He [N]found your raft and [N]came to get me.[PAL:0][END]`
---------------------------------------------

dialogstring_05AEA3 `[TPL:E][TPL:6]Man: This is the south [N]outskirts of Oakton. [FIN]The city of [N]Freejia is half a day[N]to the north. [FIN]If you're looking for[N]your friend, you should[N]look in a big town.[PAL:0][END]`