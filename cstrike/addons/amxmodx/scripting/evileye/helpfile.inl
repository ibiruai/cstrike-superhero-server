#define STR_LENGTH 499
new sentence_end[] = ".!"
public create_helpfile_html()
{
	create_helpfile_html_(0)
	create_helpfile_html_(1)
}
public create_helpfile_html_(website)
{
	new sss[STR_LENGTH + 1]
	new tsec[] = " seconds"
	new thefile
	new const beginning[] = "<html><head><meta charset='UTF-8'><style>body,table{font-family:Tahoma,sans-serif;font-size:10pt;line-height:125%;background-color:#DDD;color:#000}h3{font-size:14pt}h4{margin-bottom:6px;font-size:10pt}table{border-collapse:collapse}td{border-bottom:1px solid grey;padding:2px 10px 2px 0}tr:last-child td{border-bottom:0}p,ul{margin:6px 0}a,.property{color:#666}.passive{color:#009}.active{color:#080}</style></head><body>"
	if (website)
	{
		thefile = fopen("addons/amxmodx/data/index.html", "w")
		fputs(thefile, "<!DOCTYPE html>^n<html lang=^"en^">^n<head><meta charset=^"UTF-8^"><meta name=^"description^" content=^"This is Counter-Strike 1.6 server with SuperHero mod. Kill your opponents to gain XP and level up. Every level you'll be able to pick a new superpower.^"><meta name=^"viewport^" content=^"width=device-width, initial-scale=1^"><title>EVILEYE # SUPERHERO # SENTRY</title><style>body{font-family:sans-serif;font-size:12pt;line-height:175%;background-color:#201c16;color:#ebdbb2;overflow-x:hidden}h1,h2,h3{font-family:monospace;font-weight:100}@media screen and (min-width:800px){.wrapper{max-width:60%;min-width:800px!important;margin:0 auto}}h1{font-size:180%;text-align:center;margin-bottom:18px}h2{font-size:160%;margin-top:24px;margin-bottom:7px;padding-bottom:7px}h4{font-size:120%}h4{font-size:100%;margin-top:14px;margin-bottom:0}p,ul{margin:6px 0}a,.property{color:#a8a08c}.active{color:#72ff72}.passive{color:#79aaff}.languages{text-align:right}table{border-collapse:collapse}tr:not(:last-child) td{border-bottom:1px solid darkgrey}td{padding:2px 10px 2px 0}.gametracker img{max-width:100%;filter:sepia(1)}:not(h3)+h4{padding-top:10px}</style></head>^n<body>^n<div id=^"en^" lang=^"en^" class=^"wrapper^">^n<p class=^"languages^">^n<script>document.write('English | <a href=^"javascript:ru()^">Русский</a>');</script>^n<noscript>English | <a href=^"#ru^">Русский</a></noscript>^n</p>^n<h1>EVILEYE # SUPERHERO # SENTRY</h1>^n<p>EVILEYE # SUPERHERO # SENTRY is a CS 1.6 server with SuperHero mod and Sentry Guns.</p>^n<p>Server address: <strong>95.142.47.100:27015</strong></p>^n<p>Сonnect to the server with <strong>connect 95.142.47.100:27015</strong> in your game console or <a href=^"steam://connect/95.142.47.100:27015^">join via Steam</a>.</p>^n<p>Git: <a href=^"https://github.com/ibiruai/cstrike-superhero-server^">https://github.com/ibiruai/cstrike-superhero-server</a></p>^n<h2 id=^"news^">News</h2>^n<p>02 Feb 2019 - The server was launched. English and Russian languages are available.</p>^n<h2 id=^"server-status^">Server status</h2>^n<p><a href=^"https://www.gametracker.com/server_info/95.142.47.100:27015/^" class=^"gametracker^"><img src=^"https://cache.gametracker.com/server_info/95.142.47.100:27015/b_560_95_1.png^" alt=^"Current server status^" /></a></p>^n<h2 id=^"superhero-mod-help^">SuperHero Mod Help</h2>")
	}
	else
	{
		thefile = fopen("addons/amxmodx/data/help.en.html", "w")
		fputs(thefile, beginning)
	}
	fputs(thefile, "<p>As you kill opponents you gain Experience Points (XP). The higher the level of the person you kill the more XP you get. Once you have accumulated enough for a level up you will be able to choose a hero. The starting point is level 0 and you cannot select any heroes on this level.</p><p>Contents:</p><ol><li><a href='#commands'>Say commands</a></li><li><a href='#howtouse'>How to use powers?</a></li><li><a href='#powers'>List of powers</a></li>")
	if (!website)
		fputs(thefile, "<li><a href='#links'>Links</a></li>")
	fputs(thefile, "</ol><h3 id='commands'>Say commands</h3><p>Press <strong>I</strong> or say <strong>/menu</strong> to open the main menu. Most of things below are available from the main menu, so there is no need to remember any of those say commands.</p><table><tr><td>say /help</td><td>This help page</td></tr><tr><td>say /showmenu</td><td>Displays Select Super Power menu</td></tr><tr><td>say /herolist</td><td>Lets you see <a href='#powers'>a list of heroes and powers</a> (you can also use ^"herolist^" in the console)</td></tr><tr><td>say /myheroes</td><td>Displays your heroes</td></tr><tr><td>say /clearpowers</td><td>Clears ALL powers</td></tr><tr><td>say /drop &lt;hero&gt;</td><td>Drop one power so you can pick another</td></tr><tr><td>say /whohas &lt;hero&gt;</td><td>Shows you who has a particular hero</td></tr><tr><td>say /playerskills [@ALL|@CT|@T|name]</td><td>Shows you what heroes other players have chosen</td></tr><tr><td>say /playerlevels [@ALL|@CT|@T|name]</td><td>Shows you what levels other players are</td></tr><tr><td>say /automenu</td><td>Enable/Disable auto-show of Select Super Power menu</td></tr><tr><td>say /helpon</td><td>Enable HUD Help message (enabled by default)</td></tr><tr><td>say /helpoff</td><td>Disable HUD Help message</td></tr></table><h3 id='howtouse'>How to use powers?</h3>")
	fputs(thefile, "<p><span class='passive'>Passive powers</span> are used automatically. To use <span class='active'>active powers</span> you have to bind a key to +power#. In order to bind a key, you must open your console and use the bind command: bind ^"key^" ^"command^". In this case, the command is ^"+power#^". Here are some examples:</p><ul><li>bind f +power1</li><li>bind mouse3 +power2</li></ul>")
	format(sss, STR_LENGTH, "<p>You can have only up to %d <span class='active'>active powers</span>. You can have %d superpowers in total (you get one slot each level).</p>", get_cvar_num("sh_maxbinds"), get_cvar_num("sh_maxpowers"))
	fputs(thefile, sss)
	fputs(thefile, "<h3 id='powers'>List of powers</h3>")
	for (new x = 0; x < gSuperHeroCount; x++ ) {
		format(sss, STR_LENGTH, "<h4>%s - %s</h4><p>", gSuperHeros[x][hero], gSuperHeros[x][superpower])
		fputs(thefile, sss)
		if ( gSuperHeros[x][requiresKeys] )
			fputs(thefile, "<span class='active'>Active power:</span>")
		else
			fputs(thefile, "<span class='passive'>Passive power:</span>")
		format(sss, STR_LENGTH, " %s", gSuperHeros[x][help])
		if ( sss[strlen(sss) - 1] == sentence_end[0] || sss[strlen(sss) - 1] == sentence_end[1] )
			format(sss, STR_LENGTH, "%s</p>", sss)
		else
			format(sss, STR_LENGTH, "%s.</p>", sss)
		fputs(thefile, sss)
		if ( gSuperHeros[x][availableLevel] )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Required level:</span> %d</p>", getHeroLevel(x))
			fputs(thefile, sss)
		}
		if ( equal(gSuperHeros[x][hero], "Snake") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Heal:</span> %d HP</p><p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("snake_healpoints"), get_cvar_num("snake_cooldown"), tsec)
			fputs(thefile, sss)
		}
		else if ( equal(gSuperHeros[x][hero], "Captain America") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Chance per second:</span> %.0f%%</p><p><span class='property'>Duration:</span> %.1f%s</p>", get_cvar_float("captaina_percent") * 100, get_cvar_float("captaina_godsecs"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Domino") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Max damage multiplier:</span> %.1f</p><p><em>Damage multiplier = (Victim level - Attacker level) / Victim level</em></p>", get_cvar_float("domino_maxmult"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Dracula") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Life steal:</span> %.0f%%</p>", get_cvar_float("dracula_pctmax") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Electro") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cooldown:</span> %d%s</p><p><span class='property'>Max damage toward each enemy:</span> %d</p>", get_cvar_num("electro_cooldown"), tsec, get_cvar_num("electro_maxdamage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Hobgoblin") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage multiplier:</span> %.2f</p><p><span class='property'>HE grenades delivery:</span> every %d%s</p>", get_cvar_float("goblin_grenademult"), get_cvar_num("goblin_grenadetimer"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Janna") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Heal:</span> %d HP</p><p><span class='property'>Duration:</span> %d%s</p><p><span class='property'>Smoke grenades delivery:</span> every %d%s</p>", get_cvar_num("janna_healpoints"), get_cvar_num("janna_healtime"), tsec, get_cvar_num("janna_grenadetimer"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Jubilee") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Shades wearing time:</span> %d%s</p><p><span class='property'>Cooldown:</span> %d%s</p><p><span class='property'>Flashbangs delivery:</span> each %d%s</p>", get_cvar_num("jubilee_time"),  tsec, get_cvar_num("jubilee_cooldown"), tsec, get_cvar_num("jubilee_flash"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Wolverine") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Health regenerated per second:</span> %d HP</p>", get_cvar_num("wolv_healpoints"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Human Torch") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cost:</span> %d AP</p><p><span class='property'>How many blasts to burn one victim:</span> %d</p><p><span class='property'>Damage:</span> %d</p>", get_cvar_num("htorch_armorcost"), get_cvar_num("htorch_numburns"), get_cvar_num("htorch_burndamage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Iron Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cost per second:</span> %d AP</p><p><span class='property'>Armor:</span> %d AP</p><p><span class='property'>Armor regenerated per second while not using:</span> 1 AP</p>", get_cvar_num("ironman_fuelcost"), get_cvar_num("ironman_armor"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Shadowcat") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Noclip time:</span> %d%s</p><p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("shadowcat_cliptime"), tsec, get_cvar_num("shadowcat_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Psylocke") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Distance:</span> %d meters</p>", get_cvar_num("psylocke_distance"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Demolition Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Max damage:</span> %d</p><p><span class='property'>Max ammount of mines at once:</span> %d</p><p><span class='property'>Mine health:</span> %d HP</p>", get_cvar_num("demoman_maxdamage"), get_cvar_num("demoman_maxmines"), get_cvar_num("demoman_minehealth"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Explosion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage:</span> %d</p>", get_cvar_num("explosion_damage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Mirage") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("mirage_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Blink") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("blink_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Bass") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Laser ammo:</span> %d</p><p><span class='property'>Damage:</span> 36 − 100</p>", get_cvar_num("bass_level"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Thing") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Chance to ignore a bullet:</span> %.0f%%</p><p><span class='property'>Chance to ignore a knife hit:</span> %.0f%%</p>", get_cvar_float("Thing_weapon_percent") * 100, get_cvar_float("Thing_knife_percent") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Cho'Gath") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Bonus health per stack:</span> %d HP</p><p><span class='property'>Max bonus health:</span> %d HP</p><p><em>You'll loose your extra health on map change.</em></p>", get_cvar_num("chogath_hpgain"), get_cvar_num("chogath_maxextrahp"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Scorpion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage:</span> %d</p><p><span class='property'>Required time for victim to escape:</span> %d%s</p>", get_cvar_num("scorpion_uppercutdmg"), get_cvar_num("scorpion_escapetime"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Ainz Ooal Gown") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cost:</span> $%d</p>", get_cvar_num("ainz_cost"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Phoenix") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Max explosion damage:</span> %d</p><p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("phoenix_maxdamage"), get_cvar_num("phoenix_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Poison Ivy") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage per second:</span> %d</p>", get_cvar_num("poisonivy_damage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Mario") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Additional jumps:</span> %d</p>", get_cvar_num("mario_maxjumps"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Superman") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Gravity:</span> %.0f%%</p>", get_cvar_float("superman_gravity") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Bishop") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Absorptivity:</span> %.0f%% x Weapon damage taken</p><p><span class='property'>Damage multiplier:</span> %0.f%% x Absorbed damage</p><p><span class='property'>Blast damage:</span> %0.f%% x Absorbed damage</p>", get_cvar_float("bishop_absorbmult") * 100,get_cvar_float("bishop_damagemult") * 100,get_cvar_float("bishop_blastmult") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Invisible Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Invisibility:</span> %.0f%%</p>", 100 - get_cvar_float("invisman_alpha") / 255 * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Alien") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Invisibility:</span> %.0f%%</p>", 100 - get_cvar_float("alien_alpha") / 255 * 100)
			fputs(thefile, sss)
		}  else if ( equal(gSuperHeros[x][hero], "Catwoman") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Chance per round:</span> %.0f%%</p>", get_cvar_float("catwoman_pctperlev") * 100)
			fputs(thefile, sss)
		}
		if (website)
			fputs(thefile, "^n")
	}
	if (!website) {
		fputs(thefile, "<h3 id='links'>Links</h3><p>Website: <a href='https://ibiruai.github.io/cstrike-superhero-server/'>https://ibiruai.github.io/cstrike-superhero-server/</a></p><p>Git repository: <a href='https://github.com/ibiruai/cstrike-superhero-server'>https://github.com/ibiruai/cstrike-superhero-server</a></p><p>SuperHero Mod Sub-forum on Alliedmods.net (not affiliated with the server): <a href='https://forums.alliedmods.net/forumdisplay.php?f=30'>https://forums.alliedmods.net/forumdisplay.php?f=30</a></p>")
		fputs(thefile, "</div></body></html>")
		fclose(thefile)
	}
	tsec = " сек"
	if (website)
	{
		fputs(thefile, "</div>^n<noscript><hr></noscript>^n<div id=^"ru^" lang=^"ru^" class=^"wrapper^">^n<p class=^"languages^">^n<script>^ndocument.write('<a href=^"javascript:en()^">English</a> | Русский')^n</script>^n<noscript>^n<a href=^"#en^">English</a> | Русский^n</noscript>^n</p>^n<h1>EVILEYE # SUPERHERO # SENTRY</h1>^n<p>EVILEYE # SUPERHERO # SENTRY — CS 1.6 сервер с SuperHero модом и сторожевыми пушками.</p>^n<p>Адрес сервера: <strong>95.142.47.100:27015</strong></p>^n<p>Для входа введите <strong>connect 95.142.47.100:27015</strong> в консоли игры или <a href=^"steam://connect/95.142.47.100:27015^">присоединитесь через Steam</a>.</p>^n<p>Git: <a href=^"https://github.com/ibiruai/cstrike-superhero-server^">https://github.com/ibiruai/cstrike-superhero-server</a></p>^n<h2 id=^"новости^">Новости</h2>^n<p>02 фев 2019 - Сервер запущен. Английский и русский языки доступны.</p>^n<h2 id=^"состояние-сервера^">Состояние сервера</h2>^n<p><a href=^"https://www.gametracker.com/server_info/95.142.47.100:27015/^" class=^"gametracker^"><img src=^"https://cache.gametracker.com/server_info/95.142.47.100:27015/b_560_95_1.png^" alt=^"Текущее состояние сервера^" /></a></p>^n<h2 id=^"информация-о-моде^">Информация о моде</h2>")
	}
	else
	{
		thefile = fopen("addons/amxmodx/data/help.ru.html", "w")
		fputs(thefile, beginning)
	}
	fputs(thefile, "<p>Убивая противников и выполняя цели карты, вы получаете очки опыта. Чем выше уровень убитого вами игрока, тем больше опыта вы получаете. Набрав опыт и перейдя на следующий уровень, вы можете выбрать новую способность. Начальный уровень - нулевой, у игроков нет способностей на этом уровне.</p><p>Содержание:</p><ol><li><a href='#команды-чата'>Команды чата</a></li><li><a href='#как-пользоваться-способностями'>Как пользоваться способностями?</a></li><li><a href='#список-способностей'>Список способностей</a></li>")
	if (!website)
		fputs(thefile, "<li><a href='#ссылки'>Ссылки</a></li>")
	fputs(thefile, "</ol><h3 id='команды-чата'>Команды чата</h3><p>Чтобы открыть главное меню, нажмите клавишу <strong>Ш</strong> или напишите в чат <strong>/menu</strong>. Многое из перечисленного ниже также доступно из главного меню, и вам нет необходимости запоминать эти команды.</p><table><tr><td>say /help</td><td>Эта справочная страница</td></tr><tr><td>say /showmenu</td><td>Меню выбора способностей</td></tr><tr><td>say /herolist</td><td><a href='#список-способностей'>Список способностей</a> (вы также можете использовать команду ^"herolist^" в консоли)</td></tr><tr><td>say /myheroes</td><td>Список взятых вами способностей</td></tr><tr><td>say /clearpowers</td><td>Сбрасывает все ваши способности</td></tr><tr><td>say /drop &lt;hero&gt;</td><td>Сбрасывает одну вашу способность</td></tr><tr><td>say /whohas &lt;hero&gt;</td><td>Показывает вам, у кого есть указанная способность</td></tr><tr><td>say /playerskills [@ALL|@CT|@T|name]</td><td>Показывает вам, какие способности выбраны другими игроками</td></tr><tr><td>say /playerlevels [@ALL|@CT|@T|name]</td><td>Показывает вам, какого уровня другие игроки</td></tr><tr><td>say /automenu</td><td>Включить/выключить автоматическое появление меню выбора способностей</td></tr><tr><td>say /helpon</td><td>Отобразить справочное HUD сообщение</td></tr><tr><td>say /helpoff</td><td>Скрыть справочное HUD сообщение</td></tr></table><h3 id='как-пользоваться-способностями'>Как пользоваться способностями?</h3>")
	fputs(thefile, "<p><span class='passive'>Пассивные способности</span> используются автоматически. Чтобы использовать <span class='active'>активные способности</span>, вам нужно назначить клавишу на команду +power#, где # - номер активной способности. Для этого откройте консоль (~ или ё) и напишите в консоли: bind&nbsp;^"клавиша^"&nbsp;^"команда^". В нашем случае командой является ^"+power#^". Вот пара примеров:</p><ul><li>bind f +power1</li><li>bind mouse3 +power2</li></ul>")
	format(sss, STR_LENGTH, "<p>У вас может быть до %d <span class='active'>активных способностей</span>. Всего способностей может быть %d (вы получаете один слот на каждом уровне).</p>", get_cvar_num("sh_maxbinds"), get_cvar_num("sh_maxpowers"))
	fputs(thefile, sss)
	fputs(thefile, "<h3 id='список-способностей'>Список способностей</h3>")
	for (new x = 0; x < gSuperHeroCount; x++ ) {
		format(sss, STR_LENGTH, "<h4>%s - %s</h4><p>", gSuperHeros[x][hero], heroDictionary[dictionaryRelation[x]][DICT_RU * 2 + 1])
		fputs(thefile, sss)
		if ( gSuperHeros[x][requiresKeys] )
			fputs(thefile, "<span class='active'>Активная способность:</span>")
		else
			fputs(thefile, "<span class='passive'>Пассивная способность:</span>")
		format(sss, STR_LENGTH, " %s", heroDictionary[dictionaryRelation[x]][DICT_RU * 2 + 2])
		if ( sss[strlen(sss) - 1] == sentence_end[0] || sss[strlen(sss) - 1] == sentence_end[1] )
			format(sss, STR_LENGTH, "%s</p>", sss)
		else
			format(sss, STR_LENGTH, "%s.</p>", sss)
		fputs(thefile, sss)
		if ( gSuperHeros[x][availableLevel] )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Требуемый уровень:</span> %d</p>", getHeroLevel(x))
			fputs(thefile, sss)
		}
		if ( equal(gSuperHeros[x][hero], "Snake") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Лечение:</span> %d HP</p><p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("snake_healpoints"), get_cvar_num("snake_cooldown"), tsec)
			fputs(thefile, sss)
		}
		else if ( equal(gSuperHeros[x][hero], "Captain America") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Шанс кажду секунду:</span> %.0f%%</p><p><span class='property'>Продолжительность неуязвимости:</span> %.1f%s</p>", get_cvar_float("captaina_percent") * 100, get_cvar_float("captaina_godsecs"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Domino") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Максимальный множитель:</span> %.1f</p><p><em>Множитель урона = (Уровень жертвы - Уровень атакующего) / Уровень жертвы</em></p>", get_cvar_float("domino_maxmult"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Dracula") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Вампиризм:</span> %.0f%%</p>", get_cvar_float("dracula_pctmax") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Electro") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Откат:</span> %d%s</p><p><span class='property'>Максимальный урон по каждой жертве:</span> %d</p>", get_cvar_num("electro_cooldown"), tsec, get_cvar_num("electro_maxdamage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Hobgoblin") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Множитель урона:</span> %.2f</p><p><span class='property'>Выдача осколочных гранат:</span> каждые %d%s</p>", get_cvar_float("goblin_grenademult"), get_cvar_num("goblin_grenadetimer"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Janna") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Лечение:</span> %d HP</p><p><span class='property'>Время действия:</span> %d%s</p><p><span class='property'>Выдача дымовых гранат:</span> каждые %d%s</p>", get_cvar_num("janna_healpoints"), get_cvar_num("janna_healtime"), tsec, get_cvar_num("janna_grenadetimer"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Jubilee") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Время действия:</span> %d%s</p><p><span class='property'>Откат:</span> %d%s</p><p><span class='property'>Выдача светошумовых гранат:</span> каждые %d%s</p>", get_cvar_num("jubilee_time"),  tsec, get_cvar_num("jubilee_cooldown"), tsec, get_cvar_num("jubilee_flash"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Wolverine") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Восстановление здоровья в секунду:</span> %d HP</p>", get_cvar_num("wolv_healpoints"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Human Torch") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Стоимость выстрела:</span> %d AP</p><p><span class='property'>Количество выстрелов, чтобы убить жертву:</span> %d</p><p><span class='property'>Урон:</span> %d</p>", get_cvar_num("htorch_armorcost"), get_cvar_num("htorch_numburns"), get_cvar_num("htorch_burndamage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Iron Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Стоимость полёта в секунду:</span> %d AP</p><p><span class='property'>Ваша броня:</span> %d AP</p><p><span class='property'>Восстановление брони в секунду, когда не используется:</span> 1 AP</p>", get_cvar_num("ironman_fuelcost"), get_cvar_num("ironman_armor"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Shadowcat") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Время действия:</span> %d%s</p><p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("shadowcat_cliptime"), tsec, get_cvar_num("shadowcat_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Psylocke") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Дистанция:</span> %d метров</p>", get_cvar_num("psylocke_distance"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Demolition Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Максимальный урон:</span> %d</p><p><span class='property'>Мин одновременно:</span> %d</p><p><span class='property'>Прочность мины:</span> %d HP</p>", get_cvar_num("demoman_maxdamage"), get_cvar_num("demoman_maxmines"), get_cvar_num("demoman_minehealth"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Explosion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Урон:</span> %d</p>", get_cvar_num("explosion_damage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Mirage") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("mirage_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Blink") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("blink_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Bass") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Выстрелов:</span> %d</p><p><span class='property'>Урон:</span> 36 − 100</p>", get_cvar_num("bass_level"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Thing") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Шанс проигнорировать пулевой урон:</span> %.0f%%</p><p><span class='property'>Шанс проигнорировать ножевой удар:</span> %.0f%%</p>", get_cvar_float("Thing_weapon_percent") * 100, get_cvar_float("Thing_knife_percent") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Cho'Gath") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Бонусное здоровье за каждое пожирание:</span> %d HP</p><p><span class='property'>Максимальная прибавка к здоровью:</span> %d HP</p><p><em>При смене карты вы потеряете накопленное здоровье.</em></p>", get_cvar_num("chogath_hpgain"), get_cvar_num("chogath_maxextrahp"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Scorpion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Урон:</span> %d</p><p><span class='property'>Время, требуемое жертве на побег:</span> %d%s</p>", get_cvar_num("scorpion_uppercutdmg"), get_cvar_num("scorpion_escapetime"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Ainz Ooal Gown") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Стоимость:</span> $%d</p>", get_cvar_num("ainz_cost"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Phoenix") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Максимальный урон при взрыве:</span> %d</p><p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("phoenix_maxdamage"), get_cvar_num("phoenix_cooldown"), tsec)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Poison Ivy") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Урон в секунду:</span> %d</p>", get_cvar_num("poisonivy_damage"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Mario") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Прыжков:</span> %d</p>", get_cvar_num("mario_maxjumps"))
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Superman") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Гравитация:</span> %.0f%%</p>", get_cvar_float("superman_gravity") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Bishop") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Количество поглощаемого входящего урона:</span> %.0f%%</p><p><span class='property'>Множитель урона:</span> %0.f%% x Кол-во поглощённого урона в данный момент</p><p><span class='property'>Урон активной способности:</span> %0.f%% x Кол-во поглощённого урона в данный момент</p>", get_cvar_float("bishop_absorbmult") * 100,get_cvar_float("bishop_damagemult") * 100,get_cvar_float("bishop_blastmult") * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Invisible Man") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Невидимость:</span> %.0f%%</p>", 100 - get_cvar_float("invisman_alpha") / 255 * 100)
			fputs(thefile, sss)
		} else if ( equal(gSuperHeros[x][hero], "Alien") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Невидимость:</span> %.0f%%</p>", 100 - get_cvar_float("alien_alpha") / 255 * 100)
			fputs(thefile, sss)
		}  else if ( equal(gSuperHeros[x][hero], "Catwoman") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Шанс в начале каждого раунда:</span> %.0f%%</p>", get_cvar_float("catwoman_pctperlev") * 100)
			fputs(thefile, sss)
		}
		if (website)
			fputs(thefile, "^n")
	}
	if (website)
	{
		fputs(thefile, "</div>^n<script>function ru() {^n  document.getElementById('en').style.display = 'none';^n  document.getElementById('ru').style.display = 'block';^n}^nfunction en() {^n  document.getElementById('ru').style.display = 'none';^n  document.getElementById('en').style.display = 'block';^n}^nvar language = window.navigator.userLanguage || window.navigator.language;^nif (language.indexOf('ru') > -1) ru();</script>^n</body>^n</html>")
		fclose(thefile)
	}
	else
	{
		fputs(thefile, "<h3 id='ссылки'>Ссылки</h3><p>Сайт сервера: <a href='https://ibiruai.github.io/cstrike-superhero-server/'>https://ibiruai.github.io/cstrike-superhero-server/</a></p><p>Git-репозиторий: <a href='https://github.com/ibiruai/cstrike-superhero-server'>https://github.com/ibiruai/cstrike-superhero-server</a></p><p>Подфорум SuperHero Mod на Alliedmods.net (не имеет отношения к этому серверу): <a href='https://forums.alliedmods.net/forumdisplay.php?f=30'>https://forums.alliedmods.net/forumdisplay.php?f=30</a></p>")
		fputs(thefile, "</div></body></html>")
		fclose(thefile)
	}
}
