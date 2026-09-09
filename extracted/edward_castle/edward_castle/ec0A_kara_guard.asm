!joypadCurrent                  0656
!joypadMaskStd                  065A
!playerSpeedEw                  09B2

---------------------------------------------

ec0A_kara_guard [
  actor-def < #1D, #00, #10, {

  code_04C94A:
    COP [SetSpritePriority] ( #30 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04C9CC )
    COP [BranchIfFlagByte] ( #19, #01, &code_04C991 )
    COP [BranchIfFlagByte] ( #1A, #01, &code_04C991 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #FF )
    COP [SolidHighOffset] ( #00, #01 )
    COP [SetOnInteract] ( &code_04C9D7 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04CA41 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04C991 {
    COP [SetOnInteract] ( &code_04C9E5 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04CB20 )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #19, #01 )

  loc_04C9BC:
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_04C9CC {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04CA08 )
    BRA loc_04C9BC
}

code_04C9D7 {
    COP [PrintWideString] ( &widestring_04CA0D )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

code_04C9E5 {
    COP [BranchIfFlagByte] ( #19, #01, &code_04C9F0 )
    COP [PrintWideString] ( &widestring_04CAE1 )
    RTL 
}

code_04C9F0 {
    COP [PrintWideString] ( &widestring_04CAF5 )
    COP [ClearLowHere]
    LDA #$0008
    STA $playerSpeedEw
    LDA $joypadCurrent
    ORA #$0100
    STA $joypadCurrent
    COP [SolidHighHere]
    RTL 
}

code_04CA08 {
    COP [PrintWideString] ( &widestring_04CB3F )
    RTL 
}

widestring_04CA0D `[TPL:A]Soldier: This is the[N]Princess's room.[N]Strangers can't enter.[END]`

widestring_04CA41 `[TPL:A]Soldier:[N]This is just a shabby boy.[FIN][TPL:0]Will: [N]It's me, Kara.[FIN][TPL:1]Kara: [N]Oh...That voice...[FIN]Let him in, or I'll[N]tell everyone your[N]old nickname.[FIN][PAL:0][SFX:10]Soldier:[N]Oh, pardon me![N]Please enter![END]`

widestring_04CAE1 `[TPL:8]I'm at a loss... [END]`

widestring_04CAF5 `[TPL:9]Your business is[N]finished. Get out![FIN]Now![PAU:A][CLD]`

widestring_04CB20 `[TPL:9]Soldier:[N]Princess, let's go.[END]`

widestring_04CB3F `[TPL:9]Soldier:[N]Zzzzz...Zzzzz..[END]`