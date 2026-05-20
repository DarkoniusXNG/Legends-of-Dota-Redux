LinkLuaModifier("modifier_zeus_static_field_old_passive", "abilities/zeus_static_field_old.lua", LUA_MODIFIER_MOTION_NONE)

zeus_static_field_old = zeus_static_field_old or class({})

function zeus_static_field_old:GetIntrinsicModifierName()
	return "modifier_zeus_static_field_old_passive"
end

function zeus_static_field_old:GetCastRange(location, target)
  return self:GetSpecialValueFor("radius")
end

---------------------------------------------------------------------------------------------------

modifier_zeus_static_field_old_passive = modifier_zeus_static_field_old_passive or class({})

function modifier_zeus_static_field_old_passive:IsHidden()
	return true
end

function modifier_zeus_static_field_old_passive:IsDebuff()
	return false
end

function modifier_zeus_static_field_old_passive:IsPurgable()
	return false
end

function modifier_zeus_static_field_old_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

if IsServer() then
	function modifier_zeus_static_field_old_passive:OnAbilityFullyCast(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local cast_ability = event.ability
		local caster = event.unit

		if parent:PassivesDisabled() then return end

		-- Check if caster has this modifier
		if caster ~= parent then return end

		if not cast_ability or cast_ability:IsNull() then
			return
		end
		if not cast_ability.GetAbilityKeyValues then
			return
		end

		local ability_data = cast_ability:GetAbilityKeyValues()
		local ability_mana_cost = cast_ability:GetManaCost(-1)
		local ability_cooldown = cast_ability:GetCooldown(-1)

		-- Ignore items
		if cast_ability:IsItem() then
			return
		end

		if not ability_data then
			return
		end

		-- Check behavior first
		local ability_behavior = ability_data.AbilityBehavior
		if string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_TOGGLE") then
			return
		end

		-- If the ability costs no mana, do nothing
		if ability_mana_cost == 0 then
			return
		end

		-- If the ability has no cooldown, do nothing
		if ability_cooldown == 0 then
			return
		end

		local radius = ability:GetSpecialValueFor("radius")
		local dmg_per_hp = ability:GetSpecialValueFor("current_hp_as_dmg_pct")

		-- Find the targets
		local enemies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)
		local particle_effect = "particles/units/heroes/hero_zuus/zuus_static_field.vpcf"
		if #enemies > 0 then
			-- Particle on caster
			local caster_position = parent:GetAbsOrigin()
			local particle_caster = ParticleManager:CreateParticle(particle_effect, PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(particle_caster, 0, caster_position)
			ParticleManager:SetParticleControl(particle_caster, 1, Vector(caster_position.x, caster_position.y, caster_position.z) * 100)
			ParticleManager:ReleaseParticleIndex(particle_caster)
		end
		for _, enemy in pairs(enemies) do
			if enemy and not enemy:IsNull() then
				if not enemy:IsRoshanCustom() then
					-- Particle on enemy
					local particle_enemy = ParticleManager:CreateParticle(particle_effect, PATTACH_ABSORIGIN_FOLLOW, enemy)
					ParticleManager:SetParticleControl(particle_enemy, 0, enemy:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(particle_enemy)
					
					-- Sound
					enemy:EmitSound("Hero_Zuus.StaticField")
					
					-- Apply damage
					ApplyDamage({
						victim = enemy,
						attacker = parent,
						damage = enemy:GetHealth() * dmg_per_hp / 100,
						damage_type = ability:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
						ability = ability,
					})
				end
			end
		end
	end
end
