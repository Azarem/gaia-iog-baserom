; Remus — chained slave in the mine inner room (map $47).
; 
; Same structure as Imas: chain sprite prop, "Cut the chain!" before
; rescue, thank-you dialog after. Asks Will to visit his home village
; across the ocean and help the villagers regain their strength.
; Destroyed when flag $5E is set.
---------------------------------------------

?INCLUDE 'dm_mine_static_prop'

---------------------------------------------

dm47_remus [
  actor-def < #28, #00, #10, {

  code_05D15D:
    COP [BranchOnFlagByte] ( #5E, #01, &dm47_remus_destroy )
    COP [SpawnAfterFlags] ( @dm_mine_static_prop, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05D189 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D182
    RTL 

  loc_05D182:
    COP [SetInteractHandler] ( &code_05D18E )
    COP [SetEntryHere]
    RTL 
} >
]

code_05D189 {
    COP [PrintDialogString] ( &dialogstring_05D193 )
    RTL 
}

code_05D18E {
    COP [PrintDialogString] ( &dialogstring_05D1AE )
    RTL 
}

dialogstring_05D193 `[DEF][TPL:5]Remus:[N]Cut the chain![PAL:0][END]`

dialogstring_05D1AE `[DEF][TPL:5]Remus: Thank you. Our [N]home village is far  [N]across the ocean. [FIN]If you could go there,[N]help the villagers to[N]regain their strength.[PAL:0][END]`
---------------------------------------------

dm47_remus_destroy {
    COP [Die]
}