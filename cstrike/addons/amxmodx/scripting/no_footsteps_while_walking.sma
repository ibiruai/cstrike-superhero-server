#include <amxmodx>
#include <fakemeta>

new bool:PlayerIsWalking[33]

public plugin_init()
{
	register_plugin("No Footsteps while Walking", "1.0", "Evileye")
	
	// If they don't run (+speed key) they want to be noiseless.
	// Let them have no footsteps even if they WALK too fast because of HIGH MAXSPEED.
	register_forward( FM_PlayerPreThink, "fwdPlayerPreThink", 0 );
	register_forward( FM_CmdStart, "FMCmdStart" );
}

// When player uses +speed, they want their footsteps be soundless
// even if they have hight maxspeed.
public fwdPlayerPreThink(id)
{
     if(is_user_alive(id) && PlayerIsWalking[id])
        set_pev(id, pev_flTimeStepSound, 400) // Seems 400 allows us to be noiseless
}

// [HowTo] Detect Holding Walk Button (CS 1.6)
// https://forums.alliedmods.net/showthread.php?t=56872
public FMCmdStart( id, uc_handle, randseed )
{
    new Float:fmove, Float:smove;
    get_uc(uc_handle, UC_ForwardMove, fmove);
    get_uc(uc_handle, UC_SideMove, smove );

    new Float:maxspeed;
    pev(id, pev_maxspeed, maxspeed);
    new Float:walkspeed = (maxspeed * 0.52); 
    fmove = floatabs( fmove );
    smove = floatabs( smove );
    
    if(fmove <= walkspeed && smove <= walkspeed && !(fmove == 0.0 && smove == 0.0))
    {
        PlayerIsWalking[id] = true;
    }
    else
    {
		PlayerIsWalking[id] = false
    }
}