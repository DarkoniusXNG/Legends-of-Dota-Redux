LinkLuaModifier("modifier_veera_pursuit_lod", "abilities/nextgeneration/hero_veera/pursuit.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veera_pursuit_debuff", "abilities/nextgeneration/hero_veera/pursuit.lua", LUA_MODIFIER_MOTION_NONE)

veera_pursuit = veera_pursuit or class({})

function veera_pursuit:GetIntrinsicModifierName()
	return "modifier_veera_pursuit_lod"
end

function veera_pursuit:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function veera_pursuit:IsStealable()
	return false
end

function veera_pursuit:ShouldUseResources()
	return true
end

function veera_pursuit:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_veera_pursuit_lod = modifier_veera_pursuit_lod or class({})

function modifier_veera_pursuit_lod:IsHidden()
	return true
end

function modifier_veera_pursuit_lod:IsDebuff()
	return false
end

function modifier_veera_pursuit_lod:IsPurgable()
	return false
end

function modifier_veera_pursuit_lod:RemoveOnDeath()
	return false
end

function modifier_veera_pursuit_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_veera_pursuit_lod.OnRefresh = modifier_veera_pursuit_lod.OnCreated

function modifier_veera_pursuit_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		--MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

-- function modifier_veera_pursuit_lod:GetModifierProjectileName()
	-- if not IsServer() then return end
	-- if self.orb_attack then
		-- return ""
	-- end
-- end

if IsServer() then
	function modifier_veera_pursuit_lod:OnAttackStart(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		self.orb_attack = false

		-- Don't affect buildings and wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				-- Attack projectile change goes here
				self.orb_attack = true
			end
		end
	end

	function modifier_veera_pursuit_lod:OnAttack(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Don't affect buildings and wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				--The Attack while Autocast is ON or or manually casted (current active ability)

				-- Enable proc for this attack record number (event.record is the same for OnAttackLanded)
				self.procRecords[event.record] = true

				if self.trigger_essence_aura then
					-- Using attack modifier abilities doesn't actually fire any cast events so we need to do it manually
					-- Using CastAbility (ability needs to have OnSpellStart()) to trigger Essence Aura
					ability:CastAbility()
				else
					-- Use mana and trigger cd while respecting reductions
					-- Using attack modifier abilities doesn't actually fire any cast events so we need to use resources here
					ability:UseResources(true, false, false, true)
				end

				-- Attack sound goes here
				--parent:EmitSound("")
			end
		end
	end

	function modifier_veera_pursuit_lod:OnAttackLanded(event)
		local parent = self:GetParent()
		local attacker = event.attacker
		local target = event.target

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check if attacked entity is an item, rune or something weird
		if target.GetUnitName == nil then
			return
		end

		if self.procRecords[event.record] then
			self:SpellEffect(event)
		end
	end

	function modifier_veera_pursuit_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_veera_pursuit_lod:SpellEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()

			-- Don't affect buildings, wards, and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
				return
			end

			-- Sound when attack lands
			target:EmitSound("Hero_Veera.Pursuit") -- Hero_BountyHunter.Jinada

			-- Apply modifier to attacked unit
			if target:IsHero() then
				target:AddNewModifier(attacker, ability, "modifier_veera_pursuit_debuff", {duration = ability:GetSpecialValueFor("duration")})
			else
				target:AddNewModifier(attacker, ability, "modifier_veera_pursuit_debuff", {duration = ability:GetSpecialValueFor("creep_duration")})
			end

			-- Backflip
			RollInitiate(attacker, ability)

			self.procRecords[event.record] = nil
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_veera_pursuit_debuff = modifier_veera_pursuit_debuff or class({})

function modifier_veera_pursuit_debuff:IsHidden()
	return false
end

function modifier_veera_pursuit_debuff:IsDebuff()
	return true
end

function modifier_veera_pursuit_debuff:IsPurgable()
	return true
end

function modifier_veera_pursuit_debuff:RemoveOnDeath()
	return true
end

function modifier_veera_pursuit_debuff:GetEffectName()
	return "particles/veera_pursuit_damage.vpcf"
end

function modifier_veera_pursuit_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_veera_pursuit_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_veera_pursuit_debuff:StatusEffectPriority()
	return 10
end

function modifier_veera_pursuit_debuff:OnCreated()
	local ability = self:GetAbility()
	self.slow = ability:GetSpecialValueFor("movement_slow")
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(1)
	end
end

function modifier_veera_pursuit_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then
		return
	end
	local ability_lvl = ability:GetLevel() - 1
	local base_dmg = ability:GetLevelSpecialValueFor("base_damage", ability_lvl)
	local dmg_per_extra_ms = ability:GetLevelSpecialValueFor("movement_damage", ability_lvl)

	-- Get current move speed of the caster
	local current_speed = caster:GetIdealSpeed()

	-- Get base move speed
	local base_speed = caster:GetBaseMoveSpeed()

	-- Calculate extra move speed
	local extra_ms = math.max(current_speed - base_speed, 0)

	-- Calculate bonus damage
	local bonus_dmg = extra_ms * dmg_per_extra_ms * 0.01

	local damage_table = {
		victim = target,
		attacker = caster,
		damage = base_dmg + bonus_dmg,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK,
		ability = ability,
	}

	ApplyDamage(damage_table)
end

function modifier_veera_pursuit_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_veera_pursuit_debuff:GetModifierMoveSpeedBonus_Percentage()
	return 0 - math.abs(self.slow)
end

---------------------------------------------------------------------------------------------------

require('lib/physics')

function RollInitiate(caster, ability)
	-- local leap_speed = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false) + 50
	local casterAngles = caster:GetAngles()
	local start_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
	local land_distance = 450

	-- Physics
	local direction = caster:GetForwardVector()
	-- local velocity = leap_speed * 3.0
	local velocity = land_distance / end_time
	local end_time = 0.6
	local time_elapsed = 0
	local time = 0.3
	local jump = 48
	local flip = 360

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetPhysicsVelocity(-direction * velocity)

	-- Move the unit
	Timers:CreateTimer(0, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
		time_elapsed = time_elapsed + 0.03
		local yaw = casterAngles.x - ((time_elapsed * 3) * flip)
		GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 150, false)
		caster:SetAngles(yaw, casterAngles.y, casterAngles.z )
		if flip > 0 then flip = flip - 12 else flip = 0 end

		if time_elapsed < 0.3 then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump))
			ProjectileManager:ProjectileDodge(caster)
			jump = jump - 2.4
		else
			caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
			jump = jump * 1.06
		end

		if caster:GetAbsOrigin().z - ground_position.z <= 0 then
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin() , caster))
		end
		if time_elapsed > end_time and caster:GetAbsOrigin().z - ground_position.z <= 0 then
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
			caster:SetAngles(0, casterAngles.y, casterAngles.z )
			caster:SetPhysicsAcceleration(Vector(0,0,0))
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			caster:PreventDI(false)
			caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
			caster:SetAutoUnstuck(true)
			caster:FollowNavMesh(true)
			caster:SetPhysicsFriction(.05)
			return nil
		end

		return 0.03
	end)
end
