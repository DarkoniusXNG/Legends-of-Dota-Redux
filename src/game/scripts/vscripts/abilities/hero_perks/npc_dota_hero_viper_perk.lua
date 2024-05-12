--------------------------------------------------------------------------------------------------------
--		Hero: Viper
--		Perk: Poison effects applied by Viper lower the target's armor and magic resistance by 10%
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_viper_perk = class({
  IsHidden = function() return false end,
  IsPassive = function() return true end,
  IsPurgable = function() return false end,
  IsPermanent = function() return true end,
  RemoveOnDeath = function() return false end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
  GetTexture = function() return "custom/npc_dota_hero_viper_perk" end,
})
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function perkViper(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_viper_perk") and ability:HasAbilityFlag("poison") then
		local modifierDuration = filterTable["duration"]
        if modifierDuration == -1 then
          modifierDuration = 3
        end
		parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_viper_armor_debuff", {duration = modifierDuration})
    end
  end
end

---------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_npc_dota_hero_viper_armor_debuff", "abilities/hero_perks/npc_dota_hero_viper_perk.lua" , LUA_MODIFIER_MOTION_NONE )

modifier_npc_dota_hero_viper_armor_debuff = class({
  IsHidden = function() return false end,
  IsPurgable = function() return true end,
  GetTexture = function() return "custom/npc_dota_hero_viper_perk" end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,

  DeclareFunctions = function() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,
  GetModifierMagicalResistanceBonus = function(self) return self.debuff end,

  OnCreated = function(self)
    self.debuff = -10
    self.armorValue = self:GetParent():GetPhysicalArmorValue(false)

    --weird hack because GetPhysicalArmorValue would call below function when calcualting armor
    -- so we dont define it until after we calculate armor.
    self.GetModifierPhysicalArmorBonus = function(self) return self.armorValue * self.debuff * 0.01 end
  end,
})
