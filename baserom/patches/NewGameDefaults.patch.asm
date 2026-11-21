?INCLUDE 'sFA_diary_menu'
?INCLUDE 'options_input_remap'

; Starting from the beginning uses Stereo, Classic A, and Normal text speed, then enters scene $08.
sFA_diary_menu.DiaryStartPresentSoundButtonConfig! {
    LDA #$0000
    STA $0D90
    STA $0D8E
    JSL $@options_input_remap.SetButtonPreset
    LDA $0B3A
    AND #$FFFC            ; Text speed occupies bits 0-1 of the options word.
    STA $0B3A
    JMP $&sFA_diary_menu.DiaryNewGameStart
}
