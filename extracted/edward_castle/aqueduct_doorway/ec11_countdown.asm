?BANK 09

?INCLUDE 'chunk_03BAE1'
?INCLUDE 'ec11_button_voice'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

ec11_countdown [
  actor-def < #00, #00, #23, {

  code_09BDB8:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_09BE6D )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_09BDCB )
    RTL 
} >
]

code_09BDCB {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_09BE70 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    LDA #$CFF0
    TRB $joypadMaskStd

  code_09BDE4:
    COP [SetEntryContinue]
    LDA #$2200
    STA $0E
    COP [LoopInit] ( #78 )
    COP [BranchIfFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopInit] ( #3C )
    COP [BranchIfFlagByte] ( #03, #01, &code_09BE67 )
    JSR $&code_09BEFC
    LDA #$0001
    STA $0000
    JSL $@chunk_03BAE1.func_03BAF1
    COP [LoopNext]
    COP [LoopInit] ( #78 )
    COP [BranchIfFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopInit] ( #3C )
    COP [BranchIfFlagByte] ( #03, #01, &code_09BE67 )
    JSR $&code_09BEFC
    LDA #$0002
    STA $0000
    JSL $@chunk_03BAE1.func_03BAF1
    COP [LoopNext]
    COP [LoopInit] ( #63 )
    COP [BranchIfFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopNext]
    COP [SetFlagByte] ( #01 )
    COP [PlaySoundCh1] ( #11 )
    COP [LoopInit] ( #28 )
    COP [BranchIfFlagByte] ( #02, #00, &code_09BE6D )
    JSR $&code_09BEFC
    LDA #$0003
    STA $0000
    JSL $@chunk_03BAE1.func_03BAF1
    COP [LoopNext]
    COP [ClearFlagByte] ( #01 )
    COP [PrintWideString] ( &ec11_button_voice.widestring_09BD58 )
}

code_09BE67 {
    COP [ClearFlagByte] ( #03 )
    JMP $&code_09BDE4
}

code_09BE6D {
    COP [SetEntryContinue]
    RTL 
}

widestring_09BE70 `[TPL:B][TPL:2][::]Strange Voice: The door [N]won't open unless you [N]push this switch on [N]the count of three. [FIN]When I shout, push [N]the switch. [FIN]I'll count 1, 2, 3.[N]Don't make a mistake.[END]`

code_09BEFC {
    LDA $playerXPos
    CLC 
    ADC #$0007
    STA $14
    LDA $playerYPos
    SEC 
    SBC #$0020
    STA $16
    RTS 
}