--------------------------------------------------------------------------------------------------------
--		Hero: Io (Wisp)
--		Perk: Essence Aura free ability + 1% Spell Amp for each level put in a Light ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_wisp_perk = modifier_npc_dota_hero_wisp_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:GetTexture()
	return "custom/npc_dota_hero_wisp_perk"
end

function modifier_npc_dota_hero_wisp_perk:OnCreated()
    self.bonusPerLevel = 1
	if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("obsidian_destroyer_essence_aura_lod")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("obsidian_destroyer_essence_aura_lod")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
		self:StartIntervalThink(0.1)
    end
end

function modifier_npc_dota_hero_wisp_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_wisp_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_wisp_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
