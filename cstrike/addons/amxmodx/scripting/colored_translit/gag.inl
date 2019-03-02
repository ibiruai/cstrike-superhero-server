/*
* 	Colored Translit v3.0 by Sho0ter
*	Gager
*/
public cmd_gag(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
	{
		return PLUGIN_HANDLED
	}
	read_args(s_Arg, charsmax(s_Arg))
	parse(s_Arg, s_GagPlayer, charsmax(s_GagPlayer), s_GagTime, charsmax(s_GagTime))
	if(!is_str_num(s_GagTime))
	{
		format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_CMD_ERROR")
		WriteMessage(id, Info)
		return PLUGIN_CONTINUE
	}
	gagid = cmd_target(id, s_GagPlayer, 8)
	if(!gagid)
	{
		return PLUGIN_HANDLED
	}
	get_user_name(id, s_GagAdmin, charsmax(s_GagAdmin))
	get_user_name(gagid, s_GagTarget, charsmax(s_GagTarget))
	if(get_user_flags(gagid) & IMMUNITY_LEVEL && get_pcvar_num(g_GagImmunity))
	{
		format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_IMMUNITY", s_GagTarget)
		WriteMessage(id, Info)
	}
	else
	{
		i_GagTime = str_to_num(s_GagTime)
		get_user_name(gagid, s_GagName[gagid], 31)
		get_user_ip(gagid, s_GagIp[gagid], 31, 1)
		SysTime = get_systime(0)
		i_Gag[gagid] = SysTime + i_GagTime*60
		Flood[gagid] = false
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(gagid, "spk buttons/button5")
			client_cmd(id, "spk buttons/button5")
		}
		switch(get_cvar_num("amx_show_activity"))
		{
			case 0:
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_A0_GAG", s_GagTarget, i_GagTime)
				WriteMessage(id, Info)
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED", i_GagTime)
				WriteMessage(gagid, Info)
			}
			case 1:
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A1_GAG", s_GagTarget, i_GagTime)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info)
				}
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED", i_GagTime)
				WriteMessage(gagid, Info)
			}
			case 2:
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A2_GAG", s_GagAdmin, s_GagTarget, i_GagTime)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info)
				}
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED2", s_GagAdmin, i_GagTime)
				WriteMessage(gagid, Info)
				if(get_pcvar_num(g_Log))
				{
					get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
					get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
					format(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
					format(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(gagid, p_LogIp, charsmax(p_LogIp), 1)
					get_user_ip(id, p_LogAdminIp, charsmax(p_LogAdminIp), 1)
					format(p_LogMessage, charsmax(p_LogMessage), "%s - ADMIN %s <%s> has gaged %s <%s> for %d minutes", p_LogTime, s_GagAdmin, p_LogAdminIp, s_GagTarget, p_LogIp, i_GagTime)
					write_file(p_LogFile, p_LogMessage)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}