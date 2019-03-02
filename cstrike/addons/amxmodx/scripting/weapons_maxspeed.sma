// 19 dec 2018 - edited by evileye <http://evileye.eu.org>
// * Now it works with zoomed sniper rifles too
// * amx_weapon_maxspeed_multiplier cvar has been added

/*	Formatright © 2010, ConnorMcLeod

	This plugin is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this plugin; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#define VERSION "0.0.5"
#define PLUGIN "Weapons MaxSpeed"

#define MAX_WEAPONS CSW_P90

#define XO_WEAPON 4
#define m_pPlayer 41
#define m_iId 43

#define XO_PLAYER 5
#define m_iFOV 363
#define OFFSET_SHIELD 510
#define HAS_SHIELD  (1<<24)
#define USES_SHIELD  (1<<16)
const HAS_AND_USES_SHIELD = HAS_SHIELD|USES_SHIELD

#define SHIELD_WEAPONS_BITSUM ((1<<CSW_P228)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE)|(1<<CSW_KNIFE))

enum _:MaxSpeedType {
	Float:DefaultMaxSpeed,
	Float:ZoomedMaxSpeed,
	Float:ShieldMaxSpeed
}

new HamHook:g_iHhForwards[MAX_WEAPONS+1]
new Float:g_flMaxSpeed[MAX_WEAPONS+1][MaxSpeedType]
new pCvar_Multiplier
new Float:multiplier

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, "ConnorMcLeod")

	register_concmd("amx_weapon_maxspeed", "ConsoleCommand_WeaponSpeed", ADMIN_CFG, "<weapon shortname> <maxspeed> [zoom maxspeed] [shield maxspeed]")
	register_logevent("EventRoundStart", 2, "1=Round_Start")
	pCvar_Multiplier = register_cvar("amx_weapon_maxspeed_multiplier", "1.0")
	
	// This plugin is great but it doesn't work with zoom. Let's fix it.
	// People who use Scout, SG550, AWP, and G3SG1 want to run fast as well!
	register_event("CurWeapon", "SetZoomedMaxSpeed", "be", "1=1", "2=3", "2=13", "2=18", "2=24")
}

public EventRoundStart( )
{
	multiplier = get_pcvar_float(pCvar_Multiplier)
}

public SetZoomedMaxSpeed(id)
{
	new wID = get_user_weapon(id)
	new Float:defaultMaxSpeed
	switch (wID)
	{
		case 3: 		 defaultMaxSpeed = 220.0	// Scout
		case 13, 18, 24: defaultMaxSpeed = 150.0	// SG550, AWP, GS3SG1
		// We'll need these default values to check if we are zooming
	}
	if ( get_user_maxspeed(id) == defaultMaxSpeed ) // Are we zooming?
		set_user_maxspeed( id, g_flMaxSpeed[wID][ZoomedMaxSpeed] * multiplier ) // Then set new maxspeed
}

public ConsoleCommand_WeaponSpeed(id, lvl, cid)
{
	if( cmd_access(id, lvl, cid, 2) )
	{
		new szWeapon[32] = "weapon_"
		read_argv(1, szWeapon[7], charsmax(szWeapon)-7)

		new iId = get_weaponid(szWeapon)

		if( iId )
		{
			new iArgs = read_argc()
			if( iArgs == 2 )
			{
				Get_Weapon_State(id, iId, szWeapon)
				return PLUGIN_HANDLED
			}

			new szMaxSpeed[5]
			read_argv(2, szMaxSpeed, charsmax(szMaxSpeed))
			g_flMaxSpeed[iId][DefaultMaxSpeed] = floatmax(str_to_float(szMaxSpeed), 0.0)
			if( !g_flMaxSpeed[iId][DefaultMaxSpeed] )
			{
				if( g_iHhForwards[iId] )
				{
					DisableHamForward( g_iHhForwards[iId] )
					Get_Weapon_State(id, iId, szWeapon)
				}
				return PLUGIN_HANDLED
			}

			if( iArgs > 3 )
			{
				read_argv(3, szMaxSpeed, charsmax(szMaxSpeed))
				g_flMaxSpeed[iId][ZoomedMaxSpeed] = floatmax(str_to_float(szMaxSpeed), 0.0)
			}
			else
			{
				g_flMaxSpeed[iId][ZoomedMaxSpeed] = 0.0
			}

			if( iArgs > 4 && SHIELD_WEAPONS_BITSUM & 1<<iId )
			{
				read_argv(4, szMaxSpeed, charsmax(szMaxSpeed))
				g_flMaxSpeed[iId][ShieldMaxSpeed] = floatmax(str_to_float(szMaxSpeed), 0.0)
			}
			else
			{
				g_flMaxSpeed[iId][ShieldMaxSpeed] = 0.0
			}

			if( g_iHhForwards[iId] )
			{
				EnableHamForward( g_iHhForwards[iId] )
			}
			else
			{
				RegisterHam(Ham_CS_Item_GetMaxSpeed, szWeapon, "Item_GetMaxSpeed")
			}
			Get_Weapon_State(id, iId, szWeapon)
		}
	}
	return PLUGIN_HANDLED
}

Get_Weapon_State(id, iId, szWeapon[])
{
	if( !g_flMaxSpeed[iId][DefaultMaxSpeed] )
	{
		// console_print(id, "%s maxspeed is default, plugin is not active on this weapon", szWeapon)
	}
	else
	{
		// console_print(id, "%s maxspeed is %.1f", szWeapon, g_flMaxSpeed[iId][DefaultMaxSpeed])
		if( g_flMaxSpeed[iId][ZoomedMaxSpeed] )
		{
			// console_print(id, "%s zoomed maxspeed is %.1f", szWeapon, g_flMaxSpeed[iId][ZoomedMaxSpeed])
		}
		if( g_flMaxSpeed[iId][ShieldMaxSpeed] )
		{
			// console_print(id, "%s shield maxspeed is %.1f", szWeapon, g_flMaxSpeed[iId][ShieldMaxSpeed])
		}
	}
}

public Item_GetMaxSpeed( iWeapon )
{
	new iId = get_pdata_int(iWeapon, m_iId, XO_WEAPON)

	// alter m_flWeaponSpeed would be less efficient
	if(	g_flMaxSpeed[iId][ShieldMaxSpeed]
	&&	get_pdata_int(get_pdata_cbase(iWeapon, m_pPlayer, XO_WEAPON), OFFSET_SHIELD, XO_PLAYER) & HAS_AND_USES_SHIELD == HAS_AND_USES_SHIELD	)
	{
		SetHamReturnFloat( g_flMaxSpeed[iId][ShieldMaxSpeed] * multiplier )
	}
	else if(	g_flMaxSpeed[iId][ZoomedMaxSpeed]
	&&			get_pdata_int(get_pdata_cbase(iWeapon, m_pPlayer, XO_WEAPON), m_iFOV, XO_PLAYER) != 90	)
	{
		SetHamReturnFloat( g_flMaxSpeed[iId][ZoomedMaxSpeed] * multiplier )
	}
	else
	{
		SetHamReturnFloat( g_flMaxSpeed[iId][DefaultMaxSpeed] * multiplier )
	}
	return HAM_SUPERCEDE
}
