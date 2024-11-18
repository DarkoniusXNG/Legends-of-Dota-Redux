LinkLuaModifier("modifier_achlys_miserable_claws_lod", "abilities/nextgeneration/hero_achlys/achlys_miserable_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_achlys_miserable_claws_debuff", "abilities/nextgeneration/hero_achlys/achlys_miserable_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_achlys_miserable_claws_debuff_counter", "abilities/nextgeneration/hero_achlys/achlys_miserable_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_achlys_miserable_claws_root", "abilities/nextgeneration/hero_achlys/achlys_miserable_claws.lua", LUA_MODIFIER_MOTION_NONE)

achlys_miserable_claws = achlys_miserable_claws or class({})

function achlys_miserable_claws:GetIntrinsicModifierName()
	return "modifier_achlys_miserable_claws_lod"
end

function achlys_miserable_claws:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function achlys_miserable_claws:IsStealable()
	return false
end

function achlys_miserable_claws:ShouldUseResources()
	return true
end

function achlys_miserable_claws:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_achlys_miserable_claws_lod = modifier_achlys_miserable_claws_lod or class({})

function modifier_achlys_miserable_claws_lod:IsHidden()
	return true
end

function modifier_achlys_miserable_claws_lod:IsDebuff()
	return false
end

function modifier_achlys_miserable_claws_lod:IsPurgable()
	return false
end

function modifier_achlys_miserable_claws_lod:RemoveOnDeath()
	return false
end

function modifier_achlys_miserable_claws_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_achlys_miserable_claws_lod.OnRefresh = modifier_achlys_miserable_claws_lod.OnCreated

function modifier_achlys_miserable_claws_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_achlys_miserable_claws_lod:GetModifierProjectileName()
	if not IsServer() then return end
	if self.orb_attack then
		return "particles/units/heroes/hero_bane/bane_projectile.vpcf"
	end
end

if IsServer() then
	function modifier_achlys_miserable_claws_lod:OnAttackStart(event)
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

	function modifier_achlys_miserable_claws_lod:OnAttack(event)
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
				parent:EmitSound("Hero_LifeStealer.PreAttack")
			end
		end
	end

	function modifier_achlys_miserable_claws_lod:OnAttackLanded(event)
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

	function modifier_achlys_miserable_claws_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_achlys_miserable_claws_lod:SpellEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()

			-- Don't affect buildings, wards, and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
				return
			end

			-- Sound when attack lands
			target:EmitSound("Hero_Nightstalker.Attack")

			-- Apply modifier
			target:AddNewModifier(attacker, ability, "modifier_achlys_miserable_claws_debuff", {duration = ability:GetSpecialValueFor("duration")})

			-- Stack counter modifier (needs 2 modifiers because debuffs are independent)
			IncreaseStackCount(attacker, target, ability)

			self.procRecords[event.record] = nil
		end
	end
end

function IncreaseStackCount(caster, target, ability)
	local modifier_name = "modifier_achlys_miserable_claws_debuff_counter"
	local dur = ability:GetSpecialValueFor("duration")

	local modifier = target:FindModifierByNameAndCaster(modifier_name, caster)

	-- if the unit does not already have the counter modifier we apply it with a stackcount of 1
	-- else we increase the stack and refresh the counters duration
	if not modifier then
		target:AddNewModifier(caster, ability, modifier_name, {duration = dur})
		target:SetModifierStackCount(modifier_name, caster, 1)
	else
		modifier:IncrementStackCount()
		modifier:SetDuration(dur, true)
	end
end

---------------------------------------------------------------------------------------------------

modifier_achlys_miserable_claws_debuff = modifier_achlys_miserable_claws_debuff or class({})

function modifier_achlys_miserable_claws_debuff:IsHidden()
	return true
end

function modifier_achlys_miserable_claws_debuff:IsDebuff()
	return true
end

function modifier_achlys_miserable_claws_debuff:IsPurgable()
	return true
end

function modifier_achlys_miserable_claws_debuff:RemoveOnDeath()
	return true
end

function modifier_achlys_miserable_claws_debuff:GetEffectName()
	return "particles/achlys_miserable_claws_debuff.vpcf"
end

function modifier_achlys_miserable_claws_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_achlys_miserable_claws_debuff:GetAttributes() -- Modifiers stack additivly with independent durations
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_achlys_miserable_claws_debuff:OnCreated()
	local ability = self:GetAbility()
	self.slow = ability:GetSpecialValueFor("slow_per_stack")
	self.armor = ability:GetSpecialValueFor("armor_per_stack")
end

function modifier_achlys_miserable_claws_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_achlys_miserable_claws_debuff:GetModifierMoveSpeedBonus_Percentage()
	return 0 - math.abs(self.slow)
end

function modifier_achlys_miserable_claws_debuff:GetModifierPhysicalArmorBonus()
	return 0 - math.abs(self.armor)
end

function modifier_achlys_miserable_claws_debuff:OnDestroy()
    -- Updating visual modifier's stack count
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local modifier_name = "modifier_achlys_miserable_claws_debuff_counter"
		local modifier = target:FindModifierByNameAndCaster(modifier_name, caster)
		if modifier then
			modifier:DecrementStackCount()
			if modifier:GetStackCount() <= 0 then
				target:RemoveModifierByName(modifier_name)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_achlys_miserable_claws_debuff_counter = modifier_achlys_miserable_claws_debuff_counter or class({})

function modifier_achlys_miserable_claws_debuff_counter:IsHidden()
	return false
end

function modifier_achlys_miserable_claws_debuff_counter:IsDebuff()
	return true
end

function modifier_achlys_miserable_claws_debuff_counter:IsPurgable()
	return true
end

function modifier_achlys_miserable_claws_debuff_counter:RemoveOnDeath()
	return true
end

function modifier_achlys_miserable_claws_debuff_counter:OnCreated()
	local ability = self:GetAbility()
	self.slow = ability:GetSpecialValueFor("slow_per_stack")
	self.armor = ability:GetSpecialValueFor("armor_per_stack")
end

function modifier_achlys_miserable_claws_debuff_counter:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_TOOLTIP2,
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_achlys_miserable_claws_debuff_counter:OnTooltip()
	return self:GetStackCount() * math.abs(self.armor)
end

function modifier_achlys_miserable_claws_debuff_counter:OnTooltip2()
	return self:GetStackCount() * math.abs(self.slow)
end

if IsServer() then
	function modifier_achlys_miserable_claws_debuff_counter:OnAttacked(event)
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()

		if event.attacker ~= caster or event.target ~= target or not ability then
			return
		end

		if not CheckAngle(caster, target) and target:GetIdealSpeed() == 100 and not target:HasModifier("modifier_achlys_miserable_claws_root") then
			target:AddNewModifier(caster, ability, "modifier_achlys_miserable_claws_root", {duration = ability:GetSpecialValueFor("root_duration")})

			-- Sound when root is applied
			target:EmitSound("Hero_Nightstalker.Void") -- Hero_Bane.Nightmare
		end
	end
end

function CheckAngle(caster, target)
	local victim_angle = target:GetAnglesAsVector().y
	local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0

	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)

	return result_angle >= (-(90 / 2)) and result_angle <= ((90 / 2))
end

---------------------------------------------------------------------------------------------------

modifier_achlys_miserable_claws_root = modifier_achlys_miserable_claws_root or class({})

function modifier_achlys_miserable_claws_root:IsHidden()
	return false
end

function modifier_achlys_miserable_claws_root:IsDebuff()
	return true
end

function modifier_achlys_miserable_claws_root:IsPurgable()
	return true
end

function modifier_achlys_miserable_claws_root:RemoveOnDeath()
	return true
end

function modifier_achlys_miserable_claws_root:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_achlys_miserable_claws_root:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()

	-- Check facing of the rooted unit
	if CheckAngle(caster, target) then
		target:RemoveModifierByName("modifier_achlys_miserable_claws_root")
	end
end

function modifier_achlys_miserable_claws_root:GetEffectName()
	return "particles/achlys_miserable_claws_root.vpcf"
end

function modifier_achlys_miserable_claws_root:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_achlys_miserable_claws_root:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end
