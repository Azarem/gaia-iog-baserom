?BANK 02

?INCLUDE 'scene_script'

-- Patch for tilemap loading which adds support for no compression

!sptr		                    3E
!DCMP_SIZE	                    78
!META_SIZE                      0666
!DST_OFF                        0668
!map_bounds_x                   0692
!map_bounds_y                   0696
!A1T0L                          4302
!A1B0                           4304

---------------------------------------------

loc_02883D! {
    REP #$20
    
    LDA [$sptr]
    INC $sptr
    INC $sptr
    CMP #$0001
    BMI HandleEmptyGeometry
    STA $DCMP_SIZE
    STA $META_SIZE

    SEP #$20
    LDA $066A
    BIT #$01
    BEQ loc_02888E
    LDX #$0000
    JSR $&StoreMapAndDecompress
    LDA $066A
    BIT #$02
    BEQ loc_028894
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram
    LDA $01
    STA $0695
    XBA 
    LDA $03
    STA $0699
    JSL $@SignedMultiply
    STA $069D
    BRA loc_028894
}

---------------------------------------------

WriteMapBounds! {
    REP #$20
    LDA $00
    STA $map_bounds_x, X    -- copy stored width
    LDA $02
    STA $map_bounds_y, X    -- copy stored height
    LDA $META_SIZE
    STA $069A, X            -- copy stored multiply result (used by 0 index)
    STZ $DST_OFF             -- zero dest offset

    JSR $&DmaRomToWram
    SEP #$20
    RTS
}

---------------------------------------------

DmaLowVramTileset! {
    REP #$20
    LDA [$sptr]
    INC $sptr
    INC $sptr
    CMP #$0000
    BMI do_copy
    BNE do_copy
    STA $DCMP_SIZE
    BRA loc_028943
    
  do_copy:
    SEP #$20
    LDX $sptr
    STX $A1T0L
    LDA $40
    STA $A1B0
    BRA loc_028959
}
