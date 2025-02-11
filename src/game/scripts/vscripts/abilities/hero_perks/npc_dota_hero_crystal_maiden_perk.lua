--------------------------------------------------------------------------------------------------------
--		Hero: Crystal Maiden
--		Perk: Arcane Aura free ability + 1% Spell Amp for each level put in a Ice ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_crystal_maiden_perk = modifier_npc_dota_hero_crystal_maiden_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_crystal_maiden_perk:GetTexture()
	return "custom/npc_dota_hero_crystal_maiden_perk"
end

function modifier_npc_dota_hero_crystal_maiden_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("crystal_maiden_brilliance_aura")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("crystal_maiden_brilliance_aura")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
		self:StartIntervalThink(0.1)
    end
end

function modifier_npc_dota_hero_crystal_maiden_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("ice") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_crystal_maiden_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_crystal_maiden_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
