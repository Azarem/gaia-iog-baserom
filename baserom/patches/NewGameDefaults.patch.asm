?INCLUDE 'sFA_diary_menu'
?INCLUDE 'options_input_remap'

; Starting from the beginning uses Stereo, Classic A, and Cinematic text speed, then enters scene $08.
sFA_diary_menu.DiaryStartPresentSoundButtonConfig! {
    LDA #$0000
    STA $0D90
    STA $0D8E
    JSL $@options_input_remap.SetButtonPreset
    LDA $0B3A
    AND #$FFFC            ; Text speed occupies bits 0-1 of the options word.
    ORA #$0002            ; Cinematic for the new diary.
    STA $0B3A
    LDA #$0190            ; Start a fresh journey with 400 Dark Power.
    STA $0AD6
    JMP $&sFA_diary_menu.DiaryNewGameStart
}
