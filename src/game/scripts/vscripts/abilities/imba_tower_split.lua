LinkLuaModifier("modifier_imba_tower_split", "abilities/imba_tower_split.lua", LUA_MODIFIER_MOTION_NONE)

imba_tower_split = imba_tower_split or class({})

function imba_tower_split:GetIntrinsicModifierName()
    return "modifier_imba_tower_split"
end

function imba_tower_split:OnProjectileHit(target, location)
	if not target or target:IsNull() then
		return
	end

	local caster = self:GetCaster()
	if not caster or caster:IsNull() then
		return
	end

	local useCastAttackOrb = false
	local processProcs = true
	local skipCooldown = true
	local ignoreInvis = false
	local useProjectile = false
	local fakeAttack = false
	local neverMiss = not caster:IsRangedAttacker()

	caster:PerformAttack(target, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)

	return true
end

---------------------------------------------------------------------------------------------------

modifier_imba_tower_split = modifier_imba_tower_split or class({})

function modifier_imba_tower_split:IsHidden()
	return true
end

function modifier_imba_tower_split:IsDebuff()
	return false
end

function modifier_imba_tower_split:IsPurgable()
	return false
end

function modifier_imba_tower_split:RemoveOnDeath()
	return false
end

function modifier_imba_tower_split:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

if IsServer() then
	function modifier_imba_tower_split:OnAttackLanded(event)
		local parent = self:GetParent()
		local attacker = event.attacker

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		-- Prevent looping
		if event.no_attack_cooldown then
			return
		end
		
		-- Check if affected by break
		if attacker:PassivesDisabled() then return end
		
		-- Check if real hero or building
		if not attacker:IsRealHero() and not attacker:IsBuilding() then return end
		
		-- Check if invisible
		if attacker:IsInvisible() then return end

		local target = event.target
		local ability = self:GetAbility()
		
		-- Parameters
		local split_chance = ability:GetSpecialValueFor("split_chance")
		local split_radius = ability:GetSpecialValueFor("split_radius")
		local split_amount = ability:GetSpecialValueFor("split_amount")
		local target_pos = target:GetAbsOrigin()
		
		-- Roll for splinter chance
		if RandomInt(1, 100) <= split_chance then

			-- Choose the correct particle for this tower
			local attack_projectile = parent:GetRangedProjectileName()
			local parent_team = parent:GetTeamNumber()
			if not attack_projectile or attack_projectile == "" or attack_projectile == "particles/base_attacks/ranged_hero.vpcf" then
				if parent_team == DOTA_TEAM_BADGUYS then
					attack_projectile = "particles/base_attacks/ranged_tower_bad.vpcf"
				elseif parent_team == DOTA_TEAM_GOODGUYS then
					attack_projectile = "particles/base_attacks/ranged_tower_good.vpcf"
				end
			end
			local speed = parent:GetProjectileSpeed()
			if not speed or speed == 0 then
				speed = 750
			end

			-- Find enemies near the target
			local nearby_enemies = FindUnitsInRadius(
				parent_team,
				target_pos,
				nil,
				split_radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false
			)
			
			-- Fake split projectile info
			local split_projectile = {
				Source = target,
				Ability = ability,
				EffectName = attack_projectile,
				bDodgeable = true,
				bProvidesVision = false,
				iMoveSpeed = speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				bVisibleToEnemies = true,
			}

			-- Create fake split projectiles
			for _, enemy in pairs(nearby_enemies) do
				if enemy and not enemy:IsNull() and enemy ~= target and not enemy:IsInvulnerable() and not enemy:IsAttackImmune() then
					split_projectile.Target = enemy
					ProjectileManager:CreateTrackingProjectile(split_projectile)
					
					-- Decrease split amount
					split_amount = split_amount - 1
					
					-- Check if max amount is reached
					if split_amount <= 0 then
						return
					end
				end
			end
		end
	end
end
