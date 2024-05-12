--------------------------------------------------------------------------------------------------------
--
--		Hero: Dawnbreaker
--		Perk: Dawnbreaker gains 3% hp regen amplification for every level of Light spells she has.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dawnbreaker_perk ~= "" then modifier_npc_dota_hero_dawnbreaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:RemoveOnDeath()
	return false
end

-- function modifier_npc_dota_hero_dawnbreaker_perk:GetTexture()
	-- return "custom/npc_dota_hero_dawnbreaker_perk"
-- end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("light") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:GetModifierHPRegenAmplify_Percentage()
	return self.bonusAmount * self:GetStackCount()
end

function modifier_npc_dota_hero_dawnbreaker_perk:GetModifierLifestealRegenAmplify_Percentage()
	return self.bonusAmount * self:GetStackCount()
end
