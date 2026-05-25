--------------------------------------------------------------------------------------------------------
--    Hero: Ancient Apparition
--    Perk: Ancient Apparition reduces health restoration of targets when a Ice ability debuff is applied.
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

---------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE)

modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze = modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze or class({})

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:IsHidden()
	return true -- cleaner if MODIFIER_ATTRIBUTE_MULTIPLE is a thing
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:IsDebuff()
	return true
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:IsPurgable()
	return false -- we remove this modifier when linked Ice debuff is removed
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:RemoveOnDeath()
	return true -- we remove this modifier on death for sure
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetTexture()
	return "custom/npc_dota_hero_ancient_apparition_perk"
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_RESTORATION_AMPLIFICATION,
	}
end

--function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetDisableHealing()
	--return 1
--end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetModifierPropertyRestorationAmplification()
	return 0 - math.abs(self:GetStackCount())
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:OnCreated(event)
	self.max_heal_reduction = 80

	if IsServer() then
		self.linkedmod = event.linkedmod
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:OnIntervalThink()
	local parent = self:GetParent()
	if not parent or parent:IsNull() then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

	-- Remove this debuff if parent is not affected by linked Ice debuff anymore
	if not self.linkedmod or not parent:HasModifier(self.linkedmod) then
		self:StartIntervalThink(-1)
		self:Destroy()
		return
	end

	local mods = parent:FindAllModifiersByName(self:GetName())
	local number_of_mods = #mods
	if number_of_mods == 0 then
		-- Paradox and prevent division by zero
		return
	end

	local heal_reduction = 100*(1 - ((1 - self.max_heal_reduction / 100) ^ (1/number_of_mods)))
	self:SetStackCount(math.floor(heal_reduction))
end

---------------------------------------------------------------------------------------------------
-- Does not trigger on re-apply / refresh!
function perkAncientApparition(filterTable)
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
		if caster:HasModifier("modifier_npc_dota_hero_ancient_apparition_perk") and ability:HasAbilityFlag("ice") then
			--local modifierDuration = filterTable["duration"]
			--if modifierDuration == -1 then
				--modifierDuration = 3
			--end
			-- we dont use duration so auras can work too
			parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", {linkedmod = modifier_name})
		end
	end
end
