#include <amxmodx>
#include <amxmisc>

//#define DEBUG

enum _:MessageData
{
	md_trie,
	md_total
};

new Array:g_message_data;
new Trie:g_ignore_commands;

new Float:g_warning_delay[33];

new cvar_enabled;
new cvar_samecount;
new cvar_minlen;
new cvar_warndelay;
new cvar_slash;

new g_maxclients;

public plugin_init()
{
	register_plugin("Anti-ChatSpam", "0.6.1", "Exolent");
	register_dictionary("antispam.txt")
	
	register_clcmd("say", "CmdSay");
	register_clcmd("say_team", "CmdSayTeam");
	
	cvar_enabled = register_cvar("antispam_enabled", "1");
	cvar_samecount = register_cvar("antispam_samecount", "5");
	cvar_minlen = register_cvar("antispam_minlen", "14");
	cvar_warndelay = register_cvar("antispam_warndelay", "1.5");
	cvar_slash = register_cvar("antispam_slash", "0");
	
	g_maxclients = get_maxplayers();
	g_message_data = ArrayCreate(MessageData);
	
	new data[MessageData];
	ArrayPushArray(g_message_data, data);
	
	for( new client = 1; client <= g_maxclients; client++ )
	{
		data[md_trie] = _:TrieCreate();
		ArrayPushArray(g_message_data, data);
	}
	
	g_ignore_commands = TrieCreate();
	
	LoadIgnoreCommands();
}

public plugin_end()
{
	new data[MessageData];
	for( new client = 1; client <= g_maxclients; client++ )
	{
		ArrayGetArray(g_message_data, client, data);
		TrieDestroy(Trie:data[md_trie]);
	}
	ArrayDestroy(g_message_data);
	TrieDestroy(g_ignore_commands);
}

public client_disconnect(client)
{
	static data[MessageData];
	ArrayGetArray(g_message_data, client, data);
	
	if( data[md_total] )
	{
		TrieClear(Trie:data[md_trie]);
		data[md_total] = 0;
		
		ArraySetArray(g_message_data, client, data);
	}
	
	g_warning_delay[client] = 0.0;
}

public CmdSay(client)
{
	return get_pcvar_num(cvar_enabled) ? CheckSay(client, false) : PLUGIN_CONTINUE;
}

public CmdSayTeam(client)
{
	return get_pcvar_num(cvar_enabled) ? CheckSay(client, true) : PLUGIN_CONTINUE;
}

LoadIgnoreCommands()
{
	new filename[64];
	get_configsdir(filename, sizeof(filename) - 1);
	add(filename, sizeof(filename) - 1, "/antispam.ini");
	
	if( !file_exists(filename) ) return;
	
	new f = fopen(filename, "rt");
	
	if( !f ) return;
	
	new data[64], command[64], flag[5];
	while( !feof(f) )
	{
		fgets(f, data, sizeof(data) - 1);
		
		if( !data[0]
		|| data[0] == ';'
		|| data[0] == '/' && data[1] == '/' ) continue;
		
		strbreak(data, command, sizeof(command) - 1, flag, sizeof(flag) - 1);
		TrieSetCell(g_ignore_commands, command, str_to_num(flag));
		
#if defined DEBUG
		log_amx("Loaded command: ^"%s^", flag: %s", command, flag);
#endif
	}
	
	fclose(f);
}

CheckSay(client, bool:say_team)
{
	static message[192];
	read_args(message, sizeof(message) - 1);
	remove_quotes(message);
	trim(message);
	strtolower(message);
	
	if( !message[0] ) return PLUGIN_CONTINUE;
	
	if( !say_team && message[0] == '@' )
	{
		if( access(client, ADMIN_CHAT) )
		{
			new count;
			for( new i = 1; i <= 4; i++ )
			{
				if( message[i] == '@' ) count++;
			}
			
			if( count < 3 ) return PLUGIN_CONTINUE;
		}
	}
	
	static command[64];
	copy(command, sizeof(command) - 1, message);
	
#if defined DEBUG
	log_amx("Message data: ^"%s^"", command);
#endif
	
	new len = strlen(command);
	for( new i = 0; i < len; i++ )
	{
		if( command[i] == ' ' )
		{
			command[i] = 0;
			break;
		}
	}
	
#if defined DEBUG
	log_amx("Message -> command: ^"%s^"", command);
#endif
	
	new bool:flag;
	if( TrieGetCell(g_ignore_commands, command, flag) && (!say_team || flag) ) return PLUGIN_CONTINUE;
	
#if defined DEBUG
	log_amx("Command not found in ignored commands list");
#endif
	
	if( message[0] == '/' )
	{
#if defined DEBUG
		log_amx("Message used slash command, checking if command exists");
#endif
		new slash = get_pcvar_num(cvar_slash);
		
		if( slash && (!say_team || slash == 2) && SayCommandExists(client, command[1]) ) return PLUGIN_CONTINUE;
		
#if defined DEBUG
		log_amx("Slash command did not exist");
#endif
	}
	
	if( strlen(message) < get_pcvar_num(cvar_minlen) ) return PLUGIN_CONTINUE;
	
	static data[MessageData];
	ArrayGetArray(g_message_data, client, data);
	
	static count;
	if( !TrieGetCell(Trie:data[md_trie], message, count) )
	{
		data[md_total]++;
		count = 0;
	}
	
	TrieSetCell(Trie:data[md_trie], message, ++count);
	
	if( count > get_pcvar_num(cvar_samecount) )
	{
		new Float:gametime = get_gametime();
		if( gametime >= g_warning_delay[client] )
		{
			client_print_color(client, print_team_grey, "%L", client, "ANTISPAM_REQUEST");
			g_warning_delay[client] = gametime + get_pcvar_float(cvar_warndelay);
		}
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

bool:SayCommandExists(client, const say[])
{
	new flags = get_user_flags(client);
	
	static command[64], cmdflags, cmdinfo[3];
	
	new total = get_concmdsnum(flags, client);
	for( new i = 0; i < total; i++ )
	{
		get_concmd(i, command, sizeof(command) - 1, cmdflags, cmdinfo, sizeof(cmdinfo) - 1, flags);
		
		if( equal(say, command[contain(command, "_") + 1]) )
		{
			return true;
		}
	}
	
	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
