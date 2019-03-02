/*
* 	Colored Translit v3.0 by Sho0ter
*	Plugin Stock Functions
*/
stock is_user_gaged(id)
{
	SysTime = get_systime(0)
	if(SysTime < i_Gag[id])
	{
		if(Flood[id])
		{
			format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_FLOOD")
			i_Gag[id] = SysTime + get_pcvar_num(g_FloodTime)
		}
		else
		{
			i_ShowGag = i_Gag[id] - SysTime
			format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_GAGED", i_ShowGag/60+1)
		}
		WriteMessage(id, Info)
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(id, "spk buttons/button2")
		}
		return 1
	}
	else if(Flood[id])
	{
		Flood[id] = false
	}
	return 0
}

stock is_empty_message(const Message[])
{
	if(Message[0] == ' ' || equal(Message, "") || !strlen(Message))
	{
		return 1
	}
	return 0
}

stock is_system_message(const Message[])
{
	if(Message[0] == '@' || Message[0] == '/' || Message[0] == '!')
	{
		return 1
	}
	return 0
}

stock is_cheat_message(id, const Message[])
{
	new i = 0
	if(get_pcvar_num(g_CheatImmunity) && get_user_flags(id) & IMMUNITY_LEVEL)
	{
		return 0
	}
	while(i < CheatNum)
	{
		if(containi(Message, Cheat[i++]) != -1)
		{
			return 1
		}
	}
	return 0
}

stock is_spam_message(id, const Message[])
{
	new i = 0
	if(get_pcvar_num(g_SpamImmunity) && get_user_flags(id) & IMMUNITY_LEVEL)
	{
		return 0
	}
	while(i < SpamNum)
	{
		if(containi(Message, Spam[i++]) != -1)
		{
			return 1
		}
	}
	return 0
}

stock is_ignored_message(const Message[])
{
	new i = 0
	while(i < IgnoreNum)
	{
		if(containi(Message, Ignore[i++]) != -1 || SlashFound)
		{
			return 1
		}
	}
	return 0
}

stock is_swear_message(id, const Message[])
{
	new i = 0
	if(get_user_flags(id) & IMMUNITY_LEVEL && get_pcvar_num(g_SwearImmunity))
	{	
		return 0
	}
	while(i < SwearNum )
	{
		if(containi(Message, Swear[i++]) != -1)
		{
			new j, playercount, players[32]
			get_players( players, playercount, "c" )
			for(j = 0 ; j < playercount ; j++)
			{
				if(get_user_flags(players[j]) & ACCESS_LEVEL && is_user_connected(players[j]))
				{
					format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_CONTAIN", Swear[i-1])
					WriteMessage(players[j], Info)
					console_print(players[j], "[%s] %L", PLUGIN, LANG_PLAYER, "CT_CONTAIN", Swear[i-1])
					format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_SWEAR", s_Name, s_Msg)
					WriteMessage(players[j], Info)
					console_print(players[j], "[%s] %L", PLUGIN, LANG_PLAYER, "CT_SWEAR", s_Name, s_Msg)
				}
			}
			return i
		}
	}
	return 0
}

stock check_plugin_cmd(id, const Message[])
{
	if(equal(Message, "/rus"))
	{
		cmd_rus(id)
		return 0
	}
	if(equal(Message, "/eng"))
	{
		cmd_eng(id)
		return 0
	}
	for(new cmdid; cmdid < CmdsNum; cmdid++)
	{
		if(equal(Message, Cmds[cmdid]))
		{
			return 1
		}
	}
	return 0
}

stock client_punish(id, type)
{
	switch(type)
	{
		case PUNISH_CHEAT:
		{
			switch(get_pcvar_num(g_CheatAction))
			{
				case 1:
				{
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "CT_KICKCHEAT")
				}
				case 2:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("banid ^"%d^" ^"%s^";wait;wait;wait;writeid", get_pcvar_num(g_CheatActionTime), s_BanAuthId)
				}
				case 3:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("addip ^"%d^" ^"%s^";wait;wait;wait;writeip", get_pcvar_num(g_CheatActionTime), s_BanIp)
				}
				case 4:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					format(s_Reason, 127, "[%s] Cheat", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_CheatActionTime), s_BanAuthId, s_Reason)
				}
				case 5:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					format(s_Reason, 127, "[%s] Cheat", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_CheatActionTime), s_BanIp, s_Reason)
				}
				case 6:
				{
					get_user_name(id, s_KickName, charsmax(s_KickName))
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					num_to_str(get_user_userid(id), sUserId, charsmax(sUserId))
					get_pcvar_string(g_CheatActionCustom, s_CheatAction, charsmax(s_CheatAction))
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%userid%", sUserId)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%ip%", s_BanIp)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%steamid%", s_BanAuthId)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%name%", s_KickName)
					server_cmd(s_CheatAction)
				}
			}
			if(get_pcvar_num(g_Log) && get_pcvar_num(g_CheatAction) != 1 && get_pcvar_num(g_CheatAction) != 6 && !Logged[id])
			{
				log_action(id, ACTION_CHEAT)
				Logged[id] = true
			}
		}
		case PUNISH_SPAM:
		{
			switch(get_pcvar_num(g_SpamAction))
			{
				case 1:
				{
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "CT_KICK")
				}
				case 2:
				{
					SysTime = get_systime(0)
					i_Gag[id] = SysTime + get_pcvar_num(g_SpamActionTime) * 60
					format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SPAMGAG", get_pcvar_num(g_SpamActionTime))
					WriteMessage(id, Info)
					Flood[id] = false
					get_user_name(id, s_GagName[id], 31)
					get_user_ip(id, s_GagIp[id], 31, 1)
					if(get_pcvar_num(g_Log))
					{
						format(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
						format(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
						if(!dir_exists(p_LogDir))
						{
							mkdir(p_LogDir)
						}
						get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
						format(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has gaged %s <%s> for %d minutes. Message: %s", p_LogTime, s_GagName[id], s_GagIp[id], get_pcvar_num(g_SpamActionTime), s_Msg)
						write_file(p_LogFile, p_LogMessage)
						if(get_pcvar_num(g_Sounds))
						{
							client_cmd(id, "spk buttons/button5")
						}
					}
				}
				case 3:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("banid ^"%d^" ^"%s^";wait;wait;wait;writeid", get_pcvar_num(g_SpamActionTime), s_BanAuthId)
				}
				case 4:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("addip ^"%d^" ^"%s^";wait;wait;wait;writeip", get_pcvar_num(g_SpamActionTime), s_BanIp)
				}
				case 5:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					format(s_Reason, 127, "[%s] Spam", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_SpamActionTime), s_BanAuthId, s_Reason)
				}
				case 6:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					format(s_Reason, 127, "[%s] Spam", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_SpamActionTime), s_BanIp, s_Reason)
				}
			}
			if(get_pcvar_num(g_Log) && get_pcvar_num(g_SpamAction) > 2)
			{
				log_action(id, ACTION_SPAM)
			}
		}
	}	
}

stock log_action(id, action)
{
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
	format(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
	if(!dir_exists(p_LogDir))
	{
		mkdir(p_LogDir)
	}
	format(p_LogFile, charsmax(p_LogFile), "%s/ban_%s.log", p_LogDir, p_LogFileTime)
	get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
	get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
	get_user_name(id, s_BanName, charsmax(s_BanName))
	switch(action)
	{
		case ACTION_CHEAT:
		{
			if(get_pcvar_num(g_CheatActionTime))
			{
				format(p_LogMessage, charsmax(p_LogMessage), "%s - Cheat Filter has banned %s <%s> <%s> for %d minutes. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, get_pcvar_num(g_CheatActionTime), s_Msg)
			}
			else
			{
				format(p_LogMessage, charsmax(p_LogMessage), "%s - Cheat Filter has banned %s <%s> <%s> permanently. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, s_Msg)
			}
			write_file(p_LogFile, p_LogMessage)
		}
		case ACTION_SPAM:
		{
			if(get_pcvar_num(g_SpamActionTime))
			{
				format(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has banned %s <%s> <%s> for %d minutes. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, get_pcvar_num(g_SpamActionTime), s_Msg)
			}
			else
			{
				format(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has banned %s <%s> <%s> permanently. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, s_Msg)
			}
			write_file(p_LogFile, p_LogMessage)
		}
	}
}

stock ReplaceSwear(Size, Message[])
{
	copy(s_SwearMsg, Size, Message)
	replace_all(s_SwearMsg, Size, " ", "")
	replace_all(s_SwearMsg, Size, "A", "a")
	replace_all(s_SwearMsg, Size, "B", "b")
	replace_all(s_SwearMsg, Size, "C", "c")
	replace_all(s_SwearMsg, Size, "D", "d")
	replace_all(s_SwearMsg, Size, "E", "e")
	replace_all(s_SwearMsg, Size, "F", "f")
	replace_all(s_SwearMsg, Size, "G", "g")
	replace_all(s_SwearMsg, Size, "H", "h")
	replace_all(s_SwearMsg, Size, "I", "i")
	replace_all(s_SwearMsg, Size, "J", "j")
	replace_all(s_SwearMsg, Size, "K", "k")
	replace_all(s_SwearMsg, Size, "L", "l")
	replace_all(s_SwearMsg, Size, "M", "m")
	replace_all(s_SwearMsg, Size, "N", "n")
	replace_all(s_SwearMsg, Size, "O", "o")
	replace_all(s_SwearMsg, Size, "P", "p")
	replace_all(s_SwearMsg, Size, "Q", "q")
	replace_all(s_SwearMsg, Size, "R", "r")
	replace_all(s_SwearMsg, Size, "S", "s")
	replace_all(s_SwearMsg, Size, "T", "t")
	replace_all(s_SwearMsg, Size, "U", "u")
	replace_all(s_SwearMsg, Size, "V", "v")
	replace_all(s_SwearMsg, Size, "W", "w")
	replace_all(s_SwearMsg, Size, "X", "x")
	replace_all(s_SwearMsg, Size, "Y", "y")
	replace_all(s_SwearMsg, Size, "Z", "z")
	replace_all(s_SwearMsg, Size, "{", "[")
	replace_all(s_SwearMsg, Size, "}", "]")
	replace_all(s_SwearMsg, Size, "<", ",")
	replace_all(s_SwearMsg, Size, ">", ".")
	replace_all(s_SwearMsg, Size, "~", "`")
	replace_all(s_SwearMsg, Size, "*", "")
	replace_all(s_SwearMsg, Size, "_", "")
}

stock SendMessage(color[], alive)
{
	for(new player = 0; player <= get_maxplayers(); player++)
	{
		if(!is_user_connected(player))
		{
			continue
		}
		if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL)
		{
			console_print(player, "%s : %s", s_Name, s_Msg)
			get_user_team(player, TeamName, 9)
			ChangeTeamInfo(player, color)
			WriteMessage(player, Message)
			ChangeTeamInfo(player, TeamName)
		}
	}
}

stock SendMessageAll(color[])
{
	for(new player = 0; player <= get_maxplayers(); player++)
	{
		if(!is_user_connected(player))
		{
			continue
		}
		console_print(player, "%s : %s", s_Name, s_Msg)
		get_user_team(player, TeamName, 9)
		ChangeTeamInfo(player, color)
		WriteMessage(player, Message)
		ChangeTeamInfo(player, TeamName)
	}
}

stock SendTeamMessage(color[], alive, playerTeam)
{
	for (new player = 0; player <= get_maxplayers(); player++)
	{
		if (!is_user_connected(player))
		{
			continue
		}
		if(get_user_team(player) == playerTeam || (get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL))
		{
			if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL)
			{
				console_print(player, "%s : %s", s_Name, s_Msg)
				get_user_team(player, TeamName, 9)
				ChangeTeamInfo(player, color)
				WriteMessage(player, Message)
				ChangeTeamInfo(player, TeamName)
			}
		}
	}
}


stock ChangeTeamInfo(player, team[])
{
	message_begin (MSG_ONE, get_user_msgid("TeamInfo"), _, player)
	write_byte(player)
	write_string(team)
	message_end()
}


stock WriteMessage(player, message[])
{
	message_begin (MSG_ONE, get_user_msgid("SayText"), _, player)
	write_byte(player)
	write_string(message)
	message_end()
}