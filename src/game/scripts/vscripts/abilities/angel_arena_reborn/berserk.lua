function OnAttack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage / 100

	if not caster or caster:IsNull() then
		return
	end
	
	if caster:IsIllusion() then
		return
	end
	
	if not target or target:IsNull() then
		return
	end
	
	if not target:IsBaseNPC() then
		return
	end
	
	if target:IsOther() or target:IsBuilding() then
		return
	end

	local total_damage = damage * target:GetHealth()

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = total_damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability,
	}) 
end
