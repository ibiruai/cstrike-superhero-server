// ORC!
// "Equipment Reincarnation" from Warcraft3 XP 
// Authors: ferret (Dopefish/Spacedude)
// WC3 XP: https://forums.alliedmods.net/showthread.php?p=129465
// Ported by Evileye

/* CVARS - copy and paste to shconfig.cfg

//Orc
orc_level 0

*/

#include <superheromod>
#include <hamsandwich>
#include <fakemeta_util>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Orc"
new gHasOrcPower[SH_MAXSLOTS+1]

new bool:DiedLastRound[SH_MAXSLOTS+1]
new bool:GameRestarted

new savedArmor[SH_MAXSLOTS+1]
new CsArmorType:armorType[SH_MAXSLOTS+1]
new savedWeapons[SH_MAXSLOTS+1][32]
new savedCount[SH_MAXSLOTS+1]
new savedFocus[SH_MAXSLOTS+1]
new flashbangAmmo[SH_MAXSLOTS+1]

new bool:hasShield[SH_MAXSLOTS+1]
new bool:hasDefuse[SH_MAXSLOTS+1]
new bool:hasNvg[SH_MAXSLOTS+1]

// It contains the names of the 30 weapon ids and their corresponding
// ammo types. A "" is inserted if the weapon doesn't exist in CS or
// there is no ammo type, such as with grenades.
new gWpnNames[32][32] = {"weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90", "", ""}
new gWpnAmmo[32][32] = {"ammo_357sig", "", "ammo_762nato", "", "ammo_buckshot", "", "ammo_45acp", "ammo_556nato", "", "ammo_9mm", "ammo_57mm", "ammo_45acp", "ammo_556nato", "ammo_556nato", "ammo_556nato", "ammo_45acp", "ammo_9mm", "ammo_338magnum", "ammo_9mm", "ammo_556natobox", "ammo_buckshot", "ammo_556nato", "ammo_9mm", "ammo_762nato", "", "ammo_50ae", "ammo_556nato", "ammo_762nato", "", "ammo_57mm", "", ""}
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Orc", "1.0", "ferret (Dopefish/Spacedude)")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("orc_level", "0")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Equipment Reincarnation", "You will get all of your equipment in your next life")
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
	register_event("ResetHUD", "player_spawn", "b")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("TextMsg", "event_game_restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	// DeathMsg or sh_client_death() don't work when a player is killed by a bomb explosion
	// But with Ham_Killed the plugin never remembers if a player had a defuse kit on their death
	// That's why we have to use both of them
	RegisterHam( Ham_Killed, "player", "Fwd_Ham_Killed_Post", 1 )
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasOrcPower[id] = true
		}
		case SH_HERO_DROP: {
			gHasOrcPower[id] = false
		}
	}
	
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound("shmod/orc_reincarnation.wav")
}
//----------------------------------------------------------------------------------------------
public event_round_start()
{
	if ( GameRestarted )
	{
		GameRestarted = false
		for (new id = 1; id <= SH_MAXSLOTS; id++)
			DiedLastRound[id] = false
	}
}
//----------------------------------------------------------------------------------------------
public event_game_restart()
{
	GameRestarted = true
}
//----------------------------------------------------------------------------------------------
public Fwd_Ham_Killed_Post(id, attacker) {
	if( !gHasOrcPower[id] ) return
	
	DiedLastRound[id] = true
	
	for ( new i = 0; i < 32; ++i )
		savedWeapons[id][i] = 0
	
	savedCount[id] = 0
	savedArmor[id] = cs_get_user_armor( id, armorType[id] ) 
	savedFocus[id] = get_user_weapon(id)
	get_user_weapons( id, savedWeapons[id], savedCount[id] )
	hasShield[id] = ( cs_get_user_shield(id) ? true : false )
	hasNvg[id] =    ( cs_get_user_nvg(id)    ? true : false )
	flashbangAmmo[id] = cs_get_user_bpammo(id, CSW_FLASHBANG)
}
//----------------------------------------------------------------------------------------------
public sh_client_death(id)
{
	if ( cs_get_user_defuse(id) )
		hasDefuse[id] = true
}
//----------------------------------------------------------------------------------------------
public player_spawn(id)
{
	if ( !gHasOrcPower[id] || !is_user_connected(id) || !is_user_alive(id) ) return	
	
	new iParm[2]
	iParm[0] = id
	iParm[1] = 0
	
	if ( DiedLastRound[id] ) 
	{
		if( gHasOrcPower[id] )
		{
			set_task(0.1, "reincarnation_weapons", 10091, iParm, 2)
			set_task(0.8, "set_armor",             10092, iParm, 2)
			
			//client_cmd(id, "spk shmod/orc_reincarnation.wav")
			emit_sound(id, CHAN_AUTO, "shmod/orc_reincarnation.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW)
			sh_screen_fade(id, 0.5, 0.25, 10, 255, 10, 70)	// Green Screen Flash
			set_task(0.05, "orc_glow", id * 10000 + 2853)
			set_task(2.5, "orc_unglow", id * 10000 + 2854)
		}
	}
	DiedLastRound[id] = false
}
//----------------------------------------------------------------------------------------------
public orc_glow(task_id)
{
	sh_set_rendering( task_id / 10000, 0, 128, 0, 16, kRenderFxGlowShell )
}
//----------------------------------------------------------------------------------------------
public orc_unglow(task_id)
{
	sh_set_rendering( task_id / 10000 )
}
//----------------------------------------------------------------------------------------------
public reincarnation_weapons(iParm[2])
{
	new id = iParm[0]
	
	if ( !gHasOrcPower[id] || !is_user_connected(id) || !is_user_alive(id) ) return	
	
	new pistol
	new bool:drop = true
	switch ( get_user_team(id) )
	{
		case 1: pistol = CSW_GLOCK18
		case 2:	pistol = CSW_USP
	}

	for (new j = 0; j < savedCount[id] && j < 32; j++)
	{
		if ( contain(gWpnNames[savedWeapons[id][j]-1], "weapon_") == 0 && savedWeapons[id][j] != CSW_C4 )
		{
			give_item(id, gWpnNames[savedWeapons[id][j]-1])
			
			if ( contain(gWpnAmmo[savedWeapons[id][j]-1], "ammo_") == 0 )
			{
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
				give_item(id, gWpnAmmo[savedWeapons[id][j]-1])
			}
			
			if ( pistol == savedWeapons[id][j] )
				drop = false
		}
		
		savedWeapons[id][j] = 0
	}
	
	if ( drop )
		sh_drop_weapon(id, pistol, true)
	
	if ( flashbangAmmo[id] )			// Flashbangs
		cs_set_user_bpammo(id, CSW_FLASHBANG, flashbangAmmo[id])
	if ( hasShield[id] )
		give_item(id, "weapon_shield")	// Shield
	if ( hasNvg[id] )
		cs_set_user_nvg(id, 1)			// Night Vision
	if ( hasDefuse[id] )
		give_item(id, "item_thighpack")	// Defuse Kit
	
	if ( savedFocus[id] )
		client_cmd(id, gWpnNames[savedFocus[id]-1])
	
	savedCount[id] = 0
}
//----------------------------------------------------------------------------------------------
public set_armor(iParm[2])
{
	new id = iParm[0]
	
	if ( !gHasOrcPower[id] || !is_user_connected(id) || !is_user_alive(id) ) return	
	
	if ( savedArmor[id] > get_user_armor(id) )
		cs_set_user_armor( id, savedArmor[id], armorType[id] )
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	gHasOrcPower[id] = false
	hasDefuse[id] = false
	DiedLastRound[id] = false
}
//----------------------------------------------------------------------------------------------	