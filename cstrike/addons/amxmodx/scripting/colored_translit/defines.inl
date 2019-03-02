/*
* 	Colored Translit v3.0 by Sho0ter
*	Defines and Constats
*/
#define PLUGIN "Colored Translit" // Don't change it!
#define VERSION "3.0"
#define AUTHOR "Sho0ter"

#define ACCESS_LEVEL ADMIN_CHAT
#define NICK_LEVEL ADMIN_CHAT
#define IMMUNITY_LEVEL ADMIN_CHAT

#define is_valid_player(%1) (1 <= %1 <= 32)

#define LOGTITLE "<META http-equiv=Content-Type content='text/html;charset=UTF-8'><h2 align=center>Colored Translit Chat Logger v3.0 by Sho0ter</h2><hr>"
#define LOGFONT "<font face=^"Verdana^" size=2>"

#define PUNISH_CHEAT 1
#define PUNISH_SPAM 2

#define ACTION_CHEAT 1
#define ACTION_SPAM 2

#define MAX_SWEARS 1000
#define MAX_REPLACES 1000
#define MAX_IGNORES 1000
#define MAX_SPAMS 1000
#define MAX_CHEAT 1000

new Adds[4][10][128]
new AddsNum[4]

new Cmds[100][128]
new CmdsNum

new Replace[MAX_REPLACES][192]
new Spam[MAX_SPAMS][192]
new Cheat[MAX_CHEAT][192]
new Ignore[MAX_IGNORES][64]
new Swear[MAX_SWEARS][64]

new g_OriginalSimb[128][32]
new g_TranslitSimb[128][32]
new s_GagName[33][32]
new s_GagIp[33][32]
new SpamFound[33]
new SwearCount[33]
new i_Gag[33]

new p_LogMessage[1024]
new p_LogMsg[1024]
new p_LogInfo[512]
new p_LogTitle[512]
new p_LogFile[128]
new p_LogFileTime[32]
new p_LogIp[32]
new p_LogSteamId[32]
new p_LogTime[32]
new p_LogDir[64]
new p_LogAdminIp[32]

new Message[512]
new s_Msg[256]
new s_SwearMsg[256]
new s_Name[128]
new sUserId[32]
new AliveTeam[32]
new s_CheckGag[32]
new s_CheckIp[32]
new s_GagTime[32]
new s_GagPlayer[32]
new s_GagAdmin[32]
new s_GagTarget[32]
new s_BanAuthId[32]
new s_CountryIp[32]
new s_Country[46]
new s_KickName[64]
new s_BanName[32]
new s_BanIp[32]
new s_Reason[128]
new s_CheatAction[128]

new p_FilePath[64]
new s_ConfigsDir[64]
new s_File[64]
new s_ConfigFile[64]
new s_SwearFile[64]
new s_IgnoreFile[64]
new s_ReplaceFile[64]
new s_SpamFile[64]
new s_CheatFile[64]
new s_Country1[45]
new s_Country2[3]
new s_Country3[4]

new Input[32]
new Info[192]
new TeamColor[10]
new TeamName[10]
new s_Info[2]
new s_Arg[64]

new g_Translit
new g_Log
new g_NameColor
new g_AllChat
new g_AdminPrefix
new g_Listen
new g_ChatColor
new g_Country
new g_SwearFilter
new g_SwearWarns
new g_AutoRus
new g_ShowInfo
new g_SwearImmunity
new g_Sounds
new g_Ignore
new g_IgnoreMode
new g_SwearGag
new g_SwearTime
new g_FloodTime
new g_GagImmunity
new g_Spam
new g_SpamImmunity
new g_SpamWarns
new g_SpamAction
new g_SpamActionTime
new g_Cheat
new g_CheatImmunity
new g_CheatAction
new g_CheatActionTime
new g_CheatActionCustom

new fwd_Begin
new fwd_Cheat
new fwd_Spam
new fwd_Swear
new fwd_Format

new isAlive
new i_MaxSimbols
new SwearNum
new ReplaceNum
new IgnoreNum
new SpamNum
new CheatNum
new Line
new Len
new gagid
new i_GagTime
new SysTime
new i_ShowGag
new SwearFound
new mLen
new lgLen
new fwdResult

new bool:Flood[33]
new bool:Logged[33]
new bool:SwearList
new bool:ReplaceList
new bool:ConfigsList
new bool:TranslitList
new bool:IgnoreList
new bool:SpamList
new bool:IgnoreFound
new bool:SlashFound
new bool:CheatList

new color[10]