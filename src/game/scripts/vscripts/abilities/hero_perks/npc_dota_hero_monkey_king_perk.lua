--------------------------------------------------------------------------------------------------------
--      Hero: Monkey King
--      Perk: Jingu Mastery free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_monkey_king_perk = modifier_npc_dota_hero_monkey_king_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_monkey_king_perk:GetTexture()
	return "custom/npc_dota_hero_monkey_king_perk"
end

function modifier_npc_dota_hero_monkey_king_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("monkey_king_jingu_mastery")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("monkey_king_jingu_mastery")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end
