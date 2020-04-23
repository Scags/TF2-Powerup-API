#include <sdktools>
#include <tf2_stocks>

enum eRuneTypes
{
	Rune_Invalid = -1,
	Rune_Strength,
	Rune_Haste,
	Rune_Regen,
	Rune_Resist,
	Rune_Vampire,
	Rune_Reflect,
	Rune_Precision,
	Rune_Agility,
	Rune_Plague,
	Rune_King,
	Rune_Knockout,
	Rune_Supernova,

	Rune_LENGTH
}

#define RuneTypes 					eRuneTypes
#define RuneTypes_t 				eRuneTypes 	// Cuz

#define BLINK_TIME 					10.0

#define RUNE_REPOSITION_TIME 		60.0
// In freeforall mode, killed players drop enemy team colored powerups. These powerups reposition quicker
#define RUNE_REPOSITION_TIME_ANY	30.0

#define TF_RUNE_TEMP_RESPAWN_DELAY 	90.0
#define TF_RUNE_TEMP_UBER_RESPAWN_DELAY 	180.0

#define TF_RUNE_STRENGTH		"models/pickups/pickup_powerup_strength.mdl"
#define TF_RUNE_RESIST			"models/pickups/pickup_powerup_defense.mdl"
#define TF_RUNE_REGEN			"models/pickups/pickup_powerup_regen.mdl"
#define TF_RUNE_HASTE			"models/pickups/pickup_powerup_haste.mdl"
#define TF_RUNE_VAMPIRE			"models/pickups/pickup_powerup_vampire.mdl"
#define TF_RUNE_REFLECT 		"models/pickups/pickup_powerup_reflect.mdl"
#define TF_RUNE_PRECISION 		"models/pickups/pickup_powerup_precision.mdl"
#define TF_RUNE_AGILITY 		"models/pickups/pickup_powerup_agility.mdl"
#define TF_RUNE_KNOCKOUT 		"models/pickups/pickup_powerup_knockout.mdl"
#define TF_RUNE_KING			"models/pickups/pickup_powerup_king.mdl"
#define TF_RUNE_PLAGUE			"models/pickups/pickup_powerup_plague.mdl"
#define TF_RUNE_SUPERNOVA		"models/pickups/pickup_powerup_supernova.mdl"

#define TF_RUNE_TEMP_CRIT		"models/pickups/pickup_powerup_crit.mdl"
#define TF_RUNE_TEMP_UBER		"models/pickups/pickup_powerup_uber.mdl"

stock int MakeRune(RuneTypes type, float pos[3], float ang[3] = NULL_VECTOR, float vel[3] = NULL_VECTOR)
{
	int ent = CreateEntityByName("item_powerup_rune");
	TeleportEntity(ent, pos, ang, vel);
	DispatchSpawn(ent);
	SetRuneType(ent, type);
	return ent;
}

stock void SetRuneType(int rune, RuneTypes type)
{
	SetEntData(rune, FindDataMapInfo(rune, "m_iszModel") + 24, view_as< int >(type));
}

stock RuneTypes GetRuneType(int rune)
{
	return view_as< RuneTypes >(GetEntData(rune, FindDataMapInfo(rune, "m_iszModel") + 24));
}

// Runes will not die if there are no info_powerup_spawn s!!
// It's better to set this to a gargantuan amount
stock void SetRuneKillTime(int rune, float time)
{
	SetEntDataFloat(rune, FindDataMapInfo(rune, "m_iszModel") + 32, time);
}

stock float GetRuneKillTime(int rune)
{
	return GetEntDataFloat(rune, FindDataMapInfo(rune, "m_iszModel") + 32);
}

// Alternatively, you can perpetually set this to 0 and it won' blink like it's 
// gonna be deleted
stock void SetRuneBlinkCount(int rune, int count)
{
	SetEntData(rune, FindDataMapInfo(rune, "m_iszModel") + 28, count);
}

stock int GetRuneBlinkCount(int rune)
{
	return GetEntData(rune, FindDataMapInfo(rune, "m_iszModel") + 28);
}

stock RuneTypes GetCarryingRuneType(int client)
{
	static TFCond runeconds[] = {
		TFCond_RuneStrength,
		TFCond_RuneHaste,
		TFCond_RuneRegen,
		TFCond_RuneResist,
		TFCond_RuneVampire,
		TFCond_RuneWarlock,
		TFCond_RunePrecision,
		TFCond_RuneAgility,
		TFCond_PlagueRune,
		TFCond_KingRune,
		TFCond_RuneKnockout,
		TFCond_SupernovaRune
	}

	int count;
	do	
		if (TF2_IsPlayerInCondition(client, runeconds[count]))
			return view_as< RuneTypes >(count);
		while ++count < view_as< int >(Rune_LENGTH);		// This tagging makes me want to scream

	return Rune_Invalid;
}