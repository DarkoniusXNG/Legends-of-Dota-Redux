--------------------------------------------------------------------------------------------------------
--      Hero: Clockwerk
--      Perk: Grants True Strike and Phased Movement during Battery Assault
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_rattletrap_perk = modifier_npc_dota_hero_rattletrap_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:RemoveOnDeath()
    return false
end

-- function modifier_npc_dota_hero_rattletrap_perk:GetTexture()
	-- return "custom/npc_dota_hero_rattletrap_perk"
-- end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_rattletrap_perk:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_rattletrap_perk:OnIntervalThink(keys)
    if IsServer() then
        local caster = self:GetParent()
        if caster:HasModifier("modifier_rattletrap_battery_assault") then
            self:SetStackCount(0)
        else
            self:SetStackCount(1)
        end
    end
end

function modifier_npc_dota_hero_rattletrap_perk:IsHidden()
    return false --self:GetStackCount() == 1
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_rattletrap_perk:CheckState()
    if self:GetStackCount() == 0 then
		return {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_CANNOT_MISS] = true,
		}
	else
		return {}
	end
end
