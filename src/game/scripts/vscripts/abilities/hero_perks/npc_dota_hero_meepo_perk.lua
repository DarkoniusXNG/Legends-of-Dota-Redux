--------------------------------------------------------------------------------------------------------
--		Hero: Meepo
--		Perk: Increases all damage by 5% for every other Meepo on your team.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_meepo_perk = modifier_npc_dota_hero_meepo_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_meepo_perk:OnCreated()
	self.bonusPerMeepo = 5
	if not IsServer() then return end
	self:StartIntervalThink(0.2)
end

function modifier_npc_dota_hero_meepo_perk:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_meepo_perk:OnIntervalThink()
	if not IsServer() then return end
	
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()

	local otherMeepos = 0
	for _, hero in pairs(heroes) do
		if hero ~= caster and hero:HasModifier("modifier_npc_dota_hero_meepo_perk") and hero:IsRealHero() and hero:IsAlive() and hero:GetTeamNumber() == caster:GetTeamNumber() then
			otherMeepos = otherMeepos + 1
		end
	end
	self:SetStackCount(otherMeepos)
end

function modifier_npc_dota_hero_meepo_perk:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount() * self.bonusPerMeepo
end
