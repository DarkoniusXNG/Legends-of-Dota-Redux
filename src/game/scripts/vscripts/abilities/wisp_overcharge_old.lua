LinkLuaModifier("modifier_wisp_overcharge_old", "abilities/wisp_overcharge_old", LUA_MODIFIER_MOTION_NONE)

wisp_overcharge_old = wisp_overcharge_old or class({})

function wisp_overcharge_old:OnToggle()
	local caster = self:GetCaster()
	-- Determine if the toggle is on or off and act on it
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_wisp_overcharge_old",{})
		caster:EmitSound("Hero_Wisp.Overcharge")
		-- If caster uses overcharge after tether:
		if caster:HasModifier("modifier_wisp_tether") then
			local tether = caster:FindAbilityByName("wisp_tether")
			if not tether then
				return
			end
			local radius = tether:GetSpecialValueFor("radius")
			-- Find allies within tether range
			local allies = FindUnitsInRadius(
				caster:GetTeam(),
				caster:GetOrigin(),
				nil,
				radius + 100,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)
			-- Find tethered allies
			for _, ally in pairs(allies) do
				if ally and not ally:IsNull() and ally ~= caster then
					if ally:FindModifierByNameAndCaster("modifier_wisp_tether_haste", caster) then
						ally:AddNewModifier(caster, self, "modifier_wisp_overcharge_old", {})
					end
				end
			end
		end
	else
		caster:StopSound("Hero_Wisp.Overcharge")
		local overcharge_buff = caster:FindModifierByNameAndCaster("modifier_wisp_overcharge_old", caster)
		if overcharge_buff then
			overcharge_buff:Destroy()
		--else
			--caster:RemoveModifierByName("modifier_wisp_overcharge_old")
		end
	end
end

function wisp_overcharge_old:GetManaCost(level)
	local caster = self:GetCaster()
	local mana_cost_per_second_pct = self:GetSpecialValueFor("current_mana_cost_per_second_pct") / 100
	local interval = self:GetSpecialValueFor("drain_interval")
	local mana_cost_per_second = caster:GetMana() * mana_cost_per_second_pct
	local mana_cost_per_interval = mana_cost_per_second * interval
	return mana_cost_per_interval
end

function wisp_overcharge_old:GetHealthCost(level)
	local caster = self:GetCaster()
	local hp_per_second_pct = self:GetSpecialValueFor("current_health_cost_per_second_pct") / 100
	local interval = self:GetSpecialValueFor("drain_interval")
	local hp_per_second = caster:GetHealth() * hp_per_second_pct
	local hp_cost_per_interval = hp_per_second * interval
	return hp_cost_per_interval
end

---------------------------------------------------------------------------------------------------

modifier_wisp_overcharge_old = modifier_wisp_overcharge_old or class({})

function modifier_wisp_overcharge_old:IsHidden()
	return true
end

function modifier_wisp_overcharge_old:IsDebuff()
	return false
end

function modifier_wisp_overcharge_old:IsPurgable()
	return false
end

function modifier_wisp_overcharge_old:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
		self.dmg_reduction = ability:GetSpecialValueFor("dmg_reduction")
		self.interval = ability:GetSpecialValueFor("drain_interval")
	end

	if IsServer() then
		-- Start thinking (draining hp and mana for the caster, checking for tether)
		self:StartIntervalThink(self.interval)
	end
end

function modifier_wisp_overcharge_old:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	-- Caster doesnt exist
	if not caster or caster:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

	if parent == caster then
		if not caster:IsAlive() then
			self:StartIntervalThink(-1)
			self:Destroy()
			ability:ToggleAbility()
			return
		end

		local mana_cost_per_second_pct = ability:GetSpecialValueFor("current_mana_cost_per_second_pct") / 100
		local hp_per_second_pct = ability:GetSpecialValueFor("current_health_cost_per_second_pct") / 100

		local mana_cost_per_second = caster:GetMana() * mana_cost_per_second_pct
		local hp_per_second = caster:GetHealth() * hp_per_second_pct

		local mana_cost_per_interval = mana_cost_per_second * self.interval
		local hp_cost_per_interval = hp_per_second * self.interval

		-- Remove mana
		caster:SpendMana(mana_cost_per_interval, ability)
		-- Apply damage
		ApplyDamage({
			victim = caster,
			attacker = caster,
			damage = hp_cost_per_interval,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = ability,
		})
		
		-- If caster uses tether after overcharge:
		if caster:HasModifier("modifier_wisp_tether") then
			local tether = caster:FindAbilityByName("wisp_tether")
			if not tether then
				return
			end
			local radius = tether:GetSpecialValueFor("radius")
			-- Find allies within tether range
			local allies = FindUnitsInRadius(
				caster:GetTeam(),
				caster:GetOrigin(),
				nil,
				radius + 100,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)
			-- Find tethered allies
			for _, ally in pairs(allies) do
				if ally and not ally:IsNull() and ally ~= caster then
					if ally:FindModifierByNameAndCaster("modifier_wisp_tether_haste", caster) then
						ally:AddNewModifier(caster, self, "modifier_wisp_overcharge_old", {})
					end
				end
			end
		end
	else

		-- Caster is dead
		if not caster:IsAlive() then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		-- Caster is not overcharged
		if not caster:HasModifier("modifier_wisp_overcharge_old") then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		-- No Longer tethered
		if not parent:HasModifier("modifier_wisp_tether_haste") or not caster:HasModifier("modifier_wisp_tether") then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end
	end
end

function modifier_wisp_overcharge_old:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_wisp_overcharge_old:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_wisp_overcharge_old:GetModifierIncomingDamage_Percentage()
	return 0 - math.abs(self.dmg_reduction)
end

function modifier_wisp_overcharge_old:GetEffectName()
	return "particles/units/heroes/hero_wisp/wisp_overcharge.vpcf"
end

function modifier_wisp_overcharge_old:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

