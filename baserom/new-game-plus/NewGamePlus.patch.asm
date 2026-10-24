?BANK 0B

?INCLUDE 'system_strings'
?INCLUDE 'chunk_03BAE1'

--------------------------------------------------

diary_ngp_option {
    JSR $&DiaryMenuClearVram
    COP [6B] ( &dialogstring_0BF437 )
    COP [C8] ( &DiaryRenderSlotStats )
    COP [BD] ( @consolestring_01EADC )
    LDA $0D8C
    AND #$0003
    STA $0D92

  diary_ngp_stub:
    COP [C2]
    LDA #$000C
    STA $7F101C, X
    COP [C8] ( &DiaryCameraPan )
    COP [E2] ( @diary_ngp_stub )
    COP [40] ( #$0800, &DiaryStartSlotUp )
    COP [40] ( #$0400, &DiaryStartSlotDown )
    COP [40] ( #$0080, &diary_ngp_confirm )
    COP [40] ( #$8000, &DiaryStartCancel )
    RTL 
}

diary_ngp_confirm {
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D92
    ASL
    TAY
    LDA $0DC6, Y
    BNE diary_ngp_continue
    COP [06] ( #12 )
    RTL

  diary_ngp_continue:
    COP [06] ( #11 )


    LDA $0D92
    STA $0D8C
    LDA #$FFFF
    STA $0D92
    LDA $0D8C
    STA $306000
    JSL $@LoadGameState_Scene
    ;BCS code_0BE433
    JSR $&ApplySoundAndRemap
    LDA $0AB2
    STA $0AAC

    LDA #$0000
    LDY #$005E
  flag_clear_top:
    STA $0A00, Y
    DEY
    DEY
    BPL flag_clear_top

    LDY #$0020
  dungeon_clear_top:
    STA $0A80, Y
    DEY
    DEY
    BPL dungeon_clear_top

    LDY #$000E
  inventory_clear_top:
    STA $0AB4, Y
    DEY
    DEY
    BPL inventory_clear_top

    STA $0AD4
    STA $0AC6
    DEC
    STA $0AC4

    LDY #$000A
  wall_clear_top:
    STA $0B28, Y
    DEY
    DEY
    BPL wall_clear_top

    SEP #$20
    LDA #$80
    TRB $0B54
    INC $0B54
    REP #$20

    COP [26] ( #08, #$0050, #$00A0, #00, #$1200 )
    LDA #$2800
    TRB $playerFlags
    COP [E0]
}

diary_ngp_str     `[DLG:6,A][SIZ:A,5]Start Journey[N]Erase Trip Diary[N]Copy Trip Diary[N]Change Options[N]New Game +`

--------------------------------------------------
?INCLUDE 'sFA_diary_menu'
--------------------------------------------------

DiaryMenuInit! {
    LDA #$0000
    STA $7F0A00
    SEP #$20
    STA $TM
    REP #$20
    LDA #$FFFF
    STA $0D92
    STA $0D96
    STA $0D98
    LDA #$4001
    TSB $09EC
    SEP #$20
    LDA #$88
    STA $W34SEL
    LDA #$22
    STA $WOBJSEL
    REP #$20
    LDA #$0000
    STA $7F0A00
    STA $0B04
    LDA #$0001
    STA $00EE
    SEP #$20
    LDA #$01
    STA $TM
    LDA #$04
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$41
    STA $CGADSUB
    REP #$20
    LDA #$0080
    STA $068A
    STA $06BE
    LDA #$0300
    STA $068E
    STA $06C2
    LDA #$3000
    TSB $joypadMaskStd
    LDA #$2800
    TSB $playerFlags
    JSR $&DiaryScanSramSlots
    COP [BD] ( @consolestring_01EADC )
    LDA $20
    BEQ diary_menu_normal
    COP [6B] ( &diary_ngp_str )
    BRA diary_menu_continue

  diary_menu_normal:
    COP [6B] ( &dialogstring_0BF3F4 )

  diary_menu_continue:
    LDA #$0F00
    STA $joypadMaskInv
    STZ $18
    COP [C1]
    LDA $0654
    BNE loc_0BE2CA
    RTL 
}

-----------------------------------------------

DiaryTabCursorUp! {
    COP [06] ( #10 )
    LDA $20
    BEQ diary_main_dec_normal
    LDA $0D98
    DEC 
    BPL loc_0BE302
    LDA #$0004
    BRA loc_0BE302
}

diary_main_dec_normal {
    LDA $0D98
    DEC 
    BPL loc_0BE302
    LDA #$0003
}

------------------------------------------------

DiaryMainMenuEntry! {
    LDA $20
    BEQ diary_print_normal
    COP [6B] ( &diary_ngp_str )
    BRA loc_0BE2D0

  diary_print_normal:
    COP [6B] ( &dialogstring_0BF3F4 )
}

------------------------------------------------

DiaryTabCursorDown! {
    COP [06] ( #10 )
    LDA $20
    BEQ diary_main_inc_normal
    LDA $0D98
    INC 
    CMP #$0005
    BCC loc_0BE31E
    LDA #$0000
    BRA loc_0BE31E
}

diary_main_inc_normal {
    LDA $0D98
    INC 
    CMP #$0004
    BCC loc_0BE31E
    LDA #$0000
}

-----------------------------------------------

DiaryTabConfirm! {
    COP [06] ( #11 )
    LDA $0656
    ORA $0658
    STA $0658
    LDA $0D98
    ;AND #$0003
    STA $0000
    LDA #$FFFF
    STA $0D98
    COP [D9] ( #$0000, &code_list_0BE34C )
}

code_list_0BE34C! [
  &DiaryStartJourney   ;00
  &DiaryEraseTab   ;01
  &DiaryCopyTab   ;02
  &DiarySndBtnTab   ;03
  &diary_ngp_option   ;04
]

-----------------------------------------------
;Code for loading diary data into temp variables

DiaryScanSramSlots! {
    PHX 
    LDA #$0000
    STA $0D74
    STA $0D76
    STA $0D78
    STA $0D7A
    STA $0D7C
    STA $0D7E
    STA $0D80
    STA $0D82
    STA $0D84
    STA $0D86
    STA $0D88
    STA $0D8A
    STA $0DC0
    STA $0DC2
    STA $0DC4
    STA $0DC6
    STA $0DC8
    STA $0DCA
    LDA #$0002
    STA $24
    STZ $26
    STZ $20
    LDA $306000
    CMP #$0003
    BCC loc_0BEDA3
    LDA #$0000
    STA $306000

  loc_0BEDA3!:
    STA $0D8C

  DiaryScanSramLoop!:
    LDA $24
    XBA 
    ASL 
    TAX 
    JSL $@ComputeSaveChecksum
    LDA $0018
    CMP $3063FC, X
    BNE diary_noload
    LDA $001C
    CMP $3063FE, X
    BNE diary_noload
    BRA diary_preload

  diary_noload:
    CLC
    JMP loc_0BEE12

  diary_preload:
    PHX 
    LDA $24
    ASL 
    TAY 
    TXA 
    CLC 
    ADC #$0B12
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D74, Y
    LDA $01, S
    CLC 
    ADC #$0ACA
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D7A, Y
    LDA $01, S
    CLC 
    ADC #$0ADC
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D80, Y
    LDA $01, S
    CLC 
    ADC #$0ADE
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D86, Y
    LDA $01, S
    CLC 
    ADC #$0B54
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    AND #$007F
    BEQ $01
    INC
    STA $0DC0, Y
    LDA $306200, X
    BIT #$0080
    BEQ $06
    LDA #$0001
    STA $0DC6, Y
    STA $20
    PLA 
    SEC 
}

loc_0BEE11! {
}


------------------------------------------------
?INCLUDE 'thinker_00BBAF'
------------------------------------------------
;Enable 5th menu option highlight

loc_00BC45! {
    DEC 
    BNE code_extra
    COP [02] ( @dma_channel_00BC8D, #26 )
    RTL 
}

code_extra {
    COP [02] ( @dma_data_extra, #26 )
    RTL 
}

dma_data_extra [
  dma-channel < #10, #FF, #00 >   ;00
  dma-channel < #7F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]