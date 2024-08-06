LinkLuaModifier("modifier_item_heart_lod_passive", "items/heart.lua", LUA_MODIFIER_MOTION_NONE) -- hidden
LinkLuaModifier("modifier_item_heart_lod_consumed", "items/heart.lua", LUA_MODIFIER_MOTION_NONE) -- visible

item_heart_consumable = item_heart_consumable or class({})

function item_heart_consumable:GetIntrinsicModifierName()
	return "modifier_item_heart_lod_passive"
end

function item_heart_consumable:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Prevent Tempest Double abuse
	if caster:IsTempestDouble() or target:IsTempestDouble() then
		return
	end

	-- Stats for consumed item
	local str = self:GetSpecialValueFor("bonus_strength")
	local hp = self:GetSpecialValueFor("bonus_health")
	local regen = self:GetSpecialValueFor("health_regen_pct")

	local table_to_send = {
		str = str,
		hp = hp,
		regen = regen,
	}

	if caster == target and not caster:HasModifier("modifier_item_heart_lod_consumed") then
		caster:AddNewModifier(caster, self, "modifier_item_heart_lod_consumed", table_to_send)
		caster:EmitSound("DOTA_Item.Cheese.Activate")
		self:SpendCharge(0.1) -- Removes the item without errors or crashes, and the modifier loses the ability reference
	end
end

function item_heart_consumable:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	-- Check if its the caster thats targetted
	if caster ~= target then
		return UF_FAIL_CUSTOM
	end

	-- Check if already consumed
	if caster:HasModifier("modifier_item_heart_lod_consumed") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function item_heart_consumable:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster ~= target then
		return "#consumable_items_only_self"
	end
	--local ab  = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
	--if not ab then
		--return "#consumable_items_no_available_slot"
	--end
	if caster:HasModifier("modifier_item_heart_lod_consumed") then
		return "#consumable_items_already_consumed"
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_heart_lod_passive = modifier_item_heart_lod_passive or class({})

function modifier_item_heart_lod_passive:IsHidden()
	return true
end

function modifier_item_heart_lod_passive:IsDebuff()
	return false
end

function modifier_item_heart_lod_passive:IsPurgable()
	return false
end

function modifier_item_heart_lod_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_heart_lod_passive:IsFirstItemInInventory()
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

function modifier_item_heart_lod_passive:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_item_heart_lod_passive:OnRefresh()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.str = ability:GetSpecialValueFor("bonus_strength")
		self.hp = ability:GetSpecialValueFor("bonus_health")
		self.regen = ability:GetSpecialValueFor("health_regen_pct")
	end

	if IsServer() then
		self:OnIntervalThink()
	end
end

function modifier_item_heart_lod_passive:OnIntervalThink()
	if self:IsFirstItemInInventory() then
		self:SetStackCount(2)
	else
		self:SetStackCount(1)
	end
end

function modifier_item_heart_lod_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end

function modifier_item_heart_lod_passive:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_heart_lod_passive:GetModifierHealthBonus()
	return self.hp
end

function modifier_item_heart_lod_passive:GetModifierHealthRegenPercentage()
	-- Prevent regen stacking when having multiple Hearts
	if self:GetStackCount() == 2 then
		return self.regen
	else
		return 0
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_heart_lod_consumed = modifier_item_heart_lod_consumed or class({})

function modifier_item_heart_lod_consumed:IsHidden()
	return false
end

function modifier_item_heart_lod_consumed:IsPurgable()
	return false
end

function modifier_item_heart_lod_consumed:IsDebuff()
	return false
end

function modifier_item_heart_lod_consumed:RemoveOnDeath()
	return false
end

function modifier_item_heart_lod_consumed:GetTexture()
	return "item_heart"
end

function modifier_item_heart_lod_consumed:OnCreated(event)
	if IsServer() then
		self:SetStackCount(0 - event.str)
		self.hp = event.hp
		self.regen = event.regen
		-- Regen needs a transmitter
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_item_heart_lod_consumed:OnRefresh(event)
	if IsServer() then
		self.regen = self.regen or event.regen
		-- Needs transmitters
		self:SendBuffRefreshToClients()
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_heart_lod_consumed:AddCustomTransmitterData()
    return {
        regen = self.regen,
    }
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_heart_lod_consumed:HandleCustomTransmitterData(data)
    self.regen = data.regen
end

function modifier_item_heart_lod_consumed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end

function modifier_item_heart_lod_consumed:GetModifierBonusStats_Strength()
	return math.abs(self:GetStackCount())
end

function modifier_item_heart_lod_consumed:GetModifierHealthBonus()
	return self.hp
end

function modifier_item_heart_lod_consumed:GetModifierHealthRegenPercentage()
	-- Prevent Consumed Heart regen stacking when Hearts in the inventory
	if self:GetParent():HasModifier("modifier_item_heart_lod_passive") then
		return 0
	end
	return self.regen
end
