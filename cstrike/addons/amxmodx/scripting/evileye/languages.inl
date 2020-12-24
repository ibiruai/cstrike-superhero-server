#define DICT_HEROES		44	// Ammount of heroes
#define DICT_LANGUAGES	1	// Ammount of languages available
#define DICT_RU			0	// Number of Russian language

new dictionaryRelation[SH_MAXHEROS]
new const heroDictionary[DICT_HEROES][1 + DICT_LANGUAGES * 2][256] = {
	{
		"Ainz Ooal Gown",
	//	"Resurrection Wand", "Use Resurrection Wand to revive players",
		"Палочка воскрешения", "Воскрешайте игроков Палочкой воскрешения"
	},
	{
		"Alien",
	//	"Alien Vision", "Get Alien Vision and Invisibility - You can use only knife",
		"Зрение Чужого", "Получите Зрение Чужого и Невидимость - Вы можете использовать только нож"
	},
	{
		"Bass",
	//	"Uber Energy Beam", "Press the +power key to fire your beam cannon",
		"Мощный луч энергии", "Нажмите +power# клавишу, чтобы выстрелить из лазерной пушки"
	},
	{
		"Bishop",
	//	"Absorb Energy", "Absorb Damage and use it with your weapons! Or release all energy to deal even more damage.",
		"Поглощение энергии", "Впитывайте урон и используйте его с вашими пушками! Или высвободите всю энергию во врага"
	},
	{
		"Bomberman",
	//	"Toy Bombs", "Press +power button to plant a toy bomb",
		"Игрушечные бомбы", "Нажмите +power# кнопку, чтобы установить игрушечную бомбу"
	},
	{
		"Black Panther",
	//	"Silent Boots", "Your boots have Vibranium soles that absorb sound",
		"Бесшумные шаги", "Подошвы вашей обуви сделаны из Вибраниума и поглощают звук"
	},
	{
		"Blink",
	//	"Teleportation", "Teleport to where you are currently aiming at",
		"Телепортация", "Вы телепорируетесь в направлении своего взгляда"
	},
	{
		"Captain America",
	//	"Super Shield", "Random Invincibility",
		"Суперщит", "Шанс получить неуязвимость"
	},
	{
		"Catwoman",
	//	"Sneak Into Enemies Base", "Chance Of Sneaking Into Enemies Base",
		"Внедрение", "Шанс проникнуть на базу противника"
	},
	{
		"Cho'Gath",
	//	"Feast", "Get Extra HP by killing enemies with a knife",
		"Пожирание", "Зарабатывайте HP, убивая врагов ножом"
	},
	{
		"Chell",
	//	"Portal Gun", "Press R holding knife to get Portal Gun",
		"Портальная пушка", "Нажмите R с ножом в руках, чтобы взять портальную пушку"
	},
	{
		"Daredevil",
	//	"Radar Sense", "ESP Rings show you when other players are approaching",
		"Радарное чувство", "Экстрасенсорные кольца показывают вам местонахождение игроков"
	},
	{
		"Demolition Man",
	//	"Tripmines", "Unlimited Tripmines - Limited ammount that can be planted at once",
		"Мины-ловушки", "Бесконечные мины - Количество мин, устанавливаемых одновременно, ограничено"
	},
	{
		"Domino",
	//	"Even the Odds", "Do more Gun Damage to Higher Levels, the larger the difference the more damage.",
		"Уравнять шансы", "Вы наносите больше урона оружием по врагам более высокого уровня"
	},
	{
		"Dracula",
	//	"Vampiric Drain", "Gain HP by attacking players - More HPs per level",
		"Похищение жизни", "Атакуя игроков, вы восстанавливаете своё здоровье"
	},
	{
		"Electro",
	//	"Chain Lightning", "Powerful Lightning Attack that can hurt Multiple Enemies",
		"Цепь молний", "Мощная атака молниями, наносящая урон нескольким целям"
	},
	{
		"Explosion",
	//	"Explosion", "Blows up when killed!",
		"Взрыв!", "Вы взрываетесь, когда вас убивают"
	},
	{
		"Freeman",
	//	"Long Jump Module", "Get Crowbar and Long Jump Module",
		"Длинные прыжки", "Получите лом и модуль длинных прыжков"
	},
	{
		"Frieza",
	//	"Energy Disk", "Unleash an energy disk and take control of where it flies!",
		"Энергетический диск", "Высвободите энергетический диск и контролируйте его полёт!"
	},
	{
		"Grandmaster",
	//	"Revive Dead", "Utilize cosmic life force to Revive one Dead Teammate",
	//	"Оживление павших", "Используйте космическую жизненную энергию, чтобы оживить одного союзника"
		"Оживление павших", "Используйте космическую жизненную энергию, чтобы воскрешать павших игроков"
	},
	{
		"Hobgoblin",
	//	"Hobgoblin Grenades", "Extra Nade Damage/Refill Nade",
		"Гранаты Хобгоблина", "Дополнительный урон от осколочных гранат и их автопополнение"
	},
	{
		"Human Torch",
	//	"Flame Blast", "Ignite your enemies on fire with a Flame Blast",
		"Поток пламени", "Поджигайте своих врагов"
	},
	{
		"Janna",
	//	"Healing Grenades", "Heal your teammates with healing grenades",
		"Лечебные гранаты", "Лечите ваших союзников лечебными гранатами"
	},	{
		"Jubilee",
	//	"Pink Shades", "Use Shades for protection from bright flashes",
		"Солнцезащитные очки", "Используйте солнцезащитные очки, чтобы защититься от ярких вспышек"
	},
	{
		"Invisible Man",
	//	"Invisibility", "Makes you less visible and harder to see. Only works while not running, not shooting and not zooming.",
		"Невидимость", "Вы замаскированы, и вас труднее заметить. Не работает, когда вы бежите и используете оружие."
	},
	{
		"Iron Man",
	//	"Rocket Pack", "Rocket Jetpack - use +power key to take off",
		"Реактивный ранец", "Используйте +power# клавишу, чтобы взлететь"
	},
	{
		"Mirage",
	//	"Delusion", "Turn invisible for a short time when someone aims at you",
		"Наваждение", "Вы становитесь невидимы на короткое время, когда по вам целятся"
	},
	{
		"Mystique",
	//	"Morph into Enemy", "Press the +power key to shapeshift into the Enemy",
		"Перевоплощение", "Нажмите +power# клавишу, чтобы замаскироваться под противника"
	},
	{
		"Mario",
	//	"Mulitple Jumps", You can now jump in the air for a certain amount of times!",
		"Многократные прыжки", "Вы можете прыгать в воздухе много раз"
	},
	{
		"Orc",
	//	"Equipment Reincarnation", "You will get all of your equipment in your next live",
		"Реинкарнация снаряжения", "Вы получите всё ваше снаряжение в вашей следующей жизни"
	},
	{
		"Phoenix",
	//	"Re-Birth", "As the Phoenix you shall Rise Again from your Burning Ashes.",
		"Перерождение", "Подобно Фениксу вы восстаёте из пепла"
	},
	{
		"Poison Ivy",
	//	"Infect Poison", "Infect the enemy with your Poisoned Bullets or Poisoned Knife",
		"Отравление ядом", "Отравляйте ваших врагов ядовитыми пулями или ножом"
	},
	{
		"Psylocke",
	//	"Psychic Detection", "Recieve a telepathic warning when an enemy is near.",
		"Телепатическое обнаружение", "Вы будете получать телепатическое предупреждение о врагах поблизости"
	},
	{
		"Punisher",
	//	"Bullets are added to your current mag!", "You get more bullets into your current mag!",
		"Автопополнение патронов", "Патроны автоматически проникают в магазины ваших пушек!"
	},
	{
		"Scorpion",
	//	"Get Over Here!", "Hold +power key to Harpoon and Drag opponents to you.",
		"Get Over Here!", "Удерживайте +power# клавишу, чтобы выстреливать гарпуном и подтягивать им к себе противников"
	},
	{
		"Shadowcat",
	//	"Walk Through Walls", "Can Walk Through Walls for Short Time - GET STUCK AND YOU'LL BE AUTO-SLAIN!",
		"Прохождение сквозь стены", "Вы можете ходить сквозь стены - Вы умрёте, если застрянете в стене"
	},
	{
		"Snake",
	//	"Health Rations", "Health Rations on power key use",
		"Лечебный паёк", "Лечебные пайки на +power# клавишу"
	},
	{
		"Spider-Man",
	//	"Web Swing", "Shoot Web to Swing - Jump Reels In, Duck Reels Out",
		"Раскачивание на паутине", "Выстреливайте паутиной и раскачивайтесь - Контролируйте длину, прыгая и приседая"
	},
	{
		"Superman",
	//	"Reduced Gravity", "You can jump higher",
		"Пониженная гравитация", "Вы можете прыгать выше"
	},
	{
		"The Tick",
	//	"No Fall Damage", "SPOOOON! Take no damage from falling",
		"Нетравматичные падения", "SPOOOON! Не получайте урон от падений"
	},
	{
		"Thing",
	//	"Rock Skin", "Chance to ignore bullets and knife hits.",
		"Каменная кожа", "Шанс проигнорировать пули и ножевые удары"
	},
	{
		"Wolverine",
	//	"Auto-Heal, "HP Regeneration"
		"Восстановление", "Регенерация здоровья"
	},
	{
		"Yoda",
	//	"Force Push", "Push enemies away with the Jedi Power of the Force.",
		"Отталкивание Силой", "Отталкивайте врагов мощью джедайской Силы"
	},
	{
		"Xavier",
	//	"Team Detection", "Detect what team a player is on by a glowing trail",
		"Определение команды", "Вы видите хвост, по которому понятно, какой команде принадлежит игрок"
	}
}
//----------------------------------------------------------------------------------------------
public setDictionaryRelation()
{
	for ( new x = 0; x < gSuperHeroCount && x < SH_MAXHEROS; x++ ) 
	{
		for ( new i = 0; i < DICT_HEROES; i++ )
			if ( equal( heroDictionary[i][0], gSuperHeros[x][hero] ) )
			{
				dictionaryRelation[x] = i
				break
			}
	}
}
//----------------------------------------------------------------------------------------------
