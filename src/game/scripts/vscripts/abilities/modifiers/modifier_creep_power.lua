modifier_creep_power = class({})

function modifier_creep_power:IsHidden()
    return false
end

function modifier_creep_power:IsPurgable()
    return false
end

function modifier_creep_power:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.3) -- add a delay before action, OnIntervalThink happens only once
	end
end

function modifier_creep_power:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_creep_power:OnIntervalThink()
	local parent = self:GetParent()
    local ability = self:GetAbility()

	if not parent or parent:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

	if not parent:IsAlive() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

    if ability then
		local level = self:GetStackCount()
		local hp_scaling = math.min(120, level) * ability:GetSpecialValueFor("health_per_level")
		local bounty_scaling = level * (ability:GetSpecialValueFor("coef") / 100)
		--local resist_scaling = level * ability:GetSpecialValueFor("resist_per_level")

		--parent:SetBaseMagicalResistanceValue(math.ceil(parent:GetBaseMagicalResistanceValue() + resist_scaling))

		parent:SetMinimumGoldBounty(parent:GetMinimumGoldBounty() + (parent:GetMinimumGoldBounty() * bounty_scaling))
		parent:SetMaximumGoldBounty(parent:GetMaximumGoldBounty() + (parent:GetMaximumGoldBounty() * bounty_scaling))

		parent:SetModelScale(parent:GetModelScale() + (parent:GetModelScale() * 0.01 * math.min(12, level)))

		local should_upgrade_current_hp = true
		local max_hp = parent:GetMaxHealth()
		if parent:GetHealth() ~= max_hp then
			should_upgrade_current_hp = false
		end

		parent:SetBaseMaxHealth(max_hp + hp_scaling)
		parent:SetMaxHealth(max_hp + hp_scaling)
		if should_upgrade_current_hp then
			parent:SetHealth(max_hp + hp_scaling)
		end

		self:StartIntervalThink(-1)
    end
end

function modifier_creep_power:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("damage_per_level") * math.min(120, self:GetStackCount())
end
