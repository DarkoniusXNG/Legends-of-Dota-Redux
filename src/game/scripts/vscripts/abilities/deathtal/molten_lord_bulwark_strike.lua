LinkLuaModifier("modifier_bulwark_strike_lod", "abilities/deathtal/molten_lord_bulwark_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ablaze_modifier", "abilities/deathtal/molten_lord_ablaze_modifier.lua", LUA_MODIFIER_MOTION_NONE)

bulwark_strike = bulwark_strike or class({})

function bulwark_strike:GetIntrinsicModifierName()
	return "modifier_bulwark_strike_lod"
end

function bulwark_strike:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function bulwark_strike:IsStealable()
	return false
end

function bulwark_strike:ShouldUseResources()
	return true
end

function bulwark_strike:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_bulwark_strike_lod = modifier_bulwark_strike_lod or class({})

function modifier_bulwark_strike_lod:IsHidden()
	return true
end

function modifier_bulwark_strike_lod:IsDebuff()
	return false
end

function modifier_bulwark_strike_lod:IsPurgable()
	return false
end

function modifier_bulwark_strike_lod:RemoveOnDeath()
	return false
end

function modifier_bulwark_strike_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_bulwark_strike_lod.OnRefresh = modifier_bulwark_strike_lod.OnCreated

function modifier_bulwark_strike_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		--MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_bulwark_strike_lod:GetModifierProjectileName()
	if not IsServer() then return end
	if self.orb_attack then
		return "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
	end
end

-- function modifier_bulwark_strike_lod:GetAttackSound()
	-- if not IsServer() then return end
	-- if self.orb_attack then
		-- return "Hero_Clinkz.DeathPact.Cast"
	-- end
-- end

if IsServer() then
	function modifier_bulwark_strike_lod:OnAttackStart(event)
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

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) and (not target:IsMagicImmune()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				-- Changing attack sound and attack projectile goes here
				parent:EmitSound("Hero_Clinkz.DeathPact.Cast")
				-- Attack projectile change goes here
				self.orb_attack = true
			end
		end
	end

	function modifier_bulwark_strike_lod:OnAttack(event)
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

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) and (not target:IsMagicImmune()) then
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
			end
		end
	end

	function modifier_bulwark_strike_lod:OnAttackLanded(event)
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

		if self.procRecords[event.record] and not target:IsMagicImmune() then
			self:BulwarkStrikeEffect(event)
		end
	end

	function modifier_bulwark_strike_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_bulwark_strike_lod:BulwarkStrikeEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()

			-- Don't affect buildings, wards, spell immune units and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsMagicImmune() or target:IsInvulnerable() then
				return
			end

			local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
			local armor_multiplier = ability:GetLevelSpecialValueFor("armor_multiplier", ability:GetLevel() - 1)
			local ablaze_multiplier = ability:GetLevelSpecialValueFor("ablaze_multiplier", ability:GetLevel() - 1)
			local ablaze_duration = ability:GetLevelSpecialValueFor("ablaze_duration", ability:GetLevel() - 1)

			-- Calculate damage
			local armor = attacker:GetPhysicalArmorValue(false)
			local armor_damage = armor * armor_multiplier

			if target:HasModifier("ablaze_modifier") then
				-- Increase the damage
				armor_damage = armor_damage + armor * ablaze_multiplier
				-- Apply Ablaze to enemies near the target
				local enemies = FindUnitsInRadius(
					attacker:GetTeamNumber(),
					target:GetAbsOrigin(),
					nil,
					radius,
					ability:GetAbilityTargetTeam(),
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false
				)
				-- Apply Ablaze to all enemies in a radius including the attacked target
				for _, enemy in pairs(enemies) do
					enemy:AddNewModifier(attacker, ability, "ablaze_modifier", {duration = ablaze_duration})
				end
				
				self.particle2 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:ReleaseParticleIndex(self.particle2)
			else
				-- Apply Ablaze ONLY to the attacked target
				target:AddNewModifier(attacker, ability, "ablaze_modifier", {duration = ablaze_duration})

				-- Particle
				self.particle = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(self.particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_origin", attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(self.particle)
			end

			local damageTable = {
				victim = target,
				attacker = attacker,
				damage = armor_damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				ability = ability,
			}

			ApplyDamage(damageTable)

			self.procRecords[event.record] = nil
		end
	end
end
