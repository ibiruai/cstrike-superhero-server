// SNAKE! - I'm assuming this is meant to be Solid Snake from the MGS games.

/*

//Snake
snake_level 0
snake_health 125		//Default 125
snake_armor 125		//Default 125
snake_uspmult 2.0		//Multiplier for usp damage
snake_healpoints 75		//Amount of health given by health ration
snake_cooldown 20		//Cooldown between uses of health ration

*/


/*
* 23 dec 2018 - Evileye
*      - Snake doesn't have USP anymore
*      - sendSnakeCooldown() added to tell another plugins information about cooldown
*      
*
* v1.2 - vittu - 6/22/05
*      - Minor code clean up.
*
* v1.1 - vittu - 4/14/05
*      - Cleaned up and optimized code.
*      - Fixed Rations to get max health from Snake's health cvar.
*
*   hero created by Taker, "My First".
*/

//---------- User Changeable Defines --------//


// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1

// 1 = give USP and extra USP damage, 0 = give health rations only
#define USP_AND_XTRA_DAMAGE 0


//------- Do not edit below this point ------//

#include <amxmodx>
#include <superheromod>

// GLOBAL VARIABLES
new gHeroName[] = "Snake"
new bool:gHasSnakePower[SH_MAXSLOTS+1]
new gHealPoints
new const gSnakeSound[] = "items/medshot4.wav"

#if SEND_COOLDOWN
	new snake_cooldown
	new Float:SnakeUsedTime[SH_MAXSLOTS+1]
#endif
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Snake", "1.2", "Taker")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("snake_level", "0")
	register_cvar("snake_health", "125")
	register_cvar("snake_armor", "125")
	
#if USP_AND_XTRA_DAMAGE
	register_cvar("snake_uspmult", "2.0")
#endif
	
	register_cvar("snake_healpoints", "75")
	
#if SEND_COOLDOWN
	snake_cooldown = register_cvar("snake_cooldown", "20")
#endif

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
#if USP_AND_XTRA_DAMAGE
	shCreateHero(gHeroName, "Health Rations & USP", "Free Armor, Free Powerful USP, and Health Rations on power key use.", true, "snake_level")
#else
	shCreateHero(gHeroName, "Health Rations", "Health Rations on +power key use", true, "snake_level")
#endif
	
	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("snake_init", "snake_init")
	shRegHeroInit(gHeroName, "snake_init")

	// KEYDOWN
	register_srvcmd("snake_kd", "snake_kd")
	shRegKeyDown(gHeroName, "snake_kd")

	// NEW ROUND
	register_event("ResetHUD", "newSpawn", "b")

#if USP_AND_XTRA_DAMAGE
	// EXTRA DAMAGE
	register_event("Damage", "snake_damage", "b", "2!0")
#endif

	// Let Server know about Snakes Variable
	shSetMaxHealth(gHeroName, "snake_health")
	shSetMaxArmor(gHeroName, "snake_armor")

	gHealPoints = get_cvar_num("snake_healpoints")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound(gSnakeSound)
}
//----------------------------------------------------------------------------------------------
#if SEND_COOLDOWN
public sendSnakeCooldown(id)
{
	new cooldown
	if (gPlayerUltimateUsed[id])
		cooldown = floatround( get_pcvar_num(snake_cooldown) - get_gametime() + SnakeUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
//----------------------------------------------------------------------------------------------
public snake_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	if ( is_user_alive(id) ) {
		if ( hasPowers ) {
			#if USP_AND_XTRA_DAMAGE
				snake_weapons(id)
			#endif
		}
		// This gets run if they had the power but don't anymore
		else if ( !hasPowers && gHasSnakePower[id] ) {
			#if USP_AND_XTRA_DAMAGE
			if ( get_user_team(id) == 1 ) {
				engclient_cmd(id, "drop", "weapon_usp")
			}
			#endif
			
			shRemHealthPower(id)
			shRemArmorPower(id)
		}
	}

	// Sets this variable to the current status
	gHasSnakePower[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if ( shModActive() && gHasSnakePower[id] && is_user_alive(id) ) {
		#if USP_AND_XTRA_DAMAGE
			set_task(0.1, "snake_weapons", id)
		#endif

		gPlayerUltimateUsed[id] = false
	}
}
//----------------------------------------------------------------------------------------------
#if USP_AND_XTRA_DAMAGE
public snake_weapons(id)
{
	// No need to give a USP to a CT
	if ( is_user_alive(id) && get_user_team(id) == 1) {
		shGiveWeapon(id,"weapon_usp")
	}
}
#endif
//----------------------------------------------------------------------------------------------
public snake_kd()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	if ( !is_user_alive(id) || !gHasSnakePower[id] ) return

	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		return
	}

	sh_add_hp(id, gHealPoints)
	emit_sound(id, CHAN_AUTO, gSnakeSound, VOL_NORM, ATTN_NORM, 0, PITCH_LOW)
	snake_glow(id)
	set_task(0.7, "snake_unglow", id * 10000 + 2874)
	sh_screen_fade(id, 0.25, 0.125, 10, 255, 10, 70)	// Green Screen Flash

	if ( get_cvar_float("snake_cooldown") > 0.0 ) ultimateTimer(id, get_cvar_float("snake_cooldown"))
	
	#if SEND_COOLDOWN
	SnakeUsedTime[id] = get_gametime()
	#endif

	// Snake Messsage
	//new message[128]
	//format(message, 127, "%L", id, "SNAKE_RATION_USED")
	//set_hudmessage(255, 0, 0, -1.0, 0.3, 0, 0.25, 1.0, 0.0, 0.0, 26)
	//show_hudmessage(id, message)
}
//----------------------------------------------------------------------------------------------
public snake_glow(id)
{
	new Float:takeDamage
	pev(id, pev_takedamage, takeDamage)
	if ( takeDamage == DAMAGE_NO ) return
	
	sh_set_rendering( id, 0, 128, 0, 16, kRenderFxGlowShell )
}
//----------------------------------------------------------------------------------------------
public snake_unglow(task_id)
{
	new id = task_id / 10000
	new Float:takeDamage
	pev(id, pev_takedamage, takeDamage)
	if ( takeDamage == DAMAGE_NO && is_user_alive(id) ) return
	
	sh_set_rendering(id)
}
//----------------------------------------------------------------------------------------------
#if USP_AND_XTRA_DAMAGE
public snake_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasSnakePower[attacker] && weapon == CSW_USP && is_user_alive(id) ) {
		new extraDamage = floatround(damage * get_cvar_float("snake_uspmult") - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "usp", headshot)
	}
}
#endif
//----------------------------------------------------------------------------------------------