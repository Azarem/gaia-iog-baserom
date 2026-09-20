; Children NPCs in Watermia — snake bite remedies.
; 
; NPC: "If you're bitten by a snake, you should run around like
; crazy..." Humorous child wisdom about snake encounters.
; Multi-child dialog with different advice.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'

---------------------------------------------

wa78_children [
  actor-def < #12, #00, #10, {

  code_078BC2:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0012
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_078BE4 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_078BE4 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_078BEF )
}

code_list_078BEF [
  &code_078BF9   ;00
  &code_078BFE   ;01
  &code_078C03   ;02
  &code_078C08   ;03
  &code_078C0D   ;04
]

code_078BF9 {
    COP [PrintDialogString] ( &dialogstring_078C12 )
    RTL 
}

code_078BFE {
    COP [PrintDialogString] ( &dialogstring_078C59 )
    RTL 
}

code_078C03 {
    COP [PrintDialogString] ( &dialogstring_078CC5 )
    RTL 
}

code_078C08 {
    COP [PrintDialogString] ( &dialogstring_078D02 )
    RTL 
}

code_078C0D {
    COP [PrintDialogString] ( &dialogstring_078D5A )
    RTL 
}

dialogstring_078C12 `[DEF][SFX:10]Child: If you're bitten [N]by a snake, you should [N]run around like crazy [N]and he'll let go. [END]`

dialogstring_078C59 `[DEF][SFX:10]Child: I was bitten by a[N]snake when I went to the[N]Great Wall of China...[FIN]Once the snakes around[N]here bite you, they[N]don't let go![END]`

dialogstring_078CC5 `[DEF][SFX:10]Sabas: My father's[N]an explorer. Soon he[N]will find the Gold Ship[N]and come home!!![END]`

dialogstring_078D02 `[DEF][SFX:10]Child:[N]I'll tell you something.[FIN]Wait on the[N]right side behind the[N]gambling house.[N]A lotus leaf will come.[END]`

dialogstring_078D5A `[DEF][SFX:10]Child: This is[N]Watermia.[END]`