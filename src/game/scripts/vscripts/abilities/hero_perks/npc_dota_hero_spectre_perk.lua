--------------------------------------------------------------------------------------------------------
--		Hero: Spectre
--		Perk: Spectre gains 100 ms and phased movement towards the target.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_spectre_perk = modifier_npc_dota_hero_spectre_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_spectre_perk:GetTexture()
	return "custom/npc_dota_hero_spectre_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_npc_dota_hero_spectre_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		local phase = params.ability -- For modifier icon
		self.target = phase:GetCursorPosition() or phase:GetCursorTarget()
		if IsServer() then
			self:StartIntervalThink(0.1)
		end
	end
end

if IsServer() then
	function modifier_npc_dota_hero_spectre_perk:OnIntervalThink()
		local parent = self:GetParent()

		if not parent or parent:IsNull() then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
			return
		end

		if not parent:IsAlive() then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
			return
		end

		if not self.target then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
			return
		end

		local target = self.target
		if target.GetAbsOrigin then
			if target.IsAlive then
				if not target:IsAlive() then
					self:SetStackCount(0)
					self:StartIntervalThink(-1)
					return
				end
			end
			target = target:GetAbsOrigin()
		end
		local parent_origin = parent:GetAbsOrigin()
		local parent_facing = parent:GetForwardVector() -- The unit's forward vector is already normal

		local direction = target - parent_origin -- relative position
		direction = direction:Normalized() -- we need to normalize the relative position

		if parent_facing:Dot(direction) > 0.5 then
			self:SetStackCount(100)
		else
			self:SetStackCount(0)
		end
	end
end

function modifier_npc_dota_hero_spectre_perk:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_spectre_perk:CheckState()
	if self:GetStackCount() ~= 0 then
		return {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		}
	else
		return {}
	end
end
