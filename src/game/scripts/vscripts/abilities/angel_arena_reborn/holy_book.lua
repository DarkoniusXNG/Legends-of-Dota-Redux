function GetDamagePercent(caster, ability)
	local summ_pct = ability:GetLevelSpecialValueFor("damage_percent", ability:GetLevel() - 1)

	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
		local item = caster:GetItemInSlot(i)
		if item and item ~= ability and item:GetName() == ability:GetName() then
			summ_pct = summ_pct + item:GetSpecialValueFor("damage_percent")
		end
	end
	return summ_pct
end

function HolyBook_attack( keys )
	local caster = keys.caster
	if not caster or caster:IsNull() then return end
	if not caster:IsRealHero() then return end
	if caster:PassivesDisabled() then return end
	local target = keys.target
	local ability = keys.ability
	local position = keys.target:GetAbsOrigin()
	local team = caster:GetTeamNumber()
	local radius = keys.Radius
	local damage_percent = GetDamagePercent(caster, ability)

	local damage = keys.Damage*(damage_percent/100)

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