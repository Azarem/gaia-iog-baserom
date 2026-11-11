# B001 open questions

| ID | Question | Why it matters | How to settle it |
|----|----------|----------------|------------------|
| OQ-B001-1 | Which actor selects animations #04 to #09 of `spm_darkspace_sprites` (8 x 8 effects and a 32 x 32 figure)? `sE6_gaia` does not, and the second user, scene card `scene_meta_0010` (music bgm_descent_into_darkness), was not traced to its actors | Decides whether they are dead data and what the figure is | Find the scene whose card is `scene_meta_0010` and read its actor list; or Mesen2 with a breakpoint on `UpdateActorAnimation` while `$28` is 4-9 (UNVERIFIED-RUNTIME) |
| OQ-B001-2 | Are animations #07 to #0A of `spm_overworld_sprites` the four pieces of one vehicle (Neil's ship on the Watermia to Euro leg), and which party member do #00 to #05 draw? | Names for 14 animations (R-B001-1) | Mesen2 screenshot of the map with each party array value; or decode `gfx_overworld_actors` tiles against the tile words in the groups (UNVERIFIED-RUNTIME) |
