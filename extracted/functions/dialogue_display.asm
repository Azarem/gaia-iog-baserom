?INCLUDE 'dialogue_engine'
?INCLUDE 'system_core'

!joypadMaskStd                  065A

---------------------------------------------

ShowDialogueFrame {
    PHP 
    PHB 
    REP #$20
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@system_core.UpdateFrameRender
    REP #$20
    JSL $@dialogue_engine.WideStringRenderer
    PLA 
    STA $joypadMaskStd
    PLB 
    PLP 
    RTL 
}