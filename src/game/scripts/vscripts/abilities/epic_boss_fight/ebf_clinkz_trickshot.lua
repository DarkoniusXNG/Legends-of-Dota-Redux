LinkLuaModifier("modifier_ebf_clinkz_trickshot_active", "abilities/epic_boss_fight/ebf_clinkz_trickshot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ebf_clinkz_trickshot_passive", "abilities/epic_boss_fight/ebf_clinkz_trickshot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ebf_clinkz_trickshot_passive_cd", "abilities/epic_boss_fight/ebf_clinkz_trickshot.lua", LUA_MODIFIER_MOTION_NONE)

ebf_clinkz_trickshot = ebf_clinkz_trickshot or class({})

function ebf_clinkz_trickshot:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	
	-- Sound
	caster:EmitSound("Hero_Clinkz.Strafe")
	
	-- Apply buff
	caster:AddNewModifier(caster, self, "modifier_ebf_clinkz_trickshot_active", {duration = duration})
end

---------------------------------------------------------------------------------------------------

ebf_clinkz_trickshot_passive = ebf_clinkz_trickshot_passive or class({})

function ebf_clinkz_trickshot_passive:GetIntrinsicModifierName()
    return "modifier_ebf_clinkz_trickshot_passive"
end

function ebf_clinkz_trickshot_passive:ShouldUseResources()
  return true
end

---------------------------------------------------------------------------------------------------

ebf_clinkz_trickshot_passive_ranged = ebf_clinkz_trickshot_passive_ranged or class({})

function ebf_clinkz_trickshot_passive_ranged:GetIntrinsicModifierName()
    return "modifier_ebf_clinkz_trickshot_passive"
end

function ebf_clinkz_trickshot_passive_ranged:ShouldUseResources()
  return true
end

---------------------------------------------------------------------------------------------------

modifier_ebf_clinkz_trickshot_active = modifier_ebf_clinkz_trickshot_active or class({})

function modifier_ebf_clinkz_trickshot_active:IsHidden()
	return false
end

function modifier_ebf_clinkz_trickshot_active:IsDebuff()
	return false
end

function modifier_ebf_clinkz_trickshot_active:IsPurgable()
	return true
end

function modifier_ebf_clinkz_trickshot_active:RemoveOnDeath()
	return true
end

function modifier_ebf_clinkz_trickshot_active:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then return end
	local interval = ability:GetSpecialValueFor("double_interval")

	self:OnIntervalThink()
	self:StartIntervalThink(interval)
end

if IsServer() then
	function modifier_ebf_clinkz_trickshot_active:OnIntervalThink()
		local parent = self:GetParent()

		if parent:IsInvisible() then
			return
		end

		local attackRange = parent:Script_GetAttackRange() + parent:GetHullRadius()
		local counter = 1

		local ability = self:GetAbility()
		if not ability or ability:IsNull() then return end

		if parent:HasScepter() then
			counter = ability:GetSpecialValueFor("targets_scepter")
		end

		local useCastAttackOrb = true
		local processProcs = true
		local skipCooldown = true
		local ignoreInvis = false
		local useProjectile = parent:IsRangedAttacker()
		local fakeAttack = false
		local neverMiss = not parent:IsRangedAttacker()

		-- Check for valid units
		local units = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil,
			attackRange,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_CLOSEST,
			false
		)

		for _, unit in ipairs(units) do
			if unit and not unit:IsNull() and parent:CanEntityBeSeenByMyTeam(unit) and not unit:IsInvulnerable() and not unit:IsAttackImmune() then
				-- Additional attack on closest unit within range
				parent:PerformAttack(unit, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)
				-- Decrease counter
				counter = counter - 1
				-- End the 'for' loop when counter reaches 0
				if counter <= 0 then
					return
				end
			end
		end
	end
end

function modifier_ebf_clinkz_trickshot_active:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_strafe_fire.vpcf"
end

function modifier_ebf_clinkz_trickshot_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

---------------------------------------------------------------------------------------------------

modifier_ebf_clinkz_trickshot_passive = modifier_ebf_clinkz_trickshot_passive or class({})

function modifier_ebf_clinkz_trickshot_passive:IsHidden()
	return true
end

function modifier_ebf_clinkz_trickshot_passive:IsDebuff()
	return false
end

function modifier_ebf_clinkz_trickshot_passive:IsPurgable()
	return false
end

function modifier_ebf_clinkz_trickshot_passive:RemoveOnDeath()
	return false
end

function modifier_ebf_clinkz_trickshot_passive:OnCreated()
	if not IsServer() then return end
	local interval = 0.1
	self:StartIntervalThink(interval)
end

if IsServer() then
	function modifier_ebf_clinkz_trickshot_passive:OnIntervalThink()
		local parent = self:GetParent()

		if parent:PassivesDisabled() or parent:IsInvisible() or parent:IsIllusion() or not parent:IsAlive() then
			return
		end

		local attackRange = parent:Script_GetAttackRange() + parent:GetHullRadius()
		local interval = 1.5
		local counter = 1

		local ability = self:GetAbility()
		-- Check if on cd
		if ability and not ability:IsNull() then
			if not ability:IsCooldownReady() then
				return
			end

			interval = ability:GetSpecialValueFor("double_interval")
			if parent:HasScepter() then
				counter = ability:GetSpecialValueFor("targets_scepter")
			end
		else
			-- Don't proc if on cooldown
			if parent:HasModifier("modifier_ebf_clinkz_trickshot_passive_cd") then
				return
			end
		end

		local useCastAttackOrb = true
		local processProcs = true
		local skipCooldown = true
		local ignoreInvis = false
		local useProjectile = parent:IsRangedAttacker()
		local fakeAttack = false
		local neverMiss = not parent:IsRangedAttacker()

		-- Check for valid units
		local units = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil,
			attackRange,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_CLOSEST,
			false
		)

		for _, unit in ipairs(units) do
			if unit and not unit:IsNull() and parent:CanEntityBeSeenByMyTeam(unit) and not unit:IsInvulnerable() and not unit:IsAttackImmune() then
				-- Additional attack on closest unit within range
				parent:PerformAttack(unit, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)
				-- Decrease counter
				counter = counter - 1
				-- Trigger cooldown and end the 'for' loop when counter reaches 0
				if counter <= 0 then
					if ability and not ability:IsNull() then
						ability:StartCooldown(interval)
					else
						parent:AddNewModifier(parent, nil, "modifier_ebf_clinkz_trickshot_passive_cd", {duration = interval})
					end

					return
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_ebf_clinkz_trickshot_passive_cd = modifier_ebf_clinkz_trickshot_passive_cd or class({})

function modifier_ebf_clinkz_trickshot_passive_cd:IsHidden()
	return true
end

function modifier_ebf_clinkz_trickshot_passive_cd:IsDebuff()
	return false -- needs to be false because of Debuff Immunity
end

function modifier_ebf_clinkz_trickshot_passive_cd:IsPurgable()
	return false
end

function modifier_ebf_clinkz_trickshot_passive_cd:RemoveOnDeath()
	return true
end

