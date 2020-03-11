// Chell - Portal Gun
// based on Portal Gun plugin from here https://next21.ru/2013/04/%D0%BF%D0%BB%D0%B0%D0%B3%D0%B8%D0%BD-portal-gun/
// --evileye <https://ibiruai.github.io>

/* CVARS - copy and paste to shconfig.cfg

//Chell
chell_level 0

*/

#include <amxmodx>
#include <superheromod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

//#define PLUGIN "Portal Gun 2"
//#define VERSION "1.9.2 beta"
#define AUTHOR "Polarhigh" // aka trofian

#define IGNORE_ALL	(IGNORE_MISSILE | IGNORE_MONSTERS | IGNORE_GLASS)
#define m_pActiveItem 373

#define PORTAL_CLASSNAME	"portal_custom"
#define PORTAL_LOCK_TIME 	1.0
#define PORTAL_DESTINATION_SHIFT 4.0
#define PORTAL_WIDTH		46.0
#define PORTAL_HEIGHT		72.0

#define GUN_SHOOT_DELAY		0.45
#define GUN_DEPLOY_DELAY	1.39

#define GUN_ANIM_IDLE		0
#define GUN_ANIM_DEPLOY		3
#define GUN_ANIM_SHOT_RAND(id) __get_portal_gun_shoot_anim(id)

new gHeroID
new const gHeroName[]= "Chell"
new bool:gHasChell[SH_MAXSLOTS+1]
new freezetime = false
new CrowbarForward

new const g_sPortalModel[] = "models/shmod/portal.mdl"
new const g_sPortalGunModelV[] = "models/shmod/v_portalgun.mdl"
new const g_sPortalGunModelP[] = "models/shmod/p_portalgun.mdl"

new const g_sPortalGunSoundShot1[] = "shmod/shoot1.wav"
new const g_sPortalGunSoundShot2[] = "shmod/shoot2.wav"

new const g_sPortalSoundOpen1[] = "shmod/portal_o.wav"
new const g_sPortalSoundOpen2[] = "shmod/portal_b.wav"

new const g_sSparksSpriteBlue[] = "sprites/shmod/blue.spr"
new const g_sSparksSpriteOrange[] = "sprites/shmod/orange.spr"

new g_pStringInfTarg, g_pStringPortalClass
new g_pCommonTr

#include <portal_gun\vec_utils.inc>
#include <portal_gun\types\portalBox.inc>
#include <portal_gun\portal.inc>

new g_pStringPortalGunModelV, g_pStringPortalGunModelP
new g_idPortalGunModelV
new g_idPortalModel

#define SET_PORTAL_GUN_ANIM(%0,%1) g_iPortalWeaponAnim[%0] = %1
new g_iPortalWeaponAnim[SH_MAXSLOTS+1]

#define VISIBLE_PORTAL_GUN(%0)	g_iPlayerData[%0][1]
new g_iPlayerData[SH_MAXSLOTS+1][2]

new g_idSparksSpriteBlue, g_idSparksSpriteOrange

public plugin_precache() {
	g_idPortalModel = precache_model(g_sPortalModel)
	g_idPortalGunModelV = precache_model(g_sPortalGunModelV)
	precache_model(g_sPortalGunModelP)
	
	precache_sound(g_sPortalGunSoundShot1)
	precache_sound(g_sPortalGunSoundShot2)
	
	precache_sound(g_sPortalSoundOpen1)
	precache_sound(g_sPortalSoundOpen2)
	
	g_idSparksSpriteBlue = precache_model(g_sSparksSpriteBlue)
	g_idSparksSpriteOrange = precache_model(g_sSparksSpriteOrange)
}

public plugin_init() {
	register_plugin("SUPERHERO Chell", "1.0", AUTHOR)
	
	new gLevel = register_cvar("chell_level", "0")
	gHeroID = sh_create_hero(gHeroName, gLevel)
	sh_set_hero_info(gHeroID, "Portal Gun", "Press R holding knife to get Portal Gun")
	
	g_pCommonTr = create_tr2()
	
	g_pStringInfTarg = engfunc(EngFunc_AllocString, "info_target")
	g_pStringPortalClass = engfunc(EngFunc_AllocString, PORTAL_CLASSNAME)
	g_pStringPortalGunModelV = engfunc(EngFunc_AllocString, g_sPortalGunModelV)
	g_pStringPortalGunModelP = engfunc(EngFunc_AllocString, g_sPortalGunModelP)
	
	register_event("HLTV", "@event_hltv", "a", "1=0", "2=0")
	
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "@knife_deploy_p", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_knife", "@knife_postframe")
	register_forward(FM_UpdateClientData, "@update_client_data_p", 1)
	
	register_touch(PORTAL_CLASSNAME, "*", "@portal_touch")
	
	register_forward(FM_CmdStart, "FwdCmdStart")
	register_logevent("@round_start", 2, "1=Round_Start")
	CrowbarForward = CreateMultiForward("sh_has_crowbar", ET_CONTINUE, FP_CELL)
}

bool:has_crowbar(id)
{
	if ( !shModActive() || !is_user_alive(id) )
		return false

	new bool:hasCrowbar
	new functionReturn

	ExecuteForward(CrowbarForward, functionReturn, id)

	// Forward will return the highest value, don't return 1 or 2 in function cause of return handled or handled_main
	// and 0 is used by continue and invalid return, so can't return a bool either.
	switch(functionReturn)
	{
		case 0:
		{
			debugMessage("Function sh_has_crowbar not found! No plugin found with the function.", 0, 1)
		}
		case 3:
		{
			hasCrowbar = false
		}
		case 4:
		{
			hasCrowbar = true
		}
	}

	return hasCrowbar
}

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasChell[id] = true
			portal_create_pair(id)
			VISIBLE_PORTAL_GUN(id) = 0
			sh_chat_message(id, gHeroID, "%L", id, "CHELL_INSTRUCTION")
		}
		case SH_HERO_DROP: {
			VISIBLE_PORTAL_GUN(id) = 0
			portal_remove_pair(id)			
			if(is_user_alive(id) && VISIBLE_PORTAL_GUN(id) && get_user_weapon(id) == CSW_KNIFE)
				ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, m_pActiveItem))
			gHasChell[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public sh_client_spawn(id)
{
	if ( !gHasChell[id] )
		return

	if ( !VISIBLE_PORTAL_GUN(id) )
		sh_chat_message(id, gHeroID, "%L", id, "CHELL_INSTRUCTION")
	else
		set_task(0.1, "on_spawn", id) //sh_orc.amxx
}

public on_spawn(id)
{
	if(is_user_alive(id) && VISIBLE_PORTAL_GUN(id) && get_user_weapon(id) == CSW_KNIFE)
	{
		new weapon = get_pdata_cbase(id, m_pActiveItem)
		if(pev_valid(weapon))
			ExecuteHamB(Ham_Item_Deploy, weapon)
	}
}

public plugin_end() {
	free_tr2(g_pCommonTr)
}

public client_disconnected(id) {
	portal_remove_pair(id)
	
	gHasChell[id] = false
	VISIBLE_PORTAL_GUN(id) = 0
}

@event_hltv() {
	for(new i = 1; i <= SH_MAXSLOTS; i++)
		if (is_user_connected(i) && portal_is_set_pair(i))
		{
			//portal_close(i, PORTAL_ALL)
			portal_remove_pair(i)
			portal_create_pair(i)
		}
	freezetime = true
}

@round_start() {
	freezetime = false
}

@knife_deploy_p(gun) {
	if(!pev_valid(gun))
		return HAM_IGNORED
	
	new id = pev(gun, pev_owner)
	if(!pev_valid(id) || !gHasChell[id])
		return HAM_IGNORED
	
	if(!VISIBLE_PORTAL_GUN(id))
	{
		if (!has_crowbar(id))
			return HAM_IGNORED
		
		if (get_user_weapon(id) == CSW_KNIFE && !cs_get_user_shield(id))
		{
			set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, "models/v_crowbar.mdl"))
			set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, "models/p_crowbar.mdl"))
		}
		
		return HAM_IGNORED
	}
	
	set_pev_string(id, pev_viewmodel2, g_pStringPortalGunModelV)
	set_pev_string(id, pev_weaponmodel2, g_pStringPortalGunModelP)
	
	SET_PORTAL_GUN_ANIM(id, GUN_ANIM_DEPLOY)
	
	return HAM_HANDLED
}

@knife_postframe(gun) {
	static id
	id = pev(gun, pev_owner)
	
	if(!(0 < id <= SH_MAXSLOTS))
		return HAM_IGNORED
	
	if(!VISIBLE_PORTAL_GUN(id))
		return HAM_IGNORED
	
	static Float:nextAttackTime[SH_MAXSLOTS+1]
	if(nextAttackTime[id] > get_gametime())
		return HAM_SUPERCEDE
	
	new buttons = pev(id, pev_button)
	
	if((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) {
		new type = (buttons & IN_ATTACK) ? PORTAL_1 : PORTAL_2
		
		new Float:origin[3]
		pev(id, pev_origin, origin)
		
		new Float:originEyes[3]
		pev(id, pev_view_ofs, originEyes)
		xs_vec_add(originEyes, origin, originEyes)
		
		new Float:angle[3], Float:normal[3]
		pev(id, pev_v_angle, angle)
		angle_vector(angle, ANGLEVECTOR_FORWARD, normal)
		
		new portalBox[portalBox_t]
		
		if (freezetime)
			goto error
		
		// test surface
		if(!portalBox_create(originEyes, normal, id, portalBox))
			goto error

		// test hull
		new dimension = 1
		if(floatabs(portalBox[pfwd][2]) > 0.7)
			dimension = 2

		new Float:testOrigin[3]
		xs_vec_mul_scalar(portalBox[pfwd], VEC_HUMAN_HULL[dimension] + PORTAL_DESTINATION_SHIFT, testOrigin)
		xs_vec_add(testOrigin, portalBox[pcenter], testOrigin)
		
		engfunc(EngFunc_TraceHull, testOrigin, testOrigin, 0, HULL_HUMAN, id, g_pCommonTr)
		
		if(get_tr2(g_pCommonTr, TR_StartSolid) || get_tr2(g_pCommonTr, TR_AllSolid))
			goto error
		
		// test another portal
		new Float:radius = floatmin(PORTAL_HEIGHT, PORTAL_WIDTH) / 2.0
		
		// @TODO сделать не радиус, а что-нибудь получше, поточнее
		new anotherEnt
	 	while((anotherEnt = engfunc(EngFunc_FindEntityInSphere, anotherEnt, portalBox[pcenter], radius)))
			if(pev(anotherEnt, pev_modelindex) == g_idPortalModel && !portal_test_owner(id, anotherEnt, type))
				goto error
		
		portal_open(id, portalBox, type, .sound = true)
		goto after
		
		error:
		effect_sparks_error_open(portalBox[pcenter], portalBox[pfwd], type)		
	}
	else {
		SET_PORTAL_GUN_ANIM(id, GUN_ANIM_IDLE)
		
		return HAM_SUPERCEDE
	}
	after:
	
	emit_sound(gun, CHAN_AUTO, random_num(0,1) ? g_sPortalGunSoundShot1 : g_sPortalGunSoundShot2, 1.0, ATTN_NORM, 0, PITCH_NORM)
	SET_PORTAL_GUN_ANIM(id, GUN_ANIM_SHOT_RAND(id))
	nextAttackTime[id] = get_gametime() + GUN_SHOOT_DELAY
	
	return HAM_SUPERCEDE
}

@update_client_data_p(id, sendWeapons, cd) {
	if(get_cd(cd, CD_ViewModel) == g_idPortalGunModelV) {
		set_cd(cd, CD_flNextAttack, 9999.0)
		set_cd(cd, CD_WeaponAnim, g_iPortalWeaponAnim[id])
	}
}

@portal_touch(portal, toucher) {
	static portal2
	portal2 = pev(portal, pev_owner)
	
	static classname[33]
	pev(toucher, pev_classname, classname, 32)
	if (equal(classname, "walkguardzone")) // WalkGuard plugin 
		return
	if (equal(classname, "func_ladder") || equal(classname, "func_buyzone")) // de_rats
		return
	/*
	these are not to go through portal too
	func_wall
	fake_corpse?
	func_pushable
	trigger_push
	func_breakable
	func_water
	trigger_hurt
	*/
	
	if(!pev_valid(portal2))
		return
	
	if(pev(portal, pev_nextthink) > get_gametime())
		return
	
	if(pev(portal2, pev_effects) & EF_NODRAW)
		return
	
	if(pev(toucher, pev_flags) & FL_KILLME)
		return
	
	if(portal_teleport(toucher, portal2, portal))
		set_pev(portal2, pev_nextthink, get_gametime() + PORTAL_LOCK_TIME)
}

public FwdCmdStart(id, uc_handle)
{
	if(!is_user_alive(id) || !gHasChell[id])
		return
	
	static Button, OldButtons;
	Button = get_uc(uc_handle, UC_Buttons);
	OldButtons = pev(id, pev_oldbuttons);

	if((Button & IN_RELOAD) && !(OldButtons & IN_RELOAD) && get_user_weapon(id) == CSW_KNIFE)
	{
		static Float:nextDeployTime[SH_MAXSLOTS+1]
		if(nextDeployTime[id] > get_gametime())
			return
		
		VISIBLE_PORTAL_GUN(id) = !VISIBLE_PORTAL_GUN(id)
		
		new weapon = get_pdata_cbase(id, m_pActiveItem)
		if(pev_valid(weapon))
			ExecuteHamB(Ham_Item_Deploy, weapon)
		
		nextDeployTime[id] = get_gametime() + GUN_DEPLOY_DELAY
		
		return
	}	
}

__get_portal_gun_shoot_anim(id) {
	static sendAnim[SH_MAXSLOTS+1] = {4, ...}
	if(sendAnim[id] > 7)
		sendAnim[id] = 4
	return sendAnim[id]++
}

effect_sparks_error_open(const Float:origin[], const Float:normal[], type) {
	new Float:sparksStart[3], Float:sparksEnd[3]
	xs_vec_mul_scalar(normal, 7.0, sparksStart)
	xs_vec_add(origin, sparksStart, sparksStart)
	xs_vec_mul_scalar(normal, 20.0, sparksEnd)
	xs_vec_add(origin, sparksEnd, sparksEnd)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	engfunc(EngFunc_WriteCoord, sparksStart[0])
	engfunc(EngFunc_WriteCoord, sparksStart[1])
	engfunc(EngFunc_WriteCoord, sparksStart[2])
	engfunc(EngFunc_WriteCoord, sparksEnd[0])
	engfunc(EngFunc_WriteCoord, sparksEnd[1])
	engfunc(EngFunc_WriteCoord, sparksEnd[2])
	write_short(type == PORTAL_1 ? g_idSparksSpriteBlue : g_idSparksSpriteOrange)
	write_byte(25)
	write_byte(1)
	write_byte(1)
	write_byte(20)
	write_byte(14)
	message_end()
}
