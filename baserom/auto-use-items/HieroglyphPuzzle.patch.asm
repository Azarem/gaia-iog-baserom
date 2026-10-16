
!key_item_flags      0B58

-------------------------------------------
;Interactable actor that displays the new puzzle menu

pyCD_puzzle_activator {
    COP [SetInteractHandler] ( &pyCD_puzzle_activator_interact )
    COP [WaitOnFlagByte] ( #D1, #01 )
    COP [Die]
}

pyCD_puzzle_activator_interact {
    COP [BranchOnFlagByte] ( #0F, #00, &pyCD_puzzle_activator_clear )
    RTL
}

pyCD_puzzle_activator_clear {
    LDA $key_item_flags+3
    BIT #$003F
    BNE pyCD_puzzle_activator_use
    COP [BranchIfHasItem] ( #1E, &pyCD_puzzle_activator_use )
    COP [BranchIfHasItem] ( #1F, &pyCD_puzzle_activator_use )
    COP [BranchIfHasItem] ( #20, &pyCD_puzzle_activator_use )
    COP [BranchIfHasItem] ( #21, &pyCD_puzzle_activator_use )
    COP [BranchIfHasItem] ( #22, &pyCD_puzzle_activator_use )
    COP [BranchIfHasItem] ( #23, &pyCD_puzzle_activator_use )
    RTL
}

pyCD_puzzle_activator_use {
    COP [PrintDialogString] ( &pyCD_puzzle_activator_str )
    RTL
} 

----------------------------------------
;pyCD_puzzle

code_08CBC2! {
    COP [BranchOnFlagByte] ( #D1, #01, &code_08CC09 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0048, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0060, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0078, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0090, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$00A8, #$0098, #$7000 )
    COP [SetEntryHere]
    LDY #$0000
}