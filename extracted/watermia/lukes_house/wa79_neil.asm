; Neil in Luke's house (scene $79): four states by persistent flags, then the departure for Euro.
; 
; $94 set: Neil dies at spawn (the party has left). Otherwise he stands solid and the handler depends on $97 and $96. Before the glass night ($96 and $97 clear): 'The house on this raft gives me an idea for a new invention.'. $96 set: 'If you go west of here, there's a huge desert. You can't cross it on foot without Kruks. How will I get a Kruk?'. $97 set (the game is won): with scratch $01 clear he says 'You got Kruks? ... I think we should go west, to Euro...'; scratch $01 is set by wa79_lance's post-game handler when $A5 is clear, so the player has to talk to Lance first and Neil afterwards within one visit. With $01 set the handler prints the departure text, sets $94, stores the companion slots $0D60-$0D66, stages the world-map move and queues scene $91.
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