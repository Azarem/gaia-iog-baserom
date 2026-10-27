

!key_item_flags      0B58

-------------------------------------------

code_05D54B-= {
    LDA $key_item_flags
    BIT #$0040
    BNE code_05D552
}

code_05D552-= {
    LDA $key_item_flags
    BIT #$0080
    BNE code_05D56D
}
