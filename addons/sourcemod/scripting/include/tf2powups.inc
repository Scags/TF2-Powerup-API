#if defined _tf2powups_included
  #endinput
#endif
#define _tf2powups_included

enum RuneTypes
{
	Rune_Invalid = -1,
	Rune_Plague,
	Rune_King,
	Rune_Knockout,
	Rune_Agility,
	Rune_Precision,
	Rune_Reflect,	// Warlock
	Rune_Vampire,
	Rune_Resist,
	Rune_Regen,
	Rune_Supernova,
	Rune_Haste,
	Rune_Strength,

	Rune_LENGTH
}

#define RuneTypes_t RuneTypes 	// Cuz

native int TF2_CreateRune(float pos[3], RuneTypes type, int idk = -2, bool idk2 = false, bool idk3 = false, float vel[3] = {0.0, 0.0, 0.0});

native RuneTypes TF2_GetRuneType(int rune);

// Use TF2_RemoveCondition
//native void TF2_DropRune(int client, bool idk, int idk2);


forward Action TF2_OnRuneSpawn(float pos[3], RuneTypes &type, int &idk, bool &idk2, bool &idk3, float vel[3])
forward void TF2_OnRuneSpawnPost(int rune, float pos[3], RuneTypes type, int idk, bool idk2, bool idk3, float vel[3])

forward Action TF2_CanRuneBeTouched(int rune, int client, bool &status);

// Use TF2_OnConditionAdded
//forward void TF2_OnRunePickup(int rune, int client, RuneTypes type);

public SharedPlugin __pl_tf2powups = {
	name = "tf2powups",
	file = "tf2powups.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_tf2powups_SetNTVOptional()
{
	MarkNativeAsOptional("TF2_CreateRune");
	MarkNativeAsOptional("TF2_GetRuneType");
//	MarkNativeAsOptional("TF2_DropRune");
}
#endif