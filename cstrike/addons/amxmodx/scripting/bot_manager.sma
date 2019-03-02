#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>

#define BOTSPEC			3
#define MAXSLOTS		32

new bots

#if defined BOTSPEC
new bool:bot_on[BOTSPEC], bot_id[BOTSPEC]
new szname_bot[BOTSPEC][33] = {
	"Website: http://evileye.eu.org/",
	"Email me: evileye@firemail.cc",
	"IP address: 95.142.47.100"
}
new serverIP[] = "95.142.47.100"
#endif

public plugin_init()
{
	register_plugin("Bot Manager", "1.0", "Evileye")
	
	register_event( "TeamInfo", "event_team_info", "a" )
	
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")

	podbot_check()
}

get_playing_humans_num()
{
	return ( get_playersnum_ex(GetPlayers_ExcludeBots) - get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "SPECTATOR") - get_playersnum_ex(GetPlayers_ExcludeBots | GetPlayers_MatchTeam, "UNASSIGNED") )
}

public event_team_info()
{
	if ( !is_user_bot( read_data(1) ) )
		podbot_check()
}

public client_disconnected(id)
{
	if ( !is_user_bot(id) )
		podbot_check()
}

podbot_check()
{
	new humans = get_playing_humans_num()
	
	switch (humans)
	{
		case 0..1:	bots = 3
		case 2:		bots = 2
		case 3:		bots = 1
		default:	bots = 0
	}
	
	set_cvar_num("pb_maxbots", bots)
	set_cvar_num("pb_minbots", bots)
	
	#if defined BOTSPEC
	set_task(1.5, "spectators_check")
	#endif
}

public logevent_round_start()
{
	// Начало раунда. Проверим, нет ли ненужного подбота на сервере.
	// Команда pb_maxbots 0 не заставляет последнего подбота покинуть сервер.
	// Нам придётся кикнуть его.
	
	// Получим требуемое количество подботов на сервере
	new bots_num = get_cvar_num("pb_maxbots")
	
	if ( bots_num != 0 ) // pb_maxbots больше нуля
		return			 // Тогда ничего не делаем.
	
	// Найдём реальное количество подботов на сервере
	new bot_numT = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "TERRORIST")
	new bot_numCT = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "CT")
	new real_bot_num = bot_numT + bot_numCT	
	
	// Ботов нет на сервере - Действия не требуется
	if ( real_bot_num == 0 )
		return
	
	// Имеются лишние подботы - Это следует исправить
	
	new bots[MAXSLOTS], num
		
	if ( bot_numT )
		get_players_ex(bots, num, GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "TERRORIST")
	else
		get_players_ex(bots, num, GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "CT")
		
	// Никого не нашлось? Ничего не получится
	if ( num == 0 )
		return

	// Найдём имя бота, которого нужно кикнуть
	new bot_id = bots[0]
	new bot_name[33]
	get_user_name(bot_id, bot_name, 32)	
	
	// Кикаем бота
	server_cmd("kick ^"%s^"", bot_name)
}

public logevent_round_end()
{
	// Конец раунда. Проверим баланс команд.
	
	if (get_playing_humans_num() >= 3)	// Работает плагин PTB.
		return							// Не будем ему мешать.
	
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
	
	// Найдём бота, которого будем перемещать
	new bot_id = 0
	for (i = 0; i < num; i++)
	{
		if ( !is_user_bot(players[i]) )
			continue

		if ( numCT < numT )
		{
			if ( cs_get_user_team(players[i]) == CS_TEAM_T )
			{	
				bot_id = players[i]
				// Если бот мёртв, то прекращаем поиски - Мы нашли лучшего кандидата
				if ( !is_user_alive(bot_id) )
					break
			}
		}
		else
		{
			if ( cs_get_user_team(players[i]) == CS_TEAM_CT )
			{	
				bot_id = players[i]
				if ( !is_user_alive(bot_id) )
					break
			}			
		}
	}

	if ( bot_id == 0 )
		return // Не получилось найти бота
	
	// Выполняем перемещение
	if ( numCT < numT )
	{
		cs_set_user_team(bot_id, CS_TEAM_CT)
	}
	else
	{
		cs_set_user_team(bot_id, CS_TEAM_T)
	}
}

#if defined BOTSPEC
public spectators_check()
{
	new spectating_bots_req, spectating_bots_real, i
	
	// Сколько ботов-зрителей требуется?
	spectating_bots_req = 3 - bots
	
	// Сколько ботов-зрителей на самом деле?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_req == spectating_bots_real) // Ботов-зрителей именно столько, сколько нужно?
		return										 // Тогда продолжать не нужно.
	
	// Добавим недостающих
	for (i = 0; i < spectating_bots_req; i++)
		bot_spectator_add(i)
	
	// Уберём лишних
	for (i = spectating_bots_req; i < 3; i++)
		bot_spectator_remove(i)
	
	// Сколько ботов-зрителей на самом деле?
	spectating_bots_real = get_playersnum_ex(GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	
	if (spectating_bots_real <= spectating_bots_req) // Количество ботов-зрителей не превышает ожидаемого?
		return										 // Тогда продолжать не нужно.
	
	// Убираем всех ботов-зрителей с сервера командой kick
	new bots_spectators[MAXSLOTS], num, name[33]
	get_players_ex(bots_spectators, num, GetPlayers_ExcludeHuman | GetPlayers_MatchTeam, "SPECTATOR")
	for (i = 0; i < num; i++)
	{
		get_user_name(bots_spectators[i], name, 32)
		server_cmd("kick ^"%s^"", name)
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
	bot_on[n] = false
	bot_id[n] = 0
	server_cmd("kick ^"%s^"", szname_bot[n])	
}
#endif
