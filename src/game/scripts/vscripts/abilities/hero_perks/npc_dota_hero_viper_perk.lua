--------------------------------------------------------------------------------------------------------
--		Hero: Viper
--		Perk: Poison debuffs applied by Viper reduce the target enemy's armor
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

---------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_viper_armor_debuff", "abilities/hero_perks/npc_dota_hero_viper_perk.lua", LUA_MODIFIER_MOTION_NONE)

modifier_npc_dota_hero_viper_armor_debuff = modifier_npc_dota_hero_viper_armor_debuff or class({})

function modifier_npc_dota_hero_viper_armor_debuff:IsHidden()
	return true -- cleaner if MODIFIER_ATTRIBUTE_MULTIPLE is a thing
end

function modifier_npc_dota_hero_viper_armor_debuff:IsDebuff()
	return true
end

function modifier_npc_dota_hero_viper_armor_debuff:IsPurgable()
	return false -- we remove this modifier when linked Poison debuff is removed
end

function modifier_npc_dota_hero_viper_armor_debuff:RemoveOnDeath()
	return true -- we remove this modifier on death for sure
end

function modifier_npc_dota_hero_viper_armor_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE -- stacks with itself
end

function modifier_npc_dota_hero_viper_armor_debuff:GetTexture()
	return "custom/npc_dota_hero_viper_perk"
end

function modifier_npc_dota_hero_viper_armor_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		--MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_npc_dota_hero_viper_armor_debuff:OnCreated(event)
	self.armor_reduction = 2
	--self.max_magic_resist_reduction = 10
	if IsServer() then
		self.linkedmod = event.linkedmod
		self:StartIntervalThink(0.1)
	end
	-- weird hack because GetPhysicalArmorValue would call below function when calculating armor
	-- so we dont define it until after we calculate armor.
	--self.armorValue = self:GetParent():GetPhysicalArmorValue(false)
	--self.GetModifierPhysicalArmorBonus = function(self) return 0 - math.abs(self.armorValue * self.armor_reduction * 0.01) end
end

--function modifier_npc_dota_hero_viper_armor_debuff:OnRefresh(event)

--end

function modifier_npc_dota_hero_viper_armor_debuff:OnIntervalThink()
	local parent = self:GetParent()
	if not parent or parent:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

	-- Remove this debuff if parent is not affected by linked Poison debuff anymore
	if not self.linkedmod or not parent:HasModifier(self.linkedmod) then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end
end

function modifier_npc_dota_hero_viper_armor_debuff:GetModifierPhysicalArmorBonus()
	return 0 - math.abs(self.armor_reduction)
end

--function modifier_npc_dota_hero_viper_armor_debuff:GetModifierMagicalResistanceBonus()
	--return 0 - math.abs(self.magic_resist_reduction)
--end

---------------------------------------------------------------------------------------------------
-- Does not trigger on re-apply / refresh!
function perkViper(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
	local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	local modifier_name = filterTable["name_const"]
	if not parent_index or not caster_index or not ability_index then
		return
	end
	local parent = EntIndexToHScript( parent_index )
	local caster = EntIndexToHScript( caster_index )
	if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
	local ability = EntIndexToHScript( ability_index )
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_viper_perk") and ability:HasAbilityFlag("poison") then
			--local modifierDuration = filterTable["duration"]
			--if modifierDuration == -1 then
				--modifierDuration = 3
			--end
			-- we dont use duration so auras can work too
			parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_viper_armor_debuff", {linkedmod = modifier_name})
		end
	end
end
