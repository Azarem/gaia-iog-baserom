?INCLUDE 'hint_npc'

!abilityBitmask                 0AA2

---------------------------------------------

dark_rewards1 [
  actor-def < #05, #00, #30, {

  code_09A3E2:
    LDA $0E
    STA $26
    LDA #$2000
    STA $0E
    BRA loc_09A401
} >
]
---------------------------------------------

dark_rewards2 [
  actor-def < #05, #00, #30, {

  code_09A3F0:
    LDA $0E
    STA $26
    LDA #$2000
    STA $0E
    COP [StageSprAndHitbox] ( #85 )
    LDA #$0002
    TSB $12

  loc_09A401:
    COP [AddPosition] ( #F8, #00 )
    COP [SpawnAfterRelFlags] ( @hint_npc.code_09A38D, #$0000, #$FFD0, #$1800 )
    COP [SpawnAfterRelFlags] ( @hint_npc.code_09A3A0, #$0000, #$FFD0, #$1800 )
    COP [AddPosition] ( #F8, #01 )
    COP [SetOnInteract] ( &code_09A42B )
    LDA #$0000
    STA $24
    COP [SetEntryContinue]
    RTL 
} >
]

code_09A42B {
    LDA #$FFFF
    STA $24
    LDA $0B12
    CMP #$0015
    BNE loc_09A43B
    JMP $&code_09A479

  loc_09A43B:
    CMP #$0042
    BNE loc_09A443
    JMP $&code_09A506

  loc_09A443:
    CMP #$0062
    BNE loc_09A44B
    JMP $&code_09A584

  loc_09A44B:
    CMP #$0086
    BNE loc_09A453
    JMP $&code_09A628

  loc_09A453:
    CMP #$00B8
    BNE loc_09A45B
    JMP $&code_09A6DE

  loc_09A45B:
    CMP #$00CC
    BNE loc_09A463
    JMP $&code_09A81B

  loc_09A463:
    CMP #$00A7
    BNE loc_09A46B
    JMP $&code_09A77F

  loc_09A46B:
    CMP #$00A1
    BNE code_09A473
    JMP $&code_09A8C1

  code_09A473:
    LDA #$0000
    STA $24
    RTL 
}

code_09A479 {
    LDA $abilityBitmask
    BIT #$0001
    BNE loc_09A491
    LDA $abilityBitmask
    ORA #$0001
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A498 )
    JMP $&code_09A473

  loc_09A491:
    COP [PrintWideString] ( &widestring_09A498+M )
    JMP $&code_09A473
}

widestring_09A498 `[DEF]You receive the [N]Psycho Crusher!! [FIN][::][DEF]You can smash obstacles[N]by ramming them.[N]Use the Attack Button[N]to save energy...[END]`

code_09A506 {
    LDA $abilityBitmask
    BIT #$0010
    BNE loc_09A51E
    LDA $abilityBitmask
    ORA #$0010
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A525 )
    JMP $&code_09A473

  loc_09A51E:
    COP [PrintWideString] ( &widestring_09A525+M )
    JMP $&code_09A473
}

widestring_09A525 `[DEF]You receive the [N]Psycho Flier! [FIN][::][DEF]You can scorch enemies [N]with its flame. [N]Use the Attack Button [N]to save energy... [END]`

code_09A584 {
    LDA $abilityBitmask
    BIT #$0002
    BNE loc_09A59C
    LDA $abilityBitmask
    ORA #$0002
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A5A3 )
    JMP $&code_09A473

  loc_09A59C:
    COP [PrintWideString] ( &widestring_09A5A3+M )
    JMP $&code_09A473
}

widestring_09A5A3 `[DEF]You receive the [N]Psycho Slider! [FIN][::][DEF]Now you can use the[N]Sliding Attack, and[N]pass through small[N]passageways.[FIN]When you're running,[N]push the Attack Button.[END]`

code_09A628 {
    LDA $abilityBitmask
    BIT #$0004
    BNE loc_09A640
    LDA $abilityBitmask
    ORA #$0004
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A647 )
    JMP $&code_09A473

  loc_09A640:
    COP [PrintWideString] ( &widestring_09A647+M )
    JMP $&code_09A473
}

widestring_09A647 `[DEF]You receive the [N]Spin Dasher! [FIN][::][DEF]Send enemies flying by[N]spinning your body[N]rapidly.[FIN]Climb hills by using the[N]recoil. For more power,[N]use the Attack and[N]LR Buttons...[END]`

code_09A6DE {
    LDA $abilityBitmask
    BIT #$0040
    BNE loc_09A6F6
    LDA $abilityBitmask
    ORA #$0040
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A6FD )
    JMP $&code_09A473

  loc_09A6F6:
    COP [PrintWideString] ( &widestring_09A6FD+M )
    JMP $&code_09A473
}

widestring_09A6FD `[DEF]You receive the [N]Earthquaker! [FIN][::][DEF]The Earthquaker[N]causes earthquakes.[FIN]Stops enemies for a long[N]time. Push the Attack[N]button while jumping...[END]`

code_09A77F {
    LDA $abilityBitmask
    BIT #$0020
    BNE loc_09A797
    LDA $abilityBitmask
    ORA #$0020
    STA $abilityBitmask
    COP [PrintWideString] ( &widestring_09A79E )
    JMP $&code_09A473

  loc_09A797:
    COP [PrintWideString] ( &widestring_09A79E+M )
    JMP $&code_09A473
}

widestring_09A79E `[DEF]You receive the [N]Aura Barrier! [FIN][::][DEF]It puts a protective[N]barrier around you.[FIN]Use the Attack Button[N]power and push the LR[N]Buttons alternately.[END]`

code_09A81B {
    COP [BranchIfNoItem] ( #24, &code_09A82C )
    COP [GiveItem] ( #24, &code_09A833 )
    COP [PrintWideString] ( &widestring_09A83A )
    JMP $&code_09A473
}

code_09A82C {
    COP [PrintWideString] ( &widestring_09A83A+M )
    JMP $&code_09A473
}

code_09A833 {
    COP [PrintWideString] ( &widestring_09A88F )
    JMP $&code_09A473
}

widestring_09A83A `[DEF]You need the Aura...[FIN][::][DEF]Shadow's body has no [N]mass. When he holds up[N]this Ball, his body [N]becomes like water. [END]`

widestring_09A88F `[PAU:1E][DEF]Your inventory is full.[N]Store items somewhere[N]and come back.[END]`

code_09A8C1 {
    COP [PrintWideString] ( &widestring_09A8C6 )
    RTL 
}

widestring_09A8C6 `[DEF]The Spider spins a web [N]from stalk to stalk. If [N]you don't have a web, [N]you can fly... [END]`