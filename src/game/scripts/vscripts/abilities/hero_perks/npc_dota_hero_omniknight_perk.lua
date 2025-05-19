--------------------------------------------------------------------------------------------------------
--		Hero: Omniknight
--		Perk: Omniknight gains +3 Strength and +2%% Healing Amp for each level put in an Light or Support ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_omniknight_perk = modifier_npc_dota_hero_omniknight_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_omniknight_perk:GetTexture()
	return "custom/npc_dota_hero_omniknight_perk"
end

function modifier_npc_dota_hero_omniknight_perk:OnCreated(keys)
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_omniknight_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("light") or skill:HasAbilityFlag("support")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_omniknight_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}
end

function modifier_npc_dota_hero_omniknight_perk:GetModifierBonusStats_Strength()
	return self:GetStackCount() * 3
end

function modifier_npc_dota_hero_omniknight_perk:GetModifierHealAmplify_PercentageSource()
	return self:GetStackCount() * 2
end

function modifier_npc_dota_hero_omniknight_perk:GetModifierHealAmplify_PercentageTarget()
	return self:GetStackCount() * 2
end
