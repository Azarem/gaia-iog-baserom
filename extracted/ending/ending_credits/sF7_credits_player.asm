; Credits player character controller (~407 lines).
; 
; Manages Will's movement and animation during the credits
; walkthrough sequence. Handles auto-walk paths, form
; changes, idle poses at key locations, and the final
; walk into the sunset. Complex movement scripting.
---------------------------------------------

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
    COP [SetEntryHere]
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
    COP [SetPlayerSpriteDirect] ( #04 )

  loc_09E0E0:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA loc_09E0E0

  code_09E0E7:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA code_09E0E7

  code_09E0EE:
    COP [SetPlayerSpriteDirect] ( #04 )

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
    COP [SetPlayerSpriteDirect] ( #04 )

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
    COP [SetPlayerSpriteDirect] ( #04 )

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
    COP [HaltIfMaxFrames] ( #$012C )
    COP [SetLinkedEntryPtr] ( &code_09E013 )
    COP [HaltIfMaxFrames] ( #$01CC )
    COP [SetLinkedEntryPtr] ( &code_09E02E )
    COP [HaltIfMaxFrames] ( #$0CA8 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$0E10 )
    COP [SetLinkedEntryPtr] ( &code_09E058 )
    COP [HaltIfMaxFrames] ( #$0EB8 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$0F78 )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$1168 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$1774 )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$1968 )
    COP [SetLinkedEntryPtr] ( &code_09E02E )
    COP [HaltIfMaxFrames] ( #$1968 )
    COP [SetLinkedEntryPtr] ( &code_09E02E )
    COP [HaltIfMaxFrames] ( #$2138 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$2390 )
    COP [SetLinkedEntryPtr] ( &code_09E0DD )
    COP [HaltIfMaxFrames] ( #$23B0 )
    COP [SetLinkedEntryPtr] ( &code_09E0E7 )
    COP [HaltIfMaxFrames] ( #$23CC )
    COP [SetLinkedEntryPtr] ( &code_09E0C1 )
    COP [HaltIfMaxFrames] ( #$23EE )
    COP [SetLinkedEntryPtr] ( &code_09E0CF )
    COP [HaltIfMaxFrames] ( #$244E )
    COP [SetLinkedEntryPtr] ( &code_09E0BA )
    COP [HaltIfMaxFrames] ( #$245F )
    COP [SetLinkedEntryPtr] ( &code_09E0D6 )
    COP [HaltIfMaxFrames] ( #$2488 )
    COP [SetLinkedEntryPtr] ( &code_09E0C8 )
    COP [HaltIfMaxFrames] ( #$24C8 )
    COP [SetLinkedEntryPtr] ( &code_09E051 )
    COP [HaltIfMaxFrames] ( #$2540 )
    COP [SetLinkedEntryPtr] ( &code_09E06D )
    COP [HaltIfMaxFrames] ( #$2608 )
    COP [SetLinkedEntryPtr] ( &code_09E0EE )
    COP [HaltIfMaxFrames] ( #$2618 )
    COP [SetLinkedEntryPtr] ( &code_09E0F8 )
    COP [HaltIfMaxFrames] ( #$2658 )
    COP [SetLinkedEntryPtr] ( &code_09E0FF )
    COP [HaltIfMaxFrames] ( #$2668 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$26C8 )
    COP [SetLinkedEntryPtr] ( &code_09E0B3 )
    COP [HaltIfMaxFrames] ( #$2740 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$2770 )
    COP [SetLinkedEntryPtr] ( &code_09E106 )
    COP [HaltIfMaxFrames] ( #$2790 )
    COP [SetLinkedEntryPtr] ( &code_09E12F )
    COP [HaltIfMaxFrames] ( #$27AE )
    COP [SetLinkedEntryPtr] ( &code_09E136 )
    COP [HaltIfMaxFrames] ( #$27C7 )
    COP [SetLinkedEntryPtr] ( &code_09E13D )
    COP [HaltIfMaxFrames] ( #$27DB )
    COP [SetLinkedEntryPtr] ( &code_09E144 )
    COP [HaltIfMaxFrames] ( #$27EA )
    COP [SetLinkedEntryPtr] ( &code_09E12F )
    COP [HaltIfMaxFrames] ( #$27F6 )
    COP [SetLinkedEntryPtr] ( &code_09E136 )
    COP [HaltIfMaxFrames] ( #$2802 )
    COP [SetLinkedEntryPtr] ( &code_09E13D )
    COP [HaltIfMaxFrames] ( #$280B )
    COP [SetLinkedEntryPtr] ( &code_09E144 )
    COP [HaltIfMaxFrames] ( #$2814 )
    COP [SetLinkedEntryPtr] ( &code_09E110 )
    COP [HaltIfMaxFrames] ( #$282C )
    COP [SetLinkedEntryPtr] ( &code_09E117 )
    COP [HaltIfMaxFrames] ( #$287C )
    COP [SetLinkedEntryPtr] ( &code_09E11E )
    COP [HaltIfMaxFrames] ( #$28EC )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$291C )
    COP [SetLinkedEntryPtr] ( &code_09E09E )
    COP [HaltIfMaxFrames] ( #$293C )
    COP [SetLinkedEntryPtr] ( &code_09E0AC )
    COP [HaltIfMaxFrames] ( #$29CC )
    COP [SetLinkedEntryPtr] ( &code_09E0A5 )
    COP [HaltIfMaxFrames] ( #$29EC )
    COP [SetLinkedEntryPtr] ( &code_09E07B )
    COP [HaltIfMaxFrames] ( #$2A4C )
    COP [SetLinkedEntryPtr] ( &code_09E074 )
    COP [HaltIfMaxFrames] ( #$2AB0 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$2AF8 )
    COP [SetLinkedEntryPtr] ( &code_09E051 )
    COP [HaltIfMaxFrames] ( #$2B10 )
    COP [SetLinkedEntryPtr] ( &code_09E125 )
    COP [HaltIfMaxFrames] ( #$2B88 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$2C00 )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$2CFA )
    COP [SetLinkedEntryPtr] ( &code_09E082 )
    COP [HaltIfMaxFrames] ( #$2DBA )
    COP [SetLinkedEntryPtr] ( &code_09E089 )
    COP [HaltIfMaxFrames] ( #$2DDA )
    COP [SetLinkedEntryPtr] ( &code_09E090 )
    COP [HaltIfMaxFrames] ( #$2E52 )
    COP [SetLinkedEntryPtr] ( &code_09E097 )
    COP [HaltIfMaxFrames] ( #$2E72 )
    COP [SetLinkedEntryPtr] ( &code_09E035 )
    COP [HaltIfMaxFrames] ( #$2F6C )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$3066 )
    COP [SetLinkedEntryPtr] ( &code_09E03C )
    COP [HaltIfMaxFrames] ( #$3138 )
    COP [SetLinkedEntryPtr] ( &code_09E07B )
    COP [HaltIfMaxFrames] ( #$3634 )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$3840 )
    COP [SetLinkedEntryPtr] ( &code_09E035 )
    COP [HaltIfMaxFrames] ( #$3A34 )
    COP [SetLinkedEntryPtr] ( &code_09E04A )
    COP [HaltIfMaxFrames] ( #$3CB4 )
    COP [SetLinkedEntryPtr] ( &code_09E058 )
    COP [HaltIfMaxFrames] ( #$3D68 )
    COP [SetLinkedEntryPtr] ( &code_09E04A )
    COP [HaltIfMaxFrames] ( #$4164 )
    COP [SetLinkedEntryPtr] ( &code_09E066 )
    COP [HaltIfMaxFrames] ( #$417C )
    COP [SetLinkedEntryPtr] ( &code_09E04A )
    COP [HaltIfMaxFrames] ( #$42CC )
    COP [SetLinkedEntryPtr] ( &code_09E125 )
    COP [HaltIfMaxFrames] ( #$43F8 )
    COP [SetLinkedEntryPtr] ( &code_09E04A )
    COP [HaltIfMaxFrames] ( #$46C8 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$4830 )
    COP [SetLinkedEntryPtr] ( &code_09E04A )
    COP [HaltIfMaxFrames] ( #$4A4C )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$4D1C )
    COP [SetLinkedEntryPtr] ( &code_09E02E )
    COP [HaltIfMaxFrames] ( #$6C0C )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    COP [HaltIfMaxFrames] ( #$6D1A )
    COP [SetLinkedEntryPtr] ( &code_09E043 )
    COP [HaltIfMaxFrames] ( #$6D38 )
    COP [SetLinkedEntryPtr] ( &code_09E035 )
    COP [SetEntryHere]
    RTL 
}