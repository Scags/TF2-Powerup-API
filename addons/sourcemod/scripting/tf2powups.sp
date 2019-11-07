#include <sourcemod>
#include <dhooks>
#include <sdktools>
#include <tf2_stocks>
#include <tf2powups>

#define DEBUG 0

public Plugin myinfo = 
{
	name = "TF2 Rune API", 
	author = "Scag", 
	description = "Some extra stuff for TF2's powerups", 
	version = "1.0.0", 
	url = ""
};

GlobalForward
	hOnRuneSpawn,
	hOnRuneSpawnPost,
//	hOnRuneTouch,
	hCanBeTouched
;

RuneTypes
	iRuneTypes[1 << 11] = { Rune_Invalid, ... }		// Abysmal
;

Handle
	hItemCanBeTouchedByPlayer,
//	hMyTouch,
	hCreateRune
//	hDropRune
;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("TF2_CreateRune", Native_CreateRune);
	CreateNative("TF2_GetRuneType", Native_GetRuneType);
//	CreateNative("TF2_DropRune", Native_DropRune);

	hOnRuneSpawn 		= new GlobalForward("TF2_OnRuneSpawn", ET_Hook, Param_Array, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_Array);
	hOnRuneSpawnPost 	= new GlobalForward("TF2_OnRuneSpawnPost", ET_Ignore, Param_Cell, Param_Array, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Array);
//	hOnRuneTouch		= new GlobalForward("TF2_OnRunePickup", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	hCanBeTouched 		= new GlobalForward("TF2_CanRuneBeTouched", ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);

	RegPluginLibrary("tf2powups");
	return APLRes_Success;
}

public void OnPluginStart()
{
	GameData conf = new GameData("tf2.powups");

	hItemCanBeTouchedByPlayer = DHookCreate(0, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CTFRune_ItemCanBeTouchedByPlayer);
	DHookSetFromConf(hItemCanBeTouchedByPlayer, conf, SDKConf_Virtual, "CTFRune::ItemCanBeTouchedByPlayer");
	DHookAddParam(hItemCanBeTouchedByPlayer, HookParamType_CBaseEntity);
	if (!hItemCanBeTouchedByPlayer)
		SetFailState("Could not load hook for CTFRune::ItemCanBeTouchedByPlayer!");

/*	hMyTouch = DHookCreate(0, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CTFRune_MyTouch);
	DHookSetFromConf(hMyTouch, conf, SDKConf_Virtual, "CTFRune::MyTouch");
	DHookAddParam(hMyTouch, HookParamType_CBaseEntity);
	if (!hMyTouch)
		SetFailState("Could not load hook for CTFRune::MyTouch!");*/

	Handle hook = DHookCreateDetour(Address_Null, CallConv_CDECL, ReturnType_CBaseEntity, ThisPointer_Ignore);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFRune::CreateRune");
	DHookAddParam(hook, HookParamType_VectorPtr, _, DHookPass_ByRef);
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Bool);
	DHookAddParam(hook, HookParamType_Bool);
	DHookAddParam(hook, HookParamType_VectorPtr);
	if (!DHookEnableDetour(hook, false, CTFRune_CreateRune) || !DHookEnableDetour(hook, true, CTFRune_CreateRunePost))
		SetFailState("Could not load detour for CTFRune::CreateRune!")

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTFRune::CreateRune");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, VDECODE_FLAG_BYREF);	// pos
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// RuneTypes_t
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// -2
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	// bool
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	// bool
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if (!(hCreateRune = EndPrepSDKCall()))
		SetFailState("Could not load call to CTFRune::CreateRune");

/*	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTFPlayer::DropRune");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if (!(hDropRune = EndPrepSDKCall()))
		SetFailState("Could not load call to CTFPlayer::DropRune");*/

	delete conf;

#if DEBUG
	RegAdminCmd("sm_spawnrune", CmdSpawnRune, ADMFLAG_ROOT);
#endif
}

#if DEBUG
public Action CmdSpawnRune(int client, int args)
{
	char arg[32]; GetCmdArg(1, arg, sizeof(arg));
	int target = FindTarget(client, arg);
	float pos[3]; GetClientAbsOrigin(target, pos);
	char arg2[32]; GetCmdArg(2, arg2, sizeof(arg2));

	int rune = TF2_CreateRune(pos, view_as< RuneTypes >(StringToInt(arg2)));
	ReplyToCommand(client, "%d | %d", rune, TF2_GetRuneType(rune));
	return Plugin_Handled;
}

public Action TF2_OnRuneSpawn(float pos[3], RuneTypes &type, int &idk, bool &idk2, bool &idk3, float vel[3])
{
	PrintToServer("TF2_OnRuneSpawn((%.2f %.2f %.2f), %d, %d, %d, %d, (%.2f %.2f %.2f))", pos[0], pos[1], pos[2], type, idk, idk2, idk3, vel[0], vel[1], vel[2]);
}

public void TF2_OnRuneSpawnPost(int rune, float pos[3], RuneTypes type, int idk, bool idk2, bool idk3, float vel[3])
{
	PrintToServer("TF2_OnRuneSpawnPost(%d, (%.2f %.2f %.2f), %d, %d, %d, %d, (%.2f %.2f %.2f))", rune, pos[0], pos[1], pos[2], type, idk, idk2, idk3, vel[0], vel[1], vel[2]);
}

public Action TF2_CanRuneBeTouched(int rune, int client, bool &status)
{
	PrintToServer("TF2_CanRuneBeTouched(%d, %d, %d)", rune, client, status);
}

/*public void TF2_OnRunePickup(int rune, int client, RuneTypes type)
{
	PrintToServer("TF2_OnRunePickup(%d, %d, %d)", rune, client, type);
}*/

#endif

public void OnEntityCreated(int ent, const char[] classname)
{
	if (!strncmp(classname, "item_power", 10, false))
	{
		DHookEntity(hItemCanBeTouchedByPlayer, true, ent);
//		DHookEntity(hMyTouch, true, ent);
	}
}

public void OnEntityDestroyed(int ent, const char[] classname)
{
	if (!strncmp(classname, "item_power", 10, false))
		iRuneTypes[EntRefToEntIndex(ent)] = Rune_Invalid;
}

public MRESReturn CTFRune_ItemCanBeTouchedByPlayer(int pThis, Handle hReturn, Handle hParams)
{
	int other = DHookGetParam(hParams, 1);
	bool status = DHookGetReturn(hReturn);
	Action action;

	Call_StartForward(hCanBeTouched);
	Call_PushCell(pThis);
	Call_PushCell(other);
	Call_PushCellRef(status);
	Call_Finish(action);

	if (action == Plugin_Changed)
	{
		DHookSetReturn(hReturn, status);
		return MRES_Override;
	}
	else if (action >= Plugin_Handled)
	{
		DHookSetReturn(hReturn, false);
		return MRES_Override;
	}

	return MRES_Ignored;
}

/*public MRESReturn CTFRune_MyTouch(int pThis, Handle hParams)
{
	int other = DHookGetParam(hParams, 1);
	if (!other)	// Can be world apparently
		return MRES_Ignored;

	Call_StartForward(hOnRuneTouch);
	Call_PushCell(pThis);
	Call_PushCell(other);
	Call_Finish();
	return MRES_Ignored;
}*/

public MRESReturn CTFRune_CreateRune(Handle hReturn, Handle hParams)
{
	float pos[3]; DHookGetParamVector(hParams, 1, pos);
	RuneTypes runetype = DHookGetParam(hParams, 2);
	int idk = DHookGetParam(hParams, 3);
	bool idk2 = DHookGetParam(hParams, 4);
	bool idk3 = DHookGetParam(hParams, 5);
	float vel[3]; DHookGetParamVector(hParams, 6, vel);
	Action action;

	Call_StartForward(hOnRuneSpawn);
	Call_PushArrayEx(pos, 3, SM_PARAM_COPYBACK);
	Call_PushCellRef(runetype);
	Call_PushCellRef(idk);
	Call_PushCellRef(idk2);
	Call_PushCellRef(idk3);
	Call_PushArrayEx(vel, 3, SM_PARAM_COPYBACK);
	Call_Finish(action);

	if (action == Plugin_Changed)
	{
		DHookSetParamVector(hParams, 1, pos);
		DHookSetParam(hParams, 2, runetype);
		DHookSetParam(hParams, 3, idk);
		DHookSetParam(hParams, 4, idk2);
		DHookSetParam(hParams, 5, idk3);
		DHookSetParamVector(hParams, 6, vel);
		return MRES_ChangedHandled;
	}
	else if (action >= Plugin_Handled)
		return MRES_Supercede;

	return MRES_Ignored;
}

public MRESReturn CTFRune_CreateRunePost(Handle hReturn, Handle hParams)
{
	int rune = DHookGetReturn(hReturn);
	float pos[3]; DHookGetParamVector(hParams, 1, pos);
	RuneTypes runetype = DHookGetParam(hParams, 2);
	int idk = DHookGetParam(hParams, 3);
	bool idk2 = DHookGetParam(hParams, 4);
	bool idk3 = DHookGetParam(hParams, 5);
	float vel[3]; DHookGetParamVector(hParams, 6, vel);

	Call_StartForward(hOnRuneSpawnPost);
	Call_PushCell(rune);
	Call_PushArray(pos, 3);
	Call_PushCell(runetype);
	Call_PushCell(idk);
	Call_PushCell(idk2);
	Call_PushCell(idk3);
	Call_PushArray(vel, 3);
	Call_Finish();

	iRuneTypes[rune] = runetype;
	return MRES_Ignored;
}

public any Native_CreateRune(Handle plugin, int numParams)
{
	float pos[3]; GetNativeArray(1, pos, 3);
	float vel[3]; GetNativeArray(6, vel, 3);
	return CreateRune(pos, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), vel);
}

public any Native_GetRuneType(Handle plugin, int numParams)
{
	int rune = GetNativeCell(1);
	if (rune & (1 << 31))
		rune = EntRefToEntIndex(rune);
//	rune &= ~(1 << 31);	// No refs

	if (!IsValidEntity(rune))
		return ThrowNativeError(SP_ERROR_NATIVE, "Entity %d is invalid!", rune);

	char cls[32]; GetEntityClassname(rune, cls, sizeof(cls));
	PrintToServer("%s", cls);

	if (StrContains(cls, "item_powerup"))
		return ThrowNativeError(SP_ERROR_NATIVE, "Entity %d is not a powerup rune!", rune);

	return iRuneTypes[rune];
}

/*public any Native_DropRune(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	if (!TF2_IsPlayerInCondition(client, TFCond_HasRune))
		return;

	DropRune(client, GetNativeCell(2), GetNativeCell(3));
}*/

stock int CreateRune(float pos[3], RuneTypes runetype, int idk = -2, bool idk2 = false, bool idk3 = false, float vel[3] = {0.0, 0.0, 0.0})
{
	return SDKCall(hCreateRune, pos, runetype, idk, idk2, idk3, vel);
}

/*stock void DropRune(int client, bool idk, int idk2)
{
	SDKCall(hDropRune, client, idk, idk2);
}*/