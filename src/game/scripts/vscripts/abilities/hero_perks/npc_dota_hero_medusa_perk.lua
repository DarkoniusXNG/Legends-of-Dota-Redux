--------------------------------------------------------------------------------------------------------
--      Hero: Medusa
--      Perk: Medusa gains mana every time her attacks land. Mana gained is equal to 10% of the attack damage she dealt. And Bonus STR if no Mana Shield.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_medusa_perk = modifier_npc_dota_hero_medusa_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPurgable()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_medusa_perk:GetTexture()
	return "custom/npc_dota_hero_medusa_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:OnCreated()
	local caster = self:GetCaster()
	-- Bonus STR if Medusa does not have Mana Shield
	self.bonus_str_base = 0
	self.bonus_str_per_lvl = 0
	local mana_shield = caster:FindAbilityByName("medusa_mana_shield")
	if not mana_shield then
		self.bonus_str_base = 10
		self.bonus_str_per_lvl = 1
	end
end

function modifier_npc_dota_hero_medusa_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_medusa_perk:OnAttackLanded(params)
    if self:GetParent() == params.attacker then
       self:GetParent():GiveMana(params.damage * 0.1)
    end
end

function modifier_npc_dota_hero_medusa_perk:GetModifierBonusStats_Strength()
	return self.bonus_str_base + self:GetParent():GetLevel() * self.bonus_str_per_lvl
end
