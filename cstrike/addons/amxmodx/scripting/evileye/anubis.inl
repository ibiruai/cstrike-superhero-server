#include <fakemeta_util>

new gMsgSync1[SH_MAXSLOTS+1]
new gMsgSync2[SH_MAXSLOTS+1]
new anubisShWeaponDamage[SH_MAXSLOTS+1]		// How many weapon extra damage victim got
new anubisShPowerDamage[SH_MAXSLOTS+1]		// How many damage attacker dealt with superpower
new anubisShPower[SH_MAXSLOTS+1][32]		// Last power attacker used that dealt damage
//---------------------------------------------------------------------------------------------
public anubis_init()
{
	register_event("Damage", "show_weapon_damage", "b", "2!0", "3=0", "4!0")
	for (new i = 0; i < SH_MAXSLOTS + 1; i++)
	{
		gMsgSync1[i] = CreateHudSyncObj() 
		gMsgSync2[i] = CreateHudSyncObj()
	}
}
//---------------------------------------------------------------------------------------------
public show_damage(victim, attacker, damage, wpnDescription[32])
{
	// List of weapons
	new allWeapons[29][32] = {"p228", "scout", "hegrenade", "xm1014", "c4", "mac10", "aug", "smokegrenade", "elite", "fiveseven", "ump45", "sg550", "galil", "famas", "usp", "glock18", "awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1", "flashbang", "deagle", "sg552", "ak47", "knife", "p90"}	

	// Does attacker uses a weapon or a superpower?
	new bool:flag = false
	for (new i = 0; i < 29; i++)
		if ( equal(wpnDescription, allWeapons[i]) )
			flag = true
		
	// It is Weapon Extra damage
	if ( flag )
		// This extra damage will be displayed by show_weapon_damage()	
		anubisShWeaponDamage[victim] += damage
		
	// It is Superpower damage
	else
	{
		// Show superhero damage for attacker
		if ( victim != attacker )
		{
			// If attacker damaged multiple victims we should show them all damage they dealt to their victims!
			
			// Sometimes a player may use their powers simultaneously. We should differ dealt damage and not sum up damage that dealt with different powers.
			if (anubisShPowerDamage[attacker] && !equal(wpnDescription, anubisShPower[attacker]))
			{
				anubisShPowerDamage[attacker] = 0
			}
			
			anubisShPowerDamage[attacker] += damage 	// Sum up damage in case an attacker attacked multiple victims
			anubisShPower[attacker] = wpnDescription	// Remember a power name to check if player used more than one power simultaneously.
			
			if (anubisShPowerDamage[attacker] != 0)
			{
				if  ( !(gPlayerFlags[attacker] & SH_FLAG_NODMGDISPLAY) )
				{
					set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 2.0, 0.02, 0.02, 71)
					ShowSyncHudMsg(attacker, gMsgSync1[attacker], "%d %s", anubisShPowerDamage[attacker], wpnDescription)
				}
			}
			
			// We showed superhero damage. Now let's set this to zero
			// We need to wait a little in case attacker dealt AOE damage to multiple victims
			set_task(0.0001, "set_anubisShPowerDamage_to_zero", attacker)
		}
		
		// Show superhero damage for victim
		if ( !(gPlayerFlags[victim] & SH_FLAG_NODMGDISPLAY) )
		{
			set_hudmessage(200, 0, 0, -1.0, 0.415, 2, 0.1, 2.0, 0.02, 0.02, 72)
			ShowSyncHudMsg(victim, gMsgSync2[victim], "%d %s", damage, wpnDescription)
		}
	}
}
//---------------------------------------------------------------------------------------------
public set_anubisShPowerDamage_to_zero(attacker)
{
	anubisShPowerDamage[attacker] = 0
}
//---------------------------------------------------------------------------------------------
public show_weapon_damage(victim)	// Somebody damaged victim with a weapon
{
	new attacker = get_user_attacker(victim)
	new damage = read_data(2)
	new parameters[3]
	parameters[0] = attacker
	parameters[1] = damage
	
	// Wait for weapon extra damage information from anubisShWeaponDamage[id]
	set_task(0.0001, "show_weapon_damage_task", victim, parameters, 2)
}
//---------------------------------------------------------------------------------------------
public show_weapon_damage_task(parameters[3], victim)
{
	new attacker = parameters[0]
	new damage = parameters[1]
	new is_extradamage[8]
	
	if (anubisShWeaponDamage[victim])
		format(is_extradamage, 8, " + %i", anubisShWeaponDamage[victim])
	else
		is_extradamage = ""
	
	// Show weapon damage + weapon extra damage for victim
	if ( !(gPlayerFlags[victim] & SH_FLAG_NODMGDISPLAY) )
	{
		set_hudmessage(200, 0, 0, -1.0, 0.415, 2, 0.1, 2.0, 0.02, 0.02, 72)
		ShowSyncHudMsg(victim, gMsgSync2[victim], "%i%s^n", damage, is_extradamage)
	}
	
	// Show weapon damage + weapon extra damage for attacker
	if( is_user_connected(attacker) && !(gPlayerFlags[attacker] & SH_FLAG_NODMGDISPLAY) )
	{
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 2.0, 0.02, 0.02, 71)
		ShowSyncHudMsg(attacker, gMsgSync1[attacker], "%i%s^n", damage, is_extradamage)
	}
	
	anubisShWeaponDamage[victim] = 0		// We showed extra damage. Now let's set this to zero
}
//---------------------------------------------------------------------------------------------