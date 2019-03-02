/*
* 	Colored Translit v3.0 by Sho0ter
*	Connector
*/
public client_putinserver(id)
{
	Logged[id] = false
	set_task(10.0, "ShowInfo", id)
	get_user_name(id, s_CheckGag, charsmax(s_CheckGag))
	get_user_ip(id, s_CheckIp, charsmax(s_CheckIp), 1)
	if(get_systime(0) < i_Gag[id])
	{
		if(!equal(s_GagName[id], s_CheckGag) && !equal(s_GagIp[id], s_CheckIp))
		{
			i_Gag[id] = get_systime(0)
			SpamFound[id] = 0
			SwearCount[id] = 0
		}
	}
	return PLUGIN_CONTINUE
}