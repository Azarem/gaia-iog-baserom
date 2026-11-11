; The strange voice of the aqueduct doorway (scene $11): an invisible actor at tile (1C,07).
; 
; Parks when word flag $0113 is set. Otherwise it waits for scratch $02 (set when Lola's Melody is played in this scene) and, when Will is within #03 tiles, locks the joypad, prints the instructions ('The door won't open unless you push this switch on the count of three'), starts music #1B, unlocks and counts: #$78 silent passes, sound #10 with digit 1 for #$3C, #$78 silent, sound #10 with digit 2 for #$3C, #$63 silent, then sets scratch $01 (the on-time window), sound #11 and digit 3 for #$28 passes, clears $01 and prints 'Wait! I told you ...'. A hit before the window sets scratch $03 (from ec11_button_voice), which restarts the count; the hit in the window opens the door and clears $02, which parks this actor.
---------------------------------------------

?BANK 09

?INCLUDE 'ec11_button_voice'
?INCLUDE 'oam_digit_compose'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

ec11_countdown [
  actor-def < #00, #00, #23, {

  code_09BDB8:
    COP [BranchOnFlagWord] ( #$0113, #01, &code_09BE6D )
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #03, &code_09BDCB )
    RTL 
} >
]

code_09BDCB {
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_09BE70 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    LDA #$CFFC
    TRB $joypadMaskStd

  code_09BDE4:
    COP [SetEntryHere]
    LDA #$2200
    STA $0E
    COP [LoopStart] ( #78 )
    COP [BranchOnFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopEnd]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopStart] ( #3C )
    COP [BranchOnFlagByte] ( #03, #01, &code_09BE67 )
    JSR $&code_09BEFC
    LDA #$0001
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopEnd]
    COP [LoopStart] ( #78 )
    COP [BranchOnFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopEnd]
    COP [PlaySoundCh1] ( #10 )
    COP [LoopStart] ( #3C )
    COP [BranchOnFlagByte] ( #03, #01, &code_09BE67 )
    JSR $&code_09BEFC
    LDA #$0002
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopEnd]
    COP [LoopStart] ( #63 )
    COP [BranchOnFlagByte] ( #03, #01, &code_09BE67 )
    COP [LoopEnd]
    COP [SetFlagByte] ( #01 )
    COP [PlaySoundCh1] ( #11 )
    COP [LoopStart] ( #28 )
    COP [BranchOnFlagByte] ( #02, #00, &code_09BE6D )
    JSR $&code_09BEFC
    LDA #$0003
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    COP [LoopEnd]
    COP [ClearFlagByte] ( #01 )
    COP [PrintDialogString] ( &ec11_button_voice.dialogstring_09BD58 )
}

code_09BE67 {
    COP [ClearFlagByte] ( #03 )
    JMP $&code_09BDE4
}

code_09BE6D {
    COP [SetEntryHere]
    RTL 
}

dialogstring_09BE70 `[TPL:B][TPL:2][::]Strange Voice: The door [N]won't open unless you [N]push this switch on [N]the count of three. [FIN]When I shout, push [N]the switch. [FIN]I'll count 1, 2, 3.[N]Don't make a mistake.[END]`

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