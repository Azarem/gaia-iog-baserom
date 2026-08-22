
?INCLUDE 'chunk_03BAE1'


  loc_03CEEC:
    LDX $0646
    LDA $@scene_actors_extract_table, X
    DEC
    STA $3E
    LDA #$1000
    STA $09F4
    PLP 
    RTL 