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

#define RuneTypes eRuneTypes
#define RuneTypes_t eRuneTypes 	// Cuz

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