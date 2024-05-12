--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_void_spirit_perk = modifier_npc_dota_hero_void_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_void_spirit_perk:GetTexture()
	return "custom/npc_dota_hero_void_spirit_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_void_spirit_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("black_drake_magic_amplification_aura")
		if ab then
			--ab:SetLevel(1)
			ab:UpgradeAbility(false)
		else
			ab = caster:AddAbility("black_drake_magic_amplification_aura")
            --ab:SetStolen(true)
			ab:SetActivated(true)
			ab:SetLevel(1)
			ab:SetHidden(false)
		end
	end
end
