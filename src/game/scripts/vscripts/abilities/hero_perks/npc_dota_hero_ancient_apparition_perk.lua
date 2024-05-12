--------------------------------------------------------------------------------------------------------
--    Hero: Ancient Apparition
--    Perk: Ancient Apparition disables the health restoration of targets when a Ice ability debuff is applied.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_ancient_apparition_perk = modifier_npc_dota_hero_ancient_apparition_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:RemoveOnDeath()
  return false
end

function modifier_npc_dota_hero_ancient_apparition_perk:GetTexture()
	return "custom/npc_dota_hero_ancient_apparition_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze = modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze or class({})
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:IsPurgable()
	return false
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetTexture()
	return "ancient_apparition_ice_blast"
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_DISABLE_HEALING,
  }
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetDisableHealing()
  return 1
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:OnCreated(event)
	if IsServer() then
		self.linkedmod = event.linkedmod
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:OnIntervalThink()
	local parent = self:GetParent()
	-- Remove this debuff if parent is not affected by ice debuff anymore
	if not self.linkedmod or not parent:HasModifier(self.linkedmod) then
		self:StartIntervalThink(-1)
		self:Destroy()
	end
end
--------------------------------------------------------------------------------------------------------
function perkAncientApparition(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  local modifier_name = filterTable["name_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_ancient_apparition_perk") and ability:HasAbilityFlag("ice") then
        local modifierDuration = filterTable["duration"]
        if modifierDuration == -1 then
          modifierDuration = 3
        end
        parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", {duration = modifierDuration, linkedmod = modifier_name})
    end
  end
end
