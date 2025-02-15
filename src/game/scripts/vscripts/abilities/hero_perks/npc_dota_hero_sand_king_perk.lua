--------------------------------------------------------------------------------------------------------
--		Hero: Sand King
--		Perk: Sand King gains +1% Spell Amp, +1% Cooldown Reduction and +1% Mana Cost Reduction for each level put in an Earth ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_sand_king_perk = modifier_npc_dota_hero_sand_king_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_sand_king_perk:GetTexture()
	return "custom/npc_dota_hero_sand_king_perk"
end

function modifier_npc_dota_hero_sand_king_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_sand_king_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("earth") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_sand_king_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_sand_king_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_sand_king_perk:GetModifierPercentageCooldown()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_sand_king_perk:GetModifierPercentageManacostStacking()
	return self:GetStackCount()
end
