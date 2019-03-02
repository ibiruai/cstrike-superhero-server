/*	Formatright © 2016, Freeman

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

/* CVARS - Tips: copy and paste to amxx.cfg

//
// CS AFK Manager
//

// Time in seconds that a client can be AFK before being able to trigger AFK global messages
// AFK gobal messages are displayed to a team when all the enemies of the opposing team are AFK
// Set this cvar to 0 to disable the display of AFK global messages
// Default value: 10
afk_global_messages_away_time 10

// AFK bomb management action:
// 2 - transfer the bomb from the AFK bomb carrier to the nearest non-AFK terrorist
// 1 - force the AFK bomb carrier to drop the bomb
// 0 - do nothing with the bomb
// Default value: 2
afk_bomb_action 2

// Time in seconds that a client can have the bomb when being AFK
// Default value: 10
afk_bomb_action_time 10

// Time in seconds that an alive client or a client in appearance select menu can be AFK before he will be transferred to the spectator team
// Set this cvar to 0 to disable this feature and enable AFK kick management in replacement (if it's enabled)
// Default value: 90
afk_switch_to_spec_time 90

// Time in seconds that every clients can be AFK before being kicked
// Set this cvar to 0 to disable this feature
// Default value: 240
afk_kick_time 240

// (0|1) - If the AFK kick management is enabled, it kick spectators only if the server is full
// Default value: 1
afk_kick_spec_only_if_full 1

// This cvar control the full status, it only matters if afk_kick_spec_only_if_full is enabled
//    0    - server is full when Max_Clients - amx_reservation (default amxx cvar) is met
// 1 to 32 - server is full when Max_Clients - afk_full_minus_num is met
// Default value: 0
afk_full_minus_num 0

// (0|1) - Disable/Enable admin immunity for AFK bomb management
// Default value: 0
afk_bomb_management_immunity 0

// Flag(s) required to have immunity for AFK bomb management
// If multiple flags, admins must have them all
// Default value: "a"
afk_bomb_management_immunity_flag "a"

// (0|1) - Disable/Enable admin immunity for AFK spectator switch management
// Default value: 0
afk_switch_to_spec_immunity 0

// Flag(s) required to have immunity for AFK spectator switch management
// If multiple flags, admins must have them all
// Default value: "a"
afk_switch_to_spec_immunity_flag "a"

// (0|1) - Disable/Enable admin immunity for AFK kick management
// Default value: 0
afk_kick_immunity 0

// Flag(s) required to have immunity for AFK kick management
// If multiple flags, admins must have them all
// Default value: "a"
afk_kick_immunity_flag "a"

// Minimum players to get the plugin working
// Default value: 0
afk_min_players 0

// (0|1) - Disable/Enable check of view angle
// Default value: 0
afk_check_v_angle 0

// (0|1) - Disable/Enable colored messages
// Default value: 1
afk_colored_messages 1

// Advanced setting: Frequency at which the plugin loop
// This setting affect all the management
// Touch it only if you know what you are doing
// Default value: 1.0
afk_loop_frequency 1.0

*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"CS AFK Manager"
#define VERSION	"1.0.6 (amx 1.8.2)"
#define AUTHOR	"Freeman"

const Buttons = IN_ATTACK|IN_JUMP|IN_DUCK|IN_FORWARD|IN_BACK|IN_USE|IN_CANCEL|IN_LEFT|IN_RIGHT|IN_MOVELEFT|IN_MOVERIGHT|IN_ATTACK2|IN_RUN|IN_RELOAD|IN_ALT1|IN_SCORE

const MAXPLAYERS = 32
const MAX_NAMELENGTH = 32
const INT_BYTES = 4
const BYTE_BITS = 8
new Max_Clients

const m_iMenu = 205
const Menu_ChooseAppearance = 3
const m_bTeamChanged = 501
const MAX_ITEM_TYPES = 6
new const m_rgpPlayerItems[MAX_ITEM_TYPES] = { 367, 368, ... }

new bool:RoundFreeze
new Float:AfkTime[MAXPLAYERS+1]
new UserID[MAXPLAYERS+1]
new Float:ViewAngle[MAXPLAYERS+1][3]
new ViewAngleChanged
#define SetViewAngleChanged(%1)		ViewAngleChanged |= 1<<(%1&31)
#define RemoveViewAngleChanged(%1)	ViewAngleChanged &= ~(1<<(%1&31))
#define HasViewAngleChanged(%1)		ViewAngleChanged & 1<<(%1&31)

new PcvarGlobalMessagesAwayTime, PcvarBombAction, PcvarBombActionTime, PcvarSwitchToSpecTime, PcvarKickTime, PcvarKickSpecOnlyIfFull, PcvarFullMinusNum
new PcvarBombManagementImmunity, PcvarSwitchToSpecImmunity, PcvarKickImmunity, PcvarMinPlayers, PcvarLoopFrequency, PcvarAllowSpecators
new PcvarAmxReservation, PcvarBombManagementImmunityFlag, PcvarSwitchToSpecImmunityFlag, PcvarKickImmunityFlag, PcvarCheckViewAngle
new PcvarColoredMessages

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("afk_manager_version", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	register_dictionary("afk_manager.txt")

	PcvarGlobalMessagesAwayTime = register_cvar("afk_global_messages_away_time", "10")
	PcvarBombAction = register_cvar("afk_bomb_action", "2")
	PcvarBombActionTime = register_cvar("afk_bomb_action_time", "10")
	PcvarSwitchToSpecTime = register_cvar("afk_switch_to_spec_time", "90")
	PcvarKickTime = register_cvar("afk_kick_time", "240")
	PcvarKickSpecOnlyIfFull = register_cvar("afk_kick_spec_only_if_full", "1")
	PcvarFullMinusNum = register_cvar("afk_full_minus_num", "0")
	PcvarBombManagementImmunity = register_cvar("afk_bomb_management_immunity", "0")
	PcvarBombManagementImmunityFlag = register_cvar("afk_bomb_management_immunity_flag", "a")
	PcvarSwitchToSpecImmunity = register_cvar("afk_switch_to_spec_immunity", "0")
	PcvarSwitchToSpecImmunityFlag = register_cvar("afk_switch_to_spec_immunity_flag", "a")
	PcvarKickImmunity = register_cvar("afk_kick_immunity", "0")
	PcvarKickImmunityFlag = register_cvar("afk_kick_immunity_flag", "a")
	PcvarMinPlayers = register_cvar("afk_min_players", "0")
	PcvarCheckViewAngle = register_cvar("afk_check_v_angle", "0")
	PcvarColoredMessages = register_cvar("afk_colored_messages", "1")
	PcvarLoopFrequency = register_cvar("afk_loop_frequency", "1.0")
	PcvarAllowSpecators = get_cvar_pointer("allow_spectators")

	register_clcmd("chooseteam", "team_or_class_selected")
	register_clcmd("jointeam", "team_or_class_selected")
	register_clcmd("joinclass", "team_or_class_selected")
	register_menucmd(register_menuid("Team_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_5|MENU_KEY_6|MENU_KEY_0), "team_or_class_selected")
	register_menucmd(register_menuid("Terrorist_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6), "team_or_class_selected")
	register_menucmd(register_menuid("CT_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6), "team_or_class_selected")

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")	// New Round
	register_logevent("LogEvent_Round_Start", 2, "1=Round_Start")
	RegisterHam(Ham_Spawn, "player", "Ham_Player_Spawn_Post", .Post = true)

	Max_Clients = get_maxplayers()
}

public plugin_cfg()
{
	PcvarAmxReservation = get_cvar_pointer("amx_reservation")

	new Float:loop_frequency = get_pcvar_float(PcvarLoopFrequency)
	if ( loop_frequency < 1.0 )
	{
		loop_frequency = 1.0
		set_pcvar_float(PcvarLoopFrequency, loop_frequency)
	}

	new ent = create_entity("info_target")
	if ( ent )
	{
		entity_set_string(ent, EV_SZ_classname, "afk_manager_ent")
		register_think("afk_manager_ent", "afk_manager_loop")
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + loop_frequency)
	}
	else
	{
		set_task(loop_frequency, "afk_manager_loop", .flags = "b")
	}
}

public client_connect(id)
{
	UserID[id] = get_user_userid(id)
	AfkTime[id] = 0.0
}

public team_or_class_selected(id)
{
	AfkTime[id] = 0.0
}

public afk_manager_loop(ent)
{
	static Float:loop_frequency
	loop_frequency = get_pcvar_float(PcvarLoopFrequency)
	if ( ent )
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + loop_frequency)
	}

	static players[MAXPLAYERS], player_count
	get_players(players, player_count, "ch")

	if ( player_count < get_pcvar_num(PcvarMinPlayers) ) return

	static Float:global_messages_away_time, bomb_action, Float:afk_time, Float:bomb_action_time, Float:switch_to_spec_time, Float:kick_time 
	static kick_spec_only_if_full, bomb_management_immunity, switch_to_spec_immunity, kick_immunity, bomb_management_immunity_flag[27]
	static switch_to_spec_immunity_flag[27], kick_immunity_flag[27], allow_spectators, full_maxplayers, player, i, CsTeams:player_team
	static player_name[MAX_NAMELENGTH], players_num, terrorists[MAXPLAYERS], terrorist_count, terrorist, j, is_player_alive, deaths
	static bomb_receiver, bomb_receiver_name[MAX_NAMELENGTH], c4_ent, backpack, terrorists_afk, cts_afk, terrorists_not_afk
	static cts_not_afk, Float:player_origin[3], Float:terrorist_origin[3], Float:origins_distance, Float:shortest_distance
	static check_v_angle, Float:current_v_angle[3], last_kick_id, Float:last_kick_time, colored_messages

	global_messages_away_time = get_pcvar_float(PcvarGlobalMessagesAwayTime)
	bomb_action = get_pcvar_num(PcvarBombAction)
	bomb_action_time = get_pcvar_float(PcvarBombActionTime)
	switch_to_spec_time = get_pcvar_float(PcvarSwitchToSpecTime)
	kick_time = get_pcvar_float(PcvarKickTime)
	kick_spec_only_if_full = get_pcvar_num(PcvarKickSpecOnlyIfFull)
	bomb_management_immunity = get_pcvar_num(PcvarBombManagementImmunity)
	get_pcvar_string(PcvarBombManagementImmunityFlag, bomb_management_immunity_flag, charsmax(bomb_management_immunity_flag))
	switch_to_spec_immunity = get_pcvar_num(PcvarSwitchToSpecImmunity)
	get_pcvar_string(PcvarSwitchToSpecImmunityFlag, switch_to_spec_immunity_flag, charsmax(switch_to_spec_immunity_flag))
	kick_immunity = get_pcvar_num(PcvarKickImmunity)
	get_pcvar_string(PcvarKickImmunityFlag, kick_immunity_flag, charsmax(kick_immunity_flag))
	allow_spectators = get_pcvar_num(PcvarAllowSpecators)
	check_v_angle = get_pcvar_num(PcvarCheckViewAngle)
	colored_messages = get_pcvar_num(PcvarColoredMessages)
	full_maxplayers = get_pcvar_num(PcvarFullMinusNum)

	if ( full_maxplayers )
	{
		full_maxplayers = Max_Clients - full_maxplayers
	}
	else
	{
		if ( PcvarAmxReservation )
		{
			full_maxplayers = Max_Clients - get_pcvar_num(PcvarAmxReservation)
		}
		else
		{
			full_maxplayers = Max_Clients
		}
	}

	players_num = get_playersnum(1)
	terrorists_afk = 0
	cts_afk = 0
	terrorists_not_afk = 0
	cts_not_afk = 0
	last_kick_id = 0
	last_kick_time = 0.0

	for ( i = 0; i < player_count; i++ )
	{
		player = players[i]

		player_team = cs_get_user_team(player)
		switch(player_team)
		{
			case CS_TEAM_SPECTATOR, CS_TEAM_UNASSIGNED:
			{
				if ( kick_time > 0.0 )
				{
					if ( entity_get_int(player, EV_INT_button) & Buttons )
					{
						AfkTime[player] = 0.0
					}
					else
					{
						AfkTime[player] += loop_frequency
					}

					afk_time = AfkTime[player]

					if ( afk_time >= kick_time && ( !kick_immunity || !has_all_flags(player, kick_immunity_flag) ) && ( !kick_spec_only_if_full || players_num >= full_maxplayers ) )
					{
						if ( kick_spec_only_if_full )
						{
							if ( afk_time > last_kick_time )
							{
								last_kick_id = player
								last_kick_time = afk_time
							}
						}
						else
						{
							user_kick(player)
						}
					}
				}
			}
			case CS_TEAM_CT, CS_TEAM_T:
			{
				is_player_alive = is_user_alive(player)

				if ( ( !RoundFreeze && is_player_alive ) || get_pdata_int(player, m_iMenu) == Menu_ChooseAppearance )
				{
					if ( check_v_angle )
					{
						entity_get_vector(player, EV_VEC_v_angle, current_v_angle)
						if ( entity_get_int(player, EV_INT_button) & Buttons )
						{
							AfkTime[player] = 0.0
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
						 }
						else if ( HasViewAngleChanged(player) )
						{
							AfkTime[player] += loop_frequency
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
							RemoveViewAngleChanged(player)
						}
						else if ( ViewAngle[player][0] != current_v_angle[0] || ViewAngle[player][1] != current_v_angle[1] )
						{
							AfkTime[player] = 0.0
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
						}
						else
						{
							AfkTime[player] += loop_frequency
						}
					}
					else
					{
						if ( entity_get_int(player, EV_INT_button) & Buttons )
						{
							AfkTime[player] = 0.0
						}
						else
						{
							AfkTime[player] += loop_frequency
						}
					}

					afk_time = AfkTime[player]

					if ( global_messages_away_time > 0.0 && is_player_alive )
					{
						if ( afk_time >= global_messages_away_time )
						{
							if ( player_team == CS_TEAM_T )
							{
								terrorists_afk++
							}
							else
							{
								cts_afk++
							}
						}
						else
						{
							if ( player_team == CS_TEAM_T )
							{
								terrorists_not_afk++
							}
							else
							{
								cts_not_afk++
							}
						}
					}

					if ( 0 < bomb_action < 3 && afk_time >= bomb_action_time && user_has_weapon(player, CSW_C4) && ( !bomb_management_immunity || !has_all_flags(player, bomb_management_immunity_flag) ) )
					{
						get_players(terrorists, terrorist_count, "aceh", "TERRORIST")

						if ( terrorist_count > 1 )
						{
							if ( bomb_action == 2 )
							{
								bomb_receiver = 0
								shortest_distance = 999999.0
								entity_get_vector(player, EV_VEC_origin, player_origin)

								for ( j = 0; j < terrorist_count; j++ )
								{
									terrorist = terrorists[j]

									if ( terrorist != player && AfkTime[terrorist] < bomb_action_time )
									{
										entity_get_vector(terrorist, EV_VEC_origin, terrorist_origin)

										origins_distance = vector_distance(player_origin, terrorist_origin)

										if ( origins_distance < shortest_distance )
										{
											shortest_distance = origins_distance
											bomb_receiver = terrorist
										}
									}
								}
								if ( bomb_receiver )
								{
									c4_ent = get_pdata_cbase(player, m_rgpPlayerItems[5])
									if ( c4_ent > 0 )
									{
										engclient_cmd(player, "drop", "weapon_c4")

										backpack = entity_get_edict(c4_ent, EV_ENT_owner)

										if ( backpack > 0 && backpack != player )
										{
											entity_set_int(backpack, EV_INT_flags, entity_get_int(backpack, EV_INT_flags) | FL_ONGROUND)
											dllfunc(DLLFunc_Touch, backpack, bomb_receiver)

											get_user_name(player, player_name, charsmax(player_name))
											get_user_name(bomb_receiver, bomb_receiver_name, charsmax(bomb_receiver_name))

											if ( colored_messages )
											{
												for ( j = 0; j < terrorist_count; j++ )
												{
													terrorist = terrorists[j]

													if ( terrorist == bomb_receiver )
													{
														client_print_color(bomb_receiver, bomb_receiver, "%L", bomb_receiver, "COLORED_BOMB_GOT", player_name)
													}
													else
													{
														client_print_color(terrorist, terrorist, "%L", terrorist, "COLORED_BOMB_TRANSFERRED", bomb_receiver_name, player_name)
													}
												}
											}
											else
											{
												for ( j = 0; j < terrorist_count; j++ )
												{
													terrorist = terrorists[j]

													if ( terrorist == bomb_receiver )
													{
														client_print(bomb_receiver, print_chat, "%L", bomb_receiver, "BOMB_GOT", player_name)
													}
													else
													{
														client_print(terrorist, print_chat, "%L", terrorist, "BOMB_TRANSFERRED", bomb_receiver_name, player_name)
													}
												}
											}
										}
									}
								}
							}
							else
							{
								engclient_cmd(player, "drop", "weapon_c4")

								get_user_name(player, player_name, charsmax(player_name))

								if ( colored_messages )
								{
									for ( j = 0; j < terrorist_count; j++ )
									{
										terrorist = terrorists[j]

										client_print_color(terrorist, terrorist, "%L", terrorist, "COLORED_FORCED_TO_DROP", player_name)
									}
								}
								else
								{
									for ( j = 0; j < terrorist_count; j++ )
									{
										terrorist = terrorists[j]

										client_print(terrorist, print_chat, "%L", terrorist, "FORCED_TO_DROP", player_name)
									}
								}
							}
						}
					}
					if ( !cs_get_user_vip(player) )
					{
						if ( switch_to_spec_time > 0.0 )
						{
							if ( afk_time >= switch_to_spec_time && ( !switch_to_spec_immunity || !has_all_flags(player, switch_to_spec_immunity_flag) ) )
							{
								AfkTime[player] = 0.0

								get_user_name(player, player_name, charsmax(player_name))

								if ( colored_messages )
								{
									client_print_color(0, player, "%L", LANG_PLAYER, "COLORED_TRANSFERRED_TO_SPEC", player_name)
								}
								else
								{
									client_print(0, print_chat, "%L", LANG_PLAYER, "TRANSFERRED_TO_SPEC", player_name)
								}

								if ( is_player_alive )
								{
									deaths = cs_get_user_deaths(player)
									user_kill(player, 1)
									cs_set_user_deaths(player, deaths)
								}

								if ( allow_spectators != 1 )
								{
									set_pcvar_num(PcvarAllowSpecators, 1)
								}

								engclient_cmd(player, "joinclass", "6")
								engclient_cmd(player, "jointeam", "6")

								fm_set_pdata_bool(player, m_bTeamChanged, false)

								if ( allow_spectators != 1 )
								{
									set_pcvar_num(PcvarAllowSpecators, allow_spectators)
								}
							}
						}
						else if ( kick_time > 0.0 && afk_time >= kick_time && ( !kick_immunity || !has_all_flags(player, kick_immunity_flag) ) )
						{
							user_kick(player)
						}
					}
				}
			}
		}
	}
	
	// Bots are never AFK (they don't have keyboards but nevermind)
	terrorists_not_afk += get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "TERRORIST")
	cts_not_afk += get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "CT")

	if ( last_kick_id > 0 )
	{
		user_kick(last_kick_id)
	}

	if ( global_messages_away_time > 0.0 )
	{
		if ( cts_afk > 0 && cts_not_afk == 0 && terrorists_not_afk > 0 )
		{
			if ( colored_messages )
			{
				set_hudmessage(0, 50, 255, 0.02, 0.688, 0, 0.0, loop_frequency, 0.0, 0.0, -1)
			}
			else
			{
				set_hudmessage(255, 255, 255, 0.02, 0.688, 0, 0.0, loop_frequency, 0.0, 0.0, -1)
			}

			get_players(players, player_count, "aceh", "TERRORIST")
			for ( i = 0; i < player_count; i++ )
			{
				player = players[i]

				show_hudmessage(player, "%L", player, "ALL_CTS_AFK")
			}
		}
		else if ( terrorists_afk > 0 && terrorists_not_afk == 0 && cts_not_afk > 0 )
		{
			if ( colored_messages )
			{
				set_hudmessage(255, 50, 0, 0.02, 0.688, 0, 0.0, loop_frequency, 0.0, 0.0, -1)
			}
			else
			{
				set_hudmessage(255, 255, 255, 0.02, 0.688, 0, 0.0, loop_frequency, 0.0, 0.0, -1)
			}

			get_players(players, player_count, "aceh", "CT")
			for ( i = 0; i < player_count; i++ )
			{
				player = players[i]

				show_hudmessage(player, "%L", player, "ALL_TERRORISTS_AFK")
			}
		}
	}
}

user_kick(id)
{
	AfkTime[id] = 0.0

	new name[MAX_NAMELENGTH]
	get_user_name(id, name, charsmax(name))

	if ( get_pcvar_num(PcvarColoredMessages) )
	{
		client_print_color(0, id, "%L", LANG_PLAYER, "COLORED_AFK_KICKED", name)
	}
	else
	{
		client_print(0, print_chat, "%L", LANG_PLAYER, "AFK_KICKED", name)
	}

	server_cmd("kick #%d ^"%L^"", UserID[id], id, "AFK_KICK_REASON")
}

// New Round
public Event_HLTV()
{
	RoundFreeze = true
}

public LogEvent_Round_Start()
{
	RoundFreeze = false
}

public Ham_Player_Spawn_Post(id)
{
	if ( get_pcvar_num(PcvarCheckViewAngle) > 0 && is_user_alive(id) )
	{
		// Getting the changing spawn v_angle with v_angle or angles here is unreliable due to how the game is coded
		SetViewAngleChanged(id)
	}
}

fm_set_pdata_char(ent, charbased_offset, value, intbase_linuxdiff = 5, intbase_macdiff = 5)
{
	value &= 0xFF
	new int_offset_value = get_pdata_int(ent, charbased_offset / INT_BYTES, intbase_linuxdiff, intbase_macdiff)
	new bit_decal = (charbased_offset % INT_BYTES) * BYTE_BITS
	int_offset_value &= ~(0xFF<<bit_decal) // clear byte
	int_offset_value |= value<<bit_decal
	set_pdata_int(ent, charbased_offset / INT_BYTES, int_offset_value, intbase_linuxdiff, intbase_macdiff)
	return 1
}

fm_set_pdata_bool(ent, charbased_offset, bool:value, intbase_linuxdiff = 5, intbase_macdiff = 5)
{
	fm_set_pdata_char(ent, charbased_offset, _:value, intbase_linuxdiff, intbase_macdiff)
}