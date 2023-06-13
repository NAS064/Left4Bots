//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4bots...\n");

if (!IncludeScript("left4lib_utils"))
	error("[L4B][ERROR] Failed to include 'left4lib_utils', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_timers"))
	error("[L4B][ERROR] Failed to include 'left4lib_timers', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_concepts"))
	error("[L4B][ERROR] Failed to include 'left4lib_concepts', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_hooks"))
	error("[L4B][ERROR] Failed to include 'left4lib_hooks', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");

IncludeScript("left4bots_requirements");

// Type of scavenge item accepted by the scavenge use target
const SCAV_TYPE_GASCAN = 1;
const SCAV_TYPE_COLA = 2;

// Log levels
const LOG_LEVEL_NONE = 0; // Log always
const LOG_LEVEL_ERROR = 1;
const LOG_LEVEL_WARN = 2;
const LOG_LEVEL_INFO = 3;
const LOG_LEVEL_DEBUG = 4;

if (!Left4Utils.FileExists("left4bots/cfg/const.nut"))
{
	local fileContents = FileToString("left4bots/cfg/const_default.nut");
	if (!fileContents)
		error("[L4B][ERROR] - Could not create the const.nut file because const_default.nut was not found !!!\n");
	else
	{
		StringToFile("left4bots/cfg/const.nut", fileContents);

		printl("[L4B][INFO] Const file was not found and has been recreated");
	}
}

//IncludeScript("../../ems/left4bots/cfg/const.nut");
local textString = FileToString("left4bots/cfg/const.nut");
if (!textString)
	error("[L4B][ERROR] const.nut file was not found !!!\n");
else
{
	local compiledscript = compilestring(textString);
	compiledscript();
}

if (!("BOT_THINK_INTERVAL" in getconsttable()))
	error("[L4B][ERROR] const.nut was not included correctly !!!\n");

//if (!("Left4Bots" in getroottable()))
//{
	::Left4Bots <-
	{
		Initialized = false
		ModeName = ""
		MapName = ""
		Difficulty = "" // easy, normal, hard, impossible
		Settings =
		{
			// [1/0] 1 = Prevents (at least will try) the infamous bug of the pipe bomb thrown right before transitioning to the next chapter that makes the bots bug out and do nothing for the entire next chapter. 0 = Disabled
			anti_pipebomb_bug = 1
			
			// Chance that the bot will chat one of the BG lines at the end of the campaign (if dead or incapped)
			bg_chance = 50
			
			// Last bot entering the saferoom will close the door after this delay (if close_saferoom_door is 1). You can increase/decrease this value for maps with CHECKPOINT nav areas not perfectly aligned to the door
			close_saferoom_delay = 0.9
			
			// [1/0] Enable/Disable closing the door right after entering the saferoom
			close_saferoom_door = 1
			
			// [1/0] 1 = Bots will automatically deploy upgrade packs when near other teammates
			deploy_upgrades = 1
			
			// [1/0] 1 = Admins can make the bots die with the "die" command at any time. 0 = Only if there are no human survivors alive
			die_humans_alive = 1
			
			// [1/0] Should the bots dodge the charger?
			dodge_charger = 1
			
			// If the bot's falling (vertical) velocity is > than this, he will be safely teleported to a random teammate. 10000 or higher to prevent the teleport
			// Can be set to the value of one of the game's cvars "fall_speed_fatal" (default val. 720), "fall_speed_safe" (560) to avoid insta-death or any damage at all respectively
			fall_velocity_warp = 10000
			
			// Name of the file containing the admins
			file_admins = "admins.txt"
			
			// Name of the file containing the BG chat lines
			file_bg = "bg.txt"
			
			// Name of the file containing the CVAR changes to apply
			file_convars = "convars.txt"
			
			// Name of the file containing the GG chat lines
			file_gg = "gg.txt"
			
			// Name of the file containing the items that the vanilla AI should not pickup
			file_itemstoavoid = "itemstoavoid.txt"
			
			// Name of the file with the vocalizer/command mapping
			file_vocalizer = "vocalizer.txt"
			
			// [1/0] 1 = The bot will be forced to heal without interrupting when healing himself (unless there are enough infected nearby). 0 = The bot can interrupt healing if not feeling safe enough (vanilla behavior)
			force_heal = 1
			
			// Chance that the bot will chat one of the GG lines at the end of the campaign (if alive)
			gg_chance = 70
			
			// [1/0] Should the L4B AI handle the extra L4D1 survivors (spawned in some maps like "The Passing" or manually by some admin addon)?
			// NOTE: This does only apply when the main team is the L4D2 one, it has no effect when the L4D1 survivors are spawned as the main team
			handle_l4d1_survivors = 1
			
			// [1/0] 1 = When your order a bot to pick up an item with the "use" command and the item is a carry item (gascan, oxygen tank, fireworks etc.), the bot will hold the item until you cancel the order (or the bot is incapped/pinned)
			hold_items = 1
			
			// Chance that the bot will throw the pipe bomb/bile jar at the horde (this check runs multiple times in a second, so this chance must be pretty low to have an actual chance of no throw)
			horde_nades_chance = 5
			
			// When scanning for an actual horde, this is the maximum altitude difference between the bot and the common infected being counted
			horde_nades_maxaltdiff = 150
			
			// When scanning for an actual horde, this is the maximum distance between the bot and the common infected being counted
			horde_nades_radius = 350
			
			// When scanning for an actual horde, this is the minimum number of common infected to count
			horde_nades_size = 10
			
			// When the survivor being ridden by a jockey gets hit by a survivor bot, the jockey gets this amount of damage
			// NOTE: Due to some limitations, the damage is always the same regardless the weapon
			jockey_redirect_damage = 40
			
			// [1/0] 0 = When the bots are holding their position (order "wait"), they automatically stop holding when a survivor gets pinned by SI / is incapacitated / dies / they are in the spitter's spit / they spot a tank or the last human survivor in the team leaves or changes team. 1 = They only stop if the last human survivor leaves or changes team
			keep_holding_position = 0
			
			// [1/0] 1 = Whenever an empty chainsaw is dropped it is immediately removed from the map
			// This is useful when you allow the bots to pickup the chainsaw ("max_chainsaws" setting), so they don't get stuck dropping and picking the empty chainsaw for ever
			kill_empty_chainsaw = 0
			
			// Chance that the bots will laugh when you laugh
			laugh_chance = 25
			
			// [1/0] 1 = Load the CVAR changes from the file_convars file. 0 = Don't (useful if you are going to use another CVAR based AI improvement addon like Improved Bots, Competitive-Bots etc.)
			load_convars = 1
			
			// Minimum log level for the addon's log lines into the console
			// 0 = No log
			// 1 = Only [ERROR] messages are logged
			// 2 = [ERROR] and [WARNING]
			// 3 = [ERROR], [WARNING] and [INFO]
			// 4 = [ERROR], [WARNING], [INFO] and [DEBUG]
			loglevel = 3
			
			// Max chainsaws in the team
			max_chainsaws = 0
			
			// [1/0] Should the bots give their medkits to admins?
			medkits_bots_give = 1

			// [1/0] Can the human survivors give their pills/adrenaline to other survivors (and swap with bots)?
			meds_give = 1
			
			// When the bot tries to heal with health >= this (usually they do it in the start saferoom) the addon will interrupt it, unless there is no human in the team
			// or there are enough spare medkits around for the bot and the teammates who also need it
			min_start_health = 50
			
			// [1/0] Should the bots give their throwables to human players?
			nades_bots_give = 1
			
			// [1/0] Can the human survivors give their molotovs/pipe bombs/bile jars to other survivors (and swap with bots)?
			nades_give = 1 // TODO: Move back to L4F?
			
			// [1/0] 1 = Disable the bots scavenge for the current map
			no_scavenge = 0
			
			// [1/0] Should the bot do the pickup animation when picking items (also forces them to go closer to the items before picking them up)?
			pickup_animation = 1
			
			// If the distance between the bot and the nearest human is greater than this, the bot will not move to go pickup throwable items (so they don't waste time when you are rushing)
			pickup_max_separation = 450
			
			// [1/0] Should the bots immediately pick up medkits? 0 = vanilla behavior
			pickup_medkit = 1
			
			// [1/0] Should the bots pick up molotovs?
			pickup_molotov = 1
			
			// [1/0] Should the bots immediately pick up pills/adrenaline? 0 = vanilla behavior
			pickup_pills_adrenaline = 1
			
			// [1/0] Should the bots pick up pipe bombs?
			pickup_pipe_bomb = 1
			
			// [1/0] Should the bots pick up vomit jars?
			pickup_vomitjar = 1
			
			// [1/0] Should the bots give their pills/adrenaline to human players?
			pills_bots_give = 1
			
			// [1/0] Enable/Disable the UI sounds when giving a throwable item to another survivor
			play_sounds = 1
			
			// When the tank's rock comes this close, the bots will try to shoot it (they aren't 100% accurate tho). 0 = feature disabled
			rock_shoot_range = 700
			
			// [1/0] 1 = The bots will start scavenging gascans automatically (without the need to use the "bots lead" command) in campaign and versus game modes, even if there are humans in the team
			// NOTE: In scavenge mode they always start automatically
			scavenge_campaign_autostart = 1
			
			// Max number of bots that will be scavenging gascans/cola bottles
			scavenge_max_bots = 2
			
			// [1/0] 1 = Scavenge bots will automatically pour the gascans/cola. 0 = they will just drop them near the pour target and a human will need to complete the pouring
			scavenge_pour = 1
			
			// [1/0] Enable/Disable bots trying to shoot (the bot will crouch and shoot) the smoker's tongue when a survivor is being strangled and the smoker isn't visible
			// NOTE: This isn't perfect and may slow down the rescue even more, depending on the situation
			shoot_smokers_tongue = 1
			
			// Value for the cm_ShouldHurry director option (not sure what it does exactly)
			should_hurry = 1
			
			// Bots will shove special infected (excluding boomers) within this radius (set 0 to disable)
			shove_si_within = 70
			
			// [1/0] 0 = valid chat commands given to the bot will be hidden to the other players
			show_commands = 1
			
			// [1/0] 1 = The bots will also signal the presence of available items to pick up via chat (if signal_max_distance is non 0). 0 No signal via chat but they will still do it via vocalizer
			signal_chat = 1
			
			// Maximum distance from the human teammate (who might need that item) in order to signal the item. 0 = Entire signal feature will be disabled
			signal_max_distance = 2500
			
			// Minimum distance from the human teammate (who might need that item) in order to signal the item
			signal_min_distance = 150
			
			// Minimum wait time (in seconds) for repeating signals (2 or more signals for the same item type, regardless the source bot)
			signal_min_interval = 5.0
			
			// [1/0] If 1 (and the "Left 4 Fun" addon is installed and enabled) they will also mimic the L4F's "scripted_user_func ping" command on that item
			signal_ping = 0
			
			// Chance that the bot will vocalize "Sorry" after doing friendly fire
			sorry_chance = 80
			
			// Chance that the bots will try to deadstop a hunter/jockey attack when the attack is directed at them
			special_shove_chance = 95
			
			// [1/0] 1 = The bot's navigation is automatically blocked in the spitted acid area while the acid is active. This helps avoid the bots stepping into the acid after they dodge it
			// NOTE: This is not 100% effective, can make the bots lag behind more and may increase the chance of getting the bots stuck into the acid
			spit_block_nav = 1
			
			// The damage taken from the spitter's acid is multiplied by this factor (bots only)
			// The game reduces this damage for the bots by default. If you want them to take the same amount of damage of the humans you can set this to 2
			spit_damage_multiplier = 1
			
			// [1/0] Enable/Disable replenish ammo for T3 weapon by bots
			t3_ammo_bots = 1
			
			// [1/0] Enable/Disable replenish ammo for T3 weapon by humans
			t3_ammo_human = 0
			
			// Chance that the bot will throw the molotov at the tank (this check runs multiple times in a second while the tank is in range, so this chance must be pretty low to have an actual chance of no throw)
			tank_molotov_chance = 30
			
			// Chance that the bot will throw the bile jar at the tank (this check runs multiple times in a second while the tank is in range, so this chance must be pretty low to have an actual chance of no throw)
			tank_vomitjar_chance = 3
			
			// Minimum number of defibs (in the entire team) the bots will look for when choosing what to pick up. The bots will first try to have the minimum number of medkits and then look for the required defibs
			// For example: if you set team_min_medkits = 3 and team_min_defibs = 1, the bots will look for at least 3 medkits first, then 1 of them will replace his medkit with a defib once he finds it
			// If their inventory slot is empty they will always pick up anything
			// NOTE: Unfortunately the base AI will still give priority to the medkit, so it will try to pick the medkit and then the defib over and over again. Just carry them far away to make them stop
			team_min_defibs = 0
			
			// Minimum number of medkits (in the entire team) the bots will look for when choosing what to pick up. The bots will first try to have the minimum number of medkits and then look for the required defibs
			// For example: if you set team_min_medkits = 3 and team_min_defibs = 1, the bots will look for at least 3 medkits first, then 1 of them will replace his medkit with a defib once he finds it
			// If their inventory slot is empty they will always pick up anything
			// NOTE: Unfortunately the base AI will still give priority to the medkit, so it will try to pick the medkit and then the defib over and over again. Just carry them far away to make them stop
			team_min_medkits = 4
			
			// Chance that the bot you are looking at (or the last bot who killed a special infected) will vocalize "Thanks" after your "Nice shoot"
			thanks_chance = 90
			
			// [1/0] Are the bots allowed to throw molotovs?
			throw_molotov = 1
			
			// [1/0] Are the bots allowed to throw pipe bombs?
			throw_pipe_bomb = 1
			
			// [1/0] Are the bots allowed to throw vomit jars?
			throw_vomitjar = 1
			
			// [1/0] 1 = Survivor bots will set off car alarms just like the humans
			trigger_caralarm = 0
			
			// [1/0] 1 = Survivor bots will startle the witch when they accidentally shoot her (just like the humans)
			trigger_witch = 0
			
			// [1/0] Should the bots give their upgrade packs to human players?
			upgrades_bots_give = 1
			
			// [1/0] 1 = Non admin players can give orders to the bots (if vocalizer_commands is 1). 0 = Only the admins can
			user_can_command_bots = 0
			
			// [1/0] Enable/Disable the vocalizer orders to the bots (orders via chat are always possible)
			vocalizer_commands = 1
			
			// [1/0] While executing the 'wait' order the bot will wait crouch (1) or standing (0)
			wait_crouch = 0
			
			// Chance that the bot you are looking at will vocalize "You welcome" after your "Thanks"
			youwelcome_chance = 90
		}
		Admins = {}
		OnlineAdmins = []
		Events = {}
		Survivors = {} // Used for performance reasons, instead of doing an Entities search every time
		Bots = {}      // Same as above ^
		Tanks = {}     // Idem ^
		Deads = {}     // ^
		BtnListener = null
		BtnStatus_Shove = {}
		VocalizerOrders = {}
		RoundStarted = false
		ModeStarted = false
		DefibbingUserId = -1
		DefibbingSince = 0
		GiveItemIndex1 = 0
		GiveItemIndex2 = 0
		LastGiveItemTime = 0
		LastNadeTime = 0
		LastMolotovTime = 0
		ScavengeEnabled = false
		ScavengeUseTarget = null
		ScavengeUseTargetPos = null
		ScavengeUseType = 0
		ScavengeOrders = {}
		ItemsToAvoid = []
		CanPickupItem = { kit = true, def = true, exp = true, inc = true, pil = true, adr = true }
		ManualOrders = {}
		FinalVehicleArrived = false
		StartGenerators = false
		SurvivorsEnteredCheckpoint = 0
		C1M2CanOpenStoreDoors = false
		C5M2EntireTeamInside = false
		C7M1CanOpenTrainDoors = false
		C9M2CanActivateGenerator = false
		C12M2CanOpenEmergencyDoor = false
		C13M1CanOpenBunkerDoor = false
		Old_sb_enforce_proximity_range = 0
		Old_sb_unstick = 0
		NiceShootSurv = null
		NiceShootTime = 0
		OnTankSettings = {}
		OnTankSettingsBak = {}
		OnTankCvars = {}
		OnTankCvarsBak = {}
		HoldItems = { weapon_gascan = 0, weapon_gnome = 0, weapon_cola_bottles = 0, weapon_propanetank = 0, weapon_oxygentank = 0, weapon_fireworkcrate = 0 }
		Team_Medkits = 0
		Team_Defibs = 0
		L4F = false
		LastSignalType = ""
		LastSignalTime = 0
	}

	::Left4Bots.Log <- function (level, text)
	{
		if (level > Left4Bots.Settings.loglevel)
			return;
		
		if (level == LOG_LEVEL_DEBUG)
			printl("[L4B][DEBUG] " + text);
		else if (level == LOG_LEVEL_INFO)
			printl("[L4B][INFO] " + text);
		else if (level == LOG_LEVEL_WARN)
			error("[L4B][WARNING] " + text + "\n");
		else if (level == LOG_LEVEL_ERROR)
			error("[L4B][ERROR] " + text + "\n");
		else
			error("[L4B][" + level + "] " + text + "\n");
	}

	::Left4Bots.LoadVocalizerOrdersFromFile <- function (fileName)
	{
		local ret = {};
		
		local mappings = Left4Utils.FileToStringList(fileName);
		if (!mappings)
			return ret;

		foreach (mapping in mappings)
		{
			//Left4Bots.Log(LOG_LEVEL_DEBUG, mapping);
			mapping = Left4Utils.StringReplace(mapping, "\\t", "");
			mapping = Left4Utils.StripComments(mapping);
			if (mapping && mapping != "")
			{
				mapping = strip(mapping);
				//Left4Bots.Log(LOG_LEVEL_DEBUG, mapping);
			
				if (mapping && mapping != "")
				{
					local idx = mapping.find("=");
					if (idx != null)
					{
						local command = mapping.slice(0, idx);
						command = Left4Utils.StringReplace(command, "\"", "");
						command = strip(command);
						//Left4Bots.Log(LOG_LEVEL_DEBUG, command);
						
						local value = mapping.slice(idx + 1);
						value = Left4Utils.StringReplace(value, "\"", "");
						value = strip(value);
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "MAPPING: " + command + " = " + value);
						
						//ret[command] <- value;
						
						if (!(command in ret))
							ret[command] <- [];
						ret[command].append(value); // Allowing multiple commands for each vocalizer line
					}
				}
			}
		}
		
		return ret;
	}

	::Left4Bots.LoadItemsToAvoidFromFile <- function (fileName)
	{
		local ret = [];
		
		local items = Left4Utils.FileToStringList(fileName);
		if (!items)
			return ret;

		foreach (item in items)
		{
			item = Left4Utils.StripComments(item);
			if (item != "")
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Item to avoid: " + item);
				
				if (item == "weapon_first_aid_kit")
					Left4Bots.CanPickupItem["kit"] = false;
				else if (item == "weapon_defibrillator")
					Left4Bots.CanPickupItem["def"] = false;
				else if (item == "weapon_upgradepack_explosive")
					Left4Bots.CanPickupItem["exp"] = false;
				else if (item == "weapon_upgradepack_incendiary")
					Left4Bots.CanPickupItem["inc"] = false;
				else if (item == "weapon_pain_pills")
					Left4Bots.CanPickupItem["pil"] = false;
				else if (item == "weapon_adrenaline")
					Left4Bots.CanPickupItem["adr"] = false;
					
				ret.push(item);
			}
		}
		return ret;
	}

	// Left4Bots main initialization function
	::Left4Bots.Initialize <- function (modename, mapname)
	{
		if (Left4Bots.Initialized)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Already initialized");
			return;
		}
		
		Left4Bots.ModeName = modename;
		Left4Bots.MapName = mapname;
		Left4Bots.Difficulty = Convars.GetStr("z_difficulty").tolower();
		
		Left4Bots.Log(LOG_LEVEL_INFO, "Initializing for game mode: " + modename + " - map name: " + mapname + " - difficulty: " + Left4Bots.Difficulty);
		
		if (Left4Utils.FileExists("left4bots/cfg/noscavenge.txt"))
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "noscavenge.txt exists");
			
			local lines = Left4Utils.FileToStringList("left4bots/cfg/noscavenge.txt");
			if (lines)
			{
				foreach (line in lines)
				{
					if (line != "")
					{
						StringToFile("left4bots/cfg/settings_" + line + ".txt", "no_scavenge = 1");
						
						Left4Bots.Log(LOG_LEVEL_INFO, "Created 'settings_" + line + ".txt' file with 'no_scavenge = 1' setting");
					}
				}
			}
			
			StringToFile("left4bots/cfg/noscavenge.txt", "");
			Left4Bots.Log(LOG_LEVEL_DEBUG, "noscavenge.txt truncated");
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "noscavenge.txt does not exist");
		
		if (!Left4Utils.FileExists("left4bots/cfg/settings_c6m1_riverbank.txt"))
		{
			StringToFile("left4bots/cfg/settings_c6m1_riverbank.txt", "handle_l4d1_survivors = 0");
						
			Left4Bots.Log(LOG_LEVEL_INFO, "Default 'settings_c6m1_riverbank.txt' file with 'handle_l4d1_survivors = 0' has been created");
		}
		
		if (!Left4Utils.FileExists("left4bots/cfg/settings_c6m3_port.txt"))
		{
			StringToFile("left4bots/cfg/settings_c6m3_port.txt", "handle_l4d1_survivors = 0");
						
			Left4Bots.Log(LOG_LEVEL_INFO, "Default 'settings_c6m3_port.txt' file with 'handle_l4d1_survivors = 0' has been created");
		}
		
		if (!Left4Utils.FileExists("left4bots/cfg/settings_c1m4_atrium.txt"))
		{
			StringToFile("left4bots/cfg/settings_c1m4_atrium.txt", "throw_molotov = 0");
						
			Left4Bots.Log(LOG_LEVEL_INFO, "Default 'settings_c1m4_atrium.txt' file with 'throw_molotov = 0' has been created");
		}
		
		Left4Bots.Log(LOG_LEVEL_INFO, "Loading settings...");
		Left4Utils.LoadSettingsFromFile("left4bots/cfg/settings.txt", "Left4Bots.Settings.", Left4Bots.Log);
		
		if (Left4Bots.Settings.keep_holdind_position >= 0)
			Left4Bots.Settings.keep_holding_position = Left4Bots.Settings.keep_holdind_position;
		delete ::Left4Bots.Settings.keep_holdind_position;
		
		Left4Utils.SaveSettingsToFile("left4bots/cfg/settings.txt", ::Left4Bots.Settings, Left4Bots.Log);
		
		if (Left4Utils.FileExists("left4bots/cfg/settings_" + Left4Bots.MapName + "_" + Left4Bots.Difficulty + ".txt"))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading settings map-difficulty override...");
			Left4Utils.LoadSettingsFromFile("left4bots/cfg/settings_" + Left4Bots.MapName + "_" + Left4Bots.Difficulty + ".txt", "Left4Bots.Settings.", Left4Bots.Log);
		}
		else if (Left4Utils.FileExists("left4bots/cfg/settings_" + Left4Bots.Difficulty + ".txt"))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading settings difficulty override...");
			Left4Utils.LoadSettingsFromFile("left4bots/cfg/settings_" + Left4Bots.Difficulty + ".txt", "Left4Bots.Settings.", Left4Bots.Log);
		}
		else if (Left4Utils.FileExists("left4bots/cfg/settings_" + Left4Bots.MapName + ".txt"))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading settings map override...");
			Left4Utils.LoadSettingsFromFile("left4bots/cfg/settings_" + Left4Bots.MapName + ".txt", "Left4Bots.Settings.", Left4Bots.Log);
		}
		
		Left4Utils.PrintSettings(::Left4Bots.Settings, Left4Bots.Log, "[Settings] ");
		
		if (Left4Bots.Settings.no_scavenge)
			Left4Bots.Log(LOG_LEVEL_INFO, "Scavenge is disabled!");
		else
			Left4Bots.Log(LOG_LEVEL_INFO, "Scavenge is enabled.");
		
		Left4Bots.Log(LOG_LEVEL_INFO, "Loading admins from file: " + Left4Bots.Settings.file_admins);
		::Left4Bots.Admins = Left4Utils.LoadAdminsFromFile("left4bots/cfg/" + Left4Bots.Settings.file_admins, Left4Bots.Log);
		Left4Bots.Log(LOG_LEVEL_INFO, "Loaded " + Left4Bots.Admins.len() + " admins");
		
		if (!Left4Utils.FileExists("left4bots/cfg/vocalizer.txt"))
		{
			// using array instead of table to maintain the order
			local defaultMappingValues =
			[
				"PlayerLeadOn = lead",
				"PlayerWaitHere = wait",
				"PlayerEmphaticGo = go",
				"PlayerWarnWitch = witch",
				"PlayerHelp = move",
				"PlayerHurryUp = move",
				"PlayerMoveOn = move",
				"PlayerStayTogether = move",
				"PlayerFollowMe = move",
				"iMT_PlayerSuggestHealth = heal",
				"PlayerEmphaticGo = use",
				"PlayerHurryUp = canceldefib",
				"AskForHealth2 = healme",
				"PlayerAnswerLostCall = give",
				"PlayerYellRun = goto"
			];

			Left4Utils.StringListToFile("left4bots/cfg/vocalizer.txt", defaultMappingValues, false);
				
			Left4Bots.Log(LOG_LEVEL_INFO, "Vocalizer orders mapping file was not found and has been recreated");
		}
		
		Left4Bots.Log(LOG_LEVEL_INFO, "Loading vocalizer orders mapping from file: " + Left4Bots.Settings.file_vocalizer);
		::Left4Bots.VocalizerOrders = Left4Bots.LoadVocalizerOrdersFromFile("left4bots/cfg/" + Left4Bots.Settings.file_vocalizer);
		Left4Bots.Log(LOG_LEVEL_INFO, "Loaded " + Left4Bots.VocalizerOrders.len() + " orders");
		
		if (!Left4Utils.FileExists("left4bots/cfg/convars.txt"))
		{
			// using array instead of table to maintain the order
			local defaultConvarValues =
			[
				"allow_all_bot_survivor_team 1",
				"sb_all_bot_game 1",
				"sb_allow_shoot_through_survivors 0",
				"sb_battlestation_give_up_range_from_human 100",
				"sb_battlestation_human_hold_time 0.25",
				"sb_close_checkpoint_door_interval 0.5",
				"//sb_close_threat_range 4000",
				"sb_close_threat_range 0",
				"sb_combat_saccade_speed 2250",
				"sb_enforce_proximity_range 2000",
				"sb_far_hearing_range 500000000",
				"sb_follow_stress_factor 0",
				"sb_friend_immobilized_reaction_time_expert 0",
				"sb_friend_immobilized_reaction_time_hard 0",
				"sb_friend_immobilized_reaction_time_normal 0",
				"sb_friend_immobilized_reaction_time_vs 0",
				"sb_locomotion_wait_threshold 0.1",
				"sb_max_battlestation_range_from_human 150",
				"sb_max_scavenge_separation 700",
				"sb_max_team_melee_weapons 0",
				"sb_melee_approach_victim 0",
				"sb_min_attention_notice_time 1",
				"sb_min_orphan_time_to_cover 0",
				"sb_near_hearing_range 10000",
				"sb_neighbor_range 200",
				"sb_normal_saccade_speed 1500",
				"sb_path_lookahead_range 550",
				"sb_pushscale 2",
				"sb_reachability_cache_lifetime 0",
				"sb_rescue_vehicle_loading_range 200",
				"sb_separation_danger_max_range 300",
				"sb_separation_danger_min_range 150",
				"sb_separation_range 150",
				"sb_sidestep_for_horde 1",
				"sb_temp_health_consider_factor 0.8",
				"sb_threat_close_range 5000",
				"sb_threat_exposure_stop 500000000",
				"sb_threat_exposure_walk 400000000",
				"sb_threat_far_range 400000000",
				"sb_threat_medium_range 6000",
				"sb_threat_very_close_range 2000",
				"sb_threat_very_far_range 500000000",
				"sb_toughness_buffer 20",
				"sb_vomit_blind_time 0",
				"survivor_ff_avoidance 1"
			];

/* TODO: Maybe it is possible to use these to make the bots stop wasting their ammo on a dying tank?
z_tank_incapacitated_decay_rate          : 1        : , "sv", "cheat"  : How much health a dying Tank loses each update.
z_tank_incapacitated_health              : 5000     : , "sv", "cheat"  : Health Tank starts with in death throes.
*/

			Left4Utils.StringListToFile("left4bots/cfg/convars.txt", defaultConvarValues, false);
				
			Left4Bots.Log(LOG_LEVEL_INFO, "Convars file was not found and has been recreated");
		}
		
		if (Left4Bots.Settings.load_convars)
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading convars from file: " + Left4Bots.Settings.file_convars);
			local c = Left4Utils.LoadCvarsFromFile("left4bots/cfg/" + Left4Bots.Settings.file_convars, Left4Bots.Log);
			Left4Bots.Log(LOG_LEVEL_INFO, "Loaded " + c + " convars");
		}
		else
			Left4Bots.Log(LOG_LEVEL_INFO, "Convars file was not loaded (settings.load_convars is 0)");

		Left4Bots.Log(LOG_LEVEL_INFO, "Loading items to avoid from file: " + Left4Bots.Settings.file_itemstoavoid);
		Left4Bots.ItemsToAvoid = Left4Bots.LoadItemsToAvoidFromFile("left4bots/cfg/" + Left4Bots.Settings.file_itemstoavoid);
		Left4Bots.Log(LOG_LEVEL_INFO, "Loaded " + Left4Bots.ItemsToAvoid.len() + " items");
		
		if (Left4Utils.FileExists("left4bots/cfg/ontank_settings.txt"))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading OnTank settings...");
			Left4Bots.LoadOnTankSettingsFromFile("left4bots/cfg/ontank_settings.txt");
		}
		Left4Utils.PrintSettings(::Left4Bots.OnTankSettings, Left4Bots.Log, "[OnTank Settings] ");
		
		if (Left4Utils.FileExists("left4bots/cfg/ontank_convars.txt"))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Loading OnTank convars...");
			local c = Left4Bots.LoadOnTankCvarsFromFile("left4bots/cfg/ontank_convars.txt");
			Left4Bots.Log(LOG_LEVEL_INFO, "Loaded " + c + " OnTank convars");
		}
		
		if (!Left4Utils.FileExists("left4bots/cfg/gg.txt"))
		{
			local defaultGGLines =
			[
				"gg",
				"GG",
				"gg"
			];

			Left4Utils.StringListToFile("left4bots/cfg/gg.txt", defaultGGLines, false);
				
			Left4Bots.Log(LOG_LEVEL_INFO, "GG lines file was not found and has been recreated");
		}
		
		if (!Left4Utils.FileExists("left4bots/cfg/bg.txt"))
		{
			local defaultBGLines =
			[
				"bg",
				":(",
				":'(",
			];

			Left4Utils.StringListToFile("left4bots/cfg/bg.txt", defaultBGLines, false);
				
			Left4Bots.Log(LOG_LEVEL_INFO, "BG lines file was not found and has been recreated");
		}
		
		Left4Bots.Initialized = true;
	}

	::Left4Bots.IsAdmin <- function (player)
	{
		if (!player)
			return false;

		local steamid = player.GetNetworkIDString();
		if (!steamid || steamid == "BOT")
			return false;

		if (steamid in ::Left4Bots.Admins)
			return true;
		
		if (GetListenServerHost() == player || Director.IsSinglePlayerGame())
		{
			::Left4Bots.Admins[steamid] <- player.GetPlayerName();
			
			Left4Utils.SaveAdminsToFile("left4bots/cfg/admins.txt", ::Left4Bots.Admins);

			return true;
		}
		return false;
	}

	::Left4Bots.IsOnlineAdmin <- function (player)
	{
		if (!player)
			return false;
		
		if (Left4Bots.OnlineAdmins.find(player.GetPlayerUserId()) != null)
			return true;
		else
			return false;
	}

	::Left4Bots.PlayerIn <- function (player)
	{
		local userid = player.GetPlayerUserId().tointeger();
		
		if (Left4Bots.OnlineAdmins.find(userid) == null && Left4Bots.IsAdmin(player))
		{
			Left4Bots.Log(LOG_LEVEL_INFO, "Adding admin with userid: " + userid);
		
			Left4Bots.OnlineAdmins.push(userid);
			Left4Bots.OnlineAdmins.sort();
		}
	}

	::Left4Bots.PlayerOut <- function (userid, player)
	{
		//local userid = player.GetPlayerUserId().tointeger();
		
		local idx = Left4Bots.OnlineAdmins.find(userid);
		if (idx != null)
		{
			Left4Bots.OnlineAdmins.remove(idx);
			Left4Bots.Log(LOG_LEVEL_INFO, "OnlineAdmin removed with idx: " + idx);
		}
	}

	::Left4Bots.IsHandledSurvivor <- function (survivor)
	{
		if (!survivor || !survivor.IsValid() || !("GetPlayerUserId" in survivor))
			return false;
		
		return (survivor.GetPlayerUserId() in Left4Bots.Survivors);
	}

	::Left4Bots.LoadOnTankSettingsFromFile <- function (fileName)
	{
		Left4Bots.OnTankSettings.clear();
		
		local settings = Left4Utils.FileToStringList(fileName);
		if (!settings)
			return false;
		
		foreach (setting in settings)
		{
			setting = Left4Utils.StripComments(setting);
			setting = Left4Utils.StringReplace(setting, "=", "<-");
			if (setting != "")
			{
				try
				{
					local compiledscript = compilestring("Left4Bots.OnTankSettings." + setting);
					compiledscript();
				}
				catch(exception)
				{
					Left4Bots.Log(LOG_LEVEL_ERROR, exception);
				}
			}
		}
		Left4Bots.Log(LOG_LEVEL_INFO, "OnTank Settings loaded");
		
		return true;
	}

	::Left4Bots.LoadOnTankCvarsFromFile <- function (fileName)
	{
		Left4Bots.OnTankCvars.clear();
		
		local count = 0;
		
		local cvars = Left4Utils.FileToStringList(fileName);
		if (!cvars)
			return count;
		
		foreach (cvar in cvars)
		{
			cvar = Left4Utils.StringReplace(cvar, "\\t", "");
			cvar = Left4Utils.StripComments(cvar);
			if (cvar && cvar != "")
			{
				cvar = strip(cvar);
				if (cvar && cvar != "")
				{
					local idx = cvar.find(" ");
					if (idx != null)
					{
						local command = cvar.slice(0, idx);
						command = Left4Utils.StringReplace(command, "\"", "");
						command = strip(command);
						
						local value = cvar.slice(idx + 1);
						value = Left4Utils.StringReplace(value, "\"", "");
						value = strip(value);
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "CVAR: " + command + " " + value);
						
						Left4Bots.OnTankCvars[command] <- value;
						
						count++;
					}
				}
			}
		}
		
		return count;
	}

	::Left4Bots.OnTankActive <- function ()
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnTankActive");

		// Settings
		foreach (key, val in ::Left4Bots.OnTankSettings)
		{
			Left4Bots.OnTankSettingsBak[key] <- Left4Bots.Settings[key];
			Left4Bots.Settings[key] <- val;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Changing setting " + key + " to " + val);
		}
		
		// Convars
		foreach (key, val in ::Left4Bots.OnTankCvars)
		{
			Left4Bots.OnTankCvarsBak[key] <- Convars.GetStr(key);
			Convars.SetValue(key, val);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Changing convar " + key + " to " + val);
		}
	}
	
	::Left4Bots.OnTankGone <- function ()
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnTankGone");
		
		// Settings
		foreach (key, val in ::Left4Bots.OnTankSettingsBak)
		{
			Left4Bots.Settings[key] <- val;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Changing setting " + key + " back to " + val);
		}
		Left4Bots.OnTankSettingsBak.clear();
		
		// Convars
		foreach (key, val in ::Left4Bots.OnTankCvarsBak)
		{
			Convars.SetValue(key, val);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Changing convar " + key + " back to " + val);
		}
		Left4Bots.OnTankCvarsBak.clear();
	}

	::Left4Bots.FindBestUseTargetPos <- function (useTarget, orig = null, angl = null, fwdFailsafe = true, debugShow = false, debugShowTime = 15)
	{
		local ret = null;
		if (!useTarget || !useTarget.IsValid())
			return ret;
		
		if (!orig)
			orig = useTarget.GetCenter();
		if (!angl)
			angl = useTarget.GetAngles();
		angl = QAngle(0, angl.Yaw(), 0);
		local grounds = [];
		
		grounds.append(Left4Utils.FindGround(orig, angl, 315, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 0, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 45, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 90, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 135, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 180, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 225, debugShow, debugShowTime));
		grounds.append(Left4Utils.FindGround(orig, angl, 270, debugShow, debugShowTime));
		grounds.append(grounds[0]);
		grounds.append(grounds[1]);
		
		for (local i = 1; i < grounds.len() - 1; i++)
		{
			if (grounds[i - 1] != null && grounds[i] != null && grounds[i + 1] != null)
			{
				ret = grounds[i];
				break;
			}
		}
		
		if (ret == null)
		{
			for (local i = 1; i < grounds.len() - 1; i++)
			{
				if (grounds[i] != null)
				{
					ret = grounds[i];
					break;
				}
			}
		}
		
		if (ret == null && fwdFailsafe)
			ret = Left4Utils.FindGroundFrom(orig + (angl.Forward() * 45), FINDGROUND_MAXHEIGHT, FINDGROUND_MINFRACTION).pos;
		
		if (ret != null && debugShow)
			DebugDrawLine_vCol(orig, ret, Vector(0, 0, 255), true, debugShowTime);
		
		return ret;
	}

	::Left4Bots.SetScavengeUseTarget <- function ()
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.SetScavengeUseTarget");
		
		if (Left4Bots.ScavengeUseTarget != null && Left4Bots.ScavengeUseTarget.IsValid())
			return true;
		
		if (Left4Bots.ScavengeUseTarget != null)
		{
			Left4Bots.ScavengeUseTarget = null;
			Left4Bots.ScavengeUseTargetPos = null;
			Left4Bots.ScavengeUseType = 0;
			Left4Bots.ScavengeOrders = {};
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Scavenge use target has been removed");
		}
		
		Left4Bots.ScavengeUseTarget = Entities.FindByClassname(null, "point_prop_use_target");
		if (!Left4Bots.ScavengeUseTarget)
			return false;
		
		Left4Bots.ScavengeUseType = NetProps.GetPropInt(Left4Bots.ScavengeUseTarget, "m_spawnflags");
		
		if (Left4Bots.ScavengeUseType == SCAV_TYPE_GASCAN)
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Scavenge use target found (type: Gascan)");
		else if (Left4Bots.ScavengeUseType == SCAV_TYPE_COLA)
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Scavenge use target found (type: Cola)");
		else
		{
			Left4Bots.Log(LOG_LEVEL_WARN, "Unsupported scavenge use target type: " + Left4Bots.ScavengeUseType + ", switching to type: Gascan");
			
			Left4Bots.ScavengeUseType = SCAV_TYPE_GASCAN;
		}
		
		Left4Bots.ScavengeUseTargetPos = Left4Bots.FindBestUseTargetPos(Left4Bots.ScavengeUseTarget, null, null, true, Left4Bots.Settings.loglevel >= LOG_LEVEL_DEBUG);

		return true;
	}

	::Left4Bots.OnRoundStart <- function (params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnRoundStart - MapName: " + Left4Bots.MapName + " - MapNumber: " + Director.GetMapNumber());

		Left4Bots.RoundStarted = true;

		// Apparently, when scriptedmode is enabled and this director option isn't set, there is a big stutter (for the host)
		// when a witch is chasing a survivor and that survivor enters the saferoom. Simply having a value for this key, removes the stutter
		if (!("AllowWitchesInCheckpoints" in DirectorScript.GetDirectorOptions()))
			DirectorScript.GetDirectorOptions().AllowWitchesInCheckpoints <- false;

		if ("Left4Fun" in getroottable() && "PingEnt" in ::Left4Fun)
		{
			Left4Bots.L4F = true;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "L4F = true");
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "L4F = false");

		Left4Bots.Old_sb_enforce_proximity_range = Convars.GetFloat("sb_enforce_proximity_range");
		Left4Bots.Old_sb_unstick = Convars.GetFloat("sb_unstick");

		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnRoundStart - Old_sb_enforce_proximity_range: " + Left4Bots.Old_sb_enforce_proximity_range + " - Old_sb_unstick: " + Left4Bots.Old_sb_unstick);

		::ConceptsHub.SetHandler("Left4Bots", Left4Bots.OnConcept);
		
		foreach (player in ::Left4Utils.GetHumanPlayers())
			Left4Bots.PlayerIn(player);

		Left4Timers.AddTimer("Cleaner", 1, Left4Bots.Cleaner, {}, true);
		Left4Timers.AddTimer("ChainsawManager", 0.85, Left4Bots.ChainsawManager, {}, true);
		Left4Timers.AddTimer("ScavengeManager", SCAVENGE_MANAGER_INTERVAL, Left4Bots.ScavengeManager, {}, true);
		
		Left4Bots.BtnListener = SpawnEntityFromTable("info_target", { targetname = "l4bntlistener" });
		if (!Left4Bots.BtnListener)
			Left4Bots.Log(LOG_LEVEL_ERROR, "Left4Bots.OnRoundStart failed to spawn l4bntlistener entity");
		else
		{
			Left4Bots.BtnListener.ValidateScriptScope();
			local scope = Left4Bots.BtnListener.GetScriptScope();
			scope["BtnListenerThinkFunc"] <- Left4Bots.BtnListenerThinkFunc;
			AddThinkToEnt(Left4Bots.BtnListener, "BtnListenerThinkFunc");
		}
		
		// Old method
		local tbl = { classname = "env_sprite", model = "effects/strider_bulge_dudv_dx60.vmt" };
		PrecacheEntityFromTable(tbl);
	}

	::Left4Bots.OnModeStart <- function ()
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnModeStart");
		
		if (Left4Bots.MapName == "c7m3_port")
		{
			local bridge_checker = Entities.FindByName(null, "bridge_checker");
			if (bridge_checker)
			{
				DoEntFire("!self", "Kill", "", 0, null, bridge_checker);
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Killed bridge_checker");
			}
			else
				Left4Bots.Log(LOG_LEVEL_WARN, "bridge_checker was not found in c7m3_port map!");
			
			local generator_start_model = Entities.FindByName(null, "generator_start_model");
			if (generator_start_model)
			{
				DoEntFire("!self", "SacrificeEscapeSucceeded", "", 0, null, generator_start_model);
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Triggered generator_start_model's SacrificeEscapeSucceeded");
			}
			else
				Left4Bots.Log(LOG_LEVEL_WARN, "generator_start_model was not found in c7m3_port map!");
		}
		else if (Left4Bots.MapName == "c5m2_park")
		{
			local finale_decon_trigger = Entities.FindByName(null, "finale_decon_trigger");
			if (finale_decon_trigger)
			{
				finale_decon_trigger.ValidateScriptScope();
				local scope = finale_decon_trigger.GetScriptScope();
				
				scope["C5M2Door1_OnEntireTeamStartTouch"] <- Left4Bots.C5M2Door1_OnEntireTeamStartTouch;
				scope["C5M2Door1_OnEntireTeamEndTouch"] <- Left4Bots.C5M2Door1_OnEntireTeamEndTouch;
				
				finale_decon_trigger.ConnectOutput("OnEntireTeamStartTouch", "C5M2Door1_OnEntireTeamStartTouch");
				finale_decon_trigger.ConnectOutput("OnEntireTeamEndTouch", "C5M2Door1_OnEntireTeamEndTouch");
			}
			else
				Left4Bots.Log(LOG_LEVEL_ERROR, "finale_decon_trigger was not found in c5m2_park map!");
			
			local finale_cleanse_entrance_door = Entities.FindByName(null, "finale_cleanse_entrance_door");
			if (finale_cleanse_entrance_door)
			{
				finale_cleanse_entrance_door.ValidateScriptScope();
				local scope = finale_cleanse_entrance_door.GetScriptScope();
				
				scope["C5M2Door2_OnFullyClosed"] <- Left4Bots.C5M2Door2_OnFullyClosed;
				scope["C5M2Door2_OnClose"] <- Left4Bots.C5M2Door2_OnClose;
				scope["C5M2Door2_OnOpen"] <- Left4Bots.C5M2Door2_OnOpen;
				
				finale_cleanse_entrance_door.ConnectOutput("OnFullyClosed", "C5M2Door2_OnFullyClosed");
				finale_cleanse_entrance_door.ConnectOutput("OnClose", "C5M2Door2_OnClose");
				finale_cleanse_entrance_door.ConnectOutput("OnOpen", "C5M2Door2_OnOpen");
			}
			else
				Left4Bots.Log(LOG_LEVEL_ERROR, "finale_cleanse_entrance_door was not found in c5m2_park map!");
				
			local finale_cleanse_exit_door = Entities.FindByName(null, "finale_cleanse_exit_door");
			if (finale_cleanse_exit_door)
			{
				finale_cleanse_exit_door.ValidateScriptScope();
				local scope = finale_cleanse_exit_door.GetScriptScope();
				
				scope["C5M2Door3_OnOpen"] <- Left4Bots.C5M2Door3_OnOpen;
				
				finale_cleanse_exit_door.ConnectOutput("OnOpen", "C5M2Door3_OnOpen");
			}
			else
				Left4Bots.Log(LOG_LEVEL_ERROR, "finale_cleanse_exit_door was not found in c5m2_park map!");
		}
	}

	::Left4Bots.OnScavengeRoundStart <- function (round, firsthalf, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnScavengeRoundStart");
		
		//if (!Left4Bots.Settings.no_scavenge)
			Left4Bots.ScavengeEnabled = true;
	}

	::Left4Bots.OnVersusRoundStart <- function (params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnVersusRoundStart");
		
		//if (Left4Bots.Bots.len() == Left4Bots.Survivors.len() && !Left4Bots.Settings.no_scavenge)
		//	Left4Bots.ScavengeEnabled = true;
	}
	
	::Left4Bots.C5M2Door1_OnEntireTeamStartTouch <- function ()
	{
		Left4Bots.C5M2EntireTeamInside = true;
		
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_entrance_door");

		if (!Left4Bots.HasManualOrderTarget("finale_cleanse_entrance_door"))
		{
			local randomBot = Left4Bots.GetRandomAvailableBot();
			if (randomBot)
			{
				local entranceDoor = Entities.FindByName(null, "finale_cleanse_entrance_door");
				if (entranceDoor)
				{
					local state = NetProps.GetPropInt(entranceDoor, "m_eDoorState");
					if (state == 2) // 0 = closed - 2 = open
					{
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time() + 0.5, dest = entranceDoor, pos = Vector(-9664.007813, -5710.822754, -213.083099), lookatpos = Vector(-9644.333008, -5343.300781, -256.000000), ordertype = "door", canpause = true };
							
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: finale_cleanse_entrance_door");
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
				else
					Left4Bots.Log(LOG_LEVEL_WARN, "finale_cleanse_entrance_door was not found!");
			}
			else
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Couldn't find an available bot to close C5M2 finale_cleanse_entrance_door");
		}
		else
			Left4Bots.Log(LOG_LEVEL_ERROR, "Failed to clear previous finale_cleanse_entrance_door orders");
	}

	::Left4Bots.C5M2Door1_OnEntireTeamEndTouch <- function ()
	{
		Left4Bots.C5M2EntireTeamInside = false;
		
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_entrance_door");
	}

	::Left4Bots.C5M2Door2_OnFullyClosed <- function ()
	{
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_exit_door");
		
		if (Left4Bots.Bots.len() != Left4Bots.Survivors.len())
			return;
		
		if (!Left4Bots.HasManualOrderTarget("finale_cleanse_exit_door"))
		{
			local randomBot = Left4Bots.GetRandomAvailableBot();
			if (randomBot)
			{
				local exitDoor = Entities.FindByName(null, "finale_cleanse_exit_door");
				if (exitDoor)
				{
					local state = NetProps.GetPropInt(exitDoor, "m_eDoorState");
					if (state == 0) // 0 = closed - 2 = open
					{
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time() + 5, dest = exitDoor, pos = Vector(-9583.743164, -6047.993164, -213.945755), lookatpos = Vector(-9367.793945, -6040.201660, -256.000000), ordertype = "door", canpause = true };
							
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: finale_cleanse_exit_door");
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
				else
					Left4Bots.Log(LOG_LEVEL_WARN, "finale_cleanse_exit_door was not found!");
			}
			else
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Couldn't find an available bot to open C5M2 finale_cleanse_exit_door");
		}
		else
			Left4Bots.Log(LOG_LEVEL_ERROR, "Failed to clear previous finale_cleanse_exit_door orders");
	}

	::Left4Bots.C5M2Door2_OnClose <- function ()
	{
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_entrance_door");
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_exit_door");
	}

	::Left4Bots.C5M2Door2_OnOpen <- function ()
	{
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_entrance_door");
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_exit_door");
	}

	::Left4Bots.C5M2Door3_OnOpen <- function ()
	{
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_entrance_door");
		Left4Bots.RemoveManualOrdersByTarget("finale_cleanse_exit_door");
	}

	::Left4Bots.GetFlowPercent <- function ()
	{
		local ret = 0;
		foreach (id, surv in ::Left4Bots.Survivors)
		{
			if (surv && surv.IsValid())
			{
				local flow = GetCurrentFlowPercentForPlayer(surv);
				if (flow > ret)
					ret = flow;
			}
		}
		return ret;
	}

	::Left4Bots.Cleaner <- function (params)
	{
		// Survivors
		foreach (id, surv in ::Left4Bots.Survivors)
		{
			if (!surv || !surv.IsValid())
			{
				delete ::Left4Bots.Survivors[id];
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Removed an invalid survivor from ::Left4Bots.Survivors");
			}
		}
		
		// Bots
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (!bot || !bot.IsValid())
			{
				delete ::Left4Bots.Bots[id];
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Removed an invalid bot from ::Left4Bots.Bots");
			}
		}
		
		// Tanks
		foreach (id, tank in ::Left4Bots.Tanks)
		{
			if (!tank || !tank.IsValid())
			{
				delete ::Left4Bots.Tanks[id];
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Removed an invalid tank from ::Left4Bots.Tanks");
				
				if (Left4Bots.Tanks.len() == 0)
					Left4Bots.OnTankGone();
			}
		}
		
		// Deads
		foreach (chr, dead in ::Left4Bots.Deads)
		{
			if (!dead.dmodel || !dead.dmodel.IsValid())
			{
				delete ::Left4Bots.Deads[chr];
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Removed an invalid death model from ::Left4Bots.Deads");
				
			}
		}
		
		// Nothing to do with cleaning but...
		Left4Bots.HandleSBUnstick();
		
		Left4Bots.OnFlow(Left4Bots.GetFlowPercent());
	}

	::Left4Bots.OnFlow <- function (flowPercent)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnFlow - flowPercent: " + flowPercent);
		
		if (!Left4Bots.C7M1CanOpenTrainDoors && Left4Bots.MapName == "c7m1_docks" && flowPercent > 44)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C7M1CanOpenTrainDoors = true");
			
			Left4Bots.C7M1CanOpenTrainDoors = true;
			
			if (Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("tankdoorin_button") && !Left4Bots.HasManualOrderTarget("tankdoorout_button"))
			{
				local randomBot = Left4Bots.GetRandomAvailableBot();
				if (randomBot)
				{
					local door = Entities.FindByName(null, "tankdoorin_button");
					if (!door || !door.IsValid())
						door = Entities.FindByName(null, "tankdoorout_button");
					if (!door || !door.IsValid())
						door = null;
				
					if (door)
					{
						local pos = Vector(7103.514648, 589.364197, 130.150696);
						if (door.GetName() == "tankdoorout_button")
							pos = Vector(6971.906250, 669.720581, 167.122360);
						
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
						
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
		}
		else if (!Left4Bots.C9M2CanActivateGenerator && Left4Bots.MapName == "c9m2_lots" && flowPercent > 94)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C9M2CanActivateGenerator = true");
			
			Left4Bots.C9M2CanActivateGenerator = true;
			
			if (Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("finaleswitch_initial") && !Left4Bots.HasManualOrderTarget("generator_switch"))
			{
				local randomBot = Left4Bots.GetRandomAvailableBot();
				if (randomBot)
				{
					local generator = Entities.FindByName(null, "finaleswitch_initial");
					if (!generator || !generator.IsValid())
						generator = Entities.FindByName(null, "generator_switch");
					if (!generator || !generator.IsValid())
						generator = null;
				
					if (generator)
					{
						local pos = Vector(6849.456543, 5977.039063, 43.139301);
						
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = generator, pos = pos, ordertype = "generator", canpause = true };
						
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + generator.GetName());
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
		}
		else if (!Left4Bots.C12M2CanOpenEmergencyDoor && Left4Bots.MapName == "c12m2_traintunnel" && flowPercent > 29)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C12M2CanOpenEmergencyDoor = true");
			
			Left4Bots.C12M2CanOpenEmergencyDoor = true;
			
			if (Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("emergency_door"))
			{
				local randomBot = Left4Bots.GetRandomAvailableBot();
				if (randomBot)
				{
					local door = Entities.FindByName(null, "emergency_door");
					if (!door || !door.IsValid())
						door = null;
				
					if (door)
					{
						local pos = Vector(-8599.708008, -7498.775391, -63.968750);
						local lookatpos = Vector(-8596.366211, -7686.694824, -63.968754);
						
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, lookatpos = lookatpos, ordertype = "door", canpause = true };
						
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
		}
		else if (!Left4Bots.C13M1CanOpenBunkerDoor && Left4Bots.MapName == "c13m1_alpinecreek" && flowPercent > 83)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C13M1CanOpenBunkerDoor = true");
			
			Left4Bots.C13M1CanOpenBunkerDoor = true;
			
			if (Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("bunker_button"))
			{
				local randomBot = Left4Bots.GetRandomAvailableBot();
				if (randomBot)
				{
					local door = Entities.FindByName(null, "bunker_button");
					if (!door || !door.IsValid())
						door = null;
				
					if (door)
					{
						local pos = Vector(1036.148071, 244.124512, 714.031250);
						
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
						
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
						
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
		}
	}

	::Left4Utils.HasChainsaw <- function (survivor)
	{
		local item = Left4Utils.GetInventoryItemInSlot(survivor, INV_SLOT_SECONDARY);
		if (item && item.GetClassname() == "weapon_chainsaw")
			return true;
		
		return false;
	}

	::Left4Utils.CountChainsaws <- function ()
	{
		local ret = 0;
		foreach (id, surv in ::Left4Bots.Survivors)
		{
			if (surv && surv.IsValid() && Left4Utils.HasChainsaw(surv))
				ret++;
		}
		return ret;
	}

	::Left4Bots.ChainsawManager <- function (params)
	{
		local num = Left4Utils.CountChainsaws();
		
		if (num < Left4Bots.Settings.max_chainsaws)
		{
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot && bot.IsValid())
				{
					local scope = bot.GetScriptScope();
					if (!scope.Chainsaw)
					{
						scope.Chainsaw = true;
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "ChainsawManager - " + bot.GetPlayerName() + " - Chainsaw = true");
					}
				}
			}
			return;
		}
		else if (num == Left4Bots.Settings.max_chainsaws)
		{
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot && bot.IsValid() && !Left4Utils.HasChainsaw(bot))
				{
					local scope = bot.GetScriptScope();
					if (scope.Chainsaw)
					{
						scope.Chainsaw = false;
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "ChainsawManager - " + bot.GetPlayerName() + " - Chainsaw = false");
					}
				}
			}
		}
		else // num > Left4Bots.Settings.max_chainsaws
		{
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot && bot.IsValid() && Left4Utils.HasChainsaw(bot))
				{
					local scope = bot.GetScriptScope();
					if (scope.Chainsaw)
					{
						scope.Chainsaw = false;
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "ChainsawManager - " + bot.GetPlayerName() + " - Chainsaw = false");
					}
					
					num--;
				}
				
				if (num <= Left4Bots.Settings.max_chainsaws)
					break;
			}
		}
	}

	::Left4Bots.AddonStop <- function ()
	{
		if (Left4Bots.BtnListener)
			Left4Bots.BtnListener.Kill();
		
		// Server will crash without this
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot.IsValid())
				Left4Bots.HoldItemStop(bot);
		}
		
		//Convars.SetValue("sb_all_bot_game", 0); // Apparently with sb_all_bot_game 1, if you start the windows server and do changelevel without people connected, the server crashes.
		// too bad, this ^ doesn't fix it.
		
		Left4Bots.ScavengeEnabled = false;
		Left4Bots.StartGenerators = false;
		
		Left4Timers.RemoveTimer("ScavengeManager");
		Left4Timers.RemoveTimer("Cleaner");
		Left4Timers.RemoveTimer("ChainsawManager");
		
		::ConceptsHub.RemoveHandler("Left4Bots");
		
		Left4Bots.ClearBotThink();
		
		Left4Bots.Survivors = {};
		Left4Bots.Bots = {};
		Left4Bots.Tanks = {};
		
		Left4Bots.ScavengeUseTarget = null;
		Left4Bots.ScavengeUseTargetPos = null;
		Left4Bots.ScavengeUseType = 0;
		Left4Bots.ScavengeOrders = {};
		Left4Bots.ManualOrders = {};
	}

	::Left4Bots.OnRoundEnd <- function (winner, reason, message, time, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnRoundEnd - winner: " + winner + " - reason: " + reason + " - message: " + message + " - time: " + time);
		
		Left4Bots.ClearPipeBombs();
		
		Left4Bots.AddonStop();
	}

	::Left4Bots.OnMapTransition <- function (params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnMapTransition");
		
		Left4Bots.ClearPipeBombs();
		
		Left4Bots.AddonStop();
	}

	::Left4Bots.OnServerPreShutdown <- function (reason)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnServerPreShutdown - reason: " + reason);
		
		Left4Bots.ClearPipeBombs();
	}

	::Left4Bots.OnFinaleWin <- function ()
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnFinaleWin");
		
		local ggLines = Left4Utils.FileToStringList("left4bots/cfg/" + Left4Bots.Settings.file_gg);
		local bgLines = Left4Utils.FileToStringList("left4bots/cfg/" + Left4Bots.Settings.file_bg);
		
		foreach (id, bot in ::Left4Utils.GetAllSurvivors())
		{
			if (bot && bot.IsValid() && IsPlayerABot(bot))
			{
				local line = null;
				if (!bot.IsIncapacitated() && !bot.IsDead() && !bot.IsDying())
				{
					if (ggLines && ggLines.len() > 0 && RandomInt(1, 100) <= Left4Bots.Settings.gg_chance)
						line = ggLines[RandomInt(0, ggLines.len() - 1)];
				}
				else
				{
					if (bgLines && bgLines.len() > 0 && RandomInt(1, 100) <= Left4Bots.Settings.bg_chance)
						line = bgLines[RandomInt(0, bgLines.len() - 1)];
				}
				
				if (line)
					Left4Timers.AddTimer(null, RandomFloat(2.0, 5.0), Left4Bots.SayGG, { bot = bot, line = line });
			}
		}
	}

	::Left4Bots.SayGG <- function (params)
	{
		local bot = params["bot"];
		local line = params["line"];
		
		if (bot && bot.IsValid())
			Say(bot, line, false);
	}

	::Left4Bots.ClearPipeBombs <- function ()
	{
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "pipe_bomb_projectile"))
		{
			if (ent.IsValid())
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.ClearPipeBombs - Killing pipe_bomb_projectile");
				ent.Kill();
			}
		}
	}

	::Left4Bots.GetOtherAliveSurvivors <- function (me)
	{
		local t = {};
		local i = -1;
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && surv.GetPlayerUserId() != me.GetPlayerUserId())
				t[++i] <- surv;
		}
		return t;
	}

	::Left4Bots.GetOtherAliveHumanSurvivors <- function (me)
	{
		local t = {};
		local i = -1;
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && surv.GetPlayerUserId() != me.GetPlayerUserId() && !IsPlayerABot(surv))
				t[++i] <- surv;
		}
		return t;
	}

	::Left4Bots.GetNearestAliveSurvivor <- function (me)
	{
		local ret = null;
		local minDist = 1000000;
		foreach (surv in ::Left4Bots.GetOtherAliveSurvivors(me))
		{
			local dist = (me.GetOrigin() - surv.GetOrigin()).Length();
			if (dist < minDist)
			{
				ret = surv;
				minDist = dist;
			}
		}
		return ret;
	}
	
	::Left4Bots.GetNearestAliveHumanSurvivor <- function (me)
	{
		local ret = null;
		local minDist = 1000000;
		foreach (surv in ::Left4Bots.GetOtherAliveHumanSurvivors(me))
		{
			local dist = (me.GetOrigin() - surv.GetOrigin()).Length();
			if (dist < minDist)
			{
				ret = surv;
				minDist = dist;
			}
		}
		return ret;
	}

	::Left4Bots.IsFarFromHumanSurvivors <- function (me, range)
	{
		local aliveHumans = Left4Bots.GetOtherAliveHumanSurvivors(me);
		if (aliveHumans.len() == 0)
			return false;
		
		foreach (surv in aliveHumans)
		{
			if ((me.GetOrigin() - surv.GetOrigin()).Length() <= range)
				return false;
		}
		return true;
	}

	// Checks if 'player' has at least 'num' angry commons within 'radius' and 'maxAltDiff'
	// Returns:
	// 	- 'false' if the conditions were not met
	//	- 'true' if enough angry commons were found but no one of them was visible
	//	- the entity of the farthest visible common from the checked ones
	::Left4Bots.HasAngryCommonsWithin <- function (player, num, radius = 1000, maxAltDiff = 1000)
	{
		local t = true;
		local d = 0;
		local n = 0;
		local ent = null;
		local a = player.GetOrigin().z;
		while (ent = Entities.FindByClassnameWithin(ent, "infected", player.GetOrigin(), radius))
		{
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_lifeState") == 0) // <- still alive
			{
				local dist = (ent.GetOrigin() - player.GetOrigin()).Length();
				if (dist > d && dist >= THROW_NADE_MIN_DISTANCE && Left4Utils.CanTraceTo(player, ent))
				{
					t = ent;
					d = dist;
				}
				
				if ((NetProps.GetPropInt(ent, "m_mobRush") || NetProps.GetPropInt(ent, "m_clientLookatTarget")) && abs(a - ent.GetOrigin().z) <= maxAltDiff)
				{
					if (++n >= num)
						return t;
				}
			}
		}
		return false;
	}

	::Left4Bots.CountOtherStandingSurvivorsWithin <- function (me, radius)
	{
		local ret = 0;
		foreach (surv in ::Left4Bots.GetOtherAliveSurvivors(me))
		{
			if (!surv.IsIncapacitated() && (surv.GetOrigin() - me.GetOrigin()).Length() <= radius)
				ret++;
		}
		return ret;
	}

	::Left4Bots.GetOtherStandingSurvivorsWithin <- function (me, radius)
	{
		local t = {};
		local i = -1;
		foreach (surv in ::Left4Bots.GetOtherAliveSurvivors(me))
		{
			if (!surv.IsIncapacitated() && (surv.GetOrigin() - me.GetOrigin()).Length() <= radius)
				t[++i] <- surv;
		}
		return t;
	}

	::Left4Bots.CountSpareMedkitsAround <- function (me)
	{
		local numMedkits = Left4Utils.GetMedkitsWithin(me, 500).len();
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.CountSpareMedkitsAround - me: " + me.GetPlayerName() + " - numMedkits: " + numMedkits);
		
		foreach (surv in Left4Bots.GetOtherAliveSurvivors(me))
		{
			if (surv.GetHealth() < 75 || !Left4Utils.HasMedkit(surv))
				numMedkits--;
		}
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.CountSpareMedkitsAround - spareMedkits: " + numMedkits);
		return numMedkits;
	}

	::Left4Bots.OnHealStart <- function (player, subject, params)
	{
		if(!player || !subject)
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnHealStart - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName());
		
		if (!IsPlayerABot(player))
			return;
		
		// Don't let survivor bots heal themselves if their health is >= Left4Bots.Settings.min_start_health (usually they do it in the start saferoom) and there are not enough spare medkits around
		// ... and there are humans in the team (otherwise they won't leave the saferoom)
		if (player.GetPlayerUserId() == subject.GetPlayerUserId() && player.GetHealth() >= Left4Bots.Settings.min_start_health && Left4Bots.Bots.len() < Left4Bots.Survivors.len() && Left4Bots.CountSpareMedkitsAround(player) <= 0)
			Left4Bots.BotReset(player, true);
		else if (Left4Bots.Settings.force_heal && player.GetPlayerUserId() == subject.GetPlayerUserId() && Left4Bots.HasAngryCommonsWithin(player, 3, 100) == false && !Left4Utils.HasSpecialInfectedWithin(player, 400))
		{
			// Force healing without interrupting or they won't heal when not "feeling safe" resulting most of the times in not healing until they die
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " FORCE HEAL");
			
			Left4Bots.BotPressButton(player, BUTTON_ATTACK, BUTTON_HOLDTIME_HEAL, null, 0, 0, true); // <- without lockLook the base AI will be able to interrupt the healing
		}
	}

	::Left4Bots.SwapNades <- function (params)
	{
		local player1 = params["player1"];
		local weapon1 = params["weapon1"];
		local player2 = params["player2"];
		local weapon2 = params["weapon2"];
		
		if (weapon1 && weapon1.IsValid() && weapon2 && weapon2.IsValid())
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.SwapNades - " + weapon1.GetClassname() + " -> " + player1.GetPlayerName() + " - " + weapon2.GetClassname() + " -> " + player2.GetPlayerName());
				
		if (weapon1 && weapon1.IsValid())
			DoEntFire("!self", "Kill", "", 0, null, weapon1);
		if (weapon2 && weapon2.IsValid())
			DoEntFire("!self", "Kill", "", 0, null, weapon2);
		
		Left4Bots.GiveItemIndex1 = 0;
		Left4Bots.GiveItemIndex2 = 0;
		
		if (Left4Bots.Settings.play_sounds)
		{
			if (!IsPlayerABot(player1))
				EmitSoundOnClient(SOUND_BIGREWARD, player1);
			if (!IsPlayerABot(player2))
				EmitSoundOnClient(SOUND_BIGREWARD, player2);

			foreach (id, surv in ::Left4Bots.Survivors)
			{
				if (surv && surv.IsValid() && !IsPlayerABot(surv) && id != player1.GetPlayerUserId() && id != player2.GetPlayerUserId())
					EmitSoundOnClient(SOUND_LITTLEREWARD, surv);
			}
		}
	}

	::Left4Bots.GiveNade <- function (params)
	{
		local player1 = params["player1"];
		local player2 = params["player2"];
		local weapon = params["weapon"];
		
		if (weapon && weapon.IsValid())
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.GiveNade - " + player1.GetPlayerName() + " -> " + weapon.GetClassname() + " -> " + player2.GetPlayerName());
		
			DoEntFire("!self", "Kill", "", 0, null, weapon);
		}
		
		Left4Bots.GiveItemIndex1 = 0;
		
		if (Left4Bots.Settings.play_sounds)
		{
			if (!IsPlayerABot(player1))
				EmitSoundOnClient(SOUND_BIGREWARD, player1);
				
			foreach (id, surv in ::Left4Bots.Survivors)
			{
				if (surv && surv.IsValid() && !IsPlayerABot(surv) && id != player1.GetPlayerUserId())
					EmitSoundOnClient(SOUND_LITTLEREWARD, surv);
			}
		}
	}

	::Left4Bots.OnReviveBegin <- function (player, subject, params)
	{
		if (!IsPlayerABot(player))
			return;

		local item = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_THROW);
		if (!item)
			return;

		local nade = item.GetClassname();
		
		if (((Left4Bots.Settings.throw_pipe_bomb && nade == "weapon_pipe_bomb") || (Left4Bots.Settings.throw_vomitjar && nade == "weapon_vomitjar")) && NetProps.GetPropInt(player, "m_hasVisibleThreats") && (Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL && Left4Bots.CountOtherStandingSurvivorsWithin(player, THROW_NADE_ONREVIVE_COVER_RADIUS) < THROW_NADE_ONREVIVE_COVER_COUNT && Left4Bots.HasAngryCommonsWithin(player, 4, 350) != false)
		{
			local pos = Left4Utils.BotGetFarthestPathablePos(player, THROW_NADE_RADIUS);
			if (pos && (pos - player.GetOrigin()).Length() >= THROW_NADE_MIN_DISTANCE)
				Left4Timers.AddTimer(null, 0.1, Left4Bots.CancelReviveAndThrowNade, { player = player, subject = subject, nade = nade, pos = pos });
		}
	}

	::Left4Bots.CancelReviveAndThrowNade <- function (params)
	{
		local player = params["player"];
		local subject = params["subject"];
		local nade = params["nade"];
		local pos = params["pos"];
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.CancelReviveAndThrowNade - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName() + " - nade: " + nade);
				
		NetProps.SetPropEntity(player, "m_reviveTarget", null);
		NetProps.SetPropEntity(subject, "m_reviveOwner", null);
		
		Left4Bots.BotReset(player, true);

		Left4Bots.BotThrowNade(player, nade, pos, THROW_NADE_DELTAPITCH);
	}

	::Left4Bots.OnPlayerConnected <- function (player, params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerConnected - player: " + player.GetPlayerName());
		
		Left4Bots.PlayerIn(player);
	}

	::Left4Bots.OnPlayerDisconnected <- function (userid, player, params)
	{
		if (player && player.IsValid() && IsPlayerABot(player))
			return;

		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerDisconnected - player: " + player.GetPlayerName());
		
		Left4Bots.PlayerOut(userid, player);
		
		if (userid in ::Left4Bots.Survivors)
			delete ::Left4Bots.Survivors[userid];
	}

	::Left4Bots.PrintSurvivorsCount <- function ()
	{
		local sn = ::Left4Bots.Survivors.len();
		local bn = ::Left4Bots.Bots.len();
		local hn = sn - bn;
		Left4Bots.Log(LOG_LEVEL_DEBUG, "[Alive survivors: " + sn + " - " + bn + " bot(s) - " + hn + " human(s)]");
	}

	::Left4Bots.IsValidSurvivor <- function (player)
	{
		if (player.GetZombieType() != 9)
			return false; // Not a survivor
		
		local team = NetProps.GetPropInt(player, "m_iTeamNum"); // Certain mutations for some reason can spawn special infected with TEAM_SURVIVORS 
		if (team == TEAM_SURVIVORS)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "IsValidSurvivor - " + player.GetPlayerName() + " is a valid survivor");
			return true;
		}
			
		if (team == TEAM_L4D1_SURVIVORS && Left4Bots.Settings.handle_l4d1_survivors)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "IsValidSurvivor - " + player.GetPlayerName() + " is a valid survivor (L4D1)");
			return true;
		}
		
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "IsValidSurvivor - " + player.GetPlayerName() + " is not a valid survivor");
		return false;
	}

	::Left4Bots.OnPlayerSpawn <- function (player, params)
	{
		if (!player || !player.IsValid())
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerSpawn - player: " + player.GetPlayerName());
		
		Left4Bots.PlayerIn(player);
		
		if (Left4Bots.IsValidSurvivor(player))
		{
			//if (NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SPECTATORS)
			//{
				::Left4Bots.Survivors[player.GetPlayerUserId()] <- player;
				
				if (IsPlayerABot(player))
				{
					::Left4Bots.Bots[player.GetPlayerUserId()] <- player;
				
					Left4Bots.AddBotThink(player);
				}
				
				Left4Bots.PrintSurvivorsCount();
			//}
			if (!IsPlayerABot(player) && Left4Bots.Settings.play_sounds)
			{
				player.PrecacheScriptSound(SOUND_BIGREWARD);
				player.PrecacheScriptSound(SOUND_LITTLEREWARD);
			}
		}
		else if (("GetZombieType" in player) && player.GetZombieType() == Z_TANK)
		{
			::Left4Bots.Tanks[player.GetPlayerUserId()] <- player;
			
			if (Left4Bots.Tanks.len() == 1)
				Left4Bots.OnTankActive();
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Active tanks: " + ::Left4Bots.Tanks.len());
		}
	}
	
	::Left4Bots.OnPlayerIncapacitated <- function (player, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerIncapacitated - player: " + player.GetPlayerName());
		
		if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS)
		{
			if (!Left4Bots.Settings.keep_holding_position)
			{
				Convars.SetValue("sb_hold_position", 0);
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
			}
			
			if (IsPlayerABot(player))
				Left4Bots.BotReset(player);
		}
	}
	
	::Left4Bots.OnPlayerLedgeGrab <- function (player, causer, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerLedgeGrab - player: " + player.GetPlayerName());
		
		if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS)
		{
			if (!Left4Bots.Settings.keep_holding_position)
			{
				Convars.SetValue("sb_hold_position", 0);
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
			}
			
			if (IsPlayerABot(player))
				Left4Bots.BotReset(player);
		}
	}
	
	::Left4Bots.DelayedPlayerDeath <- function (params)
	{
		local player = params["player"];
		local attackerent = params["attackerent"];
		local type = params["dmg_type"];
		
		local chr = NetProps.GetPropInt(player, "m_survivorCharacter");
		local sdm = Left4Utils.GetSurvivorDeathModelByChar(chr);
		if (sdm)
		{
			if (attackerent == "trigger_hurt" && (Left4Utils.DamageContains(type, DMG_DROWN) || Left4Utils.DamageContains(type, DMG_CRUSH)))
				Left4Bots.Log(LOG_LEVEL_INFO, "Ignored possible unreachable survivor_death_model for dead survivor: " + player.GetPlayerName());
			else
				Left4Bots.Deads[chr] <- { dmodel = sdm, player = player };
		}
		else
			Left4Bots.Log(LOG_LEVEL_WARN, "Left4Bots.DelayedPlayerDeath - Couldn't find a survivor_death_model for the dead survivor: " + player.GetPlayerName() + "!!!");
	}
	
	::Left4Bots.OnPlayerDeath <- function (player, attacker, attackerent, weapon, abort, type, params)
	{
		if (attackerent)
			attackerent = attackerent.GetClassname();
		else
			attackerent = "null";
		
		if (attacker)
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerDeath - player: " + player.GetPlayerName() + " - attacker: " + attacker.GetPlayerName() + " - attackerent: " + attackerent + " - weapon: " + weapon + " - abort: " + abort + " - type: " + type);
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerDeath - player: " + player.GetPlayerName() + " - attacker: null - attackerent: " + attackerent + " - weapon: " + weapon + " - abort: " + abort + " - type: " + type);
		
		local victimTeam = NetProps.GetPropInt(player, "m_iTeamNum");
		if (victimTeam == TEAM_INFECTED)
		{
			if ((player.GetClassname() == "player" || player.GetClassname() == "witch") && attacker && attacker.GetClassname() == "player" && NetProps.GetPropInt(attacker, "m_iTeamNum") == TEAM_SURVIVORS && IsPlayerABot(attacker))
			{
				Left4Bots.NiceShootSurv = attacker;
				Left4Bots.NiceShootTime = Time();
			}
			
			if ("GetZombieType" in player && player.GetZombieType() == Z_TANK && player.GetPlayerUserId() in ::Left4Bots.Tanks)
			{
				delete ::Left4Bots.Tanks[player.GetPlayerUserId()];
				
				if (Left4Bots.Tanks.len() == 0)
					Left4Bots.OnTankGone();
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Active tanks: " + ::Left4Bots.Tanks.len());
				
				if (Left4Bots.C7M1CanOpenTrainDoors && Left4Bots.MapName == "c7m1_docks" && Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("tankdoorin_button") && !Left4Bots.HasManualOrderTarget("tankdoorout_button"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "tankdoorin_button");
						if (!door || !door.IsValid())
							door = Entities.FindByName(null, "tankdoorout_button");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(7103.514648, 589.364197, 130.150696);
							if (door.GetName() == "tankdoorout_button")
								pos = Vector(6971.906250, 669.720581, 167.122360);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
		}
		else if (victimTeam == TEAM_SURVIVORS)
		{
			if (player.GetPlayerUserId() in ::Left4Bots.Survivors)
				delete ::Left4Bots.Survivors[player.GetPlayerUserId()];
			
			if (IsPlayerABot(player))
			{
				if (player.GetPlayerUserId() in ::Left4Bots.Bots)
					delete ::Left4Bots.Bots[player.GetPlayerUserId()];
			
				Left4Bots.RemoveBotThink(player);
				
				if (player.GetPlayerUserId() in ::Left4Bots.ScavengeOrders)
				{
					delete ::Left4Bots.ScavengeOrders[player.GetPlayerUserId()];
			
					Left4Bots.Log(LOG_LEVEL_INFO, "Removed scavenge order slot for bot " + player.GetPlayerName());
				}
				
				if (player.GetPlayerUserId() in ::Left4Bots.ManualOrders)
				{
					delete ::Left4Bots.ManualOrders[player.GetPlayerUserId()];
					
					Left4Bots.Log(LOG_LEVEL_INFO, "Removed manual order for bot " + player.GetPlayerName());
				}
			}
			
			Left4Bots.PrintSurvivorsCount();
			
			if (!Left4Bots.Settings.keep_holding_position)
			{
				Convars.SetValue("sb_hold_position", 0);
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
			}
			
			if (Left4Bots.Bots.len() == Left4Bots.Survivors.len())
			{
				if (Left4Bots.MapName == "c5m2_park" && Left4Bots.C5M2EntireTeamInside && !Left4Bots.HasManualOrderTarget("finale_cleanse_entrance_door") && !Left4Bots.HasManualOrderTarget("finale_cleanse_exit_door"))
				{
					local entranceDoor = Entities.FindByName(null, "finale_cleanse_entrance_door");
					if (entranceDoor)
					{
						local state = NetProps.GetPropInt(entranceDoor, "m_eDoorState");
						if (state == 2) // 0 = closed - 2 = open
							Left4Bots.C5M2Door1_OnEntireTeamStartTouch();
						else
						{
							local exitDoor = Entities.FindByName(null, "finale_cleanse_exit_door");
							if (exitDoor)
							{
								local state = NetProps.GetPropInt(exitDoor, "m_eDoorState");
								if (state == 0) // 0 = closed - 2 = open
									Left4Bots.C5M2Door2_OnFullyClosed();
							}
							else
								Left4Bots.Log(LOG_LEVEL_ERROR, "finale_cleanse_exit_door was not found in c5m2_park map!");
						}
					}
					else
						Left4Bots.Log(LOG_LEVEL_ERROR, "finale_cleanse_entrance_door was not found in c5m2_park map!");
				}
				else if (Left4Bots.MapName == "c7m1_docks" && Left4Bots.C7M1CanOpenTrainDoors && !Left4Bots.HasManualOrderTarget("tankdoorin_button") && !Left4Bots.HasManualOrderTarget("tankdoorout_button"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "tankdoorin_button");
						if (!door || !door.IsValid())
							door = Entities.FindByName(null, "tankdoorout_button");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(7103.514648, 589.364197, 130.150696);
							if (door.GetName() == "tankdoorout_button")
								pos = Vector(6971.906250, 669.720581, 167.122360);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
				else if (Left4Bots.MapName == "c9m2_lots" && Left4Bots.C9M2CanActivateGenerator && !Left4Bots.HasManualOrderTarget("finaleswitch_initial") && !Left4Bots.HasManualOrderTarget("generator_switch"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local generator = Entities.FindByName(null, "finaleswitch_initial");
						if (!generator || !generator.IsValid())
							generator = Entities.FindByName(null, "generator_switch");
						if (!generator || !generator.IsValid())
							generator = null;
						
						if (generator)
						{
							local pos = Vector(6849.456543, 5977.039063, 43.139301);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = generator, pos = pos, ordertype = "generator", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + generator.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
				else if (Left4Bots.MapName == "c12m2_traintunnel" && Left4Bots.C12M2CanOpenEmergencyDoor && !Left4Bots.HasManualOrderTarget("emergency_door"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "emergency_door");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(-8599.708008, -7498.775391, -63.968750);
							local lookatpos = Vector(-8596.366211, -7686.694824, -63.968754);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, lookatpos = lookatpos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
				else if (Left4Bots.MapName == "c13m1_alpinecreek" && Left4Bots.C13M1CanOpenBunkerDoor && !Left4Bots.HasManualOrderTarget("bunker_button"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "bunker_button");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(1036.148071, 244.124512, 714.031250);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
				
				if (!Left4Bots.Settings.no_scavenge)
					Left4Bots.ScavengeEnabled = true;
				
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (bot.IsValid())
						Left4Bots.HoldItemStop(bot);
				}
			}

			// TODO
			//Left4Timers.AddTimer(null, 0.1, Left4Bots.DelayedPlayerDeath, { player = player, attackerent = attackerent, dmg_type = type });
			///*
			local chr = NetProps.GetPropInt(player, "m_survivorCharacter");
			local sdm = Left4Utils.GetSurvivorDeathModelByChar(chr);
			if (sdm)
			{
				if (attackerent == "trigger_hurt" && (Left4Utils.DamageContains(type, DMG_DROWN) || Left4Utils.DamageContains(type, DMG_CRUSH)))
					Left4Bots.Log(LOG_LEVEL_INFO, "Ignored possible unreachable survivor_death_model for dead survivor: " + player.GetPlayerName());
				else
					Left4Bots.Deads[chr] <- { dmodel = sdm, player = player };
			}
			else
				Left4Bots.Log(LOG_LEVEL_WARN, "Left4Bots.OnPlayerDeath - Couldn't find a survivor_death_model for the dead survivor: " + player.GetPlayerName() + "!!!");
			//*/
		}
	}

	::Left4Bots.OnPlayerHurt <- function (player, attacker, params)
	{
		/*
		local weapon = "";
		if ("weapon" in params)
			weapon = params["weapon"];
		local type = -1;
		if ("type" in params)
			type = params["type"]; // commons do DMG_CLUB
			
		if (attacker)
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerHurt - player: " + player.GetPlayerName() + " - attacker: " + attacker.GetClassname() + " - weapon: " + weapon + " - type: " + type);
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerHurt - player: " + player.GetPlayerName() + " - weapon: " + weapon + " - type: " + type);
		*/
		
		if (NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
		
		if (IsPlayerABot(player))
		{
			local weapon = "";
			if ("weapon" in params)
				weapon = params["weapon"];
			
			if (weapon == "insect_swarm" && Convars.GetFloat("sb_hold_position") != 0 && !Left4Bots.Settings.keep_holding_position)
			{
				// Stop holding position if one or more bots are being hit by the spitter's spit
				Convars.SetValue("sb_hold_position", 0);
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
			}
			
			if (attacker && attacker.GetClassname() == "infected")
				Left4Bots.BotShove(player, attacker);
			
			/* if the bot is in the spit and has a pickup nearby it resets but will try to go again to the pickup and reset again making the bot get stuck in the spit
			else if (!attacker || NetProps.GetPropInt(attacker, "m_iTeamNum") != TEAM_SURVIVORS)
				Left4Bots.BotReset(player);
			*/
		}
		
		/* TODO: Test if better without
		if (attacker && attacker.GetClassname() == "player" && ("GetZombieType" in attacker))
		{
			local zt = attacker.GetZombieType();
			if (zt == Z_JOCKEY || zt == Z_SMOKER || zt == Z_HUNTER || zt == Z_CHARGER)
			{
				// Left4Utils.BotCmdAttack(null, attacker); // This makes also the common infected attack the special
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (!bot.IsValid() || id == player.GetPlayerUserId())
						continue;
					
					local dist = (bot.GetOrigin() - player.GetOrigin()).Length();
					local held = bot.GetActiveWeapon();
						
					//if (isCharger || dist > ATTACK_SI_MIN_DISTANCE)
					if (dist > ATTACK_SI_MIN_DISTANCE && dist < ATTACK_SI_MAX_DISTANCE && held && held.GetClassname() != "weapon_melee" && held.GetClassname() != "weapon_chainsaw")
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " ATTACK2 " + attacker.GetPlayerName());
						
						Left4Utils.BotCmdAttack(bot, attacker);
					}
				}
			}
		}
		*/
	}

	::Left4Bots.OnFriendlyFire <- function (attacker, victim, guilty, dmgType, params)
	{
		local attackerName = "";
		local victimName = "";
		local guiltyName = "";
		
		if (attacker)
			attackerName = attacker.GetPlayerName();
		if (victimName)
			victimName = victim.GetPlayerName();
		if (guiltyName)
			guiltyName = guilty.GetPlayerName();
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnFriendlyFire - attacker: " + attackerName + " - victim: " + victimName + " - guilty: " + guiltyName);
		
		if (victim && guilty && victim.GetPlayerUserId() != guilty.GetPlayerUserId() && IsPlayerABot(guilty) /*&& !IsPlayerABot(victim)*/ && RandomInt(1, 100) <= Left4Bots.Settings.sorry_chance)
			DoEntFire("!self", "SpeakResponseConcept", "PlayerSorry", RandomFloat(0.6, 2), null, guilty);
	}
	
	::Left4Bots.OnBotReplacedPlayer <- function (player, bot, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnBotReplacedPlayer - player: " + player.GetPlayerName() + " - bot: " + bot.GetPlayerName());
		
		if (player.GetPlayerUserId() in ::Left4Bots.Survivors)
			delete ::Left4Bots.Survivors[player.GetPlayerUserId()];
		
		if (Left4Bots.IsValidSurvivor(bot))
		{
			::Left4Bots.Survivors[bot.GetPlayerUserId()] <- bot;
			::Left4Bots.Bots[bot.GetPlayerUserId()] <- bot;
		
			Left4Bots.AddBotThink(bot);
		}
		
		Left4Bots.PrintSurvivorsCount();
		
		if (Left4Bots.Bots.len() == Left4Bots.Survivors.len())
		{
			Convars.SetValue("sb_hold_position", 0); // Apparently there are no more human players, no reason to stand still
			Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
			if (Left4Bots.Settings.wait_crouch)
				Convars.SetValue("sb_crouch", 0);
			
			if (!Left4Bots.Settings.no_scavenge)
				Left4Bots.ScavengeEnabled = true;
			
			// TODO: Add the same bot automation logics of the OnPlayerDeath ?
			
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot.IsValid())
					Left4Bots.HoldItemStop(bot);
			}
		}
	}
	
	::Left4Bots.OnPlayerReplacedBot <- function (player, bot, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerReplacedBot - player: " + player.GetPlayerName() + " - bot: " + bot.GetPlayerName());
		
		Left4Bots.PlayerIn(player);
		
		if (bot.GetPlayerUserId() in ::Left4Bots.Survivors)
			delete ::Left4Bots.Survivors[bot.GetPlayerUserId()];
		
		if (bot.GetPlayerUserId() in ::Left4Bots.Bots)
			delete ::Left4Bots.Bots[bot.GetPlayerUserId()];
		
		Left4Bots.RemoveBotThink(bot);

		if (bot.GetPlayerUserId() in ::Left4Bots.ScavengeOrders)
		{
			delete ::Left4Bots.ScavengeOrders[bot.GetPlayerUserId()];
	
			Left4Bots.Log(LOG_LEVEL_INFO, "Removed scavenge order slot for bot " + bot.GetPlayerName());
		}
		
		if (bot.GetPlayerUserId() in ::Left4Bots.ManualOrders)
		{
			delete ::Left4Bots.ManualOrders[bot.GetPlayerUserId()];
		
			Left4Bots.Log(LOG_LEVEL_INFO, "Removed manual order for bot " + bot.GetPlayerName());
		}
		
		if (Left4Bots.IsValidSurvivor(player))
			::Left4Bots.Survivors[player.GetPlayerUserId()] <- player;
		
		Left4Bots.PrintSurvivorsCount();
	}
	
	::Left4Bots.OnDefibrillatorBegin <- function (player, subject, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDefibrillatorBegin - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName());
		
		Left4Bots.DefibbingUserId = player.GetPlayerUserId();
		Left4Bots.DefibbingSince = Time();
	}
	
	::Left4Bots.OnDefibrillatorUsed <- function (player, subject, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDefibrillatorUsed - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName());
		
		Left4Bots.DefibbingUserId = -1;
		Left4Bots.DefibbingSince = 0;
	}
	
	::Left4Bots.OnDefibrillatorUsedFail <- function (player, subject, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDefibrillatorUsedFail - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName());
		
		Left4Bots.DefibbingUserId = -1;
		Left4Bots.DefibbingSince = 0;
	}
	
	::Left4Bots.OnDefibrillatorInterrupted <- function (player, subject, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDefibrillatorInterrupted - player: " + player.GetPlayerName() + " - subject: " + subject.GetPlayerName());
		
		Left4Bots.DefibbingUserId = -1;
		Left4Bots.DefibbingSince = 0;
	}
	
	::Left4Bots.SpecialGotSurvivor <- function (survivor, special, isCharger = false)
	{
		if (!Left4Bots.Settings.keep_holding_position)
		{
			Convars.SetValue("sb_hold_position", 0);
			Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
			if (Left4Bots.Settings.wait_crouch)
				Convars.SetValue("sb_crouch", 0);
		}
		
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (!bot.IsValid() || id == survivor.GetPlayerUserId())
				continue;
			
			local dist = (bot.GetOrigin() - special.GetOrigin()).Length();
			local held = bot.GetActiveWeapon();
			
			//if (isCharger || (bot.GetOrigin() - survivor.GetOrigin()).Length() > ATTACK_SI_MIN_DISTANCE)
			/*
			if (dist > ATTACK_SI_MIN_DISTANCE && dist < ATTACK_SI_MAX_DISTANCE && held && held.GetClassname() != "weapon_melee" && held.GetClassname() != "weapon_chainsaw")
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " ATTACK " + special.GetPlayerName());
				
				Left4Utils.BotCmdAttack(bot, special);
			}
			*/
			Left4Utils.BotCmdAttack(bot, special);
		}
	}
	
	::Left4Bots.TryDodgeChargerEnd <- function (bot, charger)
	{
		if (!bot || !bot.IsValid())
			return;
		
		Left4Bots.BotReset(bot, true);
		
		if (charger && charger.IsValid() && !charger.IsDead() && !charger.IsDying())
			Left4Utils.BotCmdAttack(bot, charger);
	}
	
	::Left4Bots.TryDodgeCharger <- function (bot, charger, leftVector, goLeft, travelDistance = 100, maxTravelDistance = 600)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - bot: " + bot.GetPlayerName() + " - goLeft: " + goLeft);
		
		local startArea = NavMesh.GetNavArea(bot.GetCenter(), 300);
		
		local dest;
		if (goLeft)
			dest = bot.GetCenter() - (leftVector * travelDistance);
		else
			dest = bot.GetCenter() + (leftVector * (travelDistance + 40));
		
		local destArea =  NavMesh.GetNavArea(dest, 300);
		if (destArea && destArea.IsValid())
		{
			local d = NavMesh.NavAreaTravelDistance(startArea, destArea, maxTravelDistance);
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - bot: " + bot.GetPlayerName() + " - d: " + d);
			
			if (d >= 0)
			{
				Left4Bots.Log(LOG_LEVEL_INFO, bot.GetPlayerName() + " trying to dodge charger");
				
				Left4Utils.BotCmdMove(bot, dest);
				Left4Timers.AddTimer(null, 2.0, @(params) Left4Bots.TryDodgeChargerEnd(params.bot, params.charger), { bot = bot, charger = charger });
				return;
			}
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - bot: " + bot.GetPlayerName() + " - nav area not found");
		
		// Preferred direction failed, let's try the other one
		if (goLeft)
			dest = bot.GetCenter() + (leftVector * travelDistance);
		else
			dest = bot.GetCenter() - (leftVector * (travelDistance + 40));
		
		local destArea =  NavMesh.GetNavArea(dest, 300);
		if (destArea && destArea.IsValid())
		{
			local d = NavMesh.NavAreaTravelDistance(startArea, destArea, maxTravelDistance);
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - bot: " + bot.GetPlayerName() + " - d: " + d);
			
			if (d >= 0)
			{
				Left4Bots.Log(LOG_LEVEL_INFO, bot.GetPlayerName() + " trying to dodge charger");
				
				Left4Utils.BotCmdMove(bot, dest);
				Left4Timers.AddTimer(null, 2.0, @(params) Left4Bots.TryDodgeChargerEnd(params.bot, params.charger), { bot = bot, charger = charger });
				return;
			}
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - bot: " + bot.GetPlayerName() + " - nav area not found");
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.TryDodgeCharger - failed!");
	}
	
	::Left4Bots.OnChargerChargeStart <- function (charger, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnChargerChargeStart - charger: " + charger.GetPlayerName());
		
		if (Left4Bots.Settings.dodge_charger)
		{
			foreach (bot in ::Left4Bots.Bots)
			{
				if (bot && bot.IsValid() && !bot.IsDead() && !bot.IsDying() && !bot.IsIncapacitated() && NetProps.GetPropInt(bot, "m_reviveTarget") <= 0 && NetProps.GetPropInt(bot, "m_iCurrentUseAction") <= 0 && (charger.GetOrigin() - bot.GetOrigin()).Length() <= 1200 /*&& Left4Utils.CanTraceTo(bot, charger)*/ && !Left4Utils.IsPlayerHeld(bot))
				{
					local facing = charger.EyeAngles().Forward();
					local toBot = bot.GetCenter() - charger.GetCenter();
					
					facing.Norm();
					toBot.Norm();
					
					local d = Left4Utils.GetDiffAngle(Left4Utils.VectorAngles(toBot).y, Left4Utils.VectorAngles(facing).y);
					
					// d must be between -15 and 15. d > 0 -> the bot should face the charger's left. d < 0 -> the bot should face the charger's right
					if (d >= -15 && d <= 15)
						Left4Bots.TryDodgeCharger(bot, charger, charger.EyeAngles().Left(), d > 0);
				}
			}
		}
	}
	
	::Left4Bots.OnChargerCarryStart <- function (charger, victim, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnChargerCarryStart - charger: " + charger.GetPlayerName() + " - victim: " + victim.GetPlayerName());
		
		Left4Bots.SpecialGotSurvivor(victim, charger, true);
	}
	
	::Left4Bots.OnChargerPummelStart <- function (charger, victim, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnChargerPummelStart - charger: " + charger.GetPlayerName() + " - victim: " + victim.GetPlayerName());
		
		Left4Bots.SpecialGotSurvivor(victim, charger, true);
	}
	
	::Left4Bots.OnSmokerTongueGrab <- function (smoker, victim, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnSmokerTongueGrab - smoker: " + smoker.GetPlayerName() + " - victim: " + victim.GetPlayerName());
		
		Left4Bots.SpecialGotSurvivor(victim, smoker);
	}
	
	::Left4Bots.OnJockeyRide <- function (jockey, victim, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnJockeyRide - jockey: " + jockey.GetPlayerName() + " - victim: " + victim.GetPlayerName());
		
		Left4Bots.SpecialGotSurvivor(victim, jockey);
	}
	
	::Left4Bots.OnHunterPounce <- function (hunter, victim, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnHunterPounce - hunter: " + hunter.GetPlayerName() + " - victim: " + victim.GetPlayerName());
		
		Left4Bots.SpecialGotSurvivor(victim, hunter);
	}
	
	::Left4Bots.OnSpitBurst <- function (spitter, spit, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnSpitBurst - spitter: " + spitter.GetPlayerName());
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot.IsValid())
				Left4Bots.BotEscapeFromSpitterSpit(bot, spit);
		}
		
		if (Left4Bots.Settings.spit_block_nav)
			Left4Timers.AddTimer(null, 3.8, Left4Bots.SpitterSpitBlockNav, { spit_ent = spit });
	}
	
	::Left4Bots.OnWeaponFired <- function (player, weapon, params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnWeaponFired - player: " + player.GetPlayerName() + " - weapon: " + weapon);
		
		if (weapon == "pipe_bomb" || weapon == "vomitjar")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " threw " + weapon);
			
			Left4Bots.LastNadeTime = Time();
		}
		else if (weapon == "molotov")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " threw " + weapon);
			
			Left4Bots.LastMolotovTime = Time();
		}
	}
	
	::Left4Bots.OnPlayerEnteredCheckpoint <- function (player, door, doorname, area, params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerEnteredCheckpoint - player: " + player.GetClassname() + " - door: " + door + " - doorname: " + doorname + " - area: " + area);
		
		if (!Left4Bots.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
		
		Left4Bots.SurvivorsEnteredCheckpoint++;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "SurvivorsEnteredCheckpoint: " + Left4Bots.SurvivorsEnteredCheckpoint);
		
		if (Left4Bots.Settings.close_saferoom_door && door && door.IsValid() && IsPlayerABot(player) && Left4Bots.SurvivorsEnteredCheckpoint >= Left4Bots.Survivors.len())
		{
			DoEntFire("!self", "Close", "", Left4Bots.Settings.close_saferoom_delay, player, door);
			//DoEntFire("!self", "Use", "", Left4Bots.Settings.close_saferoom_delay, player, door);
			
			Left4Utils.BotLookAt(player, door, 0, 0);
		}
	}
	
	::Left4Bots.OnPlayerLeftCheckpoint <- function (player, area, params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerLeftCheckpoint - player: " + player.GetClassname() + " - area: " + area);
		
		if (!Left4Bots.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
		
		Left4Bots.SurvivorsEnteredCheckpoint--;
		if (Left4Bots.SurvivorsEnteredCheckpoint < 0)
			Left4Bots.SurvivorsEnteredCheckpoint = 0;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "SurvivorsEnteredCheckpoint: " + Left4Bots.SurvivorsEnteredCheckpoint);
	}
	
	/*
	::Left4Bots.BotEscapeFromTankRock <- function (bot, tank, targetPos)
	{
		local p = bot.GetOrigin();

		local i = 0;
		while (i < 6 && (p - targetPos).Length() <= 180)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + ".TryGetPathableLocationWithin - i = " + i);
			p = bot.TryGetPathableLocationWithin(180 + 150);
			i++;
		}

		if (i == 0)
			return; // No need to move

		if (Convars.GetFloat("sb_hold_position") != 0 && !Left4Bots.Settings.keep_holding_position)
		{
			// Stop holding position if one or more bots are are going to be hit by the tank's rock
			Convars.SetValue("sb_hold_position", 0);
			Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
			if (Left4Bots.Settings.wait_crouch)
				Convars.SetValue("sb_crouch", 0);
		}
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " dodging rock");
		
		Left4Utils.BotCmdMove(bot, p);
		Left4Timers.AddTimer(null, 3, @(params) Left4Bots.BotReset(params.bot, params.force), { bot = bot, force = true });
	}
	*/

	::Left4Bots.L4B_RockThink <- function ()
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "L4B_RockThink");
		
		//Delay = 0.1;
		
		foreach (id, bot in ::Left4Bots.Bots)
		{
			//if (bot.IsValid() && Left4Utils.CanTraceTo(bot, rock, TRACE_MASK_ALL))
			//if (bot.IsValid() && (self.GetCenter() - bot.EyePosition()).Length() <= Left4Bots.Settings.rock_shoot_range)
			if (bot.IsValid() && (self.GetCenter() - bot.EyePosition()).Length() <= Left4Bots.Settings.rock_shoot_range && NetProps.GetPropInt(bot, "m_reviveTarget") <= 0 && NetProps.GetPropInt(bot, "m_iCurrentUseAction") <= 0)
			{
				Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, self.GetCenter(), 0, 0, true);
			
				Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " shooting at rock " + self.GetEntityIndex());
				
				//Delay = 0.4;
			}
		}
	
		return Delay;
	}

	::Left4Bots.OnRockThrow <- function (params)
	{
		local tank = params["tank"];
		if (!tank || !tank.IsValid())
		{
			Left4Bots.Log(LOG_LEVEL_ERROR, "Left4Bots.OnRockThrow - tank is null!!!");
			return;
		}

		local rock = Entities.FindByClassnameNearest("tank_rock", tank.EyePosition(), 160);
		if (rock && rock.IsValid())
		{
			rock.ValidateScriptScope();
			local scope = rock.GetScriptScope();
		
			scope.Tank <- tank;
			//scope.Target <- target;
			scope.Delay <- 0.15;
		
			scope["L4B_RockThink"] <- ::Left4Bots.L4B_RockThink;

			AddThinkToEnt(rock, "L4B_RockThink");
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnRockThrow - Tank's rock not found!");
	}
	
	::Left4Bots.OnPlayerJump <- function (player, params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerJump - player: " + player.GetPlayerName());
		
		if (RandomInt(1, 100) > Left4Bots.Settings.special_shove_chance)
			return;
		
		local z = NetProps.GetPropInt(player, "m_zombieClass");
		if (z != Z_HUNTER && z != Z_JOCKEY)
			return;
		
		local victim = NetProps.GetPropEntity(player, "m_lookatPlayer");
		if (!victim || !victim.IsValid() || !victim.IsPlayer() || !("IsSurvivor" in victim) || !victim.IsSurvivor() || !IsPlayerABot(victim))
			return;
		
		local d = (victim.GetOrigin() - player.GetOrigin()).Length();
	
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerJump - " + player.GetPlayerName() + " -> " + victim.GetPlayerName() + " - " + d);
		
		if (d > 700) // Too far, no point shoving
			return;
		
		if (d <= 150)
			Left4Bots.BotShove2(victim, player);
		else
			Left4Timers.AddTimer(null, 0.001 * d, @(params) Left4Bots.BotShove2(params.bot, params.attacker), { bot = victim, attacker = player });
	}
	
	::Left4Bots.OnAbilityUse <- function (player, ability, context, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnAbilityUse - player: " + player.GetPlayerName() + " - ability: " + ability + " - context: " + context);
		
		if (ability == "ability_throw")
		{
			if (Left4Bots.Settings.rock_shoot_range > 0)
				Left4Timers.AddTimer(null, 1.9, Left4Bots.OnRockThrow, { tank = player }, false);
			
			local target = NetProps.GetPropEntity(player, "m_lookatPlayer");
			if (target && target.IsValid() && IsPlayerABot(target))
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnAbilityUse - " + target.GetPlayerName() + " RETREAT from rock");
				
				Left4Utils.BotCmdRetreat(target, player);
			}
		}
	}
	
	::Left4Bots.OnWeaponCantUseAmmo <- function (player, params)
	{
		local pWeapon = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_PRIMARY);
		if (!pWeapon || !pWeapon.IsValid())
			return;
		
		local cWeapon = pWeapon.GetClassname();
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnWeaponCantUseAmmo - player: " + player.GetPlayerName() + " - weapon: " + cWeapon);
		
		if (cWeapon == "weapon_grenade_launcher" || cWeapon == "weapon_rifle_m60")
		{
			if ((IsPlayerABot(player) && Left4Bots.Settings.t3_ammo_bots) || (!IsPlayerABot(player) && Left4Bots.Settings.t3_ammo_human))
			{
				//player.GiveAmmo(10000);

				local ammoType = NetProps.GetPropInt(pWeapon, "m_iPrimaryAmmoType");
				local maxAmmo = Left4Utils.GetMaxAmmo(ammoType);
				NetProps.SetPropIntArray(player, "m_iAmmo", maxAmmo + (pWeapon.GetMaxClip1() - pWeapon.Clip1()), ammoType);

				Left4Bots.Log(LOG_LEVEL_INFO, "OnWeaponCantUseAmmo - player: " + player.GetPlayerName() + " ammo replenished for T3 weapon " + cWeapon);
			}
		}
	}
	
	::Left4Bots.OnDoorClose <- function (player, checkpoint, params)
	{
		if (player && player.IsValid())
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDoorClose - player: " + player.GetPlayerName() + " - checkpoint: " + checkpoint);
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnDoorClose - player: NULL - checkpoint: " + checkpoint);
		
		if (checkpoint && Director.IsAnySurvivorInExitCheckpoint() && Left4Bots.Settings.anti_pipebomb_bug && Left4Bots.SurvivorsEnteredCheckpoint >= Left4Bots.Survivors.len())
		{
			Left4Bots.ClearPipeBombs();
			
			// If someone is holding a pipe bomb i also force them to switch to another weapon to make sure they don't throw the bomb while the door is closing
			foreach (surv in ::Left4Bots.Survivors)
			{
				local activeWeapon = surv.GetActiveWeapon();
				if (activeWeapon && activeWeapon.GetClassname() == "weapon_pipe_bomb")
					Left4Bots.BotSwitchToAnotherWeapon(surv);
			}
		}
	}
	
	::Left4Bots.GetManualOrdersStartedFrom <- function (player)
	{
		local ret = {};
		local time = Time();
		foreach (id, order in Left4Bots.ManualOrders)
		{
			if (order.from && order.from.IsValid() && order.from.GetPlayerUserId() == player.GetPlayerUserId() && order.dest == null && (time - order.stime) < MANUAL_ORDER_MAXTIME)
			{
				local bot = Left4Bots.GetBotByUserid(id);
				if (bot && bot.IsValid())
					ret[id] <- order;
			}
		}
		return ret;
	}
	
	::Left4Bots.ManualOrderEnd <- function (player, target, targetPos, orderType, canPause = true, answer = "PlayerYes", holdTime = null)
	{
		if (!target || !target.IsValid())
			return false;
		
		local ok = false;
		local time = Time();
		foreach (id, order in Left4Bots.ManualOrders)
		{
			if (order.from && order.from.IsValid() && order.from.GetPlayerUserId() == player.GetPlayerUserId() && order.dest == null)
			{
				if ((time - order.stime) > MANUAL_ORDER_MAXTIME)
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order from " + player.GetPlayerName() + " for bot with id " + id + " has expired and will be deleted");
					
					delete ::Left4Bots.ManualOrders[id];
				}
				else
				{
					local bot = Left4Bots.GetBotByUserid(id);
					if (!bot || !bot.IsValid())
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order from " + player.GetPlayerName() + " for bot with id " + id + " has an invalid bot and will be deleted");
					
						delete ::Left4Bots.ManualOrders[id];
					}
					else
					{
						DoEntFire("!self", "SpeakResponseConcept", answer, RandomFloat(1.5, 2), null, bot);
					
						order.ordertype = orderType;
						order.canpause = canPause;
						order.dest = target;
						order.pos = targetPos;
						
						if (holdTime)
							order.holdtime <- holdTime;
					
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + player.GetPlayerName() + " to bot " + bot.GetPlayerName() + " - destination: " + target.GetClassname());
						
						ok = true;
					}
				}
			}
		}
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order end, new count: " + Left4Bots.ManualOrders.len());
		
		return ok;
	}
	
	::Left4Bots.CheckBotPickup <- function (bot, item)
	{
		if (!bot || !bot.IsValid() || (bot.GetHealth() + bot.GetHealthBuffer()) < 50)
			return;
			
		local activeWeapon = bot.GetActiveWeapon();
		if (activeWeapon && activeWeapon.GetClassname() == item)
			Left4Bots.BotSwitchToAnotherWeapon(bot);
	}

	::Left4Bots.HoldItemThink <- function ()
	{
		if (NetProps.GetPropInt(self, "m_hOwner") <= 0)
		{
			//printl("HoldItemModel: " + HoldItemModel);
			
			local ent = null;
			while (ent = Entities.FindByModel(ent, HoldItemModel))
			{
				if (ent.GetClassname() == "prop_physics" && (ent.GetOrigin() - self.GetOrigin()).Length() <= 70 && NetProps.GetPropInt(ent, "m_hOwner") <= 0)
				{
					Left4Bots.OnWeaponDrop(HoldItemOwner, self, ent);
					break;
				}
			}
		}
		
		return 0.001
	}

	::Left4Bots.OnItemPickup <- function (player, item, params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnItemPickup - player: " + player.GetPlayerName() + " - " + item);

		// Update the count of medkits and defibrillators in the team
		local kits = 0;
		local defs = 0;
		foreach (surv in ::Left4Bots.Survivors)
		{
			local item = Left4Utils.GetInventoryItemInSlot(surv, INV_SLOT_MEDKIT);
			if (item && item.IsValid())
			{
				if (item.GetClassname() == "weapon_first_aid_kit")
					kits++;
				else if (item.GetClassname() == "weapon_defibrillator")
					defs++;
			}
		}
		Left4Bots.Team_Medkits = kits;
		Left4Bots.Team_Defibs = defs;
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Team_Medkits: " + Left4Bots.Team_Medkits + " - Team_Defibs: " + Left4Bots.Team_Defibs);

		if (!IsPlayerABot(player))
			return;

		if (::Left4Bots.Settings.hold_items)
		{
			local aw = player.GetActiveWeapon();
			if (aw && aw.IsValid() && (aw.GetClassname() in ::Left4Bots.HoldItems))
			{
				local scope = player.GetScriptScope();
				if ("LastUseTS" in scope && (Time() - scope.LastUseTS) <= 0.5)
				{
					scope.HoldItem <- aw;
						
					if (!Left4Utils.IsButtonDisabled(player, BUTTON_ATTACK))
					{
						Left4Utils.PlayerDisableButton(player, BUTTON_ATTACK | BUTTON_USE);
							
						local w = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_PRIMARY);
						if (w)
							NetProps.SetPropEntity(w, "m_hOwner", null); // This prevents the bot from switching to this weapon (and dropping the held item)
						w = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_SECONDARY);
						if (w)
							NetProps.SetPropEntity(w, "m_hOwner", null);
							
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnItemPickup - " + player.GetPlayerName() + " started holding " + aw.GetClassname());
					}
					
					local model = "";
					if (aw.GetClassname() == "weapon_gnome")
						model = "models/props_junk/gnome.mdl";
					//else if (aw.GetClassname() == "weapon_gascan")
					//	model = "models/props_junk/gascan001a.mdl";
					else if (aw.GetClassname() == "weapon_propanetank")
						model = "models/props_junk/propanecanister001a.mdl";
					else if (aw.GetClassname() == "weapon_oxygentank")
						model = "models/props_equipment/oxygentank01.mdl";
					else if (aw.GetClassname() == "weapon_fireworkcrate")
						model = "models/props_junk/explosive_box001.mdl";
					
					aw.ValidateScriptScope();
					local wScope = aw.GetScriptScope();
					wScope["HoldItemOwner"] <- player;
					wScope["HoldItemModel"] <- model;
					wScope["HoldItemThink"] <- ::Left4Bots.HoldItemThink;
					AddThinkToEnt(aw, "HoldItemThink");
				}
			}
		}
		
		if (item == "pain_pills" || item == "adrenaline")
		{
			Left4Timers.AddTimer(null, 1, @(params) Left4Bots.CheckBotPickup(params.bot, params.item), { bot = player, item = "weapon_" + item });
			return;
		}
		
		// a prop_physics cola becomes weapon_cola_bottles the first time it gets picked up so i do the switch in the order before ScavengeManager marks it as invalid
		if (item == "cola_bottles")
		{
			local id = player.GetPlayerUserId();
			local wp = player.GetActiveWeapon();
			
			if ((id in Left4Bots.ScavengeOrders) && wp && wp.GetClassname() == "weapon_cola_bottles")
				Left4Bots.ScavengeOrders[id] <- wp;
			
			return;
		}
	}
	
	::Left4Bots.OnWeaponDrop <- function (player, weapon, new_repick = null)
	{
		local p = "";
		local w = "";
		
		if (player && player.IsValid())
			p = player.GetPlayerName();
		
		if (weapon && weapon.IsValid())
			w = weapon.GetClassname();
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "OnWeaponDrop - " + p + " - " + w);
		
		if (p != "")
		{
			player.ValidateScriptScope();
			local scope = player.GetScriptScope();
			if (("HoldItem" in scope) && scope.HoldItem && scope.HoldItem == weapon)
			{
				if (new_repick)
					Left4Timers.AddTimer(null, 0.5, Left4Bots.RePickupHoldItem, { player = player, weapon = new_repick });
				else
					Left4Timers.AddTimer(null, 0.5, Left4Bots.RePickupHoldItem, { player = player, weapon = weapon });
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "OnWeaponDrop - " + p + " re-pickup " + w);
				
				Left4Bots.HoldItemStop(player);
			}
		}
		
		if (Left4Bots.Settings.kill_empty_chainsaw && w == "weapon_chainsaw" && NetProps.GetPropInt(weapon, "m_iClip1") <= 0)
			weapon.Kill();
	}
	
	::Left4Bots.RePickupHoldItem <- function (params)
	{
		local player = params["player"];
		if (!player || !player.IsValid() || !IsPlayerABot(player))
			return;
		
		local weapon = params["weapon"];
		if (!weapon || !weapon.IsValid() || NetProps.GetPropInt(weapon, "m_hOwner") > 0)
			return;
		
		if (Left4Utils.IsPlayerHeld(player) || player.IsIncapacitated() || player.IsDead() || player.IsDying())
			return;
		
		local aw = player.GetActiveWeapon();
		if (aw && aw.IsValid())
		{
			local wSlot = Left4Utils.FindSlotForItemClass(player, aw.GetClassname());
			if (wSlot != INV_SLOT_PRIMARY && wSlot != INV_SLOT_SECONDARY)
			{
				Left4Timers.AddTimer(null, 0.5, Left4Bots.RePickupHoldItem, { player = player, weapon = weapon }); // Retry later
				return;
			}
		}
		
		local scope = player.GetScriptScope();
		scope.LastUseTS <- Time();
		
		DoEntFire("!self", "Use", "", 0, player, weapon);
	}
	
	::Left4Bots.NearestBotWithMedkit <- function (target)
	{
		local ret = null;
		local dist = 1000000;
		local survs = Left4Utils.GetAliveSurvivorBots();
		foreach (surv in survs)
		{
			if (!surv.IsIncapacitated() && Left4Utils.HasMedkit(surv))
			{
				local d = (surv.GetOrigin() - target.GetOrigin()).Length();
				if (d < dist)
				{
					ret = surv;
					dist = d;
				}
			}
		}
		return ret;
	}
	
	Left4Bots.GetTierFromWeaponId <- function (weaponId)
	{
		local tier1 = [2, 3, 7, 8, 33];
		local tier2 = [4, 5, 6, 9, 10, 11, 26, 34, 35, 36];
		local tier3 = [21, 37]; // GL, M60
		
		/*
			FIRST_AID_KIT,    // 12
			DEFIBRILLATOR,    // 24

			PAIN_PILLS,       // 15
			ADRENALINE,       // 23
			
			MOLOTOV,          // 13
			PIPE_BOMB,        // 14
			VOMITJAR,         // 25
			
			CHAINSAW,         // 20
		*/
		
		if (tier1.find(weaponId) != null)
			return 1;
		else if (tier2.find(weaponId) != null)
			return 2;
		else if (tier3.find(weaponId) != null)
			return 3;
		else
			return 0;
	}
	
	Left4Bots.GetTierFromWeaponClass <- function (weaponClass)
	{
		local tier1 = ["weapon_smg", "weapon_pumpshotgun", "weapon_smg_silenced", "weapon_shotgun_chrome", "weapon_smg_mp5"];
		local tier2 = ["weapon_autoshotgun", "weapon_rifle", "weapon_hunting_rifle", "weapon_rifle_desert", "weapon_sniper_military", "weapon_shotgun_spas", "weapon_rifle_ak47", "weapon_rifle_sg552", "weapon_sniper_awp", "weapon_sniper_scout"];
		local tier3 = ["weapon_grenade_launcher", "weapon_rifle_m60"];
		
		if (tier1.find(weaponClass) != null)
			return 1;
		else if (tier2.find(weaponClass) != null)
			return 2;
		else if (tier3.find(weaponClass) != null)
			return 3;
		else
			return 0;
	}
	
	Left4Bots.HumansNeedAmmo <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying())
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist && Left4Utils.GetPrimaryAmmoPercent(surv) < 85.0)
					return true;
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedWeapon <- function (srcBot, weaponId, minDist = 250.0, maxDist = 2500.0)
	{
		local tier = Left4Bots.GetTierFromWeaponId(weaponId);
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.HumansNeedWeapon - weaponId: " + weaponId + " - tier: " + tier);
		
		if (tier <= 0)
			return false;
		
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying())
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
				{
					local w = Left4Utils.GetInventoryItemInSlot(surv, INV_SLOT_PRIMARY);
					if (!w || !w.IsValid())
						return true;
					
					local wt = Left4Bots.GetTierFromWeaponClass(w.GetClassname())
					
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.HumansNeedWeapon - w: " + w.GetClassname() + " - wt: " + wt);
				
					if (wt < tier)
						return true;
				}
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedMedkit <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying())
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
				{
					// TODO?
					
					return true;
				}
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedTempMed <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying() && Left4Utils.GetInventoryItemInSlot(surv, INV_SLOT_PILLS) == null)
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
					return true;
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedThrowable <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying() && Left4Utils.GetInventoryItemInSlot(surv, INV_SLOT_THROW) == null)
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
					return true;
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedUpgradeAmmo <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying())
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
				{
					// TODO?
					
					return true;
				}
			}
		}
		return false;
	}
	
	Left4Bots.HumansNeedLaserSight <- function (srcBot, minDist = 250.0, maxDist = 2500.0)
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && !IsPlayerABot(surv) && !surv.IsDead() && !surv.IsDying() && !Left4Utils.HasLaserSight(surv))
			{
				local d = (surv.GetOrigin() - srcBot.GetOrigin()).Length();
				if (d >= minDist && d <= maxDist)
					return true;
			}
		}
		return false;
	}
	
	Left4Bots.GetOtherMedkitSpawn <- function (srcSpawn, radius = 100.0)
	{
		local ent = null;
		while (ent = Entities.FindByClassnameWithin(ent, "weapon_first_aid_kit_spawn", srcSpawn.GetOrigin(), radius))
		{
			if (ent.IsValid() && ent.GetEntityIndex() != srcSpawn.GetEntityIndex() && Left4Bots.SpawnerHasItems(ent))
				return ent;
		}
		return null;
	}
	
	::Left4Bots.SpawnerHasItems <- function (spawner_ent, minCount = 0)
	{
		// Note: m_itemCount has already been decreased by 1 when OnPlayerUse is triggered (but not when it's called from PickupFailsafe)
		
		local m_itemCount = NetProps.GetPropInt(spawner_ent, "m_itemCount");
		local m_spawnflags = NetProps.GetPropInt(spawner_ent, "m_spawnflags");
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.SpawnerHasItems - " + spawner_ent.GetClassname() + " - m_itemCount: " + m_itemCount + " - m_spawnflags: " + m_spawnflags + " - minCount: " + minCount);
		
		// item count > 0 or infinite items in spawn flags
		return (m_itemCount > minCount || (m_spawnflags & 8) == 8);
	}
	
	::Left4Bots.OnPlayerUse <- function (player, entity, minCount = 0)
	{
		if (player == null || !player.IsValid() || entity == null || !entity.IsValid())
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerUse - " + player.GetPlayerName() + " -> " + entity.GetClassname());
		
		if (Left4Bots.Settings.signal_max_distance <= 0 || !IsPlayerABot(player))
			return;
		
		switch (entity.GetClassname())
		{
			case "weapon_ammo_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedAmmo(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "Ammo", "Ammo here!");
				
				break;
			}
			
			/* better handled in default:
			case "weapon_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedWeapon(player, NetProps.GetPropInt(entity, "m_weaponID"), Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotOtherWeapon", null, "Weapons here!");

				break;
			}
			*/
			
			case "weapon_first_aid_kit_spawn":
			{
				local other = Left4Bots.GetOtherMedkitSpawn(entity, 100.0);
				if (other && Left4Bots.HumansNeedMedkit(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, other, "PlayerSpotWeapon", "FirstAidKit", "Medkits here!");
				
				break;
			}
			
			case "weapon_pain_pills_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedTempMed(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "PainPills", "Pills here!");
				
				break;
			}
			
			case "weapon_adrenaline_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedTempMed(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "Adrenaline", "Adrenaline here!");
				
				break;
			}
			
			case "weapon_molotov_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedThrowable(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "Molotov", "Molotovs here!");
				
				break;
			}
			
			case "weapon_pipe_bomb_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedThrowable(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "PipeBomb", "Pipe bombs here!");
				
				break;
			}
			
			case "weapon_vomitjar_spawn":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedThrowable(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "VomitJar", "Bile jars here!");
				
				break;
			}
			
			case "upgrade_ammo_incendiary":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedUpgradeAmmo(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "UpgradePack_Incendiary", "Incendiary ammo here!");
				
				break;
			}
			
			case "upgrade_ammo_explosive":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedUpgradeAmmo(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "UpgradePack_Explosive", "Explosive ammo here!");
				
				break;
			}
			
			case "upgrade_laser_sight":
			{
				if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedLaserSight(player, Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
					Left4Bots.DoSignal(player, entity, "PlayerSpotWeapon", "LaserSights", "Laser sights here!");
				
				break;
			}
			
			default:
			{
				if (entity.GetClassname().find("weapon_") != null && entity.GetClassname().find("_spawn") != null)
				{
					if (Left4Bots.SpawnerHasItems(entity, minCount) && Left4Bots.HumansNeedWeapon(player, NetProps.GetPropInt(entity, "m_weaponID"), Left4Bots.Settings.signal_min_distance, Left4Bots.Settings.signal_max_distance))
						Left4Bots.DoSignal(player, entity, "PlayerSpotOtherWeapon", null, "Weapons here!");
				}
			}
		}
	}
	
	::Left4Bots.DoSignal <- function (who, what, concept, weaponname = null, chatText = null)
	{
		local signalType = concept;
		if (weaponname)
			signalType = signalType + ":" + weaponname;
		
		local t = Time();
		if (Left4Bots.LastSignalType == signalType && (t - Left4Bots.LastSignalTime) <= Left4Bots.Settings.signal_min_interval)
			return;
		
		Left4Bots.LastSignalType = signalType;
		Left4Bots.LastSignalTime = t;
		
		if (weaponname)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.DoSignal - " + who.GetPlayerName() + " -> " + what.GetClassname() + " - " + concept + " - " + weaponname);
			
			//DoEntFire("!self", "AddContext", "subject:" + actor, 0, null, who);
			DoEntFire("!self", "AddContext", "weaponname:" + weaponname, 0, null, who);
			DoEntFire("!self", "SpeakResponseConcept", concept, 0, null, who);
			DoEntFire("!self", "ClearContext", "", 0, null, who);
		}
		else
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.DoSignal - " + who.GetPlayerName() + " -> " + what.GetClassname() + " - " + concept);
			
			DoEntFire("!self", "SpeakResponseConcept", concept, 0, null, who);
		}
		
		if (Left4Bots.Settings.signal_chat && chatText)
			Say(who, chatText, true);
		
		if (Left4Bots.L4F && Left4Bots.Settings.signal_ping)
			Left4Fun.PingEnt(who, what);
	}
	
	::Left4Bots.OnPlayerSay <- function (player, text, args, params)
	{
		if (player == null || !player.IsValid() || IsPlayerABot(player) || args.len() < 2)
			return false;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnPlayerSay - " + player.GetPlayerName() + ": " + text);
		
		if (!Left4Bots.Settings.user_can_command_bots && !Left4Bots.IsOnlineAdmin(player))
			return false;
		
		local arg0 = args[0].tolower();
		local arg1 = args[1].tolower();
		
		if (arg0 == "bots")
		{
			if (arg1 == "heal")
			{
				local tgt = null;
				if (args.len() > 2)
				{
					local tgtName = args[2].tolower();
					if (tgtName == "me")
						tgt = player;
					else
						tgt = Left4Utils.GetPlayerFromName(tgtName);
				}
				
				if (tgt)
				{
					local bot = Left4Bots.NearestBotWithMedkit(tgt);
					if (bot)
						Left4Bots.BotOrder("heal", player, bot, tgt);
				}
				else
				{
					foreach (id, bot in ::Left4Bots.Bots)
						Left4Bots.BotOrder("heal", player, bot);
				}
				
				return true;
			}
			else if (arg1 == "healme")
			{
				local bot = Left4Bots.NearestBotWithMedkit(player);
				if (bot)
					Left4Bots.BotOrder("healme", player, bot);
				
				return true;
			}
			else if (arg1 == "tempheal")
			{
				foreach (id, bot in ::Left4Bots.Bots)
					Left4Bots.BotOrder("tempheal", player, bot);
				
				return true;
			}
			else if (arg1 == "warp")
			{
				foreach (id, bot in ::Left4Bots.Bots)
					Left4Bots.BotOrder("warp", player, bot);
				
				return true;
			}
			else if (arg1 == "throw")
			{
				if (args.len() > 2)
					return Left4Bots.BotOrder("throw", player, null, null, args[2].tolower());
				else
					return Left4Bots.BotOrder("throw", player, null);
			}
			else if (arg1 == "use")
			{
				local holdTime = null;
				if (args.len() > 2)
				{
					try
					{
						holdTime = args[2].tointeger();
					}
					catch(exception)
					{
						holdTime = null;
					}
				}
				
				foreach (id, bot in ::Left4Bots.Bots)
					Left4Bots.BotOrder("use", player, null, bot, holdTime);
				
				return true;
			}
			else if (arg1 == "witch")
			{
				return Left4Bots.BotOrder("witch", player);
			}
			else if (arg1 == "deploy")
			{
				foreach (id, bot in ::Left4Bots.Bots)
					Left4Bots.BotOrder("deploy", player, bot);
				
				return true;
			}
			else if (arg1 == "goto")
			{
				foreach (id, bot in ::Left4Bots.Bots)
					Left4Bots.BotOrder("goto", player, null, bot);
				
				return true;
			}
			else if (arg1 == "attack")
			{
				//foreach (id, bot in ::Left4Bots.Bots)
				//	Left4Bots.BotOrder("attack", player, bot);
				Left4Bots.BotOrder("attack", player);
				
				return true;
			}
			else if (arg1 == "die" && Left4Bots.IsOnlineAdmin(player) && (Left4Bots.Settings.die_humans_alive || Left4Bots.Survivors.len() == Left4Bots.Bots.len()))
			{
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (!bot.IsDead() && !bot.IsDying() && !bot.IsIncapacitated())
						Left4Utils.IncapacitatePlayer(bot);
				}
				return true;
			}
			else
				return Left4Bots.BotOrder(arg1, player);
		}
		else if (arg1 == "lead" || arg1 == "leadon")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("lead", player, null, bot);
		}
		else if (arg1 == "witch")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("witch", player, null, bot);
		}
		else if (arg1 == "heal")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
			{
				local tgt = null;
				if (args.len() > 2)
				{
					local tgtName = args[2].tolower();
					if (tgtName == "me")
						tgt = player;
					else
					{
						tgt = Left4Utils.GetPlayerFromName(tgtName);
						if (!tgt)
							return false;
					}
				}
				
				return Left4Bots.BotOrder("heal", player, bot, tgt);
			}
		}
		else if (arg1 == "healme")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("healme", player, bot);
		}
		else if (arg1 == "tempheal")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("tempheal", player, bot);
		}
		else if (arg1 == "warp")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("warp", player, bot);
		}
		else if (arg1 == "throw")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
			{
				if (args.len() > 2)
					return Left4Bots.BotOrder("throw", player, bot, null, args[2].tolower());
				else
					return Left4Bots.BotOrder("throw", player, bot);
			}
		}
		else if (arg1 == "swap")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("swap", player, bot);
		}
		else if (arg1 == "deploy")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("deploy", player, bot);
		}
		else if (arg1 == "give")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("give", player, bot);
		}
		else if (arg1 == "use")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
			{
				local holdTime = null;
				if (args.len() > 2)
				{
					try
					{
						holdTime = args[2].tointeger();
					}
					catch(exception)
					{
						holdTime = null;
					}
				}
				
				Left4Bots.BotOrder("use", player, null, bot, holdTime);
				
				return true;
			}
		}
		else if (arg1 == "goto")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("goto", player, null, bot);
		}
		else if (arg1 == "attack")
		{
			local bot = Left4Bots.GetBotByName(arg0);
			if (bot != null)
				return Left4Bots.BotOrder("attack", player, null, bot);
		}
		else if (arg0 == "!l4bsettings" && Left4Bots.IsOnlineAdmin(player))
		{
			if (arg1 in Left4Bots.Settings)
			{
				if (args.len() < 3)
					ClientPrint(player, 3, "\x01 Current value for " + arg1 + ": " + Left4Bots.Settings[arg1]);
				else
				{
					try
					{
						local value = args[2].tointeger();
						::Left4Bots.Settings[arg1] <- value;
						
						if (arg1 in ::Left4Bots.OnTankSettingsBak)
							::Left4Bots.OnTankSettingsBak[arg1] <- value;
						
						local trueSettings = clone ::Left4Bots.Settings;
						foreach (key, val in ::Left4Bots.OnTankSettingsBak)
							trueSettings[key] <- val;
						
						Left4Utils.SaveSettingsToFile("left4bots/cfg/settings.txt", trueSettings, Left4Bots.Log);
						
						if (arg1 == "should_hurry")
						{
							if (value)
							{
								DirectorScript.GetDirectorOptions().cm_ShouldHurry <- 1;
	
								Left4Bots.Log(LOG_LEVEL_DEBUG, "cm_ShouldHurry = 1");
							}
							else
							{
								DirectorScript.GetDirectorOptions().cm_ShouldHurry <- 0;
								
								//if ("cm_ShouldHurry" in DirectorScript.GetDirectorOptions())
								//	delete DirectorScript.GetDirectorOptions().cm_ShouldHurry;
								
								Left4Bots.Log(LOG_LEVEL_DEBUG, "cm_ShouldHurry = 0");
							}
						}
						
						ClientPrint(player, 3, "\x05 Changed value for " + arg1 + " to: " + value);
					}
					catch(exception)
					{
						Left4Bots.Log(LOG_LEVEL_ERROR, "Error changing settings value - option: " + arg1 + " - new value: " + args[2] + " - error: " + exception);
						ClientPrint(player, 3, "\x04 Error changing settings value for " + arg1);
					}
				}
			}
			else
				ClientPrint(player, 3, "\x04 Invalid settings option: " + arg1);
			
			return true;
		}
		
		return false;
	}
	
	::Left4Bots.RandomMoveAnswer <- function ()
	{
		local answers = ["PlayerYes", "PlayerImWithYou", "PlayerToTheRescue", "PlayerAnswerLostCall", "SurvivorBotYesReady"];
		return answers[RandomInt(0, answers.len() - 1)];
	}
	
	::Left4Bots.RandomYesAnswer <- function ()
	{
		local answers = ["PlayerYes", "SurvivorBotYesReady"];
		return answers[RandomInt(0, answers.len() - 1)];
	}
	
	::Left4Bots.GetBotByName <- function (name)
	{
		local n = name.tolower();
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot && bot.IsValid() && bot.GetPlayerName().tolower() == n)
				return bot;
		}
		return null;
	}
	
	::Left4Bots.GetSurvivorFromActor <- function (actor)
	{
		local ret = Left4Utils.GetSurvivorFromActor(actor);
		if (ret != null)
			return ret;
		
		switch (actor)
		{
			case "TeenGirl":
			{
				ret = Left4Bots.GetSurvivorByCharacter(EXTRA_S_ZOEY);
				if (ret == null)
					ret = Left4Bots.GetSurvivorByCharacter(S_ZOEY);
				break;
			}
			case "NamVet":
			{
				ret = Left4Bots.GetSurvivorByCharacter(EXTRA_S_BILL);
				if (ret == null)
					ret = Left4Bots.GetSurvivorByCharacter(S_BILL);
				break;
			}
			case "Manager":
			{
				ret = Left4Bots.GetSurvivorByCharacter(EXTRA_S_LOUIS);
				if (ret == null)
					ret = Left4Bots.GetSurvivorByCharacter(S_LOUIS);
				break;
			}
			case "Biker":
			{
				ret = Left4Bots.GetSurvivorByCharacter(EXTRA_S_FRANCIS);
				if (ret == null)
					ret = Left4Bots.GetSurvivorByCharacter(S_FRANCIS);
				break;
			}
			case "Gambler":
			{
				ret = Left4Bots.GetSurvivorByCharacter(S_NICK);
				break;
			}
			case "Producer":
			{
				ret = Left4Bots.GetSurvivorByCharacter(S_ROCHELLE);
				break;
			}
			case "Coach":
			{
				ret = Left4Bots.GetSurvivorByCharacter(S_COACH);
				break;
			}
			case "Mechanic":
			{
				ret = Left4Bots.GetSurvivorByCharacter(S_ELLIS);
				break;
			}
		}
		
		return ret;
	}
	
	::Left4Bots.FindNearestUsable <- function (orig, radius)
	{
		local ret = null;
		local minDist = 1000000;		
		local ent = null;
		while (ent = Entities.FindInSphere(ent, orig, radius))
		{
			// I don't know... i might be wrong but in my mind GetPropInt is faster than GetPropEntity
			//if (ent.IsValid() && NetProps.GetPropEntity(ent, "m_hOwner") == null)
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_hOwner") <= 0)
			{
				local dist = (ent.GetCenter() - orig).Length();
				local entClass = ent.GetClassname();
				if (dist < minDist && (entClass.find("weapon_") != null || entClass.find("prop_physics") != null || entClass.find("prop_minigun") != null || entClass.find("func_button") != null || (entClass.find("trigger_finale") != null && NetProps.GetPropInt(ent, "m_bDisabled") == 0) || entClass.find("prop_door_rotating") != null))
				{
					ret = ent;
					minDist = dist;
				}
			}
		}
		return ret;
	}
	
	::Left4Bots.FindNearestKillable <- function (orig, radius)
	{
		local ret = null;
		local minDist = 1000000;		
		local ent = null;
		while (ent = Entities.FindInSphere(ent, orig, radius))
		{
			if (ent.IsValid())
			{
				local dist = (ent.GetOrigin() - orig).Length();
				local entClass = ent.GetClassname();
				if (dist < minDist && (entClass == "player" || entClass == "infected"))
				{
					if (entClass == "infected")
					{
						if (NetProps.GetPropInt(ent, "m_lifeState") == 0) // still alive
						{
							ret = ent;
							minDist = dist;
						}
					}
					else if (!ent.IsDead() && !ent.IsDying()) // player
					{
						ret = ent;
						minDist = dist;
					}
				}
			}
		}
		return ret;
	}

	::Left4Bots.FindBotNearestKillable <- function (bot, radius)
	{
		local ret = null;
		local minDist = 1000000;		
		local ent = null;
		while (ent = Entities.FindInSphere(ent, bot.GetOrigin(), radius))
		{
			if (ent.IsValid())
			{
				local dist = (ent.GetOrigin() - bot.GetOrigin()).Length();
				local entClass = ent.GetClassname();
				if (dist < minDist && (entClass == "player" || entClass == "infected") && Left4Utils.CanTraceTo(bot, ent))
				{
					if (entClass == "infected")
					{
						if (NetProps.GetPropInt(ent, "m_lifeState") == 0) // still alive
						{
							ret = ent;
							minDist = dist;
						}
					}
					else if (NetProps.GetPropInt(ent, "m_iTeamNum") == TEAM_INFECTED && !ent.IsDead() && !ent.IsDying()) // player
					{
						ret = ent;
						minDist = dist;
					}
				}
			}
		}
		return ret;
	}

	::Left4Bots.DoHeal <- function (params)
	{
		local bot = params["bot"];
		if (!bot || !bot.IsValid())
			return;
		
		local aw = bot.GetActiveWeapon();
		if (aw && aw.GetClassname() == "weapon_first_aid_kit")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + bot.GetPlayerName() + " HEAL");
			
			Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_HEAL, null, 0, 0, true);
		}
		else
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + bot.GetPlayerName() + " HEAL aborted!");
	}
	
	::Left4Bots.BotOrder <- function (order, who, subject = null, botdest = null, param = null)
	{
		if (order == "lead" || order == "leadon")
		{
			if (botdest != null || Left4Bots.GetManualOrdersStartedFrom(who).len() > 0)
			{
				local target = Left4Bots.GetSaferoomDoor();
				if (!target)
					target = Left4Bots.GetNextPathStep(who);
				
				if (target)
				{
					if (botdest == null)
						Left4Bots.ManualOrderEnd(who, target, null, "lead", true, "PlayerFollowMe");
					else if (botdest.IsValid())
					{
						Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = target, pos = null, ordertype = "lead", canpause = true };
					
						DoEntFire("!self", "SpeakResponseConcept", "PlayerFollowMe", RandomFloat(1.5, 2), null, botdest);
					
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + botdest.GetPlayerName() + " - destination: " + target.GetClassname());

						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
					}
				}
				
				return true;
			}
			
			if (Left4Bots.MapName == "c7m1_docks")
			{
				if (Left4Bots.C7M1CanOpenTrainDoors && !Left4Bots.HasManualOrderTarget("tankdoorin_button") && !Left4Bots.HasManualOrderTarget("tankdoorout_button"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "tankdoorin_button");
						if (!door || !door.IsValid())
							door = Entities.FindByName(null, "tankdoorout_button");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(7103.514648, 589.364197, 130.150696);
							if (door.GetName() == "tankdoorout_button")
								pos = Vector(6971.906250, 669.720581, 167.122360);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + randomBot.GetPlayerName() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
			else if (Left4Bots.MapName == "c7m3_port")
			{
				local finale_start_button = Entities.FindByName(null, "finale_start_button");
				local finale_start_button1 = Entities.FindByName(null, "finale_start_button1");
				local finale_start_button2 = Entities.FindByName(null, "finale_start_button2");
				local bridge_start_button = Entities.FindByName(null, "bridge_start_button");
				//local generator_button = Entities.FindByName(null, "generator_button"); // when generator_button appears it's too late for the bot to get down the bridge
				local generator_model2 = Entities.FindByName(null, "generator_model2");
				
				if (finale_start_button && finale_start_button1 && finale_start_button2)
					Left4Bots.StartGenerators = false;
				else
					Left4Bots.StartGenerators = true;
				
				if (!Left4Bots.FinalVehicleArrived && (finale_start_button || finale_start_button1 || finale_start_button2)) // need to start the 3 generators
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "STAGE 1");
					
					foreach (id, bot in ::Left4Bots.Bots)
					{
						if (bot.IsValid())
						{
							if (finale_start_button)
							{
								Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = finale_start_button, pos = Vector(-407.416443, -651.816711, 2.146685), ordertype = "generator", canpause = true };
								finale_start_button = null;
							}
							else if (finale_start_button1)
							{
								Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = finale_start_button1, pos = Vector(-1239.006714, 874.744263, 160.031250), ordertype = "generator", canpause = true };
								finale_start_button1 = null;
							}
							else
							{
								Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = finale_start_button2, pos = Vector(1771.880859, 735.567078, -95.968750), ordertype = "generator", canpause = true };
								finale_start_button2 = null;
							}
							
							DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
						}
						
						if (!finale_start_button && !finale_start_button1 && !finale_start_button2)
							break;
					}
				}
				else if (Left4Bots.FinalVehicleArrived && bridge_start_button) // need to raise the bridge
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "STAGE 2");
					
					// for the bridge button try to send any bot but Bill
					local bot = Left4Bots.GetBotByCharacter(S_FRANCIS);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_LOUIS);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_ZOEY);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_BILL); // apparently Bill is the only bot available
				
					if (bot)
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Available bot: " + bot.GetPlayerName());
						
						Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = bridge_start_button, pos = Vector(-119.689484, -1734.732910, 252.031250), ordertype = "button", canpause = false };
						
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
					}
					else
						Left4Bots.Log(LOG_LEVEL_DEBUG, "No available bot!");
				}
				else if (Left4Bots.FinalVehicleArrived && generator_model2)
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "STAGE 3");
					
					// try to send Bill for the sacrifice generator, if not available i choose the bot in reverse order
					// from "STAGE 2" for a lower chance to choose the same bot who has been sent to the bridge button
					local bot = Left4Bots.GetBotByCharacter(S_BILL);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_ZOEY);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_LOUIS);
					if (!bot || bot.IsIncapacitated())
						bot = Left4Bots.GetBotByCharacter(S_FRANCIS);
					if (bot)
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Available bot: " + bot.GetPlayerName());
						
						Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = generator_model2, pos = Vector(-407.416443, -651.816711, 2.146685), ordertype = "generator", canpause = false };
						
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
					}
					else
						Left4Bots.Log(LOG_LEVEL_DEBUG, "No available bot!");
				}
			}
			else if (Left4Bots.MapName == "c9m2_lots")
			{
				if (Left4Bots.C9M2CanActivateGenerator && !Left4Bots.HasManualOrderTarget("finaleswitch_initial") && !Left4Bots.HasManualOrderTarget("generator_switch"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local generator = Entities.FindByName(null, "finaleswitch_initial");
						if (!generator || !generator.IsValid())
							generator = Entities.FindByName(null, "generator_switch");
						if (!generator || !generator.IsValid())
							generator = null;
						
						if (generator)
						{
							local pos = Vector(6849.456543, 5977.039063, 43.139301);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = generator, pos = pos, ordertype = "generator", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + randomBot.GetPlayerName() + " - destination: " + generator.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
			else if (Left4Bots.MapName == "c12m2_traintunnel")
			{
				if (Left4Bots.C12M2CanOpenEmergencyDoor && !Left4Bots.HasManualOrderTarget("emergency_door"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "emergency_door");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(-8599.708008, -7498.775391, -63.968750);
							local lookatpos = Vector(-8596.366211, -7686.694824, -63.968754);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = door, pos = pos, lookatpos = lookatpos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
			else if (Left4Bots.MapName == "c13m1_alpinecreek")
			{
				if (Left4Bots.C13M1CanOpenBunkerDoor && !Left4Bots.HasManualOrderTarget("bunker_button"))
				{
					local randomBot = Left4Bots.GetRandomAvailableBot();
					if (randomBot)
					{
						local door = Entities.FindByName(null, "bunker_button");
						if (!door || !door.IsValid())
							door = null;
						
						if (door)
						{
							local pos = Vector(1036.148071, 244.124512, 714.031250);
							
							// send the order to the bot
							Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = who, stime = Time(), dest = door, pos = pos, ordertype = "door", canpause = true };
							
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + randomBot.GetPlayerName() + " - destination: " + door.GetName());
							
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
			
			//else
			//{
				if (!Left4Bots.ScavengeEnabled && !Left4Bots.Settings.no_scavenge)
				{
					Left4Bots.Log(LOG_LEVEL_INFO, who.GetPlayerName() + " ordered to start scavenge");
					
					Left4Bots.ScavengeEnabled = true;
				}
			//}
			
			return true;
		}
		else if (order == "wait" || order == "stop" || order == "waithere")
		{
			if (Convars.GetFloat("sb_hold_position") == 0)
			{
				Left4Bots.Log(LOG_LEVEL_INFO, who.GetPlayerName() + " ordered to hold the position");
					
				Convars.SetValue("sb_hold_position", 1);
				Convars.SetValue("sb_enforce_proximity_range", PROXIMITY_RANGE_MAX);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 1);
				
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (bot.IsValid())
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
				}
			}
			
			return true;
		}
		else if (order == "move" || order == "run" || order == "help" || order == "follow" || order == "followme" || order == "together")
		{
			if (Left4Bots.ScavengeEnabled)
			{
				Left4Bots.Log(LOG_LEVEL_INFO, who.GetPlayerName() + " ordered to stop scavenge");
						
				Left4Bots.ScavengeEnabled = false;
				Left4Bots.ScavengeOrders = {};
				
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (bot.IsValid())
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
				}
			}
				
			Left4Bots.ManualOrders = {}; // cancel any given manual order
				
			Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual orders cleared, new count: " + Left4Bots.ManualOrders.len());
			
			if (Convars.GetFloat("sb_hold_position") != 0)
			{
				Left4Bots.Log(LOG_LEVEL_INFO, who.GetPlayerName() + " ordered to move");
					
				Convars.SetValue("sb_hold_position", 0);
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
				
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (bot.IsValid())
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomMoveAnswer(), 0, null, bot);
				}
			}
			
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot.IsValid())
				{
					Left4Bots.HoldItemStop(bot);
					
					Left4Bots.BotReset(bot, true); // Added to stop any pending attack command (TODO: check if it causes problems)
					
					local uEnt = NetProps.GetPropEntity(bot, "m_hUseEntity");
					if (uEnt && uEnt.GetClassname().find("prop_minigun") != null)
					{
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
						
						Left4Bots.BotPressButton(bot, BUTTON_SHOVE, BUTTON_HOLDTIME_TAP);
					}
				}
			}
			
			return true;
		}
		else if (order == "witch")
		{
			/*
			local witch = null;
			local target = Left4Utils.GetLookingTarget(who);
			if (target != null)
			{
				if ((typeof target) == "instance" && target.GetClassname() == "witch")
					witch = target;
				else if ((typeof target) == "Vector")
					witch = Entities.FindByClassnameNearest("witch", target, 150);
			
				if (witch)
				{
					if (botdest == null)
						Left4Bots.ManualOrderEnd(who, witch, null, "witch", false, Left4Bots.RandomYesAnswer());
					else if (botdest.IsValid())
					{
						Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = witch, pos = null, ordertype = "witch", canpause = false };
					
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, botdest);
					
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + botdest.GetPlayerName() + " - destination: witch");

						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
			*/
			
			local witch = Left4Utils.GetPickerEntity(who, 2000, 0.90, false, "witch");
			if (witch && witch.IsValid() && witch.GetClassname() == "witch")
			{
				if (botdest == null)
				{
					if (!Left4Bots.ManualOrderEnd(who, witch, null, "witch", false, Left4Bots.RandomYesAnswer()))
					{
						foreach (b in ::Left4Bots.Bots)
						{
							if (Left4Bots.IsBotReadyForOrder(b))
							{
								local aw = b.GetActiveWeapon();
								if (aw && aw.IsValid() && aw.GetClassname().find("shotgun") != null)
								{
									Left4Bots.ManualOrders[b.GetPlayerUserId()] <- { from = who, stime = Time(), dest = witch, pos = null, ordertype = "witch", canpause = false };
								
									DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, b);
								
									Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + b.GetPlayerName() + " (autoassigned) - destination: witch");

									Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
									
									return true;
								}
							}
						}
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Player " + who.GetPlayerName() + " ordered to crown a witch to a random bot but no available bot was found");
					}
					else
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Player " + who.GetPlayerName() + " ordered to crown a witch to a previously selected bot");
				}
				else if (botdest.IsValid())
				{
					Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = witch, pos = null, ordertype = "witch", canpause = false };
				
					DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, botdest);
				
					Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + botdest.GetPlayerName() + " - destination: witch");

					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
				}
				else
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Player " + who.GetPlayerName() + " ordered to crown a witch to an assigned bot but the bot is no longer valid");
			}
			
			return true;
		}
		else if (order == "heal" && subject && subject.IsValid() && IsPlayerABot(subject) && Left4Utils.HasMedkit(subject) && NetProps.GetPropInt(subject, "m_iCurrentUseAction") == 0)
		{
			if (!botdest || !botdest.IsValid() || botdest.GetPlayerUserId() == subject.GetPlayerUserId())
			{
				subject.SwitchToItem("weapon_first_aid_kit");
				//Left4Timers.AddTimer(null, 1.2, @(params) Left4Bots.BotPressButton(params.bot, params.button, params.holdTime, params.destination, params.deltaPitch, params.deltaYaw, params.lockLook), { bot = subject, button = BUTTON_ATTACK, holdTime = BUTTON_HOLDTIME_HEAL, destination = null, deltaPitch = 0, deltaYaw = 0, lockLook = true });
				Left4Timers.AddTimer(null, 1.2, Left4Bots.DoHeal, { bot = subject });
			}
			else
			{
				Left4Bots.ManualOrders[subject.GetPlayerUserId()] <- { from = who, stime = Time(), dest = botdest, pos = null, ordertype = "heal", canpause = false, holdtime = BUTTON_HOLDTIME_HEAL };

				DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, subject);

				Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + subject.GetPlayerName() + " - destination: " + botdest.GetClassname());

				Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
			}
			
			return true;
		}
		else if (order == "healme")
		{
			return Left4Bots.BotOrder("heal", who, subject, who);
		}
		else if (order == "tempheal" && subject && subject.IsValid() && IsPlayerABot(subject))
		{
			local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_PILLS);
			if (item && item.IsValid())
			{
				subject.SwitchToItem(item.GetClassname());
				Left4Timers.AddTimer(null, 1.2, @(params) Left4Bots.BotPressButton(params.bot, params.button, params.holdTime, params.destination, params.deltaPitch, params.deltaYaw, params.lockLook), { bot = subject, button = BUTTON_ATTACK, holdTime = 1, destination = null, deltaPitch = 0, deltaYaw = 0, lockLook = true });
			}
			
			return true;
		}
		else if (order == "warp" && subject && subject.IsValid() && IsPlayerABot(subject) && who && who.IsValid())
		{
			subject.SetOrigin(who.GetOrigin());
			
			return true;
		}
		else if (order == "throw" && who && who.IsValid())
		{
			local destination = Left4Utils.GetLookingTarget(who);
			if (destination != null)
			{
				if (param)
				{
					if (param.find("molotov") != null)
						param = "weapon_molotov";
					else if (param.find("pipe") != null)
						param = "weapon_pipe_bomb";
					else if (param.find("bile") != null)
						param = "weapon_vomitjar";
					else
						return true; // bad item name

					if (subject)
					{
						// botname throw itemname
						
						if (subject.IsValid() && IsPlayerABot(subject) && Left4Utils.HasItem(subject, param) && Left4Bots.IsBotReadyForOrder(subject, true))
							Left4Bots.BotThrowNade2(subject, param, destination, THROW_NADE_DELTAPITCH);
					}
					else
					{
						// bots throw itemname
						
						local tgtP = destination;
						if ((typeof tgtP) == "instance")
							tgtP = tgtP.GetOrigin();
						
						local nBot = null;
						local nDist = 1000000;
						foreach (id, bot in ::Left4Bots.Bots) // Find the closest bot to the destination position who can throw that item
						{
							if (bot.IsValid() && Left4Utils.HasItem(bot, param) && Left4Bots.IsBotReadyForOrder(bot, true))
							{
								local d = (bot.GetOrigin() - tgtP).Length();
								if (d < nDist)
								{
									nBot = bot;
									nDist = d;
								}
							}
						}
						if (nBot)
							Left4Bots.BotThrowNade2(nBot, param, destination, THROW_NADE_DELTAPITCH);
					}
				}
				else
				{
					if (subject)
					{
						// botname throw
						
						if (subject.IsValid() && IsPlayerABot(subject) && Left4Bots.IsBotReadyForOrder(subject, true))
						{
							local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_THROW);
							if (item)
								Left4Bots.BotThrowNade2(subject, item.GetClassname(), destination, THROW_NADE_DELTAPITCH);
						}
					}
					else
					{
						// bots throw
						
						foreach (id, bot in ::Left4Bots.Bots)
						{
							if (bot.IsValid() && Left4Bots.IsBotReadyForOrder(bot, true))
							{
								local item = Left4Utils.GetInventoryItemInSlot(bot, INV_SLOT_THROW);
								if (item)
									Left4Bots.BotThrowNade2(bot, item.GetClassname(), destination, THROW_NADE_DELTAPITCH);
							}
						}
					}
				}
			}
			
			return true;
		}
		else if (order == "swap" && subject && subject.IsValid() && IsPlayerABot(subject) && who && who.IsValid())
		{
			local held = who.GetActiveWeapon();
			if (held)
			{
				local heldClass = held.GetClassname();
				local heldSkin = NetProps.GetPropInt(held, "m_nSkin");
				local slot = Left4Utils.FindSlotForItemClass(who, heldClass);
				
				if (slot && slot != INV_SLOT_PRIMARY && slot != INV_SLOT_SECONDARY)
				{
					local spawpItem = Left4Utils.GetInventoryItemInSlot(subject, slot);
					if (spawpItem)
					{
						local swapClass = spawpItem.GetClassname();
						local swapSkin = NetProps.GetPropInt(spawpItem, "m_nSkin");
						if (swapClass != heldClass || swapSkin != heldSkin)
						{
							DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, who);
							DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, subject);
							
							Left4Bots.GiveItemIndex1 = held.GetEntityIndex();
							Left4Bots.GiveItemIndex2 = spawpItem.GetEntityIndex();
							
							who.DropItem(heldClass);
							subject.DropItem(swapClass);
							
							//who.GiveItemWithSkin(swapClass, swapSkin);
							Left4Utils.GiveItemWithSkin(who, swapClass, swapSkin);
							//subject.GiveItemWithSkin(heldClass, heldSkin);
							Left4Utils.GiveItemWithSkin(subject, heldClass, heldSkin);
							
							Left4Timers.AddTimer(null, 0.1, Left4Bots.SwapNades, { player1 = who, weapon1 = spawpItem, player2 = subject, weapon2 = held });
						}
					}
				}
				else
					Left4Bots.Log(LOG_LEVEL_ERROR, "Couldn't find the slot for item of class " + heldClass);
			}
			
			return true;
		}
		else if (order == "deploy" && subject && subject.IsValid() && IsPlayerABot(subject))
		{
			local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_MEDKIT);
			if (item)
			{
				local itemClass = item.GetClassname();
				if (itemClass == "weapon_upgradepack_incendiary" || itemClass == "weapon_upgradepack_explosive")
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + subject.GetPlayerName() + " switching to upgrade " + itemClass);
					
					subject.SwitchToItem(itemClass);
					
					Left4Timers.AddTimer(null, 1, @(params) Left4Bots.DoDeployUpgrade(params.player), { player = subject });
				}
			}
			
			return true;
		}
		else if (order == "give" && subject && subject.IsValid() && IsPlayerABot(subject) && who && who.IsValid())
		{
			if (NetProps.GetPropInt(who, "m_iTeamNum") == TEAM_SURVIVORS && !who.IsDead() && !who.IsDying() /*&& (subject.GetOrigin() - who.GetOrigin()).Length() <= 150*/)
			{
				// Give pills / adrenaline
				local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_PILLS);
				if (item && Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_PILLS) == null && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 /*&& (Time() - Left4Bots.LastGiveItemTime) > 3*/)
				{
					local itemClass = item.GetClassname();
					local itemSkin = NetProps.GetPropInt(item, "m_nSkin");

					DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, subject);
								
					Left4Bots.GiveItemIndex1 = item.GetEntityIndex();
								
					subject.DropItem(itemClass);
								
					//who.GiveItemWithSkin(itemClass, itemSkin);
					Left4Utils.GiveItemWithSkin(who, itemClass, itemSkin);
								
					Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = subject, player2 = who, weapon = item });
				}
				
				// Give medkits to admins / upgrades
				local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_MEDKIT);
				if (item && Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_MEDKIT) == null && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 /*&& (Time() - Left4Bots.LastGiveItemTime) > 1*/)
				{
					local itemClass = item.GetClassname();
					local itemSkin = NetProps.GetPropInt(item, "m_nSkin");
					if ((itemClass == "weapon_first_aid_kit" && Left4Bots.IsOnlineAdmin(who)) || itemClass == "weapon_upgradepack_explosive" || itemClass == "weapon_upgradepack_incendiary")
					{
						DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, subject);
								
						Left4Bots.GiveItemIndex1 = item.GetEntityIndex();
								
						subject.DropItem(itemClass);
								
						//who.GiveItemWithSkin(itemClass, itemSkin);
						Left4Utils.GiveItemWithSkin(who, itemClass, itemSkin);
								
						Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = subject, player2 = who, weapon = item });						
					}
				}
				
				// Give throwables
				local item = Left4Utils.GetInventoryItemInSlot(subject, INV_SLOT_THROW);
				if (item && Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_THROW) == null && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 /*&& (Time() - Left4Bots.LastGiveItemTime) > 3*/)
				{
					local itemClass = item.GetClassname();
					local itemSkin = NetProps.GetPropInt(item, "m_nSkin");
				
					DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, subject);
					
					Left4Bots.GiveItemIndex1 = item.GetEntityIndex();
					
					subject.DropItem(itemClass);
					
					//who.GiveItemWithSkin(itemClass, itemSkin);
					Left4Utils.GiveItemWithSkin(who, itemClass, itemSkin);
					
					Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = subject, player2 = who, weapon = item });
				}
			}
			
			return true;
		}
		else if (order == "use")
		{
			local target = null;
			local tTable = Left4Utils.GetLookingTargetEx(who, TRACE_MASK_NPC_SOLID);
			if (tTable)
			{
				if (tTable["ent"])
				{
					local tClass = tTable["ent"].GetClassname();
					if (tClass.find("weapon_") != null || tClass.find("prop_physics") != null || tClass.find("prop_minigun") != null || tClass.find("func_button") != null || tClass.find("trigger_finale") != null || tClass.find("prop_door_rotating") != null)
						target = tTable["ent"];
					else
						target = Left4Bots.FindNearestUsable(tTable["pos"], 100);
				}
				else
					target = Left4Bots.FindNearestUsable(tTable["pos"], 100);
				
				if (target)
				{
					local targetClass = target.GetClassname();
					local targetPos = null;
					
					if (targetClass.find("weapon_") != null || targetClass.find("prop_physics") != null)
						targetPos = null;
					else if (targetClass.find("prop_minigun") != null)
						targetPos = target.GetOrigin() - (target.GetAngles().Forward() * 50);
					else if (targetClass.find("func_button") != null || targetClass.find("trigger_finale") != null || targetClass.find("prop_door_rotating") != null)
					{
						if (!param && targetClass == "func_button_timed")
							param = NetProps.GetPropInt(target, "m_nUseTime");
						
						local p = tTable["pos"];
						local a = Left4Utils.VectorAngles(who.GetCenter() - tTable["pos"]);
						
						if (targetClass.find("trigger_finale") != null)
							targetPos = Left4Bots.FindBestUseTargetPos(target, p, a, true, Left4Bots.Settings.loglevel >= LOG_LEVEL_DEBUG);
						else
							targetPos = Left4Bots.FindBestUseTargetPos(target, p, a, false, Left4Bots.Settings.loglevel >= LOG_LEVEL_DEBUG);
						if (!targetPos)
							targetPos = target.GetCenter();
						
						if (targetClass.find("func_button") != null)
						{
							local glowEntName = NetProps.GetPropString(target, "m_sGlowEntity");
							if (glowEntName && glowEntName != "")
							{
								local glowEnt = Entities.FindByName(null, glowEntName);
								if (glowEnt)
									target = glowEnt;
							}
						}
					}
					else
						target = null;
					
					if (target)
					{
						if (botdest == null)
							Left4Bots.ManualOrderEnd(who, target, targetPos, "use", false, Left4Bots.RandomYesAnswer(), param);
						else if (botdest.IsValid())
						{
							if (param)
								Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = target, pos = targetPos, ordertype = "use", canpause = false, holdtime = param };
							else
								Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = target, pos = targetPos, ordertype = "use", canpause = false };
						
							DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, botdest);
						
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + botdest.GetPlayerName() + " - destination: " + target.GetClassname());

							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
						}
					}
				}
			}
			
			return true;
		}
		else if (order == "goto")
		{
			local pos = Left4Utils.GetLookingPosition(who, TRACE_MASK_NPC_SOLID);
			if (pos)
			{
				if (botdest == null)
					Left4Bots.ManualOrderEnd(who, Entities.FindByClassname(null, "worldspawn"), pos, "goto", false, Left4Bots.RandomYesAnswer(), param);
				else if (botdest.IsValid())
				{
					Left4Bots.ManualOrders[botdest.GetPlayerUserId()] <- { from = who, stime = Time(), dest = Entities.FindByClassname(null, "worldspawn"), pos = pos, ordertype = "goto", canpause = false };
						
					DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, botdest);
						
					Left4Bots.Log(LOG_LEVEL_INFO, "Manual order from " + who.GetPlayerName() + " to bot " + botdest.GetPlayerName() + " - destination: " + pos);

					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order added, new count: " + Left4Bots.ManualOrders.len());
				}
			}
			
			return true;
		}
		else if (order == "attack")
		{
			local target = Left4Utils.GetLookingTarget(who, TRACE_MASK_NPC_SOLID);
			if (target != null)
			{
				if ((typeof target) == "Vector")
					target = Left4Bots.FindNearestKillable(target, 80);
				else
				{
					local tClass = target.GetClassname();
					if (tClass != "player" && tClass != "infected")
						target = Left4Bots.FindNearestKillable(target.GetOrigin(), 80);
				}
			
				if (target)
				{
					if (botdest && botdest.IsValid())
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, botdest);
					else
					{
						foreach (id, bot in ::Left4Bots.Bots)
						{
							if (bot && bot.IsValid())
								DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
						}
					}
					
					Left4Utils.BotCmdAttack(botdest, target);
				}
			}
			
			return true;
		}
		else if (order == "go")
		{
			if (Left4Bots.MapName == "c7m3_port")
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, "StartGenerators = true");
				
				Left4Bots.StartGenerators = true;
			}
			
			return true;
		}
		else if (order == "canceldefib")
		{
			Left4Bots.Deads = {}; // Clear the deads list
			foreach (id, bot in ::Left4Bots.Bots)
			{
				if (bot && bot.IsValid())
				{
					local scope = bot.GetScriptScope();
					if (("GoToEnt" in scope) && ("GoToEntI" in scope) && scope.GoToEnt && scope.GoToEntI == 2) // Bot is executing the defib command
					{
						Left4Bots.BotReset(bot, true); // Cancelling the defib command
						DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, bot);
					}
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	::Left4Bots.DelayedCrashFinaleGeneratorBreak <- function (params)
	{
		if (Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.HasManualOrderTarget("generator_switch"))
		{
			local randomBot = Left4Bots.GetRandomAvailableBot();
			if (randomBot)
			{
				local generator = Entities.FindByName(null, "generator_switch");
				if (!generator || !generator.IsValid())
					generator = null;
				
				if (generator)
				{
					local pos = Vector(6849.456543, 5977.039063, 43.139301);
					
					// send the order to the bot
					Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = generator, pos = pos, ordertype = "generator", canpause = true };
					
					Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + randomBot.GetPlayerUserId() + " - destination: " + generator.GetName());
					
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
				}
			}
		}
	}
	
	// Note: It doesn't return true/false. Returns the class name of the upgrade item if he can deploy the item, null otherwise
	::Left4Bots.ShouldDeployUpgrades <- function (player, query)
	{
		if (!player || !player.IsValid())
			return null;
		
		local item = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_MEDKIT);
		if (!item)
			return null;
		
		local itemClass = item.GetClassname();
		if (itemClass != "weapon_upgradepack_incendiary" && itemClass != "weapon_upgradepack_explosive")
			return null;
		
		if ((("incheckpoint" in query) && query.incheckpoint != 0) || (("BotIsNearCheckpoint" in query) && query.BotIsNearCheckpoint != 0) || (("incombat" in query) && query.incombat != 0) || (("InCombatMusic" in query) && query.InCombatMusic != 0))
			return null;
		
		if ((("incapacitated" in query) && query.incapacitated != 0) || (("hangingfromledge" in query) && query.hangingfromledge != 0) || (("onfire" in query) && query.onfire != 0) || (("beinghealed" in query) && query.beinghealed != 0))
			return null;
			
		if ((("hangingfromtongue" in query) && query.hangingfromtongue != 0) || (("pouncevictim" in query) && query.pouncevictim != 0) || (("beingjockeyed" in query) && query.beingjockeyed != 0))
			return null;
		
		if (("activeweapon" in query) && (query.activeweapon == "UpgradePack_Incendiary" || query.activeweapon == "UpgradePack_Explosive"))
			return null;
		
		if ((!("instartarea" in query) || query.instartarea == 0) && (!("disttoclosestsurvivor" in query) || query.disttoclosestsurvivor > 100))
			return null;
		
		local primary = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_PRIMARY);
		if (primary && NetProps.GetPropInt(primary, "m_nUpgradedPrimaryAmmoLoaded") > 5)
			return null;
		
		if (Left4Bots.SurvivorsHeldOrIncapped())
			return null;
		
		return itemClass;
	}
	
	::Left4Bots.DoDeployUpgrade <- function (player)
	{
		if (!player || !player.IsValid())
			return;
		
		local item = player.GetActiveWeapon();
		if (!item)
			return;
		
		local itemClass = item.GetClassname();
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + player.GetPlayerName() + " switched to upgrade " + itemClass);
		
		if (itemClass != "weapon_upgradepack_incendiary" && itemClass != "weapon_upgradepack_explosive")
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + player.GetPlayerName() + " deploying upgrade " + itemClass);
		
		Left4Bots.BotPressButton(player, BUTTON_ATTACK, 2.2, null, 0, 0, true);
	}
	
	::Left4Bots.RemoveDeathModel <- function (dmodel)
	{
		foreach (chr, death in ::Left4Bots.Deads)
		{
			if (death.dmodel == dmodel)
			{
				delete ::Left4Bots.Deads[chr];
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Removed death model for character " + chr);
				
				return;
			}
		}
	}
	
	::Left4Bots.ExtinguishWitch <- function (params)
	{
		local witch = params["witch"];
		if (!witch || !witch.IsValid())
			return;
		
		DoEntFire("!self", "IgniteLifetime", "0", 0, null, witch);
			
		local fx = NetProps.GetPropEntity(witch, "m_hEffectEntity");
		if (fx)
			fx.Kill();
		
		Left4Timers.AddTimer(null, 0.1, Left4Bots.FixWitchAnim, { witch = witch });
	}

	::Left4Bots.FixWitchAnim <- function (params)
	{
		local witch = params["witch"];
		if (!witch || !witch.IsValid())
			return;
		
		witch.SetSequence(witch.LookupSequence("Run"));
	}
	
	::Left4Bots.OnInfectedHurt <- function (attacker, infected, damage, dmgType)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "OnInfectedHurt");
		
		if (!attacker || !infected || !attacker.IsValid() || !infected.IsValid() || attacker.GetClassname() != "player" || infected.GetClassname() != "witch" || !IsPlayerABot(attacker))
			return;
		
		local attackerTeam = NetProps.GetPropInt(attacker, "m_iTeamNum");
		if (attackerTeam != TEAM_SURVIVORS && attackerTeam != TEAM_L4D1_SURVIVORS)
			return;
		
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "OnInfectedHurt - attacker: " + attacker.GetPlayerName() + " - damage: " + damage + " - dmgType: " + dmgType);
		
		if (Left4Bots.Settings.trigger_witch && NetProps.GetPropFloat(infected, "m_rage") < 1.0 && !NetProps.GetPropInt(infected, "m_mobRush") && (dmgType & DMG_BURN) == 0)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "OnInfectedHurt - Bot " + attacker.GetPlayerName() + " startled witch (damage: " + damage + " - dmgType: " + dmgType + ")");
			
			/* Fire method
			if (!NetProps.GetPropInt(infected, "m_bIsBurning"))
				Left4Timers.AddTimer(null, 0.01, Left4Bots.ExtinguishWitch, { witch = infected }, false);

			infected.TakeDamage(0.001, DMG_BURN, attacker); // Startle the witch
			*/
			
			// Easier method
			NetProps.SetPropFloat(infected, "m_rage", 1.0);
			NetProps.SetPropFloat(infected, "m_wanderrage", 1.0);
			Left4Utils.BotCmdAttack(infected, attacker);
		}
	}
	
	::Left4Bots.OnConcept <- function (concept, query)
	{
		if (!Left4Bots.ModeStarted && "gamemode" in query)
		{
			Left4Bots.ModeStarted = true;
			Left4Bots.OnModeStart();
		}
		
		if (/*concept == "TLK_IDLE" || */concept == "PlayerExertionMinor" || concept.find("VSLib") != null)
			return;
		
		local who = null;
		if ("who" in query)
			who = query.who;
		else if ("Who" in query)
			who = query.Who;
		
		local subject = null;
		if ("subject" in query)
			subject = query.subject;
		else if ("Subject" in query)
			subject = query.Subject;
		
		if (who != null)
			who = Left4Bots.GetSurvivorFromActor(who);

		if (subject != null)
			subject = Left4Bots.GetSurvivorFromActor(subject);

		local canOrder = Left4Bots.Settings.vocalizer_commands && (who && !IsPlayerABot(who) && (Left4Bots.Settings.user_can_command_bots || Left4Bots.IsOnlineAdmin(who)));
		
		if (canOrder)
		{
			// Orders
			
			if (concept in ::Left4Bots.VocalizerOrders)
			{
				foreach (cmd in Left4Bots.VocalizerOrders[concept])
					Left4Bots.BotOrder(cmd, who, subject);
			}
			
			if (concept == "PlayerLook" || concept == "PlayerLookHere")
			{
				if (subject && IsPlayerABot(subject))
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, who.GetPlayerName() + " selected bot " + subject.GetPlayerName() + " for order");
					
					// Manual orders start by calling the receiving bot. The order destination must be said within MANUAL_ORDER_MAXTIME seconds from now.
					Left4Bots.ManualOrders[subject.GetPlayerUserId()] <- { from = who, stime = Time(), dest = null, pos = null, ordertype = "", canpause = true }; // this will cancel any previous order for this bot
					
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order start, new count: " + Left4Bots.ManualOrders.len());
				}
			}
		}
		
		if (concept == "PlayerLaugh")
		{
			if (!IsPlayerABot(who))
			{
				foreach (id, bot in ::Left4Bots.Bots)
				{
					if (bot.IsValid() && RandomInt(1, 100) <= Left4Bots.Settings.laugh_chance)
						DoEntFire("!self", "SpeakResponseConcept", "PlayerLaugh", RandomFloat(0.5, 2), null, bot);
				}
			}
		}
		else if (concept == "PlayerThanks")
		{
			if (subject && IsPlayerABot(subject) && !IsPlayerABot(who) && RandomInt(1, 100) <= Left4Bots.Settings.youwelcome_chance)
				DoEntFire("!self", "SpeakResponseConcept", "PlayerYouAreWelcome", RandomFloat(1.2, 2.3), null, subject);
		}
		else if (concept == "iMT_PlayerNiceShot")
		{
			if (!IsPlayerABot(who) && RandomInt(1, 100) <= Left4Bots.Settings.thanks_chance)
			{
				if (subject)
				{
					if (IsPlayerABot(subject))
						DoEntFire("!self", "SpeakResponseConcept", "PlayerThanks", RandomFloat(1.2, 2.3), null, subject);
				}
				else if (Left4Bots.NiceShootSurv && Left4Bots.NiceShootSurv.IsValid() && (Time() - Left4Bots.NiceShootTime) <= 10.0)
					DoEntFire("!self", "SpeakResponseConcept", "PlayerThanks", RandomFloat(0.5, 2), null, Left4Bots.NiceShootSurv);
			}
		}
		else if (concept == "PlayerWarnSpecial")
		{
			local specialtype = null;
			if ("specialtype" in query)
				specialtype = query.specialtype;
			
			if (specialtype == "TANK" && !Left4Bots.Settings.keep_holding_position)
			{
				Convars.SetValue("sb_hold_position", 0); // stop holding position, tank is coming!
				Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
				if (Left4Bots.Settings.wait_crouch)
					Convars.SetValue("sb_crouch", 0);
			}
		}
		else if (concept == "SurvivorBotHelpOverwhelmed")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, who.GetPlayerName() + " overwhelmed");
			
			if ((Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL && NetProps.GetPropInt(who, "m_hasVisibleThreats"))
			{
				local pos = null;
				local common = Left4Bots.HasAngryCommonsWithin(who, Left4Bots.Settings.horde_nades_size, Left4Bots.Settings.horde_nades_radius, Left4Bots.Settings.horde_nades_maxaltdiff);
				if (common != false)
				{
					if (common != true)
						pos = common.GetOrigin();
					else
						pos = Left4Utils.BotGetFarthestPathablePos(who, THROW_NADE_RADIUS);
				}
				
				if (pos && (pos - who.GetOrigin()).Length() >= THROW_NADE_MIN_DISTANCE)
				{
					local item = Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_THROW);
					if (IsPlayerABot(who) && !who.IsIncapacitated() && item && ((Left4Bots.Settings.throw_pipe_bomb && item.GetClassname() == "weapon_pipe_bomb") || (Left4Bots.Settings.throw_vomitjar && item.GetClassname() == "weapon_vomitjar")))
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + who.GetPlayerName() + " will throw a nade because he is being overwhelmed");
						Left4Bots.BotThrowNade(who, item.GetClassname(), pos, THROW_NADE_DELTAPITCH);
					}
					else
					{
						foreach (surv in Left4Bots.GetOtherStandingSurvivorsWithin(who, THROW_NADE_HELP_RADIUS))
						{
							if (IsPlayerABot(surv))
							{
								local item = Left4Utils.GetInventoryItemInSlot(surv, INV_SLOT_THROW);
								if (item && ((Left4Bots.Settings.throw_pipe_bomb && item.GetClassname() == "weapon_pipe_bomb") || (Left4Bots.Settings.throw_vomitjar && item.GetClassname() == "weapon_vomitjar")))
								{
									Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + surv.GetPlayerName() + " will throw a nade because " + who.GetPlayerName() + " is being overwhelmed");
									Left4Bots.BotThrowNade(surv, item.GetClassname(), pos, THROW_NADE_DELTAPITCH);
									break;
								}
							}
						}
					}
				}
			}
		}
		else if (concept == "OfferItem")
		{
			if (!IsPlayerABot(who) && subject && subject.IsValid && IsPlayerABot(subject))
				Left4Bots.LastGiveItemTime = Time();
		}
		else if (concept == "SurvivorBotRegroupWithTeam")
		{
			// Receiving this concept from a bot who is executing a move command means that the bot got nav stuck and teleported somewhere.
			// After the teleport the move command is lost and needs to be refreshed.
			if (IsPlayerABot(who))
			{
				//who.ValidateScriptScope();
				local scope = who.GetScriptScope();
				if (!("GoToEnt" in scope))
					Left4Bots.Log(LOG_LEVEL_ERROR, "Bot " who.GetPlayerName() + " has no 'GoToEnt' in scope");
				else if (scope.GoToEnt != null)
					scope.NeedMove = 2;
			}
		}
		else if (concept == "TLK_IDLE" || concept == "SurvivorBotNoteHumanAttention" || concept == "SurvivorBotHasRegroupedWithTeam")
		{
			if (Left4Bots.Settings.deploy_upgrades && IsPlayerABot(who))
			{
				local itemClass = Left4Bots.ShouldDeployUpgrades(who, query);
				if (itemClass)
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + who.GetPlayerName() + " switching to upgrade " + itemClass);
					
					who.SwitchToItem(itemClass);
					
					Left4Timers.AddTimer(null, 1, @(params) Left4Bots.DoDeployUpgrade(params.player), { player = who });
				}
			}
		}
		else if (concept == "PlayerChoke" || concept == "PlayerTonguePullStart")
		{
			if (Left4Bots.Settings.shoot_smokers_tongue)
			{
				local smoker = NetProps.GetPropEntity(who, "m_tongueOwner");
				if (smoker && smoker.IsValid())
					Left4Bots.DealWithSmoker(smoker, who);
			}
		}
		//else if (concept == "chargerpound")
		//{
			//
		//}
		else if (concept == "FinaleTriggered")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "FinaleTriggered");
			
			if (Left4Bots.MapName != "c14m2_lighthouse" && !Left4Bots.ScavengeEnabled && (Left4Bots.Settings.scavenge_campaign_autostart || Left4Bots.Survivors.len() == Left4Bots.Bots.len()) && !Left4Bots.Settings.no_scavenge)
				Left4Bots.ScavengeEnabled = true;
		}
		else if (concept == "C14M2PowerOutAgain") // Map c14m2_lighthouse triggers the finale way too early so we don't start the scavenge on FinaleTriggered but here
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C14M2PowerOutAgain");
			
			if (!Left4Bots.ScavengeEnabled && (Left4Bots.Settings.scavenge_campaign_autostart || Left4Bots.Survivors.len() == Left4Bots.Bots.len()) && !Left4Bots.Settings.no_scavenge)
				Left4Bots.ScavengeEnabled = true;
		}
		else if (concept == "PlayerPourFinished")
		{
			local score = null;
			local towin = null;
			
			if ("Score" in query)
				score = query.Score.tointeger();
			if ("towin" in query)
				towin = query.towin.tointeger();
			
			if (score != null && towin != null)
				Left4Bots.Log(LOG_LEVEL_INFO, "Poured: " + score + " - Left: " + towin);
			
			if (Left4Bots.ScavengeEnabled && towin == 0)
			{
				Left4Bots.ScavengeEnabled = false;
				
				Left4Bots.Log(LOG_LEVEL_INFO, "Scavenge complete");
			}
		}
		else if (concept == "PlayerGetToRescueVehicle")
		{
			if (IsPlayerABot(who) && !who.IsIncapacitated() && (Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL && RandomInt(1, 100) <= THROW_NADE_CHANCE)
			{
				local item = Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_THROW);
				if (item && ((Left4Bots.Settings.throw_pipe_bomb && item.GetClassname() == "weapon_pipe_bomb") || (Left4Bots.Settings.throw_vomitjar && item.GetClassname() == "weapon_vomitjar")))
				{
					local pos = Left4Utils.BotGetFarthestPathablePos(who, THROW_NADE_RADIUS);
					if (pos && (pos - who.GetOrigin()).Length() >= THROW_NADE_MIN_DISTANCE)
						Left4Bots.BotThrowNade(who, item.GetClassname(), pos, THROW_NADE_DELTAPITCH);
				}
			}
		}
		else if (concept == "FinalVehicleArrived") // FinalVehicleSpotted
		{
			if (!Left4Bots.FinalVehicleArrived)
			{
				Left4Bots.FinalVehicleArrived = true;
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "FinalVehicleArrived");
			}
		}
		else if (concept == "C1M2FirstOutside")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "C1M2FirstOutside");
			
			Left4Bots.C1M2CanOpenStoreDoors = true;
			if (!Left4Bots.ScavengeEnabled && Left4Bots.Survivors.len() == Left4Bots.Bots.len() && !Left4Bots.Settings.no_scavenge)
				Left4Bots.ScavengeEnabled = true;
			
			if (Left4Bots.ScavengeEnabled && Left4Bots.ScavengeOrders.len() > 0 && !Left4Bots.HasManualOrderTarget("store_doors"))
			{
				foreach (id, ent in Left4Bots.ScavengeOrders)
				{
					local storeDoors = Entities.FindByName(null, "store_doors");
					if (storeDoors)
					{
						local state = NetProps.GetPropInt(storeDoors, "m_eDoorState");
						if (state == 0) // door closed (2 = open)
						{
							local pos = storeDoors.GetOrigin() + (storeDoors.GetAngles().Forward() * 15) - (storeDoors.GetAngles().Left() * 30);
							
							// send the order to the bot
							Left4Bots.ManualOrders[id] <- { from = null, stime = Time(), dest = storeDoors, pos = pos, ordertype = "door", canpause = true };
						
							Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot with id " + id + " - destination: store_doors");
						
							Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
						}
					}
					break;
				}
			}
		}
		else if (concept == "CrashFinaleGeneratorBreak")
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "CrashFinaleGeneratorBreak");
			
			Left4Bots.C9M2CanActivateGenerator = true;
			
			Left4Timers.AddTimer(null, 2, Left4Bots.DelayedCrashFinaleGeneratorBreak, { }); // because generator_switch isn't spawned yet
		}
	}
	
	::Left4Bots.DealWithSmoker <- function (smoker, victim)
	{
		local tongue = NetProps.GetPropEntity(smoker, "m_customAbility");
		if (!tongue || !tongue.IsValid() || NetProps.GetPropInt(tongue, "m_tongueState") != 3)
			return;
		
		local points = Left4Bots.GetSmokerTargetPoints(tongue, smoker, victim);
		
		foreach (bot in ::Left4Bots.Bots)
		{
			if (bot && bot.IsValid() && !bot.IsDying() && NetProps.GetPropInt(bot, "m_reviveTarget") <= 0 && NetProps.GetPropInt(bot, "m_iCurrentUseAction") <= 0 && !Left4Utils.IsPlayerHeld(bot))
			{
				//Left4Utils.BotCmdAttack(bot, smoker);
				
				if (Left4Bots.ValidWeaponForSmoker(bot.GetActiveWeapon()) && !Left4Bots.CanTraceToSmoker(bot, smoker))
				{
					if ((victim.GetCenter() - bot.GetCenter()).Length() < 100)
						continue;
					
					if (bot.GetActiveWeapon().GetClassname().find("shotgun") != null && (victim.GetCenter() - bot.GetCenter()).Length() > 600 && (smoker.GetCenter() - bot.GetCenter()).Length() > 600)
						continue;
					
					for (local i = 0; i < points.len(); i++)
					{
						local p = points[i];
						if (Left4Utils.CanTraceToPos(bot, p))
						{
							Left4Bots.Log(LOG_LEVEL_INFO, bot.GetPlayerName() + " shooting the smoker's tongue");
							
							//DebugDrawCircle(p, Vector(255, 0, 0), 255, 2, true, 1.5);
							
							Left4Bots.BotPressButton(bot, BUTTON_DUCK, 1.5, p, 0, 0, true);
							Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, p, 0, 0, true);
							Left4Timers.AddTimer(null, 0.5, @(params) Left4Bots.BotPressButton(params.bot, params.button, params.holdTime, params.destination, params.deltaPitch, params.deltaYaw, params.lockLook), { bot = bot, button = BUTTON_ATTACK, holdTime = BUTTON_HOLDTIME_TAP, destination = p, deltaPitch = 0, deltaYaw = 0, lockLook = true });
							Left4Timers.AddTimer(null, 0.9, @(params) Left4Bots.BotPressButton(params.bot, params.button, params.holdTime, params.destination, params.deltaPitch, params.deltaYaw, params.lockLook), { bot = bot, button = BUTTON_ATTACK, holdTime = BUTTON_HOLDTIME_TAP, destination = p, deltaPitch = 0, deltaYaw = 0, lockLook = true });
							Left4Timers.AddTimer(null, 1.4, @(params) Left4Bots.BotPressButton(params.bot, params.button, params.holdTime, params.destination, params.deltaPitch, params.deltaYaw, params.lockLook), { bot = bot, button = BUTTON_ATTACK, holdTime = BUTTON_HOLDTIME_TAP, destination = p, deltaPitch = 0, deltaYaw = 0, lockLook = true });
							
							break;
						}
						//else
						//	DebugDrawCircle(p, Vector(0, 0, 255), 255, 2, true, 1.5);
					}
				}
			}
		}
	}
	
	::Left4Bots.CanTraceToSmoker <- function (source, smoker)
	{
		if (Left4Utils.CanTraceToEntPos(source, smoker, smoker.GetAttachmentOrigin(smoker.LookupAttachment("smoker_mouth"))))
			return true;
			
		if (Left4Utils.CanTraceToEntPos(source, smoker, smoker.GetCenter()))
			return true;
			
		if (Left4Utils.CanTraceToEntPos(source, smoker, smoker.GetOrigin()))
			return true;
		
		return false;
	}

	::Left4Bots.GetSmokerTargetPoints <- function (tongue, smoker, victim, section = 25)
	{
		local ret = {};
		local idx = 0;

		local startPos = smoker.GetAttachmentOrigin(smoker.LookupAttachment("smoker_mouth"));
		//local endPos = NetProps.GetPropVector(tongue, "m_tipPosition");
		//local endPos = victim.GetCenter();
		local endPos = victim.GetAttachmentOrigin(victim.LookupAttachment("medkit"));
		local bendCount = NetProps.GetPropInt(tongue, "m_bendPointCount");
		
		// Give priority to the smoker itself, if visible
		//ret[idx++] <- smoker.GetCenter();
		//ret[idx++] <- startPos;
		
		// Then the bend points (bend points don't move with the characters animation so they are easier target)
		local bendCount = NetProps.GetPropInt(tongue, "m_bendPointCount");
		for (local i = bendCount - 1; i >= 0; i--)
			ret[idx++] <- NetProps.GetPropVectorArray(tongue, "m_bendPositions", i);
		
		// Last some points along the tongue
		local p1 = endPos;
		local p2 = startPos;
		for (local i = bendCount - 1; i >= 0; i--)
		{
			p2 = NetProps.GetPropVectorArray(tongue, "m_bendPositions", i);
			
			local p = p1;
			local v = p2 - p1;
			local d = v.Norm();
			local n = floor(d / section);
			
			for (local x = 0; x < n; x++)
			{
				p = p + (v * section);
				ret[idx++] <- p;
			}
			
			p1 = p2;
		}
		p2 = startPos;
		
		local p = p1;
		local v = p2 - p1;
		local d = v.Norm();
		local n = floor(d / section);
			
		for (local x = 0; x < n; x++)
		{
			p = p + (v * section);
			ret[idx++] <- p;
		}
		
		return ret;
	}

	::Left4Bots.ValidWeaponForSmoker <- function (weapon)
	{
		if (!weapon || !weapon.IsValid())
			return false;
		
		if (NetProps.GetPropInt(weapon, "m_bInReload"))
			return false;
		
		local wclass = weapon.GetClassname();
		local allowed = [ ".*pistol.*", ".*smg.*" ".*rifle.*", ".*shotgun.*", ".*sniper.*"/*, ".*grenade_launcher.*"*/ ];
		foreach (str in allowed)
		{
			local expression = regexp(str);
			if (expression.match(wclass))
				return true;
		}
		return false;
	}
	
	::Left4Bots.GetLandmarkByName <- function (name)
	{
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "info_landmark"))
		{
			if (ent.GetName() == name)
				return ent;
		}
		return null;
	}

	::Left4Bots.GetChangeLevel <- function ()
	{
		local changelevel = Entities.FindByClassname(null, "info_changelevel");
		if (!changelevel)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "GetChangeLevel - info_changelevel was not found, trying trigger_changelevel...");
			changelevel = Entities.FindByClassname(null, "trigger_changelevel");
			if (!changelevel)
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, "GetChangeLevel - trigger_changelevel was not found!");
				return null;
			}
		}
		return changelevel;
	}

	::Left4Bots.GetSaferoomLandmark <- function ()
	{
		local changelevel = Left4Bots.GetChangeLevel();
		if (!changelevel)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "GetSaferoomLandmark - couldn't find a changelevel trigger on this map!");
			return null;
		}
		
		local landmark = NetProps.GetPropString(changelevel, "m_landmarkName");
		local ent = Left4Bots.GetLandmarkByName(landmark);
		if (!ent)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, "GetSaferoomLandmark - couldn't find a landmark entity named: " + landmark);
			return null;
		}
		
		return ent;
	}

	::Left4Bots.GetSaferoomDoor <- function ()
	{
		local landmark = Left4Bots.GetSaferoomLandmark();
		if (!landmark)
			return null;
		
		local door = Entities.FindByClassnameNearest("prop_door_rotating_checkpoint", landmark.GetOrigin(), 2000);
		return door;
	}

	::Left4Bots.GetSaferoomLocation <- function ()
	{
		local landmark = Left4Bots.GetSaferoomLandmark();
		if (!landmark)
			return null;
		
		local door = Entities.FindByClassnameNearest("prop_door_rotating_checkpoint", landmark.GetOrigin(), 2000);
		if (!door)
			return landmark.GetOrigin();
		
		return Vector(landmark.GetOrigin().x, landmark.GetOrigin().y, door.GetOrigin().z);
	}
	
	::Left4Bots.GetNextPathStep <- function (player)
	{
		local ret = null;
		local startflow = GetCurrentFlowDistanceForPlayer(player) + 30;
		local flow = 0;
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "info_remarkable"))
		{
			if (ent.IsValid())
			{
				local f = GetFlowDistanceForPosition(ent.GetOrigin());
				if (f > startflow && (f < flow || flow == 0))
				{
					ret = ent;
					flow = f;
				}
			}
		}
		ent = null;
		while (ent = Entities.FindByClassname(ent, "info_target"))
		{
			if (ent.IsValid())
			{
				local f = GetFlowDistanceForPosition(ent.GetOrigin());
				if (f > startflow && (f < flow || flow == 0))
				{
					ret = ent;
					flow = f;
				}
			}
		}
		if (ret)
			return ret;
		/*
		{
			local start = ret.GetOrigin();
			local end = start - Vector(0, 0, 1000);
			
			local traceTable = { start = start, end = end, mask = TRACE_MASK_SHOT };
			TraceLine(traceTable);
			
			if (traceTable.hit)
				return traceTable.pos;
		}
		*/
		return null;
	}
	
	::Left4Bots.GetBotByUserid <- function (userid)
	{
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot.IsValid() && id == userid)
				return bot;
		}
		return null;
	}
	
	::Left4Bots.BotEscapeFromSpitterSpit <- function (bot, spit = null)
	{
		local p2 = bot.GetOrigin();
		local p1 = p2;
		if (spit)
			p1 = spit.GetOrigin();

		local i = 0;
		while (i < 6 && (p1 - p2).Length() <= SPIT_RADIUS)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + ".TryGetPathableLocationWithin - i = " + i);
			p2 = bot.TryGetPathableLocationWithin(SPIT_RADIUS + 150);
			i++;
		}
		
		if (i == 0)
			return; // No need to move
		
		if (Convars.GetFloat("sb_hold_position") != 0 && !Left4Bots.Settings.keep_holding_position)
		{
			// Stop holding position if one or more bots are going to be hit by the spitter's spit
			Convars.SetValue("sb_hold_position", 0);
			Convars.SetValue("sb_enforce_proximity_range", Left4Bots.Old_sb_enforce_proximity_range);
			if (Left4Bots.Settings.wait_crouch)
				Convars.SetValue("sb_crouch", 0);
		}
		
		Left4Utils.BotCmdMove(bot, p2);
		Left4Timers.AddTimer(null, 3.5, @(params) Left4Bots.BotReset(params.bot, params.force), { bot = bot, force = true });
	}
	
	::Left4Bots.SpitterSpitBlockNav <- function (params)
	{
		local spit = params["spit_ent"];
		if (!spit || !spit.IsValid())
			return;
		
		local kvs = { classname = "script_nav_blocker", origin = spit.GetOrigin(), extent = Vector(SPIT_RADIUS, SPIT_RADIUS, SPIT_RADIUS), teamToBlock = "2", affectsFlow = "0" };
		local ent = g_ModeScript.CreateSingleSimpleEntityFromTable(kvs);
		ent.ValidateScriptScope();
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Created script_nav_blocker: " + ent.GetName());
			
		DoEntFire("!self", "SetParent", "!activator", 0, spit, ent); // I parent the nav blocker to the spit entity so it is automatically killed when the spit is gone
		DoEntFire("!self", "BlockNav", "", 0, null, ent);
	}
	
	::Left4Bots.GetNearestActiveTankWithin <- function (player, min = 80, max = 1000)
	{
		local ret = null;
		local minDist = 1000000;
		foreach (id, tank in ::Left4Bots.Tanks)
		{
			if (!tank.IsValid())
				continue;
			
			if (tank.GetPlayerUserId() == player.GetPlayerUserId())
				continue;

			local dist = (player.GetOrigin() - tank.GetOrigin()).Length();
			if (dist >= min && dist <= max && dist < minDist)
			{
				ret = tank;
				minDist = dist;
			}
		}
		return ret;
	}
	
	::Left4Bots.FindDefibPickupWithin <- function (origin)
	{
		local ent = null;
		while (ent = Entities.FindByClassnameWithin(ent, "weapon_defibrillator", origin, NEARBY_DEFIB_RADIUS))
		{
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_hOwner") <= 0)
				return ent;
		}
	}
	
	::Left4Bots.HasDeathModelWithin <- function (player, radius = 1000)
	{
		foreach (chr, death in ::Left4Bots.Deads)
		{
			if (death.dmodel.IsValid() && (player.GetOrigin() - death.dmodel.GetOrigin()).Length() <= radius)
				return true;
		}
		return false;
	}
	
	::Left4Bots.HasDeathModelWithDefibWithin <- function (player, radius = 1000)
	{
		foreach (chr, death in ::Left4Bots.Deads)
		{
			if (death.dmodel.IsValid() && (player.GetOrigin() - death.dmodel.GetOrigin()).Length() <= radius && Left4Bots.FindDefibPickupWithin(death.dmodel.GetOrigin()) != null)
				return true;
		}
		return false;
	}
	
	::Left4Bots.GetNearestDeathModelWithin <- function (player, radius = 1000)
	{
		local ret = null;
		local minDist = 1000000;
		local isHuman = false;
		foreach (chr, death in ::Left4Bots.Deads)
		{
			if (!death.dmodel.IsValid())
				continue;
			
			local human = (death.player && death.player.IsValid() && !IsPlayerABot(death.player));
			local dist = (player.GetOrigin() - death.dmodel.GetOrigin()).Length();
			if (dist <= radius && Left4Utils.AltitudeDiff(player, death.dmodel) <= BOT_GOTODEFIB_MAX_ALTDIFF && ((human && !isHuman) || (dist < minDist && (!isHuman || human))))
			{
				ret = death.dmodel;
				minDist = dist;
				isHuman = human;
			}
		}
		return ret;
	}
	
	::Left4Bots.GetNearestDeathModelWithDefibWithin <- function (player, radius = 1000)
	{
		local ret = null;
		local minDist = 1000000;
		local isHuman = false;
		foreach (chr, death in ::Left4Bots.Deads)
		{
			if (!death.dmodel.IsValid())
				continue;
			
			local human = (death.player && death.player.IsValid() && !IsPlayerABot(death.player));
			local dist = (player.GetOrigin() - death.dmodel.GetOrigin()).Length();
			if (dist <= radius && Left4Utils.AltitudeDiff(player, death.dmodel) <= BOT_GOTODEFIB_MAX_ALTDIFF && ((human && !isHuman) || (dist < minDist && (!isHuman || human))) && Left4Bots.FindDefibPickupWithin(death.dmodel.GetOrigin()) != null)
			{
				ret = death.dmodel;
				minDist = dist;
				isHuman = human;
			}
		}
		return ret;
	}
	
	::Left4Bots.ShouldGoDefib <- function (player)
	{
		if (Left4Utils.HasDefib(player))
			return Left4Bots.HasDeathModelWithin(player, BOT_GOTODEFIB_RANGE);
		else
			return Left4Bots.HasDeathModelWithDefibWithin(player, BOT_GOTODEFIB_RANGE);
	}
	
	::Left4Bots.GetPickupsToSearch <- function (player, pickup_chainsaw)
	{
		local toFind = {};
		
		if (!Left4Bots.ModeStarted || (NetProps.GetPropInt(player, "m_fFlags") & (1 << 5))) // Don't pick up anything while frozen (to avoid picking up things during the intro scenes)
			return toFind;
		
		local inv = {};
		GetInvTable(player, inv);
		
		if (!(INV_SLOT_THROW in inv))
		{
			if (Left4Bots.Settings.pickup_molotov)
			{
				toFind["weapon_molotov"] <- 0;
				toFind["weapon_molotov_spawn"] <- 0;
			}
			if (Left4Bots.Settings.pickup_pipe_bomb)
			{
				toFind["weapon_pipe_bomb"] <- 0;
				toFind["weapon_pipe_bomb_spawn"] <- 0;
			}
			if (Left4Bots.Settings.pickup_vomitjar)
			{
				toFind["weapon_vomitjar"] <- 0;
				toFind["weapon_vomitjar_spawn"] <- 0;
			}
		}
		
		if (!(INV_SLOT_MEDKIT in inv))
		{
			if (Left4Bots.CanPickupItem["def"])
			{
				toFind["weapon_defibrillator"] <- 0;
				toFind["weapon_defibrillator_spawn"] <- 0;
			}
			if (Left4Bots.Settings.pickup_medkit && Left4Bots.CanPickupItem["kit"])
			{
				toFind["weapon_first_aid_kit"] <- 0;
				toFind["weapon_first_aid_kit_spawn"] <- 0;
			}
			if (Left4Bots.CanPickupItem["exp"])
			{
				toFind["weapon_upgradepack_explosive"] <- 0;
				toFind["weapon_upgradepack_explosive_spawn"] <- 0;
			}
			if (Left4Bots.CanPickupItem["inc"])
			{
				toFind["weapon_upgradepack_incendiary"] <- 0;
				toFind["weapon_upgradepack_incendiary_spawn"] <- 0;
			}
		}
		else
		{
			local itemClass = inv[INV_SLOT_MEDKIT].GetClassname();
			local goMedkit = false;
			local goDefib = Left4Bots.HasDeathModelWithin(player, BOT_GOTODEFIB_RANGE);
			if (!goDefib)
			{
				local c = Left4Bots.Survivors.len();
				
				if ((Left4Bots.Team_Medkits < Left4Bots.Settings.team_min_medkits && Left4Bots.Team_Medkits < c) || Left4Bots.BotWillUseMeds(player))
					goMedkit = true;
				else if (Left4Bots.Team_Defibs < Left4Bots.Settings.team_min_defibs && Left4Bots.Team_Defibs < (c - Left4Bots.Settings.team_min_medkits))
					goDefib = true;
			}
			
			if (itemClass != "weapon_defibrillator" && itemClass != "weapon_first_aid_kit")
			{
				if (goDefib && Left4Bots.CanPickupItem["def"])
				{
					toFind["weapon_defibrillator"] <- 0;
					toFind["weapon_defibrillator_spawn"] <- 0;
				}
				if (Left4Bots.Settings.pickup_medkit && Left4Bots.CanPickupItem["kit"])
				{
					toFind["weapon_first_aid_kit"] <- 0;
					toFind["weapon_first_aid_kit_spawn"] <- 0;
				}
			}
			else if (itemClass != "weapon_defibrillator" && goDefib && Left4Bots.CanPickupItem["def"])
			{
				toFind["weapon_defibrillator"] <- 0;
				toFind["weapon_defibrillator_spawn"] <- 0;
			}
			else if (itemClass != "weapon_first_aid_kit" && goMedkit && Left4Bots.Settings.pickup_medkit && Left4Bots.CanPickupItem["kit"])
			{
				toFind["weapon_first_aid_kit"] <- 0;
				toFind["weapon_first_aid_kit_spawn"] <- 0;
			}
		}
		
		if (Left4Bots.Settings.pickup_pills_adrenaline && !(INV_SLOT_PILLS in inv))
		{
			if (Left4Bots.CanPickupItem["pil"])
			{
				toFind["weapon_pain_pills"] <- 0;
				toFind["weapon_pain_pills_spawn"] <- 0;
			}
			if (Left4Bots.CanPickupItem["adr"])
			{
				toFind["weapon_adrenaline"] <- 0;
				toFind["weapon_adrenaline_spawn"] <- 0;
			}
		}
		
		if (pickup_chainsaw && (!(INV_SLOT_SECONDARY in inv) || inv[INV_SLOT_SECONDARY] == null || inv[INV_SLOT_SECONDARY].GetClassname() != "weapon_chainsaw"))
		{
			toFind["weapon_chainsaw"] <- 0;
			toFind["weapon_chainsaw_spawn"] <- 0;
		}
		
		return toFind;
	}
	
	::Left4Bots.GetNearestPickupWithin <- function (player, radius = 200, pickup_chainsaw = false)
	{
		local ret = null;
		
		local toFind = Left4Bots.GetPickupsToSearch(player, pickup_chainsaw);
		if (toFind.len() <= 0)
			return ret;
		
		local ent = null;
		local minDist = 1000000;
		while (ent = Entities.FindInSphere(ent, player.GetOrigin(), radius))
		{
			if ((ent.GetClassname() in toFind) && NetProps.GetPropInt(ent, "m_hOwner") <= 0 && ent.GetEntityIndex() != Left4Bots.GiveItemIndex1 && ent.GetEntityIndex() != Left4Bots.GiveItemIndex2)
			{
				local dist = (player.GetOrigin() - ent.GetOrigin()).Length();
				if (dist < minDist && Left4Utils.CanTraceTo(player, ent))
				{
					if (ent.GetClassname().find("_spawn") == null || NetProps.GetPropInt(ent, "m_itemCount") > 0)
					{
						ret = ent;
						minDist = dist;
					}
				}
			}
		}
		return ret;
	}
	
	// Returns true if there is at least one survivor being held by SI
	::Left4Bots.SurvivorsHeld <- function ()
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && Left4Utils.IsPlayerHeld(surv))
				return true;
		}
	}
	
	// Returns true if there is at least one survivor incapacitated/hanging from ledge
	::Left4Bots.SurvivorsIncapped <- function ()
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && surv.IsIncapacitated())
				return true;
		}
	}
	
	// Returns true if there is at least one survivor being held by SI or incapacitated/hanging from ledge
	::Left4Bots.SurvivorsHeldOrIncapped <- function ()
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			if (surv.IsValid() && (surv.IsIncapacitated() || Left4Utils.IsPlayerHeld(surv)))
				return true;
		}
	}
	
	// TODO: Left4Utils???
	::Left4Utils.AreOtherSurvivorsNearby <- function (player, origin, radius = 150)
	{
		foreach (id, surv in ::Left4Bots.Survivors)
		{
			if (id == player.GetPlayerUserId() || !surv || !surv.IsValid())
				continue;
			
			if ((surv.GetOrigin() - origin).Length() < radius)
				return true;
		}
		return false;
	}
	
	// TODO: Left4Utils???
	::Left4Utils.IsSomeoneElseHolding <- function (player, weaponClass)
	{
		foreach (id, surv in ::Left4Bots.Survivors)
		{
			if (id == player.GetPlayerUserId() || !surv || !surv.IsValid())
				continue;
			
			local holding = surv.GetActiveWeapon();
			if (holding && holding.IsValid() && holding.GetClassname() == weaponClass)
				return true;
		}
		return false;
	}
	
	::Left4Bots.AddBotThink <- function (bot)
	{
		bot.ValidateScriptScope();
		local scope = bot.GetScriptScope();
		
		scope.GoToEnt <- null;
		scope.GoToEntI <- 0;
		scope.FuncI <- NetProps.GetPropInt(bot, "m_survivorCharacter") % 5; // <- this makes the bots start the sub-think functions in different order so they don't "Use" pickups or do things at the exact same time
		scope.Pause <- false;
		scope.CanPause <- true;
		scope.NeedMove <- 2;
		scope.MovePos <- Vector(0, 0, 0);
		scope.MustReset <- false;
		scope.TargetTank <- null;
		scope.TargetPos <- null;
		scope.Chainsaw <- false;
		scope.HoldItem <- null;
		scope.LastUseTS <- 0;
		
		scope["L4B_BotThink"] <- ::Left4Bots.L4B_BotThink;
		scope["BotThink_PickupItems"] <- ::Left4Bots.BotThink_PickupItems;
		scope["BotThink_UseDefib"] <- ::Left4Bots.BotThink_UseDefib;
		scope["BotThink_Scavenge"] <- ::Left4Bots.BotThink_Scavenge;
		scope["BotThink_ManualOrders"] <- ::Left4Bots.BotThink_ManualOrders;
		scope["BotThink_ThrowNades"] <- ::Left4Bots.BotThink_ThrowNades;
		scope["BotThink_Misc"] <- ::Left4Bots.BotThink_Misc;
		scope["MoveTo"] <- ::Left4Bots.MoveTo;

		AddThinkToEnt(bot, "L4B_BotThink");
	}
	
	::Left4Bots.RemoveBotThink <- function (bot)
	{
		AddThinkToEnt(bot, null);
	}
	
	::Left4Bots.ClearBotThink <- function ()
	{
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot.IsValid())
				AddThinkToEnt(bot, null);
		}
	}
	
	::Left4Bots.BotShove <- function (bot, attacker)
	{
		if (!bot || !attacker || !bot.IsValid() || !attacker.IsValid())
			return;
		
		if (Time() < NetProps.GetPropFloat(bot, "m_flNextShoveTime"))
			return;
		
		if (NetProps.GetPropInt(bot, "m_reviveTarget") > 0 || NetProps.GetPropInt(bot, "m_iCurrentUseAction") > 0)
			return;
		
		//bot.ValidateScriptScope();
		local scope = bot.GetScriptScope();
		if (!("GoToEnt" in scope))
		{
			Left4Bots.Log(LOG_LEVEL_ERROR, "Bot " + bot.GetPlayerName() + " has no 'GoToEnt' in scope");
			return;
		}
		
		if (scope.GoToEnt != null)
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " SHOVE");
			
			Left4Bots.BotPressButton(bot, BUTTON_SHOVE, BUTTON_HOLDTIME_TAP, attacker, SHOVE_COMMON_DELTAPITCH, 0, true);
			return;
		}
		
		local holdingItem = bot.GetActiveWeapon();
		if (holdingItem && holdingItem.GetClassname() != "weapon_first_aid_kit" && NetProps.GetPropInt(holdingItem, "m_bInReload"))
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " SHOVE 2");
			
			Left4Bots.BotPressButton(bot, BUTTON_SHOVE, BUTTON_HOLDTIME_TAP, attacker, SHOVE_COMMON_DELTAPITCH, 0, true);
		}
	}
	
	::Left4Bots.BotShove2 <- function (bot, attacker, deltapitch = -9.5)
	{
		if (!bot || !attacker || !bot.IsValid() || !attacker.IsValid())
			return;
		
		if (Time() < NetProps.GetPropFloat(bot, "m_flNextShoveTime"))
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, bot.GetPlayerName() + " SHOVE2");
			
		Left4Bots.BotPressButton(bot, BUTTON_SHOVE, BUTTON_HOLDTIME_TAP, attacker, deltapitch, 0, true);
	}
	
	::Left4Bots.BotReset <- function (bot, force = false)
	{
		if (!bot || !bot.IsValid())
			return;
		
		//bot.ValidateScriptScope();
		local scope = bot.GetScriptScope();
		if (!("GoToEnt" in scope))
		{
			Left4Bots.Log(LOG_LEVEL_ERROR, "Bot " bot.GetPlayerName() + " has no 'GoToEnt' in scope");
			return;
		}
		
		if (force || (scope.GoToEnt != null && scope.CanPause))
			scope.MustReset = true;
	}

	::Left4Bots.GetSurvivorByCharacter <- function (character)
	{
		foreach (id, bot in ::Left4Bots.Survivors)
		{
			if (bot.IsValid() && NetProps.GetPropInt(bot, "m_survivorCharacter") == character)
				return bot;
		}
		return null;
	}

	::Left4Bots.GetBotByCharacter <- function (character)
	{
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (bot.IsValid() && NetProps.GetPropInt(bot, "m_survivorCharacter") == character)
				return bot;
		}
		return null;
	}

	::Left4Bots.ResetCanMove <- function (params)
	{
		local player = params["player"];
		
		local scope = bot.GetScriptScope();
		scope.CanMove = true;
	}

	::Left4Bots.UnfreezePlayer <- function (params)
	{
		local player = params["player"];
		
		if (player && player.IsValid())
			NetProps.SetPropInt(player, "m_fFlags", NetProps.GetPropInt(player, "m_fFlags") & ~(1 << 5)); // unset FL_FROZEN
	}
	
	// destination can be either a vector or an entity
	::Left4Bots.BotPressButton <- function (bot, button, holdTime, destination = null, deltaPitch = 0, deltaYaw = 0, lockLook = false, unlockLookDelay = 0)
	{
		if (lockLook)
			NetProps.SetPropInt(bot, "m_fFlags", NetProps.GetPropInt(bot, "m_fFlags") | (1 << 5)); // set FL_FROZEN
		
		if (destination != null || deltaPitch != 0 || deltaYaw != 0)
			Left4Utils.BotLookAt(bot, destination, deltaPitch, deltaYaw);
		
		Left4Utils.PlayerForceButton(bot, button);
		
		if (holdTime > 0)
		{
			Left4Timers.AddTimer(null, holdTime, @(params) Left4Utils.PlayerUnForceButton(params.player, params.button), { player = bot, button = button });
		
			if (lockLook)
				Left4Timers.AddTimer(null, holdTime + unlockLookDelay, Left4Bots.UnfreezePlayer, { player = bot });
		}
	}
	
	::Left4Bots.BotSwitchToAnotherWeapon <- function (bot)
	{
		local last_weapon = NetProps.GetPropEntity(bot, "m_hLastWeapon");
		if (!last_weapon)
			last_weapon = Left4Utils.GetInventoryItemInSlot(bot, INV_SLOT_PRIMARY);
		if (!last_weapon)
			last_weapon = Left4Utils.GetInventoryItemInSlot(bot, INV_SLOT_SECONDARY);
		
		if (last_weapon)
			bot.SwitchToItem(last_weapon.GetClassname());
	}
	
	::Left4Bots.DoThrowNade <- function (bot, destination = null, deltaPitch = 0, deltaYaw = 0)
	{
		local weapon = bot.GetActiveWeapon();
		if (!weapon)
			return;
		weapon = weapon.GetClassname();
		
		if (weapon == "weapon_molotov")
		{
			if (destination && destination.IsValid() && !destination.IsOnFire() && !destination.IsDead() && !destination.IsDying() && !destination.IsIncapacitated() && destination.GetHealth() >= 1500 && ((Time() - Left4Bots.LastMolotovTime) >= THROW_MOLOTOV_MININTERVAL) && !Left4Utils.AreOtherSurvivorsNearby(bot, destination.GetOrigin(), MOLOTOV_SURVIVORS_MINDISTANCE) && Left4Utils.CanTraceTo(bot, destination))
				Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, destination, deltaPitch, deltaYaw, true, 1);
			else
				Left4Bots.BotSwitchToAnotherWeapon(bot);
		}
		else if (weapon == "weapon_pipe_bomb" || weapon == "weapon_vomitjar")
		{
			if ((Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL)
				Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, destination, deltaPitch, deltaYaw, true, 1);
			else
				Left4Bots.BotSwitchToAnotherWeapon(bot);
		}
	}
	
	::Left4Bots.DoThrowNade2 <- function (bot, pos = null, deltaPitch = 0, deltaYaw = 0)
	{
		local weapon = bot.GetActiveWeapon();
		if (!weapon)
			return;
		weapon = weapon.GetClassname();
		
		if (pos && (weapon == "weapon_molotov" || weapon == "weapon_pipe_bomb" || weapon == "weapon_vomitjar"))
			Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, pos, deltaPitch, deltaYaw, true, 1);
		else
			Left4Bots.BotSwitchToAnotherWeapon(bot);
	}
	
	// destination (Entity/Vector) = where to look at when throwing the nade (if null, the destination angle will be the actual eye angle of the bot)
	// deltaPitch (float) = vertical (pitch) offset relative to the calculated destination angle ( <0: higher, >0: lower ).
	//                    ^ Useful to throw a molotov in front of the tank instead of directly at him when he is running towards the bot.
	// deltaYaw (float) = horizontal (yaw) offset relative to the calculated destination angle ( <0: right, >0: left ).
	::Left4Bots.BotThrowNade <- function (bot, weapon, destination = null, deltaPitch = 0, deltaYaw = 0)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + bot.GetPlayerName() + " throwing " + weapon);
		
		bot.SwitchToItem(weapon);
	
		Left4Timers.AddTimer(null, 1, @(params) Left4Bots.DoThrowNade(params.bot, params.destination, params.deltaPitch, params.deltaYaw), { bot = bot, destination = destination, deltaPitch = deltaPitch, deltaYaw = deltaYaw });
	}
	
	// This makes no checks on previous throws cooldowns and anything, it just force to throw the item
	// destination (Entity/Vector) = where to look at when throwing the nade (if null, the destination angle will be the actual eye angle of the bot)
	// deltaPitch (float) = vertical (pitch) offset relative to the calculated destination angle ( <0: higher, >0: lower ).
	//                    ^ Useful to throw a molotov in front of the tank instead of directly at him when he is running towards the bot.
	// deltaYaw (float) = horizontal (yaw) offset relative to the calculated destination angle ( <0: right, >0: left ).
	::Left4Bots.BotThrowNade2 <- function (bot, weapon, destination = null, deltaPitch = 0, deltaYaw = 0)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Bot " + bot.GetPlayerName() + " throwing " + weapon);
		
		bot.SwitchToItem(weapon);
	
		Left4Timers.AddTimer(null, 1, @(params) Left4Bots.DoThrowNade2(params.bot, params.destination, params.deltaPitch, params.deltaYaw), { bot = bot, destination = destination, deltaPitch = deltaPitch, deltaYaw = deltaYaw });
	}
	
	::Left4Bots.BotWillUseMeds <- function (bot)
	{
		local totalHealth = bot.GetHealth() + bot.GetHealthBuffer();
		local inv = {};
		GetInvTable(bot, inv);

		if (totalHealth < 45 && (INV_SLOT_PILLS in inv))
			return true;
		
		if (totalHealth < 30 && (INV_SLOT_MEDKIT in inv) && inv[INV_SLOT_MEDKIT].GetClassname() == "weapon_first_aid_kit")
			return true;
		
		return false;
	}
	
	::Left4Bots.BotShootAtEntity <- function (params)
	{
		local bot = params["bot"];
		local target = params["target"];
		
		Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, target, 0, 0, true);
	}
	
	::Left4Bots.BotShootAtEntityAttachment <- function (params)
	{
		local bot = params["bot"];
		local target = params["target"];
		local attachmentid = params["attachmentid"];
		
		if (!target || !target.IsValid())
			return;
		
		Left4Bots.BotPressButton(bot, BUTTON_ATTACK, BUTTON_HOLDTIME_TAP, target.GetAttachmentOrigin(attachmentid), 0, 0, true);
	}
	
	::Left4Bots.GetBotAtIndex <- function (index)
	{
		local i = 0;
		foreach (id, bot in ::Left4Bots.Bots)
		{
			if (i == index || index >= Left4Bots.Bots.len())
				return bot;
			i++;
		}
		return null;
	}
	
	::Left4Bots.IsBotReadyForOrder <- function (bot, ignoreOrders = false)
	{
		if (ignoreOrders)
			return (bot && bot.IsValid() && !bot.IsDead() && !bot.IsDying() && !bot.IsIncapacitated() && NetProps.GetPropInt(bot, "m_reviveTarget") <= 0 && NetProps.GetPropInt(bot, "m_iCurrentUseAction") <= 0 && !Left4Utils.IsPlayerHeld(bot));
		else
			return (bot && bot.IsValid() && !bot.IsDead() && !bot.IsDying() && !bot.IsIncapacitated() && NetProps.GetPropInt(bot, "m_reviveTarget") <= 0 && NetProps.GetPropInt(bot, "m_iCurrentUseAction") <= 0 && !Left4Utils.IsPlayerHeld(bot) && !(bot.GetPlayerUserId() in Left4Bots.ScavengeOrders) && !(bot.GetPlayerUserId() in Left4Bots.ManualOrders));
	}
	
	::Left4Bots.GetRandomAvailableBot <- function ()
	{
		local n = Left4Bots.Bots.len();
		local i = RandomInt(0, n - 1);
		local bot = Left4Bots.GetBotAtIndex(i);
		local c = 1;
		
		while (bot == null || (bot.GetPlayerUserId() in Left4Bots.ScavengeOrders) || (bot.GetPlayerUserId() in Left4Bots.ManualOrders))
		{
			if (c > n)
				return null;
			
			if (++i >= n)
				i = 0;
			
			bot = Left4Bots.GetBotAtIndex(i);
			
			c++;
		}
		return bot;
	}
	
	::Left4Bots.IsScavengeOrder <- function (entIndex)
	{
		foreach (id, ent in Left4Bots.ScavengeOrders)
		{
			if (ent && ent.GetEntityIndex() == entIndex)
				return true;
		}
		return false;
	}
	
	::Left4Bots.HasManualOrderTarget <- function (targetName)
	{
		foreach (id, order in Left4Bots.ManualOrders)
		{
			if (order.dest && order.dest.IsValid() && order.dest.GetName() == targetName)
				return true;
		}
		return false;
	}
	
	::Left4Bots.RemoveManualOrdersByTarget <- function (targetName)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Removing manual orders with target " + targetName);
		foreach (id, order in Left4Bots.ManualOrders)
		{
			if (order.dest && order.dest.IsValid() && order.dest.GetName() == targetName)
				delete Left4Bots.ManualOrders[id];
		}
	}
	
	::Left4Bots.GetAvailableScavengeItems <- function (type)
	{
		//	- Spawned gascans have class "weapon_gascan" when they have been picked up by players; after spawn too but i'm not 100% sure.
		//	  They can have different m_nSkin (default is 0).
		//	  In scavenge maps (regardless the gamemode) they are spawned by weapon_scavenge_item_spawn
		//	
		//	- cola's class can be "prop_physics" after spawn but it becomes "weapon_cola_bottles" after being picked up by a player, model should be always the same.
		
		local model = "models/props_junk/gascan001a.mdl";
		if (type == SCAV_TYPE_COLA)
			model = "models/w_models/weapons/w_cola.mdl";
		
		local t = {};
		local ent = null;
		local i = -1;
		while (ent = Entities.FindByModel(ent, model))
		{
			if (ent.IsValid() && (Left4Bots.Settings.scavenge_pour || (ent.GetOrigin() - Left4Bots.ScavengeUseTarget.GetOrigin()).Length() >= SCAVENGE_DROP_RADIUS) && NetProps.GetPropInt(ent, "m_hOwner") <= 0 && !Left4Bots.IsScavengeOrder(ent.GetEntityIndex()))
				t[++i] <- ent;
		}
		return t;
	}
	
	::Left4Bots.ScavengeManager <- function (params)
	{
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.ScavengeManager");
		
		if (!Left4Bots.ScavengeEnabled)
			return;
		
		if (!Left4Bots.SetScavengeUseTarget())
			return;
		
		local num_bots = Left4Bots.Settings.scavenge_max_bots;
		if (Left4Bots.MapName == "c1m2_streets")
			num_bots = 1;
		
		while (Left4Bots.ScavengeOrders.len() < num_bots && Left4Bots.ScavengeOrders.len() < Left4Bots.Bots.len())
		{
			local randomBot = Left4Bots.GetRandomAvailableBot();
			if (!randomBot)
				break;
			
			Left4Bots.ScavengeOrders[randomBot.GetPlayerUserId()] <- null;
			
			Left4Bots.Log(LOG_LEVEL_INFO, "Added scavenge order slot for bot " + randomBot.GetPlayerName());
			
			DoEntFire("!self", "SpeakResponseConcept", Left4Bots.RandomYesAnswer(), 0, null, randomBot);
			
			if (Left4Bots.C1M2CanOpenStoreDoors && !Left4Bots.HasManualOrderTarget("store_doors"))
			{
				local storeDoors = Entities.FindByName(null, "store_doors");
				if (storeDoors)
				{
					local state = NetProps.GetPropInt(storeDoors, "m_eDoorState");
					if (state == 0) // door closed (2 = open)
					{
						local pos = storeDoors.GetOrigin() + (storeDoors.GetAngles().Forward() * 15) - (storeDoors.GetAngles().Left() * 30);
						
						// send the order to the bot
						Left4Bots.ManualOrders[randomBot.GetPlayerUserId()] <- { from = null, stime = Time(), dest = storeDoors, pos = pos, ordertype = "door", canpause = true };
					
						Left4Bots.Log(LOG_LEVEL_INFO, "Manual order to bot " + randomBot.GetPlayerName() + " - destination: store_doors");
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order set, new count: " + Left4Bots.ManualOrders.len());
					}
				}
			}
		}
		
		while (Left4Bots.ScavengeOrders.len() > Left4Bots.Settings.scavenge_max_bots)
		{
			local delId = -1;
			foreach (id, o in Left4Bots.ScavengeOrders)
			{
				delId = id;
				break;
			}
			if (delId >= 0)
			{
				delete ::Left4Bots.ScavengeOrders[delId];
				
				Left4Bots.Log(LOG_LEVEL_INFO, "Removed scavenge order slot for bot with id " + delId);
			}
			else
				break;
		}
		
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "ScavengeOrders len is " + Left4Bots.ScavengeOrders.len());
		
		if (Left4Bots.ScavengeOrders.len() <= 0)
			return; // no bot is available for scavenge
		
		local findNewItems = false;
		
		// First check if the current orders contain invalid/removed/stolen items
		foreach (id, ent in Left4Bots.ScavengeOrders)
		{
			if (ent)
			{
				if (!ent.IsValid())
				{
					Left4Bots.ScavengeOrders[id] <- null;
				
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Cleaned an invalid order for bot with userid: " + id);
					
					findNewItems = true;
				}
				else
				{
					local owner = NetProps.GetPropEntity(ent, "m_hOwner");
					if (owner != null && (!("GetPlayerUserId" in owner) || owner.GetPlayerUserId() != id))
					{
						Left4Bots.ScavengeOrders[id] <- null;
					
						Left4Bots.Log(LOG_LEVEL_DEBUG, "Cleaned a stolen order for bot with userid: " + id);
						
						findNewItems = true;
					}
				}
			}
			else
				findNewItems = true;
		}
		
		if (!findNewItems)
			return; // nothing to do here

		local scavengeItems = Left4Bots.GetAvailableScavengeItems(Left4Bots.ScavengeUseType);
		
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "scavengeItems len is " + scavengeItems.len());
		
		if (scavengeItems.len() <= 0)
			return; // nothing to do here
		
		// Assign the orders
		foreach (id, ent in Left4Bots.ScavengeOrders)
		{
			if (ent == null)
			{
				local bot = Left4Bots.GetBotByUserid(id);
				if (!bot)
				{
					// This shouldn't happen
					Left4Bots.Log(LOG_LEVEL_ERROR, "GetBotByUserid returned null!!!");
					continue;
				}
				
				local idx = Left4Utils.GetNearestEntityInList(bot, scavengeItems);
				Left4Bots.ScavengeOrders[id] <- scavengeItems[idx];
				
				Left4Bots.Log(LOG_LEVEL_INFO, "Assigned a scavenge order to bot " + bot.GetPlayerName());
				
				delete scavengeItems[idx];
				if (scavengeItems.len() <= 0)
					break;
			}
		}
	}
	
	::Left4Bots.ManualOrderComplete <- function (botid)
	{
		local ordertype = "";
		
		if (botid in ::Left4Bots.ManualOrders)
		{
			ordertype = Left4Bots.ManualOrders[botid].ordertype;
			delete ::Left4Bots.ManualOrders[botid];
		}
				
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order complete, new count: " + Left4Bots.ManualOrders.len());
		
		//Left4Timers.AddTimer(null, 0.1, Left4Bots.OnManualOrderComplete, { botid = botid, ordertype = ordertype });
	}
	
	::Left4Bots.OnManualOrderComplete <- function (botid, ordertype)
	{
		// ?
	}
	
	::Left4Bots.HasManualOrdersOfType <- function (orderType)
	{
		foreach (id, order in ::Left4Bots.ManualOrders)
		{
			if (order.ordertype == orderType)
				return true;
		}
		return false;
	}
	
	::Left4Bots.HandleSBUnstick <- function ()
	{
		local sb_unstick = Convars.GetFloat("sb_unstick");
		local hasLeadOrder = Left4Bots.HasManualOrdersOfType("lead");
		
		if (sb_unstick != 0 && hasLeadOrder)
		{
			Convars.SetValue("sb_unstick", 0);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "sb_unstick disabled");
		}
		else if (sb_unstick != Left4Bots.Old_sb_unstick && !hasLeadOrder)
		{
			Convars.SetValue("sb_unstick", Left4Bots.Old_sb_unstick);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "sb_unstick restored");
		}
	}
	
	::Left4Bots.HealingCheck <- function (params)
	{
		Left4Bots.Log(LOG_LEVEL_DEBUG, "HealingCheck");
		
		local bot = params["bot"];
		if (!bot || !bot.IsValid())
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "HealingCheck - bot: " + bot.GetPlayerName());
		
		local order = params["order"];
		if (!order)
			return;
		
		local target = NetProps.GetPropEntity(bot, "m_useActionTarget");
		if (IsPlayerABot(bot) && target && order.dest && order.dest.IsValid() && target.GetPlayerUserId() == order.dest.GetPlayerUserId())
		{
			// All OK, keep holding
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "HealingCheck - OK - dest: " + order.dest.GetPlayerName());
			
			Left4Timers.AddTimer(null, order.holdtime - 0.8, @(params) Left4Utils.PlayerUnForceButton(params.player, params.button), { player = bot, button = BUTTON_SHOVE });
			Left4Timers.AddTimer(null, order.holdtime - 0.8, Left4Bots.UnfreezePlayer, { player = bot });
		}
		else
		{
			// Abort
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, "HealingCheck - Abort");
			
			Left4Utils.PlayerUnForceButton(bot, BUTTON_SHOVE);
			Left4Bots.UnfreezePlayer({ player = bot });
			
			if (IsPlayerABot(bot))
				::Left4Bots.ManualOrders[bot.GetPlayerUserId()] <- order; // Retry
		}
	}
	
	::Left4Bots.IsCarAlarmTriggered <- function (alarm)
	{
		if (!alarm || !alarm.IsValid())
			return false;
		
		if (NetProps.GetPropInt(alarm, "m_bDisabled"))
			return true;
		
		local ambient_generic = null;
		while (ambient_generic = Entities.FindByClassname(ambient_generic, "ambient_generic"))
		{
			if (NetProps.GetPropString(ambient_generic, "m_sSourceEntName") == alarm.GetName() && NetProps.GetPropString(ambient_generic, "m_iszSound") == "Car.Alarm" && NetProps.GetPropInt(ambient_generic, "m_fActive"))
				return true;
		}
		return false;
	}
	
	::Left4Bots.TriggerCarAlarm <- function (player, alarm)
	{
		if (!player || !alarm || !player.IsValid() || !alarm.IsValid() || alarm.GetClassname() != "prop_car_alarm" || Left4Bots.IsCarAlarmTriggered(alarm))
			return;
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "TriggerCarAlarm - player: " + player.GetPlayerName());
		
		DoEntFire("!self", "SurvivorStandingOnCar", "", 0, alarm, alarm); // Activator is who triggers the alarm but it doesn't work with bots. This way it triggers but i need to play the vocalizer lines manually.
		
		local actor = Left4Utils.GetActorFromSurvivor(player);
		
		DoEntFire("!self", "AddContext", "subject:" + actor, 0, null, player);
		DoEntFire("!self", "AddContext", "panictype:CarAlarm", 0, null, player);
		DoEntFire("!self", "SpeakResponseConcept", "PanicEvent", 0, null, player);
		DoEntFire("!self", "ClearContext", "", 0, null, player);
		
		foreach (surv in ::Left4Utils.GetOtherAliveSurvivors(player))
		{
			DoEntFire("!self", "AddContext", "subject:" + actor, 0, null, surv);
			DoEntFire("!self", "AddContext", "panictype:CarAlarm", 0, null, surv);
			DoEntFire("!self", "SpeakResponseConcept", "PanicEvent", 0, null, surv);
			DoEntFire("!self", "ClearContext", "", 0, null, surv);
		}
	}
	
	::Left4Bots.BtnListenerThinkFunc <- function ()
	{
		foreach (surv in ::Left4Bots.Survivors)
		{
			//if (surv && surv.IsValid() && !IsPlayerABot(surv) && (NetProps.GetPropInt(surv, "m_afButtonPressed") & BUTTON_SHOVE) != 0)
			if (surv && surv.IsValid() && !IsPlayerABot(surv))
			{
				if ((surv.GetButtonMask() & BUTTON_SHOVE) != 0 || (NetProps.GetPropInt(surv, "m_afButtonPressed") & BUTTON_SHOVE) != 0) // <- With med items (pills and adrenaline) the shove button is disabled when looking at teammates and GetButtonMask never sees the button down but m_afButtonPressed still does
				{
					if (!(surv.GetPlayerUserId() in Left4Bots.BtnStatus_Shove) || !Left4Bots.BtnStatus_Shove[surv.GetPlayerUserId()])
					{
						Left4Bots.Log(LOG_LEVEL_DEBUG, surv.GetPlayerName() + " BUTTON_SHOVE");
						
						Left4Bots.BtnStatus_Shove[surv.GetPlayerUserId()] <- true;

						if (Left4Bots.Settings.nades_give || Left4Bots.Settings.meds_give)
							Left4Timers.AddTimer(null, 0.0, Left4Bots.OnShovePressed, { player = surv });
					}
				}
				else
					Left4Bots.BtnStatus_Shove[surv.GetPlayerUserId()] <- false;
			}
		}
		
		return 0.01;
	}
	
	::Left4Bots.OnShovePressed <- function (params)
	{
		local attacker = params["player"];
		if (!attacker || !attacker.IsValid())
			return;
		
		local attackerItem = attacker.GetActiveWeapon();
		if (!attackerItem || !attackerItem.IsValid())
			return;
		
		local slot = Left4Utils.FindSlotForItemClass(attacker, attackerItem.GetClassname());
		if (!(slot == INV_SLOT_THROW && Left4Bots.Settings.nades_give) && !(slot == INV_SLOT_PILLS && Left4Bots.Settings.meds_give))
			return;
		
		local attackerItemClass = attackerItem.GetClassname();
		local attackerItemSkin = NetProps.GetPropInt(attackerItem, "m_nSkin");
		
		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnShovePressed - " + attacker.GetPlayerName() + " - " + attackerItemClass + " - " + attackerItemSkin);
		
		local t = Time();
		if (((attackerItemClass == "weapon_pipe_bomb" || attackerItemClass == "weapon_vomitjar") && (t - Left4Bots.LastNadeTime) < 1.5) || (attackerItemClass == "weapon_molotov" && (t - Left4Bots.LastMolotovTime) < 1.5))
			return; // Preventing an exploit that allows you to give the item you just threw away. Throw the nade and press RMB immediately, the item is still seen in the players inventory (Drop event comes after a second), so the item was duplicated.
		
		local victim = Left4Utils.GetPickerEntity(attacker, 270, 0.95);
		if (!victim || !victim.IsValid() || victim.GetClassname() != "player" || !victim.IsSurvivor())
			return;

		Left4Bots.Log(LOG_LEVEL_DEBUG, "Left4Bots.OnShovePressed - attacker: " + attacker.GetPlayerName() + " - victim: " + victim.GetPlayerName() + " - weapon: " + attackerItemClass + " - skin: " + attackerItemSkin);
		
		local victimItem = Left4Utils.GetInventoryItemInSlot(victim, slot);
		if (!victimItem && slot == INV_SLOT_THROW)
		{
			DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, attacker);
			
			Left4Bots.GiveItemIndex1 = attackerItem.GetEntityIndex();
			
			attacker.DropItem(attackerItemClass);

			//victim.GiveItemWithSkin(attackerItemClass, attackerItemSkin);
			Left4Utils.GiveItemWithSkin(victim, attackerItemClass, attackerItemSkin);
			
			Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = attacker, player2 = victim, weapon = attackerItem });
			
			if (IsPlayerABot(victim))
				Left4Bots.LastGiveItemTime = Time();
		}
		else if (victimItem && IsPlayerABot(victim))
		{
			// Swap
			local victimItemClass = victimItem.GetClassname();
			local victimItemSkin = NetProps.GetPropInt(victimItem, "m_nSkin");
			
			if (victimItemClass != attackerItemClass || victimItemSkin != attackerItemSkin)
			{
				DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, attacker);
				DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, victim);
				
				Left4Bots.GiveItemIndex1 = attackerItem.GetEntityIndex();
				Left4Bots.GiveItemIndex2 = victimItem.GetEntityIndex();
				
				attacker.DropItem(attackerItemClass);
				victim.DropItem(victimItemClass);
				
				//attacker.GiveItemWithSkin(victimItemClass, victimItemSkin);
				Left4Utils.GiveItemWithSkin(attacker, victimItemClass, victimItemSkin);
				//victim.GiveItemWithSkin(attackerItemClass, attackerItemSkin);
				Left4Utils.GiveItemWithSkin(victim, attackerItemClass, attackerItemSkin);
				
				Left4Timers.AddTimer(null, 0.1, Left4Bots.SwapNades, { player1 = attacker, weapon1 = victimItem, player2 = victim, weapon2 = attackerItem });
			}
		}
	}
	
	::Left4Bots.HoldItemStop <- function (bot)
	{
		if (Left4Utils.IsButtonDisabled(bot, BUTTON_ATTACK))
		{
			Left4Utils.PlayerEnableButton(bot, BUTTON_ATTACK | BUTTON_USE);
			
			local w = Left4Utils.GetInventoryItemInSlot(bot, INV_SLOT_PRIMARY);
			if (w)
				NetProps.SetPropEntity(w, "m_hOwner", bot);
			w = Left4Utils.GetInventoryItemInSlot(bot, INV_SLOT_SECONDARY);
			if (w)
				NetProps.SetPropEntity(w, "m_hOwner", bot);
		}
		
		if (!IsPlayerABot(bot))
			return;
		
		Left4Bots.DropHoldItem(bot);
		
		local scope = bot.GetScriptScope();
		if (scope)
			scope.HoldItem <- null;
	}
	
	::Left4Bots.DropHoldItem <- function (bot)
	{
		local aw = bot.GetActiveWeapon();
		if (aw && aw.IsValid() && aw.GetClassname() in ::Left4Bots.HoldItems)
			Left4Bots.BotPressButton(bot, BUTTON_USE, BUTTON_HOLDTIME_TAP);
	}
	
	// Runs in the scope of the bot entity
	::Left4Bots.MoveTo <- function (dest, nMove = 0)
	{
		if (nMove > 0)
			NeedMove = nMove;
		
		if (NeedMove <= 0 && (dest - MovePos).Length() <= 5) // <- This checks if the destination entity moved after the bot started moving towards it and forces a move command to the new entity position if the entity moved
			return true;
		
		if (!(NetProps.GetPropInt(self, "m_fFlags") & (1 << 5)))
		{
			if (!dest || (dest.x == 0 && dest.y == 0 && dest.z == 0)) // Yes, for some reason it happens sometimes
			{
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " MOVE -> (0,0,0)!!!");
				
				return false;
			}
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " MOVE -> " + dest);
			
			Left4Utils.BotCmdMove(self, dest);
			MovePos = dest;
		
			NeedMove--;
		}
		
		return true;
	}
	
	::Left4Bots.PickupFailsafe <- function (bot, item)
	{
		if (!item || !item.IsValid() || !bot || !bot.IsValid())
			return;
		
		local cls = Left4Utils.StringReplace(item.GetClassname(), "_spawn", "");
		if (Left4Utils.HasItem(bot, cls))
			return; // Already got it
		
		DoEntFire("!self", "Use", "", 0, bot, item); // <- make sure i pick this up even if the real pickup (with the button) fails or i will be stuck here forever
		Left4Bots.OnPlayerUse(bot, item, 1); // ^this doesn't trigger the event so i do it myself
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_PickupItems <- function ()
	{
		if (self.IsIncapacitated())
		{
			if (GoToEnt)
				return false;
			else
				return null;
		}
	
		local pickup = Left4Bots.GetNearestPickupWithin(self, BOT_GOTOPICKUP_RANGE, Chainsaw);
		if (pickup)
		{
			if (Left4Bots.Settings.pickup_animation)
			{
				// New method with animation
				if ((self.GetOrigin() - pickup.GetOrigin()).Length() <= BOT_PICKUP_RANGE2)
				{
					Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, pickup, 0, 0, true);
					Left4Timers.AddTimer(null, 0.2, @(params) Left4Bots.PickupFailsafe(params.bot, params.item), { bot = self, item = pickup });
					//DoEntFire("!self", "Use", "", 0.1, self, pickup); // <- make sure i pick this up even if the real pickup (with the button) fails or i will be stuck here forever
					
					if (GoToEnt && GoToEnt.IsValid() && GoToEnt.GetEntityIndex() == pickup.GetEntityIndex())
						return false; // i got my pickup
				}
			}
			else
			{
				// Old method without animation
				if ((self.GetOrigin() - pickup.GetOrigin()).Length() <= BOT_PICKUP_RANGE)
				{
					//DoEntFire("!self", "Use", "", 0, self, pickup);
					Left4Bots.PickupFailsafe(self, pickup);

					if (GoToEnt && GoToEnt.IsValid() && GoToEnt.GetEntityIndex() == pickup.GetEntityIndex())
						return false; // i got my pickup
				}
			}
		}
	
		if (GoToEnt)
		{
			if (GoToEntI != FuncI)
				return null; // i'm already moving for something else

			if (!pickup || !GoToEnt.IsValid() || NetProps.GetPropInt(GoToEnt, "m_hOwner") > 0 || (self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= BOT_GOTO_END_RADIUS)
				return false; // my item got picked up by someone else or i reached my pickup but i didn't pick it up (shouldn't happen, maybe BOT_GOTO_END_RADIUS > BOT_PICKUP_RANGE ?)
			
			//local nearestSurv = Left4Bots.GetNearestAliveSurvivor(self);
			//local nearestSurv = Left4Bots.GetNearestAliveHumanSurvivor(self);
			//if (nearestSurv && (nearestSurv.GetOrigin() - self.GetOrigin()).Length() > Left4Bots.Settings.pickup_max_separation)
			if (Left4Bots.IsFarFromHumanSurvivors(self, Left4Bots.Settings.pickup_max_separation))
				return false; // cancel my current move towards some pickup, i'm too far from the human survivors
			
			if (!MoveTo(GoToEnt.GetOrigin()))
				return false;
			
			return null; // keep traveling towards my pickup
		}
		
		if (pickup == null)
			return null; // i didn't find any pickup
		
		if (Left4Bots.SurvivorsHeldOrIncapped())
			return null; // Teammates need help, temporarily ignore pickups
		
		//local nearestSurv = Left4Bots.GetNearestAliveSurvivor(self);
		//local nearestSurv = Left4Bots.GetNearestAliveHumanSurvivor(self);
		//if (!nearestSurv || (nearestSurv.GetOrigin() - self.GetOrigin()).Length() <= Left4Bots.Settings.pickup_max_separation)
		if (!Left4Bots.IsFarFromHumanSurvivors(self, Left4Bots.Settings.pickup_max_separation))
		{
			if (!MoveTo(pickup.GetOrigin(), 2))
				return false;
			return pickup; // let's move towards this pickup
		}
		
		return null; // ignore this pickup, i'm too far from the human survivors
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_ThrowNades <- function ()
	{
		/*
		if (self.IsIncapacitated())
		{
			if (GoToEnt)
				return false;
			else
				return null;
		}
		*/
		
		local nearestTank = Left4Bots.GetNearestActiveTankWithin(self, 0, RETREAT_FROM_TANK_DINSTANCE);
		if (nearestTank && !nearestTank.IsDead() && !nearestTank.IsDying() && !nearestTank.IsIncapacitated())
		{
			Left4Utils.BotCmdRetreat(self, nearestTank);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " RETREAT");
		}
		
		local humanSurv = NetProps.GetPropEntity(self, "m_lookatPlayer");
		if (/*!NetProps.GetPropInt(self, "m_hasVisibleThreats") &&*/ NetProps.GetPropInt(self, "m_iCurrentUseAction") == 0 && humanSurv && !IsPlayerABot(humanSurv) && NetProps.GetPropInt(humanSurv, "m_iTeamNum") == TEAM_SURVIVORS && !humanSurv.IsDead() && !humanSurv.IsDying() && (self.GetOrigin() - humanSurv.GetOrigin()).Length() <= 100)
		{
			// Give pills / adrenaline to all humans
			local item = Left4Utils.GetInventoryItemInSlot(self, INV_SLOT_PILLS);
			if (item && Left4Bots.Settings.pills_bots_give && Left4Utils.GetInventoryItemInSlot(humanSurv, INV_SLOT_PILLS) == null && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 && (Time() - Left4Bots.LastGiveItemTime) > 3)
			{
				local itemClass = item.GetClassname();
				local itemSkin = NetProps.GetPropInt(item, "m_nSkin");

				//self.SwitchToItem(itemClass);

				DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, self);

				Left4Bots.GiveItemIndex1 = item.GetEntityIndex();

				self.DropItem(itemClass);

				//humanSurv.GiveItemWithSkin(itemClass, itemSkin);
				Left4Utils.GiveItemWithSkin(humanSurv, itemClass, itemSkin);

				Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = self, player2 = humanSurv, weapon = item });
			}
			
			// Give medkits to admins / upgrades to all humans
			local item = Left4Utils.GetInventoryItemInSlot(self, INV_SLOT_MEDKIT);
			if (item && Left4Utils.GetInventoryItemInSlot(humanSurv, INV_SLOT_MEDKIT) == null && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 && (Time() - Left4Bots.LastGiveItemTime) > 1)
			{
				local itemClass = item.GetClassname();
				local itemSkin = NetProps.GetPropInt(item, "m_nSkin");
				if ((itemClass == "weapon_first_aid_kit" && Left4Bots.Settings.medkits_bots_give && Left4Bots.IsOnlineAdmin(humanSurv)) || ((itemClass == "weapon_upgradepack_explosive" || itemClass == "weapon_upgradepack_incendiary") && Left4Bots.Settings.upgrades_bots_give))
				{
					local holding = self.GetActiveWeapon();
					if (!holding || holding.GetClassname() != "weapon_first_aid_kit") // Give it only if they aren't holding it (avoid to give away the medkit while executing the heal command)
					{
						//self.SwitchToItem(itemClass);
						
						DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, self);
							
						Left4Bots.GiveItemIndex1 = item.GetEntityIndex();
							
						self.DropItem(itemClass);
							
						//humanSurv.GiveItemWithSkin(itemClass, itemSkin);
						Left4Utils.GiveItemWithSkin(humanSurv, itemClass, itemSkin);
							
						Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = self, player2 = humanSurv, weapon = item });
					}
				}
			}
		}
		else
			humanSurv = null;
		
		local item = Left4Utils.GetInventoryItemInSlot(self, INV_SLOT_THROW);
		if (!item)
			return null;

		local itemClass = item.GetClassname();
		local itemSkin = NetProps.GetPropInt(item, "m_nSkin");
		
		if (Left4Bots.Settings.nades_bots_give /*&& !NetProps.GetPropInt(self, "m_hasVisibleThreats")*/ && NetProps.GetPropInt(self, "m_iCurrentUseAction") == 0 && Left4Bots.GiveItemIndex1 == 0 && Left4Bots.GiveItemIndex2 == 0 && (Time() - Left4Bots.LastGiveItemTime) > 3)
		{
			if (humanSurv && Left4Utils.GetInventoryItemInSlot(humanSurv, INV_SLOT_THROW))
				humanSurv = null;
			
			if (humanSurv)
			{
				//self.SwitchToItem(itemClass);
			
				DoEntFire("!self", "SpeakResponseConcept", "PlayerAlertGiveItem", 0, null, self);
				
				Left4Bots.GiveItemIndex1 = item.GetEntityIndex();
				
				self.DropItem(itemClass);
				
				//humanSurv.GiveItemWithSkin(itemClass, itemSkin);
				Left4Utils.GiveItemWithSkin(humanSurv, itemClass, itemSkin);
				
				Left4Timers.AddTimer(null, 0.1, Left4Bots.GiveNade, { player1 = self, player2 = humanSurv, weapon = item });
				
				return null;
			}
		}
		
		local held = self.GetActiveWeapon();
		if (!held || held.GetClassname() != itemClass)
		{
			if (itemClass == "weapon_molotov" && Left4Bots.Settings.throw_molotov && Left4Bots.Settings.tank_molotov_chance > 0 && RandomInt(1, 100) <= Left4Bots.Settings.tank_molotov_chance)
			{
				local nearestTank = Left4Bots.GetNearestActiveTankWithin(self, TANK_MOLOTOV_MIN, TANK_MOLOTOV_MAX);
				if (nearestTank && !nearestTank.IsOnFire() && !nearestTank.IsDead() && !nearestTank.IsDying() && !nearestTank.IsIncapacitated() && nearestTank.GetHealth() >= 1500 && (Time() - Left4Bots.LastMolotovTime) >= THROW_MOLOTOV_MININTERVAL && !Left4Utils.IsSomeoneElseHolding(self, "weapon_molotov") && !Left4Utils.AreOtherSurvivorsNearby(self, nearestTank.GetOrigin(), MOLOTOV_SURVIVORS_MINDISTANCE) && Left4Utils.CanTraceTo(self, nearestTank))
				{
					TargetTank = nearestTank;
					TargetPos = null;
					self.SwitchToItem(itemClass);
				}
			}
			else if (itemClass == "weapon_vomitjar" && Left4Bots.Settings.throw_vomitjar && Left4Bots.Settings.tank_vomitjar_chance > 0 && RandomInt(1, 100) <= Left4Bots.Settings.tank_vomitjar_chance)
			{
				local nearestTank = Left4Bots.GetNearestActiveTankWithin(self, TANK_MOLOTOV_MIN, TANK_MOLOTOV_MAX);
				if (nearestTank && !nearestTank.IsDead() && !nearestTank.IsDying() && !nearestTank.IsIncapacitated() && nearestTank.GetHealth() >= 1500 && (Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL && Left4Utils.CanTraceTo(self, nearestTank))
				{
					TargetTank = nearestTank;
					TargetPos = null;
					self.SwitchToItem(itemClass);
				}
			}
			else if (/*NetProps.GetPropInt(self, "m_clientIntensity") >= 40*/ ((itemClass == "weapon_pipe_bomb" && Left4Bots.Settings.throw_pipe_bomb) || (itemClass == "weapon_vomitjar" && Left4Bots.Settings.throw_vomitjar)) && Left4Bots.Settings.horde_nades_chance > 0 && NetProps.GetPropInt(self, "m_hasVisibleThreats") && RandomInt(1, 100) <= Left4Bots.Settings.horde_nades_chance && (Time() - Left4Bots.LastNadeTime) >= THROW_NADE_MININTERVAL)
			{
				local common = Left4Bots.HasAngryCommonsWithin(self, Left4Bots.Settings.horde_nades_size, Left4Bots.Settings.horde_nades_radius, Left4Bots.Settings.horde_nades_maxaltdiff);
				if (common != false)
				{
					if (common != true)
					{
						TargetTank = null;
						TargetPos = common.GetOrigin();
						self.SwitchToItem(itemClass);
					}
					else
					{
						local pos = Left4Utils.BotGetFarthestPathablePos(self, THROW_NADE_RADIUS);
						if (pos && (pos - self.GetOrigin()).Length() >= THROW_NADE_MIN_DISTANCE)
						{
							TargetTank = null;
							TargetPos = pos;
							self.SwitchToItem(itemClass);
						}
					}
				}
			}
		}
		else if (Time() > NetProps.GetPropFloat(held, "m_flNextPrimaryAttack"))
		{
			if (itemClass == "weapon_molotov" || (itemClass == "weapon_vomitjar" && TargetTank != null))
			{
				if (TargetTank && TargetTank.IsValid())
					Left4Bots.DoThrowNade(self, TargetTank, TANK_MOLOTOV_DELTAPITCH);
					//Left4Bots.DoThrowNade(self, Left4Bots.GetNearestActiveTankWithin(self, TANK_MOLOTOV_MIN, TANK_MOLOTOV_MAX), TANK_MOLOTOV_DELTAPITCH);
				
				TargetTank = null;
			}
			else
				Left4Bots.DoThrowNade(self, TargetPos, THROW_NADE_DELTAPITCH);
		}
		
		return null;
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_Misc <- function ()
	{
		// Handling car alarms
		if (Left4Bots.Settings.trigger_caralarm)
		{
			local groundEnt = NetProps.GetPropEntity(self, "m_hGroundEntity");
			if (groundEnt && groundEnt.IsValid() && groundEnt.GetClassname() == "prop_car_alarm")
				Left4Bots.TriggerCarAlarm(self, groundEnt);
		}
		
		// TODO: should i move the tank's rock shoot logic here?
		//Left4Bots.Settings.rock_shoot_range
		
		if (HoldItem && (!HoldItem.IsValid() || (NetProps.GetPropInt(HoldItem, "m_hOwner") > 0 && NetProps.GetPropEntity(HoldItem, "m_hOwner") != self)))
		{
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " HoldItem no longer valid");

			Left4Bots.HoldItemStop(self);
		}
		
		if (Left4Bots.Settings.shove_si_within > 0)
		{
			local ent = null;
			while (ent = Entities.FindByClassnameWithin(ent, "player", self.GetOrigin(), Left4Bots.Settings.shove_si_within))
			{
				if (ent.IsValid() && !ent.IsDead() && !ent.IsDying() && (ent.GetZombieType() == Z_SMOKER || ent.GetZombieType() == Z_HUNTER || ent.GetZombieType() == Z_SPITTER || ent.GetZombieType() == Z_JOCKEY) && !ent.IsGhost() /*&& Left4Utils.CanTraceTo(self, ent)*/)
				{
					Left4Bots.BotShove2(self, ent, -6.0);
					break;
				}
			}
		}
		
		return null;
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_UseDefib <- function ()
	{
		if (self.IsIncapacitated())
		{
			if (GoToEnt)
				return false;
			else
				return null;
		}
		
		if (GoToEnt != null && GoToEntI != FuncI)
			return null; // already moving for something else
		
		if (GoToEnt)
		{
			// i'm moving towards a dead survivor to defib
			
			if (!GoToEnt.IsValid() || (Left4Bots.DefibbingUserId >= 0 && Left4Bots.DefibbingUserId != self.GetPlayerUserId()))
				return false;
			
			//if (NetProps.GetPropInt(self, "m_hasVisibleThreats"))
			if (Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
				return false;
			
			if ((self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= BOT_GOTO_END_RADIUS)
			{
				// i reached the dead survivor
				
				if (!Left4Utils.HasDefib(self))
				{
					local defib = Left4Bots.FindDefibPickupWithin(GoToEnt.GetOrigin());
					if (!defib)
						return false; // i don't have a defib and i went for a death model with defib nearby that is no longer available
					
					DoEntFire("!self", "Use", "", 0, self, defib);
					
					Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " picked up a defib nearby");
					
					return null; // do nothing until the defib is fully in my inventory
				}
				
				local holdingItem = self.GetActiveWeapon();
				if (holdingItem && holdingItem.GetClassname() == "weapon_defibrillator")
				{
					if (Time() <= NetProps.GetPropFloat(holdingItem, "m_flNextPrimaryAttack"))
						return null;
					
					Left4Bots.BotPressButton(self, BUTTON_ATTACK, BUTTON_HOLDTIME_DEFIB, GoToEnt, 0, 0, true);
					return null;
				}
				else if (holdingItem && holdingItem.GetClassname() != "weapon_pain_pills" && holdingItem.GetClassname() != "weapon_adrenaline")
				{
					Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is about to start defib");
				
					self.SwitchToItem("weapon_defibrillator");
				}
				
				//return false;
				return null; // keep doing nothing until the defib finished
			}			
			
			if (!MoveTo(GoToEnt.GetOrigin()))
				return false;
			
			return null; // keep moving
		}
		
		local holdingItem = self.GetActiveWeapon();
		if (holdingItem && holdingItem.GetClassname() == "weapon_defibrillator")
			return null; // if i'm here i have probably already started the timer to start the defib, i just need to wait until the defib begins or the AI decides to switch back to another weapon
		
		// Don't trust the "defibrillator_*" events
		if ((Time() - Left4Bots.DefibbingSince) >= 10)
		{
			Left4Bots.DefibbingUserId = -1;
			Left4Bots.DefibbingSince = 0;
		}
		
		if (Left4Bots.DefibbingUserId >= 0)
			return null;
		
		//if (NetProps.GetPropInt(self, "m_hasVisibleThreats"))
		if (Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
			return null;
		
		local death = null;
		if (Left4Utils.HasDefib(self))
			death = Left4Bots.GetNearestDeathModelWithin(self, BOT_GOTODEFIB_RANGE); // if i have a defib i search the nearest death model within a certain radius
		else
			death = Left4Bots.GetNearestDeathModelWithDefibWithin(self, BOT_GOTODEFIB_RANGE); // if i don't have a defib i search the nearest death model within a certain radius that has a defib nearby
		
		if (death)
		{
			if (!MoveTo(death.GetOrigin(), 2))
				return false;
		}
		
		return death;
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_Scavenge <- function ()
	{
		if (self.IsIncapacitated())
		{
			if (GoToEnt)
				return false;
			else
				return null;
		}
		
		if (GoToEnt != null && GoToEntI != FuncI)
			return null; // already moving for something else
		
		local currentOrder = null;
		if (self.GetPlayerUserId() in Left4Bots.ScavengeOrders)
			currentOrder = Left4Bots.ScavengeOrders[self.GetPlayerUserId()];
		
		if (!currentOrder || !currentOrder.IsValid())
		{
			if (GoToEnt)
				return false; // ScavengeManager removed my order?
			else
				return null; // wait for orders from ScavengeManager
		}
		
		if (!GoToEnt)
		{
			if (!Left4Bots.ScavengeEnabled || !currentOrder.IsValid() || !Left4Bots.ScavengeUseTarget || !Left4Bots.ScavengeUseTarget.IsValid() || NetProps.GetPropInt(currentOrder, "m_hOwner") > 0)
				return null;
			
			if (currentOrder.GetClassname() == "point_prop_use_target" && NetProps.GetPropInt(currentOrder, "m_useActionOwner") > 0)
				return null; // someone is already pouring, i need to wait my turn
			
			CanPause = true;
			
			if (Pause)
			{
				if (NetProps.GetPropInt(self, "m_hasVisibleThreats") || Left4Bots.ShouldGoDefib(self) ||  Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
					return null;
				
				Pause = false;
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is no longer in pause");
			}
			
			if (CanPause && (Left4Bots.ShouldGoDefib(self) || Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped()))
			{
				Pause = true;
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is in pause");
				
				Left4Bots.DropHoldItem(self);
				
				return null;
			}
			
			if (!MoveTo(currentOrder.GetOrigin(), 2)) // need to update my destination with the real destination next time
				return false;
				
			return currentOrder;
		}
		
		// i'm moving for my current order
		
		if (!Left4Bots.ScavengeEnabled || !GoToEnt.IsValid() || !Left4Bots.ScavengeUseTarget || !Left4Bots.ScavengeUseTarget.IsValid())
			return false;

		if (Pause)
		{
			if (NetProps.GetPropInt(self, "m_hasVisibleThreats") || Left4Bots.ShouldGoDefib(self) ||  Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
				return null;
			
			Pause = false;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is no longer in pause");
		}

		if (CanPause && (Left4Bots.ShouldGoDefib(self) || Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped()))
		{
			Pause = true;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is in pause");
			
			Left4Bots.DropHoldItem(self);
			
			return false;
		}

		if (GoToEnt.GetClassname() == "point_prop_use_target")
		{
			local held = self.GetActiveWeapon();
			if (!held || held.GetEntityIndex() != currentOrder.GetEntityIndex())
				return false; // i dropped this can for some reason
			
			if (Left4Bots.Settings.scavenge_pour && (self.GetOrigin() - Left4Bots.ScavengeUseTargetPos).Length() <= 25)
			{
				// i reached the scavenge destination, let's start pouring

				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is about to start pouring");
			
				if (NetProps.GetPropInt(GoToEnt, "m_useActionOwner") > 0)
					return null; // someone is already pouring, i need to wait my turn...
					
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " pouring");
					
				Left4Bots.BotPressButton(self, BUTTON_ATTACK, BUTTON_HOLDTIME_POUR, GoToEnt, 0, 0, true);
					
				return false;
			}
			else if (!Left4Bots.Settings.scavenge_pour && (self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= (SCAVENGE_DROP_RADIUS - 20))
			{
				// i reached the scavenge destination, i drop the item near
				
				// Left4Utils.BotLookAt(self, GoToEnt, 45, 0);
				// self.DropItem(held.GetClassname()); // don't do this with gascans or they lose their glow
				// self.SwitchToItem(Left4Utils.GetInventoryItemInSlot(self, INV_SLOT_SECONDARY).GetClassname());
				Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, GoToEnt, 0, 0, true);
				
				Left4Bots.ScavengeOrders[self.GetPlayerUserId()] <- null; // reset my current order so i can receive a new one from ScavengeManager
				
				return false;
			}
			
			if (!MoveTo(Left4Bots.ScavengeUseTargetPos))
				return false;
		}
		else
		{
			if ((self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= BOT_GOTO_END_RADIUS)
			{
				// i reached my assigned scavenge item, let's pick it up
					
				DoEntFire("!self", "Use", "", 0, self, GoToEnt);
					
				// now let's deliver this to the scavenge destination
				if (!MoveTo(Left4Bots.ScavengeUseTargetPos, 2))
					return false;
				
				CanPause = true;
				return Left4Bots.ScavengeUseTarget;
			}
			
			if (!MoveTo(GoToEnt.GetOrigin()))
				return false;
		}
		
		return null; // keep moving for my current order
	}
	
	// Runs in the scope of the bot entity
	// Returns: null = do nothing, false = must reset, otherwise return the new ent we are moving to
	::Left4Bots.BotThink_ManualOrders <- function ()
	{
		if (self.IsIncapacitated())
		{
			if (GoToEnt)
				return false;
			else
				return null;
		}
		
		local order = null;
		local orderType = null;
		local orderDest = null;
		local orderPos = null;
		local lookatPos = null;
		local holdTime = null;
		if (self.GetPlayerUserId() in Left4Bots.ManualOrders)
			order = Left4Bots.ManualOrders[self.GetPlayerUserId()];
		
		if (order)
		{
			if (order.from && !order.dest)
			{
				if ((Time() - order.stime) > MANUAL_ORDER_MAXTIME)
				{
					delete ::Left4Bots.ManualOrders[self.GetPlayerUserId()];
			
					Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order expired, new count: " + Left4Bots.ManualOrders.len());
				}
				
				return null;
			}
			else if (Time() >= order.stime) // Handling delayed orders
			{
				orderType = order.ordertype;
				orderDest = order.dest;
				orderPos = order.pos;
			
				if ("lookatpos" in order)
					lookatPos = order.lookatpos;
			
				if ("holdtime" in order)
					holdTime = order.holdtime;
			}
			else
				return null; // Waiting for the order start time
		}
			
		if (orderDest && (!orderDest.IsValid() || NetProps.GetPropInt(orderDest, "m_hOwner") > 0))
		{
			orderDest = null;
			orderPos = null;
		}

		if (!orderDest)
		{
			//if (GoToEnt != null && GoToEntI == FuncI)
			if (order)
			{
				// my order is no longer valid, need to delete it and reset myself
				
				if (self.GetPlayerUserId() in Left4Bots.ManualOrders)
					delete ::Left4Bots.ManualOrders[self.GetPlayerUserId()];
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order no longer valid, new count: " + Left4Bots.ManualOrders.len());
				
				return false;
			}
			
			return null; // nothing to do here
		}

		CanPause = order.canpause;

		if (!GoToEnt || GoToEntI != FuncI)
		{
			if (Pause)
			{
				if (NetProps.GetPropInt(self, "m_hasVisibleThreats") || Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
					return null;
				
				Pause = false;
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is no longer in pause");
			}
			
			if (CanPause && (Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped()))
			{
				Pause = true;
				
				Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is in pause");
				
				Left4Bots.DropHoldItem(self);
				
				return null;
			}
			
			if (GoToEnt && GoToEntI != FuncI) // already moving for something else but manual orders have higher priority
				Left4Bots.Log(LOG_LEVEL_DEBUG, "Manual order cancelled the previous activity");
			
			local p = orderPos;
			if (!p)
				p = orderDest.GetOrigin();
			
			if (!MoveTo(p, 2))
				return false;
			
			return orderDest; // let's start do this order
		}
		
		if (!GoToEnt || !GoToEnt.IsValid())
			return false; // my target is no longer valid
		
		if (Pause)
		{
			if (NetProps.GetPropInt(self, "m_hasVisibleThreats") || Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped())
				return null;
			
			Pause = false;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is no longer in pause");
		}
		
		if (CanPause && (Left4Bots.BotWillUseMeds(self) || Left4Bots.HasAngryCommonsWithin(self, 3, 100) != false || Left4Utils.HasSpecialInfectedWithin(self, 400) || Left4Bots.SurvivorsHeldOrIncapped()))
		{
			Pause = true;
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " is in pause");
			
			Left4Bots.DropHoldItem(self);
			
			return false;
		}
		
		local gotoClass = GoToEnt.GetClassname();
		
		if (orderType == "use")
		{
			if (gotoClass.find("weapon_") != null || gotoClass.find("prop_physics") != null)
			{
				if ((self.GetOrigin() - MovePos).Length() <= 80)
				{
					// i'm close enough, use it
					
					LastUseTS = Time();
					
					if (lookatPos)
						Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, lookatPos, 0, 0, true);
					else
						Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, GoToEnt.GetCenter(), 0, 0, true);
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
			}
			else if (gotoClass.find("prop_minigun") != null)
			{
				if ((self.GetOrigin() - MovePos).Length() <= 20)
				{
					// i'm close enough, use it
					
					if (lookatPos)
						Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, lookatPos, 0, 0, true);
					else
						Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, GoToEnt.GetCenter(), 0, 0, true);
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
			}
			//if (gotoClass.find("func_button") != null || gotoClass.find("trigger_finale") != null || gotoClass.find("prop_door_rotating") != null)
			else
			{
				if ((self.GetOrigin() - MovePos).Length() <= 50 || Left4Utils.CanTraceTo(self, GoToEnt, TRACE_MASK_SHOT, 90))
				{
					// i'm close enough, use it
					
					local hold = BUTTON_HOLDTIME_TAP;
					if (holdTime)
						hold = holdTime + 0.2;
					
					if (lookatPos)
						Left4Bots.BotPressButton(self, BUTTON_USE, hold, lookatPos, 0, 0, true);
					else
						Left4Bots.BotPressButton(self, BUTTON_USE, hold, GoToEnt.GetCenter(), 0, 0, true);
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
			}

			if (!MoveTo(MovePos))
				return false;
			
			return null; // keep moving
		}
		if (orderType == "goto")
		{
			if ((self.GetOrigin() - MovePos).Length() <= 40)
			{
				// i'm close enough, stop here
				
				Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
				
				return false;
			}

			if (!MoveTo(MovePos))
				return false;
			
			return null; // keep moving
		}
		else if (orderType == "heal")
		{
			if (!Left4Utils.HasMedkit(self))
			{
				// No longer have a medkit, abort the order
				Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
				
				return false;
			}
			
			local held = self.GetActiveWeapon();
			if (!held || held.GetClassname() != "weapon_first_aid_kit")
				self.SwitchToItem("weapon_first_aid_kit");
			else if ((self.GetOrigin() - MovePos).Length() <= BOT_GOTO_END_RADIUS && Time() > NetProps.GetPropFloat(held, "m_flNextPrimaryAttack"))
			{
				// i'm close enough and i can use the medkit, let's start healing
				
				Left4Bots.BotPressButton(self, BUTTON_SHOVE, 0, GoToEnt.GetCenter(), 0, 0, true);
				
				Left4Timers.AddTimer(null, 0.8, Left4Bots.HealingCheck, { bot = self, order = order }); // This will check if the healing started and the healing target is the right target
																										// If not, it will abort the healing and the current order and will re-add the order to try again
				Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
				
				return false;
			}
			
			if (!MoveTo(GoToEnt.GetOrigin()))
				return false;
			
			return null; // keep moving
		}
		else
		{
			if (gotoClass == "witch")
			{
				// they sent me to crown a witch... i hope i'll make it
				
				if ((self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= WITCH_CROWN_RADIUS)
				{
					// i'm close enough, let's start attack
					
					if ("LookupAttachment" in GoToEnt)
					{
						local attachId = GoToEnt.LookupAttachment("forward");
						
						// i shoot 3 bullets to her head as quick as i can (if using slow weapons like pump shotguns the bullets will be 2 but usually 1 is enough)
						
						Left4Timers.AddTimer(null, 0.1, Left4Bots.BotShootAtEntityAttachment, { bot = self, target = GoToEnt, attachmentid = attachId });
						Left4Timers.AddTimer(null, 0.5, Left4Bots.BotShootAtEntityAttachment, { bot = self, target = GoToEnt, attachmentid = attachId });
						Left4Timers.AddTimer(null, 0.9, Left4Bots.BotShootAtEntityAttachment, { bot = self, target = GoToEnt, attachmentid = attachId });
					}
					else
					{
						// old method
						// i spawn a dummy env_sprite and attach it to the "forward" attachment point (which is pretty much the head) of the witch and i use it as a target
						local head = SpawnEntityFromTable("env_sprite", { spawnflags = 1, rendermode = 0, rendercolor = "0 0 0", model = "effects/strider_bulge_dudv_dx60.vmt" });
						DoEntFire("!self", "SetParent", "!activator", 0, GoToEnt, head);
						DoEntFire("!self", "SetParentAttachment", "forward", 0, GoToEnt, head); // valid attachment points in the head: forward, reye, leye
						
						// i shoot 3 bullets to her head as quick as i can (if using slow weapons like pump shotguns the bullets will be 2 but usually 1 is enough)
						
						Left4Timers.AddTimer(null, 0.1, Left4Bots.BotShootAtEntity, { bot = self, target = head });
						Left4Timers.AddTimer(null, 0.5, Left4Bots.BotShootAtEntity, { bot = self, target = head });
						Left4Timers.AddTimer(null, 0.9, Left4Bots.BotShootAtEntity, { bot = self, target = head });
					}
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
				
				if (!MoveTo(GoToEnt.GetOrigin()))
					return false;
				
				return null; // keep moving towards her
			}
			else if (gotoClass == "prop_door_rotating")
			{
				// they sent me to open a door
				
				if ((self.GetOrigin() - MovePos).Length() <= 30)
				{
					// i'm close enough, open it
					
					local pos = GoToEnt.GetOrigin() - (GoToEnt.GetAngles().Left() * 30) + Vector(0, 0, 45);
					if (lookatPos)
						pos = lookatPos;
					
					Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, pos, 0, 0, true);
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					if (Left4Bots.C1M2CanOpenStoreDoors)
						Left4Bots.C1M2CanOpenStoreDoors = false;
					
					return false;
				}
				
				if (!MoveTo(MovePos))
					return false;
				
				return null; // keep moving towards the door
			}
			else if (gotoClass == "func_button") // TODO: Handle lookatPos?
			{
				// they sent me to press a button
				
				if ((self.GetOrigin() - MovePos).Length() <= 30)
				{
					// i'm close enough, press it
					
					Left4Bots.BotPressButton(self, BUTTON_USE, BUTTON_HOLDTIME_TAP, GoToEnt, 0, 0, true);
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
				
				if (!MoveTo(MovePos))
					return false;
				
				return null; // keep moving towards the button
			}
			else if (gotoClass == "func_button_timed")
			{
				// it's probably a generator or the train door
				
				local hold = NetProps.GetPropInt(GoToEnt, "m_nUseTime") + 0.2;
				if (holdTime)
					hold = holdTime + 0.2;
				
				if (Left4Bots.MapName == "c7m3_port")
				{
					if ((self.GetOrigin() - MovePos).Length() <= 200)
					{
						if (Left4Bots.StartGenerators && (self.GetOrigin() - MovePos).Length() <= 30)
						{
							// i'm close enough, press it
							
							Left4Bots.BotPressButton(self, BUTTON_USE, hold, GoToEnt, 0, 0, true);
							
							Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
							
							return false;
						}
						
						NeedMove = 1; // stay here until Left4Bots.StartGenerators is true
					}
				}
				else
				{
					// pos = GoToEnt.GetOrigin() + (GoToEnt.GetAngles().Forward() * 40) + (GoToEnt.GetAngles().Left() * 25); // <- this doesn't always work

					if ((self.GetOrigin() - MovePos).Length() <= 30)
					{
						// i'm close enough, press it
						
						Left4Bots.BotPressButton(self, BUTTON_USE, hold, GoToEnt, 0, 0, true);
						
						Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
						
						return false;
					}
				}
				
				if (!MoveTo(MovePos))
					return false;
				
				return null; // keep moving towards the button
			}
			else if (gotoClass == "prop_dynamic" && Left4Bots.MapName == "c7m3_port" && GoToEnt.GetName() == "generator_model2")
			{	
				local generator_button = Entities.FindByName(null, "generator_button");
				if (generator_button)
				{
					GoToEnt = generator_button;
					order.dest = generator_button;
					order.pos = Vector(-407.416443, -651.816711, 2.146685);
					
					//NeedMove = 2;
					if (!MoveTo(order.pos, 2))
						return false;
					
					return null;
				}
				
				if (!MoveTo(MovePos))
					return false;
				
				return null; // keep moving towards the button
			}
			else if (gotoClass == "prop_door_rotating_checkpoint" || gotoClass == "info_remarkable" || gotoClass == "info_target")
			{
				// i was ordered to lead the way
				
				if ((self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= 100)
				{
					// i'm close enough, let's stop here
					
					Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
					
					return false;
				}
			}
			
			// unhandled target, i just go to it's position
			
			if ((self.GetOrigin() - GoToEnt.GetOrigin()).Length() <= BOT_GOTO_END_RADIUS)
			{
				// i reached my destination
				
				Left4Bots.ManualOrderComplete(self.GetPlayerUserId());
				
				return false;
			}
			
			//MoveTo(GoToEnt.GetOrigin());
			if (!MoveTo(MovePos))
				return false;
			
			return null; // keep moving
		}
	}
	
	// Main bot's think function (splits the work of the entire think process in different frames so the think function isn't overloaded)
	// Runs in the scope of the bot entity
	::Left4Bots.L4B_BotThink <- function ()
	{
		// Don't do anything if the bot is on a ladder or its navigation system goes full retard making the bot fall / get stuck
		if (NetProps.GetPropInt(self, "movetype") == 9 /* MOVETYPE_LADDER */)
			return BOT_THINK_INTERVAL;
		
		// If the bot has FL_FROZEN flag set, CommandABot will fail even though it still returns true
		// I make sure to send at least one extra move command to the bot after the FL_FROZEN flag is unset
		if ((NetProps.GetPropInt(self, "m_fFlags") & (1 << 5)))
			NeedMove = 2;
		
		//Left4Bots.Log(LOG_LEVEL_DEBUG, "BotThink[" + self.GetPlayerName() + "]: FuncI = " + FuncI);
		
		if (self.GetVelocity().z <= (-Left4Bots.Settings.fall_velocity_warp) && !Left4Utils.IsPlayerHeld(self) && !self.IsIncapacitated() && !self.IsDead() && !self.IsDying())
		{
			local others = Left4Utils.GetOtherAliveSurvivors(self);
			if (others.len() > 0)
			{
				local to = others[RandomInt(0, others.len() - 1)];
				if (to && to.IsValid())
				{
					self.SetVelocity(Vector(0,0,0));
					self.SetOrigin(to.GetOrigin());
					
					Left4Bots.Log(LOG_LEVEL_INFO, self.GetPlayerName() + " has been teleported to " + to.GetPlayerName() + " while falling");
				}
			}
		}
		
		local r = null;
		switch (FuncI)
		{
			case 1:
			{
				r = BotThink_PickupItems();
				break;
			}
			case 2:
			{
				r = BotThink_UseDefib();
				break;
			}
			case 3:
			{
				r = BotThink_Scavenge();
				break;
			}
			case 4:
			{
				r = BotThink_ManualOrders();
				break;
			}
			case 5:
			{
				BotThink_ThrowNades();
				BotThink_Misc();
				break;
			}
		}
		
		if (r == false || MustReset)
		{
			//Left4Bots.Log(LOG_LEVEL_DEBUG, "BotThink[" + self.GetPlayerName() + "]: r is false");
			
			GoToEnt = null;
			GoToEntI = 0;
			MovePos = Vector(0, 0, 0);
			MustReset = false;
			Left4Utils.BotCmdReset(self);
			
			Left4Bots.Log(LOG_LEVEL_DEBUG, self.GetPlayerName() + " RESET");
		}
		else if (r != null)
		{
			//Left4Bots.Log(LOG_LEVEL_DEBUG, "BotThink[" + self.GetPlayerName() + "]: r is entity");
			
			GoToEnt = r;
			GoToEntI = FuncI;
		}
		
		FuncI++;
		if (FuncI > 5)
			FuncI = 1;
		
		return BOT_THINK_INTERVAL;
	}
	
	//
	
//}

IncludeScript("left4bots_events");
