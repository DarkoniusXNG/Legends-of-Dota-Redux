--------------------------------------------------------------------------------------------------------
--		Hero: Lina
--		Perk: Lina gains Intelligence and Spell Amp for each level put in a Fire ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_lina_perk = modifier_npc_dota_hero_lina_perk or class({})
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

function modifier_npc_dota_hero_lina_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

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

function modifier_npc_dota_hero_lina_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_lina_perk:GetModifierBonusStats_Intellect()
	return 3 * self:GetStackCount()
end

function modifier_npc_dota_hero_lina_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
