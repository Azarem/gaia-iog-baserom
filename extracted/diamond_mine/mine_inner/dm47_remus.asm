?INCLUDE 'dm_actor_05D49E'

---------------------------------------------

dm47_remus [
  actor-def < #28, #00, #10, {

  code_05D15D:
    COP [BranchIfFlagByte] ( #5E, #01, &dm47_remus_destroy )
    COP [SpawnAfterFlags] ( @dm_actor_05D49E, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05D189 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D182
    RTL 

  loc_05D182:
    COP [SetOnInteract] ( &code_05D18E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D189 {
    COP [PrintWideString] ( &widestring_05D193 )
    RTL 
}

code_05D18E {
    COP [PrintWideString] ( &widestring_05D1AE )
    RTL 
}

widestring_05D193 `[DEF][TPL:5]Remus:[N]Cut the chain![PAL:0][END]`

widestring_05D1AE `[DEF][TPL:5]Remus: Thank you. Our [N]home village is far  [N]across the ocean. [FIN]If you could go there,[N]help the villagers to[N]regain their strength.[PAL:0][END]`
---------------------------------------------

dm47_remus_destroy {
    COP [Die]
}