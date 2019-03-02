/*
* 	Colored Translit v3.0 by Sho0ter
*	Initialization
*/
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("colored_translit.txt")
	
	g_Translit = register_cvar("amx_translit", "1")
	g_Log = register_cvar("amx_translit_log", "1")
	g_AdminPrefix = register_cvar("amx_admin_prefix", "1")
	g_NameColor = register_cvar("amx_name_color", "6")
	g_ChatColor = register_cvar("amx_chat_color", "1")
	g_AllChat = register_cvar("amx_allchat", "0")
	g_Listen = register_cvar("amx_listen", "1")
	g_Sounds = register_cvar("amx_ctsounds", "1")
	g_Country = register_cvar("amx_country_chat", "0")
	g_SwearFilter = register_cvar("amx_swear_filter", "1")
	g_SwearWarns = register_cvar("amx_swear_warns", "3")
	g_SwearImmunity = register_cvar("amx_swear_immunity", "1")
	g_SwearGag = register_cvar("amx_swear_gag", "1")
	g_SwearTime = register_cvar("amx_swear_gag_time", "5")
	g_AutoRus = register_cvar("amx_auto_rus", "1")
	g_ShowInfo = register_cvar("amx_show_info", "1")
	g_Ignore = register_cvar("amx_ignore", "1")
	g_IgnoreMode = register_cvar("amx_ignore_mode", "1")
	g_GagImmunity = register_cvar("amx_gag_immunity", "1")
	g_FloodTime = register_cvar("amx_flood_time", "3")
	g_Spam = register_cvar("amx_spam_filter", "1")
	g_SpamImmunity = register_cvar("amx_spam_immunity", "1")
	g_SpamWarns = register_cvar("amx_spam_warns", "3")
	g_SpamAction = register_cvar("amx_spam_action", "2")
	g_SpamActionTime = register_cvar("amx_spam_time", "60")
	g_Cheat = register_cvar("amx_cheat_filter", "1")
	g_CheatImmunity = register_cvar("amx_cheat_immunity", "1")
	g_CheatAction = register_cvar("amx_cheat_action", "1")
	g_CheatActionTime = register_cvar("amx_cheat_time", "0")
	g_CheatActionCustom = register_cvar("amx_cheat_custom", "")

	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_say_team")
		
	register_concmd("amx_gag", "cmd_gag", ACCESS_LEVEL, "<Nick> <Minutes>")
	register_concmd("amx_ungag", "cmd_ungag", ACCESS_LEVEL, "<Nick>")
	
	fwd_Begin = CreateMultiForward("ct_message_begin", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL)
	fwd_Cheat = CreateMultiForward("ct_message_cheat", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_Spam = CreateMultiForward("ct_message_spam", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_Swear = CreateMultiForward("ct_message_swear", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_Format = CreateMultiForward("ct_message_format", ET_IGNORE, FP_CELL)
	
	get_localinfo("amxx_logs", p_FilePath, 63)
}