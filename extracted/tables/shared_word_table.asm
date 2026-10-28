; Shared word strings (Bank 01, 125711-125864). 15 console strings that other strings splice in with the text tag [LU:n] (console command $10, ConsoleCmd_InsertSharedWord): the operand byte is the index, and the renderer calls itself on shared_word_table[index]. Each word carries its own trailing space; there is no separator logic.
; 
; The words are not only item name prefixes: they also serve ability names ('Psycho Dash', 'Dark Friar'), item descriptions ('Restores strength.', 'Letter from Lance.') and the item menu prompts ('Rearrange items.', 'Select item and enter.'). See the table part note for the index list and which indices are used.
; 
; Only the vanilla strings were counted (tables/system_strings, 63 lines carrying 68 tags). The retranslation patches may use other indices.
---------------------------------------------

---------------------------------------------

; 15 word pointers, indexed by the [LU:n] operand ($00-$0E), all in Bank 01. The number is how many [LU:n] tags of that index the vanilla system_strings contain.
; 
; | n | Word | Tags | Examples |
; |---|------|------|----------|
; | $00 | Crystal | 0 | |
; | $01 | Diamond | 2 | 'Diamond Mine' |
; | $02 | Dark | 9 | 'Dark Knight', 'Dark Friar', 'Dark Power' |
; | $03 | Hieroglyph | 0 | |
; | $04 | Inca | 3 | 'Inca Statue A/B' (with $0C), 'Inca Melody' |
; | $05 | Mystery | 8 | the 8 'Mystery Doll' items |
; | $06 | Prison | 3 | 'Prison Key', 'Edward Castle Prison Key' |
; | $07 | Plate | 6 | the 6 'Plate with hieroglyph' descriptions |
; | $08 | Psycho | 4 | 'Psycho Dash', 'Psycho Slider' (ability names, menu and detail screens) |
; | $09 | Restores | 3 | 'Restores strength.', 'Restores Memory.' |
; | $0A | Rearrange | 2 | item menu prompt |
; | $0B | Select | 3 | item menu prompts |
; | $0C | Statue | 18 | 'Mystic Statue' (8 items), 'Incan Statue', 'Statue of Hope' and their descriptions |
; | $0D | Uses | 0 | |
; | $0E | from | 7 | 'Melody learned from Lola.' and the other 'obtained from' lines |
; 
; The strings of $00, $03 and $0D exist in the ROM but no vanilla string selects them (OQ-I063-1).

shared_word_table [
  &shared_word_crystal   ;00
  &shared_word_diamond   ;01
  &shared_word_dark   ;02
  &shared_word_hieroglyph   ;03
  &shared_word_inca   ;04
  &shared_word_mystery   ;05
  &shared_word_prison   ;06
  &shared_word_plate   ;07
  &shared_word_psycho   ;08
  &shared_word_restores   ;09
  &shared_word_rearrange   ;0A
  &shared_word_select   ;0B
  &shared_word_statue   ;0C
  &shared_word_uses   ;0D
  &shared_word_from   ;0E
]

---------------------------------------------
; Index $00 'Crystal '. No vanilla [LU:0] tag.

shared_word_crystal |Crystal |

shared_word_diamond |Diamond |

shared_word_dark |Dark |

---------------------------------------------
; Index $03 'Hieroglyph '. No vanilla [LU:3] tag (the plate descriptions spell 'hieroglyph' out in plain text).

shared_word_hieroglyph |Hieroglyph |

shared_word_inca |Inca |

shared_word_mystery |Mystery |

shared_word_prison |Prison |

shared_word_plate |Plate |

shared_word_psycho |Psycho |

shared_word_restores |Restores |

shared_word_rearrange |Rearrange |

shared_word_select |Select |

shared_word_statue |Statue |

---------------------------------------------
; Index $0D 'Uses '. No vanilla [LU:D] tag.

shared_word_uses |Uses |

shared_word_from |from |