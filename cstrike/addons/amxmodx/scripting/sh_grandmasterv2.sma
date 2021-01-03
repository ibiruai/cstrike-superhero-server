// GRANDMASTER V2

/* CVARS - copy and paste to shconfig.cfg

//Grandmaster V2
gmasterv2_level 8
gmasterv2_respawntime 5

*/

#define MESSAGE_TYPE 2

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Grandmaster"
new bool:gHasGrandmaster[SH_MAXSLOTS+1]
new const gSoundGmaster[] = "ambience/port_suckin1.wav"
new gPcvarRespawnTime
new Float:gDeathTime[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Grandmaster V2", "1.0", "evileye")
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("gmasterv2_level", "8")
	gPcvarRespawnTime = register_cvar("gmasterv2_respawntime", "5")
	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Revive Dead", "Utilize cosmic life force to revive dead players")
	register_event("DeathMsg", "ev_DeathMsg", "a")
	set_task(10.0, "gmaster_loop", _, _, _, "b")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound(gSoundGmaster)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	gHasGrandmaster[id] = mode ? true : false
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public ev_DeathMsg()
{
	new dead = read_data(2)
	gDeathTime[dead] = get_gametime()
	set_task(get_pcvar_float(gPcvarRespawnTime), "gmaster_respawn", dead)
}
//----------------------------------------------------------------------------------------------
public gmaster_respawn(dead)
{
	if ( !sh_is_active() || !sh_is_inround() ) return
	if ( !is_user_connected(dead) || is_user_alive(dead) ||
	        cs_get_user_team(dead) == CS_TEAM_SPECTATOR ) return
	if ( get_gametime() - gDeathTime[dead] - get_pcvar_float(gPcvarRespawnTime) > 1 ) return

	new players[SH_MAXSLOTS], playerCount, gmaster
	get_players(players, playerCount, "a")
	// Look for alive players with unused Grandmaster Powers
	for ( new i = 0; i < playerCount; i++ ) {
		if ( gHasGrandmaster[players[i]] ) {
			// We got a Grandmaster willing to raise the dead!
			gmaster = players[i]
			emit_sound(gmaster, CHAN_STATIC, gSoundGmaster, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			new gmasterName[32], deadName[32]
			get_user_name(gmaster, gmasterName, charsmax(gmasterName))
			get_user_name(dead, deadName, charsmax(deadName))
			#if MESSAGE_TYPE == 1
			for ( new i = 1; i <= SH_MAXSLOTS; i++ ) {
				if ( is_user_connected(i) ) {
					sh_chat_message(i, gHeroID, "%L", i, "GRANDMASTER_POWER_USED", gmasterName, deadName)
				}
			}
			#elseif MESSAGE_TYPE == 2
			for ( new i = 1; i <= SH_MAXSLOTS; i++ ) {
				if ( is_user_connected(i) ) {
					set_hudmessage(65, 65, 5, 0.01, 0.71, 2, 0.02, 3.0, 0.01, 0.1, 3)
					show_hudmessage(i, "%L", i, "GRANDMASTER_POWER_USED", gmasterName, deadName)
				}
			}
			#elseif MESSAGE_TYPE == 3
			sh_chat_message(dead, gHeroID, "%L", dead, "GRANDMASTER_POWER_USED_ON_YOU", gmasterName)
			#endif
			//Respawns the player best available method
			ExecuteHamB(Ham_CS_RoundRespawn, dead)
			emit_sound(dead, CHAN_STATIC, gSoundGmaster, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			sh_set_rendering(dead, 255, 255, 0, 16, kRenderFxGlowShell)
			set_task(3.0, "gmaster_unglow", dead)
			break
		}
	}
}
//----------------------------------------------------------------------------------------------
public gmaster_unglow(id)
{
	sh_set_rendering(id)
}
//----------------------------------------------------------------------------------------------
public gmaster_loop()
{
	static players[SH_MAXSLOTS], playerCount, dead, i
	get_players(players, playerCount, "bh")
	for ( i = 0; i < playerCount; i++ ) {
		dead = players[i]
		if (cs_get_user_team(dead) == CS_TEAM_UNASSIGNED)
			continue
		gDeathTime[dead] = get_gametime()
		set_task(get_pcvar_float(gPcvarRespawnTime), "gmaster_respawn", dead)
	}
}
