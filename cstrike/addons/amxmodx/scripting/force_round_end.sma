#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <fun>

#define PLUGIN "Force Round End"
#define VERSION "1.2"
#define AUTHOR "Alka"

#define CHECK_TIME 3.0 //Float

#define TASK_ID 1337

//Globals
new bool:g_round_started;
new g_roundtime//, g_adv_time;
// new weapon[33][31];
// new CsArmorType:armortype[33];
// new armoramount[33];
// new g_maxplayers;

//Cvars
new
toggle_plugin,
//g_show_adv,
//g_recive_weapons;
team_to_kill[] = "TERRORIST";

stock const ents_list[][] = {
	
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone"
}

// stock const WeaponNames[31][] = {
	// "",
	// "weapon_p228",
	// "",
	// "weapon_scout",
	// "weapon_hegrenade",
	// "weapon_xm1014",
	// "",
	// "weapon_mac10",
	// "weapon_aug",
	// "weapon_smokegrenade",
	// "weapon_elite",
	// "weapon_fiveseven",
	// "weapon_ump45",
	// "weapon_sg550",
	// "weapon_galil",
	// "weapon_famas",
	// "weapon_usp",
	// "weapon_glock18",
	// "weapon_awp",
	// "weapon_mp5navy",
	// "weapon_m249",
	// "weapon_m3",
	// "weapon_m4a1",
	// "weapon_tmp",
	// "weapon_g3sg1",
	// "weapon_flashbang",
	// "weapon_deagle",
	// "weapon_sg552",
	// "weapon_ak47",
	// "",
	// "weapon_p90"
// }

public plugin_init(){
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End");
	
	register_event("TextMsg", "round_restart", "a", "2&#Game_C", "2&#Game_w");
	
	register_message(get_user_msgid("RoundTime"), "Round_Timer");
	
	set_task(CHECK_TIME,"check_map");
	
	// g_maxplayers = get_maxplayers();
	
	toggle_plugin = register_cvar("amx_fre","1");
	// g_show_adv = register_cvar("amx_fre_adv","1");
	// g_recive_weapons = register_cvar("amx_fre_rw","1");
}


public round_start() {
	
	// if(get_pcvar_num(g_recive_weapons))
	// {
		// give_weapons();
	// }
	g_round_started = true;
}

public round_end()
	remove_task(TASK_ID);

public round_restart()
	remove_task(TASK_ID);


public Round_Timer()
{
	if(g_round_started)
		g_round_started = false;
	else
		return;
	

	g_roundtime = get_msg_arg_int(1);
	// g_adv_time = (g_roundtime - 11); //Postponement fix. (11) - Round is ending after 0:00
	
	if(get_pcvar_num(toggle_plugin))
	{
		set_task(float(g_roundtime), "force_end",TASK_ID);
		// if(get_pcvar_num(g_show_adv))
		// {
			// set_task(float(g_adv_time), "show_adv",TASK_ID);
		// }
	}
}

public force_end()
{
	new g_players[32], num;
	get_players(g_players, num, "ae", team_to_kill);
	new x;
	for(new i = 0; i < num; i++)
	{
		x = g_players[i];
		
		user_silentkill(x);
		cs_set_user_deaths(x, get_user_deaths(x) - 1);
	}
	if (equali(team_to_kill, "CT"))
		team_to_kill = "TERRORIST";
	else
		team_to_kill = "CT";
	get_players(g_players, num, "ae", team_to_kill);
	for(new i = 0; i < num; i++)
	{
		x = g_players[i];
		
		user_silentkill(x);
		cs_set_user_deaths(x, get_user_deaths(x) - 1);
	}
}

// public show_adv()
// {
	// set_hudmessage(0, 255, 0, -1.0, -1.0, 1, 6.0, 3.0,_,_,-1);
	// show_hudmessage(0, "10 Seconds until round end!");
	
	// if(get_pcvar_num(g_recive_weapons))
	// {
		// get_weapons();
	// }
// }

// public get_weapons()
// {
	// static i, i2
	// for( i=0 ; i<=g_maxplayers ; i++)
	// {
		// arrayset(weapon[i],0,31)
		// if(is_user_alive(i))
		// {
			// armoramount[i] = cs_get_user_armor(i,armortype[i])
			// for(i2=1;i2<=30;i2++)
			// {
				// if(i2!=2 && i2!=6 && i2!=29)
				// {
					// if(user_has_weapon(i,i2))
					// {
						// weapon[i][i2] = cs_get_user_bpammo(i,i2)
						// if(!weapon[i][i2])  weapon[i][i2] = 1
					// }
				// }
			// }
		// }
	// }
// }

// public give_weapons()
// {
	// new i, i2
	// for( i=0 ; i<=g_maxplayers ; i++)
	// {
		// if(is_user_alive(i))
		// {
			
			// cs_set_user_armor(i,armoramount[i],armortype[i])
			// strip_user_weapons(i)
			// for(i2=1;i2<=30;i2++)
			// {
				// if(i2!=2 && i2!=6 && i2!=29)
				// {
					// if(weapon[i][i2])
					// {
						// give_item(i,WeaponNames[i2])
						// cs_set_user_bpammo(i,i2,weapon[i][i2])
					// }
				// }
			// }
			// give_item(i,"weapon_knife")
		// }
	// }
// }

public check_map()
{
	for (new a = 0; a < sizeof ents_list; a++)
	{
		if (engfunc(EngFunc_FindEntityByString, -1, "classname", ents_list[a]))
		{
			pause("a");
		}
	}
}
