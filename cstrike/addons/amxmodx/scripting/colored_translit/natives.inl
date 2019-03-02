/*
* 	Colored Translit v3.0 by Sho0ter
*	Natives
*/
public plugin_natives()
{
	register_library("colored_translit")
	register_native("ct_cmd_lang", "native_cmd_lang", 1)
	register_native("ct_register_clcmd", "native_register_clcmd", 1)
	register_native("ct_send_infomsg", "native_infomsg", 1)
	register_native("ct_get_lang", "native_get_lang", 1)
	register_native("ct_add_to_msg", "native_add_to_msg", 1)
	register_native("ct_is_user_gaged", "native_is_gaged", 1)
	return PLUGIN_CONTINUE
}

public native_cmd_lang(id, lang)
{
	if(!is_valid_player(id))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	if(lang != CT_LANG_ENG && lang != CT_LANG_RUS)
	{
		log_error(AMX_ERR_NATIVE, "Invalid lang %d", lang)
		return 0
	}
	switch(lang)
	{
		case CT_LANG_ENG:
		{
			cmd_eng(id)
			return 1
		}
		case CT_LANG_RUS:
		{
			cmd_rus(id)
			return 1
		}
	}
	return 0
}

public native_register_clcmd(const cmd[])
{
	param_convert(1)
	if(!strlen(cmd))
	{
		log_error(AMX_ERR_NATIVE, "Empty command")
		return 0
	}
	copy(Cmds[CmdsNum], 127, cmd)
	CmdsNum++
	return 1
}

public native_infomsg(id, const input[], any:...)
{
	param_convert(2)
	param_convert(3)
	if(!is_valid_player(id) && id != 0)
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	new msg[192]
	vformat(msg, charsmax(msg), input, 3)
	format(Info, charsmax(Info), "^x01[^x04%s^x01] %s", PLUGIN, msg)
	if(id && is_user_connected(id))
	{
		WriteMessage(id, Info)
		return 1
	}
	else
	{
		for(new i = 1; i <= get_maxplayers(); i++)
		{
			if(!is_user_connected(i))
			{
				continue
			}
			WriteMessage(i, Info)
		}
		return 1
	}
	return 0
}

public native_get_lang(id)
{
	if(!is_valid_player(id))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	new s_Inf[2]
	get_user_info(id, "translit", s_Inf, charsmax(s_Inf))
	return str_to_num(s_Inf)
}

public native_add_to_msg(position, const input[], any:...)
{
	param_convert(2)
	param_convert(3)
	if(0 > position || position > 3)
	{
		log_error(AMX_ERR_NATIVE, "Invalid message position %d", position)
		return 0
	}
	if(!strlen(input))
	{
		log_error(AMX_ERR_NATIVE, "Empty input string")
		return 0
	}
	new rdmsg[128]
	vformat(rdmsg, charsmax(rdmsg), input, 3)
	copy(Adds[position][AddsNum[position]], 127, rdmsg)
	AddsNum[position]++
	return 1
}

public native_is_gaged(id)
{
	if(!is_valid_player(id))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	if(i_Gag[id] > get_systime(0))
	{
		return i_Gag[id]
	}
	return 0
}