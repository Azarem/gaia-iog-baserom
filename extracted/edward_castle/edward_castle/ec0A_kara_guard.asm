; Guard outside Kara's room at Edward Castle.
; 
; Two-state dialog: initially blocks entry, then Kara threatens to
; reveal his nickname and he lets Will in. Comedy scene.
---------------------------------------------

!joypadCurrent                  0656
!joypadMaskStd                  065A
!playerSpeedEw                  09B2

---------------------------------------------

ec0A_kara_guard [
  actor-def < #1D, #00, #10, {

  code_04C94A:
    COP [SetSpritePriority] ( #30 )
    COP [BranchOnFlagByte] ( #21, #01, &code_04C9CC )
    COP [BranchOnFlagByte] ( #19, #01, &code_04C991 )
    COP [BranchOnFlagByte] ( #1A, #01, &code_04C991 )
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #FF )
    COP [MarkSolidOffset] ( #00, #01 )
    COP [SetInteractHandler] ( &code_04C9D7 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [SetInteractHandler] ( #$0000 )
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04CA41 )
    COP [ClearSolidHere]
    COP [ClearSolidOffset] ( #00, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04C991 {
    COP [SetInteractHandler] ( &code_04C9E5 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04CB20 )
    COP [ClearFlagByte] ( #03 )
    COP [WaitOnFlagByte] ( #19, #01 )

  loc_04C9BC:
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_04C9CC {
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04CA08 )
    BRA loc_04C9BC
}

code_04C9D7 {
    COP [PrintDialogString] ( &dialogstring_04CA0D )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

code_04C9E5 {
    COP [BranchOnFlagByte] ( #19, #01, &code_04C9F0 )
    COP [PrintDialogString] ( &dialogstring_04CAE1 )
    RTL 
}

code_04C9F0 {
    COP [PrintDialogString] ( &dialogstring_04CAF5 )
    COP [ClearSolidHere]
    LDA #$0008
    STA $playerSpeedEw
    LDA $joypadCurrent
    ORA #$0100
    STA $joypadCurrent
    COP [MarkSolidHere]
    RTL 
}

code_04CA08 {
    COP [PrintDialogString] ( &dialogstring_04CB3F )
    RTL 
}

dialogstring_04CA0D `[TPL:A]Soldier: This is the[N]Princess's room.[N]Strangers can't enter.[END]`

dialogstring_04CA41 `[TPL:A]Soldier:[N]This is just a shabby boy.[FIN][TPL:0]Will: [N]It's me, Kara.[FIN][TPL:1]Kara: [N]Oh...That voice...[FIN]Let him in, or I'll[N]tell everyone your[N]old nickname.[FIN][PAL:0][SFX:10]Soldier:[N]Oh, pardon me![N]Please enter![END]`

dialogstring_04CAE1 `[TPL:8]I'm at a loss... [END]`

dialogstring_04CAF5 `[TPL:9]Your business is[N]finished. Get out![FIN]Now![PAU:A][CLD]`

dialogstring_04CB20 `[TPL:9]Soldier:[N]Princess, let's go.[END]`

dialogstring_04CB3F `[TPL:9]Soldier:[N]Zzzzz...Zzzzz..[END]`