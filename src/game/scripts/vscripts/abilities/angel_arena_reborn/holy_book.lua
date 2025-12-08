-- OnAttackLanded
function HolyBook_attack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = keys.Radius
	local attack_dmg = keys.Damage

	if not caster or caster:IsNull() then
		return
	end

	if not caster:IsRealHero() then
		return
	end

	if caster:PassivesDisabled() then
		return
	end

	if not target or target:IsNull() then
		return
	end

	if not target:IsBaseNPC() then
		return
	end

	--if target:IsOther() or target:IsBuilding() then
		--return
	--end
	
	local position = target:GetAbsOrigin()
	local team = caster:GetTeamNumber()
	local damage_percent = ability:GetLevelSpecialValueFor("damage_percent", ability:GetLevel() - 1)
	local damage = attack_dmg * damage_percent / 100

	local damage_table = {
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
		ability = ability
	}

	local units = FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 

	for _, unit in pairs(units) do
		if unit and not unit:IsNull() then
			if unit ~= target and unit:GetTeamNumber() ~= team and unit:IsAlive() then
				damage_table.victim = unit
				ApplyDamage(damage_table)
			end
		end
	end
end