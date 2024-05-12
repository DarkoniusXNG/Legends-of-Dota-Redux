--------------------------------------------------------------------------------------------------------
--		Hero: Drow Ranger
--		Perk: Bonus 3 agility for each level in Ranger spell.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_drow_ranger_perk = modifier_npc_dota_hero_drow_ranger_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_drow_ranger_perk:GetTexture()
	return "custom/npc_dota_hero_drow_ranger_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:OnIntervalThink()
	if IsServer() then
		local stacks = 0
		local caster = self:GetParent()
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("ranger") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:GetModifierBonusStats_Agility()
	return self.bonusAmount * self:GetStackCount()
end
