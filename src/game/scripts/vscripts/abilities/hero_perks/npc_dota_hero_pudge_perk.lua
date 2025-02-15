--------------------------------------------------------------------------------------------------------
--		Hero: Pudge
--		Perk: Pudge gains 0.1 Strength for each enemy creep kill and for each enemy creep death within 250 radius.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_pudge_perk = modifier_npc_dota_hero_pudge_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_pudge_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_pudge_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_pudge_perk:GetTexture()
	return "custom/npc_dota_hero_pudge_perk"
end

function modifier_npc_dota_hero_pudge_perk:OnCreated(keys)
	self.range = 250
	self.str_per_stack = 0.1
end

function modifier_npc_dota_hero_pudge_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_npc_dota_hero_pudge_perk:GetModifierBonusStats_Strength()
	if self.str_per_stack then
		return self:GetStackCount() * self.str_per_stack
	end

	return 0
end

if IsServer() then
	function modifier_npc_dota_hero_pudge_perk:OnDeath(event)
		local parent = self:GetParent()
		local killer = event.attacker
		local dead = event.unit

		-- Doesn't work on illusions of Pudge or when Pudge is dead
		if parent:IsIllusion() or not parent:IsAlive() then
			return
		end

		-- Don't continue if the killer doesn't exist
		if not killer or killer:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if dead unit isn't something weird (an item, rune etc.)
		if dead.GetUnitName == nil then
			return
		end

		-- Don't trigger on Pudge deaths and allied deaths
		if parent == dead or dead:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		--Stacks don't increase when killing a buildings, wards or illusions
		if dead:IsTower() or dead:IsBarracks() or dead:IsBuilding() or dead:IsOther() or dead:IsIllusion() then
			return
		end

		local parent_loc = parent:GetAbsOrigin()
		local dead_loc = dead:GetAbsOrigin()
		local parentToDeadVector = dead_loc - parent_loc
		local isDeadInRange = parentToDeadVector:Length2D() <= self.range

		if isDeadInRange or killer == parent and not dead:IsHero() then
			self:IncrementStackCount()
		end
	end
end
