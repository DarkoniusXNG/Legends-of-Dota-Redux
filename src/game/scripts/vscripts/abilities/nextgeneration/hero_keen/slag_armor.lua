LinkLuaModifier("modifier_keen_commander_slag_armor_lod", "abilities/nextgeneration/hero_keen/slag_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slag_armor_debuff", "abilities/nextgeneration/hero_keen/slag_armor.lua", LUA_MODIFIER_MOTION_NONE)

keen_commander_slag_armor = keen_commander_slag_armor or class({})

function keen_commander_slag_armor:GetIntrinsicModifierName()
	return "modifier_keen_commander_slag_armor_lod"
end

function keen_commander_slag_armor:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function keen_commander_slag_armor:IsStealable()
	return false
end

function keen_commander_slag_armor:ShouldUseResources()
	return true
end

function keen_commander_slag_armor:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_keen_commander_slag_armor_lod = modifier_keen_commander_slag_armor_lod or class({})

function modifier_keen_commander_slag_armor_lod:IsHidden()
	return true
end

function modifier_keen_commander_slag_armor_lod:IsDebuff()
	return false
end

function modifier_keen_commander_slag_armor_lod:IsPurgable()
	return false
end

function modifier_keen_commander_slag_armor_lod:RemoveOnDeath()
	return false
end

function modifier_keen_commander_slag_armor_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_keen_commander_slag_armor_lod.OnRefresh = modifier_keen_commander_slag_armor_lod.OnCreated

function modifier_keen_commander_slag_armor_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_keen_commander_slag_armor_lod:GetModifierProjectileName()
	if not IsServer() then return end
	if self.orb_attack then
		return "particles/econ/events/coal/coal_projectile.vpcf" -- "particles/keen_slag_armor_projectile.vpcf"
	end
end

if IsServer() then
	function modifier_keen_commander_slag_armor_lod:OnAttackStart(event)
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

	function modifier_keen_commander_slag_armor_lod:OnAttack(event)
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

	function modifier_keen_commander_slag_armor_lod:OnAttackLanded(event)
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

	function modifier_keen_commander_slag_armor_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_keen_commander_slag_armor_lod:SpellEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()

			-- Don't affect buildings, wards, and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
				return
			end

			-- Sound when attack lands
			target:EmitSound("Hero_Batrider.StickyNapalm.Impact")

			-- Apply modifier to attacked unit
			IncreaseStackCount(attacker, target, ability)

			if attacker:HasModifier("modifier_siege_mode") then
				local siege_mode = attacker:FindAbilityByName("keen_commander_siege_mode")
				if siege_mode then
					local radius = siege_mode:GetLevelSpecialValueFor("splash_radius", siege_mode:GetLevel() -1)
					local enemies = FindUnitsInRadius(
						attacker:GetTeamNumber(),
						target:GetAbsOrigin(),
						nil,
						radius,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
						DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
						FIND_ANY_ORDER,
						false
					)

					for _, enemy in pairs(enemies) do
						if enemy ~= target then
							-- Apply modifier to each splashed enemy
							IncreaseStackCount(attacker, enemy, ability)
						end
					end
				end
			end

			self.procRecords[event.record] = nil
		end
	end
end

function IncreaseStackCount(caster, target, ability)
	local modifier_name = "modifier_slag_armor_debuff"
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

modifier_slag_armor_debuff = modifier_slag_armor_debuff or class({})

function modifier_slag_armor_debuff:IsHidden()
	return false
end

function modifier_slag_armor_debuff:IsDebuff()
	return true
end

function modifier_slag_armor_debuff:IsPurgable()
	return true
end

function modifier_slag_armor_debuff:RemoveOnDeath()
	return true
end

function modifier_slag_armor_debuff:GetEffectName()
	return "particles/keen_slag_armor_debuff.vpcf"
end

function modifier_slag_armor_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_slag_armor_debuff:OnCreated()
	local ability = self:GetAbility()
	self.armor = ability:GetSpecialValueFor("armor_reduction")
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(1)
	end
end

function modifier_slag_armor_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local count = self:GetStackCount()

	local dps = ability:GetLevelSpecialValueFor("damage_per_second", ability:GetLevel() -1)

	if caster:HasScepter() then
		dps = dps + count * ability:GetLevelSpecialValueFor("scepter_dps_per_stack", ability:GetLevel() -1)
	end

	local damage_table = {
		victim = target,
		attacker = caster,
		damage = dps,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK,
		ability = ability,
	}

	ApplyDamage(damage_table)
end

function modifier_slag_armor_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_slag_armor_debuff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * (0 - math.abs(self.armor))
end

