/* The Thing 1.1 (by Corvae aka TheRaven)

I'm new to this so please bare with me. This hero was made
because of a suggestion in the official forum. This hero
was engineered with only two days of practice at smallcode
and superhero mod so there might be a lot of ways to improve
the code. Feel free to change it to your liking.

CVARS - copy and paste to shconfig.cfg
--------------------------------------------------------------------------------------------------
//The Thing
Thing_level 5				// Character level this hero becomes available.
Thing_weapon_percent 0.25	// Percent chance to ignore bullets
Thing_knife_percent 1.00	// Percent chance to ignore knife hits (headshots always hit)
--------------------------------------------------------------------------------------------------*/

// 26 dec 2018 - Evileye - Attacker sees a hudmessage if victim ignored damage (SHOW_HUDMESSAGE_TO_ATTACKER 1)
// Also you can't ignore grenades anymore

//---------- User Changeable Defines --------//


// 1 = show hudmessage to attacker, 0 = don't show
#define SHOW_HUDMESSAGE_TO_ATTACKER 1


//------- Do not edit below this point ------//

#include <amxmodx>
#include <superheromod>

new gHeroName[]="Thing" 
new gHasThingPower[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
  register_plugin("SUPERHERO Thing","1.1","Corvae aka TheRaven")
  if ( isDebugOn() ) server_print("Attempting to create Thing Hero")
  
  register_cvar("Thing_level", "5" )
  register_cvar("Thing_weapon_percent", "0.25" )
  register_cvar("Thing_knife_percent", "1.00" )

  shCreateHero(gHeroName, "Rock Skin", "Chance to ignore bullets and knife hits.", false, "Thing_level" )

  register_srvcmd("Thing_init", "Thing_init")
  shRegHeroInit(gHeroName, "Thing_init")
  register_event("Damage", "Thing_damage", "b", "2!0")
}
//----------------------------------------------------------------------------------------------
public Thing_init()
{
  new temp[6]
  read_argv(1,temp,5)
  new id=str_to_num(temp)
  read_argv(2,temp,5)
  new hasPowers=str_to_num(temp)
  gHasThingPower[id]=(hasPowers!=0)
}
//----------------------------------------------------------------------------------------------
public Thing_damage(id)
{
  if (!shModActive() ) return PLUGIN_CONTINUE

  new damage = read_data(2)
  new weapon, bodypart, attacker = get_user_attacker(id,weapon,bodypart)
  
  // Grenade is not a bullet or a knife hit
  if (weapon == CSW_HEGRENADE) return PLUGIN_CONTINUE

  new randNum = random_num(0, 100 )
  new ThingLevel = floatround(get_cvar_float("Thing_weapon_percent") * 100)
  if ( ThingLevel >= randNum && is_user_alive(id) && id != attacker && gHasThingPower[id] && weapon!=CSW_KNIFE ) {
    shAddHPs(id, damage, 500 )
    set_hudmessage(0, 100, 200, 0.05, 0.60, 1, 0.1, 2.0, 0.1, 0.1, 80)
    show_hudmessage(id, "%L", id, "THING_BULLETS_MSG_TO_YOU")
  
  #if SHOW_HUDMESSAGE_TO_ATTACKER
  if ( attacker >= 0 && attacker <= SH_MAXSLOTS )
  {
    set_hudmessage(128, 0, 255, 0.05, 0.60, 1, 0.1, 2.0, 0.1, 0.1, 81)
    show_hudmessage(attacker, "%L", attacker, "THING_BULLETS_MSG_TO_ENEMY")
  }
  #endif
  }
  randNum = random_num(0, 100 )
  ThingLevel = floatround(get_cvar_float("Thing_knife_percent") * 100)
  if ( ThingLevel >= randNum && is_user_alive(id) && id != attacker && gHasThingPower[id] && weapon==CSW_KNIFE && bodypart!=HIT_HEAD ) {
    shAddHPs(id, damage, 500 )
    set_hudmessage(0, 100, 200, 0.05, 0.60, 1, 0.1, 2.0, 0.1, 0.1, 80)
    show_hudmessage(id, "%L", id, "THING_KNIFE_MSG_TO_YOU")
	
  #if SHOW_HUDMESSAGE_TO_ATTACKER
  if ( attacker >= 0 && attacker <= SH_MAXSLOTS )
  {
    set_hudmessage(128, 0, 255, 0.05, 0.60, 1, 0.1, 2.0, 0.1, 0.1, 81)
    show_hudmessage(attacker, "%L", attacker, "THING_KNIFE_MSG_TO_ENEMY")
  }
  #endif
  }

  return PLUGIN_CONTINUE
}