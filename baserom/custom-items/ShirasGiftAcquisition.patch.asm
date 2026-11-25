; Saved choice flags: $C9 = Will explicitly calls Kara a friend, $CA = he says
; they hardly know each other. Cancel keeps the usual reply and records neither.
; $CB records a successful grant. A full inventory skips that scene's attempt.
?INCLUDE 'sc06_kara_return'
?INCLUDE 'gs2A_shira'
?INCLUDE 'nvAC_hamlet'

sc06_kara_return.code_list_04A6F7! [
    &code_04A703
    &ShirasGiftKaraFriend
    &ShirasGiftKaraGuarded
]

ShirasGiftKaraFriend {
    COP [SetFlagByte] ( #C9 )
    JMP $&code_04A6FD
}

ShirasGiftKaraGuarded {
    COP [SetFlagByte] ( #CA )
    JMP $&code_04A703
}

gs2A_shira.code_list_059491! [
    &code_059497
    &ShirasGiftGoldShipMisfortune
    &ShirasGiftGoldShipBlessing
]

ShirasGiftGoldShipMisfortune {
    COP [PrintDialogString] ( &dialogstring_0595B4 )
    COP [BranchOnFlagByte] ( #CA, #01, &ShirasGiftGoldShipGrant )
    JMP $&loc_0594A1
}

ShirasGiftGoldShipBlessing {
    COP [PrintDialogString] ( &dialogstring_0595E6 )
    COP [BranchOnFlagByte] ( #C9, #01, &ShirasGiftGoldShipGrant )
    JMP $&loc_0594A1
}

ShirasGiftGoldShipGrant {
    COP [BranchOnFlagByte] ( #CB, #01, &loc_0594A1 )
    COP [GiveItem] ( #2B, &loc_0594A1 )
    COP [SetFlagByte] ( #CB )
    JMP $&loc_0594A1
}

nvAC_hamlet.code_0887BA! {
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08890E )
    COP [BranchOnFlagByte] ( #CB, #01, &shiras_gift_hamlet_finish )
    COP [GiveItem] ( #2B, &shiras_gift_hamlet_finish )
    COP [SetFlagByte] ( #CB )

  shiras_gift_hamlet_finish:
    COP [SetFlagByte] ( #05 )
    COP [Die]
}
