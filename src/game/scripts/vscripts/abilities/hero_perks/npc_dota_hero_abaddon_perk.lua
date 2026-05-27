--------------------------------------------------------------------------------------------------------
--		Hero: Abaddon
--      Perk: Curse of Avernus free level + 2% Outgoing Healing Amp for each level put in an Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_abaddon_perk = modifier_npc_dota_hero_abaddon_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_abaddon_perk:GetTexture()
	return "custom/npc_dota_hero_abaddon_perk"
end

function modifier_npc_dota_hero_abaddon_perk:OnCreated()
	self.bonusPerLevel = 2
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("abaddon_frostmourne")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else 
			bonus_ability = caster:AddAbility("abaddon_frostmourne")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_abaddon_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("undead") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_abaddon_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		--MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}
end

function modifier_npc_dota_hero_abaddon_perk:GetModifierHealAmplify_PercentageSource()
	return self:GetStackCount()
end

--function modifier_npc_dota_hero_abaddon_perk:GetModifierHealAmplify_PercentageTarget()
	--return self:GetStackCount()
--end
