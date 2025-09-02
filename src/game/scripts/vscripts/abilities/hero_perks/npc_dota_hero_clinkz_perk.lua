--------------------------------------------------------------------------------------------------------
--		Hero: Clinkz
--		Perk: Clinkz gains +3 attack damage and +3 attack range for each level put in a Fire or Ranger ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_clinkz_perk = modifier_npc_dota_hero_clinkz_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_clinkz_perk:GetTexture()
	return "custom/npc_dota_hero_clinkz_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:OnCreated()
	self.bonusPerLevel = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_clinkz_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("fire") or skill:HasAbilityFlag("ranger")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_clinkz_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_npc_dota_hero_clinkz_perk:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_clinkz_perk:GetModifierAttackRangeBonus()
	return self:GetStackCount()
end
