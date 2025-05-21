local hero_names = {
	"abaddon", -- ok, D tier
	"abyssal_underlord", -- ok
	"alchemist", -- ok
	"ancient_apparition", -- ok
	"antimage", -- ok, D tier
	"arc_warden", -- ok, S tier
	"axe", -- ok, bot
	"bane", -- ok, bot
	"batrider", -- ok
	"beastmaster", -- ok
	"bloodseeker", -- ok, bot
	"bounty_hunter", -- ok, bot
	"brewmaster", -- ok, A tier
	"bristleback", -- kinda bad, bot
	"broodmother", -- ok
	"centaur", -- ok, S tier
	"chaos_knight", -- ok, bot
	"chen", -- ok, S tier
	"clinkz", -- ok, D tier
	"crystal_maiden", -- ok, D tier, bot
	"dark_seer", -- kinda bad
	"dark_willow", -- ok
	"dawnbreaker", -- ok, missing icon, A tier
	"dazzle", -- ok, bot
	"death_prophet", -- ok, S tier, bot
	"disruptor", -- terrible
	"doom_bringer", -- ok
	"dragon_knight", -- ok, A tier, bot
	"drow_ranger", -- ok, A tier, bot
	"earth_spirit", -- ok, missing icon, S tier
	"earthshaker", -- ok, A tier, bot
	"elder_titan", -- ok
	"ember_spirit", -- ok
	"enchantress", -- badly coded idea not bad
	"enigma", -- ok
	"faceless_void", -- ok
	"furion", -- ok, S tier
	"grimstroke", -- ok, A tier
	"gyrocopter", -- ok, A tier
	"hoodwink", -- ok, missing icon
	"huskar", -- ok, D tier
	"invoker", -- kinda bad, A tier
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
	"lion", -- maybe op, bot
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
	"morphling", -- ok, A tier
	"muerta", -- ok, S tier
	"naga_siren", -- ok, A tier
	"necrolyte", -- ok, D tier, bot
	"nevermore", -- ok, S tier, bot
	"night_stalker", -- ok, A tier
	"nyx_assassin", -- kinda bad, D tier
	"obsidian_destroyer", -- ok, kinda bad, A tier
	"ogre_magi", -- ok, S tier
	"omniknight", -- ok, bot
	"oracle", -- ok, A tier, bot
	"pangolier", -- ok, D tier
	"phantom_assassin", -- ok, bot
	"phantom_lancer", -- kinda bad, C tier
	"phoenix", -- ok, D tier
	"primal_beast", -- ok, S tier
	"puck", -- ok
	"pudge", -- ok, bot
	"pugna", -- ok, S tier
	"queenofpain", -- kinda bad, A tier
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
	"slark", -- ok, D tier
	"snapfire", -- ok, missing icon, A tier
	"sniper", -- ok, A tier, bot
	"spectre", -- ok, D tier
	"spirit_breaker", -- ok, kinda bad
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
	"undying", -- bad
	"ursa", -- ok, kinda bad
	"vengefulspirit", -- ok, bot
	"venomancer" , -- ok, C tier
	"viper", -- ok, bot
	"visage", -- ok
	"void_spirit", -- ok, kinda bad, D tier
	"warlock", -- too strong idea not bad, A tier, bot
	"weaver", -- ok, D tier
	"windrunner", -- ok, bot
	"winter_wyvern", -- ok, D tier
	"wisp", -- ok, D tier
	"witch_doctor", -- ok, bot
	"zuus", -- ok, C tier, bot
}
for _, name in pairs (hero_names) do
	LinkLuaModifier("modifier_npc_dota_hero_"..name.."_perk", "abilities/hero_perks/npc_dota_hero_"..name.."_perk.lua", LUA_MODIFIER_MOTION_NONE)
end

LinkLuaModifier("modifier_pudge_custom_flesh_heap_kill_tracker", "abilities/modifiers/modifier_pudge_custom_flesh_heap_kill_tracker.lua", LUA_MODIFIER_MOTION_NONE)
