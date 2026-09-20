; Credits camera pan controller (~195 lines).
; 
; Manages the smooth camera scrolling during the end credits
; town walkthrough. Pans across the revisited locations as
; character farewells play. Coordinates movement speed and
; timing with the credits text display.
---------------------------------------------

!cameraDeltaX                   06C0

---------------------------------------------

crF7_credits_camera_pan [
  thinker-def < #04, #08, {

  code_09F512:
    LDA $00E4
    BPL loc_09F518
    RTL 

  loc_09F518:
    JSR $&code_09F68D
    COP [HaltIfMaxFrames] ( #$2FA8 )
    LDA #$0258
    STA $0E
    COP [SetEntryHere]
    LDA $0E
    AND #$000F
    BNE loc_09F54C
    LDA $0762
    BMI loc_09F540
    LDA #$FFFF
    STA $0762
    LDA #$0001
    STA $0764
    BRA loc_09F54C

  loc_09F540:
    LDA #$0001
    STA $0762
    LDA #$FFFF
    STA $0764

  loc_09F54C:
    COP [QueueHdma] ( @dma_channel_09F5C6, #0F )
    DEC $0E
    BMI loc_09F557
    RTL 

  loc_09F557:
    JSR $&code_09F68D
    COP [HaltIfMaxFrames] ( #$3CF0 )
    LDA #$0258
    STA $0E
    COP [SetEntryHere]
    PHX 
    LDX #$0000

  loc_09F569:
    LDA $000760, X
    SEC 
    SBC #$0001
    STA $000760, X
    TXA 
    LSR 
    INC 
    CLC 
    ADC $000760, X
    BMI loc_09F588
    INX 
    INX 
    CPX #$0080
    BCC loc_09F569
    BRA loc_09F59B

  loc_09F588:
    LDA $000760, X
    CLC 
    ADC #$0040
    STA $000760, X
    INX 
    INX 
    CPX #$0080
    BCC loc_09F569

  loc_09F59B:
    PLX 
    LDA $0E
    LSR 
    BCC loc_09F5AB
    LDA $cameraDeltaX
    CLC 
    ADC #$0001
    STA $cameraDeltaX

  loc_09F5AB:
    COP [QueueHdma] ( @dma_channel_09F5BC, #10 )
    DEC $0E
    BMI loc_09F5B6
    RTL 

  loc_09F5B6:
    STZ $cameraDeltaX
    COP [KillThinker]
    RTL 
} >
]

dma_channel_09F5BC [
  dma-channel < #60, #1E, #07 >   ;00
  dma-channel < #C0, #60, #07 >   ;01
  dma-channel < #01, #1E, #07 >   ;02
]

dma_channel_09F5C6 [
  dma-channel < #60, #60, #07 >   ;00
  dma-channel < #01, #62, #07 >   ;01
  dma-channel < #01, #64, #07 >   ;02
  dma-channel < #01, #62, #07 >   ;03
  dma-channel < #01, #64, #07 >   ;04
  dma-channel < #01, #62, #07 >   ;05
  dma-channel < #01, #64, #07 >   ;06
  dma-channel < #01, #62, #07 >   ;07
  dma-channel < #01, #64, #07 >   ;08
  dma-channel < #01, #62, #07 >   ;09
  dma-channel < #01, #64, #07 >   ;0A
  dma-channel < #01, #62, #07 >   ;0B
  dma-channel < #01, #64, #07 >   ;0C
  dma-channel < #01, #62, #07 >   ;0D
  dma-channel < #01, #64, #07 >   ;0E
  dma-channel < #01, #62, #07 >   ;0F
  dma-channel < #01, #64, #07 >   ;10
  dma-channel < #01, #62, #07 >   ;11
  dma-channel < #01, #64, #07 >   ;12
  dma-channel < #01, #62, #07 >   ;13
  dma-channel < #01, #64, #07 >   ;14
  dma-channel < #01, #62, #07 >   ;15
  dma-channel < #01, #64, #07 >   ;16
  dma-channel < #01, #62, #07 >   ;17
  dma-channel < #01, #64, #07 >   ;18
  dma-channel < #01, #62, #07 >   ;19
  dma-channel < #01, #64, #07 >   ;1A
  dma-channel < #01, #62, #07 >   ;1B
  dma-channel < #01, #64, #07 >   ;1C
  dma-channel < #01, #62, #07 >   ;1D
  dma-channel < #01, #64, #07 >   ;1E
  dma-channel < #01, #62, #07 >   ;1F
  dma-channel < #01, #64, #07 >   ;20
  dma-channel < #01, #62, #07 >   ;21
  dma-channel < #01, #64, #07 >   ;22
  dma-channel < #01, #62, #07 >   ;23
  dma-channel < #01, #64, #07 >   ;24
  dma-channel < #01, #62, #07 >   ;25
  dma-channel < #01, #64, #07 >   ;26
  dma-channel < #01, #62, #07 >   ;27
  dma-channel < #01, #64, #07 >   ;28
  dma-channel < #01, #62, #07 >   ;29
  dma-channel < #01, #64, #07 >   ;2A
  dma-channel < #01, #62, #07 >   ;2B
  dma-channel < #01, #64, #07 >   ;2C
  dma-channel < #01, #62, #07 >   ;2D
  dma-channel < #01, #64, #07 >   ;2E
  dma-channel < #01, #62, #07 >   ;2F
  dma-channel < #01, #64, #07 >   ;30
  dma-channel < #01, #62, #07 >   ;31
  dma-channel < #01, #64, #07 >   ;32
  dma-channel < #01, #62, #07 >   ;33
  dma-channel < #01, #64, #07 >   ;34
  dma-channel < #01, #62, #07 >   ;35
  dma-channel < #01, #64, #07 >   ;36
  dma-channel < #01, #62, #07 >   ;37
  dma-channel < #01, #64, #07 >   ;38
  dma-channel < #01, #62, #07 >   ;39
  dma-channel < #01, #64, #07 >   ;3A
  dma-channel < #01, #62, #07 >   ;3B
  dma-channel < #01, #64, #07 >   ;3C
  dma-channel < #01, #62, #07 >   ;3D
  dma-channel < #01, #64, #07 >   ;3E
  dma-channel < #01, #62, #07 >   ;3F
  dma-channel < #01, #64, #07 >   ;40
  dma-channel < #01, #60, #07 >   ;41
]

code_09F68D {
    PHX 
    LDA #$0000
    TAX 

  loc_09F692:
    STA $000760, X
    INX 
    INX 
    CPX #$0080
    BCC loc_09F692
    PLX 
    RTS 
}