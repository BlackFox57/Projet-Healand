//------------------------[ INCLUDES ]------------------------------------------
#include <a_samp>
#include <a_mysql>
#include <streamer>
#include "../include/gl_common.inc"
//------------------------------------------------------------------------------
#pragma tabsize 					0
//------------------------[ SERVER DEFINES ]------------------------------------
#define SERVER_NAME					"[FR/RP] Projet Healand [0.3DL]"
#define SERVER_BUILD        		"PH 0.1.2:1459"
#define SERVER_UPDATE               "9 Avril 2021"
#define SERVER_MAKER            	"Blackfox"
#define SERVER_MAP              	"Los Santos"
#define SERVER_LANGAGE         		"Français"
#define SERVER_URL              	"www.samp.fr"
//------------------------[ SERVER LOCAL SQL ]----------------------------------
#define SQL_LHOST   				"localhost"
#define SQL_LUSER               	"root"
#define SQL_LPASS               	""
#define SQL_LTABLE              	"ph"
//------------------------{ SERVER LINUX SQL ]----------------------------------
#define SQL_HOST   					"localhost"
#define SQL_USER               		"root"
#define SQL_PASS               		""
#define SQL_TABLE              		"ph"
//------------------------[ SERVER GLOBAL SQL ]---------------------------------
#define SQL_PROTOCOL            	false // false pour le localhost / true pour la machine
//------------------------[ SERVER MAX PARAMS ]---------------------------------
#define MAX_JOUEURS             	50
#define MAX_WEAPON_DROPS    		999
#define WEAPON_DROP_TIMESPAN    	60
#define SERVER_MIN_PASS         	6
#define SERVER_MAX_PASS         	16
#define PRIVATE_VIRTUAL_WORLD   	999
#define GENDER_MALE             	0
#define GENDER_FEMALE           	1
#define MAX_VPARAMS                 16
//------------------------[ DIALOG STYLE ]--------------------------------------
#define DIALOG_STYLE_INTEGER        0
#define DIALOG_STYLE_FLOAT          1
#define DIALOG_STYLE_STRING         2
//------------------------[ SERVER TD SELECT ]----------------------------------
#define TD_SELECT_CUSTOM_CHARACTER  1
//------------------------[ SERVER COLORS HEX ]---------------------------------
#define COLOR_WHITE 				0xFFFFFFFF
#define COLOR_NORMAL_PLAYER 		0xFFBB7777
#define CMD_ERROR_COL   			0xFF4242FF
#define COLOR_ASUBCMD           	0x5BADFFFF
#define COLOR_AHELP             	0x80FF00FF
//------------------------[ SERVER COLORS RGB ]---------------------------------
#define RGB_WHITE_COL   			"{FFFFFF}"
#define RGB_GOLD_COL            	"{E6E600}"
#define RGB_ASUBCMD_COL         	"{5BADFF}"
#define RGB_AHELP_COL           	"{80FF00}"
#define RGB_ERROR_COL           	"{FF4242}"
//------------------------[ STAFF RANKS ]---------------------------------------
#define ADMIN_MODERATOR         	1
//------------------------[ SERVER DIALOG ID ]----------------------------------
#define DIALOG_EDITING_VALUE        0
#define DIALOG_ACCOUNT_REGISTER 	1
#define DIALOG_ACCOUNT_LOGIN    	2
#define DIALOG_CHARACTER_AGE        3
#define DIALOG_CHARACTER_NAME       4
#define DIALOG_CHARACTER_LASTNAME   5
//------------------------[ SERVER PICKUP TYPES ]-------------------------------
#define PICKUP_TYPE_CONCESS         1
//------------------------[ FORWARDS ]------------------------------------------
forward Timer_A();
forward KickPlayer(playerid);
forward SQL_Check_Account(playerid);
forward Create_New_PlayerAccount(playerid, password[]);
forward EncryptRegisterPassword(playerid);
forward OnPasswordEncrypted(playerid);
forward OnPlayerLogin(playerid, password[]);
forward PreviousSpawn(playerid);
forward PlayerCameraLogin(playerid);
forward SpawnThisCharacter(playerid);
forward LoadCharacter(playerid);
forward CreateNewCharacter(playerid);
forward ORM_EditNewCharacter(playerid);
forward CheckPlayerCharacter(playerid);
forward LoadVParams();
forward LoadVehicles();
forward ORM_CharacterLoaded(playerid);
//------------------------[ SERVER VARIABLES ]----------------------------------
new Timer[1],
	MySQL:database,
	str[512];/*,
	stradd[4096];*/
//------------------------[ SERVER TEXTDRAWS ]----------------------------------
new PlayerText:TD_CREATE_CHARACTER[MAX_JOUEURS][18],
    PlayerText:TD_MAIN_SCREEN[MAX_JOUEURS][7];
//------------------------[ SERVER 3DTEXT ]-------------------------------------
new Text3D:ewd_Text[MAX_WEAPON_DROPS],
    Text3D:tPlayerName[MAX_JOUEURS];
//------------------------ SERVER TAB VARIABLES ]-------------------------------
new Ethnie_Male[5][64] =
{{"Americain"},{"Chinois"},{"Mexicain"},{"Russe"},{"Italien"}};

new Ethnie_Female[5][64] =
{{"Americaine"},{"Chinoise"},{"Mexicaine"},{"Russe"},{"Italienne"}};
//------------------------[ ENUMERATEURS ]--------------------------------------
enum e_compte
{
	ec_ID,
	ORM:ec_ORMID,
	ec_IP[16],
	ec_Password[512],
	ec_Name[MAX_PLAYER_NAME+1],
	ec_Tutorial,
	ec_AutoConnect,
	ec_AdminLvl
};
new Compte[MAX_JOUEURS][e_compte];

enum e_personnage
{
	ep_ID,
	ep_CompteID,
	ORM:ep_ORMID,
	ep_Nom[16],
	ep_Prenom[16],
	ep_Sexe,
	ep_Skin,
	ep_Age,
	ep_Ethnie,
	ep_Money,
	ep_Job,
	Float:ep_PosX,
	Float:ep_PosY,
	Float:ep_PosZ,
	Float:ep_Rot,
	ep_Interior,
	ep_Monde,
	ep_Created
};
new Perso[MAX_JOUEURS][e_personnage];

enum e_vehicles
{
	ev_ID,
	ORM:ev_ORMID,
	ev_ParamsID,
	ev_PersoID,
	ev_ColorA,
	ev_ColorB,
	Float:ev_Etat,
	Float:ev_PosX,
	Float:ev_PosY,
	Float:ev_PosZ,
	Float:ev_Rot,
	ev_Suppr
};
new Vehicles[MAX_VEHICLES][e_vehicles];

enum e_vparams
{
	evp_ID,
	ORM:evp_ORMID,
	evp_Model,
	evp_Name[32],
	evp_Price,
	Float:evp_MaxFuel,
	evp_Suppr
};
new VParams[MAX_VPARAMS][e_vparams];

enum e_weapondrop
{
	ewd_Model,
	Float:ewd_PosX,
	Float:ewd_PosY,
	Float:ewd_PosZ,
	ewd_WeapID,
	ewd_Ammo,
	ewd_TimeSpan,
	ewd_ObjectID
};
new WeaponDrop[MAX_WEAPON_DROPS][e_weapondrop];
//------------------------------------------------------------------------------
main()
{
    print("\n ****      ****     *****");
	print("******    ******    ******");
	print("**   ***  **   ***  **   ***");
	print("**   ***  **   ***  **   ***");
	print("*******   *******   ******");
	print("**  ***   **  ***   **");
	print("**   ***  **   ***  **");
	printf("by %s\n",SERVER_MAKER);
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))
	    return 0;
	ResetPlayerMoney(playerid);
	//-----------------[ Initialisation variables compte ]----------------------
	strmid(Compte[playerid][ec_IP],"Aucune",0,strlen("Aucune"),16);
	strmid(Compte[playerid][ec_Password],"Vide",0,strlen("Vide"),512);
	strmid(Compte[playerid][ec_Name],"Aucun",0,strlen("Aucun"),MAX_PLAYER_NAME+1);
	Compte[playerid][ec_Tutorial] = 0;
	Compte[playerid][ec_AutoConnect] = 0;
	Compte[playerid][ec_AdminLvl] = 0;
	//-----------------[ Initialisation variable perso ]------------------------
	Perso[playerid][ep_CompteID] = 0;
	strmid(Perso[playerid][ep_Nom],"Nom de famille",0,strlen("Nom de famille"),16);
	strmid(Perso[playerid][ep_Prenom],"Prenom",0,strlen("Prenom"),16);
	Perso[playerid][ep_Sexe] = 0;
	Perso[playerid][ep_Skin] = 1;
	Perso[playerid][ep_Age] = 16;
	Perso[playerid][ep_Ethnie] = 0;
	Perso[playerid][ep_Money] = 0;
	Perso[playerid][ep_Job] = 0;
	Perso[playerid][ep_PosX] = 0.0000;
	Perso[playerid][ep_PosY] = 0.0000;
	Perso[playerid][ep_PosZ] = 0.0000;
	Perso[playerid][ep_Rot] = 0.0000;
	Perso[playerid][ep_Interior] = 0;
	Perso[playerid][ep_Monde] = 999;
	Perso[playerid][ep_Created] = 0;
	//--------------------------------------------------------------------------
	SetPlayerColor(playerid, 0xFFFFFFFF);
    return SetTimerEx("PlayerCameraLogin",100,false,"i",playerid);
}

public OnPlayerDisconnect(playerid, reason)
{
	new Cache:result;
 	if(GetPVarInt(playerid,"CharacterSpawn") != 0)
	{
	    GetPlayerPos(playerid,Perso[playerid][ep_PosX],Perso[playerid][ep_PosY],Perso[playerid][ep_PosZ]);
		GetPlayerFacingAngle(playerid,Perso[playerid][ep_Rot]);
		Perso[playerid][ep_Interior] = GetPlayerInterior(playerid);
		Perso[playerid][ep_Monde] = GetPlayerVirtualWorld(playerid);
		FreeStr(str);
		format(str,sizeof(str),"SELECT * FROM `personnages` WHERE `ep_CompteID`=%d",Compte[playerid][ec_ID]);
		result = mysql_query(database,str,true);
		orm_update(Perso[playerid][ep_ORMID]);
		cache_delete(result);
	}
	FreeStr(str);
	format(str,sizeof(str),"SELECT * FROM `comptes` WHERE `ec_ID`=%d",Compte[playerid][ec_ID]);
	result = mysql_query(database,str,true);
	orm_update(Compte[playerid][ec_ORMID]);
	return cache_delete(result);
}

public OnPlayerSpawn(playerid)
	return 1;

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
	return 0;

public OnGameModeInit()
{
	MysqlConnexion(SQL_PROTOCOL);
	LoadVParams();
	//--------------------------------------------------------------------------
	ShowNameTags(false);
	ShowPlayerMarkers(false);
	EnableStuntBonusForAll(false);
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
    //--------------------------------------------------------------------------
	SendSpecialRcon("hostname", SERVER_NAME);
	SendSpecialRcon("gamemodetext", SERVER_BUILD);
	SendSpecialRcon("mapname", SERVER_MAP);
	SendSpecialRcon("language", SERVER_LANGAGE);
	SendSpecialRcon("weburl", SERVER_URL);
	//--------------------------------------------------------------------------
    SetSVarInt("WeaponsDrop_Total",0);
    //--------------------------------------------------------------------------
	Timer[0] = SetTimer("Timer_A",1000,true);
    return print("GameMode Started With Success.");
}

public OnPlayerUpdate(playerid)
	return 1;

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], tmp[1024], idx;
    cmd = strtok(cmdtext,idx);
    if(strcmp(cmd,"/a",true)==0 || strcmp(cmd,"/admin",true)==0)
    {
        if(Compte[playerid][ec_AdminLvl] < ADMIN_MODERATOR)
       		return SendErrorMessage(playerid, "[STAFF] "#RGB_WHITE_COL"Vous n'êtes pas un membre du staff ou n'avez pas le rank d'administration suffisant.");
        new acmd[32];
        acmd = strtok(cmdtext,idx);
        if(!strlen(acmd))
        {
            SendClientMessage(playerid,COLOR_AHELP,"[Aide] "#RGB_WHITE_COL"(/a)dmin [sous-commande].");
            if(Compte[playerid][ec_AdminLvl] == ADMIN_MODERATOR)
            	SendClientMessage(playerid,COLOR_ASUBCMD,"x "#RGB_WHITE_COL"kick"#RGB_ASUBCMD_COL"x");
        }
        else if(strcmp(acmd,"kick",true)==0)
        {
            if(Compte[playerid][ec_AdminLvl] < ADMIN_MODERATOR)
                return SendErrorMessage(playerid, "[STAFF] "#RGB_WHITE_COL"Vous n'êtes pas un membre du staff ou n'avez pas le rank d'administration suffisant.");
            tmp = strtok(cmdtext,idx);
            if(!strlen(tmp))
                return SendErrorMessage(playerid, "[AIDE] "#RGB_WHITE_COL"(/a)dmin kick [ID / Partie du nom] [Raison].");
			new player = ReturnUser(tmp);
			if(!IsPlayerConnected(player))
			    return SendErrorMessage(playerid, "[ERREUR] "#RGB_WHITE_COL"Ce joueur n'est pas en ligne sur le serveur.");
            tmp = strrest(cmdtext,idx);
            if(!strlen(tmp))
                return  SendErrorMessage(playerid, "[AIDE] "#RGB_WHITE_COL"(/a)dmin kick [ID / Partie du nom] [Raison].");
			new adminname[MAX_PLAYER_NAME+1];
			GetPlayerName(playerid, adminname, sizeof(adminname));
			FreeStr(str);
			format(str,sizeof(str),"[Kick] "#RGB_WHITE_COL"Vous avez été kick du serveur par le membre du staff "#RGB_GOLD_COL"%s"#RGB_WHITE_COL".",adminname);
			SendClientMessage(player,COLOR_WHITE,str);
			FreeStr(str);
			format(str,sizeof(str),"Pour la raison suivante: "#RGB_ERROR_COL"%s",tmp);
			SendClientMessage(player,COLOR_WHITE,str);
			SetTimerEx("KickPlayer",100,false,"i",player);
        }
        else
        {
            SendClientMessage(playerid,COLOR_AHELP,"[Aide] "#RGB_WHITE_COL"(/a)dmin [sous-commande].");
            if(Compte[playerid][ec_AdminLvl] == ADMIN_MODERATOR)
            	SendClientMessage(playerid,COLOR_ASUBCMD,"x "#RGB_WHITE_COL"kick"#RGB_ASUBCMD_COL"x");
        }
        return 1;
    }
    if(strcmp(cmd,"/stats",true)==0)
    {
        //
    }
    if(strcmp(cmd,"/me",true)==0)
    {
        tmp = strrest(cmdtext,idx);
        if(!strlen(tmp))
            return SendClientMessage(playerid,COLOR_AHELP,"[Aide] "#RGB_WHITE_COL"/me [message]");
		FreeStr(str);
		format(str,sizeof(str),"%s %s %s",Perso[playerid][ep_Prenom],Perso[playerid][ep_Nom],tmp);
		return ActionMsg(playerid, str);
    }
    if(strcmp(cmd,"/do",true)==0)
    {
        tmp = strrest(cmdtext,idx);
        if(!strlen(tmp))
            return SendClientMessage(playerid,COLOR_AHELP,"[Aide] "#RGB_WHITE_COL"/me [message]");
		FreeStr(str);
		format(str,sizeof(str),"%s [%s %s]",tmp,Perso[playerid][ep_Prenom],Perso[playerid][ep_Nom]);
		return ActionMsg(playerid, str);
    }
	return SendErrorMessage(playerid,"[CMD] "#RGB_WHITE_COL"Cette commande n'existe pas.");
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_EDITING_VALUE:
	    {
	        if(!response)
	        {
	        }
	        switch(GetPVarInt(playerid,"PlayerDialogStyle"))
	        {
	            case DIALOG_STYLE_INTEGER:
	            {
	            }
	            case DIALOG_STYLE_FLOAT:
	            {
	            }
	            case DIALOG_STYLE_STRING:
	            {
	            }
	        }
	    }
	    case DIALOG_ACCOUNT_REGISTER:
	    {
            if(!response)
				return Kick(playerid);
	        if(strlen(inputtext) < SERVER_MIN_PASS || strlen(inputtext) >= SERVER_MAX_PASS)
	        {
				FreeStr(str);
				format(str,sizeof(str),"[Mot de passe] "#RGB_WHITE_COL"Votre mot doit contenir au minimum "#RGB_GOLD_COL"%d "#RGB_WHITE_COL"ou au maximum "#RGB_GOLD_COL"%d "#RGB_WHITE_COL"caractères.",
				SERVER_MIN_PASS,SERVER_MAX_PASS);
				SendClientMessage(playerid,CMD_ERROR_COL,str);
	            return ShowPlayerDialog(playerid,DIALOG_ACCOUNT_REGISTER,DIALOG_STYLE_INPUT,"Enregistrement",""#RGB_WHITE_COL"Entrez votre mot de passe:","Valider","Quitter");
	        }
	        return Create_New_PlayerAccount(playerid, inputtext);
	    }
	    case DIALOG_ACCOUNT_LOGIN:
	    {
	        if(!response)
				return Kick(playerid);
	        if(strlen(inputtext) < SERVER_MIN_PASS || strlen(inputtext) >= SERVER_MAX_PASS)
	        {
				FreeStr(str);
				format(str,sizeof(str),"[Mot de passe] "#RGB_WHITE_COL"Votre mot doit contenir au minimum "#RGB_GOLD_COL"%d "#RGB_WHITE_COL"ou au maximum "#RGB_GOLD_COL"%d "#RGB_WHITE_COL"caractères.",
				SERVER_MIN_PASS,SERVER_MAX_PASS);
				SendClientMessage(playerid,CMD_ERROR_COL,str);
	            return ShowPlayerDialog(playerid,DIALOG_ACCOUNT_LOGIN,DIALOG_STYLE_PASSWORD,"Connexion",""#RGB_WHITE_COL"Entrez votre mot de passe:","Valider","Quitter");
	        }
	        return OnPlayerLogin(playerid, inputtext);
	    }
	    case DIALOG_CHARACTER_AGE:
	    {
	        if(!response)
	            return 0;
			if(strval(inputtext) < 16 || strval(inputtext) > 60)
			{
				SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Attention l'âge de votre personnage ne peut être inférieur à 16 ans ou supérieur à 60 ans.");
				return ShowPlayerDialog(playerid,DIALOG_CHARACTER_AGE,DIALOG_STYLE_INPUT,"Age du personnage",""#RGB_WHITE_COL"Indiquer l'age de votre personnage de 16 à 60 ans.","Valider","Annuler");
			}
			Perso[playerid][ep_Age] = strval(inputtext);
			FreeStr(str);
			format(str,sizeof(str),"%d Ans",Perso[playerid][ep_Age]);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][12], str);
	    }
	    case DIALOG_CHARACTER_NAME:
	    {
	        if(!response)
         		return 0;
			if(strlen(inputtext) < 6 || strlen(inputtext) >= 16 || GetSpecialASCII(inputtext))
			{
			    SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Le nom de famille de votre personnage doit être composé au minimum de 6 caractères ou au maximum de 16 caractères.");
			    if(GetSpecialASCII(inputtext))
			        SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Les caractères speciaux ne sont pas autorisés ici.");
				return ShowPlayerDialog(playerid,DIALOG_CHARACTER_NAME,DIALOG_STYLE_INPUT,"Nom de famille du personnage",""#RGB_WHITE_COL"Indiquer le nom de famille de votre personnage.","Valider","Annuler");
			}
			strmid(Perso[playerid][ep_Nom],inputtext,0,strlen(inputtext),16);
			FreeStr(str);
			format(str,sizeof(str),"%s",Perso[playerid][ep_Nom]);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][10], str);
	    }
	    case DIALOG_CHARACTER_LASTNAME:
	    {
	        if(!response)
	            return 0;
            if(strlen(inputtext) < 6 || strlen(inputtext) >= 16 || GetSpecialASCII(inputtext))
			{
			    SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Le prénom de votre personnage doit être composé au minimum de 6 caractères ou au maximum de 16 caractères.");
			    if(GetSpecialASCII(inputtext))
			        SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Les caractères speciaux ne sont pas autorisés ici.");
				return ShowPlayerDialog(playerid,DIALOG_CHARACTER_LASTNAME,DIALOG_STYLE_INPUT,"Prénom du personnage",""#RGB_WHITE_COL"Indiquer le prénom de votre personnage.","Valider","Annuler");
			}
			strmid(Perso[playerid][ep_Prenom],inputtext,0,strlen(inputtext),16);
			FreeStr(str);
			format(str,sizeof(str),"%s",Perso[playerid][ep_Prenom]);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][11], str);
	    }
	}
	return 1;
}

public Timer_A()
{
	for(new wd = 0; wd < GetSVarInt("WeaponsDrop_Total"); wd++)
	{
	    if(WeaponDrop[wd][ewd_TimeSpan] > 0)
	    {
	        WeaponDrop[wd][ewd_TimeSpan] --;
	        if(WeaponDrop[wd][ewd_TimeSpan] < 1)
	        {
	            Delete3DTextLabel(ewd_Text[wd]);
	            DestroyObject(WeaponDrop[wd][ewd_ObjectID]);
			}
	    }
	}
	return 1;
}

public KickPlayer(playerid)
	return Kick(playerid);

public SQL_Check_Account(playerid)
{
	new playername[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid,playername,sizeof(playername));
	FreeStr(str);
	format(str,sizeof(str),"SELECT * FROM `comptes` WHERE `ec_Name`='%s'",playername);
	new Cache:result = mysql_query(database,str,true);
	new rows = CountSQLTab(str);
	if(rows != 0)
		ShowPlayerDialog(playerid,DIALOG_ACCOUNT_LOGIN,DIALOG_STYLE_PASSWORD,"Connexion",""#RGB_WHITE_COL"Entrez votre mot de passe:","Valider","Quitter");
	else
		ShowPlayerDialog(playerid,DIALOG_ACCOUNT_REGISTER,DIALOG_STYLE_INPUT,"Enregistrement",""#RGB_WHITE_COL"Entrez votre mot de passe:","Valider","Quitter");
	return cache_delete(result);
}

public Create_New_PlayerAccount(playerid, password[])
{
	new PlayerIP[16], playername[MAX_PLAYER_NAME+1];
	GetPlayerIp(playerid,PlayerIP,sizeof(PlayerIP));
	GetPlayerName(playerid,playername,sizeof(playername));
	strmid(Compte[playerid][ec_IP],PlayerIP,0,strlen(PlayerIP),16);
	strmid(Compte[playerid][ec_Password],password,0,strlen(password),512);
	strmid(Compte[playerid][ec_Name],playername,0,strlen(playername),MAX_PLAYER_NAME+1);
	Compte[playerid][ec_Tutorial] = 0;
	Compte[playerid][ec_AutoConnect] = 0;
	Compte[playerid][ec_AdminLvl] = 0;
	
	Compte[playerid][ec_ORMID] = orm_create("comptes",database);
	
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_ID],"ec_ID");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_IP],16,"ec_IP");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_Password],512,"ec_Password");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_Name],MAX_PLAYER_NAME+1,"ec_Name");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_Tutorial],"ec_Tutorial");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_AutoConnect],"ec_AutoConnect");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_AdminLvl],"ec_AdminLvl");
	
	orm_setkey(Compte[playerid][ec_ORMID],"ec_ID");
	return orm_insert(Compte[playerid][ec_ORMID],"EncryptRegisterPassword","i",playerid);
}

public EncryptRegisterPassword(playerid)
{
	FreeStr(str);
	format(str,sizeof(str),"UPDATE `comptes` SET `ec_Password`=MD5('%s') WHERE `ec_ID`=%d",Compte[playerid][ec_Password],Compte[playerid][ec_ID]);
	new Cache:result = mysql_query(database,str,true);
	cache_delete(result);
	return orm_select(Compte[playerid][ec_ORMID],"OnPasswordEncrypted","i",playerid);
}

public OnPasswordEncrypted(playerid)
	return ShowPlayerDialog(playerid,DIALOG_ACCOUNT_LOGIN,DIALOG_STYLE_PASSWORD,"Connexion","Entrez votre mot de passe:","Valider","Quitter");

public OnPlayerLogin(playerid, password[])
{
	new playername[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid,playername,sizeof(playername));
	FreeStr(str);
	format(str,sizeof(str),"SELECT * FROM `comptes` WHERE `ec_Password`=MD5('%s') AND `ec_Name`='%s'",password,playername);
	new Cache:result = mysql_query(database,str,true);
	if(!cache_num_rows())
	{
	    SendClientMessage(playerid,CMD_ERROR_COL,"[Mot de passe] "#RGB_WHITE_COL"Votre mot de passe est incorrecte.");
	    return ShowPlayerDialog(playerid,DIALOG_ACCOUNT_LOGIN,DIALOG_STYLE_PASSWORD,"Connexion","Entrez votre mot de passe:","Valider","Quitter");
	}
    Compte[playerid][ec_ORMID] = orm_create("comptes",database);

	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_ID],"ec_ID");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_IP],16,"ec_IP");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_Password],512,"ec_Password");
	orm_addvar_string(Compte[playerid][ec_ORMID],Compte[playerid][ec_Name],MAX_PLAYER_NAME+1,"ec_Name");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_Tutorial],"ec_Tutorial");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_AutoConnect],"ec_AutoConnect");
	orm_addvar_int(Compte[playerid][ec_ORMID],Compte[playerid][ec_AdminLvl],"ec_AdminLvl");

	orm_setkey(Compte[playerid][ec_ORMID],"ec_ID");
	orm_apply_cache(Compte[playerid][ec_ORMID],playerid);
	cache_delete(result);
	
	return SetTimerEx("PreviousSpawn",100,false,"i",playerid);
}

public CheckPlayerCharacter(playerid)
{
    FreeStr(str);
	format(str,sizeof(str),"SELECT * FROM `personnages` WHERE `ep_CompteID`=%d",Compte[playerid][ec_ID]);
	new rows = CountSQLTab(str);
	if(rows != 0)
	    return SetTimerEx("LoadCharacter",100,false,"i",playerid);
	return SetTimerEx("CreateNewCharacter",100,false,"i",playerid);
}

public PreviousSpawn(playerid)
{
    SetSpawnInfo(playerid,0,1,0.0,0.0,0.0,0.0,0,0,0,0,0,0);
	SpawnPlayer(playerid);
	return CheckPlayerCharacter(playerid);
}

public PlayerCameraLogin(playerid)
{
    CleanChat(playerid, 20);
	TogglePlayerControllable(playerid,false);
	SetPlayerPos(playerid,1802.2655,-1818.2560,0.0);
	SetPlayerCameraPos(playerid,1817.5249,-1849.5267,28.6349);
	SetPlayerCameraLookAt(playerid,1816.5709,-1849.8363,28.3998,0);
	//--------------------------------------------------------------------------
	TD_MAIN_SCREEN[playerid][0] = CreatePlayerTextDraw(playerid,319.666473,1.259160,"_");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][0],0.296333,10.568299);
	PlayerTextDrawTextSize(playerid,TD_MAIN_SCREEN[playerid][0],0.000000,641.000000);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][0],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][0],-1);
	PlayerTextDrawUseBox(playerid,TD_MAIN_SCREEN[playerid][0],1);
	PlayerTextDrawBoxColor(playerid,TD_MAIN_SCREEN[playerid][0],119);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][0],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][0],0);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][0],255);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][0],1);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][0],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][0],0);

	TD_MAIN_SCREEN[playerid][1] = CreatePlayerTextDraw(playerid,319.333129,350.948089,"_");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][1],0.296333,10.568299);
	PlayerTextDrawTextSize(playerid,TD_MAIN_SCREEN[playerid][1],0.000000,641.000000);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][1],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][1],-1);
	PlayerTextDrawUseBox(playerid,TD_MAIN_SCREEN[playerid][1],1);
	PlayerTextDrawBoxColor(playerid,TD_MAIN_SCREEN[playerid][1],119);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][1],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][1],0);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][1],255);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][1],1);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][1],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][1],0);

	TD_MAIN_SCREEN[playerid][2] = CreatePlayerTextDraw(playerid,319.666503,99.022155,"_");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][2],0.384333,-0.250074);
	PlayerTextDrawTextSize(playerid,TD_MAIN_SCREEN[playerid][2],0.000000,643.000000);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][2],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][2],-1);
	PlayerTextDrawUseBox(playerid,TD_MAIN_SCREEN[playerid][2],1);
	PlayerTextDrawBoxColor(playerid,TD_MAIN_SCREEN[playerid][2],-16776961);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][2],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][2],0);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][2],255);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][2],1);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][2],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][2],0);

	TD_MAIN_SCREEN[playerid][3] = CreatePlayerTextDraw(playerid,317.633178,350.399871,"_");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][3],0.384333,-0.250074);
	PlayerTextDrawTextSize(playerid,TD_MAIN_SCREEN[playerid][3],0.000000,643.000000);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][3],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][3],-1);
	PlayerTextDrawUseBox(playerid,TD_MAIN_SCREEN[playerid][3],1);
	PlayerTextDrawBoxColor(playerid,TD_MAIN_SCREEN[playerid][3],-16776961);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][3],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][3],0);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][3],255);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][3],1);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][3],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][3],0);

	FreeStr(str);
	format(str,sizeof(str),"~w~Mode: ~b~%s~n~~w~Last_update: ~b~%s~n~~w~Site: ~b~%s~n~~n~~n~~n~~n~~n~~w~Created by ~y~%s",
	SERVER_BUILD,SERVER_UPDATE,SERVER_URL,SERVER_MAKER);
	TD_MAIN_SCREEN[playerid][4] = CreatePlayerTextDraw(playerid,3.333337,352.269958,str);
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][4],0.293666,1.106370);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][4],1);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][4],-1523963137);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][4],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][4],1);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][4],255);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][4],1);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][4],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][4],0);

	TD_MAIN_SCREEN[playerid][5] = CreatePlayerTextDraw(playerid,307.533386,78.829635,"PROJET_HEALAND");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][5],0.807333,3.748739);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][5],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][5],255);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][5],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][5],1);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][5],136);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][5],3);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][5],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][5],0);

	TD_MAIN_SCREEN[playerid][6] = CreatePlayerTextDraw(playerid,305.666625,81.029602,"PROJET_HEALAND");
	PlayerTextDrawLetterSize(playerid,TD_MAIN_SCREEN[playerid][6],0.807333,3.748739);
	PlayerTextDrawAlignment(playerid,TD_MAIN_SCREEN[playerid][6],2);
	PlayerTextDrawColor(playerid,TD_MAIN_SCREEN[playerid][6],-5963521);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][6],0);
	PlayerTextDrawSetOutline(playerid,TD_MAIN_SCREEN[playerid][6],1);
	PlayerTextDrawBackgroundColor(playerid,TD_MAIN_SCREEN[playerid][6],136);
	PlayerTextDrawFont(playerid,TD_MAIN_SCREEN[playerid][6],3);
	PlayerTextDrawSetProportional(playerid,TD_MAIN_SCREEN[playerid][6],1);
	PlayerTextDrawSetShadow(playerid,TD_MAIN_SCREEN[playerid][6],0);
	
	for(new td = 0; td <= 6; td++)
	    PlayerTextDrawShow(playerid, TD_MAIN_SCREEN[playerid][td]);
	SetPVarInt(playerid,"TD_MAIN_SCREEN",1);
	return SetTimerEx("SQL_Check_Account",100,false,"i",playerid);
}

public SpawnThisCharacter(playerid)
{
	if(GetPVarInt(playerid,"TD_MAIN_SCREEN") != 0)
	{
	    SetPVarInt(playerid,"TD_MAIN_SCREEN",0);
	    for(new td = 0; td <= 6; td++)
		    PlayerTextDrawDestroy(playerid, TD_MAIN_SCREEN[playerid][td]);
	}
	//--------------------------------------------------------------------------
	SetPVarInt(playerid,"CharacterSpawn",1);
	TogglePlayerControllable(playerid,true);
	GivePlayerMoney(playerid,Perso[playerid][ep_Money]);
	SetPlayerPos(playerid,Perso[playerid][ep_PosX],Perso[playerid][ep_PosY],Perso[playerid][ep_PosZ]);
	SetPlayerFacingAngle(playerid,Perso[playerid][ep_Rot]);
	SetPlayerInterior(playerid,Perso[playerid][ep_Interior]);
	SetPlayerVirtualWorld(playerid,Perso[playerid][ep_Monde]);
	SetPlayerSkin(playerid,Perso[playerid][ep_Skin]);
	SetPlayerMoney(playerid, Perso[playerid][ep_Money]);
	FreeStr(str);
	format(str,sizeof(str),"%s %s",Perso[playerid][ep_Prenom],Perso[playerid][ep_Nom]);
	tPlayerName[playerid] = CreateDynamic3DTextLabel(str,0xFFFFFFFF,Perso[playerid][ep_PosX],Perso[playerid][ep_PosY],Perso[playerid][ep_PosZ]+0.2,20.0,playerid,INVALID_VEHICLE_ID,1,-1,-1,-1,20.0);
	return SetCameraBehindPlayer(playerid);
}

public LoadCharacter(playerid)
{
	FreeStr(str);
	format(str,sizeof(str),"SELECT * FROM `personnages` WHERE `ep_CompteID`=%d",Compte[playerid][ec_ID]);
	new Cache:result = mysql_query(database,str,true);
	//--------------------------------------------------------------------------
	Perso[playerid][ep_ORMID] = orm_create("personnages",database);

    orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_ID],"ep_ID");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_CompteID],"ep_CompteID");
	orm_addvar_string(Perso[playerid][ep_ORMID],Perso[playerid][ep_Nom],16,"ep_Nom");
	orm_addvar_string(Perso[playerid][ep_ORMID],Perso[playerid][ep_Prenom],16,"ep_Prenom");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Sexe],"ep_Sexe");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Skin],"ep_Skin");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Age],"ep_Age");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Ethnie],"ep_Ethnie");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Money],"ep_Money");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Job],"ep_Job");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosX],"ep_PosX");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosY],"ep_PosY");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosZ],"ep_PosZ");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_Rot],"ep_Rot");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Interior],"ep_Interior");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Monde],"ep_Monde");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Created],"ep_Created");

	orm_setkey(Perso[playerid][ep_ORMID],"ep_ID");
	orm_apply_cache(Perso[playerid][ep_ORMID],playerid);
	orm_select(Perso[playerid][ep_ORMID],"ORM_CharacterLoaded","i",playerid);
	return cache_delete(result);
}

public ORM_CharacterLoaded(playerid)
{
	if(Perso[playerid][ep_Created] != 0)
		return SetTimerEx("SpawnThisCharacter",100,false,"i",playerid);
	return SetTimerEx("ORM_EditNewCharacter",100,false,"i",playerid);
}

public CreateNewCharacter(playerid)
{
	Perso[playerid][ep_CompteID] = Compte[playerid][ec_ID];
	strmid(Perso[playerid][ep_Nom],"Nom de famille",0,strlen("Nom de famille"),16);
	strmid(Perso[playerid][ep_Prenom],"Prenom",0,strlen("Prenom"),16);
	Perso[playerid][ep_Sexe] = GENDER_MALE;
	Perso[playerid][ep_Skin] = 1;
	Perso[playerid][ep_Age] = 16;
	Perso[playerid][ep_Ethnie] = 0;
	Perso[playerid][ep_Money] = 350;
	Perso[playerid][ep_Job] = 0;
	Perso[playerid][ep_PosX] = 0.0;
	Perso[playerid][ep_PosY] = 0.0;
	Perso[playerid][ep_PosZ] = 0.0;
	Perso[playerid][ep_Rot] = 0.0;
	Perso[playerid][ep_Interior] = 0;
	Perso[playerid][ep_Monde] = 0;
	Perso[playerid][ep_Created] = 0;
	//--------------------------------------------------------------------------
	Perso[playerid][ep_ORMID] = orm_create("personnages",database);

    orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_ID],"ep_ID");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_CompteID],"ep_CompteID");
	orm_addvar_string(Perso[playerid][ep_ORMID],Perso[playerid][ep_Nom],16,"ep_Nom");
	orm_addvar_string(Perso[playerid][ep_ORMID],Perso[playerid][ep_Prenom],16,"ep_Prenom");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Sexe],"ep_Sexe");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Skin],"ep_Skin");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Age],"ep_Age");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Ethnie],"ep_Ethnie");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Money],"ep_Money");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Job],"ep_Job");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosX],"ep_PosX");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosY],"ep_PosY");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_PosZ],"ep_PosZ");
	orm_addvar_float(Perso[playerid][ep_ORMID],Perso[playerid][ep_Rot],"ep_Rot");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Interior],"ep_Interior");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Monde],"ep_Monde");
	orm_addvar_int(Perso[playerid][ep_ORMID],Perso[playerid][ep_Created],"ep_Created");
	
	orm_setkey(Perso[playerid][ep_ORMID],"ep_ID");
	return orm_insert(Perso[playerid][ep_ORMID],"ORM_EditNewCharacter","i",playerid);
}

public ORM_EditNewCharacter(playerid)
{
    if(GetPVarInt(playerid,"TD_MAIN_SCREEN") != 0)
	{
	    SetPVarInt(playerid,"TD_MAIN_SCREEN",0);
	    for(new td = 0; td <= 6; td++)
		    PlayerTextDrawDestroy(playerid, TD_MAIN_SCREEN[playerid][td]);
	}
	//--------------------------------------------------------------------------
    SetPlayerInterior(playerid,11);
	SetPlayerVirtualWorld(playerid, PRIVATE_VIRTUAL_WORLD-playerid);
	SetPlayerPos(playerid,489.0507,-76.8341,998.7578);
	SetPlayerFacingAngle(playerid,235.0);
	SetPlayerCameraPos(playerid,492.2566,-79.0731,999.5158);
	SetPlayerCameraLookAt(playerid,489.0507,-76.8341,998.7578,0);
	SetPVarInt(playerid,"TDSelect",TD_SELECT_CUSTOM_CHARACTER);
	
	TD_CREATE_CHARACTER[playerid][0] = CreatePlayerTextDraw(playerid, 167.000076, 215.303680, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][0], 0.145000, 15.313766);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][0], 0.000000, 107.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][0], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][0], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][0], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][0], 0);

	TD_CREATE_CHARACTER[playerid][1] = CreatePlayerTextDraw(playerid, 167.000076, 226.804382, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][1], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][1], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][1], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][1], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][1], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][1], 0);

	TD_CREATE_CHARACTER[playerid][2] = CreatePlayerTextDraw(playerid, 167.000076, 245.320297, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][2], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][2], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][2], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][2], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][2], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][2], 0);

	TD_CREATE_CHARACTER[playerid][3] = CreatePlayerTextDraw(playerid, 167.000076, 263.821411, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][3], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][3], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][3], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][3], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][3], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][3], 0);

	TD_CREATE_CHARACTER[playerid][4] = CreatePlayerTextDraw(playerid, 167.000076, 282.422546, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][4], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][4], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][4], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][4], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][4], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][4], 0);

	TD_CREATE_CHARACTER[playerid][5] = CreatePlayerTextDraw(playerid, 167.666748, 300.723663, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][5], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][5], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][5], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][5], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][5], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][5], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][5], 0);

	TD_CREATE_CHARACTER[playerid][6] = CreatePlayerTextDraw(playerid, 167.666748, 319.124786, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][6], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][6], 0.000000, 103.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][6], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][6], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][6], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][6], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][6], 0);

	TD_CREATE_CHARACTER[playerid][7] = CreatePlayerTextDraw(playerid, 136.431533, 338.225952, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][7], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][7], 0.000000, 41.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][7], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][7], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][7], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][7], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][7], 0);

	TD_CREATE_CHARACTER[playerid][8] = CreatePlayerTextDraw(playerid, 198.335311, 338.640777, "_");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][8], 0.176999, 1.483837);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][8], 0.000000, 41.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][8], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][8], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][8], 85);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][8], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][8], 0);

	TD_CREATE_CHARACTER[playerid][9] = CreatePlayerTextDraw(playerid, 167.333358, 209.911102, "Edition_personnage");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][9], 0.208666, 0.861629);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][9], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][9], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][9], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][9], 3);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][9], 0);

	TD_CREATE_CHARACTER[playerid][10] = CreatePlayerTextDraw(playerid, 166.666671, 228.577758, "Nom_de_famille");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][10], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][10], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][10], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][10], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][10], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][10], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][10], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][10], 0);

	TD_CREATE_CHARACTER[playerid][11] = CreatePlayerTextDraw(playerid, 166.833374, 247.078887, "Prenom");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][11], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][11], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][11], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][11], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][11], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][11], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][11], 0);

	TD_CREATE_CHARACTER[playerid][12] = CreatePlayerTextDraw(playerid, 166.833374, 265.780029, "Age");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][12], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][12], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][12], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][12], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][12], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][12], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][12], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][12], 0);

	TD_CREATE_CHARACTER[playerid][13] = CreatePlayerTextDraw(playerid, 166.800064, 284.581176, "Masculin");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][13], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][13], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][13], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][13], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][13], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][13], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][13], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][13], 0);

	TD_CREATE_CHARACTER[playerid][14] = CreatePlayerTextDraw(playerid, 166.800064, 302.482269, "Americain");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][14], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][14], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][14], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][14], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][14], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][14], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][14], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][14], 0);

	TD_CREATE_CHARACTER[playerid][15] = CreatePlayerTextDraw(playerid, 167.633422, 321.183410, "Apparence");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][15], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][15], 10.73186, 101.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][15], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][15], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][15], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][15], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][15], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][15], 0);

	TD_CREATE_CHARACTER[playerid][16] = CreatePlayerTextDraw(playerid, 136.300018, 340.264831, "Par_defaut");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][16], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][16], 10.73186, 40.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][16], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][16], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][16], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][16], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][16], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][16], 0);

	TD_CREATE_CHARACTER[playerid][17] = CreatePlayerTextDraw(playerid, 198.303802, 340.150024, "Valider");
	PlayerTextDrawLetterSize(playerid, TD_CREATE_CHARACTER[playerid][17], 0.181999, 1.073186);
	PlayerTextDrawTextSize(playerid, TD_CREATE_CHARACTER[playerid][17], 10.73186, 40.000000);
	PlayerTextDrawAlignment(playerid, TD_CREATE_CHARACTER[playerid][17], 2);
	PlayerTextDrawColor(playerid, TD_CREATE_CHARACTER[playerid][17], -1);
	PlayerTextDrawUseBox(playerid, TD_CREATE_CHARACTER[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, TD_CREATE_CHARACTER[playerid][17], 0);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, TD_CREATE_CHARACTER[playerid][17], 1);
	PlayerTextDrawBackgroundColor(playerid, TD_CREATE_CHARACTER[playerid][17], 255);
	PlayerTextDrawFont(playerid, TD_CREATE_CHARACTER[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, TD_CREATE_CHARACTER[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, TD_CREATE_CHARACTER[playerid][17], 0);
	
	for(new td = 10; td <= 17; td++)
	    PlayerTextDrawSetSelectable(playerid, TD_CREATE_CHARACTER[playerid][td], true);

    for(new td = 0; td <= 17; td++)
        PlayerTextDrawShow(playerid, TD_CREATE_CHARACTER[playerid][td]);

	return SelectTextDraw(playerid, COLOR_AHELP);
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:INVALID_TEXT_DRAW)
  	{
  	    if(GetPVarInt(playerid,"TDSelect") == TD_SELECT_CUSTOM_CHARACTER)
  	    {
  	        for(new td = 10; td <= 17; td++)
	    		PlayerTextDrawSetSelectable(playerid, TD_CREATE_CHARACTER[playerid][td], true);
            SelectTextDraw(playerid, COLOR_AHELP);
  	    }
  	}
  	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(_:playertextid == 65535)
	    return 0;
	if(GetPVarInt(playerid,"TDSelect") == TD_SELECT_CUSTOM_CHARACTER)
	{
	    if(playertextid == TD_CREATE_CHARACTER[playerid][10]) // Nom de famille
	        ShowPlayerDialog(playerid,DIALOG_CHARACTER_NAME,DIALOG_STYLE_INPUT,"Nom de famille du personnage",""#RGB_WHITE_COL"Indiquer le nom de famille de votre personnage.","Valider","Annuler");
		if(playertextid == TD_CREATE_CHARACTER[playerid][11]) // Prénom
		    ShowPlayerDialog(playerid,DIALOG_CHARACTER_LASTNAME,DIALOG_STYLE_INPUT,"Prénom du personnage",""#RGB_WHITE_COL"Indiquer le prénom de votre personnage.","Valider","Annuler");
		if(playertextid == TD_CREATE_CHARACTER[playerid][12]) // Age
			ShowPlayerDialog(playerid,DIALOG_CHARACTER_AGE,DIALOG_STYLE_INPUT,"Age du personnage",""#RGB_WHITE_COL"Indiquer l'age de votre personnage de 16 à 60 ans.","Valider","Annuler");
		if(playertextid == TD_CREATE_CHARACTER[playerid][13]) // Sexe
		{
		    Perso[playerid][ep_Sexe] ++;
		    if(Perso[playerid][ep_Sexe] > 1)
		        Perso[playerid][ep_Sexe] = 0;
			new stxt[16];
			if(Perso[playerid][ep_Sexe] == GENDER_MALE) { stxt = "Masculin"; }
			else { stxt = "Feminin"; }
			FreeStr(str);
			format(str,sizeof(str),"%s",stxt);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][13], str);
			FreeStr(str);
			if(Perso[playerid][ep_Sexe] == GENDER_MALE)
				format(str,sizeof(str),"%s",Ethnie_Male[Perso[playerid][ep_Ethnie]]);
			else
			    format(str,sizeof(str),"%s",Ethnie_Female[Perso[playerid][ep_Ethnie]]);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][14], str);
		    Perso[playerid][ep_Skin] = 1;
			while(Perso[playerid][ep_Skin] <= 299)
			{
			    Perso[playerid][ep_Skin] ++;
			    if(Perso[playerid][ep_Sexe] == GENDER_MALE)
			    {
				    if(Skin_Americain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinois_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italien_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
				if(Perso[playerid][ep_Sexe] == GENDER_FEMALE)
				{
				    if(Skin_Americaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinoise_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italienne_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
			}
			SetPlayerSkin(playerid, Perso[playerid][ep_Skin]);
		}
		if(playertextid == TD_CREATE_CHARACTER[playerid][14]) // Ethnie
		{
			Perso[playerid][ep_Ethnie] ++;
			if(Perso[playerid][ep_Ethnie] >= 5)
			    Perso[playerid][ep_Ethnie] = 0;
			FreeStr(str);
			if(Perso[playerid][ep_Sexe] == GENDER_MALE)
				format(str,sizeof(str),"%s",Ethnie_Male[Perso[playerid][ep_Ethnie]]);
			else
			    format(str,sizeof(str),"%s",Ethnie_Female[Perso[playerid][ep_Ethnie]]);
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][14], str);
			Perso[playerid][ep_Skin] = 1;
			while(Perso[playerid][ep_Skin] <= 299)
			{
			    Perso[playerid][ep_Skin] ++;
			    if(Perso[playerid][ep_Sexe] == GENDER_MALE)
			    {
				    if(Skin_Americain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinois_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italien_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
				if(Perso[playerid][ep_Sexe] == GENDER_FEMALE)
				{
				    if(Skin_Americaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinoise_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italienne_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
			}
			SetPlayerSkin(playerid, Perso[playerid][ep_Skin]);
		}
		if(playertextid == TD_CREATE_CHARACTER[playerid][15]) // Apparence
		{
			while(Perso[playerid][ep_Skin] != -1)
			{
			    Perso[playerid][ep_Skin] ++;
				if(Perso[playerid][ep_Skin] > 299)
				    Perso[playerid][ep_Skin] = 1;
			    if(Perso[playerid][ep_Sexe] == GENDER_MALE)
			    {
				    if(Skin_Americain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinois_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicain_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italien_Homme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
				if(Perso[playerid][ep_Sexe] == GENDER_FEMALE)
				{
				    if(Skin_Americaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 0)
						break;
					if(Skin_Chinoise_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 1)
						break;
					if(Skin_Mexicaine_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 2)
					    break;
					if(Skin_Russe_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 3)
						break;
					if(Skin_Italienne_Femme(Perso[playerid][ep_Skin]) && Perso[playerid][ep_Ethnie] == 4)
					    break;
				}
			}
			SetPlayerSkin(playerid, Perso[playerid][ep_Skin]);
		}
		if(playertextid == TD_CREATE_CHARACTER[playerid][16]) // Reset
		{
		    PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][10], "Nom de famille");
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][11], "Prenom");
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][12], "Age");
			Perso[playerid][ep_Sexe] = 0;
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][13], "Masculin");
			Perso[playerid][ep_Ethnie] = 0;
			PlayerTextDrawSetString(playerid, TD_CREATE_CHARACTER[playerid][14], "Americain");
			Perso[playerid][ep_Skin] = 1;
			SetPlayerSkin(playerid, Perso[playerid][ep_Skin]);
		}
		if(playertextid == TD_CREATE_CHARACTER[playerid][17]) // Valider
		{
		    if(strcmp(Perso[playerid][ep_Nom],"Nom de famille",true)==0 || strcmp(Perso[playerid][ep_Prenom],"Prenom",true)==0)
		    	return SendClientMessage(playerid,CMD_ERROR_COL,"[Indication] "#RGB_WHITE_COL"Vous n'avez pas indiqué le nom de famille ou le prénom du personnage.");
			SetPVarInt(playerid,"TDSelect",0);
			CancelSelectTextDraw(playerid);
			for(new td = 0; td <= 17; td++)
			    PlayerTextDrawDestroy(playerid, TD_CREATE_CHARACTER[playerid][td]);
			Perso[playerid][ep_Created] = 1;
		    Perso[playerid][ep_Monde] = 0;
		    Perso[playerid][ep_Interior] = 0;
		    Perso[playerid][ep_PosX] = 1742.9153;
			Perso[playerid][ep_PosY] = -1861.7679;
			Perso[playerid][ep_PosZ] = 13.5771;
			Perso[playerid][ep_Rot] = 360.0;
		    FreeStr(str);
		    format(str,sizeof(str),"SELECT * FROM `personnages` WHERE `ep_CompteID`=%d",Compte[playerid][ec_ID]);
		    new Cache:result = mysql_query(database,str,true);
		    orm_update(Perso[playerid][ep_ORMID]);
		    cache_delete(result);
		    SetTimerEx("SpawnThisCharacter",100,false,"i",playerid);
		}
	}
	return 1;
}

public LoadVParams()
{
	new Cache:result = mysql_query(database,"DELETE FROM `vparams` WHERE `evp_Suppr`=1",true);
	cache_delete(result);
	//--------------------------------------------------------------------------
	new rows = CountSQLTab("SELECT * FROM `vparams`");
	for(new vp = 0; vp < rows; vp++)
	{
	    VParams[vp][evp_ORMID] = orm_create("vparams",database);
	    
	    orm_addvar_int(VParams[vp][evp_ORMID],VParams[vp][evp_ID],"evp_ID");
	    orm_addvar_int(VParams[vp][evp_ORMID],VParams[vp][evp_Model],"evp_Model");
	    orm_addvar_string(VParams[vp][evp_ORMID],VParams[vp][evp_Name],32,"evp_Name");
	    orm_addvar_int(VParams[vp][evp_ORMID],VParams[vp][evp_Price],"evp_Price");
	    orm_addvar_float(VParams[vp][evp_ORMID],VParams[vp][evp_MaxFuel],"evp_MaxFuel");
	    orm_addvar_int(VParams[vp][evp_ORMID],VParams[vp][evp_Suppr],"evp_Suppr");
	    
	    orm_setkey(VParams[vp][evp_ORMID],"evp_ID");
	    orm_apply_cache(VParams[vp][evp_ORMID],vp);
	}
	return LoadVehicles();
}

public LoadVehicles()
{
    new Cache:result = mysql_query(database,"DELETE FROM `vehicles` WHERE `ev_Suppr`=1",true);
	cache_delete(result);
	//--------------------------------------------------------------------------
	new rows = CountSQLTab("SELECT * FROM `vehicles`");
	for(new v = 0; v < rows; v++)
	{
	    Vehicles[v][ev_ORMID] = orm_create("vehicles",database);
	    
	    orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_ID],"ev_ID");
		orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_ParamsID],"ev_ParamsID");
		orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_PersoID],"ev_PersoID");
		orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_ColorA],"ev_ColorA");
		orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_ColorB],"ev_ColorB");
		orm_addvar_float(Vehicles[v][ev_ORMID],Vehicles[v][ev_Etat],"ev_Etat");
		orm_addvar_float(Vehicles[v][ev_ORMID],Vehicles[v][ev_PosX],"ev_PosX");
		orm_addvar_float(Vehicles[v][ev_ORMID],Vehicles[v][ev_PosY],"ev_PosY");
		orm_addvar_float(Vehicles[v][ev_ORMID],Vehicles[v][ev_PosZ],"ev_PosZ");
		orm_addvar_float(Vehicles[v][ev_ORMID],Vehicles[v][ev_Rot],"ev_Rot");
		orm_addvar_int(Vehicles[v][ev_ORMID],Vehicles[v][ev_Suppr],"ev_Suppr");
		
		orm_setkey(Vehicles[v][ev_ORMID],"ev_ID");
	    orm_apply_cache(Vehicles[v][ev_ORMID],v);
	    
	    new params = Vehicles[v][ev_ParamsID];
		CreateVehicle(VParams[params][evp_Model],Vehicles[v][ev_PosX],Vehicles[v][ev_PosY],Vehicles[v][ev_PosZ],Vehicles[v][ev_Rot],Vehicles[v][ev_ColorA],Vehicles[v][ev_ColorB],-1);
	}
	return printf("Number of vehicles load [%d]",rows);
}

//--------------------------[ FONCTIONS ]---------------------------------------

SendErrorMessage(playerid, string[])
	return SendClientMessage(playerid,CMD_ERROR_COL,string);

MysqlConnexion(protocol = false)
{
	if(protocol)
		database = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS, SQL_TABLE);
	else
	    database = mysql_connect(SQL_LHOST, SQL_LUSER, SQL_LPASS, SQL_LTABLE);
	if(!mysql_errno())
	    return print("Mysql Plugin: Connexion réussi");
 	return print("Mysql plugin: Connexion échoué");
}

CountSQLTab(request[], rows = 0)
{
	new Cache:result = mysql_query(database,request,true);
	rows = cache_num_rows();
	cache_delete(result);
	return rows;
}

FreeStr(var[])
	return strdel(var,0,strlen(var));
	
SendSpecialRcon(string1[], string2[])
{
    FreeStr(str);
	format(str,sizeof(str),"%s %s",string1,string2);
	return SendRconCommand(str);
}

/*SendAdminMsg(playerid, rank, color, string[])
{
	for(new i = 0; i < MAX_JOUEURS; i++)
		if(Compte[i][ec_AdminLvl] >= rank && i != playerid)
		    SendClientMessage(i,color,string);
	return 1;
}*/

Skin_Americain_Homme(skinid)
{
	if((skinid == 2 || skinid == 7)||(skinid >= 17 && skinid <= 22)||(skinid >= 25 && skinid <= 26))
	    return true;
	if((skinid >= 28 && skinid <= 29)||(skinid == 34)||(skinid == 37)||(skinid >= 66 && skinid <= 67))
	    return true;
	if((skinid == 100)||(skinid == 181)||(skinid >= 247 && skinid <= 248)||(skinid == 254))
	    return true;
	return false;
}

Skin_Americaine_Femme(skinid)
{
	if((skinid == 11)||(skinid == 13)||(skinid == 40)||(skinid == 64)||(skinid == 93)||(skinid >= 139 && skinid <= 140))
	    return true;
	return false;
}

Skin_Chinois_Homme(skinid)
{
	if((skinid == 23)||(skinid >= 59 && skinid <= 60)||(skinid >= 117 && skinid <= 118)||(skinid >= 120 && skinid <= 123))
	    return true;
	if((skinid == 170)||(skinid >= 186 && skinid <= 187))
	    return true;
	return false;
}

Skin_Chinoise_Femme(skinid)
{
	if((skinid == 56)||(skinid == 141)||(skinid == 169)||(skinid == 193)||(skinid == 226)||(skinid == 263))
	    return true;
	return false;
}

Skin_Mexicain_Homme(skinid)
{
	if((skinid == 30)||(skinid == 45)||(skinid >= 46 && skinid <= 48)||(skinid == 184)||(skinid == 189)||(skinid == 292))
	    return true;
	return false;
}

Skin_Mexicaine_Femme(skinid)
{
	if((skinid == 12)||(skinid == 39)||(skinid == 41)||(skinid == 63)||(skinid == 91)||(skinid == 138)||(skinid == 195)||(skinid == 211)||(skinid == 214))
	    return true;
	return false;
}

Skin_Russe_Homme(skinid)
{
	if((skinid == 72)||(skinid == 101)||(skinid >= 111 && skinid <= 113)||(skinid == 127)||(skinid == 154)||(skinid == 177)||(skinid == 291))
	    return true;
	return false;
}

Skin_Russe_Femme(skinid)
{
	if((skinid == 85)||(skinid == 152)||(skinid == 172)||(skinid >= 191 && skinid <= 192)||(skinid == 197)||(skinid == 201)||(skinid == 251))
	    return true;
	return false;
}

Skin_Italien_Homme(skinid)
{
	if((skinid == 96)||(skinid == 98)||(skinid >= 124 && skinid <= 126)||(skinid == 171)||(skinid == 188)||(skinid == 299))
	    return true;
	return false;
}

Skin_Italienne_Femme(skinid)
{
	if((skinid == 53)||(skinid == 55)||(skinid == 151)||(skinid == 233))
	    return true;
	return false;
}

GetSpecialASCII(string[])
{
	new bool:result = false;
	for(new c = 0; c < strlen(string); c++)
	    if(((string[c] < 48) || (string[c] > 57 && string[c] < 65) || (string[c] > 90 && string[c] < 97) || (string[c] > 122)) && string[c] != 32)
			result = true;
	return result;
}

ActionMsg(playerid, string[])
{
	for(new i = 0; i < MAX_JOUEURS; i++)
	    if(IsPlayerConnected(i) && !IsPlayerNPC(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
	        SendClientMessage(i,0xBA75FFFF,string);
	return 1;
}

SetPlayerMoney(playerid, money)
{
	ResetPlayerMoney(playerid);
	Perso[playerid][ep_Money] = money;
	return GivePlayerMoney(playerid,Perso[playerid][ep_Money]);
}

CleanChat(playerid, lines)
{
	for(new l = 0; l < lines; l++)
	    SendClientMessage(playerid,0xFFFFFFFF," ");
	return 1;
}
