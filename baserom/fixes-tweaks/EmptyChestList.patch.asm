; An empty extracted list emits no bytes, causing its label to point at the
; first real chest record. Give scenes without chests their own terminator.
?INCLUDE 'scene_chest_table'

scene_chest_table.chest_list_none! [
    #FF
]
