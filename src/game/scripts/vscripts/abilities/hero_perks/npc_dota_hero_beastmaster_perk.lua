--------------------------------------------------------------------------------------------------------
--		Hero: Beastmaster
--      Perk: Increases Beastmaster's Strength by 3 for every level put in Non-ultimate Summon or Aura abilities. Beastmaster's summons take less damage while Beastmaster is alive.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_beastmaster_perk = modifier_npc_dota_hero_beastmaster_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_beastmaster_perk:GetTexture()
	return "custom/npc_dota_hero_beastmaster_perk"
end

function modifier_npc_dota_hero_beastmaster_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_npc_dota_hero_beastmaster_perk:OnCreated()
	self.bonusPerLevel = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_beastmaster_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("aura") or skill:HasAbilityFlag("summon_non_ult")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_beastmaster_perk:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_beastmaster_perk:IsAura()
	return true
end

function modifier_npc_dota_hero_beastmaster_perk:GetModifierAura()
	return "modifier_npc_dota_hero_beastmaster_perk_aura_effect"
end

function modifier_npc_dota_hero_beastmaster_perk:GetAuraRadius()
	return 50000
end

function modifier_npc_dota_hero_beastmaster_perk:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_npc_dota_hero_beastmaster_perk:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
end

function modifier_npc_dota_hero_beastmaster_perk:GetAuraEntityReject(hEntity)
	local caster = self:GetParent()
	-- Dont provide the aura effect to allies that you can't control
	if hEntity.GetPlayerOwnerID then
		if hEntity:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_beastmaster_perk_aura_effect", "abilities/hero_perks/npc_dota_hero_beastmaster_perk.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_beastmaster_perk_aura_effect = modifier_npc_dota_hero_beastmaster_perk_aura_effect or class({})

function modifier_npc_dota_hero_beastmaster_perk_aura_effect:IsHidden()
	return true
end

function modifier_npc_dota_hero_beastmaster_perk_aura_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_beastmaster_perk_aura_effect:GetModifierIncomingDamage_Percentage()
	return -20
end
