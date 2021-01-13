#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Vote Ban"
#define VERSION "1.0"
#define AUTHOR "Alka"

#define MAX_PLAYERS 33

#define MENU_KEYS (1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7 | 1<<8 | 1<<9)
#define MENU_SLOTS 8

new g_iMenuPage[MAX_PLAYERS];
new g_iVotedPlayers[MAX_PLAYERS];
new g_iVotes[MAX_PLAYERS];
new g_szVoteReason[MAX_PLAYERS][64];

new g_iPlayers[MAX_PLAYERS - 1];
new g_iNum;

new g_iMsgidSayText;

enum {
	CVAR_PERCENT = 0,
	CVAR_BANTYPE,
	CVAR_BANTIME
};
new g_szCvarName[][] = {
	"voteban_percent",
	"voteban_type",
	"voteban_time"
};
new g_szCvarValue[][] = {
	"80",
	"1",
	"100"
};
new g_iPcvar[3];
new g_szLogFile[64];

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_saycmd("voteban", "Cmd_VoteBan", -1, "");
	register_clcmd("_voteban_reason", "Cmd_VoteBanReason", -1, "");
	
	register_menucmd(register_menuid("\rVOTEBAN \yMenu:"), MENU_KEYS, "Menu_VoteBan");
	
	for(new i = 0 ; i < 3 ; i++)
	{
		g_iPcvar[i] = register_cvar(g_szCvarName[i], g_szCvarValue[i]);
	}
	g_iMsgidSayText = get_user_msgid("SayText");
	
	new szLogInfo[] = "amx_logdir";
	get_localinfo(szLogInfo, g_szLogFile, charsmax(g_szLogFile));
	add(g_szLogFile, charsmax(g_szLogFile), "/voteban");
	
	if(!dir_exists(g_szLogFile))
		mkdir(g_szLogFile);
		
	new szTime[32];
	get_time("%d-%m-%Y", szTime, charsmax(szTime));
	format(g_szLogFile, charsmax(g_szLogFile), "%s/%s.log", g_szLogFile, szTime);
}

public client_disconnect(id)
{
	if(g_iVotedPlayers[id])
	{
		get_players(g_iPlayers, g_iNum, "h");
		
		for(new i = 0 ; i < g_iNum ; i++)
		{
			if(g_iVotedPlayers[id] & (1 << g_iPlayers[i]))
			{
				g_iVotes[g_iPlayers[i]]--;
			}
		}
		g_iVotedPlayers[id] = 0;
	}
}

public Cmd_VoteBan(id)
{
	get_players(g_iPlayers, g_iNum, "h");
	
	if(g_iNum < 3)
	{
		client_printc(id, "\g> \dThis command is unavailable! Need at least 3 players.");
		return PLUGIN_HANDLED;
	}
	ShowBanMenu(id, g_iMenuPage[id] = 0);
	return PLUGIN_CONTINUE;
}

public ShowBanMenu(id, iPos)
{
	static i, iPlayer, szName[32];
	static szMenu[256], iCurrPos; iCurrPos = 0;
	static iStart, iEnd; iStart = iPos * MENU_SLOTS;
	static iKeys;
	
	get_players(g_iPlayers, g_iNum, "h");
	
	if(iStart >= g_iNum)
	{
		iStart = iPos = g_iMenuPage[id] = 0;
	}
	
	static iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\rVOTEBAN \yMenu:^n^n");
	
	iEnd = iStart + MENU_SLOTS;
	iKeys = MENU_KEY_0;
	
	if(iEnd > g_iNum)
	{
		iEnd = g_iNum;
	}
	
	for(i = iStart ; i < iEnd ; i++)
	{
		iPlayer = g_iPlayers[i];
		get_user_name(iPlayer, szName, charsmax(szName));
		
		iKeys |= (1 << iCurrPos++);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d\w.%s \d(\r%d%%\d)^n", iCurrPos, szName, get_percent(g_iVotes[iPlayer], g_iNum));
	}
	
	if(iEnd != g_iNum)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r9\w.Next ^n\r0\w.%s", iPos ? "Back" : "Exit");
		iKeys |= MENU_KEY_9;
	}
	else
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r0\w.%s", iPos ? "Back" : "Exit");
	}
	show_menu(id, iKeys, szMenu, -1, "");
	return PLUGIN_HANDLED;
}

public Menu_VoteBan(id, key)
{
	switch(key)
	{
		case 8:
		{
			ShowBanMenu(id, ++g_iMenuPage[id]);
		}
		case 9:
		{
			if(!g_iMenuPage[id])
				return PLUGIN_HANDLED;
			
			ShowBanMenu(id, --g_iMenuPage[id]);
		}
		default: {
			static iPlayer;
			iPlayer = g_iPlayers[g_iMenuPage[id] * MENU_SLOTS + key];
			
			if(!is_user_connected(iPlayer))
			{
				ShowBanMenu(id, g_iMenuPage[id]);
				return PLUGIN_HANDLED;
			}
			if(iPlayer == id)
			{
				client_print(id, print_center, "*You cannot voteban yourself!*");
				ShowBanMenu(id, g_iMenuPage[id]);
				
				return PLUGIN_HANDLED;
			}
			if(g_iVotedPlayers[id] & (1 << iPlayer))
			{
				client_print(id, print_center, "*You already votebanned this player!*");
				ShowBanMenu(id, g_iMenuPage[id]);
				
				return PLUGIN_HANDLED;
			}
			g_iVotes[iPlayer]++;
			g_iVotedPlayers[id] |= (1 << iPlayer);
			
			static szName[2][32];
			get_user_name(id, szName[0], charsmax(szName[]));
			get_user_name(iPlayer, szName[1], charsmax(szName[]));
			
			client_printc(0, "\g> \dPlayer \t%s \dvotebanned \t%s\d!", szName[0], szName[1]);
			
			CheckVotes(iPlayer, id);
			client_cmd(id, "messagemode _voteban_reason");
			
			ShowBanMenu(id, g_iMenuPage[id]);
		}
	}
	return PLUGIN_HANDLED;
}

public Cmd_VoteBanReason(id)
{
	if(!g_iVotedPlayers[id])
		return PLUGIN_HANDLED;
	
	new szArgs[64];
	read_argv(1, szArgs, charsmax(szArgs));
	
	if(szArgs[0])
	{
		formatex(g_szVoteReason[id], charsmax(g_szVoteReason[]), szArgs);
	}
	return PLUGIN_HANDLED;
}

public CheckVotes(id, voter)
{
	get_players(g_iPlayers, g_iNum, "h");
	new iPercent = get_percent(g_iVotes[id], g_iNum);
	
	if(iPercent >= get_pcvar_num(g_iPcvar[CVAR_PERCENT]))
	{
		switch(get_pcvar_num(g_iPcvar[CVAR_BANTYPE]))
		{
			case 1:
			{
				new szAuthid[32];
				get_user_authid(id, szAuthid, charsmax(szAuthid));
				server_cmd("kick #%d;wait;wait;wait;banid %d ^"%s^";wait;wait;wait;writeid", get_user_userid(id), get_pcvar_num(g_iPcvar[CVAR_BANTIME]), szAuthid);
			}
			case 2:
			{
				new szIp[32];
				get_user_ip(id, szIp, charsmax(szIp), 1);
				server_cmd("kick #%d;wait;wait;wait;addip %d ^"%s^";wait;wait;wait;writeip", get_user_userid(id), get_pcvar_num(g_iPcvar[CVAR_BANTIME]), szIp);
			}
		}
		g_iVotes[id] = 0;
		
		new szName[2][32];
		get_user_name(id, szName[0], charsmax(szName[]));
		get_user_name(id, szName[1], charsmax(szName[]));
		client_printc(0, "\g> \dPlayer \t%s \dhas been banned for \g%d\dmin. due voteban!", szName[0], get_pcvar_num(g_iPcvar[CVAR_BANTIME]));
		
		log_to_file(g_szLogFile, "Player '%s' voted for banning '%s' for: %s", szName[1], szName[0], g_szVoteReason[voter]);
	}
}

stock get_percent(value, tvalue)
{     
	return floatround(floatmul(float(value) / float(tvalue) , 100.0));
}

stock register_saycmd(saycommand[], function[], flags = -1, info[])
{
	static szTemp[64];
	formatex(szTemp, charsmax(szTemp), "say %s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team %s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say /%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say .%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team /%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
	formatex(szTemp, charsmax(szTemp), "say_team .%s", saycommand);
	register_clcmd(szTemp, function, flags, info);
}

stock client_printc(id, const text[], any:...)
{
	
	new szMsg[191], iPlayers[32], iCount = 1;
	vformat(szMsg, charsmax(szMsg), text, 3);
	
	replace_all(szMsg, charsmax(szMsg), "\g","^x04");
	replace_all(szMsg, charsmax(szMsg), "\d","^x01");
	replace_all(szMsg, charsmax(szMsg), "\t","^x03");
	
	if(id)
		iPlayers[0] = id;
	else
		get_players(iPlayers, iCount, "ch");
	
	for(new i = 0 ; i < iCount ; i++)
	{
		if(!is_user_connected(iPlayers[i]))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_iMsgidSayText, _, iPlayers[i]);
		write_byte(iPlayers[i]);
		write_string(szMsg);
		message_end();
	}
}
