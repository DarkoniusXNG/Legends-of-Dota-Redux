--------------------------------------------------------------------------------------------------------
--
--		Hero: Lina
--		Perk: Increases Lina's intelligence by 3 for each level put in fire-type spells.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lina_perk ~= "" then modifier_npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lina_perk:GetTexture()
	return "custom/npc_dota_hero_lina_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("fire") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:GetModifierBonusStats_Intellect(params)
	return self.bonusAmount * self:GetStackCount()
end
