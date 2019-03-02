/*
* 	Colored Translit v3.0 by Sho0ter
*	Say Messager
*/
public hook_say(id)
{
	if(is_user_hltv(id) || is_user_bot(id))
	{
		return PLUGIN_CONTINUE
	}
	if(is_user_gaged(id))
	{
		return PLUGIN_HANDLED
	}
	read_args(s_Msg, charsmax(s_Msg))
	remove_quotes(s_Msg)
	replace_all(s_Msg, charsmax(s_Msg), "%s", "")
	for(new posid; posid < 4; posid++)
	{
		AddsNum[posid] = 0
	}
	ExecuteForward(fwd_Begin, fwdResult, id, s_Msg, 0)
	if(check_plugin_cmd(id, s_Msg))
	{
		return PLUGIN_CONTINUE
	}
	if(is_empty_message(s_Msg))
	{
		return PLUGIN_HANDLED
	}
	if(is_system_message(s_Msg))
	{
		if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			SlashFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		SlashFound = false
	}
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
	if(get_pcvar_num(g_Cheat) && is_cheat_message(id, s_Msg))
	{
		ExecuteForward(fwd_Cheat, fwdResult, id, s_Msg)
		client_punish(id, PUNISH_CHEAT)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Spam) && is_spam_message(id, s_Msg))
	{
		ExecuteForward(fwd_Spam, fwdResult, id, s_Msg)
		SpamFound[id]++
		if(SpamFound[id]-1 >= get_pcvar_num(g_SpamWarns))
		{
			SpamFound[id] = 0
			client_punish(id, PUNISH_SPAM)
		}
		else
		{
			format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SPAMWARN", get_pcvar_num(g_SpamWarns) - SpamFound[id])
			WriteMessage(id, Info)
			if(get_pcvar_num(g_Sounds))
			{
				client_cmd(id, "spk buttons/blip2")
			}
		}
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Ignore) && is_ignored_message(s_Msg))
	{
		if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			IgnoreFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		IgnoreFound = false
	}
	get_user_team(id, AliveTeam, charsmax(AliveTeam))
	ReplaceSwear(charsmax(s_Msg), s_Msg)
	if(get_pcvar_num(g_Translit) && !IgnoreFound)
	{
		get_user_info(id, "translit", s_Info, charsmax(s_Info))
		if(equal(s_Info, "1") || get_pcvar_num(g_AutoRus) == 2)
		{
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_SwearMsg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_SwearMsg, charsmax(s_SwearMsg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_Msg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_Msg, charsmax(s_Msg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
		}
	}
	get_user_name(id, s_Name, charsmax(s_Name))
	if(get_pcvar_num(g_SwearFilter))
	{
		new iSwear = is_swear_message(id, s_SwearMsg)
		if(iSwear)
		{
			ExecuteForward(fwd_Swear, fwdResult, id, s_Msg)
		}
		if(iSwear)
		{
			SwearFound = 1
			SwearCount[id]++
			if(get_pcvar_num(g_SwearGag) && (SwearCount[id]-1 >= get_pcvar_num(g_SwearWarns)))
			{
				SwearCount[id] = 0
				Flood[id] = false
				SysTime = get_systime(0)
				i_Gag[id] = SysTime + get_pcvar_num(g_SwearTime)*60
				get_user_name(id, s_GagName[id], 31)
				get_user_ip(id, s_GagIp[id], 31, 1)
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEAR_GAG", get_pcvar_num(g_SwearTime))
				WriteMessage(id, Info)
				if(get_pcvar_num(g_Log) == 1)
				{
					format(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
					format(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
					format(p_LogMessage, charsmax(p_LogMessage), "%s - Swear Filter has gaged %s <%s> for %d minutes. Message: %s. Found: %s", p_LogTime, s_GagName[id], p_LogIp, get_pcvar_num(g_SwearTime), s_SwearMsg, Swear[iSwear - 1])
					write_file(p_LogFile, p_LogMessage)
				}
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/button5")
				}
			}
			else if(get_pcvar_num(g_SwearGag))
			{
				format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEARWARN", get_pcvar_num(g_SwearWarns) - SwearCount[id])
				WriteMessage(id, Info)
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/blip2")
				}
			}
		}
		else
		{
			SwearFound = 0
		}
	}
	if(get_pcvar_num(g_Country))
	{
		get_user_ip(id, s_CountryIp, charsmax(s_CountryIp))
		switch(get_pcvar_num(g_Country))
		{
			case 1:
			{
				geoip_country(s_CountryIp, s_Country1)
				format(s_Country, charsmax(s_Country), "%s", s_Country1)
			}
			case 2:
			{
				geoip_code2(s_CountryIp, s_Country2)
				format(s_Country, charsmax(s_Country), "%s", s_Country2)
			}
			case 3:
			{
				geoip_code3(s_CountryIp, s_Country3)
				format(s_Country, charsmax(s_Country), "%s", s_Country3)
			}
		}
	}
	ExecuteForward(fwd_Format, fwdResult, id)
	mLen = 0
	lgLen = 0
	new posnum
	mLen = format(Message, charsmax(Message), "^x01")
	if(AddsNum[CT_MSGPOS_START])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_START]; posnum++)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_START][posnum])
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">%s </font>", Adds[CT_MSGPOS_START][posnum])
		}
	}
	if(!is_user_alive(id) && !equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen += format(Message[mLen], charsmax(Message) - mLen, "^x01*%L* ", LANG_PLAYER, "CT_DEAD")
		lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">*%L* </font>", LANG_PLAYER, "CT_DEAD")
	}
	else if(!is_user_alive(id) && equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen += format(Message[mLen], charsmax(Message) - mLen, "^x01*%L* ", LANG_PLAYER, "CT_SPECTATOR")
		lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">*%L* </font>", LANG_PLAYER, "CT_SPECTATOR")
	}
	else
	{
		isAlive = 1
		mLen += format(Message[mLen], charsmax(Message) - mLen, "^x01")
	}
	if(AddsNum[CT_MSGPOS_PREFIX])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PREFIX]; posnum++)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PREFIX][posnum])
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">%s </font>", Adds[CT_MSGPOS_PREFIX][posnum])
		}
	}
	if(get_pcvar_num(g_Country))
	{
		get_user_ip(id, s_CountryIp, charsmax(s_CountryIp))
		if(containi(s_CountryIp, "10.") == 0)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "[^x04%L^x01] ", LANG_PLAYER, "CT_LAN")
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">[%L] </font>", LANG_PLAYER, "CT_LAN")
		}
		else if(containi(s_CountryIp, "172.") == 0)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "[^x04%L^x01] ", LANG_PLAYER, "CT_PROVIDER")
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">[%L] </font>", LANG_PLAYER, "CT_PROVIDER")
		}
		else if(containi(s_Country, "err") != -1)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "[^x04%L^x01] ", LANG_PLAYER, "CT_ERROR")
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">[%L] </font>", LANG_PLAYER, "CT_ERROR")
		}
		else
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "[^x04%s^x01] ", s_Country)
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">[%s] </font>", s_Country)
		}
	}
	if(get_user_flags(id) & NICK_LEVEL && get_pcvar_num(g_AdminPrefix))
	{
		mLen += format(Message[mLen], charsmax(Message) - mLen, "[^x04%L^x01] ", LANG_PLAYER, "CT_ADMIN")
		lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">[%L] </font>", LANG_PLAYER, "CT_ADMIN")
	}
	if(AddsNum[CT_MSGPOS_PRENAME])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PRENAME]; posnum++)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PRENAME][posnum])
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">%s </font>", Adds[CT_MSGPOS_PRENAME][posnum])
		}
	}
	if(get_user_flags(id) & NICK_LEVEL)
	{
		switch(get_pcvar_num(g_NameColor))
		{
			case 1:
			{
				mLen += format(Message[mLen], charsmax(Message) - mLen, "%s", s_Name)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">%s </font>", s_Name)
			}
			case 2:
			{
				mLen += format(Message[mLen], charsmax(Message) - mLen, "^x04%s^x01 ", s_Name)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">%s </font>", s_Name)
			}
			case 3:
			{
				color = "SPECTATOR"
				mLen += format(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"gray^">%s </font>", s_Name)
			}
			case 4:
			{
				color = "CT"
				mLen += format(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"blue^">%s </font>", s_Name)
			}
			case 5:
			{
				color = "TERRORIST"
				mLen += format(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"red^">%s </font>", s_Name)
			}
			case 6:
			{
				get_user_team(id, color, charsmax(color))
				mLen += format(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				if(equal(color, "CT"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"blue^">%s </font>", s_Name)
				}
				else if(equal(color, "TERRORIST"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"red^">%s </font>", s_Name)
				}
				else if(equal(color, "SPECTATOR"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"gray^">%s </font>", s_Name)
				}

			}
		}
		switch(get_pcvar_num(g_ChatColor))
		{
			case 1:
			{
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": %s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^">: %s </font>", s_Msg)
			}
			case 2:
			{
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": ^x04%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"green^">: %s </font>", s_Msg)
			}
			case 3:
			{
				copy(color, 9, "SPECTATOR")
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"gray^">: %s </font>", s_Msg)
			}
			case 4:
			{
				copy(color, 9, "CT")
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"blue^">: %s </font>", s_Msg)
			}
			case 5:
			{
				copy(color, 9, "TERRORIST")
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"red^">: %s </font>", s_Msg)
			}
			case 6:
			{
				get_user_team(id, TeamColor, 9)
				copy(color, 9, TeamColor)
				mLen += format(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				if(equal(TeamColor, "CT"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"blue^">: %s </font>", s_Msg)
				}
				else if(equal(TeamColor, "TERRORIST"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"red^">: %s </font>", s_Msg)
				}
				else if(equal(TeamColor, "SPECTATOR"))
				{
					lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"gray^">: %s </font>", s_Msg)
				}
			}
		}
	}
	else
	{
		get_user_team(id, color, 9)
		mLen += format(Message[mLen], charsmax(Message) - mLen, "^x03%s ^x01: %s", s_Name, SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
		if(equal(color, "CT"))
		{
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"blue^">%s </font><font color=^"#FFB41E^">: %s </font>", s_Name, s_Msg)
		}
		else if(equal(color, "TERRORIST"))
		{
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"red^">%s </font><font color=^"#FFB41E^">: %s </font>", s_Name, s_Msg)
		}
		else if(equal(color, "SPECTATOR"))
		{
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"gray^">%s </font><font color=^"#FFB41E^">: %s </font>", s_Name, s_Msg)
		}
	}
	if(AddsNum[CT_MSGPOS_END])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_END]; posnum++)
		{
			mLen += format(Message[mLen], charsmax(Message) - mLen, " %s", Adds[CT_MSGPOS_END][posnum])
			lgLen += format(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "<font color=^"#FFB41E^"> %s</font>", Adds[CT_MSGPOS_END][posnum])
		}
	}
	if(strlen(Message) >= 192)
	{
		format(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_LONGMSG")
		WriteMessage(id, Info)
		return PLUGIN_HANDLED
	}
	switch(get_pcvar_num(g_AllChat))
	{
		case 0:
		{
			SendMessage(color, isAlive)
		}
		case 1:
		{
			SendMessageAll(color)
		}
		case 2:
		{
			if(get_user_flags(id) & ACCESS_LEVEL)
			{
				SendMessageAll(color)
			}
			else
			{
				SendMessage(color, isAlive)
			}
		}
	}
	if(get_pcvar_num(g_Log))
	{
		format(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
		format(p_LogFile, charsmax(p_LogFile), "%s/chat_%s.htm", p_LogDir, p_LogFileTime)
		if(!dir_exists(p_LogDir))
		{
			mkdir(p_LogDir)
		}
		if(!file_exists(p_LogFile))
		{
			format(p_LogTitle, charsmax(p_LogTitle), "<title>Colored Ctranslit Chat Log v3.0 by Sho0ter - %s</title>%s", p_LogFileTime, LOGTITLE)
			write_file(p_LogFile, p_LogTitle)
			write_file(p_LogFile, LOGFONT)
		}
		get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
		get_user_authid(id, p_LogSteamId, charsmax(p_LogSteamId))
		format(p_LogInfo, charsmax(p_LogInfo), "<font color=^"black^">%s &lt;%s&gt;&lt;%s&gt;</font>", p_LogTime, p_LogSteamId, p_LogIp)
		format(p_LogMessage, charsmax(p_LogMessage), "%s - %s<br>", p_LogInfo, p_LogMsg)
		write_file(p_LogFile, p_LogMessage)
	}
	if((!SwearFound || get_pcvar_num(g_SwearGag) != 1) && get_pcvar_num(g_FloodTime))
	{
		SysTime = get_systime(0)
		i_Gag[id] = SysTime + get_pcvar_num(g_FloodTime)
		Flood[id] = true
	}
	return PLUGIN_HANDLED
}