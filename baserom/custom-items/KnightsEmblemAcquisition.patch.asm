; $4A opens the Itory route to the Incan Ruins after Lilly sees both statues.
; $DA records a successful Emblem grant from either Bill or Angkor Wat.
?INCLUDE 'it15_bill'
?INCLUDE 'awBA_glasses'
?INCLUDE 'f_inventory_full'
?INCLUDE 'spriteset_pickups_effects'

!knightsEmblemEquippedItem      0AC6

it15_bill.code_04EFA9! {
    COP [BranchOnFlagByte] ( #4A, #00, &BillSilverSphereHint )
    COP [BranchOnFlagByte] ( #DA, #01, &BillSilverSphereHint )
    COP [GiveItem] ( #2C, &BillEmblemInventoryFull )
    COP [SetFlagByte] ( #DA )
    COP [PrintDialogString] ( &BillEmblemConversation )
    RTL

  BillSilverSphereHint:
    COP [PrintDialogString] ( &dialogstring_04EFDF )
    RTL

  BillEmblemInventoryFull:
    JML $@f_inventory_full.InventoryFullMessage
}

BillEmblemConversation `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]Bill: Off on an adventure?[N]Don't worry.[FIN]I knew this day would come[N]ever since you began[N]muttering in your sleep[N]about the Dark Knights.[FIN]Your grandma Lola first[N]told me about them.[N]The Itory have handed that[N]story down for generations.[FIN]Imagine my surprise when[N]your father knew it too.[FIN]He knew parts Lola had[N]never heard. Getting him[N]to talk was like prying[N]loose a family secret.[FIN]Your father left me this[N]emblem for safekeeping.[WAI][N]A few years ago, you'd[N]have lost it before supper.[FIN]I reckon you're old enough[N]to keep it safe now.[N]Here, Will.[FIN][CLD][DEF]Will receives the[N]Knight's Emblem![END]`

; Reuse the original Black Crystal Glasses actor and coordinates.
awBA_glasses.code_089F7F! {
    COP [BranchOnFlagByte] ( #DA, #01, &code_089FB5 )
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #02 )
    COP [SetInteractHandler] ( &code_089F9D )
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    LDA $knightsEmblemEquippedItem
    CMP #$001C
    BNE knights_emblem_hide
    LDA #$2000
    TRB $10
    COP [AnimOneFrame]
    RTL

  knights_emblem_hide:
    LDA #$2000
    TSB $10
    RTL
}

awBA_glasses.code_089F9D! {
    COP [BranchOnFlagByte] ( #DA, #01, &code_089FB5 )
    LDA $knightsEmblemEquippedItem
    CMP #$001C
    BNE knights_emblem_done
    COP [PrintDialogString] ( &dialogstring_089FBB )
    COP [GiveItem] ( #2C, &code_089FB7 )
    COP [SetFlagByte] ( #DA )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_089FDC )
    JMP $&code_089FB5

  knights_emblem_done:
    RTL
}
