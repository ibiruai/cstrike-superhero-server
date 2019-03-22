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
	//client_cmd(id, "setinfo ^"translit_ee^" ^"1^"")
	set_user_info(id, "translit_ee", "1")
	format(Info, charsmax(Info), "%L", id, "CT_RUS")
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
	//client_cmd(id, "setinfo ^"translit_ee^" ^"0^"")
	set_user_info(id, "translit_ee", "0")
	format(Info, charsmax(Info), "%L", id, "CT_ENG")
	WriteMessage(id, Info)
	if(get_pcvar_num(g_Sounds))
	{
		client_cmd(id, "spk buttons/blip2")
	}
	return PLUGIN_CONTINUE
}