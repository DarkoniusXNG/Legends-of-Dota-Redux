
function StartArmageddon(keys)
	local caster = keys.caster
	local ability = keys.ability

	local duration = ability:GetSpecialValueFor("duration")
	local interval = 1 / ability:GetSpecialValueFor("meteors_per_second")
	local counter = 0

	local units = FindUnitsInRadius(
		caster:GetTeam(),
		Vector(0, 0, 0),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	
	local total = #units
end 


