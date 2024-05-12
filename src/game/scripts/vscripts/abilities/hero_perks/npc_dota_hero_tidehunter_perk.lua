--------------------------------------------------------------------------------------------------------
--
--		Hero: Tidehunter
--		Perk: Bonus 5 Damage Block for each level in Water spell
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tidehunter_perk ~= "" then modifier_npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:OnCreated()
	self.bonusPerLevel = 5
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("water") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:GetModifierPhysical_ConstantBlock()
	return self.bonusAmount * self:GetStackCount()
end

