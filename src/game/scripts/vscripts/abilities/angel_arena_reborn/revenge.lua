function takedamage(params)
	local damage = params.Damage
	local attacker = params.attacker
	local caster = params.caster
	local ability = params.ability

	if not ability or ability:IsNull() then
		return
	end

	local diff = ability:GetLevelSpecialValueFor("reduce_percent", ability:GetLevel() - 1) / 100

	if not ability:IsCooldownReady() then
		return
	end

	if not caster or caster:IsNull() then
		return
	end

	if caster:PassivesDisabled() then
		return
	end

	--if caster:IsIllusion() then
		--return
	--end

	if not attacker or attacker:IsNull() then
		return
	end

	if not attacker:IsBaseNPC() then
		return
	end

	-- Do not trigger on wards, buildings and invulnerable units
	if attacker:IsOther() or attacker:IsBuilding() or attacker:IsInvulnerable() then
		return
	end

	if damage <= 0 then
		return
	end

	local castersInt = caster:GetIntellect(false)
	local attackersInt = 0 -- default for non-heroes

	-- Find attacker's int, 
	if attacker:IsHero() then
		attackersInt = attacker:GetIntellect(false)
	end
	
	-- if attacker's int is higher -> do nothing
	if attackersInt >= castersInt then
		return
	end

	local revenge_dmg = (castersInt - attackersInt) * diff

	ApplyDamage({
		victim = attacker,
		attacker = caster,
		damage = revenge_dmg,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability,
	})

	local cooldown = ability:GetCooldown( ability:GetLevel() )
	ability:StartCooldown( cooldown )
end
