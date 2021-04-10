#include <a_samp>
#include <streamer>

public OnFilterScriptInit()
{
    Streamer_VisibleItems(STREAMER_TYPE_OBJECT,3000);
	//--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
	return print("Projet Healand Mappings Loaded.");
}

public OnFilterScriptExit()
	return 1;
