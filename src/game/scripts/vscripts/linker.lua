local hero_names = {
	"abaddon", -- ok, very bad
	"abyssal_underlord", -- terrible
	"alchemist", -- ok
	"ancient_apparition", -- ok, too strong?
	"antimage", -- ok
	"arc_warden", -- terrible
	"axe", -- ok
	"bane", -- ok
	"batrider", -- ok, kinda bad
	"beastmaster", -- terrible
	"bloodseeker", -- terrible
	"bounty_hunter", -- ok
	"brewmaster", -- terrible
	"bristleback", -- kinda bad
	"broodmother", -- kinda bad
	"centaur", -- ok
	"chaos_knight", -- ok
	"chen", -- badly coded idea not bad
	"clinkz", -- ok
	"crystal_maiden", -- kinda bad
	"dark_seer", -- kinda bad
	"dark_willow", -- kinda bad
	"dawnbreaker", -- kinda bad, missing icon
	"dazzle", -- kinda bad
	"death_prophet", -- ok, too strong?
	"disruptor", -- terrible
	"doom_bringer", -- terrible and outdated
	"dragon_knight", -- ok, kinda bad
	"drow_ranger", -- ok
	"earth_spirit", -- ok, missing icon
	"earthshaker", -- ok
	"elder_titan", -- kinda bad
	"ember_spirit", -- kinda bad
	"enchantress", -- badly coded idea not bad
	"enigma", -- ok
	"faceless_void", -- ok
	"furion", -- ok
	"grimstroke", -- ok
	"gyrocopter", -- ok
	"hoodwink", -- missing icon
	"huskar", -- badly coded idea not bad
	"invoker", -- kinda bad
	"jakiro", -- ok
	"juggernaut", -- ok
	"keeper_of_the_light", -- ok
	"kunkka", -- terrible
	"legion_commander", -- terrible and badly coded and outdated
	"leshrac", -- ok
	"lich", -- terrible and badly coded
	"life_stealer", -- terrible and outdated
	"lina", -- terrible
	"lion", -- kinda bad
	"lone_druid", -- poorly coded
	"luna", -- ok
	"lycan", -- kinda bad
	"magnataur", -- ok
	--"marci",
	"mars", -- ok
	"medusa", -- too strong?
	"meepo", -- kinda bad?
	"mirana", -- ok
	"monkey_king", -- ok
	"morphling", -- ok
	--"muerta",
	"naga_siren", -- ok
	"necrolyte", -- ok
	"nevermore", -- ok
	"night_stalker", -- ok
	"nyx_assassin", -- kinda bad
	"obsidian_destroyer", -- ok, kinda bad
	"ogre_magi", -- ok
	"omniknight", -- ok
	"oracle", -- kinda bad
	"pangolier", -- ok
	"phantom_assassin", -- ok, kinda bad
	"phantom_lancer", -- kinda bad
	"phoenix", -- ok
	--"primal_beast",
	"puck", -- kinda bad
	"pudge", -- ok
	"pugna", -- ok
	"queenofpain", -- kinda bad
	"rattletrap", -- ok, missing icon
	"razor", -- ok
	"riki", -- ok, mana regen too strong?
	"rubick", -- ok
	"sand_king", -- outdated
	"shadow_demon", -- ok
	"shadow_shaman", -- too strong?
	"shredder", -- ok
	"silencer", -- ok
	"skeleton_king", -- ok
	"skywrath_mage", -- terrible
	"slardar", -- ok
	"slark", -- ok
	"snapfire", -- ok
	"sniper", -- ok
	"spectre", -- ok
	"spirit_breaker", -- ok, kinda bad
	"storm_spirit", -- ok, kinda bad
	"sven", -- ok
	"techies", -- ok
	"templar_assassin", -- ok
	"terrorblade", -- ok
	"tidehunter", -- ok
	"tinker", -- ok
	"tiny", -- badly coded idea not bad
	"treant", -- ok
	"troll_warlord", -- ok
	"tusk", -- terrible
	"undying", -- badly coded idea not bad
	"ursa", -- ok, kinda bad
	"vengefulspirit", -- ok
	"venomancer" , -- ok
	"viper", -- ok
	"visage", -- kinda bad
	"void_spirit", -- ok, kinda bad
	"warlock", -- too strong idea not bad
	"weaver", -- ok
	"windrunner", -- ok, kinda bad
	"winter_wyvern", -- ok
	"wisp", -- ok
	"witch_doctor", -- ok
	"zuus", -- ok
}
for _, name in pairs (hero_names) do
	LinkLuaModifier("modifier_npc_dota_hero_"..name.."_perk", "abilities/hero_perks/npc_dota_hero_"..name.."_perk.lua", LUA_MODIFIER_MOTION_NONE)
end
