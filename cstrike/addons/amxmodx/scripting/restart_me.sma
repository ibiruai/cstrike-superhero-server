#include <amxmodx>

public plugin_init()
{
	register_plugin("Restart Me", "1.0", "Evileye")
	change_mtime()
}

public change_mtime()
{
	new file
	file = fopen("addons/amxmodx/logs/restart_me.log", "a")
	fputs(file, ".")
	fclose(file)
	set_task(120.0, "change_mtime")
}
