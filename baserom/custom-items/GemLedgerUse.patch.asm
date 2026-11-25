; The Ledger shows each region's total supply, irrespective of collection flags.
; Totals account for chests, hidden pickups, and scripted rewards. The two
; Sky Garden chest recovery spots at Nazca use those same chest flags.
?BANK 03
?INCLUDE 'item_use_system'

!ledgerScene                    0644
!ledgerDarkSpaceSource          0B12
; UI scratch already used by the options menu, which is closed on field item use.
!ledgerRegionalJewelTotal       0BE4

item_use_system.ItemHandlerJumpTable#52: &UseItem_GemLedger

UseItem_GemLedger {
    PHX
    LDA $ledgerScene
    AND #$00FF
    CMP #$00E6
    BNE ledger_find_region
    LDA $ledgerDarkSpaceSource
    AND #$00FF

  ledger_find_region:
    LDX #$0000
  ledger_region_loop:
    CMP $@LedgerRegionTotals, X
    BCC ledger_show_total
    INX
    INX
    INX
    INX
    BRA ledger_region_loop

  ledger_show_total:
    LDA $@LedgerRegionTotals+2, X
    STA $ledgerRegionalJewelTotal
    PLX
    COP [PrintDialogString] ( &GemLedgerReport )
    RTS
}

; Exclusive scene ceiling, followed by a packed-BCD Jewel total.
LedgerRegionTotals [
    #$0001, #$0000   ; Special/overworld scene $00
    #$000A, #$0003   ; South Cape and Seaside Cave
    #$0015, #$0004   ; Edward Castle and dungeon
    #$001C, #$0001   ; Itory and Moon Tribe
    #$0030, #$0002   ; Incan Ruins and Gold Ship
    #$003D, #$0004   ; Freejia
    #$0049, #$0003   ; Diamond Mine
    #$005A, #$0002   ; Nazca and Sky Garden
    #$0068, #$0004   ; Seaside Palace and Mu
    #$0078, #$0004   ; Fallen Wing village and approach
    #$0082, #$0003   ; Watermia
    #$0089, #$0001   ; Great Wall
    #$008A, #$0000   ; Ending scene $89
    #$008C, #$0001   ; Great Wall and return route
    #$0091, #$0000   ; Prologue and ending scenes
    #$00A0, #$0003   ; Euro
    #$00AC, #$0001   ; Mount Kehres
    #$00B0, #$0002   ; Native Village
    #$00C3, #$0004   ; Angkor Wat
    #$00CC, #$0003   ; Dao
    #$00DC, #$0005   ; Pyramid
    #$00DD, #$0001   ; Babel approach by plane
    #$00DE, #$0005   ; Pyramid boss chamber
    #$00E5, #$0001   ; Tower of Babel
    #$00E7, #$0000   ; Ending and unresolved Dark Space source
    #$00E9, #$0001   ; Tower of Babel
    #$00F2, #$0000   ; Mansion and system scenes
    #$00F7, #$0001   ; Tower of Babel finale
    #$0100, #$0000   ; Ending and system scenes
]

GemLedgerReport `[CLD][BOR:1][DLG:3,F][SIZ:D,5][SFX:0]You have given Gem[N][BCD:2,AB0] Red Jewels.[N]There are a total of[N][BCD:1,BE4] Red Jewels that can be[N]found in this region.[END]`
