; Chained laborers in the mine main area — 4 instances via index lookup.
; 
; Uses displayModeFlags ($0E) as an index into byte_0AA72F to select
; which flag byte (#A0-#A3) tracks this laborer. If already freed,
; despawns. Otherwise shows as a chain sprite (enemy frame #33) with
; solid collision and interaction.
; 
; Before freed: "I beg you! Cut this chain!!" After Freedan breaks
; the chain (status bit $0040), interaction varies by laborer index:
; Index 0: tells about 8 laborers forced to work, asks you to save them.
; Index 1: reveals the secret room with wind blowing through wall cracks.
; Index 2: gives the Mine Key (#0C) with music+text fanfare.
; Index 3: gives the Elevator Key (#0F) and asks you to save the inner
; prisoners. Each freed laborer walks offscreen and sets their flag.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'EnemyInitBasic'

!displayModeFlags               09EC

---------------------------------------------

dm3F_laborer [
  actor-def < #0C, #00, #10, {

  code_0AA6B9:
    LDA #$1000
    TSB $12
    LDA $0E
    STA $24
    PHX 
    TAX 
    LDA $@byte_0AA72F, X
    PLX 
    AND #$00FF
    JSL $@cop_handlers_flags.TestFlagRaw
    BCC loc_0AA6D5
    JMP $&code_0AA72D

  loc_0AA6D5:
    LDA #$2000
    STA $0E
    LDA #$0200
    TSB $12
    COP [SpawnAfterFlags] ( @code_0AA9E0, #$0100 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0AA733 )
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_0AA6F9
    RTL 

  loc_0AA6F9:
    COP [SetOnInteract] ( &code_0AA738 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0AA700 {
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TSB $10
    COP [ClearLowHere]
    LDA #$0080
    TSB $displayModeFlags
    COP [StageSpriteLoopMoveY] ( #0D, #08, #01 )
    COP [AnimLoop]
    LDA #$0080
    TRB $displayModeFlags
    PHX 
    LDX $24
    LDA $@byte_0AA72F, X
    PLX 
    AND #$00FF
    JSL $@cop_handlers_flags.SetFlagRaw
}

code_0AA72D {
    COP [Die]
}

byte_0AA72F [
  #A0   ;00
  #A1   ;01
  #A2   ;02
  #A3   ;03
]

code_0AA733 {
    COP [PrintDialogString] ( &dialogstring_0AA791 )
    RTL 
}

code_0AA738 {
    LDA #$&code_0AA700
    STA $00
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AA748 )
}

code_list_0AA748 [
  &code_0AA78C   ;00
  &code_0AA787   ;01
  &code_0AA751   ;02
  &code_0AA771   ;03
]

code_0AA750 {
    RTL 
}

code_0AA751 {
    COP [PrintDialogString] ( &dialogstring_0AA7B4 )
    COP [GiveItem] ( #0C, &code_0AA767 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_0AA7EF )
    RTL 
}

code_0AA767 {
    LDA #$&loc_0AA6F9
    STA $00
    COP [PrintDialogString] ( &dialogstring_0AA9C5 )
    RTL 
}

code_0AA771 {
    COP [PrintDialogString] ( &dialogstring_0AA811 )
    COP [GiveItem] ( #0F, &code_0AA767 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_0AA85C )
    RTL 
}

code_0AA787 {
    COP [PrintDialogString] ( &dialogstring_0AA874 )
    RTL 
}

code_0AA78C {
    COP [PrintDialogString] ( &dialogstring_0AA97D )
    RTL 
}

dialogstring_0AA791 `[DEF]Laborer:[N]I beg you![N]Cut this chain!![END]`

dialogstring_0AA7B4 `[DEF]Laborer:[N]Thank you! I won't[N]forget what you've done![FIN]Take this key.[FIN]`

dialogstring_0AA7EF `[CLR][SFX:0][DLY:9]You have the[N]key to the mine![PAU:FF][END]`

dialogstring_0AA811 `[DEF]There are people who are[N]forced to work deep in[N]the Diamond Mine.[FIN]Please use this key[N]to save them.[FIN]`

dialogstring_0AA85C `[CLR][SFX:0][DLY:9]You've got the[N]elevator key![PAU:FF][END]`

dialogstring_0AA874 `[DEF]Thank you for saving me.[N]As a reward, I'll tell[N]you something.[FIN]This mine has a secret[N]room. Its entrance[N]blends into the wall.[FIN]But you can find it by[N]watching for wind[N]blowing through cracks[N]in the wall.[FIN]Of course, it would blow [N]fine hair like yours [N]around. Then you'll [N]understand. [END]`

dialogstring_0AA97D `[DEF]There are eight[N]laborers including me[N]forced to work in the[N]mine. [FIN]Please save us. [END]`

dialogstring_0AA9C5 `[DEF][CLR]But your inventory[N]is full![END]`

code_0AA9E0 {
    JSL $@EnemyInitBasic
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}