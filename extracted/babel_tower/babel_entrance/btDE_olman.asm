?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'music_actors'
?INCLUDE 'table_0EDA00'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

btDE_olman [
  actor-def < #00, #01, #10, {

  code_09880B:
    LDA #$1200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #02 )
    COP [BranchIfFlagByte] ( #FD, #01, &code_098891 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0988D2 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetOnInteract] ( #$0000 )
    COP [SpawnAfterRelFlags] ( @code_0988DA, #$0000, #$FFE0, #$1800 )
    COP [StartMusic] ( #0E )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_0989A2 )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitWord] ( #$012B )
    COP [SetEntryContinue]
    JSL $@music_actors.IsMusicPlaying
    BCC loc_098857
    RTL 

  loc_098857:
    COP [WaitByte] ( #1D )
    LDA #$0005
    STA $0AAC
    LDA #$00DE
    STA $0B12
    LDA #$0017
    STA $0B08
    STA $0B0A
    LDA #$000B
    STA $0B0C
    STA $0B0E
    LDA #$1201
    STA $0B10
    LDA #$0104
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_098891 {
    COP [SpawnAfterRelFlags] ( @code_0988F3, #$0000, #$FFE0, #$1800 )
    LDA #$0001
    JSL $@InitPlayerScriptVariant
    LDY $playerActor
    LDA #$0001
    STA $0028, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_098CAA )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E4, #$00F0, #$0140, #80, #$2200 )
    COP [SetEntryContinue]
    RTL 
}

code_0988D2 {
    COP [PrintDialogString] ( &dialogstring_098903 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_0988DA {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [LoopInit] ( #28 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
}

code_0988F3 {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
}

dialogstring_098903 `[TPL:9][TPL:0][SFX:0]One worn-out body is[N]quietly laid down...[FIN]In his head, a familiar [N]voice speaks. [FIN][TPL:4][SFX:10][DLY:2]Will. It's me, [N]Olman, your father. [FIN]My body has decayed, but[N]I live on like this...[PAL:0][END]`

dialogstring_0989A2 `[TPL:B][TPL:0][DLY:1]Will: Father![N]Why are you in that[N]form!!![FIN][TPL:4][DLY:2]There's a strange room[N]in the Tower of Babel,[N]filled with the light[N]of the comet.[FIN]Time goes so fast there[N]that people evolve[N]very quickly...[FIN][TPL:0][DLY:1]Will: [N]Why are Kara and I [N]able to live?! [FIN][TPL:4][DLY:2]Will's father: [N]Because you two are [N]evolved humans. [FIN][TPL:1][DLY:1]Kara: [N]Us...? [FIN][TPL:4][DLY:2]Will's father: Long ago [N]there existed biological [N]technology using the [N]light of the comet. [FIN]People freely used the[N]power to make[N]plants and animals.[FIN]For example, they made [N]the camel. It can go [N]for long periods [N]without food or water. [FIN]When people realized the[N]power could be used as[N]a weapon,[N]demons were developed.[FIN]The world was on the[N]brink of ruin...[FIN]At that time, the Knights [N]of Darkness and Light [N]were developed to decide [N]the fate of humanity. [FIN]They are your ancestors.[FIN]The six Mystic Statues[N]were made by the[N]Knights.[FIN]The last Mystic Statue [N]is entrusted to you. [END]`

dialogstring_098CAA `[TPL:B][TPL:4][DLY:2]Soon the comet will [N]be very close.[FIN][PAU:1E]By then, the two of you [N]must go to the roof [N]of the tower. [N][PAU:28][DLY:4]Close your eyes....[END]`