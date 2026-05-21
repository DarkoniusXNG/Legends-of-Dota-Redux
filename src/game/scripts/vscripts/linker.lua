local hero_names = {
	"abaddon", -- ok, D tier
	"abyssal_underlord", -- ok
	"alchemist", -- ok
	"ancient_apparition", -- ok
	"antimage", -- ok, D tier
	"arc_warden", -- ok, S tier
	"axe", -- NEEDS REPLACEMENT, bot
	"bane", -- ok, bot
	"batrider", -- ok
	"beastmaster", -- ok
	"bloodseeker", -- ok, bot
	"bounty_hunter", -- NEEDS REPLACEMENT, bot
	"brewmaster", -- ok, A tier
	"bristleback", -- NEEDS REPLACEMENT, bot
	"broodmother", -- ok
	"centaur", -- ok, S tier
	"chaos_knight", -- ok, bot
	"chen", -- ok, S tier
	"clinkz", -- ok, D tier
	"crystal_maiden", -- ok, D tier, bot
	"dark_seer", -- NEEDS REPLACEMENT
	"dark_willow", -- NEEDS REPLACEMENT
	"dawnbreaker", -- ok, missing icon, A tier
	"dazzle", -- ok, bot
	"death_prophet", -- ok, S tier, bot
	"disruptor", -- ok
	"doom_bringer", -- ok
	"dragon_knight", -- ok, A tier, bot
	"drow_ranger", -- ok, A tier, bot
	"earth_spirit", -- ok, missing icon, S tier
	"earthshaker", -- ok, A tier, bot
	"elder_titan", -- ok
	"ember_spirit", -- ok
	"enchantress", -- NEEDS REPLACEMENT
	"enigma", -- ok
	"faceless_void", -- ok
	"furion", -- ok, S tier
	"grimstroke", -- ok, A tier
	"gyrocopter", -- ok, A tier
	"hoodwink", -- ok, missing icon
	"huskar", -- ok, D tier
	"invoker", -- NEEDS REPLACEMENT, A tier
	"jakiro", -- ok, bot
	"juggernaut", -- ok, A tier, bot
	"keeper_of_the_light", -- ok, A tier
	"kez", -- ok, D tier
	"kunkka", -- ok, S tier, bot
	"legion_commander", -- ok
	"leshrac", -- ok, S tier
	"lich", -- ok, bot
	"life_stealer", -- ok, S tier
	"lina", -- ok, S tier, bot
	"lion", -- NEEDS REPLACEMENT, bot
	"lone_druid", -- ok, D tier
	"luna", -- ok, bot
	"lycan", -- ok
	"magnataur", -- ok
	"marci", -- ok
	"mars", -- ok, missing icon, S tier
	"medusa", -- ok, A tier
	"meepo", -- ok
	"mirana", -- ok
	"monkey_king", -- ok, S tier
	"morphling", -- NEEDS REPLACEMENT, A tier
	"muerta", -- ok, S tier
	"naga_siren", -- ok, A tier
	"necrolyte", -- ok, D tier, bot
	"nevermore", -- ok, S tier, bot
	"night_stalker", -- ok, A tier
	"nyx_assassin", -- NEEDS REPLACEMENT, D tier
	"obsidian_destroyer", -- NEEDS REPLACEMENT, A tier
	"ogre_magi", -- ok, S tier
	"omniknight", -- ok, bot
	"oracle", -- NEEDS IMPROVEMENT, A tier, bot
	"pangolier", -- NEEDS IMPROVEMENT, D tier
	"phantom_assassin", -- ok, bot
	"phantom_lancer", -- ok, C tier
	"phoenix", -- ok, D tier
	"primal_beast", -- ok, S tier
	"puck", -- ok
	"pudge", -- ok, bot
	"pugna", -- ok, S tier
	"queenofpain", -- NEEDS REPLACEMENT, A tier
	"rattletrap", -- ok, missing icon, A tier
	"razor", -- ok
	"riki", -- ok, D tier
	"ringmaster", -- ok
	"rubick", -- ok
	"sand_king", -- ok, D tier, bot
	"shadow_demon", -- ok, A tier
	"shadow_shaman", -- ok
	"shredder", -- ok, A tier
	"silencer", -- ok
	"skeleton_king", -- ok, bot
	"skywrath_mage", -- ok, bot
	"slardar", -- ok, A tier
	"slark", -- NEEDS IMPROVEMENT, D tier
	"snapfire", -- ok, missing icon, A tier
	"sniper", -- NEEDS REPLACEMENT, A tier, bot
	"spectre", -- C tier
	"spirit_breaker", -- NEEDS IMPROVEMENT
	"storm_spirit", -- ok
	"sven", -- ok, bot
	"techies", -- ok, S tier
	"templar_assassin", -- ok, D tier
	"terrorblade", -- ok, S tier
	"tidehunter", -- ok, A tier
	"tinker", -- ok, D tier
	"tiny", -- ok, bot
	"treant", -- ok
	"troll_warlord", -- ok
	"tusk", -- ok, S tier
	"undying", -- NEEDS REPLACEMENT
	"ursa", -- NEEDS REPLACEMENT
	"vengefulspirit", -- ok, bot
	"venomancer" , -- ok, C tier
	"viper", -- ok, bot
	"visage", -- ok
	"void_spirit", -- NEEDS REPLACEMENT, D tier
	"warlock", -- NEEDS REPLACEMENT, A tier, bot
	"weaver", -- ok, D tier
	"windrunner", -- ok, bot
	"winter_wyvern", -- NEEDS IMPROVEMENT, D tier
	"wisp", -- ok, D tier
	"witch_doctor", -- ok, bot
	"zuus", -- ok, C tier, bot
}
for _, name in pairs (hero_names) do
	LinkLuaModifier("modifier_npc_dota_hero_"..name.."_perk", "abilities/hero_perks/npc_dota_hero_"..name.."_perk.lua", LUA_MODIFIER_MOTION_NONE)
end

LinkLuaModifier("modifier_no_invis_redux", "abilities/modifiers/modifier_no_invis_redux.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_custom_flesh_heap_kill_tracker", "abilities/modifiers/modifier_pudge_custom_flesh_heap_kill_tracker.lua", LUA_MODIFIER_MOTION_NONE)
-- Neutral creep power modifier
LinkLuaModifier("modifier_neutral_power", "abilities/modifiers/modifier_neutral_power.lua", LUA_MODIFIER_MOTION_NONE)
-- Custom AI script modifiers
LinkLuaModifier( "modifier_slark_shadow_dance_ai", "abilities/botAI/modifier_slark_shadow_dance_ai.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_alchemist_chemical_rage_ai", "abilities/botAI/modifier_alchemist_chemical_rage_ai.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_easybot", "abilities/botAI/modifier_easybot.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mediumbot", "abilities/botAI/modifier_mediumbot.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hardbot", "abilities/botAI/modifier_hardbot.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_unfairbot", "abilities/botAI/modifier_unfairbot.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bot_lod_redux", "abilities/botAI/modifier_bot_lod_redux.lua", LUA_MODIFIER_MOTION_NONE )
