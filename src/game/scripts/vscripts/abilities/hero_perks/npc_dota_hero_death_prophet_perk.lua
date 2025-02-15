--------------------------------------------------------------------------------------------------------
--    Hero: Death Prophet
--    Perk: Death Prophet gains +1% Spell Amp for each level put in a Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_death_prophet_perk = modifier_npc_dota_hero_death_prophet_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPurgable()
  return false
end

function modifier_npc_dota_hero_death_prophet_perk:GetTexture()
	return "custom/npc_dota_hero_death_prophet_perk"
end

function modifier_npc_dota_hero_death_prophet_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_death_prophet_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("undead") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_death_prophet_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_death_prophet_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
