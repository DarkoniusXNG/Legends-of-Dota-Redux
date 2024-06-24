--------------------------------------------------------------------------------------------------------
--		Hero: Naga Siren
--		Perk: Naga Siren illusions will receive 25% less damage.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_naga_siren_perk = modifier_npc_dota_hero_naga_siren_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_naga_siren_perk:GetTexture()
	return "naga_siren_mirror_image"
end

function modifier_npc_dota_hero_naga_siren_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_naga_siren_perk:GetModifierIncomingDamage_Percentage()
	if not IsServer() then
		return
	end
	if self:GetParent():IsIllusion() then
		return -25
	end
end

function modifier_npc_dota_hero_naga_siren_perk:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self.apply_to_illusions = true
	end
end
