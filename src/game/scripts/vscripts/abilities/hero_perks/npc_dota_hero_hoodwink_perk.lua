--------------------------------------------------------------------------------------------------------
--		Hero: Hoodwink
--		Perk: Hoodwink gets 2% damage amp for each tree in 400 radius around her
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_hoodwink_perk = modifier_npc_dota_hero_hoodwink_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:RemoveOnDeath()
	return false
end

-- function modifier_npc_dota_hero_hoodwink_perk:GetTexture()
	-- return "custom/npc_dota_hero_hoodwink_perk"
-- end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:OnCreated(keys)
    self.tree_radius = 400
    self.damage_amp_per_tree = 2
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

if IsServer() then
	function modifier_npc_dota_hero_hoodwink_perk:OnIntervalThink()
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
		if self.tree_radius and GridNav:IsNearbyTree(parent_origin, self.tree_radius, true) then
			-- Count trees
			local number_of_trees = 1
			local trees = GridNav:GetAllTreesAroundPoint(parent_origin, self.tree_radius, true)
			if trees then
				number_of_trees = #trees
			end

			self:SetStackCount(number_of_trees)
		else
			self:SetStackCount(0)
		end
	end
end

function modifier_npc_dota_hero_hoodwink_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_npc_dota_hero_hoodwink_perk:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount() * self.damage_amp_per_tree
end

function modifier_npc_dota_hero_hoodwink_perk:OnTooltip()
	return self:GetStackCount() * self.damage_amp_per_tree
end
