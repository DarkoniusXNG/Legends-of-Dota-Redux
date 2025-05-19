--------------------------------------------------------------------------------------------------------
--		Hero: Muerta
--		Perk: Gunslinger free ability + 3 attack damage for each point in an Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_muerta_perk = modifier_npc_dota_hero_muerta_perk or class({})

function modifier_npc_dota_hero_muerta_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_muerta_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_muerta_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_muerta_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_muerta_perk:GetTexture()
	return "muerta_pierce_the_veil"
end

function modifier_npc_dota_hero_muerta_perk:OnCreated()
	self.bonusPerLevel = 3
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("muerta_gunslinger")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else 
			bonus_ability = caster:AddAbility("muerta_gunslinger")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_muerta_perk:OnIntervalThink()
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

function modifier_npc_dota_hero_muerta_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_npc_dota_hero_muerta_perk:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
