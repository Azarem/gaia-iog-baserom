?INCLUDE 'oneshot_palette_flash_1B'
?INCLUDE 'oneshot_palette_flash_1C'
?INCLUDE 'table_0EDA00'

!joypadMaskStd                  065A

---------------------------------------------

mu63_spirits [
  actor-def < #0E, #00, #30, {

  code_0699CA:
    COP [BranchIfPlayerInAbsTiles] ( #10, #00, #20, #10, &code_069AC1 )
    COP [BranchIfFlagByte] ( #7B, #01, &code_069AAE )
    COP [ExitIfFlagByte] ( #7B, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0080, #$0058, #$1000 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_palette_flash_1B.code_00B7E2 )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0020, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$00E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0040, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$00C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0070, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0090, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0050, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0070, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0090, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$00B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_069BAA )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
    COP [WaitByte] ( #7F )
    STZ $0688
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_069AAE {
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0080, #$0058, #$1000 )
    COP [Die]
}

code_069ABB {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    RTL 
}

code_069AC1 {
    COP [BranchIfFlagByte] ( #7E, #01, &code_069B9D )
    COP [ExitIfFlagByte] ( #7E, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0180, #$0058, #$1000 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_palette_flash_1B.code_00B7E2 )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0120, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$01E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0140, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$01C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0170, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0190, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0150, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0170, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0190, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$01B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintWideString] ( &widestring_069BAA )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
    COP [WaitByte] ( #7F )
    STZ $0688
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_069B9D {
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0180, #$0058, #$1000 )
    COP [Die]
}

widestring_069BAA `[TPL:A]The Sun god...[N]Rama...[FIN]The ocean holds[N]a power...[END]`

code_069BDA {
    COP [SetSpritePriority] ( #30 )
    COP [StageSprAndHitbox] ( #0E )
    COP [PlaySoundBoth] ( #$2626 )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]

  code_069BF5:
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #02, #00, &code_069BF5 )
    COP [LoopInit] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_069C14 {
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [PlaySoundBoth] ( #$2525 )

  code_069C1D:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #02, #00, &code_069C1D )
    COP [Die]
}