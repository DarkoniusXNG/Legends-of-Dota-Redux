--------------------------------------------------------------------------------------------------------
--		Hero: Bloodseeker
--		Perk: Bloodseeker gains +1% Spell Amp, +1% Lifesteal Amp and +1% Mana Regen Amp for each level put in a Blood ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_bloodseeker_perk = modifier_npc_dota_hero_bloodseeker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_bloodseeker_perk:GetTexture()
	return "custom/npc_dota_hero_bloodseeker_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_bloodseeker_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("blood") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_bloodseeker_perk:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
	MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
  }
end

function modifier_npc_dota_hero_bloodseeker_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_bloodseeker_perk:GetModifierLifestealRegenAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_bloodseeker_perk:GetModifierMPRegenAmplify_Percentage()
	return self:GetStackCount()
end


