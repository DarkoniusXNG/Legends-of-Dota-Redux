--------------------------------------------------------------------------------------------------------
--
--		Hero: Underlord
--		Perk: Underlord gains +3 to all stats for each level put in a custom ability.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_abyssal_underlord_perk ~= "" then modifier_npc_dota_hero_abyssal_underlord_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:RemoveOnDeath()
	return false
end
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:IsCustomAbility() then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Intellect()
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Agility()
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Strength()
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------

