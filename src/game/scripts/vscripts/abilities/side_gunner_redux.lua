
LinkLuaModifier("modifier_side_gunner_redux", "abilities/side_gunner_redux.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_side_gunner_redux_cd", "abilities/side_gunner_redux.lua", LUA_MODIFIER_MOTION_NONE)

side_gunner_redux = side_gunner_redux or class({})

function side_gunner_redux:GetIntrinsicModifierName()
    return "modifier_side_gunner_redux"
end

function side_gunner_redux:ShouldUseResources()
  return true
end

function side_gunner_redux:OnProjectileHit(target, location)
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

modifier_side_gunner_redux = modifier_side_gunner_redux or class({})

function modifier_side_gunner_redux:IsHidden()
	return true
end

function modifier_side_gunner_redux:IsDebuff()
	return false
end

function modifier_side_gunner_redux:IsPurgable()
	return false
end

function modifier_side_gunner_redux:RemoveOnDeath()
	return false
end

function modifier_side_gunner_redux:OnCreated()
	if not IsServer() then return end
	local interval = 0.1
	self:StartIntervalThink(interval)
end

if IsServer() then
	function modifier_side_gunner_redux:OnIntervalThink()
		local parent = self:GetParent()

		if parent:PassivesDisabled() or parent:IsInvisible() or parent:IsIllusion() or not parent:IsAlive() then
			return
		end

		local attackRange = 700
		local interval = 3

		local ability = self:GetAbility()
		if ability and not ability:IsNull() then
			if not ability:IsCooldownReady() then
				return
			end

			attackRange = ability:GetSpecialValueFor("range")
			interval = ability:GetSpecialValueFor("interval")
			if parent:HasScepter() then
				interval = ability:GetSpecialValueFor("interval_scepter")
			end
		else
			-- Don't proc if on cooldown
			if parent:HasModifier("modifier_side_gunner_redux_cd") then
				return
			end
		end

		local projectileSpeed = parent:GetProjectileSpeed()
		if not projectileSpeed or projectileSpeed == 0 then
			projectileSpeed = 3000
		end

		-- Check for valid units
		local units = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil,
			attackRange,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		for _, unit in pairs(units) do
			if unit and not unit:IsNull() and parent:CanEntityBeSeenByMyTeam(unit) and not unit:IsInvulnerable() and not unit:IsAttackImmune() then
				local projectileInfo =
				{
					EffectName = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
					Ability = ability,
					Target = unit,
					Source = parent,
					bHasFrontalCone = false,
					iMoveSpeed = projectileSpeed,
					bReplaceExisting = false,
					bProvidesVision = false,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
				}

				parent:EmitSound("Hero_Gyrocopter.Attack")

				ProjectileManager:CreateTrackingProjectile(projectileInfo)

				if ability and not ability:IsNull() then
					ability:StartCooldown(interval)
				else
					parent:AddNewModifier(parent, nil, "modifier_side_gunner_redux_cd", {duration = interval})
				end

				return
			end
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_side_gunner_redux_cd = modifier_side_gunner_redux_cd or class({})

function modifier_side_gunner_redux_cd:IsHidden()
	return false
end

function modifier_side_gunner_redux_cd:IsDebuff()
	return false -- needs to be false because of Debuff Immunity
end

function modifier_side_gunner_redux_cd:IsPurgable()
	return false
end

function modifier_side_gunner_redux_cd:RemoveOnDeath()
	return true
end
