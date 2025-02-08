local hero_names = {
	"abaddon", -- ok, very bad, D tier
	"abyssal_underlord", -- terrible
	"alchemist", -- ok
	"ancient_apparition", -- ok, too strong?
	"antimage", -- ok, D tier
	"arc_warden", -- ok, S tier
	"axe", -- ok
	"bane", -- ok
	"batrider", -- ok, kinda bad
	"beastmaster", -- ok
	"bloodseeker", -- ok
	"bounty_hunter", -- ok
	"brewmaster", -- terrible, A tier
	"bristleback", -- kinda bad
	"broodmother", -- kinda bad
	"centaur", -- ok, S tier
	"chaos_knight", -- ok
	"chen", -- badly coded idea not bad, S tier
	"clinkz", -- ok, D tier
	"crystal_maiden", -- kinda bad, D tier
	"dark_seer", -- kinda bad
	"dark_willow", -- kinda bad
	"dawnbreaker", -- kinda bad, missing icon, A tier
	"dazzle", -- kinda bad
	"death_prophet", -- ok, S tier
	"disruptor", -- terrible
	"doom_bringer", -- terrible and outdated
	"dragon_knight", -- ok, kinda bad, A tier
	"drow_ranger", -- ok, A tier
	"earth_spirit", -- ok, missing icon, S tier
	"earthshaker", -- ok, A tier
	"elder_titan", -- kinda bad
	"ember_spirit", -- kinda bad
	"enchantress", -- badly coded idea not bad
	"enigma", -- ok
	"faceless_void", -- ok
	"furion", -- ok, S tier
	"grimstroke", -- ok, A tier
	"gyrocopter", -- ok, A tier
	"hoodwink", -- missing icon
	"huskar", -- badly coded idea not bad, D tier
	"invoker", -- kinda bad, S tier
	"jakiro", -- ok
	"juggernaut", -- ok, A tier
	"keeper_of_the_light", -- ok, A tier
	--"kez", -- D tier
	"kunkka", -- terrible, S tier
	"legion_commander", -- terrible and badly coded and outdated
	"leshrac", -- ok, S tier
	"lich", -- terrible and badly coded
	"life_stealer", -- terrible and outdated, D tier
	"lina", -- terrible, S tier
	"lion", -- kinda bad
	"lone_druid", -- poorly coded, D tier
	"luna", -- ok
	"lycan", -- kinda bad
	"magnataur", -- ok
	--"marci",
	"mars", -- ok, S tier
	"medusa", -- A tier
	"meepo", -- kinda bad?
	"mirana", -- ok
	"monkey_king", -- ok, S tier
	"morphling", -- ok, A tier
	--"muerta", -- S tier
	"naga_siren", -- ok, A tier
	"necrolyte", -- ok, D tier
	"nevermore", -- ok, S tier
	"night_stalker", -- ok, A tier
	"nyx_assassin", -- kinda bad, D tier
	"obsidian_destroyer", -- ok, kinda bad, A tier
	"ogre_magi", -- ok, S tier
	"omniknight", -- ok
	"oracle", -- kinda bad, A tier
	"pangolier", -- ok, D tier
	"phantom_assassin", -- ok, kinda bad
	"phantom_lancer", -- kinda bad, D tier
	"phoenix", -- ok, D tier
	--"primal_beast", -- S tier
	"puck", -- kinda bad
	"pudge", -- ok
	"pugna", -- ok, S tier
	"queenofpain", -- kinda bad, A tier
	"rattletrap", -- ok, missing icon, A tier
	"razor", -- ok
	"riki", -- ok, D tier
	"rubick", -- ok
	"sand_king", -- outdated, D tier
	"shadow_demon", -- ok, A tier
	"shadow_shaman", -- too strong?
	"shredder", -- ok, A tier
	"silencer", -- ok
	"skeleton_king", -- ok
	"skywrath_mage", -- terrible
	"slardar", -- ok, A tier
	"slark", -- ok, D tier
	"snapfire", -- ok, A tier
	"sniper", -- ok, A tier
	"spectre", -- ok, D tier
	"spirit_breaker", -- ok, kinda bad
	"storm_spirit", -- ok, kinda bad
	"sven", -- ok
	"techies", -- ok, S tier
	"templar_assassin", -- ok, D tier
	"terrorblade", -- ok, S tier
	"tidehunter", -- ok, A tier
	"tinker", -- ok, D tier
	"tiny", -- badly coded idea not bad
	"treant", -- ok
	"troll_warlord", -- ok
	"tusk", -- terrible, S tier
	"undying", -- badly coded idea not bad
	"ursa", -- ok, kinda bad
	"vengefulspirit", -- ok
	"venomancer" , -- ok, D tier
	"viper", -- ok
	"visage", -- kinda bad
	"void_spirit", -- ok, kinda bad, D tier
	"warlock", -- too strong idea not bad, A tier
	"weaver", -- ok, D tier
	"windrunner", -- ok, kinda bad
	"winter_wyvern", -- ok, D tier
	"wisp", -- ok, D tier
	"witch_doctor", -- ok
	"zuus", -- ok, D tier
}
for _, name in pairs (hero_names) do
	LinkLuaModifier("modifier_npc_dota_hero_"..name.."_perk", "abilities/hero_perks/npc_dota_hero_"..name.."_perk.lua", LUA_MODIFIER_MOTION_NONE)
end
