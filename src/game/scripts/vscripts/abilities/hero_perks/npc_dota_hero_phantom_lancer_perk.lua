--------------------------------------------------------------------------------------------------------
--		Hero: Phantom Lancer
--		Perk: Phantom Lancer Illusions gain bonus move speed.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_phantom_lancer_perk = modifier_npc_dota_hero_phantom_lancer_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_phantom_lancer_perk:GetTexture()
	return "custom/npc_dota_hero_phantom_lancer_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():IsIllusion() then
		return 40
	else
		return 0
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self.apply_to_illusions = true
	end
end
