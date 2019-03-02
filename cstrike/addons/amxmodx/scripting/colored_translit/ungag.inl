/*
* 	Colored Translit v3.0 by Sho0ter
*	Ungager
*/
public cmd_ungag(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}
	SysTime = get_systime(0)
	read_args(s_GagPlayer, charsmax(s_GagPlayer))
	gagid = cmd_target(id, s_GagPlayer, 8)
	if(!gagid)
	{
		return PLUGIN_HANDLED
	}
	get_user_name(id, s_GagAdmin, charsmax(s_GagAdmin))
	get_user_name(gagid, s_GagTarget, charsmax(s_GagTarget))
	if(i_Gag[gagid] <= SysTime)
	{
			format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_ALREADY", s_GagTarget)
			WriteMessage(id, Info)
	}
	else
	{
		SysTime = get_systime(0)
		i_Gag[gagid] = SysTime
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(gagid, "spk buttons/button6")
			client_cmd(id, "spk buttons/button6")
		}
		switch(get_cvar_num("amx_show_activity"))
		{
			case 0:
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_A0_UNGAG", s_GagTarget)
				WriteMessage(id, Info)
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED")
				WriteMessage(gagid, Info)
			}
			case 1:
			{
				format(Info, charsmax(Info), "[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A1_UNGAG", s_GagTarget)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info)
				}
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED")
				WriteMessage(gagid, Info)
			}
			case 2:
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A2_UNGAG", s_GagAdmin, s_GagTarget)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info)
				}
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED2", s_GagAdmin)
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
					format(p_LogMessage, charsmax(p_LogMessage), "%s - ADMIN %s <%s> has ungaged %s <%s>", p_LogTime, s_GagAdmin, p_LogAdminIp, s_GagTarget, p_LogIp)
					write_file(p_LogFile, p_LogMessage)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}