/*
* 	Colored Translit v3.0 by Sho0ter
*	Informer
*/
public ShowInfo(id)
{
	if(get_pcvar_num(g_AutoRus) == 1)
	{
		//client_cmd(id, "setinfo ^"translit_ee^" ^"1^"")
		set_user_info(id, "translit_ee", "1")
	}
	if(get_pcvar_num(g_ShowInfo) == 1 && get_pcvar_num(g_AutoRus) != 2)
	{
		if(!is_user_connected(id))
		{
			return PLUGIN_CONTINUE
		}
		format(Info, charsmax(Info), "%L", id, "CT_INFO_RUS")
		WriteMessage(id, Info)
		format(Info, charsmax(Info), "%L", id, "CT_INFO_ENG")
		WriteMessage(id, Info)
	}
	return PLUGIN_CONTINUE
}