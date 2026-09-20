; Male NPCs in Watermia — extensive town exposition.
; 
; Multi-NPC group (~175 lines). "This is Watermia. The houses
; are built on rafts. We like to move around." Various male
; townspeople providing information about Watermia's culture,
; raft-house lifestyle, and the Russian Glass tradition.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'

!gfxCacheIdxB                   064A

---------------------------------------------

wa78_men [
  actor-def < #02, #00, #10, {

  code_078504:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0002
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_078537 )
    COP [SolidHighHere]
    LDA $24
    CMP #$0005
    BEQ loc_07852D

  code_07852A:
    COP [SetEntryContinue]
    RTL 

  loc_07852D:
    COP [BranchIfFlagByte] ( #9D, #00, &code_07852A )
    COP [ClearLowHere]
    COP [Die]
} >
]

code_078537 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078542 )
}

code_list_078542 [
  &code_07855A   ;00
  &code_07855F   ;01
  &code_078564   ;02
  &code_078569   ;03
  &code_0785A1   ;04
  &code_0785A6   ;05
  &code_0785AB   ;06
  &code_0785B0   ;07
  &code_0785B5   ;08
  &code_0785BA   ;09
  &code_0785BF   ;0A
  &code_0785BF   ;0B
]

code_07855A {
    COP [PrintDialogString] ( &dialogstring_0785C9 )
    RTL 
}

code_07855F {
    COP [PrintDialogString] ( &dialogstring_078607 )
    RTL 
}

code_078564 {
    COP [PrintDialogString] ( &dialogstring_078674 )
    RTL 
}

code_078569 {
    COP [PrintDialogString] ( &dialogstring_0786C1 )
    COP [DialogueOptions] ( #02, #02, &code_list_078573 )
}

code_list_078573 [
  &code_078579   ;00
  &code_078579   ;01
  &code_07857E   ;02
]

code_078579 {
    COP [PrintDialogString] ( &dialogstring_078724 )
    RTL 
}

code_07857E {
    COP [PrintDialogString] ( &dialogstring_078741 )
    LDA #$000D
    STA $0D60
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$02D4, #$01A4, #00, #22 )
    COP [QueueMapChange] ( #01, #$00F0, #$02E0, #03, #$4300 )
    RTL 
}

code_0785A1 {
    COP [PrintDialogString] ( &dialogstring_07876E )
    RTL 
}

code_0785A6 {
    COP [PrintDialogString] ( &dialogstring_07879B )
    RTL 
}

code_0785AB {
    COP [PrintDialogString] ( &dialogstring_0787DA )
    RTL 
}

code_0785B0 {
    COP [PrintDialogString] ( &dialogstring_07881B )
    RTL 
}

code_0785B5 {
    COP [PrintDialogString] ( &dialogstring_078881 )
    RTL 
}

code_0785BA {
    COP [PrintDialogString] ( &dialogstring_0788DE )
    RTL 
}

code_0785BF {
    COP [PrintDialogString] ( &dialogstring_0788E0 )
    RTL 
}

code_0785C4 {
    COP [PrintDialogString] ( &dialogstring_078960 )
    RTL 
}

dialogstring_0785C9 `[DEF][SFX:10]Man: This is[N]Watermia. The houses are[N]built on rafts. We like[N]to move around.[END]`

dialogstring_078607 `[DEF][SFX:10]Man:[N]This animal is called[N]a Kruk.[FIN]It's good for crossing[N]the desert. It can live[N]without food or water[N]for a long time.[END]`

dialogstring_078674 `[DEF][SFX:10]Man: This is a gambling[N]house. A child would[N]have to be very poor to[N]come to this place.[END]`

dialogstring_0786C1 `[DEF]I'm the Sky Deliveryman. [N]My tame birds will take [N]you to distant towns. [FIN]Do you want to[N]go to South Cape?[N] Quit[N] Go`

dialogstring_078724 `[CLR]OK. In that case,[N]use them later.[END]`

dialogstring_078741 `[CLR]Come here, birds.[N]We're taking this person[N]to South Cape![END]`

dialogstring_07876E `[DEF]This leaf is full.[N]Find another if you[N]want to ride.[END]`

dialogstring_07879B `[DEF][SFX:10]Luke:[N]Take care of my house.[N]Make yourself at home[N]while I'm gone.[END]`

dialogstring_0787DA `[DEF]If you need a lot of[N]money, go to the raft[N]at the outside of[N]this building.[END]`

dialogstring_07881B `[DEF][SFX:10]Betting small money[N]won't make you[N]big money.[FIN]Of course, if you want[N]to risk your life, you[N]can make a fortune.[END]`

dialogstring_078881 `[DEF]Life is like a gamble.[N]Make one mistake,[N]and you're[N]on the road to ruin.[FIN]People do that[N]unconsciously.[END]`

dialogstring_0788DE `[DEF][END]`

dialogstring_0788E0 `[DEF]There's an old man in[N]the town who's a little[N]bit crazy.[FIN]He was with the explorer, [N]Olman, on his[N]expedition to the[N]Tower of Babel. [END]`

dialogstring_078960 `[DEF][END]`