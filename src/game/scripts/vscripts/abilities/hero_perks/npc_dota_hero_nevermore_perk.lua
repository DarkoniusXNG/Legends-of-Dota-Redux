--------------------------------------------------------------------------------------------------------
--      Hero: Shadow Fiend
--      Perk: Shadow Fiend gains 1 free level of Presence of the Dark Lord, whether he has it or not.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_nevermore_perk = modifier_npc_dota_hero_nevermore_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_nevermore_perk:GetTexture()
	return "custom/npc_dota_hero_nevermore_perk"
end

function modifier_npc_dota_hero_nevermore_perk:OnCreated()
 	if IsServer() then
		local caster = self:GetParent()
		local bonus_ability = caster:FindAbilityByName("nevermore_dark_lord")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("nevermore_dark_lord")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end
