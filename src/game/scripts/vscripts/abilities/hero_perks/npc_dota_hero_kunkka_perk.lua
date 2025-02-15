--------------------------------------------------------------------------------------------------------
--		Hero: Kunkka
--		Perk: Kunkka gains +1% Damage Amp for each level put in a Water ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_kunkka_perk = modifier_npc_dota_hero_kunkka_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kunkka_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_kunkka_perk:GetTexture()
	return "custom/npc_dota_hero_kunkka_perk"
end

function modifier_npc_dota_hero_kunkka_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_kunkka_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("water") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_kunkka_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_kunkka_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	return self:GetStackCount()
end
