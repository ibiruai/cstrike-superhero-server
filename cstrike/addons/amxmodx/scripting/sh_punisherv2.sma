#include <superheromod>

new gHasHero[SH_MAXSLOTS+1]
new const gHeroName[] = "PunisherV2"
new gHeroID
new pcvarAmmoToAdd

public plugin_init()
{
	register_plugin("SUPERHERO PunisherV2", "1.2", "Jelle")
	
	//cvars
	new pcvarLevel = register_cvar("punisherv2_level", "5")
	pcvarAmmoToAdd = register_cvar("punisherv2_ammotoadd", "2")
	new pcvarTimeToAdd = register_cvar("punisherv2_ammotime", "0.5")
	
	//create hero
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Bullets are added to your current mag!", "You get more bullets into your current mag!")
	
	set_task(get_pcvar_float(pcvarTimeToAdd), "add_bullets", _, _, _, "b")
}

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	gHasHero[id] = mode ? true : false
}

public add_bullets()
{
	if ( !sh_is_active() ) return

	static players[32], playerCount, player, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ )
	{
		player = players[i]

		if ( gHasHero[player] )
		{
			
			new ca
			
			//find what weapon type the player has
			switch(get_user_weapon(player))
			{
			case CSW_P228 : ca = 13;
			case CSW_SCOUT : ca = 10;
			case CSW_HEGRENADE : ca = 1;
			case CSW_XM1014 : ca = 7;
			case CSW_C4 : ca = 1;
			case CSW_MAC10 : ca = 30;
			case CSW_AUG : ca = 30;
			case CSW_SMOKEGRENADE : ca = 1;
			case CSW_ELITE : ca = 15;
			case CSW_FIVESEVEN : ca = 20;
			case CSW_UMP45 : ca = 25;
			case CSW_SG550 : ca = 30;
			case CSW_GALI : ca = 35;
			case CSW_FAMAS : ca = 25;
			case CSW_USP : ca = 12;
			case CSW_GLOCK18 : ca = 20;
			case CSW_AWP : ca = 10;
			case CSW_MP5NAVY : ca = 30;
			case CSW_M249 : ca = 100;
			case CSW_M3 : ca = 8;
			case CSW_M4A1 : ca = 30;
			case CSW_TMP : ca = 30;
			case CSW_G3SG1 : ca = 20;
			case CSW_FLASHBANG : ca = 2;
			case CSW_DEAGLE: ca = 7;
			case CSW_SG552 : ca = 30;
			case CSW_AK47 : ca = 30;
			case CSW_P90 : ca = 50;
			}
			
			new currentAmmo = cs_get_weapon_ammo(get_pdata_cbase( player, 373 ))
			new newAmmo = currentAmmo+get_pcvar_num(pcvarAmmoToAdd)
			
			//This checks if ca is higher or the equal to the new ammo which will be set
			if (newAmmo <= ca)
			{
				
				//Now lets set the new ammo!
				cs_set_weapon_ammo(get_pdata_cbase( player, 373 ), newAmmo)
			}
			//what if ca = 30, and new ammo is bigger than the max? then new ammo will be 32 in a 30 max clip weapon??
			else
			{
				//Then we just set the max bullets into the gun!
				cs_set_weapon_ammo(get_pdata_cbase( player, 373 ), ca)
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
