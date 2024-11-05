LinkLuaModifier("modifier_item_assault_lod_passive", "items/assault.lua", LUA_MODIFIER_MOTION_NONE) -- hidden
LinkLuaModifier("modifier_item_assault_lod_consumed", "items/assault.lua", LUA_MODIFIER_MOTION_NONE) -- visible
LinkLuaModifier("modifier_item_assault_lod_aura_handler", "items/assault.lua", LUA_MODIFIER_MOTION_NONE) -- hidden
LinkLuaModifier("modifier_item_assault_lod_aura_allies", "items/assault.lua", LUA_MODIFIER_MOTION_NONE) -- visible
LinkLuaModifier("modifier_item_assault_lod_aura_enemies", "items/assault.lua", LUA_MODIFIER_MOTION_NONE) -- visible

item_assault_consumable = item_assault_consumable or class({})

function item_assault_consumable:GetIntrinsicModifierName()
	return "modifier_item_assault_lod_passive"
end

function item_assault_consumable:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Prevent Tempest Double abuse
	if caster:IsTempestDouble() or target:IsTempestDouble() then
		return
	end

	-- Stats for consumed item
	local attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	local armor = self:GetSpecialValueFor("bonus_armor")
	local aura_radius = self:GetSpecialValueFor("aura_radius")
	local aura_as = self:GetSpecialValueFor("aura_attack_speed")
	local aura_pos_armor = self:GetSpecialValueFor("aura_positive_armor")
	local aura_neg_armor = self:GetSpecialValueFor("aura_negative_armor")

	local table_to_send = {
		as = attack_speed,
		armor = armor,
		aura_radius = aura_radius,
	}

	if caster == target and not caster:HasModifier("modifier_item_assault_lod_consumed") then
		caster:AddNewModifier(caster, self, "modifier_item_assault_lod_consumed", table_to_send)
		caster:EmitSound("DOTA_Item.IronTalon.Activate")
		caster.assault_attack_speed_aura_lod = aura_as
		caster.assault_bonus_armor_aura_lod = aura_pos_armor
		caster.assault_minus_armor_aura_lod = aura_neg_armor
		self:SpendCharge(0.1)
	end
end

function item_assault_consumable:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	-- Check if its the caster thats targetted
	if caster ~= target then
		return UF_FAIL_CUSTOM
	end

	-- Check if already consumed
	if caster:HasModifier("modifier_item_assault_lod_consumed") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function item_assault_consumable:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster ~= target then
		return "#consumable_items_only_self"
	end

	if caster:HasModifier("modifier_item_assault_lod_consumed") then
		return "#consumable_items_already_consumed"
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_assault_lod_passive = modifier_item_assault_lod_passive or class({})

function modifier_item_assault_lod_passive:IsHidden()
	return true
end

function modifier_item_assault_lod_passive:IsDebuff()
	return false
end

function modifier_item_assault_lod_passive:IsPurgable()
	return false
end

function modifier_item_assault_lod_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_assault_lod_passive:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
		self.armor = ability:GetSpecialValueFor("bonus_armor")
		self.aura_radius = ability:GetSpecialValueFor("aura_radius")
	end
end

modifier_item_assault_lod_passive.OnRefresh = modifier_item_assault_lod_passive.OnCreated

function modifier_item_assault_lod_passive:IsAura()
	return true
end

function modifier_item_assault_lod_passive:GetAuraRadius()
	return self.aura_radius or 1200
end

function modifier_item_assault_lod_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_assault_lod_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_assault_lod_passive:GetModifierAura()
	return "modifier_item_assault_lod_aura_handler"
end

function modifier_item_assault_lod_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_assault_lod_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_assault_lod_passive:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

-- function modifier_item_assault_consumable:OnIntervalThink()
  -- if not self:GetAbility() then 
    -- self:Destroy()
    -- return
  -- end
  -- if not self:GetCaster():IsAlive() then
    -- return
  -- end
  -- local caster = self:GetCaster()
  -- local radius = self:GetAbility():GetSpecialValueFor("assault_aura_radius")
  -- local units = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_BUILDING,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
  -- for k,v in pairs(units) do
    -- if not v:HasModifier("modifier_item_assault_lod_aura_enemies") then
      -- local modifier = v:AddNewModifier(caster,self:GetAbility(),"modifier_item_assault_lod_aura_enemies",{})
      -- modifier:SetDuration(-1,true)
      -- modifier:SetDuration(0.5,false)
    -- else
      -- v:FindModifierByName("modifier_item_assault_lod_aura_enemies"):SetDuration(-1,true)
      -- v:FindModifierByName("modifier_item_assault_lod_aura_enemies"):SetDuration(0.5,false)
    -- end
  -- end
-- end

---------------------------------------------------------------------------------------------------

modifier_item_assault_lod_consumed = modifier_item_assault_lod_consumed or class({})

function modifier_item_assault_lod_consumed:IsHidden()
	return false
end

function modifier_item_assault_lod_consumed:IsDebuff()
	return false
end

function modifier_item_assault_lod_consumed:IsPurgable()
	return false
end

function modifier_item_assault_lod_consumed:GetTexture()
	return "item_assault"
end

function modifier_item_assault_lod_consumed:OnCreated(event)
	if IsServer() then
		self.attack_speed = event.as
		self.armor = event.armor
		self.aura_radius = event.aura_radius
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_item_assault_lod_consumed:OnRefresh(event)
	if IsServer() then
		self.attack_speed = self.attack_speed or event.as
		self.armor = self.armor or event.armor
		self.aura_radius = self.aura_radius or event.aura_radius
		self:SendBuffRefreshToClients()
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_assault_lod_consumed:AddCustomTransmitterData()
	return {
		attack_speed = self.attack_speed,
		armor = self.armor,
		aura_radius = self.aura_radius,
	}
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_assault_lod_consumed:HandleCustomTransmitterData(data)
	self.attack_speed = data.attack_speed
	self.armor = data.armor
	self.aura_radius = data.aura_radius
end

function modifier_item_assault_lod_consumed:IsAura()
	return true
end

function modifier_item_assault_lod_consumed:GetAuraRadius()
	return self.aura_radius or 1200
end

function modifier_item_assault_lod_consumed:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_assault_lod_consumed:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_assault_lod_consumed:GetModifierAura()
	return "modifier_item_assault_lod_aura_handler"
end

function modifier_item_assault_lod_consumed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_assault_lod_consumed:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_assault_lod_consumed:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

---------------------------------------------------------------------------------------------------

modifier_item_assault_lod_aura_handler = modifier_item_assault_lod_aura_handler or class({})

function modifier_item_assault_lod_aura_handler:IsHidden()
	return true
end

function modifier_item_assault_lod_aura_handler:IsDebuff()
	return false
end

function modifier_item_assault_lod_aura_handler:IsPurgable()
	return false
end

function modifier_item_assault_lod_aura_handler:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.attack_speed = ability:GetSpecialValueFor("aura_attack_speed")
		self.armor_bonus = ability:GetSpecialValueFor("aura_positive_armor")
		self.armor_reduction = ability:GetSpecialValueFor("aura_negative_armor")
	elseif IsServer() then
		local caster = self:GetCaster()
		if caster and not caster:IsNull() then
			self.attack_speed = caster.assault_attack_speed_aura_lod
			self.armor_bonus = caster.assault_bonus_armor_aura_lod
			self.armor_reduction = caster.assault_minus_armor_aura_lod
		end

		-- If everything above failed:
		if not self.attack_speed then
			self.attack_speed = 30
		end
		if not self.armor_bonus then
			self.armor_bonus = 5
		end
		if not self.armor_reduction then
			self.armor_reduction = 5
		end

		-- Send data to the client
		self:SetHasCustomTransmitterData(true)
	end

	if IsServer() then
		self:StartIntervalThink(1/30)
	end
end

function modifier_item_assault_lod_aura_handler:OnRefresh()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.attack_speed = ability:GetSpecialValueFor("aura_attack_speed")
		self.armor_bonus = ability:GetSpecialValueFor("aura_positive_armor")
		self.armor_reduction = ability:GetSpecialValueFor("aura_negative_armor")
	elseif IsServer() then
		local caster = self:GetCaster()
		if caster and not caster:IsNull() then
			self.attack_speed = caster.assault_attack_speed_aura_lod
			self.armor_bonus = caster.assault_bonus_armor_aura_lod
			self.armor_reduction = caster.assault_minus_armor_aura_lod
		end

		-- If everything above failed:
		if not self.attack_speed then
			self.attack_speed = 30
		end
		if not self.armor_bonus then
			self.armor_bonus = 5
		end
		if not self.armor_reduction then
			self.armor_reduction = 5
		end

		self:SendBuffRefreshToClients()
	end
end

-- Handles visibility of the enemy debuff if owner of Assault Cuirass is invisible or in fog
function modifier_item_assault_lod_aura_handler:OnIntervalThink()
	if self:GetParent():CanEntityBeSeenByMyTeam(self:GetCaster()) then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_assault_lod_aura_handler:AddCustomTransmitterData()
	return {
		attack_speed = self.attack_speed,
		armor_bonus = self.armor_bonus,
		armor_reduction = self.armor_reduction,
	}
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_assault_lod_aura_handler:HandleCustomTransmitterData(data)
	self.attack_speed = data.attack_speed
	self.armor_bonus = data.armor_bonus
	self.armor_reduction = data.armor_reduction
end

function modifier_item_assault_lod_aura_handler:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end 

function modifier_item_assault_lod_aura_handler:GetModifierPhysicalArmorBonus()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if caster:GetTeamNumber() == parent:GetTeamNumber() then
		return math.abs(self.armor_bonus)
	else
		return 0 - math.abs(self.armor_reduction)
	end
end

function modifier_item_assault_lod_aura_handler:GetModifierAttackSpeedBonus_Constant()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if caster:GetTeamNumber() == parent:GetTeamNumber() then
		return self.attack_speed
	else
		return 0
	end
end

function modifier_item_assault_lod_aura_handler:IsAura()
	return true
end

function modifier_item_assault_lod_aura_handler:GetModifierAura()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if caster:GetTeamNumber() == parent:GetTeamNumber() then
		return "modifier_item_assault_lod_aura_allies"
	elseif self:GetStackCount() == 0 then
		return "modifier_item_assault_lod_aura_enemies"
	end
end

function modifier_item_assault_lod_aura_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_assault_lod_aura_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

-- function modifier_item_assault_lod_aura_handler:GetAuraSearchFlags()
	-- return bit.bor(DOTA_UNIT_TARGET_FLAG_INVULNERABLE, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD)
-- end

function modifier_item_assault_lod_aura_handler:GetAuraRadius()
	return 10
end

function modifier_item_assault_lod_aura_handler:GetAuraEntityReject(entity)
	local parent = self:GetParent()
	-- Dont provide the aura effect to other units
	return entity ~= parent
end

---------------------------------------------------------------------------------------------------

modifier_item_assault_lod_aura_allies = modifier_item_assault_lod_aura_allies or class({})

function modifier_item_assault_lod_aura_allies:IsHidden()
	return false
end

function modifier_item_assault_lod_aura_allies:IsDebuff()
	return false
end

function modifier_item_assault_lod_aura_allies:IsPurgable()
	return false
end

function modifier_item_assault_lod_aura_allies:GetTexture()
	return "item_assault"
end

---------------------------------------------------------------------------------------------------

modifier_item_assault_lod_aura_enemies = modifier_item_assault_lod_aura_enemies or class({})

function modifier_item_assault_lod_aura_enemies:IsHidden()
	return false
end

function modifier_item_assault_lod_aura_enemies:IsDebuff()
	return true
end

function modifier_item_assault_lod_aura_enemies:IsPurgable()
	return false
end

function modifier_item_assault_lod_aura_enemies:GetTexture()
	return "item_assault"
end
