--------------------------------------------------------------------------------------------------------
--    Hero: Storm Spirit
--    Perk: Storm Spirit gains +1% Spell Amp and +3% Attack Speed for each level put in a Lightning ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_storm_spirit_perk = modifier_npc_dota_hero_storm_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_storm_spirit_perk:GetTexture()
	return "custom/npc_dota_hero_storm_spirit_perk"
end

function modifier_npc_dota_hero_storm_spirit_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_storm_spirit_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("lightning") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_storm_spirit_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_storm_spirit_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_storm_spirit_perk:GetModifierAttackSpeedPercentage()
	return 3 * self:GetStackCount()
end

