--------------------------------------------------------------------------------------------------------
--		Hero: Ember Spirit
--		Perk: Ember Spirit gains +3 Agility and +2% Mana Cost Reduction for each level put in a Fire ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_ember_spirit_perk = modifier_npc_dota_hero_ember_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_ember_spirit_perk:GetTexture()
	return "custom/npc_dota_hero_ember_spirit_perk"
end

function modifier_npc_dota_hero_ember_spirit_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_ember_spirit_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_ember_spirit_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_ember_spirit_perk:GetModifierBonusStats_Agility()
	return 3 * self:GetStackCount()
end

function modifier_npc_dota_hero_ember_spirit_perk:GetModifierPercentageManacostStacking()
	return 2 * self:GetStackCount()
end
