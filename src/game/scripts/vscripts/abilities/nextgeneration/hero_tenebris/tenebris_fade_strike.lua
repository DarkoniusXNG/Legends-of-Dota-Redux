LinkLuaModifier("modifier_tenebris_fade_strike_lod", "abilities/nextgeneration/hero_tenebris/tenebris_fade_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tenebris_fade_strike_buff", "abilities/nextgeneration/hero_tenebris/tenebris_fade_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tenebris_fade_strike_debuff", "abilities/nextgeneration/hero_tenebris/tenebris_fade_strike.lua", LUA_MODIFIER_MOTION_NONE)

tenebris_fade_strike = tenebris_fade_strike or class({})

function tenebris_fade_strike:GetIntrinsicModifierName()
	return "modifier_tenebris_fade_strike_lod"
end

function tenebris_fade_strike:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange()
end

function tenebris_fade_strike:IsStealable()
	return false
end

function tenebris_fade_strike:ShouldUseResources()
	return true
end

function tenebris_fade_strike:OnSpellStart()

end

---------------------------------------------------------------------------------------------------

modifier_tenebris_fade_strike_lod = modifier_tenebris_fade_strike_lod or class({})

function modifier_tenebris_fade_strike_lod:IsHidden()
	return true
end

function modifier_tenebris_fade_strike_lod:IsDebuff()
	return false
end

function modifier_tenebris_fade_strike_lod:IsPurgable()
	return false
end

function modifier_tenebris_fade_strike_lod:RemoveOnDeath()
	return false
end

function modifier_tenebris_fade_strike_lod:OnCreated()
	if not IsServer() then
		return
	end
	self.procRecords = self.procRecords or {}
	local ability = self:GetAbility()
	self.trigger_essence_aura = ability:GetSpecialValueFor("trigger_essence_aura") ~= 0
end

modifier_tenebris_fade_strike_lod.OnRefresh = modifier_tenebris_fade_strike_lod.OnCreated

function modifier_tenebris_fade_strike_lod:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		--MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

-- function modifier_tenebris_fade_strike_lod:GetModifierProjectileName()
	-- if not IsServer() then return end
	-- if self.orb_attack then
		-- return ""
	-- end
-- end

if IsServer() then
	function modifier_tenebris_fade_strike_lod:OnAttackStart(event)
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

		if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and (not parent:IsSilenced()) then
			if ability:GetAutoCastState() == true or parent:GetCurrentActiveAbility() == ability then
				-- Attack projectile change goes here
				self.orb_attack = true
			end
		end
	end

	function modifier_tenebris_fade_strike_lod:OnAttack(event)
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
				parent:EmitSound("Hero_Visage.SoulAssumption.Cast")

				-- Apply a debuff to the attacker
				parent:AddNewModifier(parent, ability, "modifier_tenebris_fade_strike_debuff", {duration = ability:GetLevelSpecialValueFor("duration_debuff", ability:GetLevel() - 1)})
			end
		end
	end

	function modifier_tenebris_fade_strike_lod:OnAttackLanded(event)
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

	function modifier_tenebris_fade_strike_lod:OnAttackFail(event)
		local parent = self:GetParent()

		if event.attacker == parent and self.procRecords[event.record] then
			self.procRecords[event.record] = nil
		end
	end

	function modifier_tenebris_fade_strike_lod:SpellEffect(event)
		if event then
			local attacker = event.attacker or self:GetParent()
			local target = event.target
			local ability = self:GetAbility()
			local ability_lvl = ability:GetLevel() - 1

			-- Don't affect buildings, wards, and invulnerable units.
			if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
				return
			end

			-- Particle 1
			local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_blink_strike.vpcf", PATTACH_ABSORIGIN, attacker)
			ParticleManager:SetParticleControl(particle1, 1, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle1)

			-- Particle 2
			local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(particle2, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle2)

			-- Sound when attack lands
			target:EmitSound("Hero_Visage.SoulAssumption.Target")

			-- Get current attack speed
			local as = attacker:GetAttackSpeed(false) * 100

			-- Get 'attack speed to dmg' percent
			local as_to_dmg = ability:GetLevelSpecialValueFor("bonus_damage", ability_lvl)

			-- Calculate damage
			local dmg = math.floor(as * as_to_dmg * 0.01)

			--attacker:PopupNumbers(target, "damage", Vector(153, 0, 204), 2.0, dmg, nil, POPUP_SYMBOL_POST_EYE)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, attacker, dmg, nil)

			local dmg_table = {
				victim = target,
				attacker = attacker,
				damage = dmg,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK,
				ability = ability,
			}

			ApplyDamage(dmg_table)

			-- Apply the buff to the attacker
			attacker:AddNewModifier(attacker, ability, "modifier_tenebris_fade_strike_buff", {duration = ability:GetLevelSpecialValueFor("duration_buff", ability_lvl)})

			self.procRecords[event.record] = nil
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_tenebris_fade_strike_buff = modifier_tenebris_fade_strike_buff or class({})

function modifier_tenebris_fade_strike_buff:IsHidden()
	return false
end

function modifier_tenebris_fade_strike_buff:IsDebuff()
	return false
end

function modifier_tenebris_fade_strike_buff:IsPurgable()
	return false
end

function modifier_tenebris_fade_strike_buff:RemoveOnDeath()
	return true
end

function modifier_tenebris_fade_strike_buff:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_tenebris_fade_strike_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function modifier_tenebris_fade_strike_buff:GetModifierInvisibilityLevel()
	return 1
end

if IsServer() then
	function modifier_tenebris_fade_strike_buff:OnAbilityExecuted(event)
		local unit = event.unit

		-- Check if unit exists
		if not unit or unit:IsNull() then
			return
		end

		if unit ~= self:GetParent() then
			return
		end

		self:Destroy()
	end

	function modifier_tenebris_fade_strike_buff:OnAttack(event)
		local attacker = event.attacker

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		if attacker ~= self:GetParent() then
			return
		end

		self:Destroy()
	end
end

function modifier_tenebris_fade_strike_buff:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end

function modifier_tenebris_fade_strike_buff:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

---------------------------------------------------------------------------------------------------

modifier_tenebris_fade_strike_debuff = modifier_tenebris_fade_strike_debuff or class({})

function modifier_tenebris_fade_strike_debuff:IsHidden()
	return false
end

function modifier_tenebris_fade_strike_debuff:IsDebuff()
	return true
end

function modifier_tenebris_fade_strike_debuff:IsPurgable()
	return true
end

function modifier_tenebris_fade_strike_debuff:RemoveOnDeath()
	return true
end

function modifier_tenebris_fade_strike_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf"
end

function modifier_tenebris_fade_strike_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW -- PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tenebris_fade_strike_debuff:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end
