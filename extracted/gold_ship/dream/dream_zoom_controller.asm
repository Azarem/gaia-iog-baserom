!bg1ScrollH                     068A
!bg2ScrollH                     068E

---------------------------------------------

dream_zoom_controller [
  actor-def < #00, #00, #28, {

  code_00C1AD:
    COP [ExitIfFlagByte] ( #0E, #01 )
    LDA #$0088
    SEC 
    SBC $bg1ScrollH
    STA $00F6
    LDA #$0180
    SEC 
    SBC $bg2ScrollH
    STA $00FA
    LDA #$00A0
    STA $00FE
    COP [SetEntryContinue]
    LDA $00FE
    SEC 
    SBC #$0002
    STA $00FE
    CMP #$0040
    BCC loc_00C1DD
    RTL 

  loc_00C1DD:
    COP [Die]
} >
]