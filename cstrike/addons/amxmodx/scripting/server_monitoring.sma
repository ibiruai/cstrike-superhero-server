#include <amxmodx>
#include <geoip>

#define MAXPLAYERS 32
#define len 1500

#define LOGGING 0

new mapname[33]
new serverMaxPlayers

#if LOGGING
new g_name[33][33]
new g_AuthID[33][33]
new g_IP[33][44]
new country[33][46]
#endif

public plugin_init() {
	register_plugin("Server Monitoring", "1.0", "Evileye")
	get_mapname(mapname, 32)
	serverMaxPlayers = get_maxplayers()
	monitor_update()
}

public client_putinserver(id) {
	set_task(1.0, "monitor_update", 2294940)
	
	#if LOGGING
	if (is_user_bot(id)) return
	
	get_user_name(id , g_name[id] , 32);
	get_user_authid(id , g_AuthID[id] , 32);
	get_user_ip(id , g_IP[id] , 43, 1);
	geoip_country(g_IP[id], country[id], 45)
	if (equal(country[id], "error")) {
		if (contain(g_IP[id], "192.168.")==0 || equal(g_IP[id], "127.0.0.1") || contain(g_IP[id], "10.")==0 ||  contain(g_IP[id], "172.")==0) {
			country[id] = "LAN"
		}
		if (equal(g_IP[id], "loopback")) {
			country[id] = "ListenServer User"
		}
		else {
			country[id] = "Unknown Country"
		}
	}
	
	player_log(id, 1)
	#endif
}

public client_disconnected(id) {
	set_task(1.0, "monitor_update", 2294940)
	
	#if LOGGING
	if(is_user_bot(id)) return
	
	player_log(id, 2)
	#endif
}

#if LOGGING
public player_log(id, type) {
	new g_time[33]
	new string[250]
	get_time("%d.%m.%Y %H:%M", g_time, 32)
	
	new file
	if ( !file_exists("addons/amxmodx/log/monitoring.log") ) {
		file = fopen("addons/amxmodx/log/monitoring.log", "w")
		new thead[6][16] = {"Name", "Join", "Quit", "AuthID", "IP", "Country"}
		format(string, 250, "^^ %-20s^^ %-16s ^^ %-16s ^^ %-20s ^^ %-16s^^ %-20s^^^n", thead[0], thead[1], thead[2], thead[3], thead[4], thead[5])
		fputs(file, string)
		fclose(file)
	}
	
	new g_nothing[1] = ""
	file = fopen("addons/amxmodx/log/monitoring.log", "a")
	if (type == 1)
		format(string, 250, "| %-20s| %-16s | %-16s | %-20s | %-16s| %-20s|^n", g_name[id], g_time, g_nothing, g_AuthID[id], g_IP[id], country[id])
	if (type == 2)
		format(string, 250, "| %-20s| %-16s | %-16s | %-20s | %-16s| %-20s|^n", g_name[id], g_nothing, g_time, g_AuthID[id], g_IP[id], country[id])
	fputs(file, string)
	fclose(file)
}
#endif

public monitor_update() {
	/*
	if (get_realplayersnum() == 0)
	{
		set_cvar_num("pb_maxbots", 3)			// for GameTracker
		set_cvar_num("gal_emptyserver_wait", 5)	// Galileo fix
	}
	else
	{
		set_cvar_num("pb_maxbots", 4)
		set_cvar_num("gal_emptyserver_wait", 0)
		set_task(5.0, "BotAdd", 9292911)
	}
	*/
	new humans[MAXPLAYERS]
	new humanCount
	
	get_players(humans, humanCount, "c")
	
	new bots[MAXPLAYERS], botCount
	get_players(bots, botCount, "d")
	
	new string_ru[len]
	new string_en[len]
	
	formatex(string_ru, len, "<html><head><meta charset = 'UTF-8'><link rel='stylesheet' type='text/css' href='../css/style.css'></head><body><p>Карта: %s<br>Игроки: %i/%i</p><p>Живые игроки:<br>", mapname, humanCount + botCount, serverMaxPlayers)
	formatex(string_en, len, "<html><head><meta charset = 'UTF-8'><link rel='stylesheet' type='text/css' href='../css/style.css'></head><body><p>Map: %s<br>Players: %i/%i</p><p>Human players:<br>", mapname, humanCount + botCount, serverMaxPlayers)
	
	new playername[33]
	new i, id
	for ( i = 0; i < humanCount; i++ )
	{
		id = humans[i]
		get_user_name(id , playername , 32)
		
		format(string_ru, len, "%s <span class='human'>%s</span>, ", string_ru, playername)
		format(string_en, len, "%s <span class='human'>%s</span>, ", string_en, playername)
	}
	if (humanCount)
	{
		string_ru[strlen(string_ru) - 2] = 0
		string_en[strlen(string_en) - 2] = 0
	}
	else
	{
		format(string_ru, len, "%sНет живых игроков", string_ru)
		format(string_en, len, "%sNo human players", string_en)
	}
	format(string_ru, len, "%s </p><p>Боты:<br>", string_ru, playername)
	format(string_en, len, "%s </p><p>Bots:<br>", string_en, playername)
	
	for ( i = 0; i < botCount; i++ )
	{
		id = bots[i]
		get_user_name(id , playername , 32)
		
		format(string_ru, len, "%s <span class='bot'>%s</span>, ", string_ru, playername)
		format(string_en, len, "%s <span class='bot'>%s</span>, ", string_en, playername)
	}
	if (botCount)
	{
		string_ru[strlen(string_ru) - 2] = 0
		string_en[strlen(string_en) - 2] = 0
	}
	else
	{
		format(string_ru, len, "%sНет ботов", string_ru)
		format(string_en, len, "%sNo bots", string_en)
	}
	format(string_ru, len, "%s </p></body></html>", string_ru)
	format(string_en, len, "%s </p></body></html>", string_en)
	
	new file_ru = fopen("addons/amxmodx/data/website-status/status.ru.html", "w")
	new file_en = fopen("addons/amxmodx/data/website-status/status.en.html", "w")
	
	fputs(file_ru, string_ru)
	fputs(file_en, string_en)
	
	fclose(file_ru)
	fclose(file_en)
}
/*
public BotAdd()
{
	server_cmd("pb add")	
}

stock get_realplayersnum()
{
	new players[32], playerCnt
	get_players(players, playerCnt, "ch")
	
	return playerCnt
}
*/