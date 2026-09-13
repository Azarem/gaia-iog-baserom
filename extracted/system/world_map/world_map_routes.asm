; World map travel routes — movement step sequences for inter-location travel animations (241015–242132, Bank 03).
; 
; Pure data block containing 38 route definitions used by the WorldMapController to animate the player's airship/walking path between locations on the world map.
; 
; === DATA FORMAT ===
; 
; Top-level pointer table (world_map_routes): 38 entries ($00–$25), each pointing to a route step array.
; 
; Each route step is a 4-byte record: `route-step < flags, direction, ?, distance >`
;   - Byte 0 (flags): High nibble = animation modifier, low nibble = speed/curve modifier
;   - Byte 1 (direction): $00 = continue, $01 = turn left, $02 = turn right, $11 = sharp left, $12 = sharp right
;   - Byte 2: Additional movement parameter (usually $00, $01, or $02)
;   - Byte 3 (distance): Pixel distance to travel for this step ($10–$FF)
; 
; Routes are traversed sequentially; the WorldMapController reads steps until the array ends, moving the player icon along the defined path with direction changes and distance segments.
---------------------------------------------

---------------------------------------------

world_map_routes [
  &route_step_03ADC3   ;00
  &route_step_03ADC3   ;01
  &route_step_03ADD8   ;02
  &route_step_03ADF1   ;03
  &route_step_03AE06   ;04
  &route_step_03AE23   ;05
  &route_step_03AE38   ;06
  &route_step_03AE5D   ;07
  &route_step_03AE76   ;08
  &route_step_03AE9B   ;09
  &route_step_03AEA0   ;0A
  &route_step_03AEBD   ;0B
  &route_step_03AEDA   ;0C
  &route_step_03AEEB   ;0D
  &route_step_03AF10   ;0E
  &route_step_03AF2D   ;0F
  &route_step_03AF42   ;10
  &route_step_03AF5F   ;11
  &route_step_03AF9C   ;12
  &route_step_03AFBD   ;13
  &route_step_03AFCE   ;14
  &route_step_03AFEB   ;15
  &route_step_03B00C   ;16
  &route_step_03B02D   ;17
  &route_step_03B046   ;18
  &route_step_03B063   ;19
  &route_step_03B080   ;1A
  &route_step_03B09D   ;1B
  &route_step_03B0AE   ;1C
  &route_step_03B0C7   ;1D
  &route_step_03B0E0   ;1E
  &route_step_03B0F5   ;1F
  &route_step_03B10E   ;20
  &route_step_03B12F   ;21
  &route_step_03B154   ;22
  &route_step_03B17D   ;23
  &route_step_03B19E   ;24
  &route_step_03B1BF   ;25
]

route_step_03ADC3 [
  route-step < #00, #02, #00, #30 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #02, #00, #30 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_step_03ADD8 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #30 >   ;01
  route-step < #00, #00, #01, #80 >   ;02
  route-step < #00, #01, #00, #70 >   ;03
  route-step < #00, #00, #02, #80 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
]

route_step_03ADF1 [
  route-step < #00, #02, #00, #A0 >   ;00
  route-step < #00, #00, #01, #20 >   ;01
  route-step < #12, #02, #00, #20 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #00, #02, #00, #30 >   ;04
]

route_step_03AE06 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #10 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #E0 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #7B >   ;06
]

route_step_03AE23 [
  route-step < #00, #02, #00, #20 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_step_03AE38 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #10 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #01, #00, #30 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #01, #00, #00, #70 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
  route-step < #00, #02, #00, #10 >   ;08
]

route_step_03AE5D [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #20 >   ;01
  route-step < #00, #00, #02, #40 >   ;02
  route-step < #01, #00, #00, #50 >   ;03
  route-step < #00, #00, #01, #80 >   ;04
  route-step < #00, #02, #00, #10 >   ;05
]

route_step_03AE76 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #20 >   ;01
  route-step < #02, #11, #00, #40 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #02, #00, #00, #30 >   ;04
  route-step < #00, #00, #01, #80 >   ;05
  route-step < #00, #01, #00, #10 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_step_03AE9B [
  route-step < #00, #02, #00, #80 >
]

route_step_03AEA0 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #30 >   ;01
  route-step < #00, #00, #02, #20 >   ;02
  route-step < #01, #11, #00, #A0 >   ;03
  route-step < #00, #00, #02, #20 >   ;04
  route-step < #01, #01, #00, #10 >   ;05
  route-step < #00, #00, #01, #C0 >   ;06
]

route_step_03AEBD [
  route-step < #00, #00, #01, #40 >   ;00
  route-step < #02, #02, #00, #10 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #02, #12, #00, #A0 >   ;03
  route-step < #00, #00, #01, #20 >   ;04
  route-step < #02, #00, #00, #30 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_step_03AEDA [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #00, #02, #00, #50 >   ;03
]

route_step_03AEEB [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #20 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #00, #00, #30 >   ;04
  route-step < #00, #00, #02, #20 >   ;05
  route-step < #01, #11, #00, #40 >   ;06
  route-step < #00, #00, #01, #20 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_step_03AF10 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #01, #00, #50 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #00, #00, #60 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #02, #00, #10 >   ;06
]

route_step_03AF2D [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #70 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #01, #02, #00, #40 >   ;03
  route-step < #00, #00, #01, #40 >   ;04
]

route_step_03AF42 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #60 >   ;01
  route-step < #11, #01, #00, #A0 >   ;02
  route-step < #00, #00, #02, #20 >   ;03
  route-step < #00, #01, #00, #40 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_step_03AF5F [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #20 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #01, #00, #30 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #02, #00, #00, #10 >   ;06
  route-step < #00, #00, #02, #40 >   ;07
  route-step < #02, #02, #00, #20 >   ;08
  route-step < #00, #00, #01, #40 >   ;09
  route-step < #02, #00, #00, #50 >   ;0A
  route-step < #00, #00, #01, #80 >   ;0B
  route-step < #00, #01, #00, #10 >   ;0C
  route-step < #00, #00, #01, #80 >   ;0D
  route-step < #00, #00, #01, #80 >   ;0E
]

route_step_03AF9C [
  route-step < #00, #02, #00, #10 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #01, #00, #00, #60 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #02, #00, #30 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #01, #00, #00, #20 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_step_03AFBD [
  route-step < #00, #02, #00, #50 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
]

route_step_03AFCE [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #30 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #50 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_step_03AFEB [
  route-step < #00, #00, #01, #40 >   ;00
  route-step < #02, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #02, #12, #00, #80 >   ;03
  route-step < #00, #00, #01, #20 >   ;04
  route-step < #02, #00, #00, #60 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
  route-step < #00, #02, #00, #10 >   ;07
]

route_step_03B00C [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #40 >   ;01
  route-step < #00, #00, #02, #20 >   ;02
  route-step < #01, #11, #00, #A0 >   ;03
  route-step < #00, #00, #02, #20 >   ;04
  route-step < #01, #01, #00, #20 >   ;05
  route-step < #00, #00, #01, #40 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_step_03B02D [
  route-step < #00, #00, #02, #40 >   ;00
  route-step < #01, #02, #00, #30 >   ;01
  route-step < #01, #02, #00, #08 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #00, #02, #00, #40 >   ;04
  route-step < #00, #02, #00, #08 >   ;05
]

route_step_03B046 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #40 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #02, #01, #00, #40 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_step_03B063 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #02, #01, #00, #70 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #02, #00, #00, #20 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
]

route_step_03B080 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #20 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #01, #02, #00, #70 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #01, #00, #00, #20 >   ;05
  route-step < #00, #00, #01, #80 >   ;06
]

route_step_03B09D [
  route-step < #00, #00, #02, #20 >   ;00
  route-step < #11, #02, #00, #20 >   ;01
  route-step < #00, #00, #01, #20 >   ;02
  route-step < #00, #02, #00, #30 >   ;03
]

route_step_03B0AE [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #50 >   ;02
  route-step < #00, #00, #02, #80 >   ;03
  route-step < #02, #00, #00, #10 >   ;04
  route-step < #00, #00, #02, #80 >   ;05
]

route_step_03B0C7 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #02, #00, #00, #40 >   ;01
  route-step < #00, #00, #02, #40 >   ;02
  route-step < #02, #02, #00, #50 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #00, #02, #00, #40 >   ;05
]

route_step_03B0E0 [
  route-step < #00, #02, #00, #30 >   ;00
  route-step < #00, #00, #01, #40 >   ;01
  route-step < #02, #02, #00, #20 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #02, #00, #10 >   ;04
]

route_step_03B0F5 [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #60 >   ;02
  route-step < #00, #00, #01, #80 >   ;03
  route-step < #01, #00, #00, #20 >   ;04
  route-step < #00, #00, #01, #80 >   ;05
]

route_step_03B10E [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #80 >   ;01
  route-step < #00, #01, #00, #80 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #01, #00, #10 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #01, #00, #00, #80 >   ;06
  route-step < #00, #00, #01, #80 >   ;07
]

route_step_03B12F [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #60 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #00, #00, #90 >   ;04
  route-step < #00, #00, #02, #40 >   ;05
  route-step < #01, #01, #00, #80 >   ;06
  route-step < #00, #00, #01, #40 >   ;07
  route-step < #00, #00, #01, #80 >   ;08
]

route_step_03B154 [
  route-step < #00, #00, #01, #80 >   ;00
  route-step < #00, #00, #01, #80 >   ;01
  route-step < #00, #01, #00, #A0 >   ;02
  route-step < #00, #01, #00, #C0 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
  route-step < #02, #01, #00, #A0 >   ;05
  route-step < #00, #00, #02, #40 >   ;06
  route-step < #02, #00, #00, #A0 >   ;07
  route-step < #02, #00, #00, #C0 >   ;08
  route-step < #00, #00, #02, #80 >   ;09
]

route_step_03B17D [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #01, #00, #00, #A0 >   ;01
  route-step < #01, #00, #00, #C0 >   ;02
  route-step < #00, #00, #01, #40 >   ;03
  route-step < #01, #02, #00, #A0 >   ;04
  route-step < #00, #00, #01, #40 >   ;05
  route-step < #00, #02, #00, #A0 >   ;06
  route-step < #00, #02, #00, #C0 >   ;07
]

route_step_03B19E [
  route-step < #00, #00, #02, #80 >   ;00
  route-step < #00, #00, #02, #40 >   ;01
  route-step < #01, #01, #00, #80 >   ;02
  route-step < #00, #00, #02, #40 >   ;03
  route-step < #00, #01, #00, #A0 >   ;04
  route-step < #00, #01, #00, #80 >   ;05
  route-step < #00, #00, #02, #80 >   ;06
  route-step < #00, #00, #02, #80 >   ;07
]

route_step_03B1BF [
  route-step < #00, #02, #00, #A0 >   ;00
  route-step < #00, #02, #00, #80 >   ;01
  route-step < #00, #00, #01, #40 >   ;02
  route-step < #02, #02, #00, #80 >   ;03
  route-step < #00, #00, #02, #40 >   ;04
]