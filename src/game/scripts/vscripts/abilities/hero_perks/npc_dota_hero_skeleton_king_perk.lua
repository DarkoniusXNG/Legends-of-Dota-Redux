--------------------------------------------------------------------------------------------------------
--      Hero: Wraith King
--      Perk: Mortal Strike free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_skeleton_king_perk = modifier_npc_dota_hero_skeleton_king_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_skeleton_king_perk:GetTexture()
	return "custom/npc_dota_hero_skeleton_king_perk"
end

function modifier_npc_dota_hero_skeleton_king_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("skeleton_king_mortal_strike")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("skeleton_king_mortal_strike")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end
