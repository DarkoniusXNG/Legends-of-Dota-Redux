--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_snapfire_perk = modifier_npc_dota_hero_snapfire_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_snapfire_perk:GetTexture()
	return "custom/npc_dota_hero_snapfire_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_snapfire_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local lucky_shot = caster:FindAbilityByName("pangolier_lucky_shot")

		if lucky_shot then
			lucky_shot:UpgradeAbility(false)
		else
			lucky_shot = caster:AddAbility("pangolier_lucky_shot")
			--lucky_shot:SetStolen(true)
			lucky_shot:SetActivated(true)
			lucky_shot:SetLevel(1)
		end
	end
end
