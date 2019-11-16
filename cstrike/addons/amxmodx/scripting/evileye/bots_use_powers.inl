#define BOTMYSTIQUE_TASKID 44442600
#define BOTELECTRO_TASKID 44442500
new BotMystique[SH_MAXSLOTS+1]
new BotSnake[SH_MAXSLOTS+1]
new BotBass[SH_MAXSLOTS+1]
new BotElectro[SH_MAXSLOTS+1]
new bool:BotElectroActivated[SH_MAXSLOTS+1]

public bup_init()
{
	register_logevent("bup_new_round", 2, "1=Round_Start")
	register_event("Damage", "bup_damage", "b", "2!0", "3=0", "4!0")
	RegisterHam( Ham_Killed, "player", "bup_bot_killed", 1 )
}
//----------------------------------------------------------------------------------------------
public bup_new_round()
{
	new bots[SH_MAXSLOTS], playerCount
	new id, i, name[25]
	get_players(bots, playerCount, "ad")

	for (new x = 0; x < playerCount; x++) {
		id = bots[x]
		i = 0
		BotMystique[id] = 0
		BotSnake[id] = 0
		BotBass[id] = 0
		BotElectro[id] = 0
		BotElectroActivated[id] = false
		new playerpowercount = getPowerCount(id)
		for ( new x = 1; x <= playerpowercount && x <= SH_MAXLEVELS; x++ ) {
			if (gSuperHeros[ gPlayerPowers[id][x] ][requiresKeys]) {
				i++
				formatex(name, charsmax(name), "%s", gSuperHeros[ gPlayerPowers[id][x] ][hero])
				if (equali(name, "Mystique")) {
					BotMystique[id] = i
					remove_task(BOTMYSTIQUE_TASKID + id)
					if ( random_num(1, 6) > 4 )
						set_task( random_num(5, 10) * 1.0 , "botMystiqueOn", BOTMYSTIQUE_TASKID + id)
				}
				else if (equali(name, "Snake"))
					BotSnake[id] = i
				else if (equali(name, "Bass"))
					BotBass[id] = i
				else if (equali(name, "Electro"))
					BotElectro[id] = i
			}			
		}
	}
}
//----------------------------------------------------------------------------------------------
public bup_bot_killed(id, attacker) {
	if (!is_user_bot(id))
		return
	remove_task(BOTMYSTIQUE_TASKID + id)
	remove_task(BOTELECTRO_TASKID + id)
}
//----------------------------------------------------------------------------------------------
public bup_damage(victim) {
	new attacker = get_user_attacker(victim)
	new parameters[2]
	
	if (is_user_bot(victim) && is_user_alive(victim) && get_user_health(victim) < 80 &&	BotSnake[victim] != 0 && !SnakeCooldown[victim] && random_num(1, 6) > 2) {
		parameters[0] = victim
		parameters[1] = BotSnake[victim]
		set_task(0.5, "press_button_with_delay", victim, parameters, 2)
	}
	
	if (!is_user_bot(attacker) || get_user_health(victim) <= 0 )
		return
	
	if (BotBass[attacker] != 0 && random_num(1, 6) > 4) {
		parameters[0] = attacker
		parameters[1] = BotBass[attacker]
		set_task(0.7, "press_button_with_delay", attacker, parameters, 2)		
	} 
	if (BotElectro[attacker] != 0 && !BotElectroActivated[attacker]&& !ElectroCooldown[victim]  && random_num(1, 6) > 2) {
		parameters[0] = attacker
		parameters[1] = BotElectro[attacker]
		set_task(1.2, "press_button_with_delay", attacker, parameters, 2)
		set_task( random_num(4, 8) * 1.0 , "press_button_with_delay", BOTELECTRO_TASKID + attacker, parameters, 2)
	}
}
//----------------------------------------------------------------------------------------------
public botMystiqueOn(task_id) {
	new id = task_id - BOTMYSTIQUE_TASKID
	if (!is_user_bot(id) || !is_user_alive(id))
		return
	
	press_button(id, BotMystique[id])
	set_task( random_num(18, 25) * 1.0 , "botMystiqueOff", BOTMYSTIQUE_TASKID + id)
}
//----------------------------------------------------------------------------------------------
public botMystiqueOff(task_id) {
	new id = task_id - BOTMYSTIQUE_TASKID
	if (!is_user_bot(id) || !is_user_alive(id))
		return
	
	press_button(id, BotMystique[id])
	set_task( random_num(5, 10) * 1.0 , "botMystiqueOn", BOTMYSTIQUE_TASKID + id)
}
//----------------------------------------------------------------------------------------------
public press_button_with_delay(param[]) {
	press_button(param[0], param[1])
}
//----------------------------------------------------------------------------------------------
public press_button(id, button) {
	if (!is_user_bot(id) || !is_user_alive(id))
		return
	
	new cmd[16]
	formatex(cmd, charsmax(cmd), "+power%d", button)
	amxclient_cmd(id, cmd)
	formatex(cmd, charsmax(cmd), "-power%d", button)
	amxclient_cmd(id, cmd)
}
//----------------------------------------------------------------------------------------------