import os, time

path = "/home/steam/Half-Life/cstrike/addons/amxmodx/logs/restart_me.log"

if time.time() - os.path.getmtime(path) > 3 * 60:
	time.sleep(20)
	if time.time() - os.path.getmtime(path) > 3 * 60:
		print("\n" + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + " Server is offline. Restarting.")
		os.system('sudo shutdown -r 0')
