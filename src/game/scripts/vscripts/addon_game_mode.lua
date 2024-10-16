-- Define skill warnings
--[[skillWarnings = {
    life_stealer_infest = {getSpellIcon('life_stealer_infest'), tranAbility('life_stealer_infest'), getSpellIcon('life_stealer_consume'), tranAbility('life_stealer_consume')},
    shadow_demon_demonic_purge = {getSpellIcon('shadow_demon_demonic_purge'), tranAbility('shadow_demon_demonic_purge'), transHero('shadow_demon')},
    phantom_lancer_phantom_edge = {getSpellIcon('phantom_lancer_phantom_edge'), tranAbility('phantom_lancer_phantom_edge'), getSpellIcon('phantom_lancer_juxtapose'), tranAbility('phantom_lancer_juxtapose')},
    keeper_of_the_light_spirit_form = {getSpellIcon('keeper_of_the_light_spirit_form'), tranAbility('keeper_of_the_light_spirit_form')},
    luna_eclipse = {getSpellIcon('luna_eclipse'), tranAbility('luna_eclipse'), getSpellIcon('luna_lucent_beam'), tranAbility('luna_lucent_beam')},
    puck_illusory_orb = {getSpellIcon('puck_illusory_orb'), tranAbility('puck_illusory_orb'), getSpellIcon('puck_ethereal_jaunt'), tranAbility('puck_ethereal_jaunt')},
    techies_remote_mines = {getSpellIcon('techies_remote_mines'), tranAbility('techies_remote_mines'), getSpellIcon('techies_focused_detonate'), tranAbility('techies_focused_detonate')},
    nyx_assassin_burrow = {getSpellIcon('nyx_assassin_burrow'), tranAbility('nyx_assassin_burrow'), getSpellIcon('nyx_assassin_vendetta'), tranAbility('nyx_assassin_vendetta')},
n    lone_druid_true_form = {getSpellIcon('lone_druid_true_form'), tranAbility('lone_druid_true_form')},
    phoenix_supernova = {getSpellIcon('phoenix_supernova'), tranAbility('phoenix_supernova')},
}]]

require('lib/StatUploaderFunctions')

-- Precache obstacles
require('obstacles')

-- Misc functions
require('util')

-- Option storage
require('optionmanager')

-- Networking functions
require('network')

-- Chat commands
require('commands')

--Interaction with server (https://github.com/darklordabc/Legends-of-Dota-Server)
require('stats_client')

-- Custom Shop
require('lib/playertables')
require('lib/notifications')
-- require('panorama_shop')

-- Misc functions for Angel Arena Black Star abilities/items
require('lib/util_aabs')

-- IMBA
require('lib/util_imba')
require('lib/util_imba_funcs')
require('lib/animations')

require('pregame')
require('ingame')

-- Precaching
function Precache(context)
    local soundList = LoadKeyValues('scripts/kv/sounds.kv')
    -- Precache sounds
    for soundPath,_ in pairs(soundList["precache_sounds"]) do
        PrecacheResource("soundfile", soundPath, context)
    end
    -- COMMENT THE BELOW OUT IF YOU DO NOT WANT TO COMPILE ASSETS
    if IsInToolsMode() then
        local abilities = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
        for ability,content in pairs(abilities) do
            if type(content) == "table" then
                for block,val in pairs(content) do
                  if block == "precache" then
                    for precacheType, resource in pairs(val) do
                        PrecacheResource(precacheType, resource, context)
                    end
                  end
                end
            end
        end
    end
    -- COMMENT THE ABOVE OUT IF YOU DO NOT WANT TO COMPILE ASSETS
    PrecacheResource("particle","particles/econ/events/battlecup/battle_cup_fall_destroy_flash.vpcf",context)
    PrecacheResource("particle","particles/world_tower/tower_upgrade/ti7_radiant_tower_proj.vpcf",context)
    PrecacheResource("particle","particles/world_tower/tower_upgrade/ti7_dire_tower_projectile.vpcf",context)
    PrecacheResource("soundfile","soundevents/memes_redux_sounds.vsndevts",context)
    --PrecacheUnitByNameSync("npc_dota_lucifers_claw_doomling", context)
    --PrecacheUnitByNameSync("npc_bot_spirit_sven", context)

    -- Precache all hero sounds here as some sounds end up not working
    for k, _ in pairs(soundList["hero_sounds"]) do
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k .. ".vsndevts", context)
    end

	-- Precache bots
	PrecacheUnitByNameSync("npc_dota_hero_axe", context)
	PrecacheUnitByNameSync("npc_dota_hero_bane", context)
	PrecacheUnitByNameSync("npc_dota_hero_bloodseeker", context)
	PrecacheUnitByNameSync("npc_dota_hero_bounty_hunter", context)
	PrecacheUnitByNameSync("npc_dota_hero_bristleback", context)
	PrecacheUnitByNameSync("npc_dota_hero_chaos_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_crystal_maiden", context)
	PrecacheUnitByNameSync("npc_dota_hero_dazzle", context)
	PrecacheUnitByNameSync("npc_dota_hero_death_prophet", context)
	PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_drow_ranger", context)
	PrecacheUnitByNameSync("npc_dota_hero_earthshaker", context)
	PrecacheUnitByNameSync("npc_dota_hero_jakiro", context)
	PrecacheUnitByNameSync("npc_dota_hero_juggernaut", context)
	PrecacheUnitByNameSync("npc_dota_hero_kunkka", context)
	PrecacheUnitByNameSync("npc_dota_hero_lich", context)
	PrecacheUnitByNameSync("npc_dota_hero_lina", context)
	PrecacheUnitByNameSync("npc_dota_hero_lion", context)
	PrecacheUnitByNameSync("npc_dota_hero_luna", context)
	PrecacheUnitByNameSync("npc_dota_hero_necrolyte", context)
	PrecacheUnitByNameSync("npc_dota_hero_nevermore", context)
	PrecacheUnitByNameSync("npc_dota_hero_omniknight", context)
	PrecacheUnitByNameSync("npc_dota_hero_oracle", context)
	PrecacheUnitByNameSync("npc_dota_hero_phantom_assassin", context)
	PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
	PrecacheUnitByNameSync("npc_dota_hero_sand_king", context)
	PrecacheUnitByNameSync("npc_dota_hero_skeleton_king", context)
	PrecacheUnitByNameSync("npc_dota_hero_skywrath_mage", context)
	PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)
	PrecacheUnitByNameSync("npc_dota_hero_tiny", context)
	PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context)
	PrecacheUnitByNameSync("npc_dota_hero_viper", context)
	PrecacheUnitByNameSync("npc_dota_hero_warlock", context)
	PrecacheUnitByNameSync("npc_dota_hero_windrunner", context)
	PrecacheUnitByNameSync("npc_dota_hero_witch_doctor", context)
	PrecacheUnitByNameSync("npc_dota_hero_zuus", context)

	precacheObstacles(context)
end

-- Create the game mode when we activate
function Activate()
    -- Print LoD version header
    local versionNumber = "3.1.2"
    print('\n\nDota 2 Redux is activating! (v'..versionNumber..')')

   -- Load specific modules
    if not Pregame then
        require('pregame')
	end
    if not Ingame then
        require('ingame')
    end

    -- Init other stuff
    network:init()
    Pregame:init()
    Ingame:init()

    StatsClient:SubscribeToClientEvents()

    print('LoD seems to have activated successfully!!\n\n')

    -- PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_BADGUYS)
    -- PlayerResource:SetCustomTeamAssignment(1, DOTA_TEAM_GOODGUYS)
    -- GameRules:LockCustomGameSetupTeamAssignment(true)
end

-- Boot directly into LoD interface
--Convars:SetInt('dota_wait_for_players_to_load', 0)
