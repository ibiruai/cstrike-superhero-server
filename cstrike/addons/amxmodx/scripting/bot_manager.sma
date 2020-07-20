#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>

#define MAXSLOTS		32
#define MAXSPEC			3

#if defined MAXSPEC
new bool:bot_on[MAXSPEC], bot_id[MAXSPEC]
// The names of the spectating bots
new const szname_bot[MAXSPEC][33] = {
	"Spectator 1",
	"Spectator 2",
	"Spectator 3"
}
// Server IP address
new const serverIP[] = "95.142.47.100"
new pcvarSpecTreshold
#endif

new pcvarMaxBots, pcvarBotsTreshold
new bots_treshold

public plugin_init()
{
	register_plugin("Bot Manager", "1.0", "Evileye")
	
	pcvarMaxBots = register_cvar("bm_maxbots", "3")				// Max amount of podbots
	pcvarBotsTreshold = register_cvar("bm_bots_treshold", "4")	// This amount of players => no podbots on the server
	
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	#if defined MAXSPEC
	pcvarSpecTreshold = register_cvar("bm_spec_treshold", "18")	// This amount of players => no spectating bots on the server
	register_event("TextMsg", "event_game_restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	#endif
}

humans_num()
{
	// How many human players are in the both teams?
	return ( get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "CT") + get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "TERRORIST") )
}

public logevent_round_start()
{
	bots_treshold = get_pcvar_num(pcvarBotsTreshold)
	new bots_num = clamp(bots_treshold - humans_num(), 0, get_pcvar_num(pcvarMaxBots))
	
	if ( get_cvar_num("pb_maxbots") != bots_num )
	{
		set_cvar_num("pb_maxbots", bots_num)
		set_cvar_num("pb_minbots", bots_num)
	}
	
	if ( get_cvar_num("pb_maxbots") == 0 )
		server_cmd("pb removebots")
		
	#if defined MAXSPEC
	spectators_check(bots_num)
	#endif
}

public logevent_round_end()
{
	// The end of the round. We are checking whether teams are equal.
	
	if (humans_num() >= bots_treshold)	// No podbots are on the server
		return
	
	// Team counting
	new players[MAXSLOTS], num, numCT, numT, i
	numCT = 0
	numT  = 0
	get_players_ex(players, num, GetPlayers_ExcludeHLTV)
	for (i = 0; i < num; i++)
	{
        switch( cs_get_user_team(players[i]) )
        {
            case CS_TEAM_T:  numT++
            case CS_TEAM_CT: numCT++
        }
	}
	
	if ( (numCT + numT) % 2 == 1 || numCT == numT )
		return
	
	new CsTeams:teamFrom, CsTeams:teamTo
	if ( numCT < numT )
	{
		teamFrom = CS_TEAM_T
		teamTo = CS_TEAM_CT
	}
	else
	{
		teamFrom = CS_TEAM_CT
		teamTo = CS_TEAM_T
	}
	
	// We need to find a bot to transfer
	new bot_id = 0
	for (i = 0; i < num; i++)
	{
		if ( is_user_bot(players[i]) && cs_get_user_team(players[i]) == teamFrom )
		{	
			bot_id = players[i]
			// A dead bot is the best choice, no need to look for further
			if ( !is_user_alive(bot_id) )
				break
		}
	}

	if ( bot_id == 0 )
		return
	
	// Transferring the bot
	cs_set_user_team(bot_id, teamTo)
}

#if defined MAXSPEC
public event_game_restart()
{
	bot_spectator_remove_all()	
}

spectators_check(bots_num)
{
	new spectating_bots_req, spectating_bots_real, i
	
	// How many spectating bots do we need?
	new slots_available = clamp(get_pcvar_num(pcvarSpecTreshold) - get_playersnum_ex(GetPlayers_IncludeConnecting), 0, MAXSPEC)
	spectating_bots_req = clamp(get_pcvar_num(pcvarMaxBots) - bots_num, 0, slots_available)

	// How many spectating bots are on the server?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_req == spectating_bots_real) // Do we already have needed amount of spectating bots?
		return
	
	// Add some spectating bots
	for (i = 0; i < spectating_bots_req; i++)
		bot_spectator_add(i)
	
	// Remove some spectating bots
	for (i = spectating_bots_req; i < MAXSPEC; i++)
		bot_spectator_remove(i)
	
	// How many spectating bots are on the server?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_real <= spectating_bots_req) // If there are no unnecessary spectating bots
		return										 // then do nothing.
		
	bot_spectator_remove_all()
}
bot_spectator_remove_all()
{
	// Kick all spectating bots from the server
	new bots_spectators[MAXSLOTS], num, name[35], id
	get_players_ex(bots_spectators, num, GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	for (new i = 0; i < num; i++)
	{
		id = bots_spectators[i]
		
		if ( id < 1 || id > MAXSLOTS || !is_user_connected(id) )
			continue
		
		get_user_name(id, name, charsmax(name))
		server_cmd("kick ^"%s^"", name)
	}
	for (new i = 0; i < MAXSPEC; i++)
	{
		bot_on[i] = false
		bot_id[i] = 0
	}
}

// Code from botespectador plugin created by _|Polimpo4|_
// https://forums.alliedmods.net/showthread.php?t=293059
bot_spectator_add(n)
{	
	if( (!bot_on[n]) && (!bot_id[n]) )
	{
		bot_id[n] = engfunc(EngFunc_CreateFakeClient, szname_bot[n])
		if ( bot_id[n] > 0 )
		{
			new rj[128]
			engfunc(EngFunc_FreeEntPrivateData, bot_id[n])
			dllfunc(DLLFunc_ClientConnect, bot_id[n], szname_bot[n], serverIP, rj)
			if( is_user_connected(bot_id[n]) )
			{
				dllfunc(DLLFunc_ClientPutInServer, bot_id[n])
				set_pev(bot_id[n], pev_spawnflags, pev(bot_id[n], pev_spawnflags) | FL_FAKECLIENT)
				set_pev(bot_id[n], pev_flags, pev(bot_id[n], pev_flags) | FL_FAKECLIENT)
				cs_set_user_team(bot_id[n], CS_TEAM_SPECTATOR)
				bot_on[n] = true
			}		
		}		
	}
}
bot_spectator_remove(n)
{
	new id = bot_id[n]
	
	if ( id < 1 || id > MAXSLOTS || !is_user_connected(id) || !is_user_bot(id) )
		return	
	
	server_cmd("kick #%d", id)
	
	bot_on[n] = false
	bot_id[n] = 0
}
#endif
