pudge_flesh_heap_aoe = class({})

LinkLuaModifier("modifier_flesh_heap_aoe", "abilities/pudge_flesh_heap_aoe.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_aoe:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_aoe:GetIntrinsicModifierName()
  return "modifier_flesh_heap_aoe"
end

function pudge_flesh_heap_aoe:GetCastRange(location, target)
  return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_aoe = class({})

function modifier_flesh_heap_aoe:IsHidden()
	return false
end

function modifier_flesh_heap_aoe:IsDebuff()
	return false
end

function modifier_flesh_heap_aoe:IsPurgable()
	return false
end

function modifier_flesh_heap_aoe:RemoveOnDeath()
	return false
end

function modifier_flesh_heap_aoe:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_value_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
	self:ReEquipAllItems()
end

function modifier_flesh_heap_aoe:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_aoe:ReEquipAllItems()
  if not IsServer() then
    return
  end

  local parent = self:GetParent()
  for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
    local item = parent:GetItemInSlot(i)
    if item then
      local name = item:GetAbilityName()
      if not string.find(name, "ultimate_scepter") and not string.find(name, "gungir") then
        item:OnUnequip()
        item:OnEquip()
      end
    end
  end

  local tp_scroll = parent:GetItemInSlot(DOTA_ITEM_TP_SCROLL)
  if tp_scroll and tp_scroll:GetAbilityName() == "item_tpscroll" then
    tp_scroll:OnUnequip()
    tp_scroll:OnEquip()
  end
end

function modifier_flesh_heap_aoe:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
    MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
  }
end

local ignored_abilities = {
  --arc_warden_flux = true,
  --phantom_assassin_blur = true,
  --spectre_desolate = true,
  item_gungir = true,
  --item_dezun_bloodrite = true,
}

function modifier_flesh_heap_aoe:GetModifierOverrideAbilitySpecial(keys)
  local ability = keys.ability
  if not ability or not keys.ability_special_value then
    return 0
  end
  if ignored_abilities and ignored_abilities[ability:GetAbilityName()] then
    return 0
  end
  local ability_kvs = GetAbilityKeyValuesByName(ability:GetAbilityName())
  if ability_kvs.AbilityValues and ability_kvs.AbilityValues[keys.ability_special_value] then
    -- print("Keyvalue for ability: "..ability:GetAbilityName())
    -- print("Key: "..tostring(keys.ability_special_value))
    -- print("Value: "..tostring(ability_kvs.AbilityValues[keys.ability_special_value]))
    if type(ability_kvs.AbilityValues[keys.ability_special_value]) == "table" then
      local affected_kv = ability_kvs.AbilityValues[keys.ability_special_value].affected_by_aoe_increase
      -- print("value of affected_by_aoe_increase: ")
      -- print(affected_kv)
      if affected_kv then
        if tonumber(affected_kv) == 1 then
          --print("Affected Key: "..tostring(keys.ability_special_value))
          --print("it is affected")
          return 1
        end
      end
    end
  end

  return 0
end

function modifier_flesh_heap_aoe:GetModifierOverrideAbilitySpecialValue(keys)
  local parent = self:GetParent()
  local ability = keys.ability
  if not ability or not keys.ability_special_value then
    return
  end
  if ignored_abilities and ignored_abilities[ability:GetAbilityName()] then
    return value
  end
  local value = ability:GetLevelSpecialValueNoOverride(keys.ability_special_value, keys.ability_special_level)
  local ability_kvs = GetAbilityKeyValuesByName(ability:GetAbilityName())
  if ability_kvs.AbilityValues and ability_kvs.AbilityValues[keys.ability_special_value] then
    if type(ability_kvs.AbilityValues[keys.ability_special_value]) == "table" then
      local affected_kv = ability_kvs.AbilityValues[keys.ability_special_value].affected_by_aoe_increase
      if affected_kv then
        if tonumber(affected_kv) == 1 then
          return value + parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
        end
      end
    end
  end

  return value
end
