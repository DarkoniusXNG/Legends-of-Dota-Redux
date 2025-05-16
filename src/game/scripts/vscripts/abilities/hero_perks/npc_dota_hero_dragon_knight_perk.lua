--------------------------------------------------------------------------------------------------------
--		Hero: Dragon Knight
--		Perk: Dragon Knight gains +1% Damage Amp for each level put in a Draconic ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_dragon_knight_perk = modifier_npc_dota_hero_dragon_knight_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_dragon_knight_perk:GetTexture()
	return "custom/npc_dota_hero_dragon_knight_perk"
end

function modifier_npc_dota_hero_dragon_knight_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_dragon_knight_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("dragon") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_dragon_knight_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_dragon_knight_perk:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount()
end
