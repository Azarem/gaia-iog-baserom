; Ancient spirit guide on the Angkor Wat pinnacle (~130 lines).
; 
; Major story NPC. "Will... I've been waiting for you to come
; for thousands of years..." Will: "What?! Who are you?"
; The spirit shows Will a vision of the new world and
; explains the coming transformation. Key story revelation
; about the comet's true purpose.
---------------------------------------------

?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'
?INCLUDE 'spriteset_npc_props'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!displayModeFlags               09EC
!jewelsCollected                0AB0
!CGADSUB                        2131

---------------------------------------------

awBF_spirit_guide [
  actor-def < #00, #00, #10, {

  code_089AA6:
    COP [BranchIfFlagByte] ( #BE, #01, &code_089B6B )
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_089B6D )
    COP [AddPosition] ( #08, #00 )
    COP [BranchIfFlagByte] ( #BD, #01, &code_089AD4 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_089AD4 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_089C5B )
    SEP #$20
    LDA #$15
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @oneshot_palette_flash_18.FlashPalette18 )
    COP [WaitByte] ( #EF )
    LDA #$2000
    TSB $10
    COP [ClearLowAbs] ( #0F, #0A )
    COP [ClearLowAbs] ( #10, #0A )
    COP [SpawnThinker] ( @oneshot_palette_flash_19.FlashPalette19 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_089E2E )
    COP [GiveItem] ( #1D, &code_089B27 )

  loc_089B10:
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_089EE0 )
    COP [SetFlagByte] ( #BE )

  code_089B1F:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_089B27 {
    COP [BranchIfNoItem] ( #01, &code_089B31 )
    COP [BranchIfNoItem] ( #06, &code_089B54 )
}

code_089B31 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_089EAB )
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    COP [GiveItem] ( #1D, &code_089B1F )
    BRA loc_089B10
}

code_089B54 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_089EFC )
    COP [RemoveItem] ( #06 )
    COP [GiveItem] ( #1D, &code_089B1F )
    BRA loc_089B10
}

code_089B6B {
    COP [Die]
}

code_089B6D {
    COP [PrintDialogString] ( &dialogstring_089B8B )
    COP [SetFlagByte] ( #BD )
    LDA #$0004
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #C0, #$0000, #$0000, #00, #$4400 )
    RTL 
}

dialogstring_089B8B `[DEF][TPL:2]Will.. I've been waiting [N]for you to come for [N]thousands of years... [FIN][TPL:0]Will: [N]What?! Who are you... [FIN][TPL:2]I am dreaming. Time has [N]passed since the dream [N]began, and my body [N]became what you see. [FIN]I'm going to show you[N]a strange image.[N]Close your eyes.[END]`

dialogstring_089C5B `[DEF][TPL:0]Will: [N]Huh? What was that? [FIN][TPL:2]That is the new world...[FIN][TPL:0]Will: [N]That world is all [N]grey... [FIN]This world has blue [N]water, green mountains, [N]brown earth all over. [FIN][TPL:2]You will usher in[N]that world...[FIN][TPL:0]Will: Me? Such a [N]strange world?! [FIN][TPL:2]Tall trees replaced [N]by buildings, rivers [N]replaced by roads... [FIN]No matter what kind of[N]world people have, if[N]they think they're[N]happy, they'll be happy.[FIN]Go to the village and[N]restore those turned[N]to stone to their[N]original condition.[FIN]Release those who have[N]been turned grey back[N]to their natural state.[PAL:0][END]`

dialogstring_089E2E `[TPL:B][TPL:0]When the blinding [N]light stopped, I stood [N]quietly, as if nothing [N]had happened. [FIN]Then I found the Gorgon [N]flower held tightly [N]within my hand...[PAL:0][END]`

dialogstring_089EAB `[TPL:A]A strange voice says...[N]Let me take care of one[N]of your Red Jewels...[END]`

dialogstring_089EE0 `[TPL:A][SFX:0][DLY:9]You have the[N]Gorgon Flower![PAU:78][END]`

dialogstring_089EFC `[TPL:A]A strange voice says...[N]Let me take care of one[N]of your herbs...[END]`