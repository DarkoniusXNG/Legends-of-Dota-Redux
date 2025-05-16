--------------------------------------------------------------------------------------------------------
--		Hero: Tusk
--		Perk: Tusk gains 3 damage for each point in an Ice ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_tusk_perk = modifier_npc_dota_hero_tusk_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_tusk_perk:GetTexture()
	return "custom/npc_dota_hero_tusk_perk"
end

function modifier_npc_dota_hero_tusk_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_npc_dota_hero_tusk_perk:OnCreated()
	self.baseDamage = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_tusk_perk:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local stacks = 0
		for i = 0, parent:GetAbilityCount() - 1 do
			local skill = parent:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("ice") then
				stacks = stacks + skill:GetLevel() * self.baseDamage
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_tusk_perk:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
