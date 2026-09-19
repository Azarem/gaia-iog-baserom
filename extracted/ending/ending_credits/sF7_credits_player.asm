?INCLUDE 'CreditPositionLookup'

!characterForm                  0AD4

---------------------------------------------

sF7_actor_09DFF8 [
  actor-def < #00, #00, #A5, {

  code_09DFFB:
    COP [SetSpritePriority] ( #30 )
    LDA #$0200
    STA $14
    COP [SpawnBefore] ( @e_actor_09DDA7 )
    STZ $characterForm
    COP [StagePlayerSprite] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E013 {
    LDA #$2000
    TRB $10
    LDA #$0033
    JSL $@CreditPositionLookup
    LDA $16
    CLC 
    ADC #$0002
    STA $16

  loc_09E026:
    COP [StagePlayerMoveX] ( #0E, #02 )
    COP [AnimOnce]
    BRA loc_09E026

  code_09E02E:
    COP [StagePlayerSprite] ( #0E )
    COP [AnimOnce]
    BRA code_09E02E

  code_09E035:
    COP [StagePlayerSprite] ( #00 )
    COP [AnimOnce]
    BRA code_09E035

  code_09E03C:
    COP [StagePlayerSprite] ( #01 )
    COP [AnimOnce]
    BRA code_09E03C

  code_09E043:
    COP [StagePlayerSprite] ( #02 )
    COP [AnimOnce]
    BRA code_09E043

  code_09E04A:
    COP [StagePlayerSprite] ( #03 )
    COP [AnimOnce]
    BRA code_09E04A

  code_09E051:
    COP [StagePlayerSprite] ( #08 )
    COP [AnimOnce]
    BRA code_09E051

  code_09E058:
    COP [StagePlayerSprite] ( #09 )
    COP [AnimOnce]
    BRA code_09E058

  code_09E05F:
    COP [StagePlayerSprite] ( #0A )
    COP [AnimOnce]
    BRA code_09E05F

  code_09E066:
    COP [StagePlayerSprite] ( #0B )
    COP [AnimOnce]
    BRA code_09E066

  code_09E06D:
    COP [StagePlayerSprite] ( #0C )
    COP [AnimOnce]
    BRA code_09E06D

  code_09E074:
    COP [StagePlayerSprite] ( #0D )
    COP [AnimOnce]
    BRA code_09E074

  code_09E07B:
    COP [StagePlayerSprite] ( #11 )
    COP [AnimOnce]
    BRA code_09E07B

  code_09E082:
    COP [StagePlayerSprite] ( #12 )
    COP [AnimOnce]
    BRA code_09E082

  code_09E089:
    COP [StagePlayerSprite] ( #18 )
    COP [AnimOnce]
    BRA code_09E089

  code_09E090:
    COP [StagePlayerSprite] ( #19 )
    COP [AnimOnce]
    BRA code_09E090

  code_09E097:
    COP [StagePlayerSprite] ( #1C )
    COP [AnimOnce]
    BRA code_09E097

  code_09E09E:
    COP [StagePlayerSprite] ( #26 )
    COP [AnimOnce]
    BRA code_09E09E

  code_09E0A5:
    COP [StagePlayerSprite] ( #27 )
    COP [AnimOnce]
    BRA code_09E0A5

  code_09E0AC:
    COP [StagePlayerSprite] ( #2C )
    COP [AnimOnce]
    BRA code_09E0AC

  code_09E0B3:
    COP [StagePlayerSprite] ( #32 )
    COP [AnimOnce]
    BRA code_09E0B3

  code_09E0BA:
    COP [StagePlayerSprite] ( #36 )
    COP [AnimOnce]
    BRA code_09E0BA

  code_09E0C1:
    COP [StagePlayerSprite] ( #38 )
    COP [AnimOnce]
    BRA code_09E0C1

  code_09E0C8:
    COP [StagePlayerSprite] ( #3A )
    COP [AnimOnce]
    BRA code_09E0C8

  code_09E0CF:
    COP [StagePlayerSprite] ( #3C )
    COP [AnimOnce]
    BRA code_09E0CF

  code_09E0D6:
    COP [StagePlayerSprite] ( #44 )
    COP [AnimOnce]
    BRA code_09E0D6

  code_09E0DD:
    COP [SetPlayerBodySprite] ( #04 )

  loc_09E0E0:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA loc_09E0E0

  code_09E0E7:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA code_09E0E7

  code_09E0EE:
    COP [SetPlayerBodySprite] ( #04 )

  loc_09E0F1:
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_09E0F1

  code_09E0F8:
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    BRA code_09E0F8

  code_09E0FF:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    BRA code_09E0FF

  code_09E106:
    COP [SetPlayerBodySprite] ( #04 )

  loc_09E109:
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    BRA loc_09E109

  code_09E110:
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    BRA code_09E110

  code_09E117:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    BRA code_09E117

  code_09E11E:
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    BRA code_09E11E

  code_09E125:
    COP [SetPlayerBodySprite] ( #04 )

  loc_09E128:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    BRA loc_09E128

  code_09E12F:
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA code_09E12F

  code_09E136:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    BRA code_09E136

  code_09E13D:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA code_09E13D

  code_09E144:
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    BRA code_09E144
}
---------------------------------------------

e_actor_09DDA7 {
    LDA $00E4
    BPL loc_09DDAD
    RTL 

  loc_09DDAD:
    COP [HaltIfCounterGte] ( #$012C )
    COP [SetLinkedActorScript] ( &code_09E013 )
    COP [HaltIfCounterGte] ( #$01CC )
    COP [SetLinkedActorScript] ( &code_09E02E )
    COP [HaltIfCounterGte] ( #$0CA8 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$0E10 )
    COP [SetLinkedActorScript] ( &code_09E058 )
    COP [HaltIfCounterGte] ( #$0EB8 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$0F78 )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$1168 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$1774 )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$1968 )
    COP [SetLinkedActorScript] ( &code_09E02E )
    COP [HaltIfCounterGte] ( #$1968 )
    COP [SetLinkedActorScript] ( &code_09E02E )
    COP [HaltIfCounterGte] ( #$2138 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$2390 )
    COP [SetLinkedActorScript] ( &code_09E0DD )
    COP [HaltIfCounterGte] ( #$23B0 )
    COP [SetLinkedActorScript] ( &code_09E0E7 )
    COP [HaltIfCounterGte] ( #$23CC )
    COP [SetLinkedActorScript] ( &code_09E0C1 )
    COP [HaltIfCounterGte] ( #$23EE )
    COP [SetLinkedActorScript] ( &code_09E0CF )
    COP [HaltIfCounterGte] ( #$244E )
    COP [SetLinkedActorScript] ( &code_09E0BA )
    COP [HaltIfCounterGte] ( #$245F )
    COP [SetLinkedActorScript] ( &code_09E0D6 )
    COP [HaltIfCounterGte] ( #$2488 )
    COP [SetLinkedActorScript] ( &code_09E0C8 )
    COP [HaltIfCounterGte] ( #$24C8 )
    COP [SetLinkedActorScript] ( &code_09E051 )
    COP [HaltIfCounterGte] ( #$2540 )
    COP [SetLinkedActorScript] ( &code_09E06D )
    COP [HaltIfCounterGte] ( #$2608 )
    COP [SetLinkedActorScript] ( &code_09E0EE )
    COP [HaltIfCounterGte] ( #$2618 )
    COP [SetLinkedActorScript] ( &code_09E0F8 )
    COP [HaltIfCounterGte] ( #$2658 )
    COP [SetLinkedActorScript] ( &code_09E0FF )
    COP [HaltIfCounterGte] ( #$2668 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$26C8 )
    COP [SetLinkedActorScript] ( &code_09E0B3 )
    COP [HaltIfCounterGte] ( #$2740 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$2770 )
    COP [SetLinkedActorScript] ( &code_09E106 )
    COP [HaltIfCounterGte] ( #$2790 )
    COP [SetLinkedActorScript] ( &code_09E12F )
    COP [HaltIfCounterGte] ( #$27AE )
    COP [SetLinkedActorScript] ( &code_09E136 )
    COP [HaltIfCounterGte] ( #$27C7 )
    COP [SetLinkedActorScript] ( &code_09E13D )
    COP [HaltIfCounterGte] ( #$27DB )
    COP [SetLinkedActorScript] ( &code_09E144 )
    COP [HaltIfCounterGte] ( #$27EA )
    COP [SetLinkedActorScript] ( &code_09E12F )
    COP [HaltIfCounterGte] ( #$27F6 )
    COP [SetLinkedActorScript] ( &code_09E136 )
    COP [HaltIfCounterGte] ( #$2802 )
    COP [SetLinkedActorScript] ( &code_09E13D )
    COP [HaltIfCounterGte] ( #$280B )
    COP [SetLinkedActorScript] ( &code_09E144 )
    COP [HaltIfCounterGte] ( #$2814 )
    COP [SetLinkedActorScript] ( &code_09E110 )
    COP [HaltIfCounterGte] ( #$282C )
    COP [SetLinkedActorScript] ( &code_09E117 )
    COP [HaltIfCounterGte] ( #$287C )
    COP [SetLinkedActorScript] ( &code_09E11E )
    COP [HaltIfCounterGte] ( #$28EC )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$291C )
    COP [SetLinkedActorScript] ( &code_09E09E )
    COP [HaltIfCounterGte] ( #$293C )
    COP [SetLinkedActorScript] ( &code_09E0AC )
    COP [HaltIfCounterGte] ( #$29CC )
    COP [SetLinkedActorScript] ( &code_09E0A5 )
    COP [HaltIfCounterGte] ( #$29EC )
    COP [SetLinkedActorScript] ( &code_09E07B )
    COP [HaltIfCounterGte] ( #$2A4C )
    COP [SetLinkedActorScript] ( &code_09E074 )
    COP [HaltIfCounterGte] ( #$2AB0 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$2AF8 )
    COP [SetLinkedActorScript] ( &code_09E051 )
    COP [HaltIfCounterGte] ( #$2B10 )
    COP [SetLinkedActorScript] ( &code_09E125 )
    COP [HaltIfCounterGte] ( #$2B88 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$2C00 )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$2CFA )
    COP [SetLinkedActorScript] ( &code_09E082 )
    COP [HaltIfCounterGte] ( #$2DBA )
    COP [SetLinkedActorScript] ( &code_09E089 )
    COP [HaltIfCounterGte] ( #$2DDA )
    COP [SetLinkedActorScript] ( &code_09E090 )
    COP [HaltIfCounterGte] ( #$2E52 )
    COP [SetLinkedActorScript] ( &code_09E097 )
    COP [HaltIfCounterGte] ( #$2E72 )
    COP [SetLinkedActorScript] ( &code_09E035 )
    COP [HaltIfCounterGte] ( #$2F6C )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$3066 )
    COP [SetLinkedActorScript] ( &code_09E03C )
    COP [HaltIfCounterGte] ( #$3138 )
    COP [SetLinkedActorScript] ( &code_09E07B )
    COP [HaltIfCounterGte] ( #$3634 )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$3840 )
    COP [SetLinkedActorScript] ( &code_09E035 )
    COP [HaltIfCounterGte] ( #$3A34 )
    COP [SetLinkedActorScript] ( &code_09E04A )
    COP [HaltIfCounterGte] ( #$3CB4 )
    COP [SetLinkedActorScript] ( &code_09E058 )
    COP [HaltIfCounterGte] ( #$3D68 )
    COP [SetLinkedActorScript] ( &code_09E04A )
    COP [HaltIfCounterGte] ( #$4164 )
    COP [SetLinkedActorScript] ( &code_09E066 )
    COP [HaltIfCounterGte] ( #$417C )
    COP [SetLinkedActorScript] ( &code_09E04A )
    COP [HaltIfCounterGte] ( #$42CC )
    COP [SetLinkedActorScript] ( &code_09E125 )
    COP [HaltIfCounterGte] ( #$43F8 )
    COP [SetLinkedActorScript] ( &code_09E04A )
    COP [HaltIfCounterGte] ( #$46C8 )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$4830 )
    COP [SetLinkedActorScript] ( &code_09E04A )
    COP [HaltIfCounterGte] ( #$4A4C )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$4D1C )
    COP [SetLinkedActorScript] ( &code_09E02E )
    COP [HaltIfCounterGte] ( #$6C0C )
    COP [SetLinkedActorScript] ( &code_09E05F )
    COP [HaltIfCounterGte] ( #$6D1A )
    COP [SetLinkedActorScript] ( &code_09E043 )
    COP [HaltIfCounterGte] ( #$6D38 )
    COP [SetLinkedActorScript] ( &code_09E035 )
    COP [SetEntryContinue]
    RTL 
}