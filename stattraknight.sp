#include <sourcemod>
#include <clientprefs>
#include <smlib>
#include <sdktools>

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to automate StatTrak Night events",
	version = "0.9.8",
	url = "https://github.com/purplg/StatTrakNight"
};

const int T_TEAM = 2, CT_TEAM = 3;
int T_TARGET, CT_TARGET;
bool starting, stopping, running;

ArrayList optout_players;
ArrayList scoreboard_players;
ArrayList scoreboard_points;

#include "stattraknight/beacon/funcommands.sp"
#include "stattraknight/format.sp"
#include "stattraknight/game.sp"
#include "stattraknight/clients.sp"
#include "stattraknight/weapons.sp"
#include "stattraknight/points.sp"
#include "stattraknight/sounds.sp"
#include "stattraknight/events.sp"
#include "stattraknight/announcements.sp"
#include "stattraknight/scoreboard.sp"

public void OnPluginStart() {
	optout_players = CreateArray(32);
	scoreboard_players = CreateArray(32);
	scoreboard_points = CreateArray();

	Funcommands_OnPluginStart();
	Sounds_Load();
	Weapons_Load();

	RegAdminCmd("sm_st", Command_stattrak, ADMFLAG_SLAY, "sm_st <start|stop> [time]");
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_EndMatch);
	HookEvent("bot_takeover", Event_BotTakeover);
}

public Action Command_stattrak(int client, int args) {
	if (GetCmdArgs() == 0) {
		Scoreboard_Show(client); 
		return Plugin_Handled;
	} else {
		char arg[32];
		GetCmdArg(1, arg, sizeof(arg));

		// st_start
		if (StrEqual(arg, "start", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Start(client, StringToInt(arg));
			return Plugin_Handled;

		// st_stop
		} else if (StrEqual(arg, "stop", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Stop(client, StringToInt(arg));
			return Plugin_Handled;

		// st_restart
		} else if (StrEqual(arg, "restart", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Restart(StringToInt(arg));
			return Plugin_Handled;

		// st_points
		} else if (StrEqual(arg, "points", false)) {
			Print_Points(client);
			return Plugin_Handled;

		// st_optout
		} else if (StrEqual(arg, "optout", false)) {
			if (Client_IsValid(client)) {
				if (optout_players.FindValue(client) == -1) {
					optout_players.Push(client);
					// TODO Detect last player to optout and stop game
					Print_OptOut(client);
				} else {
					Print_AlreadyOptOut(client);
				}
			}
			return Plugin_Handled;

		// st_optin
		} else if (StrEqual(arg, "optin", false)) {
			if (Client_IsValid(client)) {
				int index = optout_players.FindValue(client);
				if (index > -1) {
					optout_players.Erase(index);
					Print_OptIn(client);
				} else {
					Print_AlreadyOptIn(client);
				}
			}
			return Plugin_Handled;

		// st_status
		} else if (StrEqual(arg, "status", false)) {
			if (running) {
				int index = optout_players.FindValue(client);
				if (index > -1) {
					Print_OptOut(client);
				} else {
					Print_OptIn(client);
				}
			} else {
				Print_NotRunning(client);
			}
			return Plugin_Handled;
			

		// st_debug
		} else if (StrEqual(arg, "debug", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			if (StrEqual(arg, "state", false)) {
				char buffer[256];
				Format(buffer, sizeof(buffer), "starting:%b, running:%b, stopping:%b", starting, running, stopping);
				PrintClient(client, buffer);
				Format(buffer, sizeof(buffer), "targetGroup:%s, weapon_rand:%i", weapon_targetGroup, weapon_rand);
				PrintClient(client, buffer);
			} else if (StrEqual(arg, "weapon", false)) {
				GetCmdArg(3, arg, sizeof(arg));
				if (Weapons_SelectGroup(arg)) {
					Print_WeaponGroup();
				} else {
					char buffer[256];
					Format(buffer, sizeof(buffer), "%s is not a valid weapon group", arg);
				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnMapEnd() {
	Funcommands_OnMapEnd();
	Game_FullStop();
}

public void OnMapStart() {
	Funcommands_OnMapStart();
	Game_Reset();
}
