/*
* 	Colored Translit v3.0 by Sho0ter
*	Files Loader 
*/
public plugin_cfg()
{
	get_configsdir(s_ConfigsDir, 63)
	format(s_File, charsmax(s_File), "%s/colored_translit/translit.ini", s_ConfigsDir)
	format(s_SwearFile, charsmax(s_File), "%s/colored_translit/swears.ini", s_ConfigsDir)
	format(s_ReplaceFile, charsmax(s_ReplaceFile), "%s/colored_translit/replaces.ini", s_ConfigsDir)
	format(s_IgnoreFile, charsmax(s_IgnoreFile), "%s/colored_translit/ignores.ini", s_ConfigsDir)
	format(s_SpamFile,  charsmax(s_SpamFile), "%s/colored_translit/spam.ini", s_ConfigsDir)
	format(s_CheatFile,  charsmax(s_CheatFile), "%s/colored_translit/cheat.ini", s_ConfigsDir)
	format(s_ConfigFile, charsmax(s_ConfigFile), "%s/colored_translit/config.cfg", s_ConfigsDir)
	if(file_exists(s_File))
	{
		while((Line = read_file(s_File, Line, Input, 31, Len)) != 0)
		{
			strtok(Input, g_OriginalSimb[i_MaxSimbols], 16, g_TranslitSimb[i_MaxSimbols], 16, ' ')
			i_MaxSimbols++
		}
		TranslitList = true
	}
	else
	{
		set_pcvar_num(g_Translit, 0)
		TranslitList = false
	}
	if(file_exists(s_SwearFile))
	{
		new i=0
		while(i < MAX_SWEARS && read_file(s_SwearFile, i , Swear[SwearNum], 63, Len))
		{
			i++
			if(Swear[SwearNum][0] == ';' || !Len)
			{
				continue
			}
			SwearNum++
		}
		SwearList = true
	}
	else
	{
		set_pcvar_num(g_SwearFilter, 0)
		SwearList = false
	}
	if(file_exists(s_ReplaceFile))
	{
		new i=0
		while(i < MAX_REPLACES && read_file(s_ReplaceFile, i , Replace[ReplaceNum], 191, Len))
		{
			i++
			if(Replace[ReplaceNum][0] == ';' || !Len)
			{
				continue
			}
			ReplaceNum++
		}
		ReplaceList = true
	}
	else
	{
		set_pcvar_num(g_SwearFilter, 0)
		ReplaceList = false
	}
	if(file_exists(s_IgnoreFile))
	{
		new i=0
		while(i < MAX_IGNORES && read_file(s_IgnoreFile, i , Ignore[IgnoreNum], 63, Len))
		{
			i++
			if(Ignore[IgnoreNum][0] == ';' || !Len)
			{
				continue
			}
			IgnoreNum++
		}
		IgnoreList = true
	}
	else
	{
		set_pcvar_num(g_Ignore, 0)
		IgnoreList = false
	}
	if(file_exists(s_SpamFile))
	{
		new i=0
		while(i < MAX_SPAMS && read_file(s_SpamFile, i , Spam[SpamNum], 191, Len))
		{
			i++
			if(Spam[SpamNum][0] == ';' || !Len)
			{
				continue
			}
			SpamNum++
		}
		SpamList = true
	}
	else
	{
		set_pcvar_num(g_Spam, 0)
		SpamList = false
	}
	if(file_exists(s_CheatFile))
	{
		new i=0
		while(i < MAX_CHEAT && read_file(s_CheatFile, i , Cheat[CheatNum], 191, Len))
		{
			i++
			if(Cheat[CheatNum][0] == ';' || !Len)
			{
				continue
			}
			CheatNum++
		}
		CheatList = true
	}
	else
	{
		set_pcvar_num(g_Cheat, 0)
		CheatList = false
	}
	if(file_exists(s_ConfigFile))
	{
		server_cmd("exec %s", s_ConfigFile)
		ConfigsList = true
	}
	else
	{
		ConfigsList = false
	}
	server_print("========== [%s] START SET FCVAR ==========", PLUGIN)
	register_cvar("Colored Translit Version", "2.0b Final", FCVAR_SERVER)
	if(TranslitList)
	{
		register_cvar("Colored Translit Status", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Status", "Failed", FCVAR_SERVER)
	}
	if(SwearList)
	{
		register_cvar("Colored Translit Swear", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Swear", "Failed", FCVAR_SERVER)
	}
	if(ReplaceList)
	{
		register_cvar("Colored Translit Replace", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Replace", "Failed", FCVAR_SERVER)
	}
	if(IgnoreList)
	{
		register_cvar("Colored Translit Ignores", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Ignores", "Failed", FCVAR_SERVER)
	}
	if(SpamList)
	{
		register_cvar("Colored Translit Spam", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Spam", "Failed", FCVAR_SERVER)
	}
	if(CheatList)
	{
		register_cvar("Colored Translit Cheat", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Cheat", "Failed", FCVAR_SERVER)
	}
	if(ConfigsList)
	{
		register_cvar("Colored Translit Config", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Config", "Failed", FCVAR_SERVER)
	}
	server_print("=========== [%s] END SET FCVAR ===========", PLUGIN)
	server_print("=========== [%s] START DEBUG =============", PLUGIN)
	if(TranslitList)
	{
		server_print("[%s] Translit File Loaded. Symbols: %d", PLUGIN, i_MaxSimbols)
	}
	else
	{
		server_print("[%s] Translit File Not Found: %s", PLUGIN, s_File)
	}
	if(SwearList)
	{
		server_print("[%s] Swear File Loaded. Swears: %d", PLUGIN, SwearNum)	
	}
	else
	{
		server_print("[%s] Swear File Not Found: %s", PLUGIN, s_SwearFile)
	}
	if(ReplaceList)
	{
		server_print("[%s] Replace File Loaded. Replacements: %d", PLUGIN, ReplaceNum)	
	}
	else
	{
		server_print("[%s] Replace File Not Found: %s", PLUGIN, s_ReplaceFile)
	}
	if(IgnoreList)
	{
		server_print("[%s] Ignore File Loaded. Ignore Words: %d", PLUGIN, IgnoreNum)
	}
	else
	{
		server_print("[%s] Ignore File Not Found: %s", PLUGIN, s_IgnoreFile)
	}
	if(SpamList)
	{
		server_print("[%s] Spam File Loaded. Spam Words: %d", PLUGIN, SpamNum)
	}
	else
	{
		server_print("[%s] Spam File Not Found: %s", PLUGIN, s_SpamFile)
	}
	if(CheatList)
	{
		server_print("[%s] Cheat File Loaded. Cheat Words: %d", PLUGIN, CheatNum)
	}
	else
	{
		server_print("[%s] Cheat File Not Found: %s", PLUGIN, s_CheatFile)
	}
	if(ConfigsList)
	{
		server_print("[%s] Config File Executed. Version: %s", PLUGIN, VERSION)
	}
	else
	{
		server_print("[%s] Config File Not Found: %s", PLUGIN, s_ConfigFile)
	}
	server_print("=========== [%s] END DEBUG ===============", PLUGIN)
	return PLUGIN_CONTINUE
}