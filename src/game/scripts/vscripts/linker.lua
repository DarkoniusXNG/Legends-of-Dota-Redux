local hero_names = {
	"abaddon", -- ok, very bad, D tier
	"abyssal_underlord", -- ok
	"alchemist", -- ok
	"ancient_apparition", -- ok
	"antimage", -- ok, D tier
	"arc_warden", -- ok, S tier
	"axe", -- ok, bot
	"bane", -- ok, bot
	"batrider", -- ok
	"beastmaster", -- ok
	"bloodseeker", -- ok
	"bounty_hunter", -- ok, bot
	"brewmaster", -- ok, A tier
	"bristleback", -- kinda bad, bot
	"broodmother", -- kinda bad
	"centaur", -- ok, S tier
	"chaos_knight", -- ok, bot
	"chen", -- badly coded idea not bad, S tier
	"clinkz", -- ok, D tier
	"crystal_maiden", -- ok, D tier, bot
	"dark_seer", -- kinda bad
	"dark_willow", -- ok
	"dawnbreaker", -- kinda bad, missing icon, A tier
	"dazzle", -- kinda bad, bot
	"death_prophet", -- ok, S tier, bot
	"disruptor", -- terrible
	"doom_bringer", -- ok
	"dragon_knight", -- ok, kinda bad and outdated, A tier, bot
	"drow_ranger", -- ok, A tier, bot
	"earth_spirit", -- ok, missing icon, S tier
	"earthshaker", -- ok, A tier, bot
	"elder_titan", -- kinda bad
	"ember_spirit", -- kinda bad
	"enchantress", -- badly coded idea not bad
	"enigma", -- ok
	"faceless_void", -- ok
	"furion", -- ok, S tier
	"grimstroke", -- ok, A tier
	"gyrocopter", -- ok, A tier
	"hoodwink", -- ok, missing icon
	"huskar", -- ok, D tier
	"invoker", -- kinda bad, S tier
	"jakiro", -- ok, bot
	"juggernaut", -- ok, A tier, bot
	"keeper_of_the_light", -- ok, A tier
	--"kez", -- D tier
	"kunkka", -- ok, S tier, bot
	"legion_commander", -- ok
	"leshrac", -- ok, S tier
	"lich", -- ok, bot
	"life_stealer", -- ok, S tier
	"lina", -- ok, S tier, bot
	"lion", -- kinda bad, bot
	"lone_druid", -- poorly coded, D tier
	"luna", -- ok, bot
	"lycan", -- kinda bad
	"magnataur", -- ok
	--"marci",
	"mars", -- ok, missing icon, S tier
	"medusa", -- A tier
	"meepo", -- kinda bad?
	"mirana", -- ok
	"monkey_king", -- ok, S tier
	"morphling", -- ok, A tier
	--"muerta", -- S tier
	"naga_siren", -- ok, A tier
	"necrolyte", -- ok, D tier, bot
	"nevermore", -- ok, S tier, bot
	"night_stalker", -- ok, A tier
	"nyx_assassin", -- kinda bad, D tier
	"obsidian_destroyer", -- ok, kinda bad, A tier
	"ogre_magi", -- ok, S tier
	"omniknight", -- ok, bot
	"oracle", -- kinda bad, A tier, bot
	"pangolier", -- ok, D tier
	"phantom_assassin", -- ok, kinda bad, bot
	"phantom_lancer", -- kinda bad, D tier
	"phoenix", -- ok, D tier
	--"primal_beast", -- S tier
	"puck", -- ok
	"pudge", -- ok, bot
	"pugna", -- ok, S tier
	"queenofpain", -- kinda bad, A tier
	"rattletrap", -- ok, missing icon, A tier
	"razor", -- ok
	"riki", -- ok, D tier
	"rubick", -- ok
	"sand_king", -- ok, D tier, bot
	"shadow_demon", -- ok, A tier
	"shadow_shaman", -- too strong?
	"shredder", -- ok, A tier
	"silencer", -- ok
	"skeleton_king", -- ok, bot
	"skywrath_mage", -- terrible, bot
	"slardar", -- ok, A tier
	"slark", -- ok, D tier
	"snapfire", -- ok, missing icon, A tier
	"sniper", -- ok, A tier, bot
	"spectre", -- ok, D tier
	"spirit_breaker", -- ok, kinda bad
	"storm_spirit", -- ok, kinda bad
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
	"undying", -- badly coded idea not bad
	"ursa", -- ok, kinda bad
	"vengefulspirit", -- ok, bot
	"venomancer" , -- ok, D tier
	"viper", -- ok, bot
	"visage", -- kinda bad
	"void_spirit", -- ok, kinda bad, D tier
	"warlock", -- too strong idea not bad, A tier, bot
	"weaver", -- ok, D tier
	"windrunner", -- ok, bot
	"winter_wyvern", -- ok, D tier
	"wisp", -- ok, D tier
	"witch_doctor", -- ok, bot
	"zuus", -- ok, D tier, bot
}
for _, name in pairs (hero_names) do
	LinkLuaModifier("modifier_npc_dota_hero_"..name.."_perk", "abilities/hero_perks/npc_dota_hero_"..name.."_perk.lua", LUA_MODIFIER_MOTION_NONE)
end
