modifier_neutral_power = class({})

function modifier_neutral_power:IsHidden()
	return false
end

function modifier_neutral_power:IsPurgable()
	return false
end

function modifier_neutral_power:GetTexture()
	return "custom/neutral_creep_power"
end

function modifier_neutral_power:OnCreated(kv)
	if IsServer() then
		local unit = self:GetParent()

		if unit:GetUnitName() == "npc_dota_roshan" or unit:GetUnitName() == "npc_dota_miniboss" then
			self:Destroy()
			return
		end

		local interval_time = kv.interval_time
		local dotaTime = GameRules:GetDOTATime(false, false)
		local initial_stacks = math.floor(dotaTime / interval_time)

		self:SetStackCount(initial_stacks)
		CalculateNewStats(unit, initial_stacks, true)
		self:StartIntervalThink(interval_time)
	end
end

function modifier_neutral_power:OnIntervalThink()
	self:IncrementStackCount()
	local unit = self:GetParent()
	if not unit or unit:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end
	if not unit:IsAlive() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end
	local stacks = self:GetStackCount()
	CalculateNewStats(unit, stacks, false)
end

function modifier_neutral_power:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_neutral_power:GetModifierBaseAttack_BonusDamage()
	local stacks = self:GetStackCount()
	local damage_per_level = 3

	return damage_per_level * stacks
end

function modifier_neutral_power:GetModifierConstantHealthRegen()
	local stacks = self:GetStackCount()
	local regen_per_level = 0.05

	return regen_per_level * stacks
end

function CalculateNewStats(unit, stacks, firstInstance)
	if IsServer() then
		local health_per_stack = 30
		local extra_gold_per_stack = 1
		local extra_exp_per_stack = 5
		local model_scale_per_stack = 0.005

		-- Increase depending on initial call or interval
		if firstInstance then
			health_per_stack = health_per_stack * stacks
			extra_gold_per_stack = extra_gold_per_stack * stacks
			extra_exp_per_stack = extra_exp_per_stack * stacks
			model_scale_per_stack = model_scale_per_stack * stacks
		end

		-- Modify Scale
		unit:SetModelScale(unit:GetModelScale() + model_scale_per_stack)

		-- Modify Health
		unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() + health_per_stack)
		unit:SetMaxHealth(unit:GetMaxHealth() + health_per_stack)
		unit:SetHealth(unit:GetHealth() + health_per_stack)

		-- Bounties
	    unit:SetDeathXP(unit:GetDeathXP() + extra_exp_per_stack)
	    unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() + extra_gold_per_stack)
	    unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() + extra_gold_per_stack)
	end
end
