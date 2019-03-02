/* AMX Mod X script.
*
*   SuperHero Monitor (sh_monitor.sma)
*   Copyright (C) 2006 vittu
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
****************************************************************************
*
*               ******** AMX Mod X 1.80 and above Only ********
*               ***** SuperHero Mod 1.2.0 and above Only ******
*               *** Must be loaded after SuperHero Mod core ***
*
*  Description:
*     This plugin will display a hud message to the user showing their true
*      current health and armor just above chat messages. Might possibly
*      add other things into the message in the future, suggestions?
*
*  Why:
*     When a users health is over 255 in the HUD it loops over again
*      starting from 0. When a users armor is over 999 it does not show the
*      correct number rather it shows a hud symbol and the last few digits.
*
*  Who:
*     This plugin is intended for SuperHero Mod servers that have heroes that
*      make it possible to have more then 255 hp or more then 999 armor.
*
*  Known Issues:
*     If using the REPLACE_HUD option, clients radar is also removed from the
*      hud. If lots of hud messages are being displayed at the same time the
*      monitor may flash briefly, but does not happen enough to be concerned.
*
****************************************************************************
*
*  http://shero.rocks-hideout.com/
*
*  Notes: Currently there are no cvars, message will not display when sh mod is off.
*          However, loop will still run incase shmod is enabled again. Plugin tested
*          at 800x600 to 1280x1024.
*
*  Changelog:
*   v1.5 - vittu - 10/28/10
*	    - Fixed possible issue with get_players array size.
*
*   v1.4 - vittu - 10/19/09
*	    - Changed to make each item optional
*	    - Added option to show when godmode is on
*	    - Added option to show information of player being spectated (similar to wc3ft)
*	    (Update required use of SuperHero Mod 1.2.0 or above, also made the code ugly.)
*
*   v1.3 - vittu - 07/06/07
*	    - Fixed bug forgot to make sure entity was valid in think forward
*           - Added requested option to show Gravity and Speed, set as disabled define because it
*              gets checked constantly
*
*   v1.2 - vittu - 06/13/07
*	    - Conversion to Fakemeta
*           - Optimization of code all around, much improved
*
*   v1.1 - vittu - 06/11/06
*	    - Used a hud sync object instead of taking up a single hud channel (suggested by jtp10181)
*	    - Added option to remove the hud's hp/ap and place message there (suggested by Freecode)
*
*   v1.0 - vittu - 06/05/06
*	    - Initial Release
*
*  Thanks:
*	    - OneEyed for the basis of an entity as a task
*
*  To-Do:
*	    - Possibly add other features instead of just HP/AP display,
*              ie. secondary message showing info of user you aim at
*           - Maybe add a file to allow user to save location of message
*           - Maybe add a check to verify users xp has loaded to show spec info (requires change in SH core)
*
****************************************************************************/

/****** Changeable defines requie recompile *******/


/********* Uncomment to replace HUD hp/ap **********/
//#define REPLACE_HUD

/********* Uncomment the ones you want to display **********/
#define MONITOR_HP
#define MONITOR_AP
//#define MONITOR_GRAVITY
//#define MONITOR_SPEED
//#define MONITOR_GODMODE
#define MONITOR_SPEC


/************* Do Not Edit Below Here **************/


#include <superheromod>

#if defined MONITOR_HP || defined MONITOR_SPEC
	new UserHealth[SH_MAXSLOTS+1]
#endif

#if defined MONITOR_AP || defined MONITOR_SPEC
	new UserArmor[SH_MAXSLOTS+1]
#endif

#if defined MONITOR_SPEC
	new ServerMaxLevel
#endif

#if defined REPLACE_HUD
	new MsgHideWeapon
	#define HIDE_HUD_HEALTH (1<<3)
#endif

new MonitorHudSync
new const TaskClassname[] = "monitorloop"
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	register_plugin("SuperHero Monitor", "1.5", "vittu")

	#if defined MONITOR_HP || defined MONITOR_SPEC
		register_event("Health", "health_change", "b")
	#endif

	#if defined MONITOR_AP || defined MONITOR_SPEC
		register_event("Battery", "armor_change", "b")
	#endif

	#if defined REPLACE_HUD
		MsgHideWeapon = get_user_msgid("HideWeapon")
		register_message(MsgHideWeapon, "msg_hideweapon")
	#endif

	MonitorHudSync = CreateHudSyncObj()

	new monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if ( monitor )
	{
		set_pev(monitor, pev_classname, TaskClassname)
		set_pev(monitor, pev_nextthink, get_gametime() + 0.1)
		register_forward(FM_Think, "monitor_think")
	}
}
//----------------------------------------------------------------------------------------------
#if defined MONITOR_SPEC
public plugin_cfg()
{
	ServerMaxLevel = sh_get_num_lvls()
}
#endif
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( !sh_is_active() || !is_user_alive(id) ) return

	#if !defined MONITOR_SPEC
		if ( is_user_bot(id) ) return
	#endif

	// Check varibles initially when spawned, mainly so hp doesn't start at 0
	#if defined MONITOR_HP || defined MONITOR_SPEC
		UserHealth[id] = get_user_health(id)
	#endif
	#if defined MONITOR_AP || defined MONITOR_SPEC
		UserArmor[id] = get_user_armor(id)
	#endif

	#if defined REPLACE_HUD
		#if defined MONITOR_SPEC
			if ( !is_user_bot(id) )
			{
		#endif
				// Remove HP and AP from screen, however radar is removed aswell
				message_begin(MSG_ONE_UNRELIABLE, MsgHideWeapon, _, id)
				write_byte(HIDE_HUD_HEALTH)
				message_end()
		#if defined MONITOR_SPEC
			}
		#endif
	#endif
}
//----------------------------------------------------------------------------------------------
#if defined MONITOR_HP || defined MONITOR_SPEC
public health_change(id)
{
	if ( !sh_is_active() || !is_user_alive(id) ) return

	#if !defined MONITOR_SPEC
		if ( is_user_bot(id) ) return
	#endif

	UserHealth[id] = read_data(1)
}
#endif
//----------------------------------------------------------------------------------------------
#if defined MONITOR_AP || defined MONITOR_SPEC
public armor_change(id)
{
	if ( !sh_is_active() || !is_user_alive(id) ) return

	#if !defined MONITOR_SPEC
		if ( is_user_bot(id) ) return
	#endif

	UserArmor[id] = read_data(1)
}
#endif
//----------------------------------------------------------------------------------------------
public monitor_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED

	static class[32]
	pev(ent, pev_classname, class, charsmax(class))

	if ( equal(class, TaskClassname) )
	{
		if ( sh_is_active() )
		{
			#if defined MONITOR_SPEED || defined MONITOR_SPEC
				static Float:velocity[3]
			#endif
			#if defined MONITOR_GRAVITY || defined MONITOR_SPEC
				static Float:gravity
			#endif
			#if defined MONITOR_GODMODE
				static Float:takeDamage
			#endif

			#if defined MONITOR_SPEC
				static specPlayer, specPlayerLevel
			#endif

			#if defined MONITOR_HP || defined MONITOR_AP || defined MONITOR_GRAVITY || defined MONITOR_SPEED || defined MONITOR_GODMODE
				static len
			#endif

			static players[32], count, i, id
			static temp[128]
			get_players(players, count, "ch")

			for ( i = 0; i < count; i++ )
			{
				id = players[i]
				temp[0] = '^0'

				if ( is_user_alive(id) )
				{
					#if defined MONITOR_HP || defined MONITOR_AP || defined MONITOR_GRAVITY || defined MONITOR_SPEED || defined MONITOR_GODMODE
						len = 0
						#if defined MONITOR_HP
							len += formatex(temp, charsmax(temp), "HP %d", UserHealth[id])
						#endif

						#if defined MONITOR_AP
							#if defined MONITOR_HP
								len += formatex(temp[len], charsmax(temp) - len, "  |  ")
							#endif

							len += formatex(temp[len], charsmax(temp) - len, "AP %d", UserArmor[id])
						#endif

						#if defined MONITOR_GRAVITY
							#if defined MONITOR_HP || defined MONITOR_AP
								len += formatex(temp[len], charsmax(temp) - len, "  |  ")
							#endif

							pev(id, pev_gravity, gravity)
							len += formatex(temp[len], charsmax(temp) - len, "G %d%%", floatround(gravity*100.0))
						#endif

						#if defined MONITOR_SPEED
							#if defined MONITOR_HP || defined MONITOR_AP || defined MONITOR_GRAVITY
								len += formatex(temp[len], charsmax(temp) - len, "  |  ")
							#endif

							pev(id, pev_velocity, velocity)
							len += formatex(temp[len], charsmax(temp) - len, "SPD %d", floatround(vector_length(velocity)) )
						#endif

						#if defined MONITOR_GODMODE
							pev(id, pev_takedamage, takeDamage)
							
							// GODMODE will only show if godmode is on
							if ( takeDamage == DAMAGE_NO )
							{
								#if defined MONITOR_HP || defined MONITOR_AP || defined MONITOR_GRAVITY || defined MONITOR_SPEED
									len += formatex(temp[len], charsmax(temp) - len, "  |  ")
								#endif
								formatex(temp[len], charsmax(temp) - len, "GODMODE")
							}
						#endif

						// Sets Y location
						#if defined REPLACE_HUD
							set_hudmessage(255, 180, 0, 0.02, 0.97, 0, 0.0, 0.3, 0.0, 0.0)
						#else
							set_hudmessage(255, 180, 0, 0.02, 0.73, 0, 0.0, 0.3, 0.0, 0.0)
						#endif

						ShowSyncHudMsg(id, MonitorHudSync, "[SH]  %s", temp)
					#endif
				}
				#if defined MONITOR_SPEC
					else
					{
						// Who is the id specing
						specPlayer = pev(id, pev_iuser2)

						if ( !specPlayer || id == specPlayer ) continue

						pev(specPlayer, pev_velocity, velocity)
						pev(specPlayer, pev_gravity, gravity)
						specPlayerLevel = sh_get_user_lvl(specPlayer)

						if ( specPlayerLevel < ServerMaxLevel ) {
							formatex(temp, charsmax(temp), "/%d", sh_get_lvl_xp(specPlayerLevel+1))
						}

						set_hudmessage(255, 255, 255, 0.018, 0.9, 2, 0.05, 0.1, 0.01, 3.0)
						ShowSyncHudMsg(id, MonitorHudSync, "[SH] Level: %d/%d  |  XP: %d%s^nHealth: %d  |  Armor: %d^nGravity: %d%%  |  Speed: %d", specPlayerLevel, ServerMaxLevel, sh_get_user_xp(specPlayer), temp, UserHealth[specPlayer], UserArmor[specPlayer], floatround(gravity*100.0), floatround(vector_length(velocity)))
					}
				#endif
			}

		}

		// Keep monitorloop active even if shmod is not, incase sh is turned back on
		set_pev(ent, pev_nextthink, get_gametime() + 0.1)
	}

	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
#if defined REPLACE_HUD
public msg_hideweapon()
{
	if ( !sh_is_active() ) return

	// Block HP/AP/Radar if not being blocked, must block all 3 can not individually be done
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | HIDE_HUD_HEALTH)
}
//----------------------------------------------------------------------------------------------
#endif