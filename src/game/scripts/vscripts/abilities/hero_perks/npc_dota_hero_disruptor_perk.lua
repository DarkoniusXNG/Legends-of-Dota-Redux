--------------------------------------------------------------------------------------------------------
--    Hero: Disruptor
--    Perk: Disruptor gains +10 cast range and +1% Mana Regen Amp for each level put in a Lightning ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_disruptor_perk = modifier_npc_dota_hero_disruptor_perk or class({})

function modifier_npc_dota_hero_disruptor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_disruptor_perk:GetTexture()
	return "custom/npc_dota_hero_disruptor_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:OnCreated()
	self.bonusPerLevel = 1
	self.castRangePerLevel = 10
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_disruptor_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_disruptor_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_disruptor_perk:GetModifierCastRangeBonusStacking()
	return self:GetStackCount() * self.castRangePerLevel
end

function modifier_npc_dota_hero_disruptor_perk:GetModifierMPRegenAmplify_Percentage()
	return self:GetStackCount()
end
