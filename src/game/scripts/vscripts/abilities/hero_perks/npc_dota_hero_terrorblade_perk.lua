--------------------------------------------------------------------------------------------------------
--		Hero: Terrorblade
--		Perk: Terrorblade gains 2 base damage and 2 attack speed for each point in Demon abilities
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_terrorblade_perk = modifier_npc_dota_hero_terrorblade_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_terrorblade_perk:GetTexture()
	return "custom/npc_dota_hero_terrorblade_perk"
end

function modifier_npc_dota_hero_terrorblade_perk:OnCreated()
	self.bonus_stat_per_level = 2
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_terrorblade_perk:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local stacks = 0
		for i = 0, parent:GetAbilityCount() - 1 do
			local skill = parent:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("demon") then
				stacks = stacks + skill:GetLevel() * self.bonus_stat_per_level
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_terrorblade_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_npc_dota_hero_terrorblade_perk:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_terrorblade_perk:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end
