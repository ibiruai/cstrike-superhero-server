// JUBILEE! - from x-men, has pyrokinetic ability like fireworks and she always wears sunglasses

/* CVARS - copy and paste to shconfig.cfg

//Jubilee
jubilee_level 5
jubilee_time 10				//time the power is active in seconds
jubilee_brightness 50			//how well you can see with shades 0 is perfect 200 is dark
jubilee_cooldown 30				//ammount of time in seconds before allowed to use the power again
jubilee_flash 10				//give her free flashbangs? 0=no. 1+ = time delay

*/

//---------- User Changeable Defines --------//


// 1 = send another plugins information about cooldown, 0 = don't send
#define SEND_COOLDOWN 1


//------- Do not edit below this point ------//

#include <amxmodx>
#include <superheromod>

new gHeroName[]="Jubilee"
new gmsgScreenFade, gBrightness
new bool:gHasJubileePower[SH_MAXSLOTS+1]
new bool:gUsingShades[SH_MAXSLOTS+1]
#define AMMOX_FLASHBANG 11
new gPcvarCooldown
#if SEND_COOLDOWN
new Float:PowerUsedTime[SH_MAXSLOTS+1]
#endif
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Jubilee","1.1","SRGrty / JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("jubilee_level", "5")
	register_cvar("jubilee_time", "10")
	register_cvar("jubilee_brightness", "50")
	gPcvarCooldown = register_cvar("jubilee_cooldown", "30")
	register_cvar("jubilee_flash", "10")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Pink Shades", "Use Shades for protection from bright flashes", true, "jubilee_level" )

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_srvcmd("jubilee_init", "jubilee_init")
	shRegHeroInit(gHeroName, "jubilee_init")
	register_event("ResetHUD","newRound","b")

	// KEYDOWN
	register_srvcmd("jubilee_kd", "jubilee_kd")
	shRegKeyDown(gHeroName, "jubilee_kd")
	
	//Find Thrown Grenades
	register_event( "AmmoX", "on_AmmoX", "b" )

	gmsgScreenFade = get_user_msgid("ScreenFade")
	gBrightness = get_cvar_num("jubilee_brightness")

	// LOOP
	set_task(0.1,"jubilee_loop",0,"",0,"b")
}
//----------------------------------------------------------------------------------------------
public jubilee_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has Jubilee powers
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	gHasJubileePower[id] = (hasPowers != 0)
	gUsingShades[id] = false

	if ( gHasJubileePower[id] && is_user_alive(id) ) {
		give_flash(id)
	}
	
	//Load CVAR to make sure we have the right value
	gBrightness = get_cvar_num("jubilee_brightness")
	if (gBrightness < 0) gBrightness = 0
	if (gBrightness > 200) gBrightness = 200
}
//----------------------------------------------------------------------------------------------
#if SEND_COOLDOWN
public sendJubileeCooldown(id)
{
	new cooldown
	if (gPlayerInCooldown[id])
		cooldown = floatround( get_pcvar_num(gPcvarCooldown) - get_gametime() + PowerUsedTime[id] + 0.4 )
	else
		cooldown = -1
	return cooldown
}
#endif
//----------------------------------------------------------------------------------------------
public jubilee_kd()
{
	// First Argument is an id with Jubilee Powers!
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// Let them know they already used their ultimate if they have
	if ( gPlayerUltimateUsed[id] || gUsingShades[id] ) {
		playSoundDenySelect(id)
		return PLUGIN_HANDLED
	}
	/*
	new Float:JubileeCooldown = get_cvar_float("jubilee_cooldown")
	if ( JubileeCooldown > 0.0 )ultimateTimer(id, JubileeCooldown )
	*/	

	gUsingShades[id] = true
	set_task(get_cvar_float("jubilee_time"),"shades_off",id)
	set_task(get_cvar_float("jubilee_time"),"shades_cooldown",id)

	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public shades_cooldown(id)
{
	
	new Float:JubileeCooldown = get_cvar_float("jubilee_cooldown")
	if ( JubileeCooldown > 0.0 )ultimateTimer(id, JubileeCooldown )
	
	#if SEND_COOLDOWN
	PowerUsedTime[id] = get_gametime()
	#endif	
}
//----------------------------------------------------------------------------------------------
public shades_off(id)
{
	gUsingShades[id] = false
	setScreenFlash(id, 0, 0, 0, 1, 0)
}
//----------------------------------------------------------------------------------------------
public jubilee_loop()
{
	new players[32], pnum, id
	get_players(players,pnum,"c")
	for ( new i = 0; i < pnum; i++ ) {
		id = players[i]
		if ( gHasJubileePower[id] && gUsingShades[id] && is_user_alive(id) ) {
			message_begin(MSG_ONE,gmsgScreenFade,{0,0,0},id)
			write_short( 15 )
			write_short( 15 )
			write_short( 12 )
			write_byte( 245 )
			write_byte( 0 )
			write_byte( 160 )
			write_byte( gBrightness )
			message_end()
		}
	}
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	gPlayerUltimateUsed[id] = false
	gUsingShades[id] = false

	if (gHasJubileePower[id]) {
		remove_task(id)
		shades_off(id)
		give_flash(id)
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public give_flash(id)
{
	if ( is_user_alive(id) && gHasJubileePower[id] && shModActive() ) {
		shGiveWeapon(id, "weapon_flashbang" )
	}
}
//----------------------------------------------------------------------------------------------
public on_AmmoX(id)
{
	if ( !shModActive() ) return
	if ( id <= 0 || id > SH_MAXSLOTS) return
	if ( !is_user_alive(id) || !is_user_connected(id) ) return

	new Float:FlashTimer = get_cvar_float("jubilee_flash")
	if ( FlashTimer <= 0.0 ) return

	new iAmmoType = read_data(1)
	new iAmmoCount = read_data(2)

	if ( iAmmoType == AMMOX_FLASHBANG && iAmmoCount == 0 && gHasJubileePower[id]) {
		set_task( FlashTimer, "give_flash", id )
	}
}
//----------------------------------------------------------------------------------------------