--------------------------------------------------------------------------------------------------------
--		Hero: Earth Spirit
--		Perk: Earth Spirit gains 3 damage for each point in Earth Abilities.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_earth_spirit_perk = modifier_npc_dota_hero_earth_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsHidden()
	return false
end

-- function modifier_npc_dota_hero_earth_spirit_perk:GetTexture()
	-- return "custom/npc_dota_hero_earth_spirit_perk"
-- end

function modifier_npc_dota_hero_earth_spirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------


function modifier_npc_dota_hero_earth_spirit_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_earth_spirit_perk:OnCreated()
	self.baseDamage = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_earth_spirit_perk:OnIntervalThink()
	if IsServer() then
		local spirit = self:GetParent()
		local stacks = 0
		for i = 0, spirit:GetAbilityCount() - 1 do
			local skill = spirit:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("earth") then
				stacks = stacks + skill:GetLevel() * self.baseDamage
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_earth_spirit_perk:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
