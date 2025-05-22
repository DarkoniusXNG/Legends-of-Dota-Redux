--------------------------------------------------------------------------------------------------------
--		Hero: Skywrath Mage
--		Perk: Skywrath Mage gains Intelligence and Mana Cost Reduction for each level put in a Light ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_skywrath_mage_perk = modifier_npc_dota_hero_skywrath_mage_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_skywrath_mage_perk:GetTexture()
	return "custom/npc_dota_hero_skywrath_mage_perk"
end

function modifier_npc_dota_hero_skywrath_mage_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_skywrath_mage_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_skywrath_mage_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_skywrath_mage_perk:GetModifierBonusStats_Intellect()
	return 3 * self:GetStackCount()
end

function modifier_npc_dota_hero_skywrath_mage_perk:GetModifierPercentageManacostStacking()
	return 2 * self:GetStackCount()
end
