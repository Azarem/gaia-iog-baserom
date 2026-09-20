; Kara in Oakton — introduces Turbo and suggests exploring.
; 
; NPC at the Oakton exterior. Says: "This dog's name is Turbo.
; Isn't he cute? Well, let's go. Maybe we can find out where
; we are." Transitions from the adrift rescue to Freejia.
---------------------------------------------

!gfxCacheIdxB                   064A

---------------------------------------------

dc30_kara [
  actor-def < #15, #00, #10, {

  code_05AAA1:
    COP [BranchIfFlagByte] ( #56, #00, &code_05AAB0 )
    COP [SetOnInteract] ( &code_05AAB2 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05AAB0 {
    COP [Die]
}

code_05AAB2 {
    COP [PrintDialogString] ( &dialogstring_05AADD )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0254, #$0354, #00, #09 )
    COP [QueueMapChange] ( #32, #$0130, #$0350, #00, #$4500 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_05AADD `[DEF][TPL:1]Kara: This dog's [N]name is Turbo. [N]Isn't he cute? [FIN]Well, let's go. Maybe [N]we'll see Lilly, Lance, [N]and Erik. [FIN][TPL:6]So they went to [N]Freejia....[PAL:0][END]`