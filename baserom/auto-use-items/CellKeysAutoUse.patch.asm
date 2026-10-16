

!key_item_flags      0B58

-------------------------------------------

code_05D54B! {
    LDA $key_item_flags
    BIT #$0040
    BNE code_05D552
    COP [BranchIfHasItem] ( #0B, &code_05D552 )
    BRA loc_05D557
}

code_05D552! {
    LDA $key_item_flags
    BIT #$0080
    BNE code_05D56D
    COP [BranchIfHasItem] ( #0C, &code_05D56D )
}
