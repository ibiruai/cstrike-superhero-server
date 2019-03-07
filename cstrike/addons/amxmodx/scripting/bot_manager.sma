#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>

#define MAXSLOTS		32
#define BOTS_TRESHOLD	4	// Количество игроков, при котором подботы покинут сервер
#define SPEC_TRESHOLD	18	// Количество игроков, при котором боты-зрители покинут сервер
#define MAXBOTS			3
#define MAXSPEC			3

#if defined MAXSPEC
new bool:bot_on[MAXSPEC], bot_id[MAXSPEC]
// Имена ваших ботов-зрителей
new const szname_bot[MAXSPEC][33] = {
	"Website: http://evileye.eu.org/",
	"Email me: evileye@firemail.cc",
	"IP address: 95.142.47.100"
}
// IP адрес вашего сервера
new const serverIP[] = "95.142.47.100"
#endif

public plugin_init()
{
	register_plugin("Bot Manager", "1.0", "Evileye")
	
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	#if defined MAXSPEC
	register_event("TextMsg", "event_game_restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	#endif
}

humans_num()
{
	// Получим количество людей в обеих командах
	return ( get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "CT") + get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "TERRORIST") )
}

public logevent_round_start()
{
	new bots_num = clamp(BOTS_TRESHOLD - humans_num(), 0, MAXBOTS)
	
	if ( get_cvar_num("pb_maxbots") != bots_num )
	{
		set_cvar_num("pb_maxbots", bots_num)
		set_cvar_num("pb_minbots", bots_num)
	}
		
	#if defined MAXSPEC
	spectators_check(bots_num)
	#endif
	
	if ( bots_num == 0 )
		server_cmd("pb removebots")
}

public logevent_round_end()
{
	// Конец раунда. Проверим баланс команд.
	
	if (humans_num() >= BOTS_TRESHOLD)	// Ботов на сервере нет.
		return
	
	// Подсчитаем количество CT и T
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
	
	if ( numCT + numT != 4 || numCT == numT ) // Игроков не 4 или команды равны?
		return								  // Тогда ничего не делаем.
	
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
	
	// Найдём бота, которого будем перемещать
	new bot_id = 0
	for (i = 0; i < num; i++)
	{
		if ( is_user_bot(players[i]) && cs_get_user_team(players[i]) == teamFrom )
		{	
			bot_id = players[i]
			// Если бот мёртв, то прекращаем поиски - Мы нашли лучшего кандидата
			if ( !is_user_alive(bot_id) )
				break
		}
	}

	if ( bot_id == 0 )
		return // Не получилось найти бота
	
	// Выполняем перемещение
	cs_set_user_team(bot_id, teamTo)
}

#if defined MAXSPEC
public event_game_restart()
{
	bot_spectator_remove_all()	
}
#endif

#if defined MAXSPEC
spectators_check(bots_num)
{
	new spectating_bots_req, spectating_bots_real, i
	
	// Сколько ботов-зрителей требуется?
	new slots_available = clamp(SPEC_TRESHOLD - get_playersnum_ex(GetPlayers_IncludeConnecting), 0, MAXSPEC)
	spectating_bots_req = clamp(MAXBOTS - bots_num, 0, slots_available)

	// Сколько ботов-зрителей на самом деле?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_req == spectating_bots_real) // Ботов-зрителей именно столько, сколько нужно?
		return										 // Тогда продолжать не нужно.
	
	// Добавим недостающих
	for (i = 0; i < spectating_bots_req; i++)
		bot_spectator_add(i)
	
	// Уберём лишних
	for (i = spectating_bots_req; i < MAXSPEC; i++)
		bot_spectator_remove(i)
	
	// Сколько ботов-зрителей на самом деле?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_real <= spectating_bots_req) // Количество ботов-зрителей не превышает ожидаемого?
		return										 // Тогда продолжать не нужно.
		
	bot_spectator_remove_all()
}
bot_spectator_remove_all()
{
	// Убираем всех ботов-зрителей с сервера командой kick
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
	if ( bot_id[n] < 1 || bot_id[n] > MAXSLOTS || !is_user_connected(bot_id[n]) )
		return
		
	bot_on[n] = false
	bot_id[n] = 0
	server_cmd("kick ^"%s^"", szname_bot[n])	
}
#endif
