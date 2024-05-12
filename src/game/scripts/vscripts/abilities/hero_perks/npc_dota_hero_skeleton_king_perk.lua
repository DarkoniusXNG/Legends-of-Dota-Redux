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

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local crit = caster:FindAbilityByName("skeleton_king_mortal_strike")

		if crit then
            crit:UpgradeAbility(false)
        else
            crit = caster:AddAbility("skeleton_king_mortal_strike")
            --crit:SetStolen(true)
            crit:SetActivated(true)
            crit:SetLevel(1)
        end
	end
end
