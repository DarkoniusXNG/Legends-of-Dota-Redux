--------------------------------------------------------------------------------------------------------
--    Hero: Chen
--    Perk: Chen's summons have 25% Spell Amp, 25% Cooldown Reduction and 25% Mana Cost Reduction while Chen is alive.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_chen_perk = modifier_npc_dota_hero_chen_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_chen_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_chen_perk:GetTexture()
	return "custom/npc_dota_hero_chen_perk"
end

function modifier_npc_dota_hero_chen_perk:IsAura()
	return true
end

function modifier_npc_dota_hero_chen_perk:GetModifierAura()
	return "modifier_npc_dota_hero_chen_perk_aura_effect"
end

function modifier_npc_dota_hero_chen_perk:GetAuraRadius()
	return 50000
end

function modifier_npc_dota_hero_chen_perk:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_npc_dota_hero_chen_perk:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_npc_dota_hero_chen_perk:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_npc_dota_hero_chen_perk:GetAuraEntityReject(hEntity)
	local caster = self:GetParent()
	-- Dont provide the aura effect to allies that you can't control and dont provide to heroes
	if hEntity.GetPlayerOwnerID then
		if hEntity:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then
			return true
		end
		if hEntity == caster or hEntity:IsHero() then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_chen_perk_aura_effect", "abilities/hero_perks/npc_dota_hero_chen_perk.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_chen_perk_aura_effect = modifier_npc_dota_hero_chen_perk_aura_effect or class({})

function modifier_npc_dota_hero_chen_perk_aura_effect:IsHidden()
	return true
end

function modifier_npc_dota_hero_chen_perk_aura_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_chen_perk_aura_effect:GetModifierSpellAmplify_Percentage()
	return 25
end

function modifier_npc_dota_hero_chen_perk_aura_effect:GetModifierPercentageCooldown()
	return 25
end

function modifier_npc_dota_hero_chen_perk_aura_effect:GetModifierPercentageManacostStacking()
	return 25
end
