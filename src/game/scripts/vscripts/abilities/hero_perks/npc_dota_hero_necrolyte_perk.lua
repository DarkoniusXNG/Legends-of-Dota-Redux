--------------------------------------------------------------------------------------------------------
--		Hero: Necrolyte
--		Perk: HeartStopper Aura free level + hp regen amp for each level put in an Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_necrolyte_perk = modifier_npc_dota_hero_necrolyte_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:GetTexture()
	return "custom/npc_dota_hero_necrolyte_perk"
end

function modifier_npc_dota_hero_necrolyte_perk:OnCreated()
    self.bonusPerLevel = 1
	if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("necrolyte_heartstopper_aura")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("necrolyte_heartstopper_aura")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
		self:StartIntervalThink(0.1)
    end
end

function modifier_npc_dota_hero_necrolyte_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_necrolyte_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_necrolyte_perk:GetModifierHPRegenAmplify_Percentage()
	return self:GetStackCount()
end
