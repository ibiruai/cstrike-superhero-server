public playground_init()
{
	// register_concmd("listentome", "listentomycommand", ADMIN_ALL)
	register_concmd("amx_shpprint", "amx_shpprint", ADMIN_ALL)
	register_concmd("amx_shpchange", "amx_shpchange", ADMIN_ALL)
}

public amx_shpprint(id, level, cid)
{
	if ( !cmd_access(id,level,cid,1) ) return
	new str[255]
	for (new i = 0; i < gSuperHeroCount; i++)
	{
		formatex(str, charsmax(str), "%s%d - %s | ", str, i, gSuperHeros[i][hero])
		if (i % 10 == 0)
		{
			console_print(id, str)
			formatex(str, charsmax(str), "")
		}		
	}
	console_print(id, str)
}

public amx_shpchange(id, level, cid)
{
	if ( !cmd_access(id,level,cid,1) ) return

	new arg[32], arg2[32], arg3[32]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	read_argv(3, arg3, charsmax(arg3))
	
	new targetID = str_to_num(arg)
	new n = str_to_num(arg2)
	new heroID = str_to_num(arg3)
	
	if (!is_user_bot(targetID)) return
	
	gPlayerPowers[targetID][n] = heroID
}

/*
public listentomycommand(id, level, cid)
{
	if ( !cmd_access(id,level,cid,1) ) return
	
	new bots[SH_MAXSLOTS], playerCount
	new id
	get_players(bots, playerCount, "ad")

	new cmd[32], arg[32], arg2[32]
	read_argv(0, cmd, charsmax(cmd))
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	
	client_print(0, print_chat, "input: %s + %s + %s", cmd, arg, arg2)
	
	for (new x = 0; x < playerCount; x++) {
		id = bots[x]
		amxclient_cmd(id, arg, arg2);
	}
}
*/