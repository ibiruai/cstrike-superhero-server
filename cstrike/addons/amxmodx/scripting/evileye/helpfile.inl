#define STR_LENGTH 499

new sentence_end[] = ".!"

public create_helpfile_html()
{
	create_helpfile_html_en(false)
	create_helpfile_html_en(true)
	
	create_helpfile_html_ru(false)
	create_helpfile_html_ru(true)
}

public create_helpfile_html_en(type)
{
	
	new sss[STR_LENGTH + 1]
	new const tsec[] = " seconds"
	new thefile
	
	if (type)
		thefile = fopen("addons/amxmodx/data/website-help/help.en.html", "w")
	else
		thefile = fopen("addons/amxmodx/data/website-motd/help.en.html", "w")
	
	if (type)
		fputs(thefile, "<!DOCTYPE html><html lang='en'><head><meta charset = 'UTF-8'><title>Evileye's SuperHero Server</title><link rel='stylesheet' type='text/css' href='../../css/style.css'></head><body><div class='wrapper'><p class='languages'>English | <a href='../../ru/help'>Русский</a></p><h1>SuperHero Mod Help</h1><p><a href='..'>Back to the main page</a></p>")
	else
		fputs(thefile, "<html lang='en'><head><meta charset = 'UTF-8'><title>Evileye's SuperHero Server</title><link rel='stylesheet' type='text/css' href='./style.css'></head><body><div class='wrapper'>")
	
	fputs(thefile, "<p>As you kill opponents you gain Experience Points (XP). The higher the level of the person you kill the more XP you get. Once you have accumulated enough for a level up you will be able to choose a hero. The starting point is level 0 and you cannot select any heroes on this level.</p><p>Contents:</p><ol><li><a href='#commands'>Say commands</a></li><li><a href='#howtouse'>How to use powers?</a></li><li><a href='#powers'>List of superpowers</a></li><li><a href='#links'>Links</a></li></ol><h2 id='commands'>Say commands</h2><hr><p>Press [ <strong>I</strong> ] or say <strong>/shmenu</strong> to open the main menu. Most of things above are available from the main menu, so there is no need to remember any of those say commands.</p><table><tr><td>say /help</td><td>This help page</td></tr><tr><td>say /showmenu</td><td>Displays Select Super Power menu</td></tr><tr><td>say /herolist</td><td>Lets you see <a href='#herolist'>a list of heroes and powers</a> (you can also use ^"herolist^" in the console)</td></tr><tr><td>say /myheroes</td><td>Displays your heroes</td></tr><tr><td>say /clearpowers</td><td>Clears ALL powers</td></tr><tr><td>say /drop &lt;hero&gt;</td><td>Drop one power so you can pick another</td></tr><tr><td>say /whohas &lt;hero&gt;</td><td>Shows you who has a particular hero</td></tr><tr><td>say /playerskills [@ALL|@CT|@T|name]</td><td>Shows you what heroes other players have chosen</td></tr><tr><td>say /playerlevels [@ALL|@CT|@T|name]</td><td>Shows you what levels other players are</td></tr><tr><td>say /automenu</td><td>Enable/Disable auto-show of Select Super Power menu</td></tr><tr><td>say /helpon</td><td>Enable HUD Help message (enabled by default)</td></tr><tr><td>say /helpoff</td><td>Disable HUD Help message</td></tr></table><h2 id='howtouse'>How to use powers?</h2><hr>")
	
	fputs(thefile, "<p><span class='passive_power'>Passive powers</span> are used automatically. To use <span class='active_power'>active powers</span> you have to bind a key to +power#. In order to bind a key, you must open your console and use the bind command: bind ^"key^" ^"command^". In this case, the command is ^"+power#^". Here are some examples:</p><ul><li>bind f +power1</li><li>bind mouse3 +power2</li></ul>")
	
	format(sss, STR_LENGTH, "<p>You can have only up to %d <span class='active_power'>active powers</span>. You can have %d superpowers in total (you get one slot each level).</p>", get_cvar_num("sh_maxbinds"), get_cvar_num("sh_maxpowers"))
	fputs(thefile, sss)
	
	fputs(thefile, "<h2 id='powers'>List of superpowers</h2><hr>")
	
	for (new x = 0; x < gSuperHeroCount; x++ ) {
		new hero_id[16]
		format(hero_id, charsmax(hero_id), "%s", gSuperHeros[x][hero])
		strtolower(hero_id)
		replace(hero_id, charsmax(hero_id), " ", "");
		replace(hero_id, charsmax(hero_id), "'", "");
		replace(hero_id, charsmax(hero_id), "-", "");
		
		format(sss, STR_LENGTH, "<h3 id='%s'>%s - %s</h3><p>", hero_id, gSuperHeros[x][hero], gSuperHeros[x][superpower])
		fputs(thefile, sss)

		if ( gSuperHeros[x][requiresKeys] )
			fputs(thefile, "<span class='active_power'>Active power:</span>")
		else
			fputs(thefile, "<span class='passive_power'>Passive power:</span>")
		
		format(sss, STR_LENGTH, " %s", gSuperHeros[x][help])
		if ( sss[strlen(sss) - 1] == sentence_end[0] || sss[strlen(sss) - 1] == sentence_end[1] )
			format(sss, STR_LENGTH, "%s</p>", sss)
		else
			format(sss, STR_LENGTH, "%s.</p>", sss)
		fputs(thefile, sss)
		
		if ( gSuperHeros[x][availableLevel] )
		{
			format(sss, STR_LENGTH, "<p><span class='level'>Required level:</span> %d</p>", getHeroLevel(x)) 
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
			format(sss, STR_LENGTH, "<p><span class='property'>Max damage multiplier:</span> %.1f</p><p class='explanation'>Damage multiplier = (Victim level - Attacker level) / Victim level</p>", get_cvar_float("domino_maxmult"))
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
			format(sss, STR_LENGTH, "<p><span class='property'>Cost:</span> %d AP</p><p><span class='property'>How many blasts to burn one victim:</span> %d</p><p><span class='property'>Damage:</span> %d</p>", get_cvar_num("htorch_numburns"), get_cvar_num("htorch_armorcost"), get_cvar_num("htorch_burndamage"))
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
			format(sss, STR_LENGTH, "<p><span class='property'>Bonus health per stack:</span> %d HP</p><p><span class='property'>Max bonus health:</span> %d HP</p><p class='explanation'>You'll loose your extra health on map change.</p>", get_cvar_num("chogath_hpgain"), get_cvar_num("chogath_maxextrahp"))
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Scorpion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage:</span> %d</p><p><span class='property'>Required time for victim to escape:</span> %d%s</p>", get_cvar_num("scorpion_uppercutdmg"), get_cvar_num("scorpion_escapetime"), tsec)
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Phoenix") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Max explosion damage:</span> %d</p><p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("phoenix_maxdamage"), get_cvar_num("phoenix_cooldown"), tsec)
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Poison Ivy") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Damage per second:</span> %d</p>", get_cvar_num("poisonivy_damage"))
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Grandmaster") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Cooldown:</span> %d%s</p>", get_cvar_num("gmaster_cooldown"), tsec)
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

	}
	
	fputs(thefile, "<h2 id='links'>Links</h2><hr><p>Website: <a href='http://evileye.eu.org/'>http://evileye.eu.org/</a></p><p>Feel free to email me: evileye@firemail.cc</p><p>SuperHero Mod Sub-forum on Alliedmods.net: <a href='https://forums.alliedmods.net/forumdisplay.php?f=30'>https://forums.alliedmods.net/forumdisplay.php?f=30</a></p>")
	
	if (type)
		fputs(thefile, "<p class='center'>еmаil: evileye at fi<span style='display: none'>a</span>remail dot cc</p></div></body></html>")
	else
		fputs(thefile, "</div></body></html>")
	
	fclose(thefile)
}

public create_helpfile_html_ru(type)
{
	
	new sss[STR_LENGTH + 1]
	new const tsec[] = " сек"
	new thefile
	
	if (type)
		thefile = fopen("addons/amxmodx/data/website-help/help.ru.html", "w")
	else
		thefile = fopen("addons/amxmodx/data/website-motd/help.ru.html", "w")
		
	
	if (type)
		fputs(thefile, "<!DOCTYPE html><html lang='ru'><head><meta charset = 'UTF-8'><title>Evileye's SuperHero Server</title><link rel='stylesheet' type='text/css' href='../../css/style.css'></head><body><div class='wrapper'><p class='languages'><a href='../../en/help'>English</a> | Русский</p><h1>Информация о моде</h1><p><a href='..'>Вернуться на главную</a></p>")
	else
		fputs(thefile, "<html lang='ru'><head><meta charset = 'UTF-8'><title>Evileye's SuperHero Server</title><link rel='stylesheet' type='text/css' href='./style.css'></head><body><div class='wrapper'>")
	
	fputs(thefile, "<p>Убивая противников и выполняя цели карты, вы зарабатываете очки опыта. Чем выше уровень игрока, которого вы одолели, тем больше очков опыта вы заработаете. Набрав достаточное количество опыта и получив новый уровень, вы сможете выбрать очередную способность. Стартовый уровень - нулевой, и вы не можете иметь суперспособности, будучи на этом уровне.</p><p>Содержание:</p><ol><li><a href='#commands'>Команды чата</a></li><li><a href='#howtouse'>Как пользоваться способностями?</a></li><li><a href='#powers'>Список способностей</a></li><li><a href='#links'>Ссылки</a></li></ol><h2 id='commands'>Команды чата</h2><hr><p>Чтобы открыть главное меню, нажмите клавишу [ <strong>I</strong> ] или напишите в чат <strong>/shmenu</strong>. Многие из вещей, перечисленных ниже, также доступны из главного меню, и вам нет необходимости запоминать эти команды.</p><table><tr><td>say /help</td><td>Эта справочная страница</td></tr><tr><td>say /showmenu</td><td>Меню выбора способностей</td></tr><tr><td>say /herolist</td><td><a href='#herolist'>Список способностей</a> (вы также можете использовать команду ^"herolist^" в консоли)</td></tr><tr><td>say /myheroes</td><td>Список взятых вами способностей</td></tr><tr><td>say /clearpowers</td><td>Сбрасывает все ваши способности</td></tr><tr><td>say /drop &lt;hero&gt;</td><td>Сбрасывает одну вашу способность</td></tr><tr><td>say /whohas &lt;hero&gt;</td><td>Показывает вам, у кого есть указанная способность</td></tr><tr><td>say /playerskills [@ALL|@CT|@T|name]</td><td>Показывает вам, какие способности выбраны другими игроками</td></tr><tr><td>say /playerlevels [@ALL|@CT|@T|name]</td><td>Показывает вам, какого уровня другие игроки</td></tr><tr><td>say /automenu</td><td>Включить/выключить автоматическое появление меню выбора способностей</td></tr><tr><td>say /helpon</td><td>Отобразить справочное HUD сообщение</td></tr><tr><td>say /helpoff</td><td>Скрыть справочное HUD сообщение</td></tr></table><h2 id='howtouse'>Как пользоваться способностями?</h2><hr>")
	
	fputs(thefile, "<p><span class='passive_power'>Пассивные способности</span> используются автоматически. Чтобы использовать <span class='active_power'>активные способности</span>, вам нужно назначить клавишу на команду +power#, где # - номер активной способности. Для этого вам нужно открыть консоль (~ или ё) и использовать в ней следующую команду: bind ^"клавиша^" ^"команда^". В нашем случае ^"команда^" - ^"+power#^". Вот пара примеров:</p><ul><li>bind f +power1</li><li>bind mouse3 +power2</li></ul>")
	
	format(sss, STR_LENGTH, "<p>У вас может быть до %d <span class='active_power'>активных способностей</span>. Всего способностей может быть %d (вы получаете один слот на каждом уровне).</p>", get_cvar_num("sh_maxbinds"), get_cvar_num("sh_maxpowers"))
	fputs(thefile, sss)
	
	fputs(thefile, "<h2 id='powers'>Список способностей</h2><hr>")
	
	for (new x = 0; x < gSuperHeroCount; x++ ) {
		new hero_id[16]
		format(hero_id, charsmax(hero_id), "%s", gSuperHeros[x][hero])
		strtolower(hero_id)
		replace(hero_id, charsmax(hero_id), " ", "");
		replace(hero_id, charsmax(hero_id), "'", "");
		replace(hero_id, charsmax(hero_id), "-", "");
		
		format(sss, STR_LENGTH, "<h3 id='%s'>%s - %s</h3><p>", hero_id, gSuperHeros[x][hero], heroDictionary[dictionaryRelation[x]][DICT_RU * 2 + 1])
		fputs(thefile, sss)

		if ( gSuperHeros[x][requiresKeys] )
			fputs(thefile, "<span class='active_power'>Активная способность:</span>")
		else
			fputs(thefile, "<span class='passive_power'>Пассивная способность:</span>")
		
		format(sss, STR_LENGTH, " %s", heroDictionary[dictionaryRelation[x]][DICT_RU * 2 + 2])
		if ( sss[strlen(sss) - 1] == sentence_end[0] || sss[strlen(sss) - 1] == sentence_end[1] )
			format(sss, STR_LENGTH, "%s</p>", sss)
		else
			format(sss, STR_LENGTH, "%s.</p>", sss)
		fputs(thefile, sss)
		
		if ( gSuperHeros[x][availableLevel] )
		{
			format(sss, STR_LENGTH, "<p><span class='level'>Требуемый уровень:</span> %d</p>", getHeroLevel(x)) 
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
			format(sss, STR_LENGTH, "<p><span class='property'>Максимальный множитель:</span> %.1f</p><p class='explanation'>Множитель урона = (Уровень жертвы - Уровень атакующего) / Уровень жертвы</p>", get_cvar_float("domino_maxmult"))
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
			format(sss, STR_LENGTH, "<p><span class='property'>Стоимость выстрела:</span> %d AP</p><p><span class='property'>Количество выстрелов, чтобы убить жертву:</span> %d</p><p><span class='property'>Урон:</span> %d</p>", get_cvar_num("htorch_numburns"), get_cvar_num("htorch_armorcost"), get_cvar_num("htorch_burndamage"))
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
			format(sss, STR_LENGTH, "<p><span class='property'>Бонусное здоровье за каждое пожирание:</span> %d HP</p><p><span class='property'>Максимальная прибавка к здоровью:</span> %d HP</p><p class='explanation'>При смене карты вы потеряете накопленное здоровье.</p>", get_cvar_num("chogath_hpgain"), get_cvar_num("chogath_maxextrahp"))
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Scorpion") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Урон:</span> %d</p><p><span class='property'>Время, требуемое жертве на побег:</span> %d%s</p>", get_cvar_num("scorpion_uppercutdmg"), get_cvar_num("scorpion_escapetime"), tsec)
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Phoenix") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Максимальный урон при взрыве:</span> %d</p><p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("phoenix_maxdamage"), get_cvar_num("phoenix_cooldown"), tsec)
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Poison Ivy") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Урон в секунду:</span> %d</p>", get_cvar_num("poisonivy_damage"))
			fputs(thefile, sss)		
		} else if ( equal(gSuperHeros[x][hero], "Grandmaster") )
		{
			format(sss, STR_LENGTH, "<p><span class='property'>Откат:</span> %d%s</p>", get_cvar_num("gmaster_cooldown"), tsec)
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

	}
	
	fputs(thefile, "<h2 id='links'>Ссылки</h2><hr><p>Сайт сервера: <a href='http://evileye.eu.org/'>http://evileye.eu.org/</a></p><p>Вы можете написать мне на почту, если хотите связаться со мной. Вот мой адрес электронной почты: evileye@firemail.cc</p><p>Подфорум SuperHero Mod на Alliedmods.net (не имеет отношения к этому серверу): <a href='https://forums.alliedmods.net/forumdisplay.php?f=30'>https://forums.alliedmods.net/forumdisplay.php?f=30</a></p>")
	
	if (type)
		fputs(thefile, "<p class='center'>еmаil: evileye at fi<span style='display: none'>a</span>remail dot cc</p></div></body></html>")
	else
		fputs(thefile, "</div></body></html>")
	
	fclose(thefile)
}