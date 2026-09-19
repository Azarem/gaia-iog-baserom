; Moon Tribe encounter at their camp.
; 
; Major story scene: the Moon Tribe introduces themselves as
; Shadows created by the comet's light. Exposition about the
; comet, the transformation, and Shadow's origin. Complex
; multi-phase dialog with cutscene elements.
---------------------------------------------

?INCLUDE 'oneshot_palette_flash_1F'

---------------------------------------------

it1A_moon_tribe [
  actor-def < #00, #00, #30, {

  code_09D0F8:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #2A, #01, &code_09D137 )
    PHX 
    LDX #$00E0
    LDA #$0000

  loc_09D10A:
    STA $7F0B00, X
    INX 
    INX 
    CPX #$0100
    BNE loc_09D10A
    PLX 
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_09D11E )
    RTL 
} >
]

code_09D11E {
    COP [PrintDialogString] ( &dialogstring_09D1FC )
    COP [DialogueOptions] ( #03, #01, &code_list_09D128 )
}

code_list_09D128 [
  &code_09D130   ;00
  &code_09D130   ;01
  &code_09D130   ;02
  &code_09D130   ;03
]

code_09D130 {
    COP [PrintDialogString] ( &dialogstring_09D2D0 )
    COP [WaitByte] ( #27 )
}

code_09D137 {
    LDA #$2000
    TRB $10
    COP [SetFlagByte] ( #2A )
    COP [SpawnThinker] ( @oneshot_palette_flash_1F.code_00B800 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09D1D3 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
}

it1A_moon_tribe2 [
  actor-def < #00, #00, #30, {

  code_09D156:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_09D1D8 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

it1A_moon_tribe3 [
  actor-def < #00, #00, #30, {

  code_09D176:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_09D1DD )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

it1A_moon_tribe4 [
  actor-def < #00, #00, #30, {

  code_09D196:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_09D1F2 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

it1A_moon_tribe5 [
  actor-def < #00, #00, #30, {

  code_09D1B6:
    COP [ExitIfFlagByte] ( #2A, #01 )
    LDA #$2000
    TRB $10
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_09D1F7 )
    COP [SetEntryContinue]
    COP [StageSpriteMoveY] ( #27, #3B )
    COP [AnimOnce]
    RTL 
} >
]

code_09D1D3 {
    COP [PrintDialogString] ( &dialogstring_09D30F )
    RTL 
}

code_09D1D8 {
    COP [PrintDialogString] ( &dialogstring_09D388 )
    RTL 
}

code_09D1DD {
    COP [PrintDialogString] ( &dialogstring_09D462 )
    COP [DialogueOptions] ( #02, #01, &code_list_09D1E7 )
}

code_list_09D1E7 [
  &code_09D1ED   ;00
  &code_09D1ED   ;01
  &code_09D1ED   ;02
]

code_09D1ED {
    COP [PrintDialogString] ( &dialogstring_09D4AD )
    RTL 
}

code_09D1F2 {
    COP [PrintDialogString] ( &dialogstring_09D4DC )
    RTL 
}

code_09D1F7 {
    COP [PrintDialogString] ( &dialogstring_09D574 )
    RTL 
}

dialogstring_09D1FC `[DEF]Strange Voice:[N]Good evening....[N]Out for a stroll?[FIN][TPL:0]Will: [N]Who is it? [FIN][PAL:0]Strange Voice:[N]Up, up. This body[N]is lighter than air.[FIN][PAL:4]Will: [N]What are you? [FIN][PAL:0]Strange Voice: Guess who? [N] Cotton candy's relative[N] Bird man[N] Old man's ghost...`

dialogstring_09D2D0 `[CLR]Strange Voice: Wrong![N]Actually, we are the [N]Moon Tribe, also [N]known as "Shadows.ˮ[END]`

dialogstring_09D30F `[DEF]Moon Tribe:[N]Wherever there's light,[N]there are shadows.[FIN]We, who were changed by[N]being bathed in the[N]light only once...[FIN]will spend our future in[N]a world without light.[END]`

dialogstring_09D388 `[DEF]Moon Tribe: The comet is[N]a vehicle of destruction[N]whose evil light has[N]changed all creatures.[FIN]Moon Tribe:[N]It's a remnant of a[N]weapon from a terrible[N]battle long ago.[FIN][TPL:0]Will: The world [N]will be unbearable? [FIN][PAL:0]Moon Tribe: [N]Yes. You're bright, but [N]you're still immature. [END]`

dialogstring_09D462 `[DEF]Moon Tribe: One of my  [N]party has been kidnapped. [FIN]Know your destination?[N] Yes[N] No`

dialogstring_09D4AD `[CLR]Moon Tribe:[N]Maybe someone's chasing[N]you. Ku ku ku .....[END]`

dialogstring_09D4DC `[DEF]Moon Tribe: It comes [N]once every 800 years. [N]This is the fourth time.[FIN]The more light that[N]reaches you,[N]the stronger the Dark [N]Power.[FIN]What will be born[N]of the light this time...[END]`

dialogstring_09D574 `[DEF]Moon Tribe:[N]We've transcended time,[N]and have lived long...[FIN]We saw the destruction [N]of the Incan Empire. [FIN]The Incan Statue sleeps [N]in the cave below... [N]If you like, we'll give [N]it to you. [FIN]At any rate, go look[N]in the cave...[N]Ku ku ku...[END]`