--------------------------------------------------------------------------------------------------------
--      Hero: Ogre Magi
--      Perk: When Ogre Magi casts a spell, he also bloodlusts himself for 20 seconds. And Bonus INT if no Dumb Luck.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_ogre_magi_perk = modifier_npc_dota_hero_ogre_magi_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_ogre_magi_perk:GetTexture()
	return "custom/npc_dota_hero_ogre_magi_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:OnCreated()
	local caster = self:GetCaster()
	self.bloodlust = caster:FindAbilityByName("ogre_magi_bloodlust")
	if not self.bloodlust then
		self.bloodlust = caster:AddAbility("ogre_magi_bloodlust")
		self.bloodlust:SetLevel(1)
		self.bloodlust:SetHidden(true)
	else
		self.bloodlust:UpgradeAbility(false)
	end
	-- Bonus INT if Ogre does not have Dumb Luck
	self.bonus_int_base = 0
	self.bonus_int_per_lvl = 0
	local dumb_luck = caster:FindAbilityByName("ogre_magi_dumb_luck")
	if not dumb_luck then
		self.bonus_int_base = 10
		self.bonus_int_per_lvl = 1
	end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	--local ability = keys.ability
	if hero == keys.unit then
		hero:AddNewModifier(hero,self.bloodlust,"modifier_ogre_magi_bloodlust",{duration=20})
	end
  end
end

function modifier_npc_dota_hero_ogre_magi_perk:GetModifierBonusStats_Intellect()
	return self.bonus_int_base + self:GetParent():GetLevel() * self.bonus_int_per_lvl
end
