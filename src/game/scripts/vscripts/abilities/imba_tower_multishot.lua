LinkLuaModifier("modifier_imba_tower_multishot", "abilities/imba_tower_multishot.lua", LUA_MODIFIER_MOTION_NONE)

imba_tower_multishot = imba_tower_multishot or class({})

function imba_tower_multishot:GetIntrinsicModifierName()
    return "modifier_imba_tower_multishot"
end

---------------------------------------------------------------------------------------------------

modifier_imba_tower_multishot = modifier_imba_tower_multishot or class({})

function modifier_imba_tower_multishot:IsHidden()
	return true
end

function modifier_imba_tower_multishot:IsDebuff()
	return false
end

function modifier_imba_tower_multishot:IsPurgable()
	return false
end

function modifier_imba_tower_multishot:RemoveOnDeath()
	return false
end

function modifier_imba_tower_multishot:OnCreated()
  local ability = self:GetAbility()
  if IsServer() then
    self.bonus_range = ability:GetSpecialValueFor("bonus_range")
  end
end

function modifier_imba_tower_multishot:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
	}
end

if IsServer() then
	function modifier_imba_tower_multishot:OnAttack(event)
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
		
		-- Check if invisible or dead
		if attacker:IsInvisible() or not attacker:IsAlive() then return end

		self:SplitShot(event.target)
	end

	function modifier_imba_tower_multishot:SplitShot(target)
		local parent = self:GetParent()
		local radius = parent:Script_GetAttackRange() + self.bonus_range
		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_ANY_ORDER,
			false
		)

		local useCastAttackOrb = true
		local processProcs = true
		local skipCooldown = true
		local ignoreInvis = true
		local useProjectile = parent:IsRangedAttacker()
		local fakeAttack = false
		local neverMiss = not parent:IsRangedAttacker()

		for _, enemy in pairs(enemies) do
			if enemy and enemy ~= target then

				parent:PerformAttack(enemy, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)
			end
		end
	end
end
