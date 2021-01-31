// Hob Goblin - Extra Nade Damage/Refill Nade

/* CVARS - copy and paste to shconfig.cfg

//Hob Goblin
goblin_level 0
goblin_grenademult 1.5		//Damage multiplyer from orginal damage amount
goblin_grenadetimer 10		//How many second delay for new grenade

*/

// v1.17 - JTP - Fixed giving new genades using more reliable event

#include <amxmodx>
#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[]= "Hobgoblin"
new bool:gHasHobgoblin[SH_MAXSLOTS+1]
new bool:gBlockGiveTask[SH_MAXSLOTS+1]
new gPcvarGrenadeTimer
new gPcvarGrenadeMult
new gGrenTrail
new const HEGRENADE_MODEL[] = "models/w_hegrenade.mdl"

#define AMMOX_HEGRENADE 12
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Hobgoblin", SH_VERSION_STR, "{HOJ} Batman/JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("goblin_level", "0")
	gPcvarGrenadeMult = register_cvar("goblin_grenademult", "1.5")
	gPcvarGrenadeTimer = register_cvar("goblin_grenadetimer", "10")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Hobgoblin Grenades", "Extra Nade Damage/Refill Nade")
	sh_set_hero_dmgmult(gHeroID, gPcvarGrenadeMult, CSW_HEGRENADE)

	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
	register_event("AmmoX", "on_ammox", "b")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	gGrenTrail = precache_model("sprites/zbeam5.spr")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasHobgoblin[id] = true
			give_grenade(id)
		}
		case SH_HERO_DROP: {
			gHasHobgoblin[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasHobgoblin[id] ) {
		//Block Ammox nade give task on spawn, since you are given a nade on spawn.
		//This must not be delayed, it must catch before inital ammox called.
		gBlockGiveTask[id] = true

		give_grenade(id)
	}
}
//----------------------------------------------------------------------------------------------
public give_grenade(id)
{
	if ( sh_is_active() && is_user_alive(id) && gHasHobgoblin[id] && get_pcvar_float(gPcvarGrenadeTimer) > 0 ) {
		sh_give_weapon(id, CSW_HEGRENADE)
	}
}
//----------------------------------------------------------------------------------------------
public on_ammox(id)
{
	//Ammox is used in case other heroes give nades so the task can be removed when nade is refilled.
	if ( !sh_is_active() || !is_user_alive(id) || !gHasHobgoblin[id] ) return

	//new iAmmoType = read_data(1)
	if ( read_data(1) == AMMOX_HEGRENADE ) {
		new iAmmoCount = read_data(2)

		if ( iAmmoCount == 0 && !gBlockGiveTask[id] ) {
			//This will be called on spawn as well as when nade is thrown, block this on spawn.
			//Nade was thrown set task to give another.
			set_task(get_pcvar_float(gPcvarGrenadeTimer), "give_grenade", id)
		}
		else if ( iAmmoCount > 0 ) {
			gBlockGiveTask[id] = false
			remove_task(id)
		}
		if (get_pcvar_float(gPcvarGrenadeMult) <= 1.0)
			return
		// From SuperHero Gambit
		// https://forums.alliedmods.net/showthread.php?t=30213
		// Have to Find the current HE grenade
		new iCurrent = -1
		while ( ( iCurrent = find_ent(iCurrent, "grenade") ) > 0 ) {
			new string[32]
			entity_get_string(iCurrent, EV_SZ_model, string, 31)

			if ( id == entity_get_edict(iCurrent, EV_ENT_owner) && equali(HEGRENADE_MODEL, string)) {

				new Float:glowColor[3] = {225.0, 0.0, 20.0}

				// Make the nade glow
				entity_set_int(iCurrent, EV_INT_renderfx, kRenderFxGlowShell)
				entity_set_vector(iCurrent, EV_VEC_rendercolor, glowColor)

				// Make the nade a bit invisible to make glow look better
				entity_set_int(iCurrent, EV_INT_rendermode, kRenderTransAlpha)
				entity_set_float(iCurrent, EV_FL_renderamt, 100.0 )

				// Make a trail
				message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
				write_byte(22)			//TE_BEAMFOLLOW
				write_short(iCurrent)	// entity:attachment to follow
				write_short(gGrenTrail)	// sprite index
				write_byte(10)		// life in 0.1's
				write_byte(10)		// line width in 0.1's
				write_byte(225)	// colour
				write_byte(90)
				write_byte(102)
				write_byte(255)	// brightness
				message_end()
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	gHasHobgoblin[id] = false
}
//----------------------------------------------------------------------------------------------