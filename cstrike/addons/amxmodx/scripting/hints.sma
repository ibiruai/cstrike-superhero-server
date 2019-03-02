#include <amxmodx>
#include <superheromod>
#include <hamsandwich>
#include <fvault>
#include <geoip>

new bool:showGreeting[SH_MAXSLOTS+1]
new bool:newPlayer[SH_MAXSLOTS+1]
new bool:showLangmenu[SH_MAXSLOTS+1]

public plugin_init()
{
	register_plugin("Hints", "1.0", "Evileye")
	register_dictionary("hints.txt")

	// NEW ROUND
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
}

public player_spawn(id)
{
	if ( is_user_bot(id) ) return
	
	if ( showGreeting[id] )
	{
		new name[32]
		get_user_name(id, name, 31)
		
		if ( newPlayer[id] )
		{
			if ( showLangmenu[id] )
				Language(id)
			
			client_print_color(id, print_team_default, "%L", id, "WELCOME", name)
			client_print_color(id, print_team_grey, "%L", id, "HINT_MENU")
		}
		else
		{
			new dice = random_num(1, 6)	
			
			new option[8]
			formatex(option, 8, "HELLO_%i", dice)
			
			client_print_color(id, print_team_default, "%L", id, option, name)
		}
		
		showGreeting[id] = false
	}
}

public event_new_round()
{
	new dice
	
	new players[SH_MAXSLOTS], playerCount
	get_players(players, playerCount, "")
	
	for ( new i = 0; i < playerCount; i++ )
	{
		new id = players[i]
		
		if ( showGreeting[id] ) continue

		// TIPS
		dice = random_num(1, 6)
		if ( dice <= 6)
		{
			dice = random_num(1, 10)
			switch (dice)
			{
				case 1..2:
				{
					client_print_color(id, print_team_grey, "%L", id, "HINT_RTV")
					client_print_color(id, print_team_grey, "%L", id, "HINT_NOM")
				}
				case 3..5:
				{
					client_print_color(id, print_team_grey, "%L", id, "HINT_MENU")
				}
				case 6..8:
				{
					client_print_color(id, print_team_grey, "%L", id, "HINT_MENU_KEY")
				}
				case 9..10:
				{
					client_print_color(id, print_team_grey, "%L", id, "HINT_BIND_1")
					client_print_color(id, print_team_grey, "%L", id, "HINT_BIND_2")
				}
			}		
		}	
	}
}

public client_putinserver(id)
{
	if ( is_user_bot(id) ) return
	
	showGreeting[id] = true
	newPlayer[id]  = true
	
	new name[32], string[10]
	get_user_name(id, name, 31)
	
	if ( fvault_get_data("vault_language", name, string, 9) )
	{
		if ( contain( string, "default" ) == -1 )
			set_user_info(id, "lang", string)
		
		newPlayer[id] = false
	}
	else
	{
		showLangmenu[id] = true
		
		new playerLanguage[3]
		get_user_info(id, "lang", playerLanguage, 3)
		
		if ( contain( playerLanguage, "ru" ) != -1 )
			showLangmenu[id] = false
		else
		{
			new playerIP[32]
			new playerCountry[3]
			get_user_ip(id, playerIP, charsmax(playerIP), 1)
			geoip_code2(playerIP, playerCountry)
			
			if ( contain( playerCountry, "RU" ) != -1 )
				showLangmenu[id] = false
		}
		
		if ( !showLangmenu[id] )
		{
			set_user_info(id, "lang", "ru")
			
			new playerName[33]
			get_user_name(id, playerName, charsmax(playerName))
			fvault_pset_data("vault_language", playerName, "ru")
		}
	}
}

public Language(id)
{
	if ( callfunc_begin("LanguageMenu", "superheromodnvault.amxx") == 1 ) 
	{
		callfunc_push_int(id)
		callfunc_end()
	}
}