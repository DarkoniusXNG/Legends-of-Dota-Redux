function StrafeAttack(keys)
	local caster = keys.caster
	local radius = caster:Script_GetAttackRange()
	local abilityName = keys.ability:GetName()

	if caster:IsRangedAttacker() == false then 
		radius = radius + 50
	end
	local counter = 1
	if caster:HasScepter() then
		counter = keys.ability:GetSpecialValueFor("targets_scepter")
	end

	if caster:PassivesDisabled() and abilityName == "ebf_clinkz_trickshot_passive" then return end

	local units = FindUnitsInRadius(
		caster:GetTeam(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		FIND_ANY_ORDER,
		false
	)

	local useCastAttackOrb = true
	local processProcs = true
	local skipCooldown = true
	local ignoreInvis = false
	local useProjectile = caster:IsRangedAttacker()
	local fakeAttack = false
	local neverMiss = not caster:IsRangedAttacker()

	for _, unit in pairs( units ) do
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3)
		if counter > 0 then
			if unit and not unit:IsNull() then
				caster:PerformAttack(unit, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)
				counter = counter - 1
			end
		end
	end
	
end
