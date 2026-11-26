; GaiaLabs Retranslation, chapter 18. Dialogue only.

?INCLUDE 'dm3E_intro'
dm3E_intro.dialogstring_05FA59! `[DEF]A mysterious garden floats[N]in the sky above Nazca.[FIN][DEF]Far below, Neil and the[N]others look no bigger than[N]grains of rice.[END]`

?INCLUDE 'sg4C_spirits'
sg4C_spirits.dialogstring_05F371! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: We meet[N]again, huh? Mweheheheh.[WAI][N]We have watched kingdoms[N]rise, prosper, and crumble[N]beneath this garden.[WAI][N]We watched the Incas fall.[N]They were not the first,[N]nor were they the last.[END]`
sg4C_spirits.dialogstring_05F3C9! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: This garden in[N]the sky is our vessel.[FIN]It carried our people[N]long ago, before the[N]comet's light changed[N]our bodies.[FIN]The great markings below[N]once guided this vessel[N]across the heavens.[FIN]Their makers vanished,[N]but the stars they[N]marked shine on.[END]`
sg4C_spirits.dialogstring_05F46E! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: The garden has[N]two faces.[WAI][N]Leap from the edge and you[N]may land on the world[N]beneath the one you see.[WAI][N]Up and down are only[N]a question of where[N]you stand.[END]`

?INCLUDE 'sg52_switch'
sg52_switch.dialogstring_05F71C! `[DEF][CLD][DLG:3,F][SIZ:D,5]This tile makes a sound[AD][END]`

?INCLUDE 'sg55_mystic_statue'
sg55_mystic_statue.dialogstring_0ACF0E! `[CLD][DLG:3,13][SIZ:D,3]When the giant bird falls,[N]Will finds a Mystic Statue[N]among its remains![END]`
sg55_mystic_statue.dialogstring_0ACF4A! `[DEF]Through the roar of a[N]propeller, Neil's voice[N]booms from a megaphone![FIN][CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme6]Neil: Will! You're[N]getting too close to the[N]ground![FIN][CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme6]I'll catch you with the[N]aeroplane. Now jump![END]`

?INCLUDE 'sp58_missed_flight'
sp58_missed_flight.dialogstring_06805C! `[CLD][BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]Neil: Shoot! I missed![FIN][CLD][BOR:2][DLG:3,6][SIZ:C,2][PRT:@RetranslationTheme1]Kara: Neil, you idiot![N]Will's going to die![FIN][CLD][BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme4]Lance: Neil! There's still[N]time. Turn around![FIN][CLD][BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]Neil: Right! I'll get him[N]this time![END]`

?INCLUDE 'sp58_red_eye'
sp58_red_eye.dialogstring_068230! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: That was close…[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: *Sniffle* *Sniffle*[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Erik: *Sob* *Sob* *Sob*[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Kara and Erik, stop[N]cryin'. We saved Will,[N]after all.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Neil, this[N]invention, it's amazing![N]How does it stay[N]in the air?[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: Well, not so easily,[N]with so many people.[N]The wings ride on[N]changes in air pressure.[FIN]And the engine burns[N]a powerful liquid fuel.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Yeah...[N]I'm not gonna[N]pretend I understand.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: How far can it go?[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: Never really[N]tested its range before.[N]Can probably take us[N]to the next ruins![FIN]... so long as the[N]fuel holds out.[WAI][N]It should be fine![END]`
; The v0.051 exchange includes the discussion of the flight ahead.
sp58_red_eye.code_06821C! {
    COP [WaitWord] ( #$012B )
    COP [PrintDialogString] ( &dialogstring_068230 )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06834A )
    COP [Die]
}

sp58_red_eye.dialogstring_06834A! `[CLD][BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]Neil: If the pattern we've[N]been following holds, the[N]next point should be out[N]over the ocean--[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]where old stories place[N]Mu.[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme6]Alright, out to the[N]ocean…!![FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Somewhere beneath this[N]sea, the continent of Mu[N]should still be waiting[N]for us.[END]`

?INCLUDE 'sp58_monologue'
sp58_monologue.dialogstring_0683EB! `[DEF]Will and the others[N]escape the aeroplane[N]just in time[AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](Neil figured out how to[N]fall from the sky without[N]getting hurt, and somehow[N]forgot to fill the tank[AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought]Hard to stay mad[N]at him, though.[N]He caught me.)[END]`
