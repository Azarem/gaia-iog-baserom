; Neil at Luke's house — inspired by raft houses for invention.
; 
; NPC. Says: "The house on this raft gives me an idea for
; a new invention." Character-consistent dialog — Neil always
; thinking about inventions.
---------------------------------------------

!gfxCacheIdxB                   064A

---------------------------------------------

wa79_neil [
  actor-def < #14, #00, #10, {

  code_07A19F:
    COP [BranchOnFlagByte] ( #94, #01, &code_07A1C8 )
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #97, #01, &code_07A1C1 )
    COP [BranchOnFlagByte] ( #96, #01, &code_07A1BA )
    COP [SetInteractHandler] ( &code_07A1CA )
    COP [SetEntryHere]
    RTL 
} >
]

code_07A1BA {
    COP [SetInteractHandler] ( &code_07A1CF )
    COP [SetEntryHere]
    RTL 
}

code_07A1C1 {
    COP [SetInteractHandler] ( &code_07A1D4 )
    COP [SetEntryHere]
    RTL 
}

code_07A1C8 {
    COP [Die]
}

code_07A1CA {
    COP [PrintDialogString] ( &dialogstring_07A217 )
    RTL 
}

code_07A1CF {
    COP [PrintDialogString] ( &dialogstring_07A255 )
    RTL 
}

code_07A1D4 {
    COP [BranchOnFlagByte] ( #01, #01, &code_07A1DF )
    COP [PrintDialogString] ( &dialogstring_07A2BE )
    RTL 
}

code_07A1DF {
    COP [PrintDialogString] ( &dialogstring_07A366 )
    COP [SetFlagByte] ( #94 )
    LDA #$0007
    STA $0D60
    LDA #$0008
    STA $0D62
    LDA #$0009
    STA $0D64
    LDA #$000A
    STA $0D66
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$02D4, #$01A4, #00, #15 )
    COP [QueueMapChange] ( #91, #$0370, #$0430, #06, #$5400 )
    RTL 
}

dialogstring_07A217 `[TPL:A][TPL:6]Neil: The house on this [N]raft gives me an idea [N]for a new invention.[END]`

dialogstring_07A255 `[TPL:A][TPL:6]Neil: If you go [N]west of here, there's [N]a huge desert. [FIN]You can't cross it [N]on foot [N]without Kruks. [FIN]How will I get [N]a Kruk?[PAL:0][END]`

dialogstring_07A2BE `[TPL:A][TPL:6]Neil: [N]You got Kruks? They're [N]so expensive . .? [FIN]Why such a sad face? [N]Maybe I shouldn't ask [N]what the reason is. [FIN]I think we [N]should go west, [N]to Euro... [FIN]Lance and Lilly want [N]to stay here. You [N]should ask them why. [END]`

dialogstring_07A366 `[TPL:B][TPL:6]Neil: The moment when a [N]man and woman are first [N]attracted to each other [N]is like magic. [FIN]I don't think you ever[N]forget that feeling.[FIN]By the way. Euro is [N]where my parents [N]live. It will help you [N]if we go there. [FIN]We're leaving for Euro![END]`