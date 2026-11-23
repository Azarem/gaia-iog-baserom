; GaiaLabs Retranslation, chapter 05. Dialogue only.

?INCLUDE 'ec0B_cell'
ec0B_cell.dialogstring_04D42F! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought][DLY:0](Well, she tried to warn[N]me. But if I hadn't come[AD])[WAI][N](I hope Grandma and[N]Grandpa are okay.)[WAI][N](Grandpa, why couldn't you[N]have designed a[AD] less[N]secure prison?)[END]`

?INCLUDE 'ec0B_ball'
ec0B_ball.dialogstring_04DBF1! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: Something's[N]scratched into this iron[N]ball and chain...[WAI][N]"My wife?"[END]`

?INCLUDE 'ec0B_moss'
ec0B_moss.dialogstring_04DB62! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought][DLY:0](This moss must have seen[N]countless prisoners[AD])[WAI][N](I wonder how long before[N]I give it a name?)[END]`

?INCLUDE 'ec0B_door'
ec0B_door.dialogstring_04DB2D! `[BOR:3][DLG:3,17][SIZ:D,1][PRT:@RetranslationTheme0]There's a lock here…[END]`

?INCLUDE 'ec0B_cell'
ec0B_cell.dialogstring_04D60A! `[DEF]A soldier's deep voice[N]echoes from a hole opened[N]in the ceiling.[FIN][CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme19][DLY:0]It's today's ration of[N]bread. You'll get water[N]tomorrow.[END]`
ec0B_cell.dialogstring_04D37A! `[DEF]Will tries a bite of[N]the bread.[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought][DLY:0](Stale and hard. It makes[N]Grandma Lola's oddest[N]meals seem downright[N]palatable.)[END]`
ec0B_cell.dialogstring_04D679! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought][DLY:0](I've spent the whole day[N]trying not to be afraid.[N]Now I'm mostly bored.)[WAI][N](I keep thinking there has[N]to be a way out of here.)[WAI][N](But I'm so tired...[N]Maybe if I sleep awhile,[N]I'll think of something.)[END]`
ec0B_cell.dialogstring_04D732! `[PAU:78][CLD][DEF]A familiar voice echoes[N]from Will's flute through[N]the silence of the cell[AD][FIN][CLD][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0]Flute: Will[AD][FIN][CLD][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0]Flute: Will,[N]this is your father.[END]`
; The flute's final question takes one row before the two answers.
ec0B_cell.code_04D275! {
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04D679 )
    COP [WaitByte] ( #1D )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_in_1B.FadeBackdropIn1B )
    COP [WaitByte] ( #BF )
    COP [PrintDialogString] ( &dialogstring_04D732 )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
    COP [WaitByte] ( #BF )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04D78A )
    COP [DialogueOptions] ( #02, #01, &code_list_04D2A6 )
}
ec0B_cell.dialogstring_04D78A! `[PAU:3C][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: Dad[AD]?[FIN][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0][DLY:0]Flute: You've grown, Will.[N]You were so little when[N]I left.[FIN][DLY:0]Does Grandma Lola still[N]make those...[PAU:1E] pies?[FIN][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0][DLY:0]Will: Dad! Where are you?![FIN][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0][DLY:0]Flute: Please, just[N]listen, we haven't much[N]time.[FIN]Will you hear me out?[N][PAL:0] Yes, of course[N] No, you abandoned me!`
ec0B_cell.dialogstring_04D87D! `[CLR][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0]Flute: I know I left you[N]with questions. I can't[N]answer them all yet.[WAI][N]But I need your help.[N]I was once held in this[N]cell too.[WAI][N]Look at the left wall.[N]A stone there holds the[N]same power.[END]`
ec0B_cell.dialogstring_04D8D2! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: You were here?[FIN][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0][DLY:0]Flute: Yes. Grandpa Bill[N]knew the secret of the[N]stones.[FIN][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0][DLY:0]Will: Grandpa? What[N]stones?[FIN][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Flute][DLY:0][DLY:0]Flute: The ones that lie[N]within demons.[WAI][N]Demons leave stones behind[N]when they fall.[WAI][N]The approaching comet[N]stirs power inside them.[WAI][N]Gather that power.[N]It will help you.[WAI][N]Then search the ruins for[N]the Mystic Statues.[WAI][N]As the comet draws nearer,[N]the demons will grow[N]stronger.[WAI][N]Go first to the[N]Incan ruins.[FIN][CLD][DEF]The voice from the flute[N]fades into silence.[END]`
ec0B_cell.dialogstring_04D4A5! `[DLG:3,17][SIZ:D,1]Squee squee![PAU:28][CLD]`
ec0B_cell.dialogstring_04D4B1! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: Hey, you're Kara's[N]pet?[WAI][N]Oh? A letter and key are[N]tied near its tail[AD][FIN][CLD][DEF]The letter read:[FIN][CLD][BOR:1][DLG:3,D][SIZ:D,6][PRT:@RetranslationTheme1][SFX:0]"Father won't listen to a[N] word I say.[N] I too am a prisoner--[N] in a prison of silk[N] and gold.[WAI][N] Tonight I'm going to[N] escape the castle.[N] And I'm getting you out[N] too.[N]                  Kara"[FIN]`
ec0B_cell.dialogstring_04D5F4! `[CLD][DLG:3,4][SIZ:D,1][SFX:0][DLY:9]Got the jail key![PAU:A0][END]`

?INCLUDE 'item_use_system'
item_use_system.dialogstring_03861F! `[DEF]Will uses the Prison Key.[N]The gate opens with a[N]heavy, dull sound.[END]`

?INCLUDE 'ec0B_guard'
ec0B_guard.dialogstring_04DC5E! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16][DLY:0]I don't need anyone's[N]help... I can[N]get out by myself...[END]`

?INCLUDE 'sE6_gaia'
sE6_gaia.dialogstring_08DE96! `[BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Gaia]Child of echoes, hear now[N]my counsel.[FIN]`
sE6_gaia.dialogstring_08DED3! `[PRT:@dialogstring_08DE96]When thou defeatest every[N]enemy in one place, jewels[N]of strength may appear.[FIN]Gather them, and thou[N]shalt grow stronger.[FIN]If thou wilt but pause and[N]rest, thou shouldst divine[N]where enemies remain.[FIN]Remember this when demons[N]hide from thy sight[AD][FIN]`

; Compact narration used by the shared room-clear stat rewards in v0.051.
?INCLUDE 'reward_actors'
reward_actors.dialogstring_00E058! `[DEF][DLY:1][SFX:0]Will feels healthier.[END]`
reward_actors.dialogstring_00E09F! `[DEF][DLY:1][SFX:0]Will feels stronger.[END]`
reward_actors.dialogstring_00E0EA! `[DEF][DLY:1][SFX:0]Will feels hardier.[END]`

?INCLUDE 'ec0C_force_hint'
ec0C_force_hint.dialogstring_04DCBD! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought](I get stronger by slaying[N]every demon here?)[WAI][N](Sure hope there aren't[N]any side effects.)[END]`

?INCLUDE 'ec0E_lily'
ec0E_lily.dialogstring_09AA02! `[CLD][BOR:6][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme2]What are you doing?[N]I'm not an enemy![END]`
ec0E_lily.dialogstring_09AA1B! `[BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Hurry, come this way[AD]![N]You won't be hurt by the[N]demons[AD]![END]`

?INCLUDE 'ec0F_rusty_switch'
ec0F_rusty_switch.dialogstring_0A89BF! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought][DLY:0](I can't press it down[N]very much[AD]! It looks like[N]it's rusted[AD])[END]`

?INCLUDE 'ec10_dp_hint_spirit'
ec10_dp_hint_spirit.dialogstring_04DD20! `[CLD][BOR:4][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme17][DLY:0]A silver sphere that[N]somehow glows with[N]darkness[AD][WAI][N]Gather one hundred, and[N]thy Source of Life shall[N]grow by one.[WAI][N]Should an enemy strike[N]thee down, this darkness[N]shall return thee nearby.[WAI][N]It is the power of echoes,[N]shadows, and returning[AD][END]`

?INCLUDE 'ec11_flower'
ec11_flower.dialogstring_09BC51! `[BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme18][DLY:0]Blooming Flower:[N]Please play your flute[AD][N]Please play that melody[AD][END]`

?INCLUDE 'item_use_system'
item_use_system.dialogstring_038517! `[DLG:3,17][SIZ:D,1]Raised the Red Jewel![FIN][CLD][DLG:3,11][SIZ:D,4]The Red Jewel became a ray[N]of light and flew to Gem,[N]the jewel merchant's,[N]location![END]`
item_use_system.dialogstring_038C76! `[DEF]Will quietly plays the[N]melody Lola had taught[N]him.[END]`
item_use_system.dialogstring_038CDB! `[DLG:3,13][SIZ:D,3]He quietly started playing[N]the melody that Lola had[N]taught him.[FIN][::][DLG:3,13][SIZ:D,3]But nothing happened.[END]`
item_use_system.dialogstring_038D17! `[DEF]When the melody ends, a[N]voice can suddenly be[N]heard from somewhere[AD][FIN][CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Mysterious voice: Please[N]go in front of the switch[N]on the right side of the[N]room.[END]`

?INCLUDE 'ec11_countdown'
ec11_countdown.dialogstring_09BE70! `[::][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Mysterious voice: The door[N]won't open unless two[N]people hit this switch at[N]the same time.[WAI][N]Match the timing with my[N]count and push the switch.[WAI][N]The timing will be 1-2-3,[N]alright? Don't get it[N]wrong.[END]`

?INCLUDE 'ec11_button_voice'
ec11_button_voice.dialogstring_09BD58! `[BOR:6][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme2]Hold on! Didn't I say we[N]have to press them[N]simultaneously?[FIN][JMP:&dialogstring_09BE70]`
ec11_button_voice.dialogstring_09BD92! `[PAU:1E][BOR:6][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme2]Alright![N]The door opened…![FIN]Okay, go on ahead![END]`

?INCLUDE 'sE6_gaia'
sE6_gaia.dialogstring_08DE4D! `[CLD][BOR:4][DLG:3,11][SIZ:D,4][PRT:@CastleV051Gaia]Thou art injured. Close[N]thine eyes and be still[AD][FIN]`
sE6_gaia.dialogstring_08E98A! `[PRT:@dialogstring_08DE96]Thy form is a temporary[N]one. Thou shouldst try[N]standing in front of the[N]statue that is beside me.[FIN]`
sE6_gaia.dialogstring_08F157! `[DLG:3,15][SIZ:D,2]A voice echoes in[N]Will's head.[FIN][CLD][BOR:4][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]Will[AD] my descendant.[N]Our hope.[WAI][N]I am Freedan, Knight of[N]Darkness. Darkness is not[N]always evil.[WAI][N]Shade often shields life[N]from harsh light.[WAI][N]I have endured beyond my[N]time, that I might aid[N]thee[AD][FIN][CLD][DEF]Will's consciousness feels[N]another presence.[END]`

?INCLUDE 'ec13_lily'
ec13_lily.dialogstring_09C06C! `[DEF]With the demons gone,[N]Will's transformed form[N]fades away[AD][END]`
ec13_lily.dialogstring_09C0A8! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Girl: I saw you! You[N]really surprised me. You[N]can transform too, huh?[WAI][N]I'm Lilly, from the Itory[N]clan. That melody you[N]played[AD][WAI][N]it is only known to our[N]people.[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: Grandma Lola taught[N]it to me. I play it when[N]I'm in trouble.[FIN][CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Lilly: I've eaten Grandma[N]Lola's awful pies before.[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will][DLY:0]Will: You know Grandma?![FIN][CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Lilly: Hehe[AD] She asked me[N]to come rescue you![END]`
ec13_lily.dialogstring_09C226! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2][DLY:0]Lilly: Ah[AD] The Elder is[N]calling me. I have to go.[WAI][N]We'll meet again, Will.[N]Count on it! See you![END]`
