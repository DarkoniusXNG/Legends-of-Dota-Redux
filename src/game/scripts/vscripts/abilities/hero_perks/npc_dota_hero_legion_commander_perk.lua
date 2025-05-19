--------------------------------------------------------------------------------------------------------
--		Hero: Legion Commander
--		Perk: Legion Commander gains +1% damage reduction for each allied creep in 700 radius around her. Allied heroes grant +2% damage reduction.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_legion_commander_perk = modifier_npc_dota_hero_legion_commander_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_legion_commander_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_legion_commander_perk:GetTexture()
	return "custom/npc_dota_hero_legion_commander_perk"
end

function modifier_npc_dota_hero_legion_commander_perk:OnCreated(keys)
	self.radius = 700
	self.dmg_reduction_per_creep = 1
	self.dmg_reduction_per_hero = 2
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

if IsServer() then
	function modifier_npc_dota_hero_legion_commander_perk:OnIntervalThink()
		local parent = self:GetParent()

		if not parent or parent:IsNull() then
			self:StartIntervalThink(-1)
			return
		end

		if not parent:IsAlive() then
			return
		end

		local parent_origin = parent:GetAbsOrigin()
		-- Check if tree is nearby
		if self.radius then
			-- Count units and real heroes
			local number_of_creeps = 0
			local number_of_heroes = 0
			local allies = FindUnitsInRadius(
				parent:GetTeamNumber(),
				parent_origin,
				parent,
				self.radius,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
				FIND_ANY_ORDER,
				false
			)

			for _, unit in pairs(allies) do
				if unit and not unit:IsNull() and unit.IsRealHero then
					if unit:IsRealHero() and unit ~= parent then
						number_of_heroes = number_of_heroes + 1
					elseif not unit:IsHero() then
						number_of_creeps = number_of_creeps + 1
					end
				end
			end

			self:SetStackCount(number_of_creeps * self.dmg_reduction_per_creep + number_of_heroes * self.dmg_reduction_per_hero)
		else
			self:SetStackCount(0)
		end
	end
end

function modifier_npc_dota_hero_legion_commander_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_legion_commander_perk:GetModifierIncomingDamage_Percentage()
	if not IsServer() then
		return
	end
	return 0 - math.abs(self:GetStackCount())
end
