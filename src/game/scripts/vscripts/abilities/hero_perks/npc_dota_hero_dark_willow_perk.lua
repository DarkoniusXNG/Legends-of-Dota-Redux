--------------------------------------------------------------------------------------------------------
--		Hero: Dark Willow
--		Perk: Dark Willow gains +3 to all stats for each level put in a support ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_dark_willow_perk = modifier_npc_dota_hero_dark_willow_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_dark_willow_perk:GetTexture()
	return "custom/npc_dota_hero_dark_willow_perk"
end

function modifier_npc_dota_hero_dark_willow_perk:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:OnCreated()
	self.bonusPerLevel = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("support") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end
