LinkLuaModifier("modifier_item_desolator_lod_passive", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_desolator_lod_consumed", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_desolator_lod_debuff", "items/desolator.lua", LUA_MODIFIER_MOTION_NONE)

item_desolator_consumable = item_desolator_consumable or class({})

function item_desolator_consumable:GetIntrinsicModifierName()
  return "modifier_item_desolator_lod_passive"
end

function item_desolator_consumable:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Stats for consumed item
	local damage = self:GetSpecialValueFor("bonus_damage") --+ self:GetSpecialValueFor("max_damage")
	local armor_reduction = self:GetSpecialValueFor("corruption_armor")
	local debuff_duration = self:GetSpecialValueFor("corruption_duration")

	if caster == target and not caster:HasModifier("modifier_item_desolator_lod_consumed") then
		caster:AddNewModifier(caster, self, "modifier_item_desolator_lod_consumed", {dmg = damage, armor = armor_reduction, dur = debuff_duration})

		self:SpendCharge()
	end
end

function item_desolator_consumable:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	-- Check if its the caster thats targetted
	if caster ~= target then
		return UF_FAIL_CUSTOM
	end

	-- Check if already consumed
	if caster:HasModifier("modifier_item_desolator_lod_consumed") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function item_desolator_consumable:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster ~= target then
		return "#consumable_items_only_self"
	end

	if caster:HasModifier("modifier_item_desolator_lod_consumed") then
		return "#consumable_items_already_consumed"
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_passive = modifier_item_desolator_lod_passive or class({})

function modifier_item_desolator_lod_passive:IsHidden()
  return true
end

function modifier_item_desolator_lod_passive:IsDebuff()
  return false
end

function modifier_item_desolator_lod_passive:IsPurgable()
  return false
end

function modifier_item_desolator_lod_passive:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_desolator_lod_passive:IsFirstItemInInventory()
  local parent = self:GetParent()
  local ability = self:GetAbility()

  if parent:IsNull() or ability:IsNull() then
    return false
  end

  if not IsServer() then
    print("IsFirstItemInInventory will not return the correct result on the client!")
    return
  end

  return parent:FindAllModifiersByName(self:GetName())[1] == self
end

function modifier_item_desolator_lod_passive:OnCreated()
  local ability = self:GetAbility()
  if ability and not ability:IsNull() then
    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
  end
end

modifier_item_desolator_lod_passive.OnRefresh = modifier_item_desolator_lod_passive.OnCreated

function modifier_item_desolator_lod_passive:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	MODIFIER_PROPERTY_PROJECTILE_NAME,
  }
end

function modifier_item_desolator_lod_passive:GetModifierProjectileName()
  if self:IsFirstItemInInventory() then
    return "particles/items_fx/desolator_projectile.vpcf"
  end
end

function modifier_item_desolator_lod_passive:GetModifierPreAttack_BonusDamage()
  return self.bonus_damage or self:GetAbility():GetSpecialValueFor("bonus_damage")
end

if IsServer() then
  function modifier_item_desolator_lod_passive:OnAttackLanded(event)
    if not self:IsFirstItemInInventory() then
      return
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local target = event.target

    if parent ~= event.attacker then
      return
    end

    if parent:IsIllusion() then
      return
    end

    -- To prevent crashes:
    if not target or target:IsNull() then
      return
    end

    -- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
    -- items don't have that method -> nil; if the target is an item, don't continue
    if target.GetUnitName == nil then
      return
    end

    -- Doesn't work on allies
    if target:GetTeamNumber() == parent:GetTeamNumber() then
      return
    end

    -- Calculate duration of the debuff
    local armor_reduction_duration = ability:GetSpecialValueFor("corruption_duration")
    -- Calculate duration while keeping status resistance in mind
    --local armor_reduction_duration = target:GetValueChangedByStatusResistance(armor_reduction_duration)
    -- Apply passive debuff
    target:AddNewModifier(parent, ability, "modifier_item_desolator_lod_debuff", {duration = armor_reduction_duration})
  end
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_debuff = modifier_item_desolator_lod_debuff or class({})

function modifier_item_desolator_lod_debuff:IsHidden()
  return false
end

function modifier_item_desolator_lod_debuff:IsDebuff()
  return true
end

function modifier_item_desolator_lod_debuff:IsPurgable()
  return true
end

function modifier_item_desolator_lod_debuff:OnCreated(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("corruption_armor")
	else
		if IsServer() then
			self.armor_reduction = event.armor
			self:SetHasCustomTransmitterData(true)
		end
	end
end

function modifier_item_desolator_lod_debuff:OnRefresh(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("corruption_armor")
	else
		if IsServer() then
			self.armor_reduction = self.armor_reduction or event.armor
			self:SendBuffRefreshToClients(true)
		end
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_desolator_lod_debuff:AddCustomTransmitterData()
    return {
        armor_reduction = self.armor_reduction,
    }
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_desolator_lod_debuff:HandleCustomTransmitterData(data)
    self.armor_reduction = data.armor_reduction
end

function modifier_item_desolator_lod_debuff:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
end

function modifier_item_desolator_lod_debuff:GetModifierPhysicalArmorBonus()
  return 0 - math.abs(self.armor_reduction)
end

function modifier_item_desolator_lod_debuff:GetTexture()
  return "item_desolator"
end

---------------------------------------------------------------------------------------------------

modifier_item_desolator_lod_consumed = modifier_item_desolator_lod_consumed or class({})

function modifier_item_desolator_lod_consumed:IsHidden()
  return false
end

function modifier_item_desolator_lod_consumed:IsPurgable()
  return false
end

function modifier_item_desolator_lod_consumed:IsDebuff()
  return false
end

function modifier_item_desolator_lod_consumed:RemoveOnDeath()
  return false
end

function modifier_item_desolator_lod_consumed:GetTexture()
  return "item_desolator"
end

function modifier_item_desolator_lod_consumed:OnCreated(event)
	if IsServer() then
		self:SetStackCount(0 - event.dmg)
		self.armor = event.armor
		self.dur = event.dur
	end
end

function modifier_item_desolator_lod_consumed:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	MODIFIER_PROPERTY_PROJECTILE_NAME,
  }
end

function modifier_item_desolator_lod_consumed:GetModifierProjectileName()
  if not self:GetParent():HasModifier("modifier_item_desolator_lod_passive") then
    return "particles/items_fx/desolator_projectile.vpcf"
  end
end

function modifier_item_desolator_lod_consumed:GetModifierPreAttack_BonusDamage()
  return math.abs(self:GetStackCount())
end

if IsServer() then
  function modifier_item_desolator_lod_consumed:OnAttackLanded(event)
    local parent = self:GetParent()

	if parent:HasModifier("modifier_item_desolator_lod_passive") then
      return
    end

    local target = event.target

    if parent ~= event.attacker then
      return
    end

    if parent:IsIllusion() then
      return
    end

    -- To prevent crashes:
    if not target or target:IsNull() then
      return
    end

    -- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
    -- items don't have that method -> nil; if the target is an item, don't continue
    if target.GetUnitName == nil then
      return
    end

    -- Doesn't work on allies
    if target:GetTeamNumber() == parent:GetTeamNumber() then
      return
    end

    -- Calculate duration of the debuff
    local armor_reduction_duration = self.dur
    -- Calculate duration while keeping status resistance in mind
    --local armor_reduction_duration = target:GetValueChangedByStatusResistance(armor_reduction_duration)
    -- Apply passive debuff
    target:AddNewModifier(parent, nil, "modifier_item_desolator_lod_debuff", {duration = armor_reduction_duration, armor = self.armor})
  end
end
