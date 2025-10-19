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
end

function modifier_flesh_heap_aoe:OnRefresh()
	self:OnCreated()
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
}

local forbidden_kvs = {
  --magnataur_reverse_polarity = {pull_radius = true, max_knockback_distance = true,},
}

function modifier_flesh_heap_aoe:GetModifierOverrideAbilitySpecial(keys)
  local ability = keys.ability
  if not ability or not keys.ability_special_value then
    return 0
  end
  if ignored_abilities and ignored_abilities[ability:GetAbilityName()] then
    return 0
  end
  if forbidden_kvs and forbidden_kvs[ability:GetAbilityName()] then
    local t = forbidden_kvs[ability:GetAbilityName()]
    if t[keys.ability_special_value] then
      return 0
    end
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
    return 0
  end
  if ignored_abilities and ignored_abilities[ability:GetAbilityName()] then
    return value
  end
  if forbidden_kvs and forbidden_kvs[ability:GetAbilityName()] then
    local t = forbidden_kvs[ability:GetAbilityName()]
    if t[keys.ability_special_value] then
      return value
    end
  end
  local value = ability:GetLevelSpecialValueNoOverride(keys.ability_special_value, keys.ability_special_level)
  if not value or value == 0 then
    return value
  end
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
