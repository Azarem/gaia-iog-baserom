; Will's monologue about the wind at Larai Cliff — plays once.
; 
; On first visit (flag $6C not set): locks joypad, waits, then shows
; Will's narration about the tremendous wind at Larai Cliff and the
; old man's warning. Sets flag $6C to prevent repeat. Despawns on
; subsequent visits.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

ir1D_monologue [
  actor-def < #00, #00, #30, {

  code_09D02E:
    COP [BranchIfFlagByte] ( #6C, #01, &code_09D04A )
    COP [SetFlagByte] ( #6C )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_09D04C )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_09D04A {
    COP [Die]
}

dialogstring_09D04C `[TPL:E][TPL:0]Will: There was a [N]tremendous wind at the [N]Larai Cliff. [FIN]That's probably what the [N]old man meant by the [N]breath of the spirits.... [FIN]This is the cliff with[N]no wind. My heart[N]beats fast.[PAL:0][END]`
---------------------------------------------

dialogstring_05F8F7 `Will: There was a [N]tremendous wind at the [N]Larai Cliff. [FIN]That's probably what the [N]old man meant by the [N]breath of the spirits.... [FIN]This is the cliff with[N]no wind. My heart[N]beats fast.[PAL:0][END]`