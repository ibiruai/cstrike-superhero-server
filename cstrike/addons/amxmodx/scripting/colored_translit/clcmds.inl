/*
* 	Colored Translit v3.0 by Sho0ter
*	Lang Changer
*/
public cmd_rus(id)
{
	if(!is_user_connected(id) || get_pcvar_num(g_AutoRus) == 2)
	{
		return PLUGIN_CONTINUE
	}
	client_cmd(id, "setinfo ^"translit^" ^"1^"")
	format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_RUS")
	WriteMessage(id, Info)
	if(get_pcvar_num(g_Sounds))
	{
		client_cmd(id, "spk buttons/blip2")
	}
	return PLUGIN_CONTINUE
}

public cmd_eng(id)
{
	if(!is_user_connected(id) || get_pcvar_num(g_AutoRus) == 2)
	{
		return PLUGIN_CONTINUE
	}
	client_cmd(id, "setinfo ^"translit^" ^"0^"")
	format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_ENG")
	WriteMessage(id, Info)
	if(get_pcvar_num(g_Sounds))
	{
		client_cmd(id, "spk buttons/blip2")
	}
	return PLUGIN_CONTINUE
}